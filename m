Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 227CB6B0081
	for <linux-mm@kvack.org>; Wed, 23 May 2012 09:53:32 -0400 (EDT)
Date: Wed, 23 May 2012 08:53:29 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2] slab+slob: dup name string
In-Reply-To: <alpine.DEB.2.00.1205222048380.28165@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1205230849410.29893@router.home>
References: <1337680298-11929-1-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1205220857380.17600@router.home> <alpine.DEB.2.00.1205222048380.28165@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>

On Tue, 22 May 2012, David Rientjes wrote:

> On Tue, 22 May 2012, Christoph Lameter wrote:
>
> > > [ v2: Also dup string for early caches, requested by David Rientjes ]
> >
> > kstrdups that early could cause additional issues. Its better to leave
> > things as they were.
> >
>
> No, it's not, there's no reason to prevent caches created before
> g_cpucache_up <= EARLY to be destroyed because it makes a patch easier to
> implement and then leave that little gotcha as an undocumented treasure
> for someone to find when they try it later on.

g_cpucache_up <= EARLY is slab bootstrap code and the system is in a
pretty fragile state. Plus the the kmalloc logic *depends* on these
caches being present. Removing those is not a good idea. The other caches
that are created at that point are needed to create more caches.

There is no reason to remove these caches.

> This is much easier to do, just statically allocate the const char *'s
> needed for the boot caches and then set their ->name's manually in
> kmem_cache_init() and then avoid the kfree() in kmem_cache_destroy() if
> the name is between &boot_cache_name[0] and &boot_cache_name[n].

Yeah that is already occurring for some of the boot caches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
