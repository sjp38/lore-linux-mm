Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1B1F86B0072
	for <linux-mm@kvack.org>; Thu, 10 Nov 2011 01:18:27 -0500 (EST)
Subject: Re: [patch 1/5]thp: improve the error code path
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <alpine.DEB.2.00.1111092205400.2384@chino.kir.corp.google.com>
References: <1319511521.22361.135.camel@sli10-conroe>
	 <20111025114406.GC10182@redhat.com>
	 <1319593680.22361.145.camel@sli10-conroe>
	 <1320643049.22361.204.camel@sli10-conroe>
	 <20111110021853.GQ5075@redhat.com>
	 <1320892395.22361.229.camel@sli10-conroe>
	 <alpine.DEB.2.00.1111091828500.32414@chino.kir.corp.google.com>
	 <20111110030646.GT5075@redhat.com>
	 <alpine.DEB.2.00.1111092039110.27280@chino.kir.corp.google.com>
	 <1320904609.22361.239.camel@sli10-conroe>
	 <alpine.DEB.2.00.1111092205400.2384@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 10 Nov 2011 14:27:35 +0800
Message-ID: <1320906455.22361.243.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Thu, 2011-11-10 at 14:08 +0800, David Rientjes wrote:
> On Thu, 10 Nov 2011, Shaohua Li wrote:
> 
> > Index: linux/mm/huge_memory.c
> > ===================================================================
> > --- linux.orig/mm/huge_memory.c	2011-11-07 13:52:48.000000000 +0800
> > +++ linux/mm/huge_memory.c	2011-11-10 13:52:08.000000000 +0800
> > @@ -487,41 +487,68 @@ static struct attribute_group khugepaged
> >  	.attrs = khugepaged_attr,
> >  	.name = "khugepaged",
> >  };
> > -#endif /* CONFIG_SYSFS */
> >  
> > -static int __init hugepage_init(void)
> > +static struct kobject *hugepage_kobj;
> > +static int __init hugepage_init_sysfs(void)
> >  {
> >  	int err;
> > -#ifdef CONFIG_SYSFS
> > -	static struct kobject *hugepage_kobj;
> > -#endif
> >  
> > -	err = -EINVAL;
> > -	if (!has_transparent_hugepage()) {
> > -		transparent_hugepage_flags = 0;
> > -		goto out;
> > -	}
> > -
> > -#ifdef CONFIG_SYSFS
> > -	err = -ENOMEM;
> >  	hugepage_kobj = kobject_create_and_add("transparent_hugepage", mm_kobj);
> >  	if (unlikely(!hugepage_kobj)) {
> >  		printk(KERN_ERR "hugepage: failed kobject create\n");
> > -		goto out;
> > +		return -ENOMEM;
> >  	}
> >  
> >  	err = sysfs_create_group(hugepage_kobj, &hugepage_attr_group);
> >  	if (err) {
> >  		printk(KERN_ERR "hugepage: failed register hugeage group\n");
> > -		goto out;
> > +		goto delete_obj;
> >  	}
> >  
> >  	err = sysfs_create_group(hugepage_kobj, &khugepaged_attr_group);
> >  	if (err) {
> >  		printk(KERN_ERR "hugepage: failed register hugeage group\n");
> > -		goto out;
> > +		goto remove_hp_group;
> >  	}
> > -#endif
> > +
> > +	return 0;
> > +
> > +remove_hp_group:
> > +	sysfs_remove_group(hugepage_kobj, &hugepage_attr_group);
> > +delete_obj:
> > +	kobject_put(hugepage_kobj);
> > +	return err;
> > +}
> > +
> > +static void __init hugepage_exit_sysfs(void)
> > +{
> > +	sysfs_remove_group(hugepage_kobj, &khugepaged_attr_group);
> > +	sysfs_remove_group(hugepage_kobj, &hugepage_attr_group);
> > +	kobject_put(hugepage_kobj);
> > +}
> 
> As mentioned previously, if khugepaged_slab_init() and 
> mm_slots_hash_init() is done first before sysfs is initialized, then you 
> shouldn't need hugepage_exit_sysfs() at all; all its error handling should 
> be localized to hugepage_init().
then we just move some error handling code to hugepage_init(). It
doesn't mean this one is better or that one is better, but I really see
no point to refresh the patch again.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
