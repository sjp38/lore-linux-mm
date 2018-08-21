Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 87BDB6B1EA9
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 08:24:33 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id b12-v6so11651699plr.17
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 05:24:33 -0700 (PDT)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id u1-v6si13858175plk.97.2018.08.21.05.24.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 05:24:32 -0700 (PDT)
Date: Tue, 21 Aug 2018 15:24:27 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH] mm/gup_benchmark: fix unsigned comparison with less than
 zero
Message-ID: <20180821122427.26thwexm2c7ihubc@black.fi.intel.com>
References: <20180821113634.3782-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180821113634.3782-1-colin.king@canonical.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin King <colin.king@canonical.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Michael S . Tsirkin" <mst@redhat.com>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Aug 21, 2018 at 11:36:34AM +0000, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> Currently the return from get_user_pages_fast is being checked
> to be less than zero for an error check, however, the variable being
> checked is unsigned so the check is always false. Fix this by using
> a signed long instead.
> 
> Detected by Coccinelle ("Unsigned expression compared with zero: nr <= 0")
> 
> Fixes: 64c349f4ae78 ("mm: add infrastructure for get_user_pages_fast() benchmarking")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

This is good catch, but the fix is wrong. See below.

> ---
>  mm/gup_benchmark.c | 8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/gup_benchmark.c b/mm/gup_benchmark.c
> index 6a473709e9b6..a9a15e7a1185 100644
> --- a/mm/gup_benchmark.c
> +++ b/mm/gup_benchmark.c
> @@ -31,6 +31,8 @@ static int __gup_benchmark_ioctl(unsigned int cmd,
>  	nr = gup->nr_pages_per_call;
>  	start_time = ktime_get();
>  	for (addr = gup->addr; addr < gup->addr + gup->size; addr = next) {
> +		long n;
> +
>  		if (nr != gup->nr_pages_per_call)
>  			break;

This check has to be done against 'n', not nr'. We stop as soon as
get_user_pages_fast() doesn't return the number of pages we expected.

I would rather change type of 'nr' to signed. It should also fix the
issue, right?

-- 
 Kirill A. Shutemov
