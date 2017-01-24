Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2C8686B026C
	for <linux-mm@kvack.org>; Tue, 24 Jan 2017 16:24:43 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 204so252985651pfx.1
        for <linux-mm@kvack.org>; Tue, 24 Jan 2017 13:24:43 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 82si20713048pge.77.2017.01.24.13.24.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jan 2017 13:24:42 -0800 (PST)
Date: Tue, 24 Jan 2017 13:24:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] zswap: disable changing params if init fails
Message-Id: <20170124132441.5027560693ed6d8c283c1953@linux-foundation.org>
In-Reply-To: <20170124200259.16191-2-ddstreet@ieee.org>
References: <20170124200259.16191-1-ddstreet@ieee.org>
	<20170124200259.16191-2-ddstreet@ieee.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Linux-MM <linux-mm@kvack.org>, Seth Jennings <sjenning@redhat.com>, Michal Hocko <mhocko@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Dan Streetman <dan.streetman@canonical.com>

On Tue, 24 Jan 2017 15:02:57 -0500 Dan Streetman <ddstreet@ieee.org> wrote:

> Add zswap_init_failed bool that prevents changing any of the module
> params, if init_zswap() fails, and set zswap_enabled to false.  Change
> 'enabled' param to a callback, and check zswap_init_failed before
> allowing any change to 'enabled', 'zpool', or 'compressor' params.
> 
> Any driver that is built-in to the kernel will not be unloaded if its
> init function returns error, and its module params remain accessible for
> users to change via sysfs.  Since zswap uses param callbacks, which
> assume that zswap has been initialized, changing the zswap params after
> a failed initialization will result in WARNING due to the param callbacks
> expecting a pool to already exist.  This prevents that by immediately
> exiting any of the param callbacks if initialization failed.
> 
> This was reported here:
> https://marc.info/?l=linux-mm&m=147004228125528&w=4

I added Marcin's reportde-by to the changelog.

> And fixes this WARNING:
> [  429.723476] WARNING: CPU: 0 PID: 5140 at mm/zswap.c:503
> __zswap_pool_current+0x56/0x60
> 
> Fixes: 90b0fc26d5db ("zswap: change zpool/compressor at runtime")
> Cc: stable@vger.kernel.org

Is this really serious enough to justify a -stable backport?  It's just
a bit of extra noise associated with an initialization problem which
the user will be fixing anyway.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
