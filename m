Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0E1116B02C4
	for <linux-mm@kvack.org>; Tue,  2 May 2017 10:15:55 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id c15so13595372ith.22
        for <linux-mm@kvack.org>; Tue, 02 May 2017 07:15:55 -0700 (PDT)
Received: from mail1.merlins.org (magic.merlins.org. [209.81.13.136])
        by mx.google.com with ESMTPS id t15si17328793ioi.151.2017.05.02.07.15.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 02 May 2017 07:15:54 -0700 (PDT)
Date: Tue, 2 May 2017 07:15:44 -0700
From: Marc MERLIN <marc@merlins.org>
Message-ID: <20170502141544.rufykv6blliqzqfd@merlins.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <29c02986-f065-d3be-f176-0c190a72bc58@I-love.SAKURA.ne.jp>
 <20170502074432.GB14593@dhcp22.suse.cz>
Subject: Re: 4.8.8 kernel trigger OOM killer repeatedly when I have lots of
 RAM that should be free
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Tejun Heo <tj@kernel.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On Tue, May 02, 2017 at 09:44:33AM +0200, Michal Hocko wrote:
> On Mon 01-05-17 21:12:35, Marc MERLIN wrote:
> > Howdy,
> > 
> > Well, sadly, the problem is more or less back is 4.11.0. The system doesn't really 
> > crash but it goes into an infinite loop with
> > [34776.826800] BUG: workqueue lockup - pool cpus=6 node=0 flags=0x0 nice=0 stuck for 33s!
> > More logs: https://pastebin.com/YqE4riw0
> 
> I am seeing a lot of traces where tasks is waiting for an IO. I do not
> see any OOM report there. Why do you believe this is an OOM killer
> issue?

Good question. This is a followup of the problem I had in 4.8.8 until I
got a patch to fix the issue. Then, it used to OOM and later, to pile up
I/O tasks like this.
Now it doesn't OOM anymore, but tasks still pile up.
I temporarily fixed the issue by doing this:
gargamel:~# echo 0 > /proc/sys/vm/dirty_ratio
gargamel:~# echo 0 > /proc/sys/vm/dirty_background_ratio

of course my performance is abysmal now, but I can at least run btrfs
scrub without piling up enough IO to deadlock the system.

On Tue, May 02, 2017 at 07:44:47PM +0900, Tetsuo Handa wrote:
> > Any idea what I should do next?
> 
> Maybe you can try collecting list of all in-flight allocations with backtraces
> using kmallocwd patches at
> http://lkml.kernel.org/r/1489578541-81526-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
> and http://lkml.kernel.org/r/201704272019.JEH26057.SHFOtMLJOOVFQF@I-love.SAKURA.ne.jp
> which also tracks mempool allocations.
> (Well, the
> 
> -	cond_resched();
> +	//cond_resched();
> 
> change in the latter patch would not be preferable.)

Thanks. I can give that a shot as soon as my current scrub is done, it
may take another 12 to 24H at this rate.
In the meantimne, as explained above, not allowing any dirty VM has
worked around the problem (Linus pointed out to me in the original
thread that on a lightly loaded 24GB system, even 1 or 2% could still be
a lot of memory for requests to pile up in and cause issues in
degenerative cases like mine).
Now I'm still curious what changed betweeen 4.8.8 + custom patches and 4.11 to cause
this.

Marc
-- 
"A mouse is a device used to point at the xterm you want to type in" - A.S.R.
Microsoft is to operating systems ....
                                      .... what McDonalds is to gourmet cooking
Home page: http://marc.merlins.org/                         | PGP 1024R/763BE901

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
