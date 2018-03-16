Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 786E56B000C
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 18:05:29 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id v25so5286090pgn.20
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 15:05:29 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id w17-v6si6879207plp.561.2018.03.16.15.05.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Mar 2018 15:05:28 -0700 (PDT)
Subject: Re: [PATCH v12 05/22] selftests/vm: generic function to handle shadow
 key register
References: <1519264541-7621-1-git-send-email-linuxram@us.ibm.com>
 <1519264541-7621-6-git-send-email-linuxram@us.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <92951c0a-0468-6d3c-efef-2d9da53fd10f@intel.com>
Date: Fri, 16 Mar 2018 15:05:19 -0700
MIME-Version: 1.0
In-Reply-To: <1519264541-7621-6-git-send-email-linuxram@us.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ram Pai <linuxram@us.ibm.com>, shuahkh@osg.samsung.com, linux-kselftest@vger.kernel.org
Cc: mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, x86@kernel.org, linux-arch@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@redhat.com, akpm@linux-foundation.org, benh@kernel.crashing.org, paulus@samba.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, hbabu@us.ibm.com, mhocko@kernel.org, bauerman@linux.vnet.ibm.com, ebiederm@xmission.com, arnd@arndb.de

On 02/21/2018 05:55 PM, Ram Pai wrote:
> +static inline u32 pkey_to_shift(int pkey)
> +{
> +	return pkey * PKEY_BITS_PER_PKEY;
> +}

pkey_bit_position(), perhaps?

> +static inline pkey_reg_t reset_bits(int pkey, pkey_reg_t bits)
> +{
> +	u32 shift = pkey_to_shift(pkey);
> +
> +	return ~(bits << shift);
> +}

I'd prefer clear_pkey_flags() or maybe clear_pkey_bits().  "reset" can
mean "reset to 0" or "reset to 1".

Also, why the u32 here?  Isn't an int more appropriate?

> +static inline pkey_reg_t left_shift_bits(int pkey, pkey_reg_t bits)
> +{
> +	u32 shift = pkey_to_shift(pkey);
> +
> +	return (bits << shift);
> +}
> +
> +static inline pkey_reg_t right_shift_bits(int pkey, pkey_reg_t bits)
> +{
> +	u32 shift = pkey_to_shift(pkey);
> +
> +	return (bits >> shift);
> +}

Some comments on these would be handy.  Basically that this takes a
per-key flags value and puts it at the right position so it can be
shoved in the register.
