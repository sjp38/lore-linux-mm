Date: Sat, 15 Jan 2005 00:26:45 +0100
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: smp_rmb in mm/memory.c in 2.6.10
Message-ID: <20050114232645.GR8709@dualathlon.random>
References: <20050114225159.GO8709@dualathlon.random> <20050114231422.89551.qmail@web14301.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050114231422.89551.qmail@web14301.mail.yahoo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanojsarcar@yahoo.com>
Cc: Hugh Dickins <hugh@veritas.com>, Anton Blanchard <anton@samba.org>, Andi Kleen <ak@suse.de>, William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org, davem@redhat.com, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jan 14, 2005 at 03:14:22PM -0800, Kanoj Sarcar wrote:
> Yes, I ignored the 64bit case, and I am surprised the
> semantics are different. I can't see why it is a good
> idea to want different memory barrier semantics out of
> i_size_write() and friends depending on various CONFIG
> options and architecture. Maybe you can argue
> performance here, but is the slight advantage in
> performance on certain architectures (which is
> achieved nonetheless with over-barriering eg on x86)
> worth the extra code maintenance hassles?

The only reason there are barriers in the non-64bit cases is to
serialize i_size_read vs i_size_write (long long is not atomic with
gcc on 32bit), it wasn't meant to be anymore than that, on 64bit that's
automatic since gcc handles long long atomically natively (this isn't
really true in theory, but the pratical guys on l-k will never agree to
change that to assume standard C semantics that cannot guarantee
atomicity). See all other theorical race conditions I enlightened in
set_pte in all archs (which requires atomicity and in turn shouldn't be
implementd in C, it's exactly the same issue as i_size_write/read). So
in practice curent code is fine, and the locking was not meant to
serialize the truncate vs nopage race.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
