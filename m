Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 792A86B02F4
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 01:57:07 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 125so24355488pgi.2
        for <linux-mm@kvack.org>; Wed, 19 Jul 2017 22:57:07 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id x84si1199417pgx.426.2017.07.19.22.57.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jul 2017 22:57:06 -0700 (PDT)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6K5tEmB131076
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 01:57:06 -0400
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2btce3w46s-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 01:57:05 -0400
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 20 Jul 2017 15:57:03 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6K5v0if26673320
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 15:57:00 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6K5uxNM018543
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 15:57:00 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC v6 03/62] powerpc: introduce pte_set_hash_slot() helper
In-Reply-To: <1500177424-13695-4-git-send-email-linuxram@us.ibm.com>
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com> <1500177424-13695-4-git-send-email-linuxram@us.ibm.com>
Date: Thu, 20 Jul 2017 11:26:53 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <874lu7r6qi.fsf@skywalker.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org
Cc: benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au, khandual@linux.vnet.ibm.com, bsingharora@gmail.com, dave.hansen@intel.com, hbabu@us.ibm.com, arnd@arndb.de, akpm@linux-foundation.org, corbet@lwn.net, mingo@redhat.com, mhocko@kernel.org

Ram Pai <linuxram@us.ibm.com> writes:

> Introduce pte_set_hash_slot().It  sets the (H_PAGE_F_SECOND|H_PAGE_F_GIX)
> bits at  the   appropriate   location   in   the   PTE  of  4K  PTE.  For
> 64K PTE, it  sets  the  bits  in  the  second  part  of  the  PTE. Though
> the implementation  for the former just needs the slot parameter, it does
> take some additional parameters to keep the prototype consistent.
>
> This function  will  be  handy  as  we   work   towards  re-arranging the
> bits in the later patches.
>

Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> ---
>  arch/powerpc/include/asm/book3s/64/hash-4k.h  |   15 +++++++++++++++
>  arch/powerpc/include/asm/book3s/64/hash-64k.h |   25 +++++++++++++++++++++++++
>  2 files changed, 40 insertions(+), 0 deletions(-)
>
> diff --git a/arch/powerpc/include/asm/book3s/64/hash-4k.h b/arch/powerpc/include/asm/book3s/64/hash-4k.h
> index d2cf949..dc153c6 100644
> --- a/arch/powerpc/include/asm/book3s/64/hash-4k.h
> +++ b/arch/powerpc/include/asm/book3s/64/hash-4k.h
> @@ -53,6 +53,21 @@ static inline int hash__hugepd_ok(hugepd_t hpd)
>  }
>  #endif
>
> +/*
> + * 4k pte format is  different  from  64k  pte  format.  Saving  the
> + * hash_slot is just a matter of returning the pte bits that need to
> + * be modified. On 64k pte, things are a  little  more  involved and
> + * hence  needs   many   more  parameters  to  accomplish  the  same.
> + * However we  want  to abstract this out from the caller by keeping
> + * the prototype consistent across the two formats.
> + */
> +static inline unsigned long pte_set_hash_slot(pte_t *ptep, real_pte_t rpte,
> +			unsigned int subpg_index, unsigned long slot)
> +{
> +	return (slot << H_PAGE_F_GIX_SHIFT) &
> +		(H_PAGE_F_SECOND | H_PAGE_F_GIX);
> +}
> +
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE
>
>  static inline char *get_hpte_slot_array(pmd_t *pmdp)
> diff --git a/arch/powerpc/include/asm/book3s/64/hash-64k.h b/arch/powerpc/include/asm/book3s/64/hash-64k.h
> index c281f18..89ef5a9 100644
> --- a/arch/powerpc/include/asm/book3s/64/hash-64k.h
> +++ b/arch/powerpc/include/asm/book3s/64/hash-64k.h
> @@ -67,6 +67,31 @@ static inline unsigned long __rpte_to_hidx(real_pte_t rpte, unsigned long index)
>  	return ((rpte.hidx >> (index<<2)) & 0xfUL);
>  }
>
> +/*
> + * Commit the hash slot and return pte bits that needs to be modified.
> + * The caller is expected to modify the pte bits accordingly and
> + * commit the pte to memory.
> + */
> +static inline unsigned long pte_set_hash_slot(pte_t *ptep, real_pte_t rpte,
> +		unsigned int subpg_index, unsigned long slot)
> +{
> +	unsigned long *hidxp = (unsigned long *)(ptep + PTRS_PER_PTE);
> +
> +	rpte.hidx &= ~(0xfUL << (subpg_index << 2));
> +	*hidxp = rpte.hidx  | (slot << (subpg_index << 2));
> +	/*
> +	 * Commit the hidx bits to memory before returning.
> +	 * Anyone reading  pte  must  ensure hidx bits are
> +	 * read  only  after  reading the pte by using the
> +	 * read-side  barrier  smp_rmb(). __real_pte() can
> +	 * help ensure that.
> +	 */
> +	smp_wmb();
> +
> +	/* no pte bits to be modified, return 0x0UL */
> +	return 0x0UL;
> +}
> +
>  #define __rpte_to_pte(r)	((r).pte)
>  extern bool __rpte_sub_valid(real_pte_t rpte, unsigned long index);
>  /*
> -- 
> 1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
