Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 5B8566B024D
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 03:00:21 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6K70H9t013321
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 20 Jul 2010 16:00:18 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EC4E645DE4F
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 16:00:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A90A145DE52
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 16:00:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 701101DB805F
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 16:00:16 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 18C721DB8057
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 16:00:16 +0900 (JST)
Date: Tue, 20 Jul 2010 15:55:02 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/8] v3 Move the find_memory_block() routine up
Message-Id: <20100720155502.17242173.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4C451D4E.8040600@austin.ibm.com>
References: <4C451BF5.50304@austin.ibm.com>
	<4C451D4E.8040600@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nathan Fontenot <nfont@austin.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org, greg@kroah.com
List-ID: <linux-mm.kvack.org>

On Mon, 19 Jul 2010 22:51:42 -0500
Nathan Fontenot <nfont@austin.ibm.com> wrote:

> Move the find_me mory_block() routine up to avoid needing a forward
> declaration in subsequent patches.
> 
> Signed-off-by: Nathan Fontenot <nfont@austin.ibm.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
>  drivers/base/memory.c |   62 +++++++++++++++++++++++++-------------------------
>  1 file changed, 31 insertions(+), 31 deletions(-)
> 
> Index: linux-2.6/drivers/base/memory.c
> ===================================================================
> --- linux-2.6.orig/drivers/base/memory.c	2010-07-16 12:41:30.000000000 -0500
> +++ linux-2.6/drivers/base/memory.c	2010-07-19 20:42:11.000000000 -0500
> @@ -435,6 +435,37 @@ int __weak arch_get_memory_phys_device(u
>  	return 0;
>  }
>  
> +/*
> + * For now, we have a linear search to go find the appropriate
> + * memory_block corresponding to a particular phys_index. If
> + * this gets to be a real problem, we can always use a radix
> + * tree or something here.
> + *
> + * This could be made generic for all sysdev classes.
> + */
> +struct memory_block *find_memory_block(struct mem_section *section)
> +{
> +	struct kobject *kobj;
> +	struct sys_device *sysdev;
> +	struct memory_block *mem;
> +	char name[sizeof(MEMORY_CLASS_NAME) + 9 + 1];
> +
> +	/*
> +	 * This only works because we know that section == sysdev->id
> +	 * slightly redundant with sysdev_register()
> +	 */
> +	sprintf(&name[0], "%s%d", MEMORY_CLASS_NAME, __section_nr(section));
> +
> +	kobj = kset_find_obj(&memory_sysdev_class.kset, name);
> +	if (!kobj)
> +		return NULL;
> +
> +	sysdev = container_of(kobj, struct sys_device, kobj);
> +	mem = container_of(sysdev, struct memory_block, sysdev);
> +
> +	return mem;
> +}
> +
>  static int add_memory_block(int nid, struct mem_section *section,
>  			unsigned long state, enum mem_add_context context)
>  {
> @@ -468,37 +499,6 @@ static int add_memory_block(int nid, str
>  	return ret;
>  }
>  
> -/*
> - * For now, we have a linear search to go find the appropriate
> - * memory_block corresponding to a particular phys_index. If
> - * this gets to be a real problem, we can always use a radix
> - * tree or something here.
> - *
> - * This could be made generic for all sysdev classes.
> - */
> -struct memory_block *find_memory_block(struct mem_section *section)
> -{
> -	struct kobject *kobj;
> -	struct sys_device *sysdev;
> -	struct memory_block *mem;
> -	char name[sizeof(MEMORY_CLASS_NAME) + 9 + 1];
> -
> -	/*
> -	 * This only works because we know that section == sysdev->id
> -	 * slightly redundant with sysdev_register()
> -	 */
> -	sprintf(&name[0], "%s%d", MEMORY_CLASS_NAME, __section_nr(section));
> -
> -	kobj = kset_find_obj(&memory_sysdev_class.kset, name);
> -	if (!kobj)
> -		return NULL;
> -
> -	sysdev = container_of(kobj, struct sys_device, kobj);
> -	mem = container_of(sysdev, struct memory_block, sysdev);
> -
> -	return mem;
> -}
> -
>  int remove_memory_block(unsigned long node_id, struct mem_section *section,
>  		int phys_device)
>  {
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
