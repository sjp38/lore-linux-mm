Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3C5266B743F
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 07:13:13 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id w2so9892905edc.13
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 04:13:13 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r18-v6si7755867ejh.206.2018.12.05.04.13.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 04:13:11 -0800 (PST)
Date: Wed, 5 Dec 2018 13:13:10 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] core-api/memory-hotplug.rst: divide Locking Internal
 section by different locks
Message-ID: <20181205121310.GK1286@dhcp22.suse.cz>
References: <20181205023426.24029-1-richard.weiyang@gmail.com>
 <20181205023426.24029-2-richard.weiyang@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181205023426.24029-2-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: david@redhat.com, osalvador@suse.de, akpm@linux-foundation.org, linux-doc@vger.kernel.org, linux-mm@kvack.org

On Wed 05-12-18 10:34:26, Wei Yang wrote:
> Currently locking for memory hotplug is a little complicated.
> 
> Generally speaking, we leverage the two global lock:
> 
>   * device_hotplug_lock
>   * mem_hotplug_lock
> 
> to serialise the process.
> 
> While for the long term, we are willing to have more fine-grained lock
> to provide higher scalability.
> 
> This patch divides Locking Internal section based on these two global
> locks to help readers to understand it. Also it adds some new finding to
> enrich it.
> 
> [David: words arrangement]
> 
> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>

For a love of mine I cannot find the locking description by Oscar. Maybe
it never existed and I just made it up ;) But if it is not imaginary
then my recollection is that it was much more comprehensive. If not then
even this is a good start.

> ---
>  Documentation/core-api/memory-hotplug.rst | 27 ++++++++++++++++++++++++---
>  1 file changed, 24 insertions(+), 3 deletions(-)
> 
> diff --git a/Documentation/core-api/memory-hotplug.rst b/Documentation/core-api/memory-hotplug.rst
> index de7467e48067..95662b283328 100644
> --- a/Documentation/core-api/memory-hotplug.rst
> +++ b/Documentation/core-api/memory-hotplug.rst
> @@ -89,6 +89,20 @@ NOTIFY_STOP stops further processing of the notification queue.
>  Locking Internals
>  =================
>  
> +There are three locks involved in memory-hotplug, two global lock and one local
> +lock:
> +
> +- device_hotplug_lock
> +- mem_hotplug_lock
> +- device_lock
> +
> +Currently, they are twisted together for all kinds of reasons. The following
> +part is divided into device_hotplug_lock and mem_hotplug_lock parts
> +respectively to describe those tricky situations.
> +
> +device_hotplug_lock
> +---------------------
> +
>  When adding/removing memory that uses memory block devices (i.e. ordinary RAM),
>  the device_hotplug_lock should be held to:
>  
> @@ -111,13 +125,20 @@ As the device is visible to user space before taking the device_lock(), this
>  can result in a lock inversion.
>  
>  onlining/offlining of memory should be done via device_online()/
> -device_offline() - to make sure it is properly synchronized to actions
> -via sysfs. Holding device_hotplug_lock is advised (to e.g. protect online_type)
> +device_offline() - to make sure it is properly synchronized to actions via
> +sysfs. Even mem_hotplug_lock is used to protect the process, because of the
> +lock inversion described above, holding device_hotplug_lock is still advised
> +(to e.g. protect online_type)
> +
> +mem_hotplug_lock
> +---------------------
>  
>  When adding/removing/onlining/offlining memory or adding/removing
>  heterogeneous/device memory, we should always hold the mem_hotplug_lock in
>  write mode to serialise memory hotplug (e.g. access to global/zone
> -variables).
> +variables). Currently, we take advantage of this to serialise sparsemem's
> +mem_section handling in sparse_add_one_section() and
> +sparse_remove_one_section().
>  
>  In addition, mem_hotplug_lock (in contrast to device_hotplug_lock) in read
>  mode allows for a quite efficient get_online_mems/put_online_mems
> -- 
> 2.15.1
> 

-- 
Michal Hocko
SUSE Labs
