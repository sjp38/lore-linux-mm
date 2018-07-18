Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 24B6B6B0279
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 11:36:58 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id cf17-v6so2784120plb.2
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 08:36:58 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id w9-v6si3346665ply.462.2018.07.18.08.36.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 08:36:57 -0700 (PDT)
Subject: Re: [PATCH v14 08/22] selftests/vm: fix the wrong assert in
 pkey_disable_set()
References: <1531835365-32387-1-git-send-email-linuxram@us.ibm.com>
 <1531835365-32387-9-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <b8ace761-2140-afce-a1d4-fc2a27c8fd9e@intel.com>
Date: Wed, 18 Jul 2018 08:36:50 -0700
MIME-Version: 1.0
In-Reply-To: <1531835365-32387-9-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

On 07/17/2018 06:49 AM, Ram Pai wrote:
> If the flag is 0, no bits will be set. Hence we cant expect
> the resulting bitmap to have a higher value than what it
> was earlier.
...
> --- a/tools/testing/selftests/vm/protection_keys.c
> +++ b/tools/testing/selftests/vm/protection_keys.c
> @@ -415,7 +415,7 @@ void pkey_disable_set(int pkey, int flags)
>  	dprintf1("%s(%d) pkey_reg: 0x"PKEY_REG_FMT"\n",
>  		__func__, pkey, read_pkey_reg());
>  	if (flags)
> -		pkey_assert(read_pkey_reg() > orig_pkey_reg);
> +		pkey_assert(read_pkey_reg() >= orig_pkey_reg);
>  	dprintf1("END<---%s(%d, 0x%x)\n", __func__,
>  		pkey, flags);
>  }

I know these are just selftests, but this change makes zero sense
without the context from how powerpc works.  It's also totally
non-obvious from the patch itself what is going on, even though I
specifically called this out in a previous review.

Please add a comment here that either specifically calls out powerpc or
talks about "an architecture that does this ..."
