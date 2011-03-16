Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2681A8D0039
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 13:17:37 -0400 (EDT)
Received: from wpaz5.hot.corp.google.com (wpaz5.hot.corp.google.com [172.24.198.69])
	by smtp-out.google.com with ESMTP id p2GHHZvq013587
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 10:17:35 -0700
Received: from iyf13 (iyf13.prod.google.com [10.241.50.77])
	by wpaz5.hot.corp.google.com with ESMTP id p2GHG3mW019877
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 16 Mar 2011 10:17:34 -0700
Received: by iyf13 with SMTP id 13so2380518iyf.0
        for <linux-mm@kvack.org>; Wed, 16 Mar 2011 10:17:33 -0700 (PDT)
Date: Wed, 16 Mar 2011 10:17:19 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/8] drivers/random: Cache align ip_random better
In-Reply-To: <20110316022804.27679.qmail@science.horizon.com>
Message-ID: <alpine.LSU.2.00.1103161011370.13407@sister.anvils>
References: <20110316022804.27679.qmail@science.horizon.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: George Spelvin <linux@horizon.com>
Cc: penberg@cs.helsinki.fi, herbert@gondor.hengli.com.au, mpm@selenic.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 13 Mar 2011, George Spelvin wrote:

> Cache aligning the secret[] buffer makes copying from it infinitesimally
> more efficient.
> ---
>  drivers/char/random.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/char/random.c b/drivers/char/random.c
> index 72a4fcb..4bcc4f2 100644
> --- a/drivers/char/random.c
> +++ b/drivers/char/random.c
> @@ -1417,8 +1417,8 @@ static __u32 twothirdsMD4Transform(__u32 const buf[4], __u32 const in[12])
>  #define HASH_MASK ((1 << HASH_BITS) - 1)
>  
>  static struct keydata {
> -	__u32 count; /* already shifted to the final position */
>  	__u32 secret[12];
> +	__u32 count; /* already shifted to the final position */
>  } ____cacheline_aligned ip_keydata[2];
>  
>  static unsigned int ip_cnt;

I'm intrigued: please educate me.  On what architectures does cache-
aligning a 48-byte buffer (previously offset by 4 bytes) speed up
copying from it, and why?  Does the copying involve 8-byte or 16-byte
instructions that benefit from that alignment, rather than cacheline
alignment?
 
Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
