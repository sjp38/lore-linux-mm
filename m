Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 7CBD66B002B
	for <linux-mm@kvack.org>; Tue, 25 Dec 2012 10:32:45 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id un3so7297707obb.21
        for <linux-mm@kvack.org>; Tue, 25 Dec 2012 07:32:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAAvDA15U=KCOujRYA5k3YkvC9Z=E6fcG5hopPUJNgULYj_MAJw@mail.gmail.com>
References: <CAAvDA15U=KCOujRYA5k3YkvC9Z=E6fcG5hopPUJNgULYj_MAJw@mail.gmail.com>
Date: Wed, 26 Dec 2012 00:32:44 +0900
Message-ID: <CAAmzW4P-T3NC1E73KOFFExMJR3S5+iTX0MWJhLzXZsyykbtmDQ@mail.gmail.com>
Subject: Re: BUG: slub creates kmalloc slabs with refcount=0
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Hargrove <phhargrove@lbl.gov>
Cc: linux-mm@kvack.org

Hello, Paul.

2012/12/25 Paul Hargrove <phhargrove@lbl.gov>:
>
> I have a 3.7.1 kernel on x86-86
> It is configured with
>   CONFIG_SLUB=y
>   CONFIG_SLUB_DEBUG=y
>
> I have an out-of-tree module calling KMEM_CACHE for an 8-byte struct:
>         cr_pdata_cachep = KMEM_CACHE(cr_pdata_s,0);
>         if (!cr_pdata_cachep) goto no_pdata_cachep;
>         printk(KERN_ERR "@ refcount = %d name = '%s'\n",
> cr_pdata_cachep->refcount, cr_pdata_cachep->name);
>
> The output of the printk, below, shows that the request has been merged with
> the built-in 8-byte kmalloc pool, BUT the resulting refcount is 1, rather
> than 2 (or more):
>     @ refcount = 1 name = 'kmalloc-8'
>
> This results in a very unhappy kernel when the module calls
>     kmem_cache_destroy(cr_pdata_cachep);
> at rmmod time, resulting is messages like
>     BUG kmalloc-8 (Tainted: G           O): Objects remaining in kmalloc-96
> on kmem_cache_close()
>
> A quick look through mm/slub.c appears to confirm my suspicion that
> "s->refcount" is never incremented for the built-in kmalloc-* caches.
> However, I leave it to the experts to determine where the increment belongs.
>
> FWIW: I am currently passing SLAB_POISON for the flags argument to
> KMEM_CACHE() as a work-around (it prevents merging and, if I understand
> correctly, has no overhead in a non-debug build).
>
> -Paul
>
> --
> Paul H. Hargrove                          PHHargrove@lbl.gov
> Future Technologies Group
> Computer and Data Sciences Department     Tel: +1-510-495-2352
> Lawrence Berkeley National Laboratory     Fax: +1-510-486-6900

My e-mail client's 'Reply to message ID' is not working properly.
I sent a patch('slub:assign refcount for kmalloc_caches') for fixing
this and Cc'ed you.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
