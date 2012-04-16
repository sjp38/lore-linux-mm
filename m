Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 84C9E6B00E7
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 10:43:01 -0400 (EDT)
Message-ID: <4F8C2F8F.1040009@parallels.com>
Date: Mon, 16 Apr 2012 11:41:19 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slub: don't create a copy of the name string in kmem_cache_create
References: <1334351170-26672-1-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1204160900270.7795@router.home>
In-Reply-To: <alpine.DEB.2.00.1204160900270.7795@router.home>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, devel@openvz.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>

On 04/16/2012 11:02 AM, Christoph Lameter wrote:
> On Fri, 13 Apr 2012, Glauber Costa wrote:
>
>> When creating a cache, slub keeps a copy of the cache name through
>> strdup. The slab however, doesn't do that. This means that everyone
>> registering caches have to keep a copy themselves anyway, since code
>> needs to work on all allocators.
>>
>> Having slab create a copy of it as well may very well be the right
>> thing to do: but at this point, the callers are already there
>
> What would break if we would add that to slab? I think this is more robust
> because right now slab relies on the caller not freeing the string.

Hard to think of anything, since we call kmem_cache_create() outside of
interrupt context anyway.

We have one more point in which we can fail - specially now that we are 
constraining memory usage, but one can argue that if we are short on 
memory, better not create another cache anyway.

My main reason for taking this out of slub, instead of adding to the 
slab, is that I don't remember any single bug report about that - and 
there are certainly people around using slab, and the interface has been 
around for so long, that pretty much everyone will assume this anyway.

I am happy, however, to patch it either way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
