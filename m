Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id DEE396B025F
	for <linux-mm@kvack.org>; Tue, 15 Aug 2017 01:30:29 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id c80so5843194oig.7
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 22:30:29 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id g2si5783488oif.17.2017.08.14.22.30.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 14 Aug 2017 22:30:28 -0700 (PDT)
Message-Id: <201708150530.v7F5UHfO096653@www262.sakura.ne.jp>
Subject: Re: [PATCH 2/2] mm, oom: fix potential data corruption when
 =?ISO-2022-JP?B?b29tX3JlYXBlciByYWNlcyB3aXRoIHdyaXRlcg==?=
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Tue, 15 Aug 2017 14:30:17 +0900
References: <20170814135919.GO19063@dhcp22.suse.cz> 
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, akpm@linux-foundation.org, andrea@kernel.org, kirill@shutemov.name, oleg@redhat.com, wenwei.tww@alibaba-inc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Sat 12-08-17 00:46:18, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > On Fri 11-08-17 16:54:36, Tetsuo Handa wrote:
> > > > > Michal Hocko wrote:
> > > > > > On Fri 11-08-17 11:28:52, Tetsuo Handa wrote:
> > > > > > > Will you explain the mechanism why random values are written instead of zeros
> > > > > > > so that this patch can actually fix the race problem?
> > > > > > 
> > > > > > I am not sure what you mean here. Were you able to see a write with an
> > > > > > unexpected content?
> > > > > 
> > > > > Yes. See http://lkml.kernel.org/r/201708072228.FAJ09347.tOOVOFFQJSHMFL@I-love.SAKURA.ne.jp .
> > > > 
> > > > Ahh, I've missed that random part of your output. That is really strange
> > > > because AFAICS the oom reaper shouldn't really interact here. We are
> > > > only unmapping anonymous memory and even if a refault slips through we
> > > > should always get zeros.
> > > > 
> > > > Your test case doesn't mmap MAP_PRIVATE of a file so we shouldn't even
> > > > get any uninitialized data from a file by missing CoWed content. The
> > > > only possible explanations would be that a page fault returned a
> > > > non-zero data which would be a bug on its own or that a file write
> > > > extend the file without actually writing to it which smells like a fs
> > > > bug to me.
> > > 
> > > As I wrote at http://lkml.kernel.org/r/201708112053.FIG52141.tHJSOQFLOFMFOV@I-love.SAKURA.ne.jp ,
> > > I don't think it is a fs bug.
> > 
> > Were you able to reproduce with other filesystems?
> 
> Yes, I can reproduce this problem using both xfs and ext4 on 4.11.11-200.fc25.x86_64
> on Oracle VM VirtualBox on Windows.
> 
> I believe that this is not old data from disk, for I can reproduce this problem
> using newly attached /dev/sdb which has never written any data (other than data
> written by mkfs.xfs and mkfs.ext4).
> 
>   /dev/sdb /tmp ext4 rw,seclabel,relatime,data=ordered 0 0
>   
> The garbage pattern (the last 4096 bytes) is identical for both xfs and ext4.

I can reproduce this problem very easily using btrfs on 4.11.11-200.fc25.x86_64
on Oracle VM VirtualBox on Windows.

  /dev/sdb /tmp btrfs rw,seclabel,relatime,space_cache,subvolid=5,subvol=/ 0 0

The garbage pattern is identical for all xfs/ext4/btrfs.
More complicated things a fs does, more likely to hit this problem?
I tried ntfs but so far I am not able to reproduce this problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
