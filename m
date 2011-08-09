Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 315316B016D
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 08:25:44 -0400 (EDT)
Message-Id: <4E41439D0200007800050581@nat28.tlf.novell.com>
Date: Tue, 09 Aug 2011 13:26:37 +0100
From: "Jan Beulich" <JBeulich@novell.com>
Subject: Re: Subject: [PATCH V6 2/4] mm: frontswap: core code
References: <20110808204615.GA15864@ca-server1.us.oracle.com>
In-Reply-To: <20110808204615.GA15864@ca-server1.us.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: hannes@cmpxchg.org, jackdachef@gmail.com, hughd@google.com, jeremy@goop.org, npiggin@kernel.dk, linux-mm@kvack.org, akpm@linux-foundation.org, sjenning@linux.vnet.ibm.com, chris.mason@oracle.com, konrad.wilk@oracle.com, kurt.hackel@oracle.com, riel@redhat.com, ngupta@vflare.org, linux-kernel@vger.kernel.org, matthew@wil.cx

>>> On 08.08.11 at 22:46, Dan Magenheimer <dan.magenheimer@oracle.com> =
wrote:
> From: Dan Magenheimer <dan.magenheimer@oracle.com>
> Subject: [PATCH V6 2/4] mm: frontswap: core code
>=20
> This second patch of four in this frontswap series provides the core =
code
> for frontswap that interfaces between the hooks in the swap subsystem =
and
> a frontswap backend via frontswap_ops.
>=20
> Two new files are added: mm/frontswap.c and include/linux/frontswap.h
>=20
> Credits: Frontswap_ops design derived from Jeremy Fitzhardinge
> design for tmem; sysfs code modelled after mm/ksm.c
>=20
> [v6: rebase to 3.1-rc1]
> [v6: lliubbo@gmail.com: fix null pointer deref if vzalloc fails]
> [v6: konrad.wilk@oracl.com: various checks and code clarifications/commen=
ts]
> [v5: no change from v4]
> [v4: rebase to 2.6.39]
> Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
> Reviewed-by: Konrad Wilk <konrad.wilk@oracle.com>
> Acked-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> Cc: Jeremy Fitzhardinge <jeremy@goop.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Nitin Gupta <ngupta@vflare.org>
> Cc: Matthew Wilcox <matthew@wil.cx>
> Cc: Chris Mason <chris.mason@oracle.com>
> Cc: Jan Beulich <JBeulich@novell.com>
> Cc: Rik Riel <riel@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
>=20
> --- linux/include/linux/frontswap.h	1969-12-31 17:00:00.000000000 =
-0700
> +++ frontswap/include/linux/frontswap.h	2011-08-08 08:59:08.8426938=
87 -0600
> @@ -0,0 +1,92 @@
> +#ifndef _LINUX_FRONTSWAP_H
> +#define _LINUX_FRONTSWAP_H
> +
> +#include <linux/swap.h>
> +#include <linux/mm.h>
> +
> +struct frontswap_ops {
> +	void (*init)(unsigned);
> +	int (*put_page)(unsigned, pgoff_t, struct page *);
> +	int (*get_page)(unsigned, pgoff_t, struct page *);
> +	void (*flush_page)(unsigned, pgoff_t);
> +	void (*flush_area)(unsigned);
> +};
> +
> +extern int frontswap_enabled;
> +extern struct frontswap_ops
> +	frontswap_register_ops(struct frontswap_ops *ops);
> +extern void frontswap_shrink(unsigned long);
> +extern unsigned long frontswap_curr_pages(void);
> +
> +extern void __frontswap_init(unsigned type);
> +extern int __frontswap_put_page(struct page *page);
> +extern int __frontswap_get_page(struct page *page);
> +extern void __frontswap_flush_page(unsigned, pgoff_t);
> +extern void __frontswap_flush_area(unsigned);
> +
> +#ifndef CONFIG_FRONTSWAP
> +/* all inline routines become no-ops and all externs are ignored */
> +#define frontswap_enabled (0)
> +#endif
> +
> +static inline int frontswap_test(struct swap_info_struct *sis, =
pgoff_t=20
> offset)
> +{
> +	int ret =3D 0;
> +
> +	if (frontswap_enabled && sis->frontswap_map)
> +		ret =3D test_bit(offset % BITS_PER_LONG,
> +			&sis->frontswap_map[offset/BITS_PER_LONG]);

	if (sis->frontswap_map)
		ret =3D test_bit(offset, sis->frontswap_map);

(since sis->frontswap_map can't be non-NULL without
frontswap_enabled being true, and since test_bit() itself already
does what you open-coded here.

> +	return ret;
> +}
> +
> +static inline void frontswap_set(struct swap_info_struct *sis, =
pgoff_t=20
> offset)
> +{
> +	if (frontswap_enabled && sis->frontswap_map)
> +		set_bit(offset % BITS_PER_LONG,
> +			&sis->frontswap_map[offset/BITS_PER_LONG]);

Similarly here ...

> +}
> +
> +static inline void frontswap_clear(struct swap_info_struct *sis, =
pgoff_t=20
> offset)
> +{
> +	if (frontswap_enabled && sis->frontswap_map)
> +		clear_bit(offset % BITS_PER_LONG,
> +			&sis->frontswap_map[offset/BITS_PER_LONG]);

and here.

Jan

> +}
> +
> +static inline int frontswap_put_page(struct page *page)
> +{
> +	int ret =3D -1;
> +
> +	if (frontswap_enabled)
> +		ret =3D __frontswap_put_page(page);
> +	return ret;
> +}
> +
> +static inline int frontswap_get_page(struct page *page)
> +{
> +	int ret =3D -1;
> +
> +	if (frontswap_enabled)
> +		ret =3D __frontswap_get_page(page);
> +	return ret;
> +}
> +
> +static inline void frontswap_flush_page(unsigned type, pgoff_t offset)
> +{
> +	if (frontswap_enabled)
> +		__frontswap_flush_page(type, offset);
> +}
> +
> +static inline void frontswap_flush_area(unsigned type)
> +{
> +	if (frontswap_enabled)
> +		__frontswap_flush_area(type);
> +}
> +
> +static inline void frontswap_init(unsigned type)
> +{
> +	if (frontswap_enabled)
> +		__frontswap_init(type);
> +}
> +
> +#endif /* _LINUX_FRONTSWAP_H */
> --- linux/mm/frontswap.c	1969-12-31 17:00:00.000000000 -0700
> +++ frontswap/mm/frontswap.c	2011-08-08 10:27:42.676687669 -0600
> @@ -0,0 +1,346 @@
> +/*
> + * Frontswap frontend
> + *
> + * This code provides the generic "frontend" layer to call a matching
> + * "backend" driver implementation of frontswap.  See
> + * Documentation/vm/frontswap.txt for more information.
> + *
> + * Copyright (C) 2009-2010 Oracle Corp.  All rights reserved.
> + * Author: Dan Magenheimer
> + *
> + * This work is licensed under the terms of the GNU GPL, version 2.
> + */
> +
> +#include <linux/mm.h>
> +#include <linux/mman.h>
> +#include <linux/sysctl.h>
> +#include <linux/swap.h>
> +#include <linux/swapops.h>
> +#include <linux/proc_fs.h>
> +#include <linux/security.h>
> +#include <linux/capability.h>
> +#include <linux/module.h>
> +#include <linux/uaccess.h>
> +#include <linux/frontswap.h>
> +#include <linux/swapfile.h>
> +
> +/*
> + * frontswap_ops is set by frontswap_register_ops to contain the =
pointers
> + * to the frontswap "backend" implementation functions.
> + */
> +static struct frontswap_ops frontswap_ops;
> +
> +/*
> + * This global enablement flag reduces overhead on systems where=20
> frontswap_ops
> + * has not been registered, so is preferred to the slower alternative: =
a
> + * function call that checks a non-global.
> + */
> +int frontswap_enabled;
> +EXPORT_SYMBOL(frontswap_enabled);
> +
> +/* useful stats available in /sys/kernel/mm/frontswap */
> +static unsigned long frontswap_gets;
> +static unsigned long frontswap_succ_puts;
> +static unsigned long frontswap_failed_puts;
> +static unsigned long frontswap_flushes;
> +
> +/*
> + * register operations for frontswap, returning previous thus allowing
> + * detection of multiple backends and possible nesting
> + */
> +struct frontswap_ops frontswap_register_ops(struct frontswap_ops *ops)
> +{
> +	struct frontswap_ops old =3D frontswap_ops;
> +
> +	frontswap_ops =3D *ops;
> +	frontswap_enabled =3D 1;
> +	return old;
> +}
> +EXPORT_SYMBOL(frontswap_register_ops);
> +
> +/* Called when a swap device is swapon'd */
> +void __frontswap_init(unsigned type)
> +{
> +	struct swap_info_struct *sis =3D swap_info[type];
> +
> +	BUG_ON(sis =3D=3D NULL);
> +	if (sis->frontswap_map =3D=3D NULL)
> +		return;
> +	if (frontswap_enabled)
> +		(*frontswap_ops.init)(type);
> +}
> +EXPORT_SYMBOL(__frontswap_init);
> +
> +/*
> + * "Put" data from a page to frontswap and associate it with the page's
> + * swaptype and offset.  Page must be locked and in the swap cache.
> + * If frontswap already contains a page with matching swaptype and
> + * offset, the frontswap implmentation may either overwrite the data
> + * and return success or flush the page from frontswap and return =
failure
> + */
> +int __frontswap_put_page(struct page *page)
> +{
> +	int ret =3D -1, dup =3D 0;
> +	swp_entry_t entry =3D { .val =3D page_private(page), };
> +	int type =3D swp_type(entry);
> +	struct swap_info_struct *sis =3D swap_info[type];
> +	pgoff_t offset =3D swp_offset(entry);
> +
> +	BUG_ON(!PageLocked(page));
> +	BUG_ON(sis =3D=3D NULL);
> +	if (frontswap_test(sis, offset))
> +		dup =3D 1;
> +	ret =3D (*frontswap_ops.put_page)(type, offset, page);
> +	if (ret =3D=3D 0) {
> +		frontswap_set(sis, offset);
> +		frontswap_succ_puts++;
> +		if (!dup)
> +			sis->frontswap_pages++;
> +	} else if (dup) {
> +		/*
> +		  failed dup always results in automatic flush of
> +		  the (older) page from frontswap
> +		 */
> +		frontswap_clear(sis, offset);
> +		sis->frontswap_pages--;
> +		frontswap_failed_puts++;
> +	} else
> +		frontswap_failed_puts++;
> +	return ret;
> +}
> +EXPORT_SYMBOL(__frontswap_put_page);
> +
> +/*
> + * "Get" data from frontswap associated with swaptype and offset that =
were
> + * specified when the data was put to frontswap and use it to fill the
> + * specified page with data. Page must be locked and in the swap cache
> + */
> +int __frontswap_get_page(struct page *page)
> +{
> +	int ret =3D -1;
> +	swp_entry_t entry =3D { .val =3D page_private(page), };
> +	int type =3D swp_type(entry);
> +	struct swap_info_struct *sis =3D swap_info[type];
> +	pgoff_t offset =3D swp_offset(entry);
> +
> +	BUG_ON(!PageLocked(page));
> +	BUG_ON(sis =3D=3D NULL);
> +	if (frontswap_test(sis, offset))
> +		ret =3D (*frontswap_ops.get_page)(type, offset, page);
> +	if (ret =3D=3D 0)
> +		frontswap_gets++;
> +	return ret;
> +}
> +EXPORT_SYMBOL(__frontswap_get_page);
> +
> +/*
> + * Flush any data from frontswap associated with the specified swaptype
> + * and offset so that a subsequent "get" will fail.
> + */
> +void __frontswap_flush_page(unsigned type, pgoff_t offset)
> +{
> +	struct swap_info_struct *sis =3D swap_info[type];
> +
> +	BUG_ON(sis =3D=3D NULL);
> +	if (frontswap_test(sis, offset)) {
> +		(*frontswap_ops.flush_page)(type, offset);
> +		sis->frontswap_pages--;
> +		frontswap_clear(sis, offset);
> +		frontswap_flushes++;
> +	}
> +}
> +EXPORT_SYMBOL(__frontswap_flush_page);
> +
> +/*
> + * Flush all data from frontswap associated with all offsets for the
> + * specified swaptype.
> + */
> +void __frontswap_flush_area(unsigned type)
> +{
> +	struct swap_info_struct *sis =3D swap_info[type];
> +
> +	BUG_ON(sis =3D=3D NULL);
> +	if (sis->frontswap_map =3D=3D NULL)
> +		return;
> +	(*frontswap_ops.flush_area)(type);
> +	sis->frontswap_pages =3D 0;
> +	memset(sis->frontswap_map, 0, sis->max / sizeof(long));
> +}
> +EXPORT_SYMBOL(__frontswap_flush_area);
> +
> +/*
> + * Frontswap, like a true swap device, may unnecessarily retain pages
> + * under certain circumstances; "shrink" frontswap is essentially a
> + * "partial swapoff" and works by calling try_to_unuse to attempt to
> + * unuse enough frontswap pages to attempt to -- subject to memory
> + * constraints -- reduce the number of pages in frontswap
> + */
> +void frontswap_shrink(unsigned long target_pages)
> +{
> +	int wrapped =3D 0;
> +	bool locked =3D false;
> +
> +	/* try a few times to maximize chance of try_to_unuse success */
> +	for (wrapped =3D 0; wrapped < 3; wrapped++) {
> +
> +		struct swap_info_struct *si =3D NULL;
> +		unsigned long total_pages =3D 0, total_pages_to_unuse;
> +		unsigned long pages =3D 0, pages_to_unuse =3D 0;
> +		int type;
> +
> +		/*
> +		 * we don't want to hold swap_lock while doing a very
> +		 * lengthy try_to_unuse, but swap_list may change
> +		 * so restart scan from swap_list.head each time
> +		 */
> +		spin_lock(&swap_lock);
> +		locked =3D true;
> +		total_pages =3D 0;
> +		for (type =3D swap_list.head; type >=3D 0; type =3D =
si->next) {
> +			si =3D swap_info[type];
> +			total_pages +=3D si->frontswap_pages;
> +		}
> +		if (total_pages <=3D target_pages)
> +			goto out;
> +		total_pages_to_unuse =3D total_pages - target_pages;
> +		for (type =3D swap_list.head; type >=3D 0; type =3D =
si->next) {
> +			si =3D swap_info[type];
> +			if (total_pages_to_unuse < si->frontswap_pages)
> +				pages =3D pages_to_unuse =3D total_pages_to=
_unuse;
> +			else {
> +				pages =3D si->frontswap_pages;
> +				pages_to_unuse =3D 0; /* unuse all */
> +			}
> +			if (security_vm_enough_memory_kern(pages))
> +				continue;
> +			vm_unacct_memory(pages);
> +			break;
> +		}
> +		if (type < 0)
> +			goto out;
> +		locked =3D false;
> +		spin_unlock(&swap_lock);
> +		try_to_unuse(type, true, pages_to_unuse);
> +	}
> +
> +out:
> +	if (locked)
> +		spin_unlock(&swap_lock);
> +	return;
> +}
> +EXPORT_SYMBOL(frontswap_shrink);
> +
> +/*
> + * count and return the number of pages frontswap pages across all
> + * swap devices.  This is exported so that a kernel module can
> + * determine current usage without reading sysfs.
> + */
> +unsigned long frontswap_curr_pages(void)
> +{
> +	int type;
> +	unsigned long totalpages =3D 0;
> +	struct swap_info_struct *si =3D NULL;
> +
> +	spin_lock(&swap_lock);
> +	for (type =3D swap_list.head; type >=3D 0; type =3D si->next) {
> +		si =3D swap_info[type];
> +		if (si !=3D NULL)
> +			totalpages +=3D si->frontswap_pages;
> +	}
> +	spin_unlock(&swap_lock);
> +	return totalpages;
> +}
> +EXPORT_SYMBOL(frontswap_curr_pages);
> +
> +#ifdef CONFIG_SYSFS
> +
> +/* see Documentation/ABI/xxx/sysfs-kernel-mm-frontswap */
> +
> +#define FRONTSWAP_ATTR_RO(_name) \
> +	static struct kobj_attribute _name##_attr =3D __ATTR_RO(_name)
> +#define FRONTSWAP_ATTR(_name) \
> +	static struct kobj_attribute _name##_attr =3D \
> +		__ATTR(_name, 0644, _name##_show, _name##_store)
> +
> +static ssize_t curr_pages_show(struct kobject *kobj,
> +			       struct kobj_attribute *attr, char *buf)
> +{
> +	return sprintf(buf, "%lu\n", frontswap_curr_pages());
> +}
> +
> +static ssize_t curr_pages_store(struct kobject *kobj,
> +			       struct kobj_attribute *attr,
> +			       const char *buf, size_t count)
> +{
> +	unsigned long target_pages;
> +
> +	if (strict_strtoul(buf, 10, &target_pages))
> +		return -EINVAL;
> +
> +	frontswap_shrink(target_pages);
> +
> +	return count;
> +}
> +FRONTSWAP_ATTR(curr_pages);
> +
> +static ssize_t succ_puts_show(struct kobject *kobj,
> +			       struct kobj_attribute *attr, char *buf)
> +{
> +	return sprintf(buf, "%lu\n", frontswap_succ_puts);
> +}
> +FRONTSWAP_ATTR_RO(succ_puts);
> +
> +static ssize_t failed_puts_show(struct kobject *kobj,
> +			       struct kobj_attribute *attr, char *buf)
> +{
> +	return sprintf(buf, "%lu\n", frontswap_failed_puts);
> +}
> +FRONTSWAP_ATTR_RO(failed_puts);
> +
> +static ssize_t gets_show(struct kobject *kobj,
> +			       struct kobj_attribute *attr, char *buf)
> +{
> +	return sprintf(buf, "%lu\n", frontswap_gets);
> +}
> +FRONTSWAP_ATTR_RO(gets);
> +
> +static ssize_t flushes_show(struct kobject *kobj,
> +			       struct kobj_attribute *attr, char *buf)
> +{
> +	return sprintf(buf, "%lu\n", frontswap_flushes);
> +}
> +FRONTSWAP_ATTR_RO(flushes);
> +
> +static struct attribute *frontswap_attrs[] =3D {
> +	&curr_pages_attr.attr,
> +	&succ_puts_attr.attr,
> +	&failed_puts_attr.attr,
> +	&gets_attr.attr,
> +	&flushes_attr.attr,
> +	NULL,
> +};
> +
> +static struct attribute_group frontswap_attr_group =3D {
> +	.attrs =3D frontswap_attrs,
> +	.name =3D "frontswap",
> +};
> +
> +#endif /* CONFIG_SYSFS */
> +
> +static int __init init_frontswap(void)
> +{
> +	int err =3D 0;
> +
> +#ifdef CONFIG_SYSFS
> +	err =3D sysfs_create_group(mm_kobj, &frontswap_attr_group);
> +#endif /* CONFIG_SYSFS */
> +	return err;
> +}
> +
> +static void __exit exit_frontswap(void)
> +{
> +	frontswap_shrink(0UL);
> +}
> +
> +module_init(init_frontswap);
> +module_exit(exit_frontswap);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
