Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 415766B02F1
	for <linux-mm@kvack.org>; Fri, 25 Dec 2015 06:35:41 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id p187so201201137wmp.1
        for <linux-mm@kvack.org>; Fri, 25 Dec 2015 03:35:41 -0800 (PST)
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com. [74.125.82.49])
        by mx.google.com with ESMTPS id e196si63656088wmd.100.2015.12.25.03.35.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Dec 2015 03:35:39 -0800 (PST)
Received: by mail-wm0-f49.google.com with SMTP id p187so198975634wmp.0
        for <linux-mm@kvack.org>; Fri, 25 Dec 2015 03:35:39 -0800 (PST)
Date: Fri, 25 Dec 2015 12:35:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
Message-ID: <20151225113537.GA6754@dhcp22.suse.cz>
References: <1450204575-13052-1-git-send-email-mhocko@kernel.org>
 <CAOxpaSV38vy2ywCqQZggfydWsSfAOVo-q8cn7OcuN86ch=4mEA@mail.gmail.com>
 <20151224094758.GA22760@dhcp22.suse.cz>
 <CAOxpaSXRxJGqL3Fxz5280KZy6xG0ZGwyrf-7i6LArSC0eJsv2A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOxpaSXRxJGqL3Fxz5280KZy6xG0ZGwyrf-7i6LArSC0eJsv2A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ross Zwisler <zwisler@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Thu 24-12-15 13:44:03, Ross Zwisler wrote:
> On Thu, Dec 24, 2015 at 2:47 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Wed 23-12-15 16:00:09, Ross Zwisler wrote:
> > [...]
> >> While running xfstests on next-20151223 I hit a pair of kernel BUGs
> >> that bisected to this commit:
> >>
> >> 1eb3a80d8239 ("mm, oom: introduce oom reaper")
> >
> > Thank you for the report and the bisection.
> >
> >> Here is a BUG produced by generic/029 when run against XFS:
> >>
> >> [  235.751723] ------------[ cut here ]------------
> >> [  235.752194] kernel BUG at mm/filemap.c:208!
> >
> > This is VM_BUG_ON_PAGE(page_mapped(page), page), right? Could you attach
> > the full kernel log? It all smells like a race when OOM reaper tears
> > down the mapping and there is a truncate still in progress. But hitting
> > the BUG_ON just because of that doesn't make much sense to me. OOM
> > reaper is essentially MADV_DONTNEED. I have to think about this some
> > more, though, but I am in a holiday mode until early next year so please
> > bear with me.
> 
> The two stack traces were gathered with next-20151223, so the line numbers
> may have moved around a bit when compared to the actual "mm, oom: introduce
> oom reaper" commit.

I was looking at the same next tree, I believe
$ git describe
next-20151223

[...]
> > There was a warning before this triggered. The full kernel log would be
> > helpful as well.
> 
> Sure, I can gather full kernel logs, but it'll probably after the new year.

OK, I will wait for the logs. It is really interesting to see what was
the timing between OOM killer invocation and this trace.

> > [...]
> >> [  609.425325] Call Trace:
> >> [  609.425797]  [<ffffffff811dc307>] invalidate_inode_pages2+0x17/0x20
> >> [  609.426971]  [<ffffffff81482167>] xfs_file_read_iter+0x297/0x300
> >> [  609.428097]  [<ffffffff81259ac9>] __vfs_read+0xc9/0x100
> >> [  609.429073]  [<ffffffff8125a319>] vfs_read+0x89/0x130
> >> [  609.430010]  [<ffffffff8125b418>] SyS_read+0x58/0xd0
> >> [  609.430943]  [<ffffffff81a527b2>] entry_SYSCALL_64_fastpath+0x12/0x76
> >> [  609.432139] Code: 85 d8 fe ff ff 01 00 00 00 f6 c4 40 0f 84 59 ff
> >> ff ff 49 8b 47 20 48 8d 78 ff a8 01 49 0f 44 ff 8b 47 48 85 c0 0f 88
> >> bd 01 00 00 <0f> 0b 4d 3b 67 08 0f 85 70 ff ff ff 49 f7 07 00 18 00 00
> >> 74 15
> > [...]
> >> My test setup is a qemu guest machine with a pair of 4 GiB PMEM
> >> ramdisk test devices, one for the xfstest test disk and one for the
> >> scratch disk.
> >
> > Is this just a plain ramdisk device or it needs a special configuration?
> 
> Just a plain PMEM ram disk with DAX turned off.  Configuration instructions
> for PMEM can be found here:
> 
> https://nvdimm.wiki.kernel.org/

Thanks I will try to reproduce early next year. But so far I think this
is just a general issue of MADV_DONTNEED vs. truncate and oom_reaper is
just lucky to trigger it. There shouldn't be anything oom_reaper
specific here. Maybe there is some additional locking missing?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
