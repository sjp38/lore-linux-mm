Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BE3FC6B0047
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 03:56:34 -0500 (EST)
Received: by fxm22 with SMTP id 22so7754716fxm.6
        for <linux-mm@kvack.org>; Fri, 26 Feb 2010 00:56:32 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1267166172-14059-1-git-send-email-dmonakhov@openvz.org>
References: <1267166172-14059-1-git-send-email-dmonakhov@openvz.org>
Date: Fri, 26 Feb 2010 10:56:31 +0200
Message-ID: <84144f021002260056g68e25ecer1dd826ecc5d42a56@mail.gmail.com>
Subject: Re: [PATCH] failslab: add ability to filter slab caches [v3]
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Dmitry Monakhov <dmonakhov@openvz.org>
Cc: linux-mm@kvack.org, cl@linux-foundation.org, rientjes@google.com, akinobu.mita@gmail.com
List-ID: <linux-mm.kvack.org>

On Fri, Feb 26, 2010 at 8:36 AM, Dmitry Monakhov <dmonakhov@openvz.org> wro=
te:
> This patch allow to inject faults only for specific slabs.
> In order to preserve default behavior cache filter is off by
> default (all caches are faulty).
>
> One may define specific set of slabs like this:
> # mark skbuff_head_cache as faulty
> echo 1 > /sys/kernel/slab/skbuff_head_cache/failslab
> # Turn on cache filter (off by default)
> echo 1 > /sys/kernel/debug/failslab/cache-filter
> # Turn on fault injection
> echo 1 > /sys/kernel/debug/failslab/times
> echo 1 > /sys/kernel/debug/failslab/probability
>
> Acked-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Dmitry Monakhov <dmonakhov@openvz.org>

Lets CC the failslab author as well for ACKs.

> ---
> =A0Documentation/vm/slub.txt =A0 =A0| =A0 =A01 +
> =A0include/linux/fault-inject.h | =A0 =A05 +++--
> =A0include/linux/slab.h =A0 =A0 =A0 =A0 | =A0 =A05 +++++
> =A0mm/failslab.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 18 +++++++++++++++-=
--
> =A0mm/slab.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A02 +-
> =A0mm/slub.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 29 ++++++++++++=
+++++++++++++++--
> =A06 files changed, 52 insertions(+), 8 deletions(-)
>
> diff --git a/Documentation/vm/slub.txt b/Documentation/vm/slub.txt
> index b37300e..07375e7 100644
> --- a/Documentation/vm/slub.txt
> +++ b/Documentation/vm/slub.txt
> @@ -41,6 +41,7 @@ Possible debug options are
> =A0 =A0 =A0 =A0P =A0 =A0 =A0 =A0 =A0 =A0 =A0 Poisoning (object and paddin=
g)
> =A0 =A0 =A0 =A0U =A0 =A0 =A0 =A0 =A0 =A0 =A0 User tracking (free and allo=
c)
> =A0 =A0 =A0 =A0T =A0 =A0 =A0 =A0 =A0 =A0 =A0 Trace (please only use on si=
ngle slabs)
> + =A0 =A0 =A0 A =A0 =A0 =A0 =A0 =A0 =A0 =A0 Toggle failslab filter mark f=
or the cache
> =A0 =A0 =A0 =A0O =A0 =A0 =A0 =A0 =A0 =A0 =A0 Switch debugging off for cac=
hes that would have
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0caused higher minimum slab=
 orders
