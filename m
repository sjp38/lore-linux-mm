Message-ID: <39DBA9AA.AA4DEB1C@sgi.com>
Date: Wed, 04 Oct 2000 15:05:30 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Re: Odd swap behavior
References: <Pine.LNX.4.21.0010041844510.1054-100000@duckman.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik van Riel wrote:
	[ ... ]
> 
> Please take a look at vmscan.c::refill_inactive()
> 
> Furthermore, we don't do background scanning on all
> active pages, only on the unmapped ones.

Does that mean stack pages of processes are not included?
Non-aggressive swap can hurt performance.	

> 
> Agreed, but I don't see an "easy" solution for 2.4.
> 

Ok, I have another suggestion. Suppose you had a situation
where a page is read from disk. It has buffers. Initially
the page is active, and then aged. Where does the page go at age = 0?
In reading the current code it seems that it would go to
inactive_dirty. See how deactivate_page() chooses the dirty list
to add a page which has buffers. Of course, later page_launder()
would do try_to_free_buffers() which discards (clean) buffer heads,
and at that point the page is put on free_list/reclaimed.
Would it not be more efficient to bung clean (read) pages directly
to inactive_clean on age = 0?


--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
