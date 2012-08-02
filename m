Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 976A16B004D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 12:51:38 -0400 (EDT)
Message-ID: <501AB013.1090607@parallels.com>
Date: Thu, 2 Aug 2012 20:51:31 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slub: use free_page instead of put_page for freeing kmalloc
 allocation
References: <1343913065-14631-1-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1208020902390.23049@router.home> <20120802164203.GA30111@cmpxchg.org>
In-Reply-To: <20120802164203.GA30111@cmpxchg.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>

On 08/02/2012 08:42 PM, Johannes Weiner wrote:
> On Thu, Aug 02, 2012 at 09:06:41AM -0500, Christoph Lameter wrote:
>> On Thu, 2 Aug 2012, Glauber Costa wrote:
>>
>>> diff --git a/mm/slub.c b/mm/slub.c
>>> index e517d43..9ca4e20 100644
>>> --- a/mm/slub.c
>>> +++ b/mm/slub.c
>>> @@ -3453,7 +3453,7 @@ void kfree(const void *x)
>>>  	if (unlikely(!PageSlab(page))) {
>>>  		BUG_ON(!PageCompound(page));
>>>  		kmemleak_free(x);
>>> -		put_page(page);
>>> +		__free_pages(page, compound_order(page));
>>
>> Hmmm... put_page would have called put_compound_page(). which would have
>> called the dtor function. dtor is set to __free_pages() ok which does
>> mlock checks and verifies that the page is in a proper condition for
>> freeing. Then it calls free_one_page().
>>
>> __free_pages() decrements the refcount and then calls __free_pages_ok().
>>
>> So we loose the checking and the dtor stuff with this patch. Guess that is
>> ok?
> 
> The changelog is not correct, however.  People DO get pages underlying
> slab objects and even free the slab objects before returning the page.
> See recent fix:

Well, yes, in the sense that slab objects are page-backed.

The point is that a user of kmalloc/kfree should not treat a memory area
as if it were a page, even if it is page-sized.

If it is just the Changelog you are unhappy about, I can do another
submission rewording it.

> commit 5bf5f03c271907978489868a4c72aeb42b5127d2
> Author: Pravin B Shelar <pshelar@nicira.com>
> Date:   Tue May 29 15:06:49 2012 -0700
> 
>     mm: fix slab->page flags corruption
>     
>     Transparent huge pages can change page->flags (PG_compound_lock) without
>     taking Slab lock.  Since THP can not break slab pages we can safely access
>     compound page without taking compound lock.
>     
>     Specifically this patch fixes a race between compound_unlock() and slab
>     functions which perform page-flags updates.  This can occur when
>     get_page()/put_page() is called on a page from slab.

This is just another argument not to do put_page on slab pages!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