> =A0 =A0 =A0 =A0- =A0 =A0 =A0 =A0 =A0 =A0 =A0 Switch all debugging off (us=
eful if the kernel is
> diff --git a/include/linux/fault-inject.h b/include/linux/fault-inject.h
> index 06ca9b2..7b64ad4 100644
> --- a/include/linux/fault-inject.h
> +++ b/include/linux/fault-inject.h
> @@ -82,9 +82,10 @@ static inline void cleanup_fault_attr_dentries(struct =
fault_attr *attr)
> =A0#endif /* CONFIG_FAULT_INJECTION */
>
> =A0#ifdef CONFIG_FAILSLAB
> -extern bool should_failslab(size_t size, gfp_t gfpflags);
> +extern bool should_failslab(size_t size, gfp_t gfpflags, unsigned long f=
lags);
> =A0#else
> -static inline bool should_failslab(size_t size, gfp_t gfpflags)
> +static inline bool should_failslab(size_t size, gfp_t gfpflags,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unsigned lo=
ng flags)
> =A0{
> =A0 =A0 =A0 =A0return false;
> =A0}
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 2da8372..4884462 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -70,6 +70,11 @@
> =A0#else
> =A0# define SLAB_NOTRACK =A0 =A0 =A0 =A0 =A00x00000000UL
> =A0#endif
> +#ifdef CONFIG_FAILSLAB
> +# define SLAB_FAILSLAB =A0 =A0 =A0 =A0 0x02000000UL =A0 =A0/* Fault inje=
ction mark */
> +#else
> +# define SLAB_FAILSLAB =A0 =A0 =A0 =A0 0x00000000UL
> +#endif
>
> =A0/* The following flags affect the page allocator grouping pages by mob=
ility */
> =A0#define SLAB_RECLAIM_ACCOUNT =A0 0x00020000UL =A0 =A0 =A0 =A0 =A0 =A0/=
* Objects are reclaimable */
> diff --git a/mm/failslab.c b/mm/failslab.c
> index 9339de5..bb41f98 100644
> --- a/mm/failslab.c
> +++ b/mm/failslab.c
> @@ -1,18 +1,22 @@
> =A0#include <linux/fault-inject.h>
> =A0#include <linux/gfp.h>
> +#include <linux/slab.h>
>
> =A0static struct {
> =A0 =A0 =A0 =A0struct fault_attr attr;
> =A0 =A0 =A0 =A0u32 ignore_gfp_wait;
> + =A0 =A0 =A0 int cache_filter;
> =A0#ifdef CONFIG_FAULT_INJECTION_DEBUG_FS
> =A0 =A0 =A0 =A0struct dentry *ignore_gfp_wait_file;
> + =A0 =A0 =A0 struct dentry *cache_filter_file;
> =A0#endif
> =A0} failslab =3D {
> =A0 =A0 =A0 =A0.attr =3D FAULT_ATTR_INITIALIZER,
> =A0 =A0 =A0 =A0.ignore_gfp_wait =3D 1,
> + =A0 =A0 =A0 .cache_filter =3D 0,
> =A0};
>
> -bool should_failslab(size_t size, gfp_t gfpflags)
> +bool should_failslab(size_t size, gfp_t gfpflags, unsigned long cache_fl=
ags)
> =A0{
> =A0 =A0 =A0 =A0if (gfpflags & __GFP_NOFAIL)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return false;
> @@ -20,6 +24,9 @@ bool should_failslab(size_t size, gfp_t gfpflags)
> =A0 =A0 =A0 =A0 if (failslab.ignore_gfp_wait && (gfpflags & __GFP_WAIT))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return false;
>
> + =A0 =A0 =A0 if (failslab.cache_filter && !(cache_flags & SLAB_FAILSLAB)=
)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return false;
> +
> =A0 =A0 =A0 =A0return should_fail(&failslab.attr, size);
> =A0}
>
> @@ -30,7 +37,6 @@ static int __init setup_failslab(char *str)
> =A0__setup("failslab=3D", setup_failslab);
>
> =A0#ifdef CONFIG_FAULT_INJECTION_DEBUG_FS
> -
> =A0static int __init failslab_debugfs_init(void)
> =A0{
> =A0 =A0 =A0 =A0mode_t mode =3D S_IFREG | S_IRUSR | S_IWUSR;
> @@ -46,8 +52,14 @@ static int __init failslab_debugfs_init(void)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0debugfs_create_bool("ignore-gfp-wait", mod=
e, dir,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0&failslab.ignore_gfp_wait);
>
> - =A0 =A0 =A0 if (!failslab.ignore_gfp_wait_file) {
> + =A0 =A0 =A0 failslab.cache_filter_file =3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 debugfs_create_bool("cache-filter", mode, d=
ir,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 &failslab.cache_filter);
> +
> + =A0 =A0 =A0 if (!failslab.ignore_gfp_wait_file ||
> + =A0 =A0 =A0 =A0 =A0 !failslab.cache_filter_file) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D -ENOMEM;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 debugfs_remove(failslab.cache_filter_file);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0debugfs_remove(failslab.ignore_gfp_wait_fi=
le);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cleanup_fault_attr_dentries(&failslab.attr=
);
> =A0 =A0 =A0 =A0}
> diff --git a/mm/slab.c b/mm/slab.c
> index 7451bda..33496b7 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -3101,7 +3101,7 @@ static bool slab_should_failslab(struct kmem_cache =
*cachep, gfp_t flags)
> =A0 =A0 =A0 =A0if (cachep =3D=3D &cache_cache)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return false;
>
> - =A0 =A0 =A0 return should_failslab(obj_size(cachep), flags);
> + =A0 =A0 =A0 return should_failslab(obj_size(cachep), flags, cachep->fla=
gs);
> =A0}
>
> =A0static inline void *____cache_alloc(struct kmem_cache *cachep, gfp_t f=
lags)
> diff --git a/mm/slub.c b/mm/slub.c
> index 8d71aaf..cab5288 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -151,7 +151,8 @@
> =A0* Set of flags that will prevent slab merging
> =A0*/
> =A0#define SLUB_NEVER_MERGE (SLAB_RED_ZONE | SLAB_POISON | SLAB_STORE_USE=
R | \
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 SLAB_TRACE | SLAB_DESTROY_BY_RCU | SLAB_NOL=
EAKTRACE)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 SLAB_TRACE | SLAB_DESTROY_BY_RCU | SLAB_NOL=
EAKTRACE | \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 SLAB_FAILSLAB)
>
> =A0#define SLUB_MERGE_SAME (SLAB_DEBUG_FREE | SLAB_RECLAIM_ACCOUNT | \
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0SLAB_CACHE_DMA | SLAB_NOTRACK)
> @@ -1020,6 +1021,9 @@ static int __init setup_slub_debug(char *str)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case 't':
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slub_debug |=3D SLAB_TRACE=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 case 'a':
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 slub_debug |=3D SLAB_FAILSL=
AB;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0default:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0printk(KERN_ERR "slub_debu=
g option '%c' "
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"unknown. =
skipped\n", *str);
> @@ -1718,7 +1722,7 @@ static __always_inline void *slab_alloc(struct kmem=
_cache *s,
> =A0 =A0 =A0 =A0lockdep_trace_alloc(gfpflags);
> =A0 =A0 =A0 =A0might_sleep_if(gfpflags & __GFP_WAIT);
>
> - =A0 =A0 =A0 if (should_failslab(s->objsize, gfpflags))
> + =A0 =A0 =A0 if (should_failslab(s->objsize, gfpflags, s->flags))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
>
> =A0 =A0 =A0 =A0local_irq_save(flags);
> @@ -4171,6 +4175,23 @@ static ssize_t trace_store(struct kmem_cache *s, c=
onst char *buf,
> =A0}
> =A0SLAB_ATTR(trace);
>
> +#ifdef CONFIG_FAILSLAB
> +static ssize_t failslab_show(struct kmem_cache *s, char *buf)
> +{
> + =A0 =A0 =A0 return sprintf(buf, "%d\n", !!(s->flags & SLAB_FAILSLAB));
> +}
> +
> +static ssize_t failslab_store(struct kmem_cache *s, const char *buf,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 size_t length)
> +{
> + =A0 =A0 =A0 s->flags &=3D ~SLAB_FAILSLAB;
> + =A0 =A0 =A0 if (buf[0] =3D=3D '1')
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 s->flags |=3D SLAB_FAILSLAB;
> + =A0 =A0 =A0 return length;
> +}
> +SLAB_ATTR(failslab);
> +#endif
> +
> =A0static ssize_t reclaim_account_show(struct kmem_cache *s, char *buf)
> =A0{
> =A0 =A0 =A0 =A0return sprintf(buf, "%d\n", !!(s->flags & SLAB_RECLAIM_ACC=
OUNT));
> @@ -4467,6 +4488,10 @@ static struct attribute *slab_attrs[] =3D {
> =A0 =A0 =A0 =A0&deactivate_remote_frees_attr.attr,
> =A0 =A0 =A0 =A0&order_fallback_attr.attr,
> =A0#endif
> +#ifdef CONFIG_FAILSLAB
> + =A0 =A0 =A0 &failslab_attr.attr,
> +#endif
> +
> =A0 =A0 =A0 =A0NULL
> =A0};
>
> --
> 1.6.6
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
