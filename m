Message-ID: <45BBCFE9.5010600@redhat.com>
Date: Sat, 27 Jan 2007 17:19:21 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] Track mlock()ed pages
References: <Pine.LNX.4.64.0701252141570.10629@schroedinger.engr.sgi.com>	<45B9A00C.4040701@yahoo.com.au>	<Pine.LNX.4.64.0701252234490.11230@schroedinger.engr.sgi.com>	<20070126031300.59f75b06.akpm@osdl.org>	<Pine.LNX.4.64.0701260742340.6141@schroedinger.engr.sgi.com>	<20070126101027.90bf3e63.akpm@osdl.org>	<Pine.LNX.4.64.0701261021200.7848@schroedinger.engr.sgi.com> <20070126104206.f0b45f74.akpm@osdl.org>
In-Reply-To: <20070126104206.f0b45f74.akpm@osdl.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Christoph Lameter <clameter@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

> Of course it would.  But how do you know it is "too expensive"?  We "scan
> all the vmas mapping a page" as a matter of course in the page scanner -
> millions of times a minute.  If that's "too expensive" then ouch.

We can do it lazily.

At mlock time, move pages onto the mlocked list, unless they
are there already.

On munlock, move pages to the active list.  For mlock-only
memory (shared memory segments?) we could add a simple check
to see if the next process on the list has the page mlocked,
checking only that one.

While scanning the active list, move mlocked pages that are
found back onto the mlocked list.

This lazy movement of pages will impact shared libraries,
but probably not shared memory segments.

Does this sound workable?

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
