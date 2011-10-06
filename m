Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id AABC96B025C
	for <linux-mm@kvack.org>; Thu,  6 Oct 2011 03:10:54 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p966tfac023748
	for <linux-mm@kvack.org>; Thu, 6 Oct 2011 02:55:41 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p967AqMJ263842
	for <linux-mm@kvack.org>; Thu, 6 Oct 2011 03:10:52 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p967AowP001004
	for <linux-mm@kvack.org>; Thu, 6 Oct 2011 01:10:52 -0600
Date: Thu, 6 Oct 2011 12:23:26 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 9/26]   Uprobes: Background page
 replacement.
Message-ID: <20111006065326.GD17591@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com>
 <20110920120137.25326.72005.sendpatchset@srdronam.in.ibm.com>
 <20111005161914.GA903@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20111005161914.GA903@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

* Oleg Nesterov <oleg@redhat.com> [2011-10-05 18:19:14]:

> On 09/20, Srikar Dronamraju wrote:
> >
> > +int __weak read_opcode(struct task_struct *tsk, unsigned long vaddr,
> > +						uprobe_opcode_t *opcode)
> > +{
> > +	struct vm_area_struct *vma;
> > +	struct page *page;
> > +	void *vaddr_new;
> > +	int ret;
> > +
> > +	ret = get_user_pages(tsk, tsk->mm, vaddr, 1, 0, 0, &page, &vma);
> > +	if (ret <= 0)
> > +		return ret;
> > +	ret = -EINVAL;
> > +
> > +	/*
> > +	 * We are interested in text pages only. Our pages of interest
> > +	 * should be mapped for read and execute only. We desist from
> > +	 * adding probes in write mapped pages since the breakpoints
> > +	 * might end up in the file copy.
> > +	 */
> > +	if (!valid_vma(vma))
> > +		goto put_out;
> 
> Another case when valid_vma() looks suspicious. We are going to restore
> the original instruction. We shouldn't fail (at least we shouldn't "leak"
> ->mm_uprobes_count) if ->vm_flags was changed between register_uprobe()
> and unregister_uprobe().
> 

Agree.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
