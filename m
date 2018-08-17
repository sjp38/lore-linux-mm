Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 15DA66B0754
	for <linux-mm@kvack.org>; Fri, 17 Aug 2018 04:41:52 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 33-v6so4470615plf.19
        for <linux-mm@kvack.org>; Fri, 17 Aug 2018 01:41:52 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y40-v6si1628305pla.229.2018.08.17.01.41.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Aug 2018 01:41:50 -0700 (PDT)
Date: Fri, 17 Aug 2018 10:41:46 +0200
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH RFC 1/2] drivers/base: export
 lock_device_hotplug/unlock_device_hotplug
Message-ID: <20180817084146.GB14725@kroah.com>
References: <20180817075901.4608-1-david@redhat.com>
 <20180817075901.4608-2-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180817075901.4608-2-david@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, devel@linuxdriverproject.org, linux-s390@vger.kernel.org, xen-devel@lists.xenproject.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Dan Williams <dan.j.williams@intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Oscar Salvador <osalvador@suse.de>, Vitaly Kuznetsov <vkuznets@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, "K . Y . Srinivasan" <kys@microsoft.com>, Haiyang Zhang <haiyangz@microsoft.com>, Stephen Hemminger <sthemmin@microsoft.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, "Rafael J . Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, David Rientjes <rientjes@google.com>

On Fri, Aug 17, 2018 at 09:59:00AM +0200, David Hildenbrand wrote:
> From: Vitaly Kuznetsov <vkuznets@redhat.com>
> 
> Well require to call add_memory()/add_memory_resource() with
> device_hotplug_lock held, to avoid a lock inversion. Allow external modules
> (e.g. hv_balloon) that make use of add_memory()/add_memory_resource() to
> lock device hotplug.
> 
> Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
> [modify patch description]
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  drivers/base/core.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/drivers/base/core.c b/drivers/base/core.c
> index 04bbcd779e11..9010b9e942b5 100644
> --- a/drivers/base/core.c
> +++ b/drivers/base/core.c
> @@ -700,11 +700,13 @@ void lock_device_hotplug(void)
>  {
>  	mutex_lock(&device_hotplug_lock);
>  }
> +EXPORT_SYMBOL_GPL(lock_device_hotplug);
>  
>  void unlock_device_hotplug(void)
>  {
>  	mutex_unlock(&device_hotplug_lock);
>  }
> +EXPORT_SYMBOL_GPL(unlock_device_hotplug);

If these are going to be "global" symbols, let's properly name them.
device_hotplug_lock/unlock would be better.  But I am _really_ nervous
about letting stuff outside of the driver core mess with this, as people
better know what they are doing.

Can't we just "lock" the memory stuff instead?  Why does the entirety of
the driver core need to be messed with here?

thanks,

greg k-h
