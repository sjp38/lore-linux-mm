From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14199.62442.849894.647906@dukat.scot.redhat.com>
Date: Mon, 28 Jun 1999 23:15:06 +0100 (BST)
Subject: Re: filecache/swapcache questions [RFC] [RFT] [PATCH] kanoj-mm12-2.3.8
 Fix swapoff races
In-Reply-To: <Pine.BSO.4.10.9906281648010.24888-100000@funky.monkey.org>
References: <14199.57040.245837.447659@dukat.scot.redhat.com>
	<Pine.BSO.4.10.9906281648010.24888-100000@funky.monkey.org>
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.3.96.990629092936.7614B@mole.spellcast.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@monkey.org>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Kanoj Sarcar <kanoj@google.engr.sgi.com>, Andrea Arcangeli <andrea@suse.de>, torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 28 Jun 1999 17:14:17 -0400 (EDT), Chuck Lever <cel@monkey.org>
said:

> that doesn't hurt because try_to_free_page() doesn't acquire anything but
> the kernel lock in my patch.  

Removing swapout from try_to_free_page is fundamentally broken, since it
removes a critical rate limiter from the vm allocator paths.  Acquiring
it in kswapd is still a deadlock situation.

> the eventual goal of my adventure is to drop the kernel lock while doing
> the page COW in do_wp_page, since in 2.3.6+, the COW is again protected
> because of race conditions with kswapd.  

OK, but doing this by adding extra mm locks to the swapout path is
itself fraught with deadlocks, and doesn't get around the fact that
multiple different mm's can reference the same swap page so you don't
actually eliminate all of the races anyway by adding that locking.

--Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
