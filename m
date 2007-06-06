Subject: Re: [PATCH 4/4] mm: variable length argument support
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20070606013658.20bcbe2f.akpm@linux-foundation.org>
References: <20070605150523.786600000@chello.nl>
	 <20070605151203.790585000@chello.nl>
	 <20070606013658.20bcbe2f.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Wed, 06 Jun 2007 10:54:21 +0200
Message-Id: <1181120061.7348.177.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Ollie Wild <aaw@google.com>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-06-06 at 01:36 -0700, Andrew Morton wrote:
> On Tue, 05 Jun 2007 17:05:27 +0200 Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> 
> > From: Ollie Wild <aaw@google.com>
> > 
> > Remove the arg+env limit of MAX_ARG_PAGES by copying the strings directly
> > from the old mm into the new mm.
> > 
> > We create the new mm before the binfmt code runs, and place the new stack
> > at the very top of the address space. Once the binfmt code runs and figures
> > out where the stack should be, we move it downwards.
> > 
> > It is a bit peculiar in that we have one task with two mm's, one of which is
> > inactive.
> > 
> > ...
> >
> > +				flush_cache_page(bprm->vma, kpos,
> > +						 page_to_pfn(kmapped_page));

Bah, and my frv cross build bums out on an unrelated change,..
I'll see if I can get a noMMU arch building, in the mean time, would you
try this:

---

Since no-MMU doesn't do the fancy inactive mm access there is no need to
flush cache.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---

Index: linux-2.6-2/fs/exec.c
===================================================================
--- linux-2.6-2.orig/fs/exec.c	2007-06-05 16:48:52.000000000 +0200
+++ linux-2.6-2/fs/exec.c	2007-06-06 10:49:19.000000000 +0200
@@ -428,8 +428,10 @@ static int copy_strings(int argc, char _
 				kmapped_page = page;
 				kaddr = kmap(kmapped_page);
 				kpos = pos & PAGE_MASK;
+#ifdef CONFIG_MMU
 				flush_cache_page(bprm->vma, kpos,
 						 page_to_pfn(kmapped_page));
+#endif
 			}
 			if (copy_from_user(kaddr+offset, str, bytes_to_copy)) {
 				ret = -EFAULT;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
