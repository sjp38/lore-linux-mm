Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA17358
	for <linux-mm@kvack.org>; Mon, 15 Mar 1999 13:58:34 -0500
Date: Mon, 15 Mar 1999 18:58:26 GMT
Message-Id: <199903151858.SAA02057@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: A couple of questions
In-Reply-To: <36DBE391.EF9C1C06@earthling.net>
References: <36DBE391.EF9C1C06@earthling.net>
Sender: owner-linux-mm@kvack.org
To: Neil Booth <NeilB@earthling.net>
Cc: linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

<Late answer: I've been offline for a couple of weeks>

On Tue, 02 Mar 1999 22:11:45 +0900, Neil Booth <NeilB@earthling.net> said:

> I have a couple of questions about do_wp_page; I hope they're welcome
> here.

> 1) do_wp_page has most execution paths doing an unlock_kernel() but
> there are a couple that don't. Why isn't this inconsistent? 

Good question, and a possible bug.  Anyone else care to glance at this?
It's a possible problem only on SMP, of course.  The obvious fix is:

----------------------------------------------------------------
--- mm/memory.c~	Tue Jan 19 01:33:10 1999
+++ mm/memory.c	Mon Mar 15 18:57:31 1999
@@ -651,13 +651,13 @@
 		delete_from_swap_cache(page_map);
 		/* FallThrough */
 	case 1:
-		/* We can release the kernel lock now.. */
-		unlock_kernel();
-
 		flush_cache_page(vma, address);
 		set_pte(page_table, pte_mkdirty(pte_mkwrite(pte)));
 		flush_tlb_page(vma, address);
 end_wp_page:
+		/* We can release the kernel lock now.. */
+		unlock_kernel();
+
 		if (new_page)
 			free_page(new_page);
 		return 1;
----------------------------------------------------------------

> 2) The last 2 of the 3 branches to end_wp_page seem to me to be
> impossible code paths.

> 	if (!pte_present(pte))
> 		goto end_wp_page;
> 	if (pte_write(pte))
> 		goto end_wp_page;

No, the start of do_wp_page() looks like:

	pte = *page_table;
	new_page = __get_free_page(GFP_USER);

and the get_free_page() call can block if we are out of memory, dropping
the kernel lock in the process.  The page table can be modified by
kswapd during this interval.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
