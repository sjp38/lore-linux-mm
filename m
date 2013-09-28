Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 544F66B0031
	for <linux-mm@kvack.org>; Sat, 28 Sep 2013 02:50:00 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so3702420pad.9
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 23:49:59 -0700 (PDT)
Received: by mail-we0-f182.google.com with SMTP id q59so3622952wes.27
        for <linux-mm@kvack.org>; Fri, 27 Sep 2013 23:49:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0000014142863060-919062ff-7284-445d-b3ec-f38cc8d5a6c8-000000@email.amazonses.com>
References: <1379646960-12553-1-git-send-email-jbrassow@redhat.com>
	<0000014142863060-919062ff-7284-445d-b3ec-f38cc8d5a6c8-000000@email.amazonses.com>
Date: Sat, 28 Sep 2013 09:49:56 +0300
Message-ID: <CAOJsxLGaNe_cap7fx8ZRZPWqkQhUbpA07Qhtgsg_+c5JdgV=qQ@mail.gmail.com>
Subject: Re: [PATCH] Problems with RAID 4/5/6 and kmem_cache
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Jonathan Brassow <jbrassow@redhat.com>, linux-raid@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sun, Sep 22, 2013 at 12:56 AM, Christoph Lameter <cl@linux.com> wrote:
> On Thu, 19 Sep 2013, Jonathan Brassow wrote:
>
>> 4) kmem_cache_create(name="foo-a")
>> - This FAILS because kmem_cache_sanity_check colides with the existing
>>   name ("foo-a") associated with the non-removed cache.
>
> That should not happen. breakage you see will result. Oh. I see the move
> to common code resulted in the SLAB checks being used for SLUB.
>
> The following patch should fix this.
>
> Subject: slab_common: Do not check for duplicate slab names
>
> SLUB can alias multiple slab kmem_create_requests to one slab cache
> to save memory and increase the cache hotness. As a result the name
> of the slab can be stale. Only check the name for duplicates if we are
> in debug mode where we do not merge multiple caches.
>
> Signed-off-by: Christoph Lameter <cl@linux.com>
>
> Index: linux/mm/slab_common.c
> ===================================================================
> --- linux.orig/mm/slab_common.c 2013-09-20 11:49:13.052208294 -0500
> +++ linux/mm/slab_common.c      2013-09-21 16:55:23.097131481 -0500
> @@ -56,6 +56,7 @@
>                         continue;
>                 }
>
> +#if !defined(CONFIG_SLUB) || !defined(CONFIG_SLUB_DEBUG_ON)
>                 /*
>                  * For simplicity, we won't check this in the list of memcg
>                  * caches. We have control over memcg naming, and if there
> @@ -69,6 +70,7 @@
>                         s = NULL;
>                         return -EINVAL;
>                 }
> +#endif
>         }
>
>         WARN_ON(strchr(name, ' '));     /* It confuses parsers */

Applied to slab/urgent, thanks!

Do we need to come up with something less #ifdeffy for v3.13?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
