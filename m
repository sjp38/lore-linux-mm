Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id C0B506B004D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 10:19:29 -0400 (EDT)
Message-ID: <5017E8C3.1040004@parallels.com>
Date: Tue, 31 Jul 2012 18:16:35 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Common [13/20] Extract a common function for kmem_cache_destroy
References: <20120601195245.084749371@linux.com> <20120601195307.063633659@linux.com> <5017C90E.7060706@parallels.com> <alpine.DEB.2.00.1207310910580.32295@router.home>
In-Reply-To: <alpine.DEB.2.00.1207310910580.32295@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>

On 07/31/2012 06:12 PM, Christoph Lameter wrote:
> On Tue, 31 Jul 2012, Glauber Costa wrote:
> 
>> Problem is that you are now allocating objects from kmem_cache with
>> kmem_cache_alloc, but freeing it with kfree - and in multiple locations.
> 
> Why would this be an issue"?

I believe consistency wins here. Since the kmalloc cache can be
different in many ways from the normal caches in their paths, we should
use the corresponding free functions for those. But perhaps I shouldn't
even have mentioned that, since this is, as I explained below, the real
root issue, and confused the report...

>> In particular, after the whole series is applied, you will have a call
>> to "kfree(s)" in sysfs_slab_remove() that is called from
>> kmem_cache_shutdown(), and later on kmem_cache_free(kmem_cache, s) from
>> the destruction common code -> a double free.
> 
> I will look at that but I have already reworked the patches a couple of
> times since then. I hope to be able to post an updated series against
> upstream at the end of the week (before the next conference).
> 

Unfortunately, that wasn't the only problem as well. I am not yet able
to pinpoint the correct source, but we're handling cache deletion very
poorly after this series.

Since you said you had reworked this, I'll just stop looking for now.
But would you please make sure that this following use case is well
tested before you send?

1) After machine is up, create a bogus cache
2) free that cache right away.
3) Create two more caches.

The creation of the second cache fails, because
kmem_cache_alloc(kmem_cache, x) returns bad values. Those bad values can
take multiple forms, but the most common is a value that is equal to an
already assigned value.

I am creating caches for the following objects to demonstrate that:

struct bgb {
        struct dentry d;
        int a;
        int b;
        int c;
};

struct bgb2 {
        struct dentry d;
        struct inode i;
        int a;
        int b;
        int c;
};

But this shouldn't matter at all, I am just posting so you can rule out
any size or merging related issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
