Date: Sat, 20 Jul 2002 15:27:03 -0700 (PDT)
Message-Id: <20020720.152703.102669295.davem@redhat.com>
Subject: Re: [PATCH] generalized spin_lock_bit
From: "David S. Miller" <davem@redhat.com>
In-Reply-To: <1027196511.1555.767.camel@sinai>
References: <1027196511.1555.767.camel@sinai>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: rml@tech9.net
Cc: torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@conectiva.com.br, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

   
   Thanks to Christoph Hellwig for prodding to make it per-architecture,
   Ben LaHaise for the loop optimization, and William Irwin for the
   original bit locking.

Just note that the implementation of these bit spinlocks will be
extremely expensive on some platforms that lack "compare and swap"
type instructions (or something similar like "load locked, store
conditional" as per mips/alpha).

Why not just use the existing bitops implementation?  The code is
going to be mostly identical, ala:

	while (test_and_set_bit(ptr, nr)) {
		while (test_bit(ptr, nr))
			barrier();
	}

This makes less work for architectures to support this thing.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
