Date: Sun, 4 Apr 2004 22:59:20 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] get_user_pages shortcut for anonymous pages.
Message-Id: <20040404225920.340c12ee.akpm@osdl.org>
In-Reply-To: <20040402141710.GA1903@mschwid3.boeblingen.de.ibm.com>
References: <20040402141710.GA1903@mschwid3.boeblingen.de.ibm.com>
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
>  			struct page *map;
>   			int lookup_write = write;
>   			while (!(map = follow_page(mm, start, lookup_write))) {
>  +				/*
>  +				 * Shortcut for anonymous pages. We don't want
>  +				 * to force the creation of pages tables for
>  +				 * insanly big anonymously mapped areas that
>  +				 * nobody touched so far. This is important
>  +				 * for doing a core dump for these mappings.
>  +				 */
>  +				if (!lookup_write && 
>  +				    (!vma->vm_ops || !vma->vm_ops->nopage)) {
>  +					map = ZERO_PAGE(start);
>  +					break;
>  +				}
>   				spin_unlock(&mm->page_table_lock);

I think this will do the wrong thing if the virtual address refers to an
anon page which is swapped out.

You'd need to teach follow_page() to return one of three values:
page-present, page-not-present-but-used-to-be or
page-not-present-and-never-was.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
