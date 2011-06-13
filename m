Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id A2AE36B0092
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 05:22:23 -0400 (EDT)
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5D90r8l029355
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 05:00:53 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5D9MLfM753846
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 05:22:21 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5D9MKdr025023
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 05:22:21 -0400
Date: Mon, 13 Jun 2011 14:44:47 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 2/22]  2: uprobes: Breakground page
 replacement.
Message-ID: <20110613091447.GE27130@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
 <20110607125835.28590.25476.sendpatchset@localhost6.localdomain6>
 <1307660612.2497.1774.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1307660612.2497.1774.camel@laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

* Peter Zijlstra <peterz@infradead.org> [2011-06-10 01:03:32]:

> On Tue, 2011-06-07 at 18:28 +0530, Srikar Dronamraju wrote:
> > +/**
> > + * __replace_page - replace page in vma by new page.
> > + * based on replace_page in mm/ksm.c
> > + *
> > + * @vma:      vma that holds the pte pointing to page
> > + * @page:     the cowed page we are replacing by kpage
> > + * @kpage:    the modified page we replace page by
> > + *
> > + * Returns 0 on success, -EFAULT on failure.
> > + */
> > +static int __replace_page(struct vm_area_struct *vma, struct page *page,
> > +                                       struct page *kpage)
> 
> This is a verbatim copy of mm/ksm.c:replace_page(), I think I can
> remember why you did this, but the changelog utterly fails to mention
> why we need a second copy of this logic (or anything much at all).
> 

__replace_page is not exactly a copy of replace_page. Its a slightly
modified copy of replace_page. Here are the reasons for having this
modified copy instead of using the replace_page.

replace_page was written specifically for ksm purpose by Hugh Dickins.
Also Hugh said he doesnt like replace_page to be exposed for other uses.
He has plans for further modifying replace_page for ksm specific
purposes which might not be aligned to what we are using.

Further for replace_page, its good enuf to call page_add_anon_rmap()
However for uprobes needs we need to call page_add_new_anon_rmap().
page_add_new_anon_rmap() will add the page to the right lru list.

replace_page needs a reference to orig_pte while __replace_page doesnt
need.

I can add the same to Changelog but I am not sure it makes a good
reading. Hence I had skipped it.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
