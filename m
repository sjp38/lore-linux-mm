Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 496D86B056F
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 17:00:21 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id q50so39692716wrb.14
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 14:00:21 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id m142si3049791wmd.203.2017.07.28.14.00.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jul 2017 14:00:20 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6SKxh1e119522
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 17:00:18 -0400
Received: from e24smtp04.br.ibm.com (e24smtp04.br.ibm.com [32.104.18.25])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2c0aetdy7f-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 17:00:18 -0400
Received: from localhost
	by e24smtp04.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <bauerman@linux.vnet.ibm.com>;
	Fri, 28 Jul 2017 18:00:16 -0300
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
	by d24relay03.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v6SL0Dv739649296
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 18:00:13 -0300
Received: from d24av04.br.ibm.com (localhost [127.0.0.1])
	by d24av04.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v6SL0EjX013096
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 18:00:14 -0300
References: <1500177424-13695-1-git-send-email-linuxram@us.ibm.com> <1500177424-13695-28-git-send-email-linuxram@us.ibm.com>
From: Thiago Jung Bauermann <bauerman@linux.vnet.ibm.com>
Subject: Re: [RFC v6 27/62] powerpc: helper to validate key-access permissions of a pte
In-reply-to: <1500177424-13695-28-git-send-email-linuxram@us.ibm.com>
Date: Fri, 28 Jul 2017 18:00:02 -0300
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87tw1we0q5.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-kselftest@vger.kernel.org, arnd@arndb.de, corbet@lwn.net, mhocko@kernel.org, dave.hansen@intel.com, mingo@redhat.com, paulus@samba.org, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com


Ram Pai <linuxram@us.ibm.com> writes:
> --- a/arch/powerpc/mm/pkeys.c
> +++ b/arch/powerpc/mm/pkeys.c
> @@ -201,3 +201,36 @@ int __arch_override_mprotect_pkey(struct vm_area_struct *vma, int prot,
>  	 */
>  	return vma_pkey(vma);
>  }
> +
> +static bool pkey_access_permitted(int pkey, bool write, bool execute)
> +{
> +	int pkey_shift;
> +	u64 amr;
> +
> +	if (!pkey)
> +		return true;
> +
> +	pkey_shift = pkeyshift(pkey);
> +	if (!(read_uamor() & (0x3UL << pkey_shift)))
> +		return true;
> +
> +	if (execute && !(read_iamr() & (IAMR_EX_BIT << pkey_shift)))
> +		return true;
> +
> +	if (!write) {
> +		amr = read_amr();
> +		if (!(amr & (AMR_RD_BIT << pkey_shift)))
> +			return true;
> +	}
> +
> +	amr = read_amr(); /* delay reading amr uptil absolutely needed */

Actually, this is causing amr to be read twice in case control enters
the "if (!write)" block above but doesn't enter the other if block nested
in it.

read_amr should be called only once, right before "if (!write)".

-- 
Thiago Jung Bauermann
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
