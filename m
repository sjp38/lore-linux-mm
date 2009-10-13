Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B440E6B009C
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 22:50:16 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9D2oDlx030037
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 13 Oct 2009 11:50:14 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 52E9745DE5A
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 11:50:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 09A5245DE51
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 11:50:11 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D2C9B1DB8041
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 11:50:10 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 73C5F1DB8046
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 11:50:09 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] munmap() don't check sysctl_max_mapcount
In-Reply-To: <Pine.LNX.4.64.0910121512070.2943@sister.anvils>
References: <20091012184654.E4D0.A69D9226@jp.fujitsu.com> <Pine.LNX.4.64.0910121512070.2943@sister.anvils>
Message-Id: <20091013102137.C755.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 13 Oct 2009 11:50:08 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi

> > > If you change your patch so that do_munmap() cannot increase the final
> > > number vmas beyond sysctl_max_map_count, that would seem reasonable.
> > > But would that satisfy your testcase?  And does the testcase really
> > > matter in practice?  It doesn't seem to have upset anyone before.
> > 
> > Very thank you for payed attention to my patch. Yes, this is real issue.
> > my customer suffer from it.
> 
> That's a good reason for a fix; though nothing you say explains why
> they're operating right at the sysctl_max_map_count limit (which is
> likely to give them further surprises), and cannot raise that limit.

Probably, my last mail was not clear a bit. I talked about two thing
at the same time. sorry for ambiguous message.

 (1) custmer faced bug
 (2) my future view

In point (1), the limit itself is not problem at all. the customer
can change it. but nobody accept resource deallocation makes SIGABORT
internally. I think both kernel and glibc have fault.

removing sysctl_max_map_count is only my future view.


> > May I explain why you haven't seen this issue? this issue is architecture
> > independent problem. however register stack architecture (e.g. ia64, sparc)
> > dramatically increase the possibility of the heppen this issue.
> 
> Thanks for going to all this trouble; but I never doubted it could
> happen, nor that some would be more likely to suffer than others.
> 
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

Ah! yes.
I had forgot it. thanks pointing this.

Yes, I agree we can't remove max_mapcount yet.

Side node: My co-worker working on implement enhanced ELF header to gdb,
it's derived from solaris. I expect we can remove the above ushort limitation
in this year.

> One reason will be to limit the amount of kernel memory which can
> be pinned by a user program - why limit their ability to to lock down
> user pages, if we let them run wild with kernel data structures?
> The more important on 32-bit machines with more than 1GB of memory, as
> the lowmem restriction comes to bite.  But I probably should not have
> mentioned that, I fear you'll now go on a hunt for other places where
> we impose no such limit, and embarrass me greatly with the result ;)

hmhm, 32bit, I see.

Side note: 64K max_mapcount restrict number of thread to 32K. there seems
too small in modern 64bit. after solving ELF ushort issue, the default value
on 64bit might be considerable. I think.


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

OK, I agree.

> > Honestly, I doubt nobody suffer from removing sysctl_max_mapcount.
> 
> I expect Kame to disagree with you on that.

I have to say your expection is bingo! ;)


> > And yes, stack unmapping have exceptional charactatics. the guard zone
> > gurantee it never raise map_count. 
> > So, I think the attached patch (0001-Don-t...) is the same as you talked about, right?
> 
> Yes, I've not tested but that looks right to me (I did have to think a
> bit to realize that the case where the munmap spans more than one vma
> is fine with the check you've added).  In the version below I've just
> changed your code comment.

Thank you! 


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

The customer don't need to remove this limit. That's merely my personal
opinion.
Currently, various library and application don't check munmap() return value.  
I have pessimistic expection to change them. In practice, we have two way to
get rid of suffer of munlock return value.
  (1) removing the possibility of error return (i.g. remove sysctl_max_mapcount)
  (2) limitation bump up until usual application never touch its limit.

I thought we can (1). but I've changed my opinion by this mail. probably
(2) is better. but it is long term issue. we can't do it until solving ELF
issue....

Thanks again. you clarified various viewpoint.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
