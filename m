Date: Fri, 10 Oct 2008 14:54:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/1] hugetlb: pull gigantic page initialisation out of
 the default path
Message-Id: <20081010145418.4d0236ba.akpm@linux-foundation.org>
In-Reply-To: <200810082331.45359.nickpiggin@yahoo.com.au>
References: <1223458499-12752-1-git-send-email-apw@shadowen.org>
	<200810082331.45359.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: apw@shadowen.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kniht@linux.vnet.ibm.com, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Wed, 8 Oct 2008 23:31:45 +1100
Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> On Wednesday 08 October 2008 20:34, Andy Whitcroft wrote:
> > As we can determine exactly when a gigantic page is in use we can optimise
> > the common regular page cases by pulling out gigantic page initialisation
> > into its own function.  As gigantic pages are never released to buddy we
> > do not need a destructor.  This effectivly reverts the previous change
> > to the main buddy allocator.  It also adds a paranoid check to ensure we
> > never release gigantic pages from hugetlbfs to the main buddy.
> 
> Thanks for doing this. Can prep_compound_gigantic_page be #ifdef HUGETLB?

Yup.

--- a/mm/page_alloc.c~hugetlb-pull-gigantic-page-initialisation-out-of-the-default-path-fix
+++ a/mm/page_alloc.c
@@ -280,6 +280,7 @@ void prep_compound_page(struct page *pag
 	}
 }
 
+#ifdef CONFIG_HUGETLBFS
 void prep_compound_gigantic_page(struct page *page, unsigned long order)
 {
 	int i;
@@ -294,6 +295,7 @@ void prep_compound_gigantic_page(struct 
 		p->first_page = page;
 	}
 }
+#endif
 
 static void destroy_compound_page(struct page *page, unsigned long order)
 {
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
