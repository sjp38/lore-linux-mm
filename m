From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14200.46136.840759.709221@dukat.scot.redhat.com>
Date: Tue, 29 Jun 1999 12:55:36 +0100 (BST)
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
 Fix swapoff races
In-Reply-To: <Pine.LNX.4.10.9906290032460.1588-100000@laser.random>
References: <Pine.BSO.4.10.9906281648010.24888-100000@funky.monkey.org>
	<Pine.LNX.4.10.9906290032460.1588-100000@laser.random>
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.3.96.990629092958.7614E@mole.spellcast.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Chuck Lever <cel@monkey.org>, "Stephen C. Tweedie" <sct@redhat.com>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 29 Jun 1999 00:48:18 +0200 (CEST), Andrea Arcangeli
<andrea@suse.de> said:

> I thought a bit about that as well. I also coded a maybe possible
> solution. Look at this snapshot:

Much better: the synchronisation between the page fault and the swapper
is per-page, not per-mm, this way.  That way the swapper can afford
just to skip the one locked page rather than block for an mm lock.  My
only reservation is that it's a bit ugly to overload the "locked" bit
this way, but it's the only obvious test in try_to_swap_out that we can
use.  

Adding a new PG_Locked_PTE flag for the page, to indicate that somebody
is relying on this pte for COW operation and kswapd should skip it,
would be an alternative: it makes the intent much more clear (and keeps
PG_Locked purely for IO locking, which is really as it should be).

--Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
