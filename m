From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] fix spurious OOM kills
Date: Wed, 24 Nov 2004 17:36:52 +0100
Message-ID: <1101314212.9481.13.camel@tglx.tec.linutronix.de>
References: <20041111112922.GA15948@logos.cnet>
	 <20041114094417.GC29267@logos.cnet>
	 <20041114170339.GB13733@dualathlon.random>
	 <20041114202155.GB2764@logos.cnet>	<419A2B3A.80702@tebibyte.org>
	 <419B14F9.7080204@tebibyte.org>	<20041117012346.5bfdf7bc.akpm@osdl.org>
	 <419CD8C1.4030506@ribosome.natur.cuni.cz>
	 <20041118131655.6782108e.akpm@osdl.org>
	 <419D25B5.1060504@ribosome.natur.cuni.cz>
	 <419D2987.8010305@cyberone.com.au>
	 <419D383D.4000901@ribosome.natur.cuni.cz>
	 <20041118160824.3bfc961c.akpm@osdl.org>
	 <419E821F.7010601@ribosome.natur.cuni.cz>
	 <1100946207.2635.202.camel@thomas> <419F2AB4.30401@ribosome.natur.cuni.cz>
	 <1100957349.2635.213.camel@thomas>
	 <419FB4CD.7090601@ribosome.natur.cuni.cz> <1101037999.23692.5.camel@thomas>
	 <41A08765.7030402@ribosome.natur.cuni.cz>
	 <1101045469.23692.16.camel@thomas>
	 <1101120922.19380.17.camel@tglx.tec.linutronix.de>
	 <41
Reply-To: tglx@linutronix.de
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262793AbUKXSnN@vger.kernel.org>
In-Reply-To: <41A4AE3A.4050906@ribosome.natur.cuni.cz>
Sender: linux-kernel-owner@vger.kernel.org
To: Martin =?iso-8859-2?Q?MOKREJ=A9?= <mmokrejs@ribosome.natur.cuni.cz>
Cc: Andrew Morton <akpm@osdl.org>, piggin@cyberone.com.au, chris@tebibyte.org, marcelo.tosatti@cyclades.com, andrea@novell.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>
List-Id: linux-mm.kvack.org

On Wed, 2004-11-24 at 16:52 +0100, Martin MOKREJ=C5=A0 wrote:
> > No, it's not related to hyperthreading. It's on the way out.=20
> >=20
> > I put an additional check into the page allocator. Does this help ?
>=20
> The application got killed. But, consider yourself the stacktrace ...=
 ;)

> oom-killer: gfp_mask=3D0x1d2
> Free pages:        3932kB (112kB HighMem)
>  [<c0103dfd>] dump_stack+0x1e/0x22
>  [<c013ec1c>] out_of_memory+0x97/0xcf
>  [<c0146dc8>] try_to_free_pages+0x163/0x184
>  [<c013fde2>] __alloc_pages+0x27e/0x400
>  [<c0142368>] do_page_cache_readahead+0x15b/0x1b9
>  [<c013c5aa>] filemap_nopage+0x2d4/0x375
>  [<c014aa82>] do_no_page+0xc4/0x38c
>  [<c014af30>] handle_mm_fault+0xde/0x189
>  [<c01166d5>] do_page_fault+0x456/0x6ad
>  [<c0103a43>] error_code+0x2b/0x30
> Out of Memory: Killed process 6672 (RNAsubopt).
> RNAsubopt: page allocation failure. order:0, mode:0x1d2
>  [<c0103dfd>] dump_stack+0x1e/0x22
>  [<c013fd90>] __alloc_pages+0x22c/0x400
>  [<c0142368>] do_page_cache_readahead+0x15b/0x1b9
>  [<c013c5aa>] filemap_nopage+0x2d4/0x375
>  [<c014aa82>] do_no_page+0xc4/0x38c
>  [<c014af30>] handle_mm_fault+0xde/0x189
>  [<c01166d5>] do_page_fault+0x456/0x6ad
>  [<c0103a43>] error_code+0x2b/0x30

Yep, that's expected. The first stacktrace is from my patch. I added
this to see from where the allocation is called. The second trace is
from the page fault handler, as the allocation request now returns
failed to prevent the second call into oom.

tglx
