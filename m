Date: Tue, 8 Jan 2008 12:55:36 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 0/4] VM_MIXEDMAP patchset with s390 backend
Message-ID: <20080108115536.GB460@wotan.suse.de>
References: <476A73F0.4070704@de.ibm.com> <476A7D21.7070607@de.ibm.com> <20071221004556.GB31040@wotan.suse.de> <476B9000.2090707@de.ibm.com> <20071221102052.GB28484@wotan.suse.de> <476B96D6.2010302@de.ibm.com> <20071221104701.GE28484@wotan.suse.de> <1199784954.25114.27.camel@cotte.boeblingen.de.ibm.com> <20080108100803.GA24570@wotan.suse.de> <47835FBE.8080406@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <47835FBE.8080406@de.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: carsteno@de.ibm.com
Cc: Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>, Heiko Carstens <h.carstens@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 08, 2008 at 12:34:22PM +0100, Carsten Otte wrote:
> Nick Piggin wrote:
> >I'm just curious (or forgetful) as to why s390's pfn_valid does not walk
> >your memory segments? (That would allow the s390 proof of concept to be
> >basically a noop, and mixedmap_refcount_pfn will only be required when
> >we start using another pte bit.
> Our pfn_valid uses a hardware instruction, which does check if there 
> is memory behind a pfn which we can access. And we'd like to use the 
> very same memory segment for both regular memory hotplug where the 
> memory ends up in ZONE_NORMAL (in this case the memory would be 
> read+write, and not shared with other guests), and for backing xip 
> file systems (in this case the memory would be read-only, and shared). 
> And in both cases, our instruction does consider the pfn to be valid. 
> Thus, pfn_valid is not the right indicator for us to check if we need 
> refcounting or not.

Sure, but I think pfn_valid is _supposed_ to indicate whether the pfn has
a struct page, isn't it? I think that is the case with the other standard
memory models. That would make it applicable for you (ie. if it were
implemented as mixedmap_refcount_pfn).

Is it used in any performance critical paths that it needs to be really
fast?

(Anyway, this is just an aside -- I have no real problem with
mixedmap_refcount_pfn, or using a special pte bit...)


> >I think using another bit in the pte for special mappings is reasonable.
> >As I posted in my earlier patch, we can also use it to simplify 
> >vm_normal_page,
> >and it facilitates a lock free get_user_pages.
> That patch looks very nice. I am going to define PTE_SPECIAL for s390 
> arch next...

Great.


> >Anyway, hmm... I guess we should probably get these patches into -mm and
> >then upstream soon. Any objections from anyone? Do you guys have 
> >performance /
> >stress testing for xip?
> I think it is mature enough to push upstream, I've booted a distro 
> with /usr on it.

Oh good. So just to clarify -- I guess you guys have a readonly filesystem
containing the distro on the host, and mount it XIP on each guest... avoiding
struct page means you save a bit of memory on each guest?


> But I really really want to exchange patch #4 with a 
> pte-bit based one before pushing this.

OK fair enough, let's do that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
