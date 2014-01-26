Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f174.google.com (mail-lb0-f174.google.com [209.85.217.174])
	by kanga.kvack.org (Postfix) with ESMTP id D93EF6B0035
	for <linux-mm@kvack.org>; Sun, 26 Jan 2014 03:15:40 -0500 (EST)
Received: by mail-lb0-f174.google.com with SMTP id l4so3596852lbv.5
        for <linux-mm@kvack.org>; Sun, 26 Jan 2014 00:15:39 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id ya3si3025554lbb.116.2014.01.26.00.15.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 26 Jan 2014 00:15:39 -0800 (PST)
Message-ID: <52E4C420.8020800@parallels.com>
Date: Sun, 26 Jan 2014 12:15:28 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slab: fix wrong retval on kmem_cache_create_memcg error
 path
References: <1390598126-4332-1-git-send-email-vdavydov@parallels.com> <alpine.DEB.2.02.1401252036410.10325@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1401252036410.10325@chino.kir.corp.google.com>
Content-Type: multipart/mixed;
	boundary="------------010306060909040309010806"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Jones <davej@redhat.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

--------------010306060909040309010806
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit

On 01/26/2014 08:39 AM, David Rientjes wrote:
> On Sat, 25 Jan 2014, Vladimir Davydov wrote:
>
>> diff --git a/mm/slab_common.c b/mm/slab_common.c
>> index 8e40321..499b53c 100644
>> --- a/mm/slab_common.c
>> +++ b/mm/slab_common.c
>> @@ -249,7 +249,6 @@ out_unlock:
>>  				name, err);
>>  			dump_stack();
>>  		}
>> -		return NULL;
>>  	}
>>  	return s;
>>  
>> @@ -257,6 +256,7 @@ out_free_cache:
>>  	memcg_free_cache_params(s);
>>  	kfree(s->name);
>>  	kmem_cache_free(kmem_cache, s);
>> +	s = NULL;
>>  	goto out_unlock;
>>  }
>>  
> I thought I left spaghetti code back in my BASIC 2.0 days.  It should be 
> much more readable to just do
>
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -233,14 +233,15 @@ out_unlock:
>  	mutex_unlock(&slab_mutex);
>  	put_online_cpus();
>  
> -	/*
> -	 * There is no point in flooding logs with warnings or especially
> -	 * crashing the system if we fail to create a cache for a memcg. In
> -	 * this case we will be accounting the memcg allocation to the root
> -	 * cgroup until we succeed to create its own cache, but it isn't that
> -	 * critical.
> -	 */
> -	if (err && !memcg) {
> +	if (err) {
> +		/*
> +		 * There is no point in flooding logs with warnings or
> +		 * especially crashing the system if we fail to create a cache
> +		 * for a memcg.
> +		 */
> +		if (memcg)
> +			return NULL;
> +
>  		if (flags & SLAB_PANIC)
>  			panic("kmem_cache_create: Failed to create slab '%s'. Error %d\n",
>  				name, err);
>
> and stop trying to remember what err, memcg, and s are in all possible 
> contexts.  Sheesh.

Hi, David,

Although it's rather a matter of personal preference, I tend to agree
with you.

Andrew,

The fix by David Rientjes is attached. It's up to you to decide, which
one looks better.

Thank you and sorry about the noise.

--------------010306060909040309010806
Content-Type: text/x-patch;
	name="0001-slab-fix-wrong-retval-on-kmem_cache_create_memcg-err.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename*0="0001-slab-fix-wrong-retval-on-kmem_cache_create_memcg-err.pa";
	filename*1="tch"


--------------010306060909040309010806--
