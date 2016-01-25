Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id D67BA6B0009
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 17:06:00 -0500 (EST)
Received: by mail-ig0-f177.google.com with SMTP id mw1so40486274igb.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 14:06:00 -0800 (PST)
Received: from mail-io0-x22f.google.com (mail-io0-x22f.google.com. [2607:f8b0:4001:c06::22f])
        by mx.google.com with ESMTPS id m3si1124995igj.63.2016.01.25.14.06.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jan 2016 14:06:00 -0800 (PST)
Received: by mail-io0-x22f.google.com with SMTP id 1so166847890ion.1
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 14:06:00 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56A682B5.8000603@intel.com>
References: <1453740953-18109-1-git-send-email-labbott@fedoraproject.org>
	<1453740953-18109-4-git-send-email-labbott@fedoraproject.org>
	<56A682B5.8000603@intel.com>
Date: Mon, 25 Jan 2016 14:05:59 -0800
Message-ID: <CAGXu5jJCrNMuE9JgqsBeuL1UFyp-z+erWVPOK_FGT+vum7X5Wg@mail.gmail.com>
Subject: Re: [kernel-hardening] [RFC][PATCH 3/3] mm/page_poisoning.c: Allow
 for zero poisoning
From: Kees Cook <keescook@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Laura Abbott <labbott@fedoraproject.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Jan 25, 2016 at 12:16 PM, Dave Hansen <dave.hansen@intel.com> wrote:
> Thanks for doing this!  It all looks pretty straightforward.
>
> On 01/25/2016 08:55 AM, Laura Abbott wrote:
>> By default, page poisoning uses a poison value (0xaa) on free. If this
>> is changed to 0, the page is not only sanitized but zeroing on alloc
>> with __GFP_ZERO can be skipped as well. The tradeoff is that detecting
>> corruption from the poisoning is harder to detect. This feature also
>> cannot be used with hibernation since pages are not guaranteed to be
>> zeroed after hibernation.
>
> Ugh, that's a good point about hibernation.  I'm not sure how widely it
> gets used but it does look pretty widely enabled in distribution kernels.
>
> Is this something that's fixable?  It seems like we could have the
> hibernation code run through and zero all the free lists.  Or, we could
> just disable the optimization at runtime when a hibernation is done.

We can also make hibernation run-time disabled when poisoning is used
(similar to how kASLR disables it).

> Not that we _have_ to do any of this now, but if a runtime knob (like a
> sysctl) could be fun too.  I would be nice for folks to turn it on and
> off if they wanted the added security of "real" poisoning vs. the
> potential performance boost from this optimization.
>
>> +static inline bool should_zero(void)
>> +{
>> +     return !IS_ENABLED(CONFIG_PAGE_POISONING_ZERO) ||
>> +             !page_poisoning_enabled();
>> +}
>
> I wonder if calling this "free_pages_prezeroed()" would make things a
> bit more clear when we use it in prep_new_page().
>
>>  static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
>>                                                               int alloc_flags)
>>  {
>> @@ -1401,7 +1407,7 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
>>       kernel_map_pages(page, 1 << order, 1);
>>       kasan_alloc_pages(page, order);
>>
>> -     if (gfp_flags & __GFP_ZERO)
>> +     if (should_zero() && gfp_flags & __GFP_ZERO)
>>               for (i = 0; i < (1 << order); i++)
>>                       clear_highpage(page + i);
>
> It's probably also worth pointing out that this can be a really nice
> feature to have in virtual machines where memory is being deduplicated.
>  As it stands now, the free lists end up with gunk in them and tend not
> to be easy to deduplicate.  This patch would fix that.

Oh, good point!

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
