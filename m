From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14418.44165.273585.41704@dukat.scot.redhat.com>
Date: Sat, 11 Dec 1999 19:56:53 +0000 (GMT)
Subject: Re: Getting big areas of memory, in 2.3.x?
In-Reply-To: <Pine.LNX.4.10.9912100139370.12148-100000@chiara.csoma.elte.hu>
References: <Pine.LNX.3.96.991209180518.21542B-100000@kanga.kvack.org>
	<Pine.LNX.4.10.9912100139370.12148-100000@chiara.csoma.elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, Rik van Riel <riel@nl.linux.org>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, Jeff Garzik <jgarzik@mandrakesoft.com>, alan@lxorguk.ukuu.org.uk, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 10 Dec 1999 01:44:53 +0100 (CET), Ingo Molnar
<mingo@chiara.csoma.elte.hu> said:

> On Thu, 9 Dec 1999, Benjamin C.R. LaHaise wrote:
>> The type of allocation determines what pool memory is allocated from.  
>> Ie nonpagable kernel allocations come from one zone, atomic
>> allocations from another and user from yet another.  ...

> well, this is perfectly possible with the current zone allocator (check
> out how build_zonelists() builds dynamic allocation paths). I dont see
> much point in it though, it might prevent fragmentation to a certain
> degree, but i dont think it is a fair use of memory resources. (i'm pretty
> sure the atomic zone would stay unused most of the time) 

Don't use static zones then.

Something I talked about with Linus a while back was to separate memory
into 4MB or 16MB zones, and do allocation not from individual zones but
from zone lists.  Then you just keep track of two lists of zones: one
which contains zones which are known to have been used for non-pagable
allocations, and another in which all allocations are pagable.  

The pagable-allocation zone family can always be used for large
allocations: you just select a contiguous region of pages which aren't
currently being used by the contiguous allocator, and page them out (or
relocate them to a different zone if you prefer).

If this is only needed by device initialisation, the relocation doesn't
have to be fast.  A dumb, brute-force search (such as is already done by
sys_swapoff()) will do fine.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
