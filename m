Date: Wed, 3 May 2000 09:19:50 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
In-Reply-To: <200005031611.JAA73707@google.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.10005030914510.5951-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Rajagopal Ananthanarayanan <ananth@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Wed, 3 May 2000, Kanoj Sarcar wrote:
> 
> Note that try_to_swap_out holds the vmlist/page_table_lock on the
> victim process, as well as lock_kernel, and though this is not the
> easiest code to analyze, it seems to me that is enough protection 
> on the swapcache pages.

The swapcache code gets none of those locks as far as I can tell.

The swapcache code gets the page lock, and the "page cache" lock. But it
doesn't get the vmlist lock (the swap cache is not associated withany
particular mm), nor does it get the kernel lock (I think - I didn't look
through the code-paths).

>		 Also note, I am not saying it is not a good
> idea to lock the page in try_to_swap_out, but lets not rush into
> that without understanding the root cause ...

Certainly agreed. The interactions in this area are rather complex. But in
the end (whether this is a real bug or not) I suspect that I'd just prefer
to have the simple "you must lock the page before mucking with the page
flags" rule - even if some other magic lock happens to make all of the
current code ok. Just for clarity. 

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
