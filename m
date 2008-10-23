Message-ID: <49009575.60004@cosmosbay.com>
Date: Thu, 23 Oct 2008 17:17:09 +0200
From: Eric Dumazet <dada1@cosmosbay.com>
MIME-Version: 1.0
Subject: Re: SLUB defrag pull request?
References: <1223883004.31587.15.camel@penberg-laptop>  <84144f020810221348j536f0d84vca039ff32676e2cc@mail.gmail.com>  <E1Ksksa-0002Iq-EV@pomaz-ex.szeredi.hu>  <Pine.LNX.4.64.0810221416130.26639@quilx.com>  <E1KsluU-0002R1-Ow@pomaz-ex.szeredi.hu>  <1224745831.25814.21.camel@penberg-laptop>  <E1KsviY-0003Mq-6M@pomaz-ex.szeredi.hu>  <Pine.LNX.4.64.0810230638450.11924@quilx.com>  <84144f020810230658o7c6b3651k2d671aab09aa71fb@mail.gmail.com>  <Pine.LNX.4.64.0810230705210.12497@quilx.com> <84144f020810230714g7f5d36bas812ad691140ee453@mail.gmail.com> <Pine.LNX.4.64.0810230721400.12497@quilx.com>
In-Reply-To: <Pine.LNX.4.64.0810230721400.12497@quilx.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Miklos Szeredi <miklos@szeredi.hu>, nickpiggin@yahoo.com.au, hugh@veritas.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter a ecrit :
> On Thu, 23 Oct 2008, Pekka Enberg wrote:
> 
>>> The problem looks like its freeing objects on a different processor that
>>> where it was used last. With the pointer array it is only necessary 
>>> to touch
>>> the objects that contain the arrays.
>>
>> Interesting. SLAB gets away with this because of per-cpu caches or
>> because it uses the bufctls instead of a freelist?
> 
> Exactly. Slab adds a special management structure to each slab page that 
> contains the freelist and other stuff. Freeing first occurs to a per cpu 
> queue that contains an array of pointers. Then later the objects are 
> moved from the pointer array into the management structure for the slab.
> 
> What we could do for SLUB is to generate a linked list of pointer arrays 
> in the free objects of a slab page. If all objects are allocated then no 
> pointer array is needed. The first object freed would become the first 
> pointer array. If that is found to be exhausted then the object 
> currently being freed is becoming the next pointer array and we put a 
> link to the old one into the object as well.
> 

This idea is very nice, especially considering that many objects are freed
by RCU, and their rcu_head (which is hot at kfree() time), might be far
away the linked list anchor actually used in SLUB.

At alloc time, I remember I added a prefetchw() call in SLAB in __cache_alloc(),
this could explain some differences between SLUB and SLAB too, since SLAB
gives a hint to processor to warm its cache.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
