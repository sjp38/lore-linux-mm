Date: Fri, 2 Apr 2004 10:43:34 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC][PATCH 1/3] radix priority search tree - objrmap complexity fix
Message-ID: <20040402104334.A871@infradead.org>
References: <20040402001535.GG18585@dualathlon.random> <Pine.LNX.4.44.0404020145490.2423-100000@localhost.localdomain> <20040402011627.GK18585@dualathlon.random> <20040401173649.22f734cd.akpm@osdl.org> <20040402020022.GN18585@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040402020022.GN18585@dualathlon.random>; from andrea@suse.de on Fri, Apr 02, 2004 at 04:00:22AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, hugh@veritas.com, vrajesh@umich.edu, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 02, 2004 at 04:00:22AM +0200, Andrea Arcangeli wrote:
> I now fixed up the whole compound thing, it made no sense to keep
> compound off with HUGETLBSF=N, that's a generic setup for all order > 0

I got lots of the following OOPSEs with 2.6.5-rc3aa2 on a powerpc running
the xfs testsuite (with the truncate fix applied):

Apr  2 13:27:21 bird kernel: Bad page state at destroy_compound_page (in process 'swapper', page c08d9920)
Apr  2 13:27:21 bird kernel: flags:0x00000008 mapping:00000000 mapped:0 count:0
Apr  2 13:27:21 bird kernel: Backtrace:
Apr  2 13:27:21 bird kernel: Call trace:
Apr  2 13:27:21 bird kernel:  [c000b5c8] dump_stack+0x18/0x28
Apr  2 13:27:21 bird kernel:  [c0048b60] bad_page+0x70/0xb0
Apr  2 13:27:21 bird kernel:  [c0048c70] destroy_compound_page+0x80/0xb8
Apr  2 13:27:21 bird kernel:  [c0048ec4] free_pages_bulk+0x21c/0x220
Apr  2 13:27:21 bird kernel:  [c0049020] __free_pages_ok+0x158/0x16c
Apr  2 13:27:21 bird kernel:  [c004d4f8] slab_destroy+0x140/0x234
Apr  2 13:27:21 bird kernel:  [c00505c8] reap_timer_fnc+0x1e4/0x2b8
Apr  2 13:27:21 bird kernel:  [c002feac] run_timer_softirq+0x134/0x1fc
Apr  2 13:27:21 bird kernel:  [c002abd0] do_softirq+0x140/0x144
Apr  2 13:27:21 bird kernel:  [c0009e5c] timer_interrupt+0x2d0/0x300
Apr  2 13:27:21 bird kernel:  [c0007cac] ret_from_except+0x0/0x14
Apr  2 13:27:21 bird kernel:  [c000381c] ppc6xx_idle+0xe4/0xf0
Apr  2 13:27:21 bird kernel:  [c0009b7c] cpu_idle+0x28/0x38
Apr  2 13:27:21 bird kernel:  [c00038c4] rest_init+0x50/0x60
Apr  2 13:27:21 bird kernel:  [c0364784] start_kernel+0x198/0x1d8
Apr  2 13:27:21 bird kernel: Trying to fix it up, but a reboot is needed
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
