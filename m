Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id B3BBC6B005A
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 10:46:06 -0400 (EDT)
Message-ID: <501A92A8.7020909@parallels.com>
Date: Thu, 2 Aug 2012 18:46:00 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Common [00/16] Sl[auo]b: Common code rework V8
References: <20120801211130.025389154@linux.com> <501A3F1E.4060307@parallels.com> <alpine.DEB.2.00.1208020912340.23049@router.home> <501A8BE4.4060206@parallels.com> <alpine.DEB.2.00.1208020928200.23049@router.home>
In-Reply-To: <alpine.DEB.2.00.1208020928200.23049@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Joonsoo Kim <js1304@gmail.com>

On 08/02/2012 06:28 PM, Christoph Lameter wrote:
> On Thu, 2 Aug 2012, Glauber Costa wrote:
> 
>> Which is then the patchset's fault. Since as I said, my call order is:
>>
>> kmem_cache_create() -> kmem_cache_destroy().
>>
>> All allocs and frees are implicit.
>>
>> It also works okay both before the patches are applied, and with slab.
> 
> Are you creating two identical caches?
> 

In this example, yes. But note that I destroy in the between, so the
order is:

1) x = kmem_cache_create(...)
2) kmem_cache_destroy(x);
3) x = kmem_cache_create(...)

I am doing this way so I can be sure my slab memcg is not involved.
The first time I came across this, was while testing that code. In that
environment, the sequence would be:

1) create a cgroup.
2) delete that cgroup
3) create another cgroup.

In that scenario, we create a bunch of other caches. All of them differ
at least in names, since we append the memcg name to the end of the cache.

Also, on the interest of ruling out the "equal caches" hypotheses, I am
now creating a second cache that bears no relation whatsoever to the
first one I deleted. Problem persists.

Although this is not guaranteed, the fact that it works with slab and
after this series they look alike a lot more, may point out to aliasing
as the cause of this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
