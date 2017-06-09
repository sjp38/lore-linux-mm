Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 530B46B0279
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 03:43:52 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id g15so4977501wmc.8
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 00:43:52 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t2si409509wrb.3.2017.06.09.00.43.50
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Jun 2017 00:43:50 -0700 (PDT)
Date: Fri, 9 Jun 2017 09:43:48 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Sleeping BUG in khugepaged for i586
Message-ID: <20170609074348.GB21764@dhcp22.suse.cz>
References: <20170605144401.5a7e62887b476f0732560fa0@linux-foundation.org>
 <caa7a4a3-0c80-432c-2deb-3480df319f65@suse.cz>
 <1e883924-9766-4d2a-936c-7a49b337f9e2@lwfinger.net>
 <9ab81c3c-e064-66d2-6e82-fc9bac125f56@suse.cz>
 <alpine.DEB.2.10.1706071352100.38905@chino.kir.corp.google.com>
 <20170608144831.GA19903@dhcp22.suse.cz>
 <20170608170557.GA8118@bombadil.infradead.org>
 <20170608201822.GA5535@dhcp22.suse.cz>
 <20170608203046.GB5535@dhcp22.suse.cz>
 <d348054d-3857-65bb-e896-c4bd2ea6ee85@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d348054d-3857-65bb-e896-c4bd2ea6ee85@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Matthew Wilcox <willy@infradead.org>, David Rientjes <rientjes@google.com>, Larry Finger <Larry.Finger@lwfinger.net>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri 09-06-17 08:48:58, Vlastimil Babka wrote:
> On 06/08/2017 10:30 PM, Michal Hocko wrote:
> > But I guess you are primary after syncing the preemptive mode for 64 and
> > 32b systems, right? I agree that having a different model is more than
> > unfortunate because 32b gets much less testing coverage and so a risk of
> > introducing a new bug is just a matter of time. Maybe we should make
> > pte_offset_map disable preemption and currently noop pte_unmap to
> > preempt_enable. The overhead should be pretty marginal on x86_64 but not
> > all arches have per-cpu preempt count. So I am not sure we really want
> > to add this to just for the debugging purposes...
> 
> I think adding that overhead for everyone would be unfortunate. It would
> be acceptable, if it was done only for the config option that enables
> the might_sleep() checks (CONFIG_DEBUG_ATOMIC_SLEEP?)

That is certainly possible. But is it worth it?
arch/alpha/include/asm/pgtable.h:#define pte_offset_map(dir,addr)	pte_offset_kernel((dir),(addr))
arch/arc/include/asm/pgtable.h:#define pte_offset_map(dir, addr)		pte_offset(dir, addr)
arch/arm/include/asm/pgtable.h:#define pte_offset_map(pmd,addr)	(__pte_map(pmd) + pte_index(addr))
arch/arm64/include/asm/pgtable.h:#define pte_offset_map(dir,addr)	pte_offset_kernel((dir), (addr))
arch/arm64/include/asm/pgtable.h:#define pte_offset_map_nested(dir,addr)	pte_offset_kernel((dir), (addr))
arch/cris/include/asm/pgtable.h:#define pte_offset_map(dir, address) \
arch/frv/include/asm/pgtable.h:#define pte_offset_map(dir, address) \
arch/frv/include/asm/pgtable.h:#define pte_offset_map(dir, address) \
arch/hexagon/include/asm/pgtable.h:#define pte_offset_map(dir, address)                                    \
arch/hexagon/include/asm/pgtable.h:#define pte_offset_map_nested(pmd, addr) pte_offset_map(pmd, addr)
arch/ia64/include/asm/pgtable.h:#define pte_offset_map(dir,addr)	pte_offset_kernel(dir, addr)
arch/m32r/include/asm/pgtable.h:#define pte_offset_map(dir, address)	\
arch/m68k/include/asm/mcf_pgtable.h:#define pte_offset_map(pmdp, addr) ((pte_t *)__pmd_page(*pmdp) + \
arch/m68k/include/asm/motorola_pgtable.h:#define pte_offset_map(pmdp,address) ((pte_t *)__pmd_page(*pmdp) + (((address) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1)))
arch/m68k/include/asm/sun3_pgtable.h:#define pte_offset_map(pmd, address) ((pte_t *)page_address(pmd_page(*pmd)) + pte_index(address))
arch/metag/include/asm/pgtable.h:#define pte_offset_map(dir, address)		pte_offset_kernel(dir, address)
arch/metag/include/asm/pgtable.h:#define pte_offset_map_nested(dir, address)	pte_offset_kernel(dir, address)
arch/microblaze/include/asm/pgtable.h:#define pte_offset_map(dir, addr)		\
arch/mips/include/asm/pgtable-32.h:#define pte_offset_map(dir, address)					\
arch/mips/include/asm/pgtable-64.h:#define pte_offset_map(dir, address)					\
arch/mn10300/include/asm/pgtable.h:#define pte_offset_map(dir, address) \
arch/nios2/include/asm/pgtable.h:#define pte_offset_map(dir, addr)			\
arch/openrisc/include/asm/pgtable.h:#define pte_offset_map(dir, address)	        \
arch/openrisc/include/asm/pgtable.h:#define pte_offset_map_nested(dir, address)     \
arch/parisc/include/asm/pgtable.h:#define pte_offset_map(pmd, address) pte_offset_kernel(pmd, address)
arch/powerpc/include/asm/book3s/32/pgtable.h:#define pte_offset_map(dir, addr)		\
arch/powerpc/include/asm/book3s/64/pgtable.h:#define pte_offset_map(dir,addr)	pte_offset_kernel((dir), (addr))
arch/powerpc/include/asm/nohash/32/pgtable.h:#define pte_offset_map(dir, addr)		\
arch/powerpc/include/asm/nohash/64/pgtable.h:#define pte_offset_map(dir,addr)	pte_offset_kernel((dir), (addr))
arch/s390/include/asm/pgtable.h:#define pte_offset_map(pmd, address) pte_offset_kernel(pmd, address)
arch/score/include/asm/pgtable.h:#define pte_offset_map(dir, address)	\
arch/sh/include/asm/pgtable_32.h:#define pte_offset_map(dir, address)		pte_offset_kernel(dir, address)
arch/sh/include/asm/pgtable_64.h:#define pte_offset_map(dir,addr)	pte_offset_kernel(dir, addr)
arch/sparc/include/asm/pgtable_32.h:#define pte_offset_map(d, a)		pte_offset_kernel(d,a)
arch/sparc/include/asm/pgtable_64.h:#define pte_offset_map			pte_index
arch/tile/include/asm/pgtable.h:#define pte_offset_map(dir, address) pte_offset_kernel(dir, address)
arch/um/include/asm/pgtable.h:#define pte_offset_map(dir, address) \
arch/unicore32/include/asm/pgtable.h:#define pte_offset_map(dir, addr)	(pmd_page_vaddr(*(dir)) \
arch/x86/include/asm/pgtable_32.h:#define pte_offset_map(dir, address)					\
arch/x86/include/asm/pgtable_32.h:#define pte_offset_map(dir, address)					\
arch/x86/include/asm/pgtable_64.h:#define pte_offset_map(dir, address) pte_offset_kernel((dir), (address))
arch/xtensa/include/asm/pgtable.h:#define pte_offset_map(dir,addr)	pte_offset_kernel((dir),(addr))
include/linux/mm.h:#define pte_offset_map_lock(mm, pmd, address, ptlp)	\
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
