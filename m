Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id E906F6B0255
	for <linux-mm@kvack.org>; Tue, 18 Aug 2015 18:38:19 -0400 (EDT)
Received: by igui7 with SMTP id i7so91518287igu.0
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 15:38:19 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 98si13210512ioi.193.2015.08.18.15.38.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Aug 2015 15:38:19 -0700 (PDT)
Date: Tue, 18 Aug 2015 15:38:18 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] zpool: define and use max type length
Message-Id: <20150818153818.cab58a99f60113c2aca2f006@linux-foundation.org>
In-Reply-To: <1439928361-31294-1-git-send-email-ddstreet@ieee.org>
References: <1439928361-31294-1-git-send-email-ddstreet@ieee.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Seth Jennings <sjennings@variantweb.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, kbuild test robot <fengguang.wu@intel.com>

On Tue, 18 Aug 2015 16:06:00 -0400 Dan Streetman <ddstreet@ieee.org> wrote:

> Add ZPOOL_MAX_TYPE_NAME define, and change zpool_driver *type field to
> type[ZPOOL_MAX_TYPE_NAME].  Remove redundant type field from struct zpool
> and use zpool->driver->type instead.
> 
> The define will be used by zswap for its zpool param type name length.
> 

Patchset is fugly.  All this putzing around with fixed-length strings,
worrying about overflow and is-it-null-terminated-or-isnt-it.  Shudder.

It's much better to use variable-length strings everywhere.  We're not
operating in contexts which can't use kmalloc, we're not
performance-intensive and these strings aren't being written to
fixed-size fields on disk or anything.  Why do we need any fixed-length
strings?

IOW, why not just replace that alloca with a kstrdup()?

> --- a/include/linux/zpool.h
> +++ b/include/linux/zpool.h
>
> ...
>
> @@ -79,7 +77,7 @@ static struct zpool_driver *zpool_get_driver(char *type)
>  
>  	spin_lock(&drivers_lock);
>  	list_for_each_entry(driver, &drivers_head, list) {
> -		if (!strcmp(driver->type, type)) {
> +		if (!strncmp(driver->type, type, ZPOOL_MAX_TYPE_NAME)) {

Why strncmp?  Please tell me these strings are always null-terminated.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
