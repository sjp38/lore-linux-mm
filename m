Date: Mon, 5 Apr 2004 14:29:40 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] get_user_pages shortcut for anonymous pages.
Message-Id: <20040405142940.5a4ed583.akpm@osdl.org>
In-Reply-To: <20040405142433.GA5955@mschwid3.boeblingen.de.ibm.com>
References: <20040405142433.GA5955@mschwid3.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Martin Schwidefsky <schwidefsky@de.ibm.com> wrote:
>
> > You'd need to teach follow_page() to return one of three values:
> > page-present, page-not-present-but-used-to-be or
> > page-not-present-and-never-was.
> Hmm, this would get ugly because follow_page calls
> follow_huge_addr and follow_huge_pmd for system with highmem. I
> really don't want to change follow_page. Instead I added a check
> for pgd_none/pgd_bad and pmd_none/pmd_bad for page directory
> entries needed for the pages in question. After all the patch is
> supposed to prevent the creation of page tables so why not check
> the pgd/pmd slots? 
> 
> diff -urN linux-2.6/mm/memory.c linux-2.6-bigcore/mm/memory.c

OK..  I'm not sure that this patch makes sense though.  I mean, if your
test had gone and dirtied all these pages rather than forcing the coredump
code to do it, we'd still exhaust all physical memory with pagetables,
assuming you have enough swapspace.  So I don't see we're gaining much?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
