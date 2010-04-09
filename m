Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 18A376B021B
	for <linux-mm@kvack.org>; Fri,  9 Apr 2010 02:29:29 -0400 (EDT)
Message-ID: <4BBEC92B.9060407@redhat.com>
Date: Fri, 09 Apr 2010 14:28:59 +0800
From: Xiaotian Feng <dfeng@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slab: fix caller tracking on !CONFIG_DEBUG_SLAB && CONFIG_TRACING
References: <1270721493-27820-1-git-send-email-dfeng@redhat.com> <alpine.DEB.2.00.1004081209380.21040@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1004081209380.21040@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, Vegard Nossum <vegard.nossum@gmail.com>, Dmitry Monakhov <dmonakhov@openvz.org>, Catalin Marinas <catalin.marinas@arm.com>
List-ID: <linux-mm.kvack.org>

On 04/09/2010 03:12 AM, David Rientjes wrote:
> On Thu, 8 Apr 2010, Xiaotian Feng wrote:
>
>> diff --git a/include/linux/slab.h b/include/linux/slab.h
>> index 4884462..1a0625c 100644
>> --- a/include/linux/slab.h
>> +++ b/include/linux/slab.h
>> @@ -267,7 +267,7 @@ static inline void *kmem_cache_alloc_node(struct kmem_cache *cachep,
>>    * allocator where we care about the real place the memory allocation
>>    * request comes from.
>>    */
>> -#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_SLUB)
>> +#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_SLUB) || defined(CONFIG_TRACING)
>>   extern void *__kmalloc_track_caller(size_t, gfp_t, unsigned long);
>>   #define kmalloc_track_caller(size, flags) \
>>   	__kmalloc_track_caller(size, flags, _RET_IP_)
>> @@ -285,7 +285,7 @@ extern void *__kmalloc_track_caller(size_t, gfp_t, unsigned long);
>>    * standard allocator where we care about the real place the memory
>>    * allocation request comes from.
>>    */
>> -#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_SLUB)
>> +#if defined(CONFIG_DEBUG_SLAB) || defined(CONFIG_SLUB) || defined(CONFIG_TRACING)
>>   extern void *__kmalloc_node_track_caller(size_t, gfp_t, int, unsigned long);
>>   #define kmalloc_node_track_caller(size, flags, node) \
>>   	__kmalloc_node_track_caller(size, flags, node, \
>
> This doesn't work if the underlying slab allocator doesn't define
> __kmalloc_node_track_caller() regardless of whether CONFIG_TRACING is
> enabled or not.  SLOB, for example, never defines it, and that's why the
> conditional exists in the way it currently does.
>

Sorry, I didn't realized this, can we use (defined(CONFIG_TRACING) && 
defined(CONFIG_SLAB)) ?

> This is your patch with CONFIG_EMBEDDED&&  CONFIG_SLOB:
>
> mm/built-in.o: In function `__krealloc':
> (.text+0x1283c): undefined reference to `__kmalloc_track_caller'
> mm/built-in.o: In function `kmemdup':
> (.text+0x128b4): undefined reference to `__kmalloc_track_caller'
> mm/built-in.o: In function `kstrndup':
> (.text+0x128fc): undefined reference to `__kmalloc_track_caller'
> mm/built-in.o: In function `kstrdup':
> (.text+0x12943): undefined reference to `__kmalloc_track_caller'
> mm/built-in.o: In function `memdup_user':
> (.text+0x129f7): undefined reference to `__kmalloc_track_caller'
> drivers/built-in.o:(.text+0xc48a4): more undefined references to `__kmalloc_track_caller' follow
> net/built-in.o: In function `__alloc_skb':
> (.text+0x8dc6): undefined reference to `__kmalloc_node_track_caller'
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
