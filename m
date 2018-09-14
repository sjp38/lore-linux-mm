Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 056D88E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 04:42:10 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id b8-v6so8896187oib.4
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 01:42:10 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p18-v6si1352463otb.142.2018.09.14.01.42.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 01:42:08 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8E8cVvh072977
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 04:42:07 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mg8nvapgy-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 04:42:07 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 14 Sep 2018 09:42:05 +0100
Date: Fri, 14 Sep 2018 11:41:58 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH V8 1/2] xxHash: create arch dependent 32/64-bit xxhash()
References: <20180913214102.28269-1-timofey.titovets@synesis.ru>
 <20180913214102.28269-2-timofey.titovets@synesis.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180913214102.28269-2-timofey.titovets@synesis.ru>
Message-Id: <20180914084157.GE15191@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timofey Titovets <timofey.titovets@synesis.ru>
Cc: linux-mm@kvack.org, Timofey Titovets <nefelim4ag@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, kvm@vger.kernel.org, leesioh <solee@os.korea.ac.kr>

On Fri, Sep 14, 2018 at 12:41:01AM +0300, Timofey Titovets wrote:
> From: Timofey Titovets <nefelim4ag@gmail.com>
> 
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

Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
 
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

-- 
Sincerely yours,
Mike.
