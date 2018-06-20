Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 735816B0006
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 11:11:10 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id r8-v6so1422815pgq.2
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 08:11:10 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id n21-v6si2063507pgc.229.2018.06.20.08.11.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jun 2018 08:11:09 -0700 (PDT)
Subject: Re: [PATCH v13 18/24] selftests/vm: fix an assertion in
 test_pkey_alloc_exhaust()
References: <1528937115-10132-1-git-send-email-linuxram@us.ibm.com>
 <1528937115-10132-19-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <55227442-a573-62b1-3206-1f3065a4b55f@intel.com>
Date: Wed, 20 Jun 2018 08:11:07 -0700
MIME-Version: 1.0
In-Reply-To: <1528937115-10132-19-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

On 06/13/2018 05:45 PM, Ram Pai wrote:
>  	/*
> -	 * There are 16 pkeys supported in hardware.  Three are
> -	 * allocated by the time we get here:
> -	 *   1. The default key (0)
> -	 *   2. One possibly consumed by an execute-only mapping.
> -	 *   3. One allocated by the test code and passed in via
> -	 *      'pkey' to this function.
> -	 * Ensure that we can allocate at least another 13 (16-3).
> +	 * There are NR_PKEYS pkeys supported in hardware. arch_reserved_keys()
> +	 * are reserved. One of which is the default key(0). One can be taken
> +	 * up by an execute-only mapping.
> +	 * Ensure that we can allocate at least the remaining.
>  	 */
> -	pkey_assert(i >= NR_PKEYS-3);
> +	pkey_assert(i >= (NR_PKEYS-arch_reserved_keys()-1));

We recently had a bug here.  I fixed it and left myself a really nice
comment so I and others wouldn't screw it up in the future.

Does this kill my nice, new comment?
