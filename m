Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id A76956B00DA
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 08:29:14 -0400 (EDT)
Date: Mon, 23 Mar 2009 10:35:03 -0300
From: "Luiz Fernando N. Capitulino" <lcapitulino@mandriva.com.br>
Subject: Re: PATCH: Introduce struct vma_link_info
Message-ID: <20090323103503.1a09d6d4@mandriva.com.br>
In-Reply-To: <1237581389.4667.130.camel@laptop>
References: <20090320103438.08e67358@doriath.conectiva>
	<1237581389.4667.130.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: akpm@linux-foundation.org, riel@redhat.com, mingo@elte.hu, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ehabkost@redhat.com
List-ID: <linux-mm.kvack.org>

Em Fri, 20 Mar 2009 21:36:29 +0100
Peter Zijlstra <peterz@infradead.org> escreveu:

| On Fri, 2009-03-20 at 10:34 -0300, Luiz Fernando N. Capitulino wrote:
| > Andrew,
| > 
| >   Currently find_vma_prepare() and low-level VMA functions (eg. __vma_link())
| > require callers to provide three parameters to return/pass "link" information
| > (pprev, rb_link and rb_parent):
| > 
| > static struct vm_area_struct *
| > find_vma_prepare(struct mm_struct *mm, unsigned long addr,
| >                 struct vm_area_struct **pprev, struct rb_node ***rb_link,
| >                 struct rb_node ** rb_parent);
| > 
| >  With this patch callers can pass a struct vma_link_info instead:
| > 
| > static struct vm_area_struct *
| > find_vma_prepare(struct mm_struct *mm, unsigned long addr,
| >                 struct vma_link_info *link_info);
| > 
| >  The code gets simpler and it should be better because less variables
| > are pushed into the stack/registers. As shown by the following
| > kernel build test:
| > 
| > kernel			real	user	sys
| > 
| > 2.6.29-rc8-vanilla      1136.64 1033.38 82.88
| > 2.6.29-rc8-linfo        1135.07 1032.44 82.92
| > 
| >  I have also ran hackbench, but I can't understand why its result
| > indicates a regression:
| > 
| > kernel                 Avarage of three runs (25 processes groups)
| > 
| > 2.6.29.rc8-vanilla                2.03
| > 2.6.29.rc8-linfo                  2.12
| > 
| >  Rik has said to me that this could be inside error margin. So, I'm
| > submitting the patch for inclusion.
| > 
| > Signed-off-by: Luiz Fernando N. Capitulino <lcapitulino@mandriva.com.br>
| 
| I'd rather we look into using the threaded RB-tree to get rid of all
| this prev crap.

 Okay, it makes sense. Also, Eduardo has a point for the hackbench's
regression: the patch is probably dropping some of gcc's optimizations
on the variables that got packed into the struct (although I haven't
checked the assembly yet).

 So, better to forget this one.

 Are there patches for the threaded tree available already?

-- 
Luiz Fernando N. Capitulino

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
