Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6DCDF6B025F
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 18:15:22 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id e199so40687053pfh.7
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 15:15:22 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id o5si2224234pgk.27.2017.07.20.15.15.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jul 2017 15:15:21 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6KMEWrM022288
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 18:15:21 -0400
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bu01acdfb-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 18:15:18 -0400
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Thu, 20 Jul 2017 16:15:16 -0600
Date: Thu, 20 Jul 2017 15:15:04 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [RFC v6 27/62] powerpc: helper to validate key-access
 permissions of a pte
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com>
 <1500177424-13695-28-git-send-email-linuxram@us.ibm.com>
 <87mv7zpq1k.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87mv7zpq1k.fsf@skywalker.in.ibm.com>
Message-Id: <20170720221504.GJ5487@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

On Thu, Jul 20, 2017 at 12:12:47PM +0530, Aneesh Kumar K.V wrote:
> Ram Pai <linuxram@us.ibm.com> writes:
> 
> > helper function that checks if the read/write/execute is allowed
> > on the pte.
> >
> > Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> > ---
> >  arch/powerpc/include/asm/book3s/64/pgtable.h |    4 +++
> >  arch/powerpc/include/asm/pkeys.h             |   12 +++++++++
> >  arch/powerpc/mm/pkeys.c                      |   33 ++++++++++++++++++++++++++
> >  3 files changed, 49 insertions(+), 0 deletions(-)
> >
> > diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
> > index 30d7f55..0056e58 100644
> > --- a/arch/powerpc/include/asm/book3s/64/pgtable.h
> > +++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
> > @@ -472,6 +472,10 @@ static inline void write_uamor(u64 value)
> >  	mtspr(SPRN_UAMOR, value);
> >  }
> >
> > +#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
> > +extern bool arch_pte_access_permitted(u64 pte, bool write, bool execute);
> > +#endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
> > +
> >  #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
> >  static inline pte_t ptep_get_and_clear(struct mm_struct *mm,
> >  				       unsigned long addr, pte_t *ptep)
> > diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
> > index bbb5d85..7a9aade 100644
> > --- a/arch/powerpc/include/asm/pkeys.h
> > +++ b/arch/powerpc/include/asm/pkeys.h
> > @@ -53,6 +53,18 @@ static inline u64 pte_to_hpte_pkey_bits(u64 pteflags)
> >  		((pteflags & H_PAGE_PKEY_BIT4) ? HPTE_R_KEY_BIT4 : 0x0UL));
> >  }
> >
> > +static inline u16 pte_to_pkey_bits(u64 pteflags)
> > +{
> > +	if (!pkey_inited)
> > +		return 0x0UL;
> 
> Do we really need that above check ? We should always find it
> peky_inited to be set. 

Yes. there are cases where pkey_inited is not enabled. 
a) if the MMU is radix.
b) if the PAGE size is 4k.
c) if the device tree says the feature is not available
d) if the CPU is of a older generation. P6 and older.

RP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
