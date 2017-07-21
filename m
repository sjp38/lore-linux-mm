Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D0D8C6B025F
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 02:52:04 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id v31so15680139wrc.7
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 23:52:04 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 45si7508024wrx.82.2017.07.20.23.52.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jul 2017 23:52:03 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6L6mtlw060505
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 02:52:02 -0400
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2bu4ftg7n1-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 02:52:01 -0400
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Fri, 21 Jul 2017 16:51:59 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6L6punX29819104
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 16:51:56 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6L6psJG019078
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 16:51:55 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC v6 27/62] powerpc: helper to validate key-access permissions of a pte
In-Reply-To: <20170720221504.GJ5487@ram.oc3035372033.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com> <1500177424-13695-28-git-send-email-linuxram@us.ibm.com> <87mv7zpq1k.fsf@skywalker.in.ibm.com> <20170720221504.GJ5487@ram.oc3035372033.ibm.com>
Date: Fri, 21 Jul 2017 12:21:50 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87k232p9ix.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

Ram Pai <linuxram@us.ibm.com> writes:

> On Thu, Jul 20, 2017 at 12:12:47PM +0530, Aneesh Kumar K.V wrote:
>> Ram Pai <linuxram@us.ibm.com> writes:
>> 
>> > helper function that checks if the read/write/execute is allowed
>> > on the pte.
>> >
>> > Signed-off-by: Ram Pai <linuxram@us.ibm.com>
>> > ---
>> >  arch/powerpc/include/asm/book3s/64/pgtable.h |    4 +++
>> >  arch/powerpc/include/asm/pkeys.h             |   12 +++++++++
>> >  arch/powerpc/mm/pkeys.c                      |   33 ++++++++++++++++++++++++++
>> >  3 files changed, 49 insertions(+), 0 deletions(-)
>> >
>> > diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
>> > index 30d7f55..0056e58 100644
>> > --- a/arch/powerpc/include/asm/book3s/64/pgtable.h
>> > +++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
>> > @@ -472,6 +472,10 @@ static inline void write_uamor(u64 value)
>> >  	mtspr(SPRN_UAMOR, value);
>> >  }
>> >
>> > +#ifdef CONFIG_PPC64_MEMORY_PROTECTION_KEYS
>> > +extern bool arch_pte_access_permitted(u64 pte, bool write, bool execute);
>> > +#endif /* CONFIG_PPC64_MEMORY_PROTECTION_KEYS */
>> > +
>> >  #define __HAVE_ARCH_PTEP_GET_AND_CLEAR
>> >  static inline pte_t ptep_get_and_clear(struct mm_struct *mm,
>> >  				       unsigned long addr, pte_t *ptep)
>> > diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
>> > index bbb5d85..7a9aade 100644
>> > --- a/arch/powerpc/include/asm/pkeys.h
>> > +++ b/arch/powerpc/include/asm/pkeys.h
>> > @@ -53,6 +53,18 @@ static inline u64 pte_to_hpte_pkey_bits(u64 pteflags)
>> >  		((pteflags & H_PAGE_PKEY_BIT4) ? HPTE_R_KEY_BIT4 : 0x0UL));
>> >  }
>> >
>> > +static inline u16 pte_to_pkey_bits(u64 pteflags)
>> > +{
>> > +	if (!pkey_inited)
>> > +		return 0x0UL;
>> 
>> Do we really need that above check ? We should always find it
>> peky_inited to be set. 
>
> Yes. there are cases where pkey_inited is not enabled. 
> a) if the MMU is radix.
That should be be a feature check

> b) if the PAGE size is 4k.

That is a kernel config change

> c) if the device tree says the feature is not available
> d) if the CPU is of a older generation. P6 and older.

Both feature check.

how about doing something like

static inline u16 pte_to_pkey_bits(u64 pteflags)
{
	if (!(pteflags & H_PAGE_KEY_MASK))
		return 0x0UL;

	return (((pteflags & H_PAGE_PKEY_BIT0) ? 0x10 : 0x0UL) |
		((pteflags & H_PAGE_PKEY_BIT1) ? 0x8 : 0x0UL) |
		((pteflags & H_PAGE_PKEY_BIT2) ? 0x4 : 0x0UL) |
		((pteflags & H_PAGE_PKEY_BIT3) ? 0x2 : 0x0UL) |
		((pteflags & H_PAGE_PKEY_BIT4) ? 0x1 : 0x0UL));
}

We still have to look at the code generated to see it is really saving
something.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
