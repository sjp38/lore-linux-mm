Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id CD37F6B0390
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 12:05:27 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id l21so4077630ioi.2
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 09:05:27 -0700 (PDT)
Received: from mail-io0-x236.google.com (mail-io0-x236.google.com. [2607:f8b0:4001:c06::236])
        by mx.google.com with ESMTPS id c29si7710614ioj.1.2017.04.11.09.05.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 09:05:26 -0700 (PDT)
Received: by mail-io0-x236.google.com with SMTP id a103so7980173ioj.1
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 09:05:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170411141956.GP6729@dhcp22.suse.cz>
References: <20170404113022.GC15490@dhcp22.suse.cz> <alpine.DEB.2.20.1704041005570.23420@east.gentwo.org>
 <20170404151600.GN15132@dhcp22.suse.cz> <alpine.DEB.2.20.1704041412050.27424@east.gentwo.org>
 <20170404194220.GT15132@dhcp22.suse.cz> <alpine.DEB.2.20.1704041457030.28085@east.gentwo.org>
 <20170404201334.GV15132@dhcp22.suse.cz> <CAGXu5jL1t2ZZkwnGH9SkFyrKDeCugSu9UUzvHf3o_MgraDFL1Q@mail.gmail.com>
 <20170411134618.GN6729@dhcp22.suse.cz> <CAGXu5j+EVCU1WrjpMmr0PYW2N_RzF0tLUgFumDR+k4035uqthA@mail.gmail.com>
 <20170411141956.GP6729@dhcp22.suse.cz>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 11 Apr 2017 09:05:24 -0700
Message-ID: <CAGXu5jJkJeJYYicXmng0REgEamuxzKrKzq_gtJ2dv5BEN4BkUA@mail.gmail.com>
Subject: Re: [PATCH] mm: Add additional consistency check
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 11, 2017 at 7:19 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Tue 11-04-17 07:14:01, Kees Cook wrote:
>> On Tue, Apr 11, 2017 at 6:46 AM, Michal Hocko <mhocko@kernel.org> wrote:
>> > On Mon 10-04-17 21:58:22, Kees Cook wrote:
>> >> On Tue, Apr 4, 2017 at 1:13 PM, Michal Hocko <mhocko@kernel.org> wrote:
>> >> > On Tue 04-04-17 14:58:06, Cristopher Lameter wrote:
>> >> >> On Tue, 4 Apr 2017, Michal Hocko wrote:
>> >> >>
>> >> >> > On Tue 04-04-17 14:13:06, Cristopher Lameter wrote:
>> >> >> > > On Tue, 4 Apr 2017, Michal Hocko wrote:
>> >> >> > >
>> >> >> > > > Yes, but we do not have to blow the kernel, right? Why cannot we simply
>> >> >> > > > leak that memory?
>> >> >> > >
>> >> >> > > Because it is a serious bug to attempt to free a non slab object using
>> >> >> > > slab operations. This is often the result of memory corruption, coding
>> >> >> > > errs etc. The system needs to stop right there.
>> >> >> >
>> >> >> > Why when an alternative is a memory leak?
>> >> >>
>> >> >> Because the slab allocators fail also in case you free an object multiple
>> >> >> times etc etc. Continuation is supported by enabling a special resiliency
>> >> >> feature via the kernel command line. The alternative is selectable but not
>> >> >> the default.
>> >> >
>> >> > I disagree! We should try to continue as long as we _know_ that the
>> >> > internal state of the allocator is still consistent and a further
>> >> > operation will not spread the corruption even more. This is clearly not
>> >> > the case for an invalid pointer to kfree.
>> >> >
>> >> > I can see why checking for an early allocator corruption is not always
>> >> > feasible and you can only detect after-the-fact but this is not the case
>> >> > here and putting your system down just because some buggy code is trying
>> >> > to free something it hasn't allocated is not really useful. I completely
>> >> > agree with Linus that we overuse BUG way too much and this is just
>> >> > another example of it.
>> >>
>> >> Instead of the proposed BUG here, what's the correct "safe" return value?
>> >
>> > I would assume that _you_ as the one who proposes the change would take
>> > some time to read and understand the code and know this answer. This is
>> > how we do changes to the kernel: have an objective, understand the code
>> > and generate the patch.
>> >
>> > I am really sad that this particular patch has shown that you didn't
>> > bother to consider the later part and blindly applied something that you
>> > haven't thought through properly. Please try harder next time.
>>
>> Our objectives are different: I want the kernel to immediately stop
>> when corruption is detected. Since others are interested in making it
>> survivable, I was hoping to get a hint about what such an improvement
>> would look like.
>
> I do not think sprinkling BUG_ONs will help that objective. And BUG_ON
> under IRQ disable is likely not helping an error survivable...

Yes, agreed. Handling it cleanly is always better.

>> Instead this condescending attitude, can you instead
>> provide constructive help that will get our users closer to the safe
>> kernel operation we're all interested in?
>
> I would do something like...
> ---
> diff --git a/mm/slab.c b/mm/slab.c
> index bd63450a9b16..87c99a5e9e18 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -393,10 +393,15 @@ static inline void set_store_user_dirty(struct kmem_cache *cachep) {}
>  static int slab_max_order = SLAB_MAX_ORDER_LO;
>  static bool slab_max_order_set __initdata;
>
> +static inline struct kmem_cache *page_to_cache(struct page *page)
> +{
> +       return page->slab_cache;
> +}
> +
>  static inline struct kmem_cache *virt_to_cache(const void *obj)
>  {
>         struct page *page = virt_to_head_page(obj);
> -       return page->slab_cache;
> +       return page_to_cache(page);
>  }
>
>  static inline void *index_to_obj(struct kmem_cache *cache, struct page *page,
> @@ -3813,14 +3818,18 @@ void kfree(const void *objp)
>  {
>         struct kmem_cache *c;
>         unsigned long flags;
> +       struct page *page;
>
>         trace_kfree(_RET_IP_, objp);
>
>         if (unlikely(ZERO_OR_NULL_PTR(objp)))
>                 return;
> +       page = virt_to_head_page(obj);
> +       if (CHECK_DATA_CORRUPTION(!PageSlab(page)))
> +               return;
>         local_irq_save(flags);
>         kfree_debugcheck(objp);
> -       c = virt_to_cache(objp);
> +       c = page_to_cache(page);
>         debug_check_no_locks_freed(objp, c->object_size);
>
>         debug_check_no_obj_freed(objp, c->object_size);

Awesome! Thank you very much! I'll play with this.

-Kees

-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
