Message-Id: <l03130311b7441c211cd9@[192.168.239.105]>
In-Reply-To: <3B1E61E4.291EF31C@uow.edu.au>
References: <3B1E2C3C.55DF1E3C@uow.edu.au>,	
 <3B1E203C.5DC20103@uow.edu.au>,		
 <l03130308b7439bb9f187@[192.168.239.105]>	
 <l0313030db743d4a05018@[192.168.239.105]>
 <l0313030fb743f99e010e@[192.168.239.105]>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Date: Wed, 6 Jun 2001 20:40:05 +0100
From: Jonathan Morton <chromi@cyberspace.org>
Subject: Re: [PATCH] reapswap for 2.4.5-ac10
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <andrewm@uow.edu.au>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>> AFAICT, the scanning in refill_inactive_scan() simply looks at a list of
>> pages, and doesn't really do physical addresses.  The age of a page should
>> be independent on the number of mappings it has, but dependent instead on
>> how much it is used (or how long it is not used for).  That code already
>> exists, and it works.
>
>Well, the page will have different ages wrt all the mms which map it.

Hmmm...  I'm obviously still learning the intricacies of how this all fits
together.  I really thought that if you had a struct page*, it pointed to a
unique page and that the pte's of different vma's were capable of multiply
pointing at said struct page*.  But, isn't that what page->count is for?
So have I grabbed the wrong end of what you're saying, and in fact I had it
right in the first place?

So, if multiple processes are really using a single page, then it makes
sense for the age to skyrocket - you don't wanna swap that page out,
otherwise all the processes that are using it will stall.  If you have a
shared page that isn't being used, you want the age to decay at the same
rate as non-shared pages, though it doesn't particularly matter what that
rate is.

Once this is achieved, the age turns into a reasonable approximation to
working set - as long as we don't force the age down under memory pressure
without allowing other processes to get in on the act.  Ah, that seems to
be what we're doing at the moment...

--------------------------------------------------------------
from:     Jonathan "Chromatix" Morton
mail:     chromi@cyberspace.org  (not for attachments)

The key to knowledge is not to rely on people to teach you it.

GCS$/E/S dpu(!) s:- a20 C+++ UL++ P L+++ E W+ N- o? K? w--- O-- M++$ V? PS
PE- Y+ PGP++ t- 5- X- R !tv b++ DI+++ D G e+ h+ r++ y+(*)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
