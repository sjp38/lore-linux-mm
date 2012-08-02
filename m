Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 0CEC96B0044
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 13:24:28 -0400 (EDT)
Message-ID: <501AB7C5.9010206@parallels.com>
Date: Thu, 2 Aug 2012 21:24:21 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slub: use free_page instead of put_page for freeing kmalloc
 allocation
References: <1343913065-14631-1-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1208020902390.23049@router.home> <20120802164203.GA30111@cmpxchg.org> <501AB013.1090607@parallels.com> <20120802171019.GA1239@cmpxchg.org>
In-Reply-To: <20120802171019.GA1239@cmpxchg.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>

On 08/02/2012 09:10 PM, Johannes Weiner wrote:
> On Thu, Aug 02, 2012 at 08:51:31PM +0400, Glauber Costa wrote:
>> On 08/02/2012 08:42 PM, Johannes Weiner wrote:
>>> On Thu, Aug 02, 2012 at 09:06:41AM -0500, Christoph Lameter wrote:
>>>> On Thu, 2 Aug 2012, Glauber Costa wrote:
>>>>
>>>>> diff --git a/mm/slub.c b/mm/slub.c
>>>>> index e517d43..9ca4e20 100644
>>>>> --- a/mm/slub.c
>>>>> +++ b/mm/slub.c
>>>>> @@ -3453,7 +3453,7 @@ void kfree(const void *x)
>>>>>  	if (unlikely(!PageSlab(page))) {
>>>>>  		BUG_ON(!PageCompound(page));
>>>>>  		kmemleak_free(x);
>>>>> -		put_page(page);
>>>>> +		__free_pages(page, compound_order(page));
>>>>
>>>> Hmmm... put_page would have called put_compound_page(). which would have
>>>> called the dtor function. dtor is set to __free_pages() ok which does
>>>> mlock checks and verifies that the page is in a proper condition for
>>>> freeing. Then it calls free_one_page().
>>>>
>>>> __free_pages() decrements the refcount and then calls __free_pages_ok().
>>>>
>>>> So we loose the checking and the dtor stuff with this patch. Guess that is
>>>> ok?
>>>
>>> The changelog is not correct, however.  People DO get pages underlying
>>> slab objects and even free the slab objects before returning the page.
>>> See recent fix:
>>
>> Well, yes, in the sense that slab objects are page-backed.
>>
>> The point is that a user of kmalloc/kfree should not treat a memory area
>> as if it were a page, even if it is page-sized.
> 
> I whole-heartedly agree.  But it's hard to verify there aren't any
> doing that.  And even though it's ugly to do, it's technically
> working, no?  No longer supporting it would be a regression.

I've done an extensive audit per Christoph's request, and although of
course this is not enough to guarantee it 100 %, it should at least be
enough to sustain a belief that it should be reasonably safe.

About regressions, yes, it is working. But as you know, this area is
under undergoing change by myself. For kmemcg to work, we need to
explicitly mark instances of __free_pages that are accounted. With this
patch, this is trivial. Without this patch, I need to come up with a
quite ugly hack to mark put_pages as well, that would exist for no
reason aside from "avoid touching this".

I could of course just bundle this is my series, but since this is an
independent change, it is better to send it separate so it get better
review, testing and validation.

>> If it is just the Changelog you are unhappy about, I can do another
>> submission rewording it.
> 
> __free_pages still respects the refcount, so I think the Changelog is
> not actually appropriate for the change you're making.  You're just
> changing what Christoph outlined above, the compound page handling.

I can update the Changelog, no problem.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
