Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id B4F6F6B78F6
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 03:22:37 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id s70so22597100qks.4
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 00:22:37 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w123si5440187qka.53.2018.12.06.00.22.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Dec 2018 00:22:36 -0800 (PST)
Subject: Re: [PATCH v2 2/2] core-api/memory-hotplug.rst: divide Locking
 Internal section by different locks
References: <20181205023426.24029-1-richard.weiyang@gmail.com>
 <20181206002622.30675-1-richard.weiyang@gmail.com>
 <20181206002622.30675-2-richard.weiyang@gmail.com>
From: David Hildenbrand <david@redhat.com>
Message-ID: <385fd990-7969-197d-e811-a91c63ff3668@redhat.com>
Date: Thu, 6 Dec 2018 09:22:32 +0100
MIME-Version: 1.0
In-Reply-To: <20181206002622.30675-2-richard.weiyang@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>, rppt@linux.ibm.com, mhocko@suse.com, osalvador@suse.de
Cc: akpm@linux-foundation.org, linux-doc@vger.kernel.org, linux-mm@kvack.org

On 06.12.18 01:26, Wei Yang wrote:
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
> ---
> v2: adjustment based on David and Mike comment
> ---
>  Documentation/core-api/memory-hotplug.rst | 27 ++++++++++++++++++++++++---
>  1 file changed, 24 insertions(+), 3 deletions(-)
> 
> diff --git a/Documentation/core-api/memory-hotplug.rst b/Documentation/core-api/memory-hotplug.rst
> index de7467e48067..51d477ad4b80 100644
> --- a/Documentation/core-api/memory-hotplug.rst
> +++ b/Documentation/core-api/memory-hotplug.rst
> @@ -89,6 +89,20 @@ NOTIFY_STOP stops further processing of the notification queue.
>  Locking Internals
>  =================
>  
> +In addition to fine grained locks like pgdat_resize_lock, there are three locks
> +involved
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
> +sysfs. Even if mem_hotplug_lock is used to protect the process, because of the
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
> 

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb
