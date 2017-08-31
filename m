Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id DDD186B0292
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 04:33:44 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id i76so5437901wme.2
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 01:33:44 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p7si5978179wrg.170.2017.08.31.01.33.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 31 Aug 2017 01:33:43 -0700 (PDT)
Subject: Re: [PATCH 1/4] mm, page_owner: make init_pages_in_zone() faster
From: Vlastimil Babka <vbabka@suse.cz>
References: <20170720134029.25268-1-vbabka@suse.cz>
 <20170720134029.25268-2-vbabka@suse.cz>
 <20170724123843.GH25221@dhcp22.suse.cz>
 <483227ce-6786-f04b-72d1-dba18e06ccaa@suse.cz>
Message-ID: <45813564-2342-fc8d-d31a-f4b68a724325@suse.cz>
Date: Thu, 31 Aug 2017 09:55:25 +0200
MIME-Version: 1.0
In-Reply-To: <483227ce-6786-f04b-72d1-dba18e06ccaa@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Yang Shi <yang.shi@linaro.org>, Laura Abbott <labbott@redhat.com>, Vinayak Menon <vinmenon@codeaurora.org>, zhong jiang <zhongjiang@huawei.com>

On 08/23/2017 08:47 AM, Vlastimil Babka wrote:
> On 07/24/2017 02:38 PM, Michal Hocko wrote:
>> On Thu 20-07-17 15:40:26, Vlastimil Babka wrote:
>>> In init_pages_in_zone() we currently use the generic set_page_owner() function
>>> to initialize page_owner info for early allocated pages. This means we
>>> needlessly do lookup_page_ext() twice for each page, and more importantly
>>> save_stack(), which has to unwind the stack and find the corresponding stack
>>> depot handle. Because the stack is always the same for the initialization,
>>> unwind it once in init_pages_in_zone() and reuse the handle. Also avoid the
>>> repeated lookup_page_ext().
>>
>> Yes this looks like an improvement but I have to admit that I do not
>> really get why we even do save_stack at all here. Those pages might
>> got allocated from anywhere so we could very well provide a statically
>> allocated "fake" stack trace, no?
> 
> We could, but it's much simpler to do it this way than try to extend
> stack depot/stack saving to support creating such fakes. Would it be
> worth the effort?

Ah, I've noticed we already do this for the dummy (prevent recursion)
stack and failure stack. So here you go. It will also make the fake
stack more obvious after "[PATCH 2/2] mm, page_owner: Skip unnecessary
stack_trace entries" is merged, which would otherwise remove
init_page_owner() from the stack.

----8<----
