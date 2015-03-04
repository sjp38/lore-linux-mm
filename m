Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f47.google.com (mail-qg0-f47.google.com [209.85.192.47])
	by kanga.kvack.org (Postfix) with ESMTP id 181FA6B0070
	for <linux-mm@kvack.org>; Wed,  4 Mar 2015 16:23:26 -0500 (EST)
Received: by qgaj5 with SMTP id j5so2024886qga.12
        for <linux-mm@kvack.org>; Wed, 04 Mar 2015 13:23:25 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id e37si4439443qgd.75.2015.03.04.13.23.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 04 Mar 2015 13:23:25 -0800 (PST)
Date: Wed, 4 Mar 2015 16:22:30 -0500
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH 0/4] cleancache: remove limit on the number of cleancache
 enabled filesystems
Message-ID: <20150304212230.GB18253@l.oracle.com>
References: <cover.1424628280.git.vdavydov@parallels.com>
 <20150223161222.GD30733@l.oracle.com>
 <20150224103406.GF16138@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150224103406.GF16138@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Vrabel <david.vrabel@citrix.com>, Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>, Stefan Hengelein <ilendir@googlemail.com>, Florian Schmaus <fschmaus@gmail.com>, Andor Daam <andor.daam@googlemail.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Bob Liu <lliubbo@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Feb 24, 2015 at 01:34:06PM +0300, Vladimir Davydov wrote:
> On Mon, Feb 23, 2015 at 11:12:22AM -0500, Konrad Rzeszutek Wilk wrote:
> > Thank you for posting these patches. I was wondering if you had
> > run through some of the different combinations that you can
> > load the filesystems/tmem drivers in random order? The #4 patch
> > deleted a nice chunk of documentation that outlines the different
> > combinations.
> 
> Yeah, I admit the synchronization between cleancache_register_ops and
> cleancache_init_fs is far not obvious. I should have updated the comment
> instead of merely dropping it, sorry. What about the following patch
> proving correctness of register_ops-vs-init_fs synchronization? It is
> meant to be applied incrementally on top of patch #4.

Just fold it in please. But more importantly - I was wondering if you
had run throught the different combinations it outlines?


> ---
> diff --git a/mm/cleancache.c b/mm/cleancache.c
> index fbdaf9c77d7a..8fc50811119b 100644
> --- a/mm/cleancache.c
> +++ b/mm/cleancache.c
> @@ -54,6 +54,57 @@ int cleancache_register_ops(struct cleancache_ops *ops)
>  	if (cmpxchg(&cleancache_ops, NULL, ops))
>  		return -EBUSY;
>  
> +	/*
> +	 * A cleancache backend can be built as a module and hence loaded after
> +	 * a cleancache enabled filesystem has called cleancache_init_fs. To
> +	 * handle such a scenario, here we call ->init_fs or ->init_shared_fs
> +	 * for each active super block. To differentiate between local and
> +	 * shared filesystems, we temporarily initialize sb->cleancache_poolid
> +	 * to CLEANCACHE_NO_BACKEND or CLEANCACHE_NO_BACKEND_SHARED
> +	 * respectively in case there is no backend registered at the time
> +	 * cleancache_init_fs or cleancache_init_shared_fs is called.
> +	 *
> +	 * Since filesystems can be mounted concurrently with cleancache
> +	 * backend registration, we have to be careful to guarantee that all
> +	 * cleancache enabled filesystems that has been mounted by the time
> +	 * cleancache_register_ops is called has got and all mounted later will
> +	 * get cleancache_poolid. This is assured by the following statements
> +	 * tied together:
> +	 *
> +	 * a) iterate_supers skips only those super blocks that has started
> +	 *    ->kill_sb
> +	 *
> +	 * b) if iterate_supers encounters a super block that has not finished
> +	 *    ->mount yet, it waits until it is finished
> +	 *
> +	 * c) cleancache_init_fs is called from ->mount and
> +	 *    cleancache_invalidate_fs is called from ->kill_sb
> +	 *
> +	 * d) we call iterate_supers after cleancache_ops has been set
> +	 *
> +	 * From a) it follows that if iterate_supers skips a super block, then
> +	 * either the super block is already dead, in which case we do not need
> +	 * to bother initializing cleancache for it, or it was mounted after we
> +	 * initiated iterate_supers. In the latter case, it must have seen
> +	 * cleancache_ops set according to d) and initialized cleancache from
> +	 * ->mount by itself according to c). This proves that we call
> +	 * ->init_fs at least once for each active super block.
> +	 *
> +	 * From b) and c) it follows that if iterate_supers encounters a super
> +	 * block that has already started ->init_fs, it will wait until ->mount
> +	 * and hence ->init_fs has finished, then check cleancache_poolid, see
> +	 * that it has already been set and therefore do nothing. This proves
> +	 * that we call ->init_fs no more than once for each super block.
> +	 *
> +	 * Combined together, the last two paragraphs prove the function
> +	 * correctness.
> +	 *
> +	 * Note that various cleancache callbacks may proceed before this
> +	 * function is called or even concurrently with it, but since
> +	 * CLEANCACHE_NO_BACKEND is negative, they will all result in a noop
> +	 * until the corresponding ->init_fs has been actually called and
> +	 * cleancache_ops has been set.
> +	 */
>  	iterate_supers(cleancache_register_ops_sb, NULL);
>  	return 0;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
