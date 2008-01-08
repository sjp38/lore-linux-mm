Date: Tue, 8 Jan 2008 11:08:03 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 0/4] VM_MIXEDMAP patchset with s390 backend
Message-ID: <20080108100803.GA24570@wotan.suse.de>
References: <20071214133817.GB28555@wotan.suse.de> <20071214134106.GC28555@wotan.suse.de> <476A73F0.4070704@de.ibm.com> <476A7D21.7070607@de.ibm.com> <20071221004556.GB31040@wotan.suse.de> <476B9000.2090707@de.ibm.com> <20071221102052.GB28484@wotan.suse.de> <476B96D6.2010302@de.ibm.com> <20071221104701.GE28484@wotan.suse.de> <1199784954.25114.27.camel@cotte.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1199784954.25114.27.camel@cotte.boeblingen.de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Carsten Otte <cotte@de.ibm.com>
Cc: carsteno@de.ibm.com, Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>, Heiko Carstens <h.carstens@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 08, 2008 at 10:35:54AM +0100, Carsten Otte wrote:
> Am Freitag, den 21.12.2007, 11:47 +0100 schrieb Nick Piggin:
> > BTW. having a per-arch function sounds reasonable for a start. I'd just give
> > it a long name, so that people don't start using it for weird things ;)
> > mixedmap_refcount_pfn() or something.
> Based on our previous discussion, and based on previous patches by Jared
> and Nick, this patch series makes XIP without struct page backing usable
> on s390 architecture.
> This patch set includes:
> 1/4: mm: introduce VM_MIXEDMAP mappings from Jared Hulbert, modified to
> use an arch-callback to identify whether or not a pfn needs refcounting
> 2/4: xip: support non-struct page memory from Nick Piggin, modified to
> use an arch-callback to identify whether or not a pfn needs refcounting
> 3/4: s390: remove struct page entries for z/VM DCSS memory segments
> 4/4: s390: proof of concept implementation of mixedmap_refcount_pfn()
> for s390 using list-walk

Nice! I'm glad that the xip support didn't need anything further than
the mixedmap_refcount_pfn for s390. Hopefully it proves to be stable
under further testing.

I'm just curious (or forgetful) as to why s390's pfn_valid does not walk
your memory segments? (That would allow the s390 proof of concept to be
basically a noop, and mixedmap_refcount_pfn will only be required when
we start using another pte bit.

 
> Above stack seems to work well, I did some sniff-testing applied on top
> of Linus' current git tree. We do want to spend a precious pte bit to
> speed up this callback, therefore patch 4/4 will get replaced.

I think using another bit in the pte for special mappings is reasonable.
As I posted in my earlier patch, we can also use it to simplify vm_normal_page,
and it facilitates a lock free get_user_pages.

Anyway, hmm... I guess we should probably get these patches into -mm and
then upstream soon. Any objections from anyone? Do you guys have performance /
stress testing for xip?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
