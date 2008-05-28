Date: Wed, 28 May 2008 22:43:56 +0200
From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH] Re: bad pmd ffff810000207238(9090909090909090).
Message-ID: <20080528204356.GA12687@1wt.eu>
References: <483CBCDD.10401@lugmen.org.ar> <Pine.LNX.4.64.0805281922530.7959@blonde.site> <20080528195637.GA11662@1wt.eu> <alpine.LNX.1.10.0805282210580.19264@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.1.10.0805282210580.19264@fbirervta.pbzchgretzou.qr>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jan Engelhardt <jengelh@medozas.de>
Cc: Hugh Dickins <hugh@veritas.com>, Fede <fedux@lugmen.org.ar>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 28, 2008 at 10:14:31PM +0200, Jan Engelhardt wrote:
> 
> On Wednesday 2008-05-28 21:56, Willy Tarreau wrote:
> >On Wed, May 28, 2008 at 07:36:07PM +0100, Hugh Dickins wrote:
> >> On Tue, 27 May 2008, Fede wrote:
> >> > 
> >> > Today I tried to start a firewalling script and failed due to an unrelated
> >> > issue, but when I checked the log I saw this:
> >> > 
> >> > May 27 20:38:15 kaoz ip_tables: (C) 2000-2006 Netfilter Core Team
> >> > May 27 20:38:28 kaoz Netfilter messages via NETLINK v0.30.
> >> > May 27 20:38:28 kaoz nf_conntrack version 0.5.0 (16384 buckets, 65536 max)
> >> > May 27 20:38:28 kaoz ctnetlink v0.93: registering with nfnetlink.
> >> > May 27 20:38:28 kaoz ClusterIP Version 0.8 loaded successfully
> >> > May 27 20:38:28 kaoz mm/memory.c:127: bad pmd
> >> > ffff810000207238(9090909090909090).
> >> > 
> >> > I also found another post with a very similar issue. The other post had almost
> >> > the same message (*mm*/*memory*.*c*:*127*: *bad* *pmd*
> >> > ffff810000207808(9090909090909090).)
> >> > 
> >> > Does anyone know what is it?
> >> 
> >> Thanks a lot for re-reporting this: it was fun to work it out.
> >> It's not a rootkit, it's harmless, but we ought to fix the noise.
> >> Simple patch below, but let me explain more verbosely first.
> >> 
> >> What was really interesting in your report was that the address
> >> is so close to that in OGAWA-San's report.  I had a look at that
> >> page on my x86_64 boxes, and they have lots of 0x90s there too.
> >> It's just some page alignment filler that x86_64 kernel startup
> >> has missed cleaning up - patch below fixes that.  There's no
> >> security aspect to it: the entries were already not-present,
> >> they just generate this noise by triggering the pmd_bad test.
> >
> >Is there a particular reason we use 0x90 as an alignment filler ?
> 
> Alignment within functions. You could use a JMP to jump over
> the alignment, but that would be costly. So in order to
> "run through the wall", you need an opcode that does not
> do anything, something like 0x90.
> 0xAF would map to scasd on x86, and I'd hardly call that a
> no-op.

OK, I did not understand from Hugh's explanation that it was
all about alignment within functions. Of course, 0x90 is fine
there (though there are multi-byte NOPs available).

Cheers,
Willy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
