Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 87E7E6B0038
	for <linux-mm@kvack.org>; Mon, 25 Sep 2017 15:11:40 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id i131so798379wma.9
        for <linux-mm@kvack.org>; Mon, 25 Sep 2017 12:11:40 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id o201si91121wmg.151.2017.09.25.12.11.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Sep 2017 12:11:39 -0700 (PDT)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <20170925184737.8807-5-matthew.auld@intel.com>
References: <20170925184737.8807-1-matthew.auld@intel.com>
 <20170925184737.8807-5-matthew.auld@intel.com>
Message-ID: <150636669485.18819.3648302910733753333@mail.alporthouse.com>
Subject: Re: [PATCH 04/22] drm/i915/gemfs: enable THP
Date: Mon, 25 Sep 2017 20:11:34 +0100
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Auld <matthew.auld@intel.com>, intel-gfx@lists.freedesktop.org
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, "Kirill A . Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

Quoting Matthew Auld (2017-09-25 19:47:19)
> Enable transparent-huge-pages through gemfs by mounting with
> huge=3Dwithin_size.
> =

> v2: prefer kern_mount_data
> =

> Signed-off-by: Matthew Auld <matthew.auld@intel.com>
> Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
> Cc: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: Dave Hansen <dave.hansen@intel.com>
> Cc: Kirill A. Shutemov <kirill@shutemov.name>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: linux-mm@kvack.org
> ---
>  drivers/gpu/drm/i915/i915_gemfs.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> =

> diff --git a/drivers/gpu/drm/i915/i915_gemfs.c b/drivers/gpu/drm/i915/i91=
5_gemfs.c
> index 168d0bd98f60..dc35719814f0 100644
> --- a/drivers/gpu/drm/i915/i915_gemfs.c
> +++ b/drivers/gpu/drm/i915/i915_gemfs.c
> @@ -24,6 +24,7 @@
>  =

>  #include <linux/fs.h>
>  #include <linux/mount.h>
> +#include <linux/pagemap.h>
>  =

>  #include "i915_drv.h"
>  #include "i915_gemfs.h"
> @@ -32,12 +33,17 @@ int i915_gemfs_init(struct drm_i915_private *i915)
>  {
>         struct file_system_type *type;
>         struct vfsmount *gemfs;
> +       char within_size[] =3D "huge=3Dwithin_size";
> +       char *options =3D NULL;
>  =

>         type =3D get_fs_type("tmpfs");
>         if (!type)
>                 return -ENODEV;
>  =


/*
 * Enable hugepages that fit into the object's size so that
 * we do not overallocate, as the excess will not be reused and
 * our objects may be extremely long lived.
 */

> -       gemfs =3D kern_mount(type);
> +       if (has_transparent_hugepage())
> +               options =3D within_size;
> +
> +       gemfs =3D kern_mount_data(type, options);

The alternative to the previous two patches would be to export a
function to set the hugepage policy on the shmem_sb_info.

>         if (IS_ERR(gemfs))
>                 return PTR_ERR(gemfs);

Reviewed-by: Chris Wilson <chris@chris-wilson.co.uk>
-Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
