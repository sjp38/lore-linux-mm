Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 186B16B0003
	for <linux-mm@kvack.org>; Tue, 22 May 2018 16:22:51 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id m2-v6so14436715uab.9
        for <linux-mm@kvack.org>; Tue, 22 May 2018 13:22:51 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id k5-v6si6648038uae.216.2018.05.22.13.22.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 May 2018 13:22:49 -0700 (PDT)
Date: Tue, 22 May 2018 16:22:42 -0400
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: Re: [PATCH V6 2/2 RESEND] ksm: replace jhash2 with faster hash
Message-ID: <20180522202242.otvdunkl75yfhkt4@xakep.localdomain>
References: <20180418193220.4603-1-timofey.titovets@synesis.ru>
 <20180418193220.4603-3-timofey.titovets@synesis.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180418193220.4603-3-timofey.titovets@synesis.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timofey Titovets <nefelim4ag@gmail.com>
Cc: linux-mm@kvack.org, leesioh <solee@os.korea.ac.kr>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org

Hi Timofey,

> 
> Perf numbers:
> Intel(R) Xeon(R) CPU E5-2420 v2 @ 2.20GHz
> ksm: crc32c   hash() 12081 MB/s
> ksm: xxh64    hash()  8770 MB/s
> ksm: xxh32    hash()  4529 MB/s
> ksm: jhash2   hash()  1569 MB/s

That is a very nice improvement over jhash2!

> Add function to autoselect hash algo on boot,
> based on hashing speed, like raid6 code does.

Are you aware of hardware where crc32c is slower compared to xxhash?
Perhaps always use crc32c when available?

> +
> +static u32 fasthash(const void *input, size_t length)
> +{
> +again:
> +	switch (fastest_hash) {
> +	case HASH_CRC32C:
> +		return crc32c(0, input, length);
> +	case HASH_XXHASH:
> +		return xxhash(input, length, 0);

You are loosing half of 64-bit word in xxh64 case? Is this acceptable? May
be do one more xor: in 64-bit case in xxhash() do: (v >> 32) | (u32)v ?

> +	default:
> +		choice_fastest_hash();
> +		/* The correct value depends on page size and endianness */
> +		zero_checksum = fasthash(ZERO_PAGE(0), PAGE_SIZE);
> +		goto again;
> +	}
> +}

choice_fastest_hash() does not belong to fasthash(). We are loosing leaf
function optimizations if you keep it in this hot-path. Also, fastest_hash
should really be a static branch in order to avoid extra load and conditional
branch.

I think, crc32c should simply be used when it is available, and use xxhash
otherwise, the decision should be made in ksm_init()

Thank you,
Pavel
