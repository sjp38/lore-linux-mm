Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5956F681021
	for <linux-mm@kvack.org>; Thu, 16 Feb 2017 22:08:04 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 65so47584022pgi.7
        for <linux-mm@kvack.org>; Thu, 16 Feb 2017 19:08:04 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id l1si8858931plk.130.2017.02.16.19.08.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Feb 2017 19:08:03 -0800 (PST)
Date: Thu, 16 Feb 2017 20:08:02 -0700
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH v2 2/2] mm: validate device_hotplug is held for memory
 hotplug
Message-ID: <20170217030802.GA27382@linux.intel.com>
References: <148728202805.38457.18028105614854319884.stgit@dwillia2-desk3.amr.corp.intel.com>
 <148728203880.38457.1158394701925100383.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <148728203880.38457.1158394701925100383.stgit@dwillia2-desk3.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>, linux-nvdimm@lists.01.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, Ben Hutchings <ben@decadent.org.uk>, Vlastimil Babka <vbabka@suse.cz>

On Thu, Feb 16, 2017 at 01:53:58PM -0800, Dan Williams wrote:
> mem_hotplug_begin() assumes that it can set mem_hotplug.active_writer
> and run the hotplug process without racing another thread. Validate this
> assumption with a lockdep assertion.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Toshi Kani <toshi.kani@hpe.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Reported-by: Ben Hutchings <ben@decadent.org.uk>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  drivers/base/core.c    |    5 +++++
>  include/linux/device.h |    1 +
>  mm/memory_hotplug.c    |    2 ++
>  3 files changed, 8 insertions(+)
> 
> diff --git a/drivers/base/core.c b/drivers/base/core.c
> index 8c25e68e67d7..3050e6f99403 100644
> --- a/drivers/base/core.c
> +++ b/drivers/base/core.c
> @@ -638,6 +638,11 @@ int lock_device_hotplug_sysfs(void)
>  	return restart_syscall();
>  }
>  
> +void assert_held_device_hotplug(void)
> +{
> +	lockdep_assert_held(&device_hotplug_lock);
> +}
> +
>  #ifdef CONFIG_BLOCK
>  static inline int device_is_not_partition(struct device *dev)
>  {
> diff --git a/include/linux/device.h b/include/linux/device.h
> index 491b4c0ca633..815965ee55dd 100644
> --- a/include/linux/device.h
> +++ b/include/linux/device.h
> @@ -1135,6 +1135,7 @@ static inline bool device_supports_offline(struct device *dev)
>  extern void lock_device_hotplug(void);
>  extern void unlock_device_hotplug(void);
>  extern int lock_device_hotplug_sysfs(void);
> +void assert_held_device_hotplug(void);
>  extern int device_offline(struct device *dev);
>  extern int device_online(struct device *dev);
>  extern void set_primary_fwnode(struct device *dev, struct fwnode_handle *fwnode);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index b8c11e063ff0..1635a2a085e5 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -126,6 +126,8 @@ void put_online_mems(void)
>  
>  void mem_hotplug_begin(void)
>  {
> +	assert_held_device_hotplug();

What's the benefit to defining assert_held_device_hotplug() as a one line
wrapper, instead of just calling lockdep_assert_held(&device_hotplug_lock)
directly?

> +
>  	mem_hotplug.active_writer = current;
>  
>  	memhp_lock_acquire();
> 
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
