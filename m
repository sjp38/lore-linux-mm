Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id EAC569003C7
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 16:08:39 -0400 (EDT)
Received: by ykoo205 with SMTP id o205so45168829yko.0
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 13:08:39 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a12si2355059ykc.172.2015.08.05.13.08.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Aug 2015 13:08:39 -0700 (PDT)
Date: Wed, 5 Aug 2015 13:08:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] zpool: add zpool_has_pool()
Message-Id: <20150805130836.16c42cd0a9fe6f4050cf0620@linux-foundation.org>
In-Reply-To: <1438782403-29496-2-git-send-email-ddstreet@ieee.org>
References: <1438782403-29496-1-git-send-email-ddstreet@ieee.org>
	<1438782403-29496-2-git-send-email-ddstreet@ieee.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Seth Jennings <sjennings@variantweb.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed,  5 Aug 2015 09:46:41 -0400 Dan Streetman <ddstreet@ieee.org> wrote:

> Add zpool_has_pool() function, indicating if the specified type of zpool
> is available (i.e. zsmalloc or zbud).  This allows checking if a pool is
> available, without actually trying to allocate it, similar to
> crypto_has_alg().
> 
> This is used by a following patch to zswap that enables the dynamic
> runtime creation of zswap zpools.
> 
> ...
>
>  /**
> + * zpool_has_pool() - Check if the pool driver is available
> + * @type	The type of the zpool to check (e.g. zbud, zsmalloc)
> + *
> + * This checks if the @type pool driver is available.
> + *
> + * Returns: true if @type pool is available, false if not
> + */
> +bool zpool_has_pool(char *type)
> +{
> +	struct zpool_driver *driver = zpool_get_driver(type);
> +
> +	if (!driver) {
> +		request_module("zpool-%s", type);
> +		driver = zpool_get_driver(type);
> +	}
> +
> +	if (!driver)
> +		return false;
> +
> +	zpool_put_driver(driver);
> +	return true;
> +}

This looks racy: after that zpool_put_driver() has completed, an rmmod
will invalidate zpool_has_pool()'s return value.

If there's some reason why this can't happen, can we please have a code
comment which reveals that reason?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
