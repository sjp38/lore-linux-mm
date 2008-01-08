Message-ID: <47835FBE.8080406@de.ibm.com>
Date: Tue, 08 Jan 2008 12:34:22 +0100
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: [rfc][patch 0/4] VM_MIXEDMAP patchset with s390 backend
References: <20071214133817.GB28555@wotan.suse.de> <20071214134106.GC28555@wotan.suse.de> <476A73F0.4070704@de.ibm.com> <476A7D21.7070607@de.ibm.com> <20071221004556.GB31040@wotan.suse.de> <476B9000.2090707@de.ibm.com> <20071221102052.GB28484@wotan.suse.de> <476B96D6.2010302@de.ibm.com> <20071221104701.GE28484@wotan.suse.de> <1199784954.25114.27.camel@cotte.boeblingen.de.ibm.com> <20080108100803.GA24570@wotan.suse.de>
In-Reply-To: <20080108100803.GA24570@wotan.suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: carsteno@de.ibm.com, Jared Hulbert <jaredeh@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>, Heiko Carstens <h.carstens@de.ibm.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> I'm just curious (or forgetful) as to why s390's pfn_valid does not walk
> your memory segments? (That would allow the s390 proof of concept to be
> basically a noop, and mixedmap_refcount_pfn will only be required when
> we start using another pte bit.
Our pfn_valid uses a hardware instruction, which does check if there 
is memory behind a pfn which we can access. And we'd like to use the 
very same memory segment for both regular memory hotplug where the 
memory ends up in ZONE_NORMAL (in this case the memory would be 
read+write, and not shared with other guests), and for backing xip 
file systems (in this case the memory would be read-only, and shared). 
And in both cases, our instruction does consider the pfn to be valid. 
Thus, pfn_valid is not the right indicator for us to check if we need 
refcounting or not.

> I think using another bit in the pte for special mappings is reasonable.
> As I posted in my earlier patch, we can also use it to simplify vm_normal_page,
> and it facilitates a lock free get_user_pages.
That patch looks very nice. I am going to define PTE_SPECIAL for s390 
arch next...

> Anyway, hmm... I guess we should probably get these patches into -mm and
> then upstream soon. Any objections from anyone? Do you guys have performance /
> stress testing for xip?
I think it is mature enough to push upstream, I've booted a distro 
with /usr on it. But I really really want to exchange patch #4 with a 
pte-bit based one before pushing this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
