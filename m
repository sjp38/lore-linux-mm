Received: from dukat.scot.redhat.com (sct@dukat.scot.redhat.com [195.89.149.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id JAA26824
	for <linux-mm@kvack.org>; Wed, 7 Apr 1999 09:06:44 -0400
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14091.22597.198249.259683@dukat.scot.redhat.com>
Date: Wed, 7 Apr 1999 14:06:13 +0100 (BST)
Subject: Re: [patch] only-one-cache-query [was Re: [patch] arca-vm-2.2.5]
In-Reply-To: <Pine.LNX.4.05.9904070243310.222-100000@laser.random>
References: <Pine.LNX.4.05.9904051723490.507-100000@laser.random>
	<Pine.LNX.4.05.9904070243310.222-100000@laser.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Mark Hemment <markhe@sco.COM>, Chuck Lever <cel@monkey.org>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, 7 Apr 1999 13:28:33 +0200 (CEST), Andrea Arcangeli
<andrea@e-mind.com> said:

> Last night I had a new idea on how to cleanly and trivially avoid the two
> cache query. We only need to know if we slept or not in GFP. 

No, that's not a viable solution in the long term.  We have been
steadily fine-graining the locking in the kernel by replacing the global
kernel lock with per-facility or per-resource locks, and in the future
we can expect to see the page cache also running without the global
lock.

At that point, we will need to drop any spinlocks we hold before calling
get_free_page(), because the scheduler will only drop the global lock
automatically if we sleep and we can't sleep with any other locks held.
Now, even if we _don't_ sleep, another CPU can get in to mess with the
page cache while we are doing allocation stuff.

> I am running the code while writing this and I'll release very soon a
> 2.2.5_arca8.bz2 with this new improvement included.

Fine, but it's a short-term fix.  The hash-cookie mechanism has the
advantage of being suitable for a fine-grain-locked page cache in the
future.

--Stephen


--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
