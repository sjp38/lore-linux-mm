Received: by wf-out-1314.google.com with SMTP id 28so2603578wfc.11
        for <linux-mm@kvack.org>; Mon, 01 Dec 2008 03:18:33 -0800 (PST)
Message-ID: <84144f020812010318v205579ean57edecf7992ec7ef@mail.gmail.com>
Date: Mon, 1 Dec 2008 13:18:33 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [patch][rfc] acpi: do not use kmem caches
In-Reply-To: <20081201083128.GB2529@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20081201083128.GB2529@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-acpi@vger.kernel.org, lenb@kernel.org
List-ID: <linux-mm.kvack.org>

Hi Nick,

On Mon, Dec 1, 2008 at 10:31 AM, Nick Piggin <npiggin@suse.de> wrote:
> What does everyone think about this patch?

Doesn't matter all that much for SLUB which already merges the ACPI
caches with the generic kmalloc caches. But for SLAB, it's an obvious
wil so:

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

> ACPI subsystem creates a handful of kmem caches that are not particularly
> appropriate. Most of them seem to be empty or nearly empty most of the time,
> and the others don't have too many objects. In this situation, kmem caches
> can actually have more overhead than they save.
>
> Just use ACPI's generic code for its acpi_cache_t type.
> ---
>  drivers/acpi/osl.c              |   85 ----------------------------------------
>  include/acpi/acmacros.h         |    2
>  include/acpi/platform/aclinux.h |    9 ----
>  3 files changed, 3 insertions(+), 93 deletions(-)
>
> Index: linux-2.6/include/acpi/acmacros.h
> ===================================================================
> --- linux-2.6.orig/include/acpi/acmacros.h
> +++ linux-2.6/include/acpi/acmacros.h
> @@ -670,7 +670,7 @@ struct acpi_integer_overlay {
>  #define ACPI_ALLOCATE_ZEROED(a)     acpi_ut_allocate_zeroed((acpi_size)(a), ACPI_MEM_PARAMETERS)
>  #endif
>  #ifndef ACPI_FREE
> -#define ACPI_FREE(a)                acpio_os_free(a)
> +#define ACPI_FREE(a)                acpi_os_free(a)
>  #endif
>  #define ACPI_MEM_TRACKING(a)
>
> Index: linux-2.6/include/acpi/platform/aclinux.h
> ===================================================================
> --- linux-2.6.orig/include/acpi/platform/aclinux.h
> +++ linux-2.6/include/acpi/platform/aclinux.h
> @@ -65,7 +65,6 @@
>  /* Host-dependent types and defines */
>
>  #define ACPI_MACHINE_WIDTH          BITS_PER_LONG
> -#define acpi_cache_t                        struct kmem_cache
>  #define acpi_spinlock                   spinlock_t *
>  #define ACPI_EXPORT_SYMBOL(symbol)  EXPORT_SYMBOL(symbol);
>  #define strtoul                     simple_strtoul
> @@ -73,6 +72,8 @@
>  /* Full namespace pathname length limit - arbitrary */
>  #define ACPI_PATHNAME_MAX              256
>
> +#define ACPI_USE_LOCAL_CACHE
> +
>  #else                          /* !__KERNEL__ */
>
>  #include <stdarg.h>
> @@ -128,12 +129,6 @@ static inline void *acpi_os_allocate_zer
>        return kzalloc(size, irqs_disabled()? GFP_ATOMIC : GFP_KERNEL);
>  }
>
> -static inline void *acpi_os_acquire_object(acpi_cache_t * cache)
> -{
> -       return kmem_cache_zalloc(cache,
> -                                irqs_disabled()? GFP_ATOMIC : GFP_KERNEL);
> -}
> -
>  #define ACPI_ALLOCATE(a)       acpi_os_allocate(a)
>  #define ACPI_ALLOCATE_ZEROED(a)        acpi_os_allocate_zeroed(a)
>  #define ACPI_FREE(a)           kfree(a)
> Index: linux-2.6/drivers/acpi/osl.c
> ===================================================================
> --- linux-2.6.orig/drivers/acpi/osl.c
> +++ linux-2.6/drivers/acpi/osl.c
> @@ -1212,91 +1212,6 @@ void acpi_os_release_lock(acpi_spinlock
>        spin_unlock_irqrestore(lockp, flags);
>  }
>
> -#ifndef ACPI_USE_LOCAL_CACHE
> -
> -/*******************************************************************************
> - *
> - * FUNCTION:    acpi_os_create_cache
> - *
> - * PARAMETERS:  name      - Ascii name for the cache
> - *              size      - Size of each cached object
> - *              depth     - Maximum depth of the cache (in objects) <ignored>
> - *              cache     - Where the new cache object is returned
> - *
> - * RETURN:      status
> - *
> - * DESCRIPTION: Create a cache object
> - *
> - ******************************************************************************/
> -
> -acpi_status
> -acpi_os_create_cache(char *name, u16 size, u16 depth, acpi_cache_t ** cache)
> -{
> -       *cache = kmem_cache_create(name, size, 0, 0, NULL);
> -       if (*cache == NULL)
> -               return AE_ERROR;
> -       else
> -               return AE_OK;
> -}
> -
> -/*******************************************************************************
> - *
> - * FUNCTION:    acpi_os_purge_cache
> - *
> - * PARAMETERS:  Cache           - Handle to cache object
> - *
> - * RETURN:      Status
> - *
> - * DESCRIPTION: Free all objects within the requested cache.
> - *
> - ******************************************************************************/
> -
> -acpi_status acpi_os_purge_cache(acpi_cache_t * cache)
> -{
> -       kmem_cache_shrink(cache);
> -       return (AE_OK);
> -}
> -
> -/*******************************************************************************
> - *
> - * FUNCTION:    acpi_os_delete_cache
> - *
> - * PARAMETERS:  Cache           - Handle to cache object
> - *
> - * RETURN:      Status
> - *
> - * DESCRIPTION: Free all objects within the requested cache and delete the
> - *              cache object.
> - *
> - ******************************************************************************/
> -
> -acpi_status acpi_os_delete_cache(acpi_cache_t * cache)
> -{
> -       kmem_cache_destroy(cache);
> -       return (AE_OK);
> -}
> -
> -/*******************************************************************************
> - *
> - * FUNCTION:    acpi_os_release_object
> - *
> - * PARAMETERS:  Cache       - Handle to cache object
> - *              Object      - The object to be released
> - *
> - * RETURN:      None
> - *
> - * DESCRIPTION: Release an object to the specified cache.  If cache is full,
> - *              the object is deleted.
> - *
> - ******************************************************************************/
> -
> -acpi_status acpi_os_release_object(acpi_cache_t * cache, void *object)
> -{
> -       kmem_cache_free(cache, object);
> -       return (AE_OK);
> -}
> -#endif
> -
>  /**
>  *     acpi_dmi_dump - dump DMI slots needed for blacklist entry
>  *
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
