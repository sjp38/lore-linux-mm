Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4767B6B026A
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 08:45:43 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id j15so9842775wre.15
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 05:45:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e24si1603706wra.456.2017.10.31.05.45.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 Oct 2017 05:45:42 -0700 (PDT)
Subject: Re: [PATCH] mm/swap: Use page flags to determine LRU list in
 __activate_page()
References: <20171019145657.11199-1-khandual@linux.vnet.ibm.com>
 <20171019153322.c4uqalws7l7fdzcx@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <23110557-b2db-9f4a-d072-ad58fd0c1931@suse.cz>
Date: Tue, 31 Oct 2017 13:45:39 +0100
MIME-Version: 1.0
In-Reply-To: <20171019153322.c4uqalws7l7fdzcx@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, shli@kernel.org

On 10/19/2017 05:33 PM, Michal Hocko wrote:
> On Thu 19-10-17 20:26:57, Anshuman Khandual wrote:
>> Its already assumed that the PageActive flag is clear on the input
>> page, hence page_lru(page) will pick the base LRU for the page. In
>> the same way page_lru(page) will pick active base LRU, once the
>> flag PageActive is set on the page. This change of LRU list should
>> happen implicitly through the page flags instead of being hard
>> coded.
> 
> The patch description tells what but it doesn't explain _why_? Does the
> resulting code is better, more optimized or is this a pure readability
> thing?
> 
> All I can see is that page_lru is more complex and a large part of it
> can be optimized away which has been done manually here. I suspect the
> compiler can deduce the same thing.

We shouldn't overestimate the compiler (or the objective conditions it
has) for optimizing stuff away:

After applying the patch:

./scripts/bloat-o-meter swap_before.o mm/swap.o
add/remove: 0/0 grow/shrink: 1/0 up/down: 160/0 (160)
function                                     old     new   delta
__activate_page                              708     868    +160
Total: Before=13538, After=13698, chg +1.18%

I don't think we want that, it's not exactly a cold code...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
