Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f45.google.com (mail-la0-f45.google.com [209.85.215.45])
	by kanga.kvack.org (Postfix) with ESMTP id 59A606B0031
	for <linux-mm@kvack.org>; Thu, 19 Dec 2013 03:51:49 -0500 (EST)
Received: by mail-la0-f45.google.com with SMTP id eh20so324325lab.32
        for <linux-mm@kvack.org>; Thu, 19 Dec 2013 00:51:48 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id a4si1284565laf.53.2013.12.19.00.51.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Dec 2013 00:51:47 -0800 (PST)
Message-ID: <52B2B39A.7070303@parallels.com>
Date: Thu, 19 Dec 2013 12:51:38 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/6] slab: cleanup kmem_cache_create_memcg()
References: <6f02b2d079ffd0990ae335339c803337b13ecd8c.1387372122.git.vdavydov@parallels.com> <20131218165603.GB31080@dhcp22.suse.cz> <52B292CF.5030002@parallels.com> <20131219084447.GA9331@dhcp22.suse.cz>
In-Reply-To: <20131219084447.GA9331@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, devel@openvz.org, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>

On 12/19/2013 12:44 PM, Michal Hocko wrote:
> On Thu 19-12-13 10:31:43, Vladimir Davydov wrote:
>> On 12/18/2013 08:56 PM, Michal Hocko wrote:
>>> On Wed 18-12-13 17:16:52, Vladimir Davydov wrote:
>>>> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
>>>> Cc: Michal Hocko <mhocko@suse.cz>
>>>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>>>> Cc: Glauber Costa <glommer@gmail.com>
>>>> Cc: Christoph Lameter <cl@linux.com>
>>>> Cc: Pekka Enberg <penberg@kernel.org>
>>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>> Dunno, is this really better to be worth the code churn?
>>>
>>> It even makes the generated code tiny bit bigger:
>>> text    data     bss     dec     hex filename
>>> 4355     171     236    4762    129a mm/slab_common.o.after
>>> 4342     171     236    4749    128d mm/slab_common.o.before
>>>
>>> Or does it make the further changes much more easier? Be explicit in the
>>> patch description if so.
>> Hi, Michal
>>
>> IMO, undoing under labels looks better than inside conditionals, because
>> we don't have to repeat the same deinitialization code then, like this
>> (note three calls to kmem_cache_free()):
> Agreed but the resulting code is far from doing nice undo on different
> conditions. You have out_free_cache which frees everything regardless
> whether name or cache registration failed. So it doesn't help with
> readability much IMO.

AFAIK it's common practice not to split kfree's to be called under
different labels on fail paths, because kfree(NULL) results in a no-op.
Since on undo, we only call kfree, I introduce the only label. Of course
I could do something like

    s->name=...
    if (!s->name)
        goto out_free_name;
    err = __kmem_new_cache(...)
    if (err)
        goto out_free_name;
<...>
out_free_name:
    kfree(s->name);
out_free_cache:
    kfree(s);
    goto out_unlock;

But I think using only out_free_cache makes the code look clearer.

>
>>     s = kmem_cache_zalloc(kmem_cache, GFP_KERNEL);
>>     if (s) {
>>         s->object_size = s->size = size;
>>         s->align = calculate_alignment(flags, align, size);
>>         s->ctor = ctor;
>>
>>         if (memcg_register_cache(memcg, s, parent_cache)) {
>>             kmem_cache_free(kmem_cache, s);
>>             err = -ENOMEM;
>>             goto out_locked;
>>         }
>>
>>         s->name = kstrdup(name, GFP_KERNEL);
>>         if (!s->name) {
>>             kmem_cache_free(kmem_cache, s);
>>             err = -ENOMEM;
>>             goto out_locked;
>>         }
>>
>>         err = __kmem_cache_create(s, flags);
>>         if (!err) {
>>             s->refcount = 1;
>>             list_add(&s->list, &slab_caches);
>>             memcg_cache_list_add(memcg, s);
>>         } else {
>>             kfree(s->name);
>>             kmem_cache_free(kmem_cache, s);
>>         }
>>     } else
>>         err = -ENOMEM;
>>
>> The next patch, which fixes the memcg_params leakage on error, would
>> make it even worse introducing two calls to memcg_free_cache_params()
>> after kstrdup and __kmem_cache_create.
>>
>> If you think it isn't worthwhile applying this patch, just let me know,
>> I don't mind dropping it.
> As I've said if it helps with the later patches then I do not mind but
> on its own it doesn't sound like a huge improvement.
>
> Btw. you do not have to set err = -ENOMEM before goto out_locked. Just
> set before kmem_cache_zalloc. You also do not need to initialize it to 0
> because kmem_cache_sanity_check will set it.

OK, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
