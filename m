Received: from tc-1-192.ariake.gol.ne.jp (neil@tc-1-241.ariake.gol.ne.jp [203.216.42.241])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA19649
	for <linux-mm@kvack.org>; Mon, 15 Mar 1999 17:43:51 -0500
From: neil@tc-1-192.ariake.gol.ne.jp
Message-ID: <19990316074606.A10483@tc-1-192.ariake.gol.ne.jp>
Date: Tue, 16 Mar 1999 07:46:06 +0900
Subject: Re: A couple of questions
References: <36DBE391.EF9C1C06@earthling.net> <199903151858.SAA02057@dax.scot.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <199903151858.SAA02057@dax.scot.redhat.com>; from Stephen C. Tweedie on Mon, Mar 15, 1999 at 06:58:26PM +0000
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Stephen,

Stephen C. Tweedie wrote:-
> Hi,
> 
[..snip..]
>
> > 2) The last 2 of the 3 branches to end_wp_page seem to me to be
> > impossible code paths.
> 
> > 	if (!pte_present(pte))
> > 		goto end_wp_page;
> > 	if (pte_write(pte))
> > 		goto end_wp_page;
> 
> No, the start of do_wp_page() looks like:
> 
> 	pte = *page_table;
> 	new_page = __get_free_page(GFP_USER);
> 
> and the get_free_page() call can block if we are out of memory, dropping
> the kernel lock in the process.  The page table can be modified by
> kswapd during this interval.

Thanks for your reply.  I think you've missed my point on this one.
The variable "pte" is set before calling __get_free_page(), and being
local cannot be modified by other processes.  Hence I still believe
the 2 branches shown are impossible, their negative having been the
condition for entering do_wp_page().

The case you mention is captured by the initial test

	if (pte_val(*page_table) != pte_val(pte))
		goto end_wp_page;

performed before the two above.  Do you agree?

Cheers,

Neil.
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
