Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4B1E66B025E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 05:31:10 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w143so25313055wmw.3
        for <linux-mm@kvack.org>; Wed, 18 May 2016 02:31:10 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f141si9807999wmf.102.2016.05.18.02.31.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 May 2016 02:31:09 -0700 (PDT)
Subject: Re: [PATCH v1] mm: bad_page() checks bad_flags instead of page->flags
 for hwpoison page
References: <1463470975-29972-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20160518092100.GB2527@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <573C365B.6020807@suse.cz>
Date: Wed, 18 May 2016 11:31:07 +0200
MIME-Version: 1.0
In-Reply-To: <20160518092100.GB2527@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On 05/18/2016 11:21 AM, Mel Gorman wrote:
> On Tue, May 17, 2016 at 04:42:55PM +0900, Naoya Horiguchi wrote:
>> There's a race window between checking page->flags and unpoisoning, which
>> taints kernel with "BUG: Bad page state". That's overkill. It's safer to
>> use bad_flags to detect hwpoisoned page.
>>
>
> I'm not quite getting this one. Minimally, instead of = __PG_HWPOISON, it
> should have been (bad_flags & __PG_POISON). As Vlastimil already pointed
> out, __PG_HWPOISON can be 0. What I'm not getting is why this fixes the
> race. The current race is
>
> 1. Check poison, set bad_flags
> 2. poison clears in parallel
> 3. Check page->flag state in bad_page and trigger warning
>
> The code changes it to
>
> 1. Check poison, set bad_flags
> 2. poison clears in parallel
> 3. Check bad_flags and trigger warning

I think you got step 3 here wrong. It's "skip the warning since we have 
set bad_flags to hwpoison and bad_flags didn't change due to parallel 
unpoison".

Perhaps the question is why do we need to split the handling between 
check_new_page_bad() and bad_page() like this? It might have been 
different in the past, but seems like at this point we only look for 
hwpoison from check_new_page_bad(). But a cleanup can come later.

> There is warning either way. What did I miss?
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
