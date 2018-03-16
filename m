Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2948A6B0009
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 18:19:22 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 62-v6so6251336ply.4
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:19:22 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id d13si5731120pgn.366.2018.03.16.15.19.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 15:19:21 -0700 (PDT)
Subject: Re: [PATCH v12 11/22] selftests/vm: pkey register should match shadow
 pkey
References: <1519264541-7621-1-git-send-email-linuxram@us.ibm.com>
 <1519264541-7621-12-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <e9270064-4951-26dc-aeb0-1378fd7ab542@intel.com>
Date: Fri, 16 Mar 2018 15:19:12 -0700
MIME-Version: 1.0
In-Reply-To: <1519264541-7621-12-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@redhat.com, akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, arnd@arndb.de

On 02/21/2018 05:55 PM, Ram Pai wrote:
> expected_pkey_fault() is comparing the contents of pkey
> register with 0. This may not be true all the time. There
> could be bits set by default by the architecture
> which can never be changed. Hence compare the value against
> shadow pkey register, which is supposed to track the bits
> accurately all throughout
> 
> cc: Dave Hansen <dave.hansen@intel.com>
> cc: Florian Weimer <fweimer@redhat.com>
> Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> ---
>  tools/testing/selftests/vm/protection_keys.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/tools/testing/selftests/vm/protection_keys.c b/tools/testing/selftests/vm/protection_keys.c
> index 254b66d..6054093 100644
> --- a/tools/testing/selftests/vm/protection_keys.c
> +++ b/tools/testing/selftests/vm/protection_keys.c
> @@ -926,10 +926,10 @@ void expected_pkey_fault(int pkey)
>  	pkey_assert(last_pkey_faults + 1 == pkey_faults);
>  	pkey_assert(last_si_pkey == pkey);
>  	/*
> -	 * The signal handler shold have cleared out PKEY register to let the
> +	 * The signal handler shold have cleared out pkey-register to let the

Heh, you randomly changed the formatting and didn't bother with my awful
typo. :)

>  	 * test program continue.  We now have to restore it.
>  	 */
> -	if (__rdpkey_reg() != 0)
> +	if (__rdpkey_reg() != shadow_pkey_reg)
>  		pkey_assert(0);
>  
>  	__wrpkey_reg(shadow_pkey_reg);
> 

I don't think this should be "shadow_pkey_reg".  This was just trying to
double-check that the signal handler messed around with PKRU the way we
expected.

We could also just check that the disable bits for 'pkey' are clear at
this point.  That would be almost as good.
