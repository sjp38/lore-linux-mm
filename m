Date: Thu, 18 Nov 2004 18:38:47 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: fast path for anonymous memory allocation
In-Reply-To: <419D581F.2080302@yahoo.com.au>
Message-ID: <Pine.LNX.4.58.0411181835540.1421@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.44.0411061527440.3567-100000@localhost.localdomain>
 <Pine.LNX.4.58.0411181126440.30385@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0411181715280.834@schroedinger.engr.sgi.com>
 <419D581F.2080302@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Hugh Dickins <hugh@veritas.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 19 Nov 2004, Nick Piggin wrote:

> Ahh, you're doing clear_user_highpage after the pte is already set up?

The huge page code also has that optimization. Clearing of pages
may take some time which is one reason the kernel drops the page table
lock for anonymous page allocation and then reacquires it. The patch does
not relinquish the lock on the fast path thus the move outside of the
lock.

> Won't that be racy? I guess that would be an advantage of my approach,
> the clear_user_highpage can be done first (although that is more likely
> to be wasteful of cache).

If you do the clearing with the page table lock held then performance will
suffer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
