Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 926586B7522
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 17:08:21 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d1-v6so4594223pfo.16
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 14:08:21 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s12-v6si2830355pgi.514.2018.09.05.14.08.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 14:08:20 -0700 (PDT)
Date: Wed, 5 Sep 2018 14:08:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3 3/3] mm: don't miss the last page because of
 round-off error
Message-Id: <20180905140818.c2120d25eba0baef90a84ed2@linux-foundation.org>
In-Reply-To: <20180829213311.GA13501@castle>
References: <20180827162621.30187-1-guro@fb.com>
	<20180827162621.30187-3-guro@fb.com>
	<20180827140432.b3c792f60235a13739038808@linux-foundation.org>
	<20180829213311.GA13501@castle>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Shakeel Butt <shakeelb@google.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Rik van Riel <riel@surriel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Matthew Wilcox <willy@infradead.org>

On Wed, 29 Aug 2018 14:33:19 -0700 Roman Gushchin <guro@fb.com> wrote:

> >From d8237d3df222e6c5a98a74baa04bc52edf8a3677 Mon Sep 17 00:00:00 2001
> From: Roman Gushchin <guro@fb.com>
> Date: Wed, 29 Aug 2018 14:14:48 -0700
> Subject: [PATCH] math64: prevent double calculation of DIV64_U64_ROUND_UP()
>  arguments
> 
> Cause the DIV64_U64_ROUND_UP(ll, d) macro to cache
> the result of (d) expression in a local variable to
> avoid double calculation, which might bring unexpected
> side effects.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> ---
>  include/linux/math64.h | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/math64.h b/include/linux/math64.h
> index 94af3d9c73e7..bb2c84afb80c 100644
> --- a/include/linux/math64.h
> +++ b/include/linux/math64.h
> @@ -281,6 +281,7 @@ static inline u64 mul_u64_u32_div(u64 a, u32 mul, u32 divisor)
>  }
>  #endif /* mul_u64_u32_div */
>  
> -#define DIV64_U64_ROUND_UP(ll, d)	div64_u64((ll) + (d) - 1, (d))
> +#define DIV64_U64_ROUND_UP(ll, d)	\
> +	({ u64 _tmp = (d); div64_u64((ll) + _tmp - 1, _tmp); })
>  
>  #endif /* _LINUX_MATH64_H */

Does it have to be done as a macro?  A lot of these things are
implemented as nice inline C functions.

Also, most of these functions and macros return a value whereas
DIV64_U64_ROUND_UP() does not.  Desirable?

(And we're quite pathetic about documenting what those return values
_are_, which gets frustrating for the poor schmucks who sit here
reviewing code all day).
