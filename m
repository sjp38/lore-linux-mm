From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200005031635.JAA78671@google.engr.sgi.com>
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
Date: Wed, 3 May 2000 09:35:37 -0700 (PDT)
In-Reply-To: <Pine.LNX.4.10.10005030914510.5951-100000@penguin.transmeta.com> from "Linus Torvalds" at May 03, 2000 09:19:50 AM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Rajagopal Ananthanarayanan <ananth@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> 
> 
> On Wed, 3 May 2000, Kanoj Sarcar wrote:
> > 
> > Note that try_to_swap_out holds the vmlist/page_table_lock on the
> > victim process, as well as lock_kernel, and though this is not the
> > easiest code to analyze, it seems to me that is enough protection 
> > on the swapcache pages.
> 
> The swapcache code gets none of those locks as far as I can tell.
> 
> The swapcache code gets the page lock, and the "page cache" lock. But it
> doesn't get the vmlist lock (the swap cache is not associated withany
> particular mm), nor does it get the kernel lock (I think - I didn't look
> through the code-paths).
>

What we are coming down to is a case by case analysis. For example,
do_wp_page, which does pull a page out of the swap cache, has the
vmlist_lock. do_swap_page does not, but neither is the page in the
pte at that point. free_page_and_swap_cache already has the vmlist_lock.

Some of this is documented in Documentation/vm/locking under the
section "Swap cache locking".

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
