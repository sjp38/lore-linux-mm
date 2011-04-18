Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id ED6F1900086
	for <linux-mm@kvack.org>; Sun, 17 Apr 2011 21:21:33 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 4FCD13EE0BB
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 10:21:30 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 34F1145DE93
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 10:21:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 160DD45DE8F
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 10:21:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 04374E08002
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 10:21:30 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C2B711DB8038
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 10:21:29 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: mm: convert vma->vm_flags to 64bit
In-Reply-To: <alpine.LSU.2.00.1104171649350.21405@sister.anvils>
References: <20110412151116.B50D.A69D9226@jp.fujitsu.com> <alpine.LSU.2.00.1104171649350.21405@sister.anvils>
Message-Id: <20110418102128.933A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 18 Apr 2011 10:21:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Mundt <lethal@linux-sh.org>, Russell King <linux@arm.linux.org.uk>

Hi

> On Tue, 12 Apr 2011, KOSAKI Motohiro wrote:
> > 
> > Benjamin, Hugh, I hope to add your S-O-B to this one because you are original author. 
> > Can I do?
> 
> Well, now you've fixed the mm/fremap.c omission, you're welcome to my
> Acked-by: Hugh Dickins <hughd@google.com>

Thank you!


> I happen not to shared Ben's aversion to unsigned long long, I just
> don't really care one way or another on that; but I do get irritated by
> obfuscatory types which we then have to cast or unfold all over the place,
> I don't know if vm_flags_t would have been in that category or not.

I agree.

> You've made a few different choices than I did, okay: the only place
> where it might be worth disagreeing with you, is on mm->def_flags:
> I would rather make that an unsigned int than an unsigned long long,
> to save 4 bytes on 64-bit (if it were moved) rather than waste 4 bytes
> on 32-bit - in the unlikely event that someone adds a high VM_flag to
> def_flags, I'd rather hope they would test its effect.  However,
> it's every mm not every vma, so maybe not worth worrying about.

Yeap. I thought it is one of typical easy-read-code vs memory-footprint
trade-off. And after I looked size of task_struct, I was lost interest to
spned my time to keep small mm_struct size. ;-)

off-topic, if mm_struct size is performance important, we have to 
get rid of mm->cpu_vm_mask from mm_struct at first. cpumask_t use 
NR_CPUS/8 bytes and NR_CPUS==4096 when we use recent distros. it's
one of root cause of mm_struct bloat.



> I am surprised that
> #define VM_EXEC		0x00000004ULL
> does not cause trouble for arch/arm/kernel/asm-offsets.c,
> but you tried cross-building it which I never did.
> 
> Does your later addition of __nocast on vm_flags not make trouble
> for the unsigned long casts in arch/arm/include/asm/cacheflush.h?
> (And if it does not, then just what does __nocast do?)

If my understanding is correct, __nocast mean warn _implicit_ narrowing
conversion. Thus, arm defconfig cross build doesn't make any warn nor 
error. :)

side note: honestly says, I know arm defconfig doesn't build many
subarch specific cacheflush code. But I have no way to confirm it. ;)

> 
> Thanks for seeing this through,
> Hugh



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
