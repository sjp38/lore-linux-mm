Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7B4106B29C2
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 07:13:57 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id w44-v6so2153206edb.16
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 04:13:57 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s26-v6si3248905edq.393.2018.08.23.04.13.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 04:13:56 -0700 (PDT)
Date: Thu, 23 Aug 2018 13:13:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] fs: fix local var type
Message-ID: <20180823111355.GD29735@dhcp22.suse.cz>
References: <1535014754-31918-1-git-send-email-swkhack@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1535014754-31918-1-git-send-email-swkhack@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weikang Shi <swkhack@gmail.com>
Cc: akpm@linux-foundation.org, alexander.h.duyck@intel.com, vbabka@suse.cz, mgorman@suse.de, l.stach@pengutronix.de, vdavydov.dev@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, my_email@gmail.com

On Thu 23-08-18 01:59:14, Weikang Shi wrote:
> In the seq_hex_dump function,the remaining variable is int, but it receive a type of size_t argument.
> So I change the type of remaining

The changelog should explain _why_ we need this fix. Is any of the code
path overflowing?

Besides that I do not think this fix is complete. What about linelen?

Why do we even need len to be size_t? Why it cannot be int as well. I
strongly doubt we need more than 32b here.
 
> Signed-off-by: Weikang Shi <swkhack@gmail.com>
> ---
>  fs/seq_file.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/fs/seq_file.c b/fs/seq_file.c
> index 1dea7a8..d0e8bec 100644
> --- a/fs/seq_file.c
> +++ b/fs/seq_file.c
> @@ -847,7 +847,8 @@ void seq_hex_dump(struct seq_file *m, const char *prefix_str, int prefix_type,
>  		  bool ascii)
>  {
>  	const u8 *ptr = buf;
> -	int i, linelen, remaining = len;
> +	int i, linelen;
> +	size_t remaining = len;
>  	char *buffer;
>  	size_t size;
>  	int ret;
> -- 
> 2.7.4
> 

-- 
Michal Hocko
SUSE Labs
