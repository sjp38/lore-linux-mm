Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 465FD6B000C
	for <linux-mm@kvack.org>; Wed, 14 Mar 2018 10:19:26 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 1-v6so1515668plv.6
        for <linux-mm@kvack.org>; Wed, 14 Mar 2018 07:19:26 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id g23si2199448pfb.87.2018.03.14.07.19.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Mar 2018 07:19:25 -0700 (PDT)
Subject: Re: [PATCH 1/1 v2] x86: pkey-mprotect must allow pkey-0
References: <1521013574-27041-1-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <18b155e3-07e9-5a4b-1f95-e1667078438c@intel.com>
Date: Wed, 14 Mar 2018 07:19:23 -0700
MIME-Version: 1.0
In-Reply-To: <1521013574-27041-1-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, mingo@redhat.com
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, corbet@lwn.net, arnd@arndb.de, fweimer@redhat.com, msuchanek@suse.com

On 03/14/2018 12:46 AM, Ram Pai wrote:
> Once an address range is associated with an allocated pkey, it cannot be
> reverted back to key-0. There is no valid reason for the above behavior.  On
> the contrary applications need the ability to do so.

I'm trying to remember why we cared in the first place. :)

Could you add that to the changelog, please?

> @@ -92,7 +92,8 @@ int mm_pkey_alloc(struct mm_struct *mm)
>  static inline
>  int mm_pkey_free(struct mm_struct *mm, int pkey)
>  {
> -	if (!mm_pkey_is_allocated(mm, pkey))
> +	/* pkey 0 is special and can never be freed */
> +	if (!pkey || !mm_pkey_is_allocated(mm, pkey))
>  		return -EINVAL;

If an app was being really careful, couldn't it free up all of the
implicitly-pkey-0-assigned memory so that it is not in use at all?  In
that case, we might want to allow this.

On the other hand, nobody is likely to _ever_ actually do this so this
is good shoot-yourself-in-the-foot protection.
