Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 959926B025F
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 10:33:23 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id r187so6327203pfr.8
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 07:33:23 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id u8si2499219pfg.58.2017.08.29.07.33.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Aug 2017 07:33:22 -0700 (PDT)
Message-ID: <1504017185.5001.71.camel@linux.intel.com>
Subject: Re: [PATCH 02/23] drm/i915: introduce simple gemfs
From: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Date: Tue, 29 Aug 2017 17:33:05 +0300
In-Reply-To: <20170821183503.12246-3-matthew.auld@intel.com>
References: <20170821183503.12246-1-matthew.auld@intel.com>
	 <20170821183503.12246-3-matthew.auld@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Auld <matthew.auld@intel.com>, intel-gfx@lists.freedesktop.org
Cc: Chris Wilson <chris@chris-wilson.co.uk>, Dave Hansen <dave.hansen@intel.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Mon, 2017-08-21 at 19:34 +0100, Matthew Auld wrote:
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
> Signed-off-by: Matthew Auld <matthew.auld@intel.com>
> Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> Cc: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Kirill A. Shutemov <kirill@shutemov.name>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: linux-mm@kvack.org

<SNIP>

> @@ -4288,6 +4289,25 @@ static const struct drm_i915_gem_object_ops i915_gem_object_ops = {
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
> +	filp = shmem_file_setup_with_mnt(i915->mm.gemfs, "i915", size,
> +					 VM_NORESERVE);

Can you double-check that /proc/meminfo is unaffected by this change?
If we stop appearing under "Shemem:" we maybe need to maybe highlight
this somewhere (at least in commit message).

<SNIP>

> +int i915_gemfs_init(struct drm_i915_private *i915)
> +{
> +	struct file_system_type *type;
> +	struct vfsmount *gemfs;
> +
> +	type = get_fs_type("tmpfs");
> +	if (!type)
> +		return -ENODEV;
> +
> +	gemfs = kern_mount(type);
> +	if (IS_ERR(gemfs))
> +		return PTR_ERR(gemfs);

By occasionally checking that "i915->mm.gemfs" might be NULL, could we
continue without our own gemfs mount and just lose the additional
features? Or is it not worth the hassle?

Anyway, this is:

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
