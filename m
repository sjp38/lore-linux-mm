Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 08A828D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 12:59:12 -0400 (EDT)
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <20110419160606.932084E6A@hiauly1.hia.nrc.ca>
References: <20110419160606.932084E6A@hiauly1.hia.nrc.ca>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 19 Apr 2011 11:59:09 -0500
Message-ID: <1303232349.3171.21.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John David Anglin <dave@hiauly1.hia.nrc.ca>
Cc: mhocko@suse.cz, akpm@linux-foundation.org, hughd@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-parisc@vger.kernel.org

On Tue, 2011-04-19 at 12:06 -0400, John David Anglin wrote:
> > It compiles OK, but crashes on boot in fsck.  The crash is definitely mm
> > but looks to be a slab problem (it's a null deref on a spinlock in
> > add_partial(), which seems unrelated to this patch).
> 
> I had a somewhat similar crash Sunday with the "debian" config building GCC.
> This is with 2.6.39-rc3+  without the mm patch:
> 
> mx3210 login: [12244.664000] Backtrace:
> [12244.664000]  [<000000004020c9a0>] __slab_free+0x100/0x200
> [12244.664000]  [<000000004020d23c>] kmem_cache_free+0xf4/0x108
> [12244.668000]  [<000000001c7e9efc>] __journal_remove_journal_head+0x214/0x248 [
> jbd]
> [12244.668000]  [<000000001c7edd48>] journal_put_journal_head+0xc8/0x168 [jbd]
> [12244.668000]  [<000000001c7e158c>] journal_invalidatepage+0x45c/0x710 [jbd]
> [12244.672000]  [<000000001c8652d8>] ext3_invalidatepage+0x88/0xe8 [ext3]
> [12244.672000]  [<00000000401d76f4>] do_invalidatepage+0x34/0x40
> [12244.672000]  [<00000000401d7770>] truncate_inode_page+0x70/0x178
> [12244.676000]  [<00000000401d798c>] truncate_inode_pages_range+0x114/0x518
> [12244.676000]  [<00000000401d7da4>] truncate_inode_pages+0x14/0x20
> [12244.680000]  [<000000001c86ac1c>] ext3_evict_inode+0x64/0x2a8 [ext3]
> [12244.680000]  [<0000000040234424>] evict+0xac/0x1c8
> 
> [12244.692000] PSW: 00001000000001101111001100001110 Not tainted
> [12244.692000] r00-03  000000ff0806f30e 0000000040745e50 000000004020c9a0 000000
> 01453d6000
> [12244.692000] r04-07  0000000040722e50 0000000000000000 00000002bf400000 000000
> 001c7dc000
> [12244.696000] r08-11  0000000000000002 0000000040630298 0000000000000001 000000
> 007bba4940
> [12244.696000] r12-15  00000002bf400000 0000000000000001 0000000000000000 000000
> 0000000001
> [12244.700000] r16-19  000000007e71d888 000000007e71d888 0000000000001000 200000
> 0000000081
> [12244.700000] r20-23  0000000000000000 0000000040630290 0000000000000001 000000
> 001c7e9efc
> [12244.704000] r24-27  000000000800000e 00000001453d6000 0000000000000000 000000
> 0040722e50
> [12244.704000] r28-31  0000000000000001 000000007bba4b70 000000007bba4ba0 000000
> 0000000023
> [12244.708000] sr00-03  000000000556c000 000000000556c000 0000000000000000 000000000556c000
> [12244.708000] sr04-07  0000000000000000 0000000000000000 0000000000000000 0000000000000000
> 
> [12244.712000]
> [12244.712000] IASQ: 0000000000000000 0000000000000000 IAOQ: 000000004011b240 000000004011b244
> [12244.712000]  IIR: 0f4015dc    ISR: 0000000000000000  IOR: 0000000000000000
> [12244.716000]  CPU:        3   CR30: 000000007bba4000 CR31: ffffffffffffffff
> [12244.716000]  ORIG_R28: 0000000000000001
> [12244.720000]  IAOQ[0]: _raw_spin_lock+0x10/0x20
> [12244.720000]  IAOQ[1]: _raw_spin_lock+0x14/0x20
> [12244.720000]  RP(r2): __slab_free+0x100/0x200

Yes, it's the same crash.  Apparently get_node() is returning NULL for
some reason.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
