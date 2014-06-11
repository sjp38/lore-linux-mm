Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 2BCDD6B0156
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 08:19:00 -0400 (EDT)
Received: by mail-wi0-f181.google.com with SMTP id n3so987443wiv.14
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 05:18:59 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gh5si41571627wjd.145.2014.06.11.05.18.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Jun 2014 05:18:59 -0700 (PDT)
Message-ID: <5398492E.3070406@suse.cz>
Date: Wed, 11 Jun 2014 14:18:54 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 4/6] mm, compaction: skip buddy pages by their order
 in the migrate scanner
References: <alpine.DEB.2.02.1405211954410.13243@chino.kir.corp.google.com> <1401898310-14525-1-git-send-email-vbabka@suse.cz> <1401898310-14525-4-git-send-email-vbabka@suse.cz> <alpine.DEB.2.02.1406041656400.22536@chino.kir.corp.google.com> <5390374E.5080708@suse.cz> <alpine.DEB.2.02.1406051428360.18119@chino.kir.corp.google.com> <53916BB0.3070001@suse.cz> <alpine.DEB.2.02.1406090207300.24247@chino.kir.corp.google.com> <53959C11.2000305@suse.cz> <alpine.DEB.2.02.1406091512540.5271@chino.kir.corp.google.com> <5396B31B.6080706@suse.cz> <alpine.DEB.2.02.1406101646540.32203@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1406101646540.32203@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>

On 06/11/2014 01:54 AM, David Rientjes wrote:
> On Tue, 10 Jun 2014, Vlastimil Babka wrote:
>
>>> I think the compiler is allowed to turn this into
>>>
>>> 	if (ACCESS_ONCE(page_private(page)) > 0 &&
>>> 	    ACCESS_ONCE(page_private(page)) < MAX_ORDER)
>>> 		low_pfn += (1UL << ACCESS_ONCE(page_private(page))) - 1;
>>>
>>> since the inline function has a return value of unsigned long but gcc may
>>> not do this.  I think
>>>
>>> 	/*
>>> 	 * Big fat comment describing why we're using ACCESS_ONCE(), that
>>> 	 * we're ok to race, and that this is meaningful only because of
>>> 	 * the previous PageBuddy() check.
>>> 	 */
>>> 	unsigned long pageblock_order = ACCESS_ONCE(page_private(page));
>>>
>>> is better.
>>
>> I've talked about it with a gcc guy and (although he didn't actually see the
>> code so it might be due to me not explaining it perfectly), the compiler will
>> inline page_order_unsafe() so that there's effectively.
>>
>> unsigned long freepage_order = ACCESS_ONCE(page_private(page));
>>
>> and now it cannot just replace all freepage_order occurences with new
>> page_private() accesses. So thanks to the inlining, the volatile qualification
>> propagates to where it matters. It makes sense to me, but if it's according to
>> standard or gcc specific, I don't know.
>>
>
> I hate to belabor this point, but I think gcc does treat it differently.
> If you look at the assembly comparing your patch to if you do
>
> 	unsigned long freepage_order = ACCESS_ONCE(page_private(page));
>
> instead, then if you enable annotation you'll see that gcc treats the
> store as page_x->D.y.private in your patch vs. MEM[(volatile long unsigned
> int *)page_x + 48B] with the above.

Hm sure you compiled a version that used page_order_unsafe() and not 
page_order()? Because I do see:

MEM[(volatile long unsigned int *)valid_page_114 + 48B];

That's gcc 4.8.1, but our gcc guy said he tried 4.5+ and all was like 
this. And that it would be a gcc bug if not.
He also did a test where page_order was called twice in one function and 
page_order_unsafe twice in another function. page_order() was reduced to 
a single access in the assembly, page_order_unsafe were two accesses.

> I don't have the ability to prove that all versions of gcc optimization
> will not choose to reaccess page_private(page) here, but it does show that
> at least gcc 4.6.3 does not consider them to be equivalents.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
