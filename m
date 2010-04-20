Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1F10C6B01F5
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 19:26:18 -0400 (EDT)
Date: Wed, 21 Apr 2010 00:07:19 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: Suspicious compilation warning
Message-ID: <20100420230719.GB1432@n2100.arm.linux.org.uk>
References: <k2ncecb6d8f1004191627w3cd36450xf797f746460abb09@mail.gmail.com> <20100420155122.6f2c26eb.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100420155122.6f2c26eb.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Jimenez <mroberto@cpti.cetuc.puc-rio.br>, Stephen Rothwell <sfr@canb.auug.org.au>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "H. Peter Anvin" <hpa@zytor.com>, Yinghai Lu <yinghai@kernel.org>, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 20, 2010 at 03:51:22PM -0700, Andrew Morton wrote:
> On Mon, 19 Apr 2010 20:27:43 -0300
> Marcelo Jimenez <mroberto@cpti.cetuc.puc-rio.br> wrote:
> 
> > I get this warning while compiling for ARM/SA1100:
> > 
> > mm/sparse.c: In function '__section_nr':
> > mm/sparse.c:135: warning: 'root' is used uninitialized in this function
> > 
> > With a small patch in fs/proc/meminfo.c, I find that NR_SECTION_ROOTS
> > is zero, which certainly explains the warning.
> > 
> > # cat /proc/meminfo
> > NR_SECTION_ROOTS=0
> > NR_MEM_SECTIONS=32
> > SECTIONS_PER_ROOT=512
> > SECTIONS_SHIFT=5
> > MAX_PHYSMEM_BITS=32
> 
> hm, who owns sparsemem nowadays? Nobody identifiable.
> 
> Does it make physical sense to have SECTIONS_PER_ROOT > NR_MEM_SECTIONS?

Well, it'll be about this number on everything using sparsemem extreme:

#define SECTIONS_PER_ROOT       (PAGE_SIZE / sizeof (struct mem_section))

and with only 32 sections, this is going to give a NR_SECTION_ROOTS value
of zero.  I think the calculation of NR_SECTIONS_ROOTS is wrong.

#define NR_SECTION_ROOTS        (NR_MEM_SECTIONS / SECTIONS_PER_ROOT)

Clearly if we have 1 mem section, we want to have one section root, so
I think this division should round up any fractional part, thusly:

#define NR_SECTION_ROOTS        ((NR_MEM_SECTIONS + SECTIONS_PER_ROOT - 1) / SECTIONS_PER_ROOT)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
