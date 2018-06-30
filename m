Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id D45F56B0008
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 21:37:56 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id ba8-v6so3733341plb.4
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 18:37:56 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 67-v6si9134200pgi.456.2018.06.29.18.37.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 18:37:55 -0700 (PDT)
Date: Fri, 29 Jun 2018 18:37:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/fadvise: Fix signed overflow UBSAN complaint
Message-Id: <20180629183754.b5accab9f7f6593a39d6f0be@linux-foundation.org>
In-Reply-To: <20180629184453.7614-1-aryabinin@virtuozzo.com>
References: <20180627204808.99988d94180dd144b14aa38b@linux-foundation.org>
	<20180629184453.7614-1-aryabinin@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: icytxw@gmail.com, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 29 Jun 2018 21:44:53 +0300 Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:

> Signed integer overflow is undefined according to the C standard.
> The overflow in ksys_fadvise64_64() is deliberate, but since it is signed
> overflow, UBSAN complains:
> 	UBSAN: Undefined behaviour in mm/fadvise.c:76:10
> 	signed integer overflow:
> 	4 + 9223372036854775805 cannot be represented in type 'long long int'
> 
> Use unsigned types to do math. Unsigned overflow is defined so UBSAN
> will not complain about it. This patch doesn't change generated code.
> 
> ...
>
> --- a/mm/fadvise.c
> +++ b/mm/fadvise.c
> @@ -73,7 +73,7 @@ int ksys_fadvise64_64(int fd, loff_t offset, loff_t len, int advice)
>  	}
>  
>  	/* Careful about overflows. Len == 0 means "as much as possible" */
> -	endbyte = offset + len;
> +	endbyte = (u64)offset + (u64)len;
>  	if (!len || endbyte < len)
>  		endbyte = -1;
>  	else

Readers of this code will wonder "what the heck are those casts for". 
Therefore:

--- a/mm/fadvise.c~mm-fadvise-fix-signed-overflow-ubsan-complaint-fix
+++ a/mm/fadvise.c
@@ -72,7 +72,11 @@ int ksys_fadvise64_64(int fd, loff_t off
 		goto out;
 	}
 
-	/* Careful about overflows. Len == 0 means "as much as possible" */
+	/*
+	 * Careful about overflows. Len == 0 means "as much as possible".  Use
+	 * unsigned math because signed overflows are undefined and UBSan
+	 * complains.
+	 */
 	endbyte = (u64)offset + (u64)len;
 	if (!len || endbyte < len)
 		endbyte = -1;
_
