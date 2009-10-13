Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 300546B0085
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 20:56:08 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9D0u5Ja010178
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 13 Oct 2009 09:56:05 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1469845DE62
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 09:56:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E399C45DE57
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 09:56:04 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C67F31DB803A
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 09:56:04 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6AD781DB8042
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 09:56:04 +0900 (JST)
Date: Tue, 13 Oct 2009 09:53:42 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] munmap() don't check sysctl_max_mapcount
Message-Id: <20091013095342.197c767b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0910121512070.2943@sister.anvils>
References: <20091002180533.5F77.A69D9226@jp.fujitsu.com>
	<Pine.LNX.4.64.0910091007010.17240@sister.anvils>
	<20091012184654.E4D0.A69D9226@jp.fujitsu.com>
	<Pine.LNX.4.64.0910121512070.2943@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, 12 Oct 2009 16:04:08 +0100 (BST)
Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:

> On Mon, 12 Oct 2009, KOSAKI Motohiro wrote:
> > And, I doubt I haven't catch your mention. May I ask some question?
> > Honestly I don't think max_map_count is important knob. it is strange
> > mutant of limit of virtual address space in the process.
> > At very long time ago (probably the stone age), linux doesn't have
> > vma rb_tree handling, then many vma directly cause find_vma slow down.
> > However current linux have good scalability. it can handle many vma issue.
> 
> I think there are probably several different reasons for the limit,
> some perhaps buried in prehistory, yes, and others forgotten.
> 
> One reason is well-known to your colleague, KAMEZAWA-san:
> the ELF core dump format only supports a ushort number of sections.
> 
yes.

> One reason will be to limit the amount of kernel memory which can
> be pinned by a user program - why limit their ability to to lock down
> user pages, if we let them run wild with kernel data structures?
> The more important on 32-bit machines with more than 1GB of memory, as
> the lowmem restriction comes to bite.  But I probably should not have
> mentioned that, I fear you'll now go on a hunt for other places where
> we impose no such limit, and embarrass me greatly with the result ;)
> 
> And one reason will be the long vma->vm_next searches: less of an
> issue nowadays, yes, and preemptible if you have CONFIG_PREEMPT=y;
> but still might be something of a problem.
> 
> > So, Why do you think max_mapcount sould be strictly keeped?
> 
> I don't believe it's the most serious limit we have, and I'm no
> expert on its origins; but I do believe that if we profess to have
> some limit, then we have to enforce it.  If we're going to allow
> anybody to get around the limit, better just throw the limit away.
> 
> > 
> > Honestly, I doubt nobody suffer from removing sysctl_max_mapcount.
> 
> I expect Kame to disagree with you on that.
> 
> > 
> > And yes, stack unmapping have exceptional charactatics. the guard zone
> > gurantee it never raise map_count. 
> > So, I think the attached patch (0001-Don-t...) is the same as you talked about, right?
> 
> Yes, I've not tested but that looks right to me (I did have to think a
> bit to realize that the case where the munmap spans more than one vma
> is fine with the check you've added).  In the version below I've just
> changed your code comment.
> 
> > I can accept it. I haven't test it on ia64. however, at least it works
> > well on x86.
> > 
> > BUT, I still think kernel souldn't refuse any resource deallocation.
> > otherwise, people discourage proper resource deallocation and encourage
> > brutal intentional memory leak programming style. What do you think?
> 
> I think you're a little too trusting.  It's common enough that in order
> to free one resource, we need just a little of another resource; and
> it is frustrating when that other resource is tightly limited.  But if
> somebody owes you 10000 yen, and asks to borrow just another 1000 yen
> to make some arrangement to pay you back, then the next day asks to
> borrow just another 1000 yen to enhance that arrangement, then....
> 
> That's what I'm asking to guard against here.   But if you're so
> strongly against having that limit, please just get your customers
> to raise it to INT_MAX: that should be enough to keep away from
> its practical limitations, shouldn't it?
> 
> 
I discussed with Kosaki. Ah, hmm, reporing our status.

 - Even if we think the program which exceeds max_map_count and go abort()
   as buggy program, we don't think abort() (in library) is very good.
   So, we want to avoid this. 

 - We hear one of our collegue (debugger team) is now preparing ELF-extention
   patches for kernel and gdb. We hear solaris has ELF-extention for handling more
   than 65535 program headers and recent AMD64 ABI draft includes it.
   We now think this extention should go first. We discuss him with our schedule.

 - Considering "too much consume memory" attack, we need some limits.
   Then, we wonder adding
          - system-wide max_map_count (enough large)
          or
          - determine per process max_map_count based on host's memory size.

   BTW, looking sysctl, there is threads-max.

       [kamezawa@bluextal ~]$ cat /proc/sys/kernel/threads-max
       409600

   This number is system-wide and automatically determined at boot.
   But, in fact, there is max_map_count and per process threads-max is determined
   by it. We think this not very neat.
   
 We'll consider more. Probably, we'll start from ELF extention.


Thanks,
-Kame


   






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
