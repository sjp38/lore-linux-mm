From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14532.13432.760022.313353@dukat.scot.redhat.com>
Date: Mon, 6 Mar 2000 22:43:04 +0000 (GMT)
Subject: Re: [RFC] [RFT] Shared /dev/zero mmaping feature
In-Reply-To: <200003012009.MAA90800@google.engr.sgi.com>
References: <qwwn1oilbo4.fsf@sap.com>
	<200003012009.MAA90800@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Christoph Rohland <hans-christoph.rohland@sap.com>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 1 Mar 2000 12:09:11 -0800 (PST), kanoj@google.engr.sgi.com
(Kanoj Sarcar) said:

> Great, we can see what makes sense for /dev/zero wrt shmfs ...

In principle, there is no reason why we need any special support for
this sort of thing.  The swap cache already does very nearly all we
need.

The swap cache maintains links between swap locations on disk and
(potentially shared) anonymous pages in memory.  It was designed so that
even if you fork, as long as the resulting COW pages remain unchanged,
the two processes will share the same pages of physical memory or swap
no matter what.

Basically, as soon as you try to swap out an anonymous page from one
process, a swap entry is allocated and a swap cache entry is set up.
Only once the last process swaps out does the physical page in memory
get released.  Until that happens, any lookup of the swap entry from a
swapped-out process will find the page already in memory.

To make this work for shared anonymous pages, we need two changes to the
swap cache.  We need to teach the swap cache about writable anonymous
pages, and we need to be able to defer the physical writing of the page
to swap until the last reference to the swap cache frees up the page.
Do that, and shared /dev/zero maps will Just Work.

The mechanics of this are probably a little too subtle to get right for
2.4 at this stage (in particular you need to know when to write the page
back to disk: we don't have the necessary PAGE_DIRTY infrastructure in
place for anonymous pages), but I definitely think this is the right way
to do things in the long term.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
