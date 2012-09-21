Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id F1B856B0068
	for <linux-mm@kvack.org>; Fri, 21 Sep 2012 05:34:22 -0400 (EDT)
Message-ID: <505C33D3.5000202@parallels.com>
Date: Fri, 21 Sep 2012 13:30:59 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 09/16] sl[au]b: always get the cache from its page
 in kfree
References: <1347977530-29755-1-git-send-email-glommer@parallels.com> <1347977530-29755-10-git-send-email-glommer@parallels.com> <00000139d9fe8595-8905906d-18ed-4d41-afdb-f4c632c2d50a-000000@email.amazonses.com> <5059777E.8060906@parallels.com> <CAOJsxLFgwOqUcLHEwYNERwn1Uvp4-8CmvRKTfBFAHD6p_-6c7g@mail.gmail.com>
In-Reply-To: <CAOJsxLFgwOqUcLHEwYNERwn1Uvp4-8CmvRKTfBFAHD6p_-6c7g@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com, devel@openvz.org, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Frederic Weisbecker <fweisbec@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>

On 09/21/2012 01:33 PM, Pekka Enberg wrote:
> On Wed, Sep 19, 2012 at 10:42 AM, Glauber Costa <glommer@parallels.com> wrote:
>>>> index f2d760c..18de3f6 100644
>>>> --- a/mm/slab.c
>>>> +++ b/mm/slab.c
>>>> @@ -3938,9 +3938,12 @@ EXPORT_SYMBOL(__kmalloc);
>>>>   * Free an object which was previously allocated from this
>>>>   * cache.
>>>>   */
>>>> -void kmem_cache_free(struct kmem_cache *cachep, void *objp)
>>>> +void kmem_cache_free(struct kmem_cache *s, void *objp)
>>>>  {
>>>>      unsigned long flags;
>>>> +    struct kmem_cache *cachep = virt_to_cache(objp);
>>>> +
>>>> +    VM_BUG_ON(!slab_equal_or_parent(cachep, s));
>>>
>>> This is an extremely hot path of the kernel and you are adding significant
>>> processing. Check how the benchmarks are influenced by this change.
>>> virt_to_cache can be a bit expensive.
>>
>> Would it be enough for you to have a separate code path for
>> !CONFIG_MEMCG_KMEM?
>>
>> I don't really see another way to do it, aside from deriving the cache
>> from the object in our case. I am open to suggestions if you do.
> 
> We should assume that most distributions enable CONFIG_MEMCG_KMEM,
> right? Therfore, any performance impact should be dependent on whether
> or not kmem memcg is *enabled* at runtime or not.
> 
> Can we use the "static key" thingy introduced by tracing folks for this?
> 
Yes.

I am already using static keys extensively in this patchset, and that is
how I intend to handle this particular case.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
