Date: Sat, 20 Jul 2002 16:25:21 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] generalized spin_lock_bit
In-Reply-To: <1027200016.1086.800.camel@sinai>
Message-ID: <Pine.LNX.4.44.0207201622350.1814-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@conectiva.com.br, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>


On 20 Jul 2002, Robert Love wrote:
>
> My assumption was similar - that the bit locking may be inefficient on
> other architectures - so I put the spin_lock_bit code in per-arch
> headers.

Well, but you also passed it an unsigned long, and the bit number.

Which at least to me implies that they have to set that bit.

Which is totally unnecessary, if they _instead_ decide to set something
else altogether.

For example, the implementation on pte_chain_lock(page) might be something
like this instead:

	static void pte_chain_lock(struct page *page)
	{
		unsigned long hash = hash(page) & PTE_CHAIN_MASK;
		spin_lock(pte_chain[hash]);
	}

	static void pte_chain_unlock(struct page *page)
	{
		unsigned long hash = hash(page) & PTE_CHAIN_MASK;
		spin_unlock(pte_chain[hash]);
	}

> In other words, I assumed we may need to make some changes but to
> bit-locking in general and not rip out the whole design.

bit-locking in general doesn't work. Some architectures can sanely only
lock a byte (or even just a word).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
