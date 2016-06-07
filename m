Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0CFB56B0005
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 03:34:32 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id h68so75091316lfh.2
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 00:34:31 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id n1si31777674wjz.36.2016.06.07.00.34.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jun 2016 00:34:29 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id r5so3584332wmr.0
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 00:34:29 -0700 (PDT)
Date: Tue, 7 Jun 2016 09:34:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [linux-next: Tree for Jun 1] __khugepaged_exit
 rwsem_down_write_failed lockup
Message-ID: <20160607073427.GC12305@dhcp22.suse.cz>
References: <20160601131122.7dbb0a65@canb.auug.org.au>
 <20160602014835.GA635@swordfish>
 <20160602092113.GH1995@dhcp22.suse.cz>
 <20160602120857.GA704@swordfish>
 <20160602122109.GM1995@dhcp22.suse.cz>
 <20160603135154.GD29930@redhat.com>
 <20160603144600.GK20676@dhcp22.suse.cz>
 <20160603151001.GG29930@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160603151001.GG29930@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>

On Fri 03-06-16 17:10:01, Andrea Arcangeli wrote:
> Hello Michal,
> 
> CC'ed Hugh,
> 
> On Fri, Jun 03, 2016 at 04:46:00PM +0200, Michal Hocko wrote:
> > What do you think about the external dependencies mentioned above. Do
> > you think this is a sufficient argument wrt. occasional higher
> > latencies?
> 
> It's a tradeoff and both latencies would be short and uncommon so it's
> hard to tell.
> 
> There's also mmput_async for paths that may care about mmput
> latencies. Exit itself cannot use it, it's mostly for people taking
> the mm_users pin that may not want to wait for mmput to run. It also
> shouldn't happen that often, it's a slow path.
> 
> The whole model inherited from KSM is to deliberately depend only on
> the mmap_sem + test_exit + mm_count, and never on mm_users, which to
> me in principle doesn't sound bad.

I do agree that this model is quite clever (albeit convoluted). It just
assumes that all other mmap_sem users are behaving the same. Now most
in-kernel users will do get_task_mm() and then lock mmap_sem, but I
haven't checked all of them and it is quite possible that some of those
would like to optimize in a similar way and only increment mm_count.
I might be too pessimistic about the out of mm code but I would feel
much better if the exit path didn't depend on them.

Anyway, if the current model sounds better I will definitely not insist
on my patch. It is more of an idea for simplification than a fix for
anything I have seen happening in the real life.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
