Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id DDE8F6B0253
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 19:24:13 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 80so255327029pfy.2
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 16:24:13 -0800 (PST)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id r82si21329793pfd.93.2017.01.24.16.24.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 16:24:12 -0800 (PST)
Received: by mail-pf0-x244.google.com with SMTP id 19so12968404pfo.3
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 16:24:12 -0800 (PST)
Date: Wed, 25 Jan 2017 09:24:26 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH 2/3] zswap: allow initialization at boot without pool
Message-ID: <20170125002426.GA2234@jagdpanzerIV.localdomain>
References: <20170124200259.16191-1-ddstreet@ieee.org>
 <20170124200259.16191-3-ddstreet@ieee.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170124200259.16191-3-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@redhat.com>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, Dan Streetman <dan.streetman@canonical.com>


just a note,

On (01/24/17 15:02), Dan Streetman wrote:
[..]
> @@ -692,6 +702,15 @@ static int __zswap_param_set(const char *val, const struct kernel_param *kp,
>  		 */
>  		list_add_tail_rcu(&pool->list, &zswap_pools);
>  		put_pool = pool;
> +	} else if (!zswap_has_pool) {
> +		/* if initial pool creation failed, and this pool creation also
> +		 * failed, maybe both compressor and zpool params were bad.
> +		 * Allow changing this param, so pool creation will succeed
> +		 * when the other param is changed. We already verified this
> +		 * param is ok in the zpool_has_pool() or crypto_has_comp()
> +		 * checks above.
> +		 */
> +		ret = param_set_charp(s, kp);
>  	}
>  
>  	spin_unlock(&zswap_pools_lock);

looks like there still GFP_KERNEL allocation from atomic section:
param_set_charp()->kmalloc_parameter()->kmalloc(GFP_KERNEL), under
`zswap_pools_lock'.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
