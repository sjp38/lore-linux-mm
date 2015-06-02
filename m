Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f171.google.com (mail-qc0-f171.google.com [209.85.216.171])
	by kanga.kvack.org (Postfix) with ESMTP id 7290F900016
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 16:26:32 -0400 (EDT)
Received: by qczw4 with SMTP id w4so40369570qcz.2
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 13:26:32 -0700 (PDT)
Received: from smtp.variantweb.net (smtp.variantweb.net. [104.131.104.118])
        by mx.google.com with ESMTPS id j19si16893598qgd.102.2015.06.02.13.26.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jun 2015 13:26:31 -0700 (PDT)
Date: Tue, 2 Jun 2015 15:26:28 -0500
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCH 0/5] zswap: make params runtime changeable
Message-ID: <20150602202628.GB14741@cerebellum.local.variantweb.net>
References: <1433257917-13090-1-git-send-email-ddstreet@ieee.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1433257917-13090-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Jun 02, 2015 at 11:11:52AM -0400, Dan Streetman wrote:
> This patch series allows setting all zswap params at runtime, instead
> of only being settable at boot-time.
> 
> The changes to zswap are rather large, due to the creation of zswap pools,
> which contain both a compressor function as well as a zpool.  When either
> the compressor or zpool param is changed at runtime, a new zswap pool is
> created with the new compressor and zpool, and used for all new compressed
> pages.  Any old zswap pools that still contain pages are retained only to
> load pages from, and destroyed once they become empty.
> 
> One notable change required for this to work is to split the currently
> global kernel param mutex into a global mutex only for built-in params,
> and a per-module mutex for loadable module params.  The reason this change
> is required is because zswap's compressor and zpool param handler callback
> functions attempt to load, via crypto_has_comp() and the new zpool_has_pool()
> functions, any required compressor or zpool modules.  The problem there is
> that the zswap param callback functions run while the global param mutex is
> locked, but when they attempt to load another module, if the loading module
> has any params set e.g. via /etc/modprobe.d/*.conf, modprobe will also try
> to take the global param mutex, and a deadlock will result, with the mutex
> held by the zswap param callback which is waiting for modprobe, but modprobe
> waiting for the mutex to change the loading module's param.  Using a
> per-module mutex for all loadable modules prevents this, since each module
> will take its own mutex and never conflict with another module's param
> changes.

Nice work Dan :)

I'm trying to look at this as three different efforts. In order of
increasing difficulty:
- Enabling/disabling zswap at runtime
- Changing the compressor at runtime, which doesn't involve the zpool layer
- Changing the allocator (type) at runtime which does involve the zpool layer.

In other words, we can store entries that use a different compressor in
the same zpool, but not entries stored in different allocators.

Enabling zswap at runtime is very straightforward, especially if you
aren't going to attempt to flush out all the pages on a disable; only
prevent new stores.  I like that.

Changing the compressor at runtime is the next easiest one, since you
have to allocate new compressor transforms, but not a new zpool.  You
just store which compressor was used on a per-entry basis.

Changing the allocator (type) is the hardest since it involves a new
zpool, and all the code for managing multiple zpools in zswap.

This is a lot of change all at once.  Maybe we could just do the runtime
enable/disable of zswap and the runtime change of compressors first?  I
think those two alone would be a lot less invasive.  Then we can look at
runtime change of the allocator as a separate thing.

Thanks,
Seth

> 
> 
> Dan Streetman (5):
>   zpool: add zpool_has_pool()
>   module: add per-module params lock
>   zswap: runtime enable/disable
>   zswap: dynamic pool creation
>   zswap: change zpool/compressor at runtime
> 
>  arch/um/drivers/hostaudio_kern.c                 |  20 +-
>  drivers/net/ethernet/myricom/myri10ge/myri10ge.c |   6 +-
>  drivers/net/wireless/libertas_tf/if_usb.c        |   6 +-
>  drivers/usb/atm/ueagle-atm.c                     |   4 +-
>  drivers/video/fbdev/vt8623fb.c                   |   4 +-
>  include/linux/module.h                           |   1 +
>  include/linux/moduleparam.h                      |  67 +--
>  include/linux/zpool.h                            |   2 +
>  kernel/module.c                                  |   1 +
>  kernel/params.c                                  |  45 +-
>  mm/zpool.c                                       |  25 +
>  mm/zswap.c                                       | 696 +++++++++++++++++------
>  net/mac80211/rate.c                              |   4 +-
>  13 files changed, 640 insertions(+), 241 deletions(-)
> 
> -- 
> 2.1.0
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
