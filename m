Message-ID: <3910EB99.2B9E1980@sgi.com>
Date: Wed, 03 May 2000 20:16:41 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Re: Oops in __free_pages_ok (pre7-1) (Long) (backtrace)
References: <Pine.LNX.4.10.10005031828520.950-100000@penguin.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-mm@kvack.org, "David S. Miller" <davem@redhat.com>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> Ok,
>  there's a pre7-4 out there that does the swapout with the page locked.
> I've given it some rudimentary testing, but certainly nothing really
> exotic. Please comment..
> 

One other problem with having the page locked in
try_to_swapout() is in the call to 
prepare_highmem_swapout() when the incoming
page is in highmem. Then,
  
(1) The newly allocated page (regular_page) needs to be locked.
    This is may be trivial as setting PG_locked in regular_page,
    since no one else knows about it.

(2) Before __free_page() is called on the incoming highmem
     page it needs to be unlocked --- otherwise, we'll have
     dejavu all over in __free_pages_ok!
    This is a little tricky however, since not all callers of
    prepare_highmem_swapout() have the incoming page locked.
    For now, you can get away with something like
    (in mm/highmem.c):

        /*
         * ok, we can just forget about our highmem page since
         * we stored its data into the new regular_page.
         */
+	if (PageLocked(page))
+		UnlockPage(page);
       __free_page(page);



    
-- 
--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
