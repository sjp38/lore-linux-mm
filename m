Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7DD826B0271
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 17:04:54 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id x4so5842746pgv.2
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 14:04:54 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id z5si5149070pfz.415.2018.01.17.14.04.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 14:04:53 -0800 (PST)
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
References: <CA+55aFwvgm+KKkRLaFsuAjTdfQooS=UaMScC0CbZQ9WnX_AF=g@mail.gmail.com>
 <201801160115.w0G1FOIG057203@www262.sakura.ne.jp>
 <CA+55aFxOn5n4O2JNaivi8rhDmeFhTQxEHD4xE33J9xOrFu=7kQ@mail.gmail.com>
 <201801170233.JDG21842.OFOJMQSHtOFFLV@I-love.SAKURA.ne.jp>
 <CA+55aFyxyjN0Mqnz66B4a0R+uR8DdfxdMhcg5rJVi8LwnpSRfA@mail.gmail.com>
 <201801172008.CHH39543.FFtMHOOVSQJLFO@I-love.SAKURA.ne.jp>
 <CA+55aFw_itrZGTkDPL41DtwCBEBHmxXsucp5HUbNDX9hwOFddw@mail.gmail.com>
 <CA+55aFySaBgxmNA3f_u4ebBEdD7Smq68s0qjMCntzuzP3c_gqQ@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <4fe52147-b6a1-83a7-ee4b-104846ddb919@linux.intel.com>
Date: Wed, 17 Jan 2018 14:04:51 -0800
MIME-Version: 1.0
In-Reply-To: <CA+55aFySaBgxmNA3f_u4ebBEdD7Smq68s0qjMCntzuzP3c_gqQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Tony Luck <tony.luck@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>

On 01/17/2018 01:51 PM, Linus Torvalds wrote:
> In fact, it seems to be such a fundamental bug that I suspect I'm
> entirely wrong, and full of shit. So it's an interesting and not
> _obviously_ incorrect theory, but I suspect I must be missing
> something.

I'll just note that a few of the pfns I decoded were smack in the middle
of the zone, not near either the high or low end of ZONE_NORMAL where we
would expect this cross-zone stuff to happen.

But I guess we could get similar wonkiness where 'struct page' is
screwed up in so many different ways if during buddy joining you do:

	list_del(&buddy->lru);

and 'buddy' is off in another zone for which you do not hold the
spinlock.  If we are somehow missing some locking, or double-allocating
a page, something like this would help:

 static inline void rmv_page_order(struct page *page)
 {
+	 WARN_ON_ONCE(!PageBuddy(page));
         __ClearPageBuddy(page);
         set_page_private(page, 0);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
