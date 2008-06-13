Date: Fri, 13 Jun 2008 09:25:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUG] 2.6.26-rc5-mm3 kernel BUG at mm/filemap.c:575!
Message-Id: <20080613092520.fb35cd70.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <200806122138.59969.nickpiggin@yahoo.com.au>
References: <20080611225945.4da7bb7f.akpm@linux-foundation.org>
	<4850E1E5.90806@linux.vnet.ibm.com>
	<20080612015746.172c4b56.akpm@linux-foundation.org>
	<200806122138.59969.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Jun 2008 21:38:59 +1000
Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> +int putback_lru_page(struct page *page)
> +{
> +       int lru;
> +       int ret = 1;
> +       int was_unevictable;
> +
> +       VM_BUG_ON(!PageLocked(page));
> +       VM_BUG_ON(PageLRU(page));
> +
> +       lru = !!TestClearPageActive(page);
> +       was_unevictable = TestClearPageUnevictable(page); /* for 
> page_evictable() */
> +
> +       if (unlikely(!page->mapping)) {
> +               /*
> +                * page truncated.  drop lock as put_page() will
> +                * free the page.
> +                */
> +               VM_BUG_ON(page_count(page) != 1);
> +               unlock_page(page);
>                 ^^^^^^^^^^^^^^^^^^
> 
> 
> This is a rather wild thing to be doing. It's a really bad idea
> to drop a lock that's taken several function calls distant and
> across different files...
> 
I agree and strongly hope this unlock should be removed.
The caller can do unlock by itself, I think.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
