Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 15FE26B0632
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 13:31:47 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id c84so40379729qkb.13
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 10:31:47 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m1-v6sor5532588qtp.34.2018.11.08.10.31.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 08 Nov 2018 10:31:46 -0800 (PST)
Date: Thu, 8 Nov 2018 13:31:43 -0500
From: Pavel Tatashin <pasha.tatashin@gmail.com>
Subject: Re: [PATCH RESEND V8 1/2] xxHash: create arch dependent 32/64-bit
 xxhash()
Message-ID: <20181108183143.jtgzcapauqrynqxz@xakep.localdomain>
References: <20181023182554.23464-1-nefelim4ag@gmail.com>
 <20181023182554.23464-2-nefelim4ag@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181023182554.23464-2-nefelim4ag@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>
Cc: Timofey Titovets <nefelim4ag@gmail.com>, linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org, leesioh <solee@os.korea.ac.kr>

Hi Andrew,

Can you please accept these patches? They are simple yet provide a good
performance improvement. Timofey has been resending them for a while.

Thank you,
Pasha

On 18-10-23 21:25:53, Timofey Titovets wrote:
> xxh32() - fast on both 32/64-bit platforms
> xxh64() - fast only on 64-bit platform
> 
> Create xxhash() which will pickup fastest version
> on compile time.
> 
> As result depends on cpu word size,
> the main proporse of that - in memory hashing.
> 
> Changes:
>   v2:
>     - Create that patch
>   v3 -> v8:
>     - Nothing, whole patchset version bump
> 
> Signed-off-by: Timofey Titovets <nefelim4ag@gmail.com>
> Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
> Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> 
> CC: Andrea Arcangeli <aarcange@redhat.com>
> CC: linux-mm@kvack.org
> CC: kvm@vger.kernel.org
> CC: leesioh <solee@os.korea.ac.kr>
> ---
>  include/linux/xxhash.h | 23 +++++++++++++++++++++++
>  1 file changed, 23 insertions(+)
> 
> diff --git a/include/linux/xxhash.h b/include/linux/xxhash.h
> index 9e1f42cb57e9..52b073fea17f 100644
> --- a/include/linux/xxhash.h
> +++ b/include/linux/xxhash.h
> @@ -107,6 +107,29 @@ uint32_t xxh32(const void *input, size_t length, uint32_t seed);
>   */
>  uint64_t xxh64(const void *input, size_t length, uint64_t seed);
>  
> +/**
> + * xxhash() - calculate wordsize hash of the input with a given seed
> + * @input:  The data to hash.
> + * @length: The length of the data to hash.
> + * @seed:   The seed can be used to alter the result predictably.
> + *
> + * If the hash does not need to be comparable between machines with
> + * different word sizes, this function will call whichever of xxh32()
> + * or xxh64() is faster.
> + *
> + * Return:  wordsize hash of the data.
> + */
> +
> +static inline unsigned long xxhash(const void *input, size_t length,
> +				   uint64_t seed)
> +{
> +#if BITS_PER_LONG == 64
> +       return xxh64(input, length, seed);
> +#else
> +       return xxh32(input, length, seed);
> +#endif
> +}
> +
>  /*-****************************
>   * Streaming Hash Functions
>   *****************************/
> -- 
> 2.19.0
> 
