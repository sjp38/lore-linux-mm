Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id CFFCD6B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 17:12:35 -0500 (EST)
From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Hung task when calling clone() due to netfilter/slab
References: <1326558605.19951.7.camel@lappy>
	<1326561043.5287.24.camel@edumazet-laptop>
	<1326632384.11711.3.camel@lappy>
	<1326648305.5287.78.camel@edumazet-laptop>
	<alpine.DEB.2.00.1201170910130.4800@router.home>
	<1326813630.2259.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<alpine.DEB.2.00.1201170927020.4800@router.home>
	<1326814208.2259.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<alpine.DEB.2.00.1201170942240.4800@router.home>
	<alpine.DEB.2.00.1201171620590.14697@router.home>
	<m1bopz2ws3.fsf@fess.ebiederm.org>
Date: Thu, 19 Jan 2012 14:15:01 -0800
In-Reply-To: <m1bopz2ws3.fsf@fess.ebiederm.org> (Eric W. Biederman's message
	of "Thu, 19 Jan 2012 13:43:40 -0800")
Message-ID: <m14nvr2vbu.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Sasha Levin <levinsasha928@gmail.com>, Dave Jones <davej@redhat.com>, davem <davem@davemloft.net>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, kaber@trash.net, pablo@netfilter.org, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>

ebiederm@xmission.com (Eric W. Biederman) writes:

> Christoph Lameter <cl@linux.com> writes:
>
>> Another version that drops the slub lock for both invocations of sysfs
>> functions from kmem_cache_create. The invocation from slab_sysfs_init
>> is not a problem since user space is not active at that point.
>>
>>
>> Subject: slub: Do not take the slub lock while calling into sysfs
>>
>> This patch avoids holding the slub_lock during kmem_cache_create()
>> when calling sysfs. It is possible because kmem_cache_create()
>> allocates the kmem_cache object and therefore is the only one context
>> that can access the newly created object. It is therefore possible
>> to drop the slub_lock early. We defer the adding of the new kmem_cache
>> to the end of processing because the new kmem_cache structure would
>> be reachable otherwise via scans over slabs. This allows sysfs_slab_add()
>> to run without holding any locks.
>>
>> The case is different if we are creating an alias instead of a new
>> kmem_cache structure. In that case we can also drop the slub lock
>> early because we have taken a refcount on the kmem_cache structure.
>> It therefore cannot vanish from under us.
>> But if the sysfs_slab_alias() call fails we can no longer simply
>> decrement the refcount since the other references may have gone
>> away in the meantime. Call kmem_cache_destroy() to cause the
>> refcount to be decremented and the kmem_cache structure to be
>> freed if all references are gone.
>>
>> Signed-off-by: Christoph Lameter <cl@linux.com>
>
> I am dense.  Is the deadlock here that you are fixing slub calling sysfs
> with the slub_lock held but sysfs then calling kmem_cache_zalloc?
>
> I don't see what sysfs is doing in the creation path that would cause
> a deadlock except for using slab.

Oh.  I see.  The problem is calling kobject_uevent (which happens to
live in slabs sysfs_slab_add) with a lock held.  And kobject_uevent
makes a blocking call to userspace.

No locks held seems to be a good policy on that one.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
