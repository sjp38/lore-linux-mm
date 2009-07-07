Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 918C96B004F
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 09:21:54 -0400 (EDT)
Subject: Re: kmemleak not tainted
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <20090707131725.GB3238@localdomain.by>
References: <20090707115128.GA3238@localdomain.by>
	 <1246970859.9451.34.camel@pc1117.cambridge.arm.com>
	 <20090707131725.GB3238@localdomain.by>
Content-Type: text/plain
Date: Tue, 07 Jul 2009 14:22:21 +0100
Message-Id: <1246972941.9451.44.camel@pc1117.cambridge.arm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2009-07-07 at 16:17 +0300, Sergey Senozhatsky wrote:
> > On Tue, 2009-07-07 at 14:51 +0300, Sergey Senozhatsky wrote:
> > > kernel: [ 1917.133154] INFO: RCU detected CPU 0 stall (t=485140/3000 jiffies)
[...]
> > What I think happens is that the kmemleak thread runs for several
> > seconds for scanning the memory and there may not be any context
> > switches. I have a patch to add more cond_resched() calls throughout the
> > kmemleak_scan() function which I hope will get merged. 
[...]
> > I don't get any  of these messages with CONFIG_PREEMPT enabled.
> 
> It started with rc2-git1 (may be). Almost every scan ends with RCU pending.

Should I assume that CONFIG_PREEMPT is disabled on your system?

The branch with the pending kmemleak patches is below (I sent Linus a
pull request):

http://www.linux-arm.org/git?p=linux-2.6.git;a=shortlog;h=kmemleak

You can try the "Add more cond_resched() calls..." patch and see if it
makes any difference.

> Hm.. Something is broken...
> cat /.../kmemleak
> [ 7933.537868] ================================================
> [ 7933.537873] [ BUG: lock held when returning to user space! ]
> [ 7933.537876] ------------------------------------------------
> [ 7933.537880] cat/2897 is leaving the kernel with locks still held!
> [ 7933.537884] 1 lock held by cat/2897:
> [ 7933.537887]  #0:  (scan_mutex){+.+.+.}, at: [<c10f717c>] kmemleak_open+0x4c/0x80

That the "Do not acquire scan_mutex in kmemleak_open()" patch in the
same branch.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
