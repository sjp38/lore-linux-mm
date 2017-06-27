Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id BFF886B0279
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 20:16:49 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b13so14402889pgn.4
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 17:16:49 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id k85si858281pfb.470.2017.06.26.17.16.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 17:16:49 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v5R0DnJf108793
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 20:16:48 -0400
Received: from e17.ny.us.ibm.com (e17.ny.us.ibm.com [129.33.205.207])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bb563rx1c-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 20:16:48 -0400
Received: from localhost
	by e17.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Mon, 26 Jun 2017 20:16:46 -0400
Date: Mon, 26 Jun 2017 17:16:37 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [RFC v3 02/23] powerpc: introduce set_hidx_slot helper
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1498095579-6790-1-git-send-email-linuxram@us.ibm.com>
 <1498095579-6790-3-git-send-email-linuxram@us.ibm.com>
 <1498431798.7935.5.camel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1498431798.7935.5.camel@gmail.com>
Message-Id: <20170627001637.GA5846@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com

On Mon, Jun 26, 2017 at 09:03:18AM +1000, Balbir Singh wrote:
> On Wed, 2017-06-21 at 18:39 -0700, Ram Pai wrote:
> > Introduce set_hidx_slot() which sets the (H_PAGE_F_SECOND|H_PAGE_F_GIX)
> > bits at  the  appropriate  location  in  the  PTE  of  4K  PTE.  In the
> > case of 64K PTE, it sets the bits in the second part of the PTE. Though
> > the implementation for the former just needs the slot parameter, it does
> > take some additional parameters to keep the prototype consistent.
> > 
> > This function will come in handy as we  work  towards  re-arranging the
> > bits in the later patches.
> > 
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

ok.

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

 __real_pte() reads the hidx. The smp_rmb() is in that function.

> 
> > +	return 0x0UL;
> > +}
> 
> We return 0 here and slot information for 4k pages, it is not that
> clear

We return 0 here and commit the 4k-hpte hidx. 


RP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
