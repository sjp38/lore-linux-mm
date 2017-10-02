Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C0B8C6B0069
	for <linux-mm@kvack.org>; Mon,  2 Oct 2017 07:55:43 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id f84so11735209pfj.0
        for <linux-mm@kvack.org>; Mon, 02 Oct 2017 04:55:43 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id m9si7882021pll.209.2017.10.02.04.55.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Oct 2017 04:55:42 -0700 (PDT)
Message-ID: <1506945338.6755.53.camel@linux.intel.com>
Subject: Re: [PATCH 02/21] drm/i915: introduce simple gemfs
From: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Date: Mon, 02 Oct 2017 14:55:38 +0300
In-Reply-To: <20170929161032.24394-3-matthew.auld@intel.com>
References: <20170929161032.24394-1-matthew.auld@intel.com>
	 <20170929161032.24394-3-matthew.auld@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Auld <matthew.auld@intel.com>, intel-gfx@lists.freedesktop.org
Cc: Chris Wilson <chris@chris-wilson.co.uk>, Dave Hansen <dave.hansen@intel.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Fri, 2017-09-29 at 17:10 +0100, Matthew Auld wrote:
> Not a fully blown gemfs, just our very own tmpfs kernel mount. Doing so
> moves us away from the shmemfs shm_mnt, and gives us the much needed
> flexibility to do things like set our own mount options, namely huge=
> which should allow us to enable the use of transparent-huge-pages for
> our shmem backed objects.
> 
> v2: various improvements suggested by Joonas
> 
> v3: move gemfs instance to i915.mm and simplify now that we have
> file_setup_with_mnt
> 
> v4: fallback to tmpfs shm_mnt upon failure to setup gemfs
> 
> v5: make tmpfs fallback kinder
> 
> Signed-off-by: Matthew Auld <matthew.auld@intel.com>
> Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> Cc: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Kirill A. Shutemov <kirill@shutemov.name>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: linux-mm@kvack.org

<SNIP>

> @@ -4251,6 +4252,29 @@ static const struct drm_i915_gem_object_ops i915_gem_object_ops = {
>  	.pwrite = i915_gem_object_pwrite_gtt,
>  };
>  
> +static int i915_gem_object_create_shmem(struct drm_device *dev,
> +					struct drm_gem_object *obj,
> +					size_t size)
> +{
> +	struct drm_i915_private *i915 = to_i915(dev);
> +	struct file *filp;
> +
> +	drm_gem_private_object_init(dev, obj, size);
> +
> +	if (i915->mm.gemfs)
> +		filp = shmem_file_setup_with_mnt(i915->mm.gemfs, "i915", size,
> +						 VM_NORESERVE);
> +	else
> +		filp = shmem_file_setup("i915", size, VM_NORESERVE);

Put that VM_NORESERVE to 'flags' variable.

> @@ -4915,6 +4939,9 @@ i915_gem_load_init(struct drm_i915_private *dev_priv)
>  
>  	spin_lock_init(&dev_priv->fb_tracking.lock);
>  
> +	if (i915_gemfs_init(dev_priv))
> +		DRM_NOTE("Unable to create a private tmpfs mountpoint, hugepage support will be disabled.\n");

s/mountpoint/mount/, as we're not creating a directory. Maybe also
include the returned error for easier post-mortem?

Reviewed-by: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>

Regards, Joonas
-- 
Joonas Lahtinen
Open Source Technology Center
Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
