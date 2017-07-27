Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 85D736B04C9
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 16:41:08 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z48so34382966wrc.4
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 13:41:08 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y94si16290645wrc.530.2017.07.27.13.41.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 13:41:07 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6RKf325051569
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 16:41:05 -0400
Received: from e24smtp04.br.ibm.com (e24smtp04.br.ibm.com [32.104.18.25])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2byj7a6fe0-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 16:41:04 -0400
Received: from localhost
	by e24smtp04.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bauerman@linux.vnet.ibm.com>;
	Thu, 27 Jul 2017 17:40:59 -0300
Received: from d24av02.br.ibm.com (d24av02.br.ibm.com [9.8.31.93])
	by d24relay03.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6RKetaf35979280
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 17:40:55 -0300
Received: from d24av02.br.ibm.com (localhost [127.0.0.1])
	by d24av02.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6RKewmG022674
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 17:40:58 -0300
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com> <1500177424-13695-16-git-send-email-linuxram@us.ibm.com>
From: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
Subject: Re: [RFC v6 15/62] powerpc: helper functions to initialize AMR, IAMR and UMOR registers
In-reply-to: <1500177424-13695-16-git-send-email-linuxram@us.ibm.com>
Date: Thu, 27 Jul 2017 17:40:44 -0300
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <877eyt4nqr.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, arnd@arndb.de, corbet@lwn.net, mhocko@kernel.org, dave.hansen@intel.com, mingo@redhat.com, paulus@samba.org, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com


Ram Pai <linuxram@us.ibm.com> writes:

> Introduce helper functions that can initialize the bits in the AMR,
> IAMR and UMOR register; the bits that correspond to the given pkey.
>
> Signed-off-by: Ram Pai <linuxram@us.ibm.com>

s/UMOR/UAMOR/ here and in the subject as well.

> --- a/arch/powerpc/mm/pkeys.c
> +++ b/arch/powerpc/mm/pkeys.c
> @@ -16,3 +16,47 @@
>  #include <linux/pkeys.h>                /* PKEY_*                       */
>
>  bool pkey_inited;
> +#define pkeyshift(pkey) ((arch_max_pkey()-pkey-1) * AMR_BITS_PER_PKEY)
> +
> +static inline void init_amr(int pkey, u8 init_bits)
> +{
> +	u64 new_amr_bits = (((u64)init_bits & 0x3UL) << pkeyshift(pkey));
> +	u64 old_amr = read_amr() & ~((u64)(0x3ul) << pkeyshift(pkey));
> +
> +	write_amr(old_amr | new_amr_bits);
> +}
> +
> +static inline void init_iamr(int pkey, u8 init_bits)
> +{
> +	u64 new_iamr_bits = (((u64)init_bits & 0x3UL) << pkeyshift(pkey));
> +	u64 old_iamr = read_iamr() & ~((u64)(0x3ul) << pkeyshift(pkey));
> +
> +	write_amr(old_iamr | new_iamr_bits);
> +}

init_iamr should call write_iamr, not write_amr.

-- 
Thiago Jung Bauermann
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
