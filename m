Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 7CC396B004D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 04:28:42 -0400 (EDT)
Message-ID: <5017968C.6050301@parallels.com>
Date: Tue, 31 Jul 2012 12:25:48 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: Any reason to use put_page in slub.c?
References: <1343391586-18837-1-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1207271054230.18371@router.home> <50163D94.5050607@parallels.com> <alpine.DEB.2.00.1207301421150.27584@router.home>
In-Reply-To: <alpine.DEB.2.00.1207301421150.27584@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On 07/30/2012 11:23 PM, Christoph Lameter wrote:
> On Mon, 30 Jul 2012, Glauber Costa wrote:
> 
>> On 07/27/2012 07:55 PM, Christoph Lameter wrote:
>>> On Fri, 27 Jul 2012, Glauber Costa wrote:
>>>
>>>> But I am still wondering if there is anything I am overlooking.
>>>
>>> put_page() is necessary because other subsystems may still be holding a
>>> refcount on the page (if f.e. there is DMA still pending to that page).
>>>
>>
>> Humm, this seems to be extremely unsafe in my read.
> 
> I do not like it either. Hopefully these usecases have been removed in the
> meantime but that used to be an issue.
> 
>> If you do kmalloc, the API - AFAIK - does not provide us with any
>> guarantee that the object (it's not even a page, in the strict sense!)
>> allocated is reference counted internally. So relying on kfree to do it
>> doesn't bode well. For one thing, slab doesn't go to the page allocator
>> for high order allocations, and this code would crash miserably if
>> running with the slab.
>>
>> Or am I missing something ?
> 
> Yes the refcounting is done at the page level by the page allocator. It is
> safe. The slab allocator can free a page removing all references from its
> internal structure while the subsystem page reference will hold off the
> page allocator from actually freeing the page until the subsystem itself
> drops the page count.
> 

pages, yes. But when you do kfree, you don't free a page. You free an
object. The allocator is totally free to keep the page around and pass
it on to someone else.

The use case that put_page protect against, would be totally and
absolutely broken with every other allocator. They could give an object
in the same address to another user in the very next moment.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
