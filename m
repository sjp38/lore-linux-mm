Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 68FDB6B004A
	for <linux-mm@kvack.org>; Mon,  6 Sep 2010 17:16:33 -0400 (EDT)
Date: Mon, 6 Sep 2010 14:07:47 -0700
From: Greg KH <greg@kroah.com>
Subject: Re: [RFCv5 3/9] mm: cma: Added SysFS support
Message-ID: <20100906210747.GA5863@kroah.com>
References: <cover.1283749231.git.mina86@mina86.com> <9771a9c07874a642bb587f4c0ebf886d720332b6.1283749231.git.mina86@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9771a9c07874a642bb587f4c0ebf886d720332b6.1283749231.git.mina86@mina86.com>
Sender: owner-linux-mm@kvack.org
To: Michal Nazarewicz <m.nazarewicz@samsung.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Jonathan Corbet <corbet@lwn.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, Pawel Osciak <p.osciak@samsung.com>, Peter Zijlstra <peterz@infradead.org>, Russell King <linux@arm.linux.org.uk>, Zach Pfeffer <zpfeffer@codeaurora.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Sep 06, 2010 at 08:33:53AM +0200, Michal Nazarewicz wrote:
> +++ b/Documentation/ABI/testing/sysfs-kernel-mm-contiguous
> @@ -0,0 +1,53 @@
> +What:		/sys/kernel/mm/contiguous/
> +Date:		August 2010
> +Contact:	Michal Nazarewicz <m.nazarewicz@samsung.com>
> +Description:
> +		If CMA has been built with SysFS support,
> +		/sys/kernel/mm/contiguous/ contains a file called
> +		"map", a file called "allocators" and a directory
> +		called "regions".
> +
> +		The "map" file lets one change the CMA's map attribute
> +		at run-time.

How?

> +		The "allocators" file list all registered allocators.
> +		Allocators with no name are listed as a single minus
> +		sign.

So this returns more than one value?

> +		The "regions" directory list all reserved regions.

Same here?

> --- a/Documentation/contiguous-memory.txt
> +++ b/Documentation/contiguous-memory.txt
> @@ -256,6 +256,10 @@
>       iff it matched in previous pattern.  If the second part is
>       omitted it will mach any type of memory requested by device.
>  
> +     If SysFS support is enabled, this attribute is accessible via
> +     SysFS and can be changed at run-time by writing to
> +     /sys/kernel/mm/contiguous/map.

it is "sysfs" no wierd "SysFS" please.

> diff --git a/include/linux/cma.h b/include/linux/cma.h
> index f6f9cb5..d0f41f4 100644
> --- a/include/linux/cma.h
> +++ b/include/linux/cma.h
> @@ -18,6 +18,9 @@
>  #include <linux/rbtree.h>
>  #include <linux/list.h>
>  #include <linux/init.h>
> +#if defined CONFIG_CMA_SYSFS
> +#  include <linux/kobject.h>
> +#endif

Just always include it, no need to put a #ifdef around it, right?

