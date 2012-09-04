Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 9A4796B005D
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 07:10:39 -0400 (EDT)
Message-ID: <5045E0ED.1000402@parallels.com>
Date: Tue, 4 Sep 2012 15:07:25 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm, slob: Drop usage of page->private for storing
 page-sized allocations
References: <1346753637-13389-1-git-send-email-elezegarcia@gmail.com> <5045D4B9.9000909@parallels.com> <CALF0-+WZhY5NOYiEdDR2n_JrCKB70jei55pEw=914aSWmeqhNg@mail.gmail.com>
In-Reply-To: <CALF0-+WZhY5NOYiEdDR2n_JrCKB70jei55pEw=914aSWmeqhNg@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>

On 09/04/2012 02:34 PM, Ezequiel Garcia wrote:
> Hi Glauber,
> 
> On Tue, Sep 4, 2012 at 7:15 AM, Glauber Costa <glommer@parallels.com> wrote:
>> On 09/04/2012 02:13 PM, Ezequiel Garcia wrote:
>>> This field was being used to store size allocation so it could be
>>> retrieved by ksize(). However, it is a bad practice to not mark a page
>>> as a slab page and then use fields for special purposes.
>>> There is no need to store the allocated size and
>>> ksize() can simply return PAGE_SIZE << compound_order(page).
>>
>> What happens for allocations smaller than a page?
>> It seems you are breaking ksize for those.
>>
> 
> Allocations smaller than a page save its own size on a header
> located at each returned pointer. This is documented at the beginning of slob:
> 
> "Above this is an implementation of kmalloc/kfree. Blocks returned
> from kmalloc are prepended with a 4-byte header with the kmalloc size."
> 
> For this objects (smaller than a page) ksize works fine:
> 
> size_t ksize(const void *block) {
> [...]
>   unsigned int *m = (unsigned int *)(block - align);
>   return SLOB_UNITS(*m) * SLOB_UNIT;
> 
> (see how ksize substract 'align' from block to find the header?)
> 
> Of course, it's possible I've overlooked something, but I think this
> should work.
> 

Ok. Slob also goes to the page allocator for higher order kmallocs,
so it should work.





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
