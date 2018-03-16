Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id DB95E6B000E
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 18:13:15 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id az5-v6so6231382plb.14
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:13:15 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id x24-v6si6903980pll.83.2018.03.16.15.13.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 15:13:14 -0700 (PDT)
Subject: Re: [PATCH v12 09/22] selftests/vm: fix alloc_random_pkey() to make
 it really random
References: <1519264541-7621-1-git-send-email-linuxram@us.ibm.com>
 <1519264541-7621-10-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <9e410d84-3cd3-edf5-4699-26fcc2bbb393@intel.com>
Date: Fri, 16 Mar 2018 15:13:06 -0700
MIME-Version: 1.0
In-Reply-To: <1519264541-7621-10-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@redhat.com, akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, arnd@arndb.de

On 02/21/2018 05:55 PM, Ram Pai wrote:
> alloc_random_pkey() was allocating the same pkey every time.
> Not all pkeys were geting tested. fixed it.
...
> @@ -602,13 +603,15 @@ int alloc_random_pkey(void)
>  	int alloced_pkeys[NR_PKEYS];
>  	int nr_alloced = 0;
>  	int random_index;
> +
>  	memset(alloced_pkeys, 0, sizeof(alloced_pkeys));
> +	srand((unsigned int)time(NULL));
>  
>  	/* allocate every possible key and make a note of which ones we got */
>  	max_nr_pkey_allocs = NR_PKEYS;
> -	max_nr_pkey_allocs = 1;
>  	for (i = 0; i < max_nr_pkey_allocs; i++) {
>  		int new_pkey = alloc_pkey();

The srand() is probably useful, but won't this always just do a single
alloc_pkey() now?  That seems like it will mean we always use the first
one the kernel gives us, which isn't random.

> -	dprintf1("%s()::%d, ret: %d pkey_reg: 0x%x shadow: 0x%x\n", __func__,
> -			__LINE__, ret, __rdpkey_reg(), shadow_pkey_reg);
> +	dprintf1("%s()::%d, ret: %d pkey_reg: 0x%x shadow: 0x%016lx\n",
> +		__func__, __LINE__, ret, __rdpkey_reg(), shadow_pkey_reg);
>  	return ret;
>  }

This belonged in the pkey_reg_t patch, I think.