>  
>  struct device;
> @@ -204,6 +207,10 @@ struct cma_region {
>  	unsigned users;
>  	struct list_head list;
>  
> +#if defined CONFIG_CMA_SYSFS
> +	struct kobject kobj;
> +#endif

Same here, no need for a #ifdef, right?

Especially as it will change your lifetime rules for this object, why
would you not want this to always be the case?

> +
>  	unsigned used:1;
>  	unsigned registered:1;
>  	unsigned reserved:1;
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 86043a3..8bed799 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -322,16 +322,36 @@ config CMA
>  	  For more information see <Documentation/contiguous-memory.txt>.
>  	  If unsure, say "n".
>  
> -config CMA_DEBUG
> -	bool "CMA debug messages (DEVELOPEMENT)"
> +config CMA_DEVELOPEMENT
> +	bool "Include CMA developement features"
>  	depends on CMA
>  	help
> +	  This lets you enable some developement features of the CMA
> +	  framework.  It does not add any code to the kernel.
> +
> +	  Those options are mostly usable during development and testing.
> +	  If unsure, say "n".
> +
> +config CMA_DEBUG
> +	bool "CMA debug messages"
> +	depends on CMA_DEVELOPEMENT
> +	help
>  	  Turns on debug messages in CMA.  This produces KERN_DEBUG
>  	  messages for every CMA call as well as various messages while
>  	  processing calls such as cma_alloc().  This option does not
>  	  affect warning and error messages.
>  
> -	  This is mostly used during development.  If unsure, say "n".
> +config CMA_SYSFS
> +	bool "CMA SysFS interface support"
> +	depends on CMA_DEVELOPEMENT
> +	help
> +	  Enable support for SysFS interface.  The interface is available
> +	  under /sys/kernel/mm/contiguous.  Each region and allocator is
> +	  represented there.
> +
> +	  For more information consult
> +	  <Documentation/contiguous-memory.txt> and
> +	  <Documentation/ABI/testing/sysfs-kernel-mm-contiguous> files.
>  
>  config CMA_BEST_FIT
>  	bool "CMA best-fit allocator"
> diff --git a/mm/cma.c b/mm/cma.c
> index 06d0d5a..955f08c 100644
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -38,8 +38,8 @@
>  
>  
>  /*
> - * Protects cma_regions, cma_allocators, cma_map, cma_map_length, and
> - * cma_chunks_by_start.
> + * Protects cma_regions, cma_allocators, cma_map, cma_map_length,
> + * cma_kobj, cma_sysfs_regions and cma_chunks_by_start.
>   */
>  static DEFINE_MUTEX(cma_mutex);
>  
> @@ -143,7 +143,11 @@ int __init __must_check cma_early_region_register(struct cma_region *reg)
>  
>  /************************* Regions & Allocators *************************/
>  
> +static void __cma_sysfs_region_add(struct cma_region *reg);
> +
>  static int __cma_region_attach_alloc(struct cma_region *reg);
> +static void __maybe_unused __cma_region_detach_alloc(struct cma_region *reg);
> +
>  
>  /* List of all regions.  Named regions are kept before unnamed. */
>  static LIST_HEAD(cma_regions);
> @@ -226,6 +230,8 @@ int __must_check cma_region_register(struct cma_region *reg)
>  	else
>  		list_add_tail(&reg->list, &cma_regions);
>  
> +	__cma_sysfs_region_add(reg);
> +
>  done:
>  	mutex_unlock(&cma_mutex);
>  
> @@ -482,6 +488,329 @@ subsys_initcall(cma_init);
>  
>  
>  
> +/************************* SysFS *************************/
> +
> +#if defined CONFIG_CMA_SYSFS
> +
> +static struct kobject cma_sysfs_regions;

No static kobjects please, that means the code is broken.

> +static int cma_sysfs_regions_ready;
> +
> +
> +#define CMA_ATTR_INLINE(_type, _name)					\
> +	(&((struct cma_ ## _type ## _attribute){			\
> +		.attr	= {						\
> +			.name	= __stringify(_name),			\
> +			.mode	= 0644,					\
> +		},							\
> +		.show	= cma_sysfs_ ## _type ## _ ## _name ## _show,	\
> +		.store	= cma_sysfs_ ## _type ## _ ## _name ## _store,	\
> +	}).attr)
> +
> +#define CMA_ATTR_RO_INLINE(_type, _name)				\
> +	(&((struct cma_ ## _type ## _attribute){			\
> +		.attr	= {						\
> +			.name	= __stringify(_name),			\
> +			.mode	= 0444,					\
> +		},							\
> +		.show	= cma_sysfs_ ## _type ## _ ## _name ## _show,	\
> +	}).attr)
> +
> +
> +struct cma_root_attribute {
> +	struct attribute attr;
> +	ssize_t (*show)(char *buf);
> +	int (*store)(const char *buf);
> +};

Why can't you use a 'struct device' instead of using a "raw" kobject?

> +
> +static ssize_t cma_sysfs_root_map_show(char *page)
> +{
> +	ssize_t len;
> +
> +	len = cma_map_length;
> +	if (!len) {
> +		*page = 0;
> +		len = 0;
> +	} else {
> +		if (len > (size_t)PAGE_SIZE - 1)
> +			len = (size_t)PAGE_SIZE - 1;
> +		memcpy(page, cma_map, len);
> +		page[len++] = '\n';
> +	}
> +
> +	return len;
> +}

What are you returning here?  A "raw" buffer?  Why?  That's not what
sysfs is for.

> +
> +static int cma_sysfs_root_map_store(const char *page)
> +{
> +	ssize_t len = cma_map_validate(page);
> +	char *val = NULL;
> +
> +	if (len < 0)
> +		return len;
> +
> +	if (len) {
> +		val = kmemdup(page, len + 1, GFP_KERNEL);
> +		if (!val)
> +			return -ENOMEM;
> +		val[len] = '\0';
> +	}
> +
> +	kfree(cma_map);
> +	cma_map = val;
> +	cma_map_length = len;
> +
> +	return 0;
> +}

What is this doing?  It doesn't look like a "text" file to me, or am I
confused?

> +
> +static ssize_t cma_sysfs_root_allocators_show(char *page)
> +{
> +	struct cma_allocator *alloc;
> +	size_t left = PAGE_SIZE;
> +	char *ch = page;
> +
> +	cma_foreach_allocator(alloc) {
> +		ssize_t l = snprintf(ch, left, "%s ", alloc->name ?: "-");
> +		ch   += l;
> +		left -= l;
> +	}
> +
> +	if (ch != page)
> +		ch[-1] = '\n';
> +	return ch - page;
> +}

You are returning more than one value per sysfs file, why?

> +static ssize_t
> +cma_sysfs_root_show(struct kobject *kobj, struct attribute *attr, char *buf)
> +{
> +	struct cma_root_attribute *rattr =
> +		container_of(attr, struct cma_root_attribute, attr);
> +	ssize_t ret;
> +
> +	mutex_lock(&cma_mutex);
> +	ret = rattr->show(buf);

Are you sure you are not going to want to pass the attribute and kobject
to the show/store function?

> +	mutex_unlock(&cma_mutex);
> +
> +	return ret;
> +}
> +
> +static ssize_t
> +cma_sysfs_root_store(struct kobject *kobj, struct attribute *attr,
> +		       const char *buf, size_t count)
> +{
> +	struct cma_root_attribute *rattr =
> +		container_of(attr, struct cma_root_attribute, attr);
> +	int ret;
> +
> +	mutex_lock(&cma_mutex);
> +	ret = rattr->store(buf);
> +	mutex_unlock(&cma_mutex);
> +
> +	return ret < 0 ? ret : count;
> +}
> +
> +static struct kobj_type cma_sysfs_root_type = {
> +	.sysfs_ops	= &(const struct sysfs_ops){
> +		.show	= cma_sysfs_root_show,
> +		.store	= cma_sysfs_root_store,
> +	},
> +	.default_attrs	= (struct attribute * []) {
> +		CMA_ATTR_INLINE(root, map),
> +		CMA_ATTR_RO_INLINE(root, allocators),
> +		NULL
> +	},
> +};

This type is broken by design, and as per the documentation in the
kernel, I now get to publically ridicule you for doing so (as explained
in the documentation.)

Please go fix it up.

If you don't know why it is broken, then please, read the documentation
provided in the kernel, it's as if I write it for no one to later pay
attention to.  Why do I even bother...

> +
> +static int __init cma_sysfs_init(void)
> +{
> +	static struct kobject root;

Again, no static kobjects please.

> +	static struct kobj_type fake_type;
> +
> +	struct cma_region *reg;
> +	int ret;
> +
> +	/* Root */
> +	ret = kobject_init_and_add(&root, &cma_sysfs_root_type,
> +				   mm_kobj, "contiguous");
> +	if (unlikely(ret < 0)) {

Why "unlikely"?  Is this a fast-path or something?  Hint, I don't think
so...

> +		pr_err("init: unable to add root kobject: %d\n", ret);
> +		return ret;
> +	}
> +
> +	/* Regions */
> +	ret = kobject_init_and_add(&cma_sysfs_regions, &fake_type,
> +				   &root, "regions");
> +	if (unlikely(ret < 0)) {

Same thing here.

> +		pr_err("init: unable to add regions kobject: %d\n", ret);
> +		return ret;
> +	}
> +
> +	mutex_lock(&cma_mutex);
> +	cma_sysfs_regions_ready = 1;
> +	cma_foreach_region(reg)
> +		__cma_sysfs_region_add(reg);
> +	mutex_unlock(&cma_mutex);
> +
> +	return 0;
> +}
> +device_initcall(cma_sysfs_init);
> +
> +
> +
> +struct cma_region_attribute {
> +	struct attribute attr;
> +	ssize_t (*show)(struct cma_region *reg, char *buf);
> +	int (*store)(struct cma_region *reg, const char *buf);
> +};
> +
> +
> +static ssize_t cma_sysfs_region_name_show(struct cma_region *reg, char *page)
> +{
> +	return reg->name ? snprintf(page, PAGE_SIZE, "%s\n", reg->name) : 0;
> +}

Is a name field ever really going to be bigger than a page?

> +
> +static ssize_t cma_sysfs_region_start_show(struct cma_region *reg, char *page)
> +{
> +	return snprintf(page, PAGE_SIZE, "%p\n", (void *)reg->start);
> +}

Same for a start field.

> +
> +static ssize_t cma_sysfs_region_size_show(struct cma_region *reg, char *page)
> +{
> +	return snprintf(page, PAGE_SIZE, "%zu\n", reg->size);
> +}

Same for the size

> +
> +static ssize_t cma_sysfs_region_free_show(struct cma_region *reg, char *page)
> +{
> +	return snprintf(page, PAGE_SIZE, "%zu\n", reg->free_space);
> +}

Same here.

> +
> +static ssize_t cma_sysfs_region_users_show(struct cma_region *reg, char *page)
> +{
> +	return snprintf(page, PAGE_SIZE, "%u\n", reg->users);
> +}

And here

> +
> +static ssize_t cma_sysfs_region_alloc_show(struct cma_region *reg, char *page)
> +{
> +	if (reg->alloc)
> +		return snprintf(page, PAGE_SIZE, "%s\n",
> +				reg->alloc->name ?: "-");
> +	else if (reg->alloc_name)
> +		return snprintf(page, PAGE_SIZE, "[%s]\n", reg->alloc_name);
> +	else
> +		return 0;
> +}

Are all of these files in the Documentation/ABI directory?  I missed
that in your above description...


> +
> +static int
> +cma_sysfs_region_alloc_store(struct cma_region *reg, const char *page)
> +{
> +	char *s;
> +
> +	if (reg->alloc && reg->users)
> +		return -EBUSY;
> +
> +	if (!*page || *page == '\n') {
> +		s = NULL;
> +	} else {
> +		size_t len;
> +
> +		for (s = (char *)page; *++s && *s != '\n'; )
> +			/* nop */;
> +
> +		len = s - page;
> +		s = kmemdup(page, len + 1, GFP_KERNEL);
> +		if (!s)
> +			return -ENOMEM;
> +		s[len] = '\0';
> +	}
> +
> +	if (reg->alloc)
> +		__cma_region_detach_alloc(reg);
> +
> +	if (reg->free_alloc_name)
> +		kfree(reg->alloc_name);
> +
> +	reg->alloc_name = s;
> +	reg->free_alloc_name = !!s;
> +
> +	return 0;
> +}
> +
> +
> +static ssize_t
> +cma_sysfs_region_show(struct kobject *kobj, struct attribute *attr,
> +		      char *buf)
> +{
> +	struct cma_region *reg = container_of(kobj, struct cma_region, kobj);
> +	struct cma_region_attribute *rattr =
> +		container_of(attr, struct cma_region_attribute, attr);
> +	ssize_t ret;
> +
> +	mutex_lock(&cma_mutex);
> +	ret = rattr->show(reg, buf);
> +	mutex_unlock(&cma_mutex);
> +
> +	return ret;
> +}
> +
> +static int
> +cma_sysfs_region_store(struct kobject *kobj, struct attribute *attr,
> +		       const char *buf, size_t count)
> +{
> +	struct cma_region *reg = container_of(kobj, struct cma_region, kobj);
> +	struct cma_region_attribute *rattr =
> +		container_of(attr, struct cma_region_attribute, attr);
> +	int ret;
> +
> +	mutex_lock(&cma_mutex);
> +	ret = rattr->store(reg, buf);
> +	mutex_unlock(&cma_mutex);
> +
> +	return ret < 0 ? ret : count;
> +}
> +
> +static struct kobj_type cma_sysfs_region_type = {
> +	.sysfs_ops	= &(const struct sysfs_ops){
> +		.show	= cma_sysfs_region_show,
> +		.store	= cma_sysfs_region_store,
> +	},
> +	.default_attrs	= (struct attribute * []) {
> +		CMA_ATTR_RO_INLINE(region, name),
> +		CMA_ATTR_RO_INLINE(region, start),
> +		CMA_ATTR_RO_INLINE(region, size),
> +		CMA_ATTR_RO_INLINE(region, free),
> +		CMA_ATTR_RO_INLINE(region, users),
> +		CMA_ATTR_INLINE(region, alloc),
> +		NULL
> +	},
> +};

Again, broken by design, please fix.

> +
> +static void __cma_sysfs_region_add(struct cma_region *reg)
> +{
> +	int ret;
> +
> +	if (!cma_sysfs_regions_ready)
> +		return;
> +
> +	memset(&reg->kobj, 0, sizeof reg->kobj);
> +
> +	ret = kobject_init_and_add(&reg->kobj, &cma_sysfs_region_type,
> +				   &cma_sysfs_regions,
> +				   "%p", (void *)reg->start);
> +
> +	if (reg->name &&
> +	    sysfs_create_link(&cma_sysfs_regions, &reg->kobj, reg->name) < 0)
> +		/* Ignore any errors. */;

That's handy, why do you think the kernel is FORCING you to check the
return value of this function?  So you can then just ignore it?  It's as
if we add this code for absolutely no reason, sometimes I wonder why I
even bother...

In short, ick, ick, ick.

Oh, and go read the documentation, it's there for a reason.

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
