Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DE35B6B0003
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 11:43:59 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e7-v6so2503228pfe.10
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 08:43:59 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id j61-v6si3498402plb.68.2018.07.18.08.43.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 08:43:58 -0700 (PDT)
Subject: Re: [PATCH v14 09/22] selftests/vm: fixed bugs in
 pkey_disable_clear()
References: <1531835365-32387-1-git-send-email-linuxram@us.ibm.com>
 <1531835365-32387-10-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <a59b8787-f9bb-2fc7-c1b4-a5fab5d53647@intel.com>
Date: Wed, 18 Jul 2018 08:43:55 -0700
MIME-Version: 1.0
In-Reply-To: <1531835365-32387-10-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, mingo@redhat.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, fweimer@redhat.com, msuchanek@suse.de, aneesh.kumar@linux.vnet.ibm.com

On 07/17/2018 06:49 AM, Ram Pai wrote:
> instead of clearing the bits, pkey_disable_clear() was setting
> the bits. Fixed it.

Again, I know these are just selftests, but I'm seeing a real lack of
attention to detail with these.  Please at least go to the trouble of
writing actual changelogs with full sentences and actual capitalization.
 I think it's the least you can do if I'm going to spend time reviewing
these.

I'll go one better.  Can you just use this as a changelog?

	pkey_disable_clear() does not work.  Instead of clearing bits,
	it sets them, probably because it originated as a copy-and-paste
	of pkey_disable_set().

	This has been dead code up to now because the only callers are
	pkey_access/write_allow() and _those_ are currently unused.

> Also fixed a wrong assertion in that function. When bits are
> cleared, the resulting bit value will be less than the original.
> 
> This hasn't been a problem so far because this code isn't currently
> used.
> 
> cc: Dave Hansen <dave.hansen@intel.com>
> cc: Florian Weimer <fweimer@redhat.com>
> Signed-off-by: Ram Pai <linuxram@us.ibm.com>
> ---
>  tools/testing/selftests/vm/protection_keys.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/tools/testing/selftests/vm/protection_keys.c b/tools/testing/selftests/vm/protection_keys.c
> index 2dd94c3..8fa4f74 100644
> --- a/tools/testing/selftests/vm/protection_keys.c
> +++ b/tools/testing/selftests/vm/protection_keys.c
> @@ -433,7 +433,7 @@ void pkey_disable_clear(int pkey, int flags)
>  			pkey, pkey, pkey_rights);
>  	pkey_assert(pkey_rights >= 0);
>  
> -	pkey_rights |= flags;
> +	pkey_rights &= ~flags;
>
>  	ret = hw_pkey_set(pkey, pkey_rights, 0);
>  	shadow_pkey_reg &= clear_pkey_flags(pkey, flags);
> @@ -446,7 +446,7 @@ void pkey_disable_clear(int pkey, int flags)
>  	dprintf1("%s(%d) pkey_reg: 0x"PKEY_REG_FMT"\n", __func__,
>  			pkey, read_pkey_reg());

If you add a better changelog:

Acked-by: Dave Hansen <dave.hansen@intel.com>

>  	if (flags)
> -		assert(read_pkey_reg() > orig_pkey_reg);
> +		assert(read_pkey_reg() <= orig_pkey_reg);
>  }

This really is an orthogonal change that would have been better placed
with the other patch that did the exact same thing.  But I'd be OK with
it here, as long as it has an actual comment.
