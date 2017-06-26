Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6CCAE6B02C3
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 00:03:26 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id w6so45178059qtg.12
        for <linux-mm@kvack.org>; Sun, 25 Jun 2017 21:03:26 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id b26si10324730qkj.283.2017.06.25.21.03.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 25 Jun 2017 21:03:25 -0700 (PDT)
Message-ID: <1498449778.31581.118.camel@kernel.crashing.org>
Subject: Re: [RFC v3 02/23] powerpc: introduce set_hidx_slot helper
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Sun, 25 Jun 2017 23:02:58 -0500
In-Reply-To: <1498431798.7935.5.camel@gmail.com>
References: <1498095579-6790-1-git-send-email-linuxram@us.ibm.com>
	 <1498095579-6790-3-git-send-email-linuxram@us.ibm.com>
	 <1498431798.7935.5.camel@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, Ram Pai <linuxram@us.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On Mon, 2017-06-26 at 09:03 +1000, Balbir Singh wrote:
> On Wed, 2017-06-21 at 18:39 -0700, Ram Pai wrote:
> > Introduce set_hidx_slot() which sets the (H_PAGE_F_SECOND|H_PAGE_F_GIX)
> > bits at  the  appropriate  location  in  the  PTE  of  4K  PTE.  In the
> > case of 64K PTE, it sets the bits in the second part of the PTE. Though
> > the implementation for the former just needs the slot parameter, it does
> > take some additional parameters to keep the prototype consistent.
> > 
> > This function will come in handy as we  work  towards  re-arranging the
> > bits in the later patches.

The name somewhat sucks. Something like pte_set_hash_slot() or
something like that would be much more meaningful.

> > Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> > ---
> >  arch/powerpc/include/asm/book3s/64/hash-4k.h  |  7 +++++++
> >  arch/powerpc/include/asm/book3s/64/hash-64k.h | 16 ++++++++++++++++
> >  2 files changed, 23 insertions(+)
> > 
> > diff --git a/arch/powerpc/include/asm/book3s/64/hash-4k.h b/arch/powerpc/include/asm/book3s/64/hash-4k.h
> > index 9c2c8f1..cef644c 100644
> > --- a/arch/powerpc/include/asm/book3s/64/hash-4k.h
> > +++ b/arch/powerpc/include/asm/book3s/64/hash-4k.h
> > @@ -55,6 +55,13 @@ static inline int hash__hugepd_ok(hugepd_t hpd)
> >  }
> >  #endif
> >  
> > +static inline unsigned long set_hidx_slot(pte_t *ptep, real_pte_t rpte,
> > +			unsigned int subpg_index, unsigned long slot)
> > +{
> > +	return (slot << H_PAGE_F_GIX_SHIFT) &
> > +		(H_PAGE_F_SECOND | H_PAGE_F_GIX);
> > +}
> > +
> 
> A comment on top would help explain that 4k and 64k are different, 64k
> is a new layout.
> 
> >  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
> >  
> >  static inline char *get_hpte_slot_array(pmd_t *pmdp)
> > diff --git a/arch/powerpc/include/asm/book3s/64/hash-64k.h b/arch/powerpc/include/asm/book3s/64/hash-64k.h
> > index 3f49941..4bac70a 100644
> > --- a/arch/powerpc/include/asm/book3s/64/hash-64k.h
> > +++ b/arch/powerpc/include/asm/book3s/64/hash-64k.h
> > @@ -75,6 +75,22 @@ static inline unsigned long __rpte_to_hidx(real_pte_t rpte, unsigned long index)
> >  	return (pte_val(rpte.pte) >> H_PAGE_F_GIX_SHIFT) & 0xf;
> >  }
> >  
> > +static inline unsigned long set_hidx_slot(pte_t *ptep, real_pte_t rpte,
> > +		unsigned int subpg_index, unsigned long slot)
> > +{
> > +	unsigned long *hidxp = (unsigned long *)(ptep + PTRS_PER_PTE);
> > +
> > +	rpte.hidx &= ~(0xfUL << (subpg_index << 2));
> > +	*hidxp = rpte.hidx  | (slot << (subpg_index << 2));
> > +	/*
> > +	 * Avoid race with __real_pte()
> > +	 * hidx must be committed to memory before committing
> > +	 * the pte.
> > +	 */
> > +	smp_wmb();
> 
> Whats the other paired barrier, is it in set_pte()?
> 
> > +	return 0x0UL;
> > +}
> 
> We return 0 here and slot information for 4k pages, it is not that
> clear
> 
> Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
