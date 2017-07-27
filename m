Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 55C596B02FD
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 10:02:02 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v102so35444330wrb.2
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 07:02:02 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f65si1858114wmg.36.2017.07.27.07.02.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 07:02:00 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6RDwagl039220
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 10:01:59 -0400
Received: from e24smtp03.br.ibm.com (e24smtp03.br.ibm.com [32.104.18.24])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2byf50fdf7-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 10:01:59 -0400
Received: from localhost
	by e24smtp03.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bauerman@linux.vnet.ibm.com>;
	Thu, 27 Jul 2017 11:01:57 -0300
Received: from d24av02.br.ibm.com (d24av02.br.ibm.com [9.8.31.93])
	by d24relay02.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6RE1sBs20185258
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 11:01:54 -0300
Received: from d24av02.br.ibm.com (localhost [127.0.0.1])
	by d24av02.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6RE1uZH019518
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 11:01:57 -0300
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com> <1500177424-13695-14-git-send-email-linuxram@us.ibm.com>
From: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
Subject: Re: [RFC v6 13/62] powerpc: track allocation status of all pkeys
In-reply-to: <1500177424-13695-14-git-send-email-linuxram@us.ibm.com>
Date: Thu, 27 Jul 2017 11:01:44 -0300
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87eft23rnb.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, arnd@arndb.de, corbet@lwn.net, mhocko@kernel.org, dave.hansen@intel.com, mingo@redhat.com, paulus@samba.org, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com


Hello Ram,

I'm still going through the patches and haven't formed a full picture of
the feature in my mind yet, so my comments today won't be particularly
insightful...

But hopefully the comments that I currently have will be helpful anyway.

Ram Pai <linuxram@us.ibm.com> writes:
> diff --git a/arch/powerpc/include/asm/pkeys.h b/arch/powerpc/include/asm/pkeys.h
> index 203d7de..09b268e 100644
> --- a/arch/powerpc/include/asm/pkeys.h
> +++ b/arch/powerpc/include/asm/pkeys.h
> @@ -2,21 +2,87 @@
>  #define _ASM_PPC64_PKEYS_H
>
>  extern bool pkey_inited;
> -#define ARCH_VM_PKEY_FLAGS 0
> +#define arch_max_pkey()  32
> +#define ARCH_VM_PKEY_FLAGS (VM_PKEY_BIT0 | VM_PKEY_BIT1 | VM_PKEY_BIT2 | \
> +				VM_PKEY_BIT3 | VM_PKEY_BIT4)
> +/*
> + * Bits are in BE format.
> + * NOTE: key 31, 1, 0 are not used.
> + * key 0 is used by default. It give read/write/execute permission.
> + * key 31 is reserved by the hypervisor.
> + * key 1 is recommended to be not used.
> + * PowerISA(3.0) page 1015, programming note.
> + */
> +#define PKEY_INITIAL_ALLOCAION  0xc0000001

There's a typo in the macro name, should be "ALLOCATION".

-- 
Thiago Jung Bauermann
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
