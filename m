Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id E0CB26B00F0
	for <linux-mm@kvack.org>; Tue, 22 May 2012 23:55:55 -0400 (EDT)
Received: by dakp5 with SMTP id p5so13089240dak.14
        for <linux-mm@kvack.org>; Tue, 22 May 2012 20:55:55 -0700 (PDT)
Date: Tue, 22 May 2012 20:55:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] slab+slob: dup name string
In-Reply-To: <alpine.DEB.2.00.1205220857380.17600@router.home>
Message-ID: <alpine.DEB.2.00.1205222048380.28165@chino.kir.corp.google.com>
References: <1337680298-11929-1-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1205220857380.17600@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>

On Tue, 22 May 2012, Christoph Lameter wrote:

> > [ v2: Also dup string for early caches, requested by David Rientjes ]
> 
> kstrdups that early could cause additional issues. Its better to leave
> things as they were.
> 

No, it's not, there's no reason to prevent caches created before 
g_cpucache_up <= EARLY to be destroyed because it makes a patch easier to 
implement and then leave that little gotcha as an undocumented treasure 
for someone to find when they try it later on.

I hate consistency patches like this because it could potentially fail a 
kmem_cache_create() from a sufficiently long cache name when it wouldn't 
have before, but I'm not really concerned since kmem_cache_create() will 
naturally be followed by kmem_cache_alloc() which is more likely to cause 
the oom anyway.  But it's just another waste of memory for consistency 
sake.

This is much easier to do, just statically allocate the const char *'s 
needed for the boot caches and then set their ->name's manually in 
kmem_cache_init() and then avoid the kfree() in kmem_cache_destroy() if 
the name is between &boot_cache_name[0] and &boot_cache_name[n].

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
