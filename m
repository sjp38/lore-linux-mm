Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B5BA26B0085
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 04:07:36 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9Q87Xwj017781
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 26 Oct 2010 17:07:33 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id F291C45DE4F
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 17:07:32 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BBEED45DE4E
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 17:07:32 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 34F1D1DB8046
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 17:07:31 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D94761DB8042
	for <linux-mm@kvack.org>; Tue, 26 Oct 2010 17:07:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: mem-hotplug + ksm make lockdep warning
In-Reply-To: <alpine.LSU.2.00.1010252248210.2939@sister.anvils>
References: <20101025193711.917F.A69D9226@jp.fujitsu.com> <alpine.LSU.2.00.1010252248210.2939@sister.anvils>
Message-Id: <20101026163218.B7BF.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 26 Oct 2010 17:07:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hughd@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> On Mon, 25 Oct 2010, KOSAKI Motohiro wrote:
> > Hi Hugh,
> > 
> > commit 62b61f611e(ksm: memory hotremove migration only) makes following
> > lockdep warnings. Is this intentional?
> 
> No, certainly not intentional: thanks for finding this.  Looking back,
> I think the machine I tested memory hotplug versus KSM upon was not
> the machine I habitually ran lockdep on, I bet I forgot to try it.
> 
> > 
> > More detail: current lockdep hieralcy is here.
> 
> And especial thanks for taking the trouble to present it in a way
> that I find much easier to understand than lockdep's pronouncements.
> 
> > 
> > memory_notify
> > 	offline_pages
> > 		lock_system_sleep();
> > 			mutex_lock(&pm_mutex);
> > 		memory_notify(MEM_GOING_OFFLINE)
> > 			__blocking_notifier_call_chain
> > 				down_read(memory_chain.rwsem)
> > 				ksm_memory_callback()
> > 					mutex_lock(&ksm_thread_mutex);  // memory_chain.rmsem -> ksm_thread_mutex order
> > 				up_read(memory_chain.rwsem)
> > 		memory_notify(MEM_OFFLINE)
> > 			__blocking_notifier_call_chain
> > 				down_read(memory_chain.rwsem)		// ksm_thread_mutex -> memory_chain.rmsem order
> > 				ksm_memory_callback()
> > 					mutex_unlock(&ksm_thread_mutex);
> > 				up_read(memory_chain.rwsem)
> > 		unlock_system_sleep();
> > 			mutex_unlock(&pm_mutex);
> > 
> > So, I think pm_mutex protect ABBA deadlock. but it exist only when
> > CONFIG_HIBERNATION=y. IOW, this code is not correct generically. Am I
> > missing something?
> 
> I do remember taking great comfort from lock_system_sleep() i.e. pm_mutex
> when I did the ksm_memory_callback(); but I think that comfort was more
> along the lines of it making obvious that taking a mutex was okay there,
> than it providing any safety.  I think I was unconscious of the issue you
> raise, perhaps didn't even notice rwsem in __blocking_notifier_call_chain.
> 
> But is it really a problem, given that it's down_read(rwsem) in each case?
> Yes, but I had to look up akpm's comment on msync in ChangeLog-2.6.11 to
> remember why:
> 
> 	And yes, the ranking of down_read() versus down() does matter:
> 	
> 		Task A			Task B		Task C
> 	
> 		down_read(rwsem)
> 					down(sem)
> 							down_write(rwsem)
> 		down(sem)
> 					down_read(rwsem)
> 	
> 	C's down_write() will cause B's down_read to block.
> 	B holds `sem', so A will never release `rwsem'.

Yeah, in other word, my raised issue is neccessary following three actor.

A. do memory unplug
B. ditto
C. register new blocking notifier chain

Thus, I don't think this issue is occur so frquently. (Who want to unplug memory
concurrently?) But even though, some arch don't have hibernation support at all
and we need to fix it, maybe.


> 
> Am I mistaken, or is get_any_page() in mm/memory-failure.c also relying
> on lock_system_sleep() to do real locking, even without CONFIG_HIBERNATION?

I think get_any_page() also need to fix. ;)
Andi, please double check.

> If it is, then I think we should solve both problems by making it lock
> unconditionally: though neither "lock_system_sleep" nor "pm_mutex" is an
> appropriate name then... maybe "lock_memory_hotplug", but still using a
> pm_mutex declared outside of CONFIG_PM?  Seems a bit weird.

I agree with making lock_memory_hotplug.

> And some kind of lockdep annotation needed for ksm_memory_callback(),
> to help it understand how the outer mutex makes the inner inversion safe?
> Or does lockdep manage that without help?

I don't know lockdep internal at all. I can only say CONFIG_HIBERNATION=y
still makes this lockdep splat. iow, lockdep can't handle this inner 
inversion safe issue automatically.



> I think I'm not going to find time to do the patch for a while,
> so please go ahead if you can.

I also need to attend KS. So, If you can accept to waiting until middle of 
next month, I'll do.

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
