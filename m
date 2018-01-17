Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id AEEAF6B0271
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 17:00:58 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id o11so12385369pgp.14
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 14:00:58 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id s134si4520657pgs.301.2018.01.17.14.00.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 14:00:57 -0800 (PST)
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
References: <CA+55aFwvgm+KKkRLaFsuAjTdfQooS=UaMScC0CbZQ9WnX_AF=g@mail.gmail.com>
 <201801160115.w0G1FOIG057203@www262.sakura.ne.jp>
 <CA+55aFxOn5n4O2JNaivi8rhDmeFhTQxEHD4xE33J9xOrFu=7kQ@mail.gmail.com>
 <201801170233.JDG21842.OFOJMQSHtOFFLV@I-love.SAKURA.ne.jp>
 <CA+55aFyxyjN0Mqnz66B4a0R+uR8DdfxdMhcg5rJVi8LwnpSRfA@mail.gmail.com>
 <201801172008.CHH39543.FFtMHOOVSQJLFO@I-love.SAKURA.ne.jp>
 <CA+55aFw_itrZGTkDPL41DtwCBEBHmxXsucp5HUbNDX9hwOFddw@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <87aea433-ba6b-8543-d925-3ef36911f124@linux.intel.com>
Date: Wed, 17 Jan 2018 14:00:54 -0800
MIME-Version: 1.0
In-Reply-To: <CA+55aFw_itrZGTkDPL41DtwCBEBHmxXsucp5HUbNDX9hwOFddw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Tony Luck <tony.luck@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>

On 01/17/2018 01:39 PM, Linus Torvalds wrote:
> 
> So maybe something like this to test the theory?
> 
>     diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>     index 76c9688b6a0a..f919a5548943 100644
>     --- a/mm/page_alloc.c
>     +++ b/mm/page_alloc.c
>     @@ -756,6 +756,8 @@ static inline void rmv_page_order(struct page *page)
>      static inline int page_is_buddy(struct page *page, struct page *buddy,
>                                                             unsigned int order)
>      {
>     +       if (WARN_ON_ONCE(page_zone(page) != page_zone(buddy)))
>     +               return 0;
>             if (page_is_guard(buddy) && page_order(buddy) == order) {
>                     if (page_zone_id(page) != page_zone_id(buddy))
>                             return 0;

I thought that page_zone_id() stuff was there to prevent this kind of
cross-zone stuff from happening.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
