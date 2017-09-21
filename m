Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 425676B0069
	for <linux-mm@kvack.org>; Thu, 21 Sep 2017 11:36:59 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id d8so12265737pgt.1
        for <linux-mm@kvack.org>; Thu, 21 Sep 2017 08:36:59 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id h5si1166895pfe.224.2017.09.21.08.36.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Sep 2017 08:36:58 -0700 (PDT)
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: [PATCH] KSM: Replace jhash2 with xxhash
References: <20170921074519.9333-1-nefelim4ag@gmail.com>
Date: Thu, 21 Sep 2017 08:36:57 -0700
In-Reply-To: <20170921074519.9333-1-nefelim4ag@gmail.com> (Timofey Titovets's
	message of "Thu, 21 Sep 2017 10:45:19 +0300")
Message-ID: <8760ccdpwm.fsf@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timofey Titovets <nefelim4ag@gmail.com>
Cc: linux-mm@kvack.org

Timofey Titovets <nefelim4ag@gmail.com> writes:

> xxhash much faster then jhash,
> ex. for x86_64 host:
> PAGE_SIZE: 4096, loop count: 1048576
> jhash2:   0xacbc7a5b            time: 1907 ms,  th:  2251.9 MiB/s
> xxhash32: 0x570da981            time: 739 ms,   th:  5809.4 MiB/s
> xxhash64: 0xa1fa032ab85bbb62    time: 371 ms,   th: 11556.6 MiB/s
>
> xxhash64 on x86_32 work with ~ same speed as jhash2.
> xxhash32 on x86_32 work with ~ same speed as for x86_64

Which CPU is that?

>
> So replace jhash with xxhash,
> and use fastest version for current target ARCH.

Can you do some macro-benchmarking too? Something that uses
KSM and show how the performance changes.

You could manually increase the scan rate to make it easier
to see.

> @@ -51,6 +52,12 @@
>  #define DO_NUMA(x)	do { } while (0)
>  #endif
>  
> +#if BITS_PER_LONG == 64
> +typedef	u64	xxhash;
> +#else
> +typedef	u32	xxhash;
> +#endif

This should be in xxhash.h ? 

xxhash_t would seem to be a better name.

> -	u32 checksum;
> +	xxhash checksum;
>  	void *addr = kmap_atomic(page);
> -	checksum = jhash2(addr, PAGE_SIZE / 4, 17);
> +#if BITS_PER_LONG == 64
> +	checksum = xxh64(addr, PAGE_SIZE, 0);
> +#else
> +	checksum = xxh32(addr, PAGE_SIZE, 0);
> +#endif

This should also be generic in xxhash.h



-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
