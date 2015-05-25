Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id ED2ED6B00D5
	for <linux-mm@kvack.org>; Mon, 25 May 2015 11:24:32 -0400 (EDT)
Received: by wgbgq6 with SMTP id gq6so75514803wgb.3
        for <linux-mm@kvack.org>; Mon, 25 May 2015 08:24:32 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s2si18727938wjw.208.2015.05.25.08.24.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 25 May 2015 08:24:31 -0700 (PDT)
Message-ID: <55633EAC.8060702@suse.cz>
Date: Mon, 25 May 2015 17:24:28 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] hugetlb: Do not account hugetlb pages as NR_FILE_PAGES
References: <1432214842-22730-1-git-send-email-mhocko@suse.cz> <20150521170909.GA12800@cmpxchg.org> <20150522142143.GF5109@dhcp22.suse.cz> <20150522143558.GA2462@suse.de>
In-Reply-To: <20150522143558.GA2462@suse.de>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 05/22/2015 04:35 PM, Mel Gorman wrote:
>> 
>> Thanks!
>> 
>> > This makes a lot of sense to me.  The only thing I worry about is the
>> > proliferation of PageHuge(), a function call, in relatively hot paths.
>> 
>> I've tried that (see the patch below) but it enlarged the code by almost
>> 1k
>>    text    data     bss     dec     hex filename
>>  510323   74273   44440  629036   9992c mm/built-in.o.before
>>  511248   74273   44440  629961   99cc9 mm/built-in.o.after
>> 
>> I am not sure the code size increase is worth it. Maybe we can reduce
>> the check to only PageCompound(page) as huge pages are no in the page
>> cache (yet).
>> 
> 
> That would be a more sensible route because it also avoids exposing the
> hugetlbfs destructor unnecessarily.

You could maybe do test such as (PageCompound(page) && PageHuge(page)) to
short-circuit the call while remaining future-proof.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
