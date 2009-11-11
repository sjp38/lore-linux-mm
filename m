Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D36BB6B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 23:35:44 -0500 (EST)
Date: Wed, 11 Nov 2009 12:35:40 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 6/6] mm: sigbus instead of abusing oom
Message-ID: <20091111043540.GA22223@localhost>
References: <Pine.LNX.4.64.0911102202500.2816@sister.anvils> <20091111113719.589e61d7.kamezawa.hiroyu@jp.fujitsu.com> <20091111114119.FD53.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091111114119.FD53.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Andi Kleen <andi@firstfloor.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 11, 2009 at 10:42:04AM +0800, KOSAKI Motohiro wrote:
> > On Tue, 10 Nov 2009 22:06:49 +0000 (GMT)
> > Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:
> >
> > > When do_nonlinear_fault() realizes that the page table must have been
> > > corrupted for it to have been called, it does print_bad_pte() and
> > > returns ... VM_FAULT_OOM, which is hard to understand.
> > >
> > > It made some sense when I did it for 2.6.15, when do_page_fault()
> > > just killed the current process; but nowadays it lets the OOM killer
> > > decide who to kill - so page table corruption in one process would
> > > be liable to kill another.
> > >
> > > Change it to return VM_FAULT_SIGBUS instead: that doesn't guarantee
> > > that the process will be killed, but is good enough for such a rare
> > > abnormality, accompanied as it is by the "BUG: Bad page map" message.
> > >
> > > And recent HWPOISON work has copied that code into do_swap_page(),
> > > when it finds an impossible swap entry: fix that to VM_FAULT_SIGBUS too.
> > >
> > > Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> >
> > Thank you !
> > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>
> Thank you, me too.
>
> 	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Thank you!

 	Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>


Some unrelated comments:

We observed that copy_to_user() on a hwpoison page would trigger 3
(duplicate) late kills (the last three lines below):

early kill:
        [   56.964041] virtual address 7fffcab7d000 found in vma
        [   56.964390]  7fffcab7d000 phys b4365000
        [   58.089254] Triggering MCE exception on CPU 0
        [   58.089563] Disabling lock debugging due to kernel taint
        [   58.089914] Machine check events logged
        [   58.090187] MCE exception done on CPU 0
        [   58.090462] MCE 0xb4365: page flags 0x100000000100068=uptodate,lru,active,mmap,anonymous,swapbacked count 1 mapcount 1
        [   58.091878] MCE 0xb4365: Killing copy_to_user_te:3768 early due to hardware memory corruption
        [   58.092425] MCE 0xb4365: dirty LRU page recovery: Recovered
late kill on copy_to_user():
        [   59.136331] Copy 4096 bytes to 00007fffcab7d000
        [   59.136641] MCE: Killing copy_to_user_te:3768 due to hardware memory corruption fault at 7fffcab7d000
        [   59.137231] MCE: Killing copy_to_user_te:3768 due to hardware memory corruption fault at 7fffcab7d000
        [   59.137812] MCE: Killing copy_to_user_te:3768 due to hardware memory corruption fault at 7fffcab7d001

And this patch does not affect it (somehow weird but harmless behavior).

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
