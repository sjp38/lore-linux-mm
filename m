Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7BE1C6B0007
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 10:54:00 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id r8-v6so1399187pgq.2
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 07:54:00 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id n68-v6si2517830pfb.152.2018.06.20.07.53.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jun 2018 07:53:59 -0700 (PDT)
Subject: Re: [PATCH v13 13/24] selftests/vm: pkey register should match shadow
 pkey
References: <1528937115-10132-1-git-send-email-linuxram@us.ibm.com>
 <1528937115-10132-14-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <6246f823-77d9-6727-097e-73f103078a44@intel.com>
Date: Wed, 20 Jun 2018 07:53:57 -0700
MIME-Version: 1.0
In-Reply-To: <1528937115-10132-14-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

On 06/13/2018 05:45 PM, Ram Pai wrote:
> +++ b/tools/testing/selftests/vm/protection_keys.c
> @@ -916,10 +916,10 @@ void expected_pkey_fault(int pkey)
>  		pkey_assert(last_si_pkey == pkey);
>  
>  	/*
> -	 * The signal handler shold have cleared out PKEY register to let the
> +	 * The signal handler should have cleared out pkey-register to let the
>  	 * test program continue.  We now have to restore it.
>  	 */
> -	if (__read_pkey_reg() != 0)
> +	if (__read_pkey_reg() != shadow_pkey_reg)
>  		pkey_assert(0);
>  
>  	__write_pkey_reg(shadow_pkey_reg);

I think this is wrong on x86.

When we leave the signal handler, we zero out PKRU so that the faulting
instruction can continue, that's why we have the check against zero.
I'm actually kinda surprised this works.

Logically, this patch does:

	if (hardware != shadow)
		error();
	hardware = shadow;

That does not look right to me.  What we want is:

	if (hardware != signal_return_pkey_reg)
		error();
	hardware = shadow;
