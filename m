Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9C8A16B7FC8
	for <linux-mm@kvack.org>; Fri,  7 Dec 2018 04:26:49 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id i14so1665581edf.17
        for <linux-mm@kvack.org>; Fri, 07 Dec 2018 01:26:49 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y13-v6sor999748ejb.25.2018.12.07.01.26.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Dec 2018 01:26:48 -0800 (PST)
Date: Fri, 7 Dec 2018 09:26:46 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm, kmemleak: Little optimization while scanning
Message-ID: <20181207092646.zygzfrdnqcq6xvqm@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181206131918.25099-1-osalvador@suse.de>
 <20181207041528.xs4xnw6vpsbu5csx@master>
 <1544163250.3008.7.camel@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1544163250.3008.7.camel@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oscar Salvador <osalvador@suse.de>
Cc: Wei Yang <richard.weiyang@gmail.com>, akpm@linux-foundation.org, catalin.marinas@arm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com

On Fri, Dec 07, 2018 at 07:14:10AM +0100, Oscar Salvador wrote:
>
>> > +
>> 
>> This one maybe not necessary.
>
>Yeah, that is a remind of an include file I used for time measurement.
>I hope Andrew can drop that if this is taken.
>
>> > /*
>> >  * Kmemleak configuration and common defines.
>> >  */
>> > @@ -1547,11 +1548,14 @@ static void kmemleak_scan(void)
>> > 		unsigned long pfn;
>> > 
>> > 		for (pfn = start_pfn; pfn < end_pfn; pfn++) {
>> > -			struct page *page;
>> > +			struct page *page =
>> > pfn_to_online_page(pfn);
>> > +
>> > +			if (!page)
>> > +				continue;
>> > 
>> > -			if (!pfn_valid(pfn))
>> > +			/* only scan pages belonging to this node
>> > */
>> > +			if (page_to_nid(page) != i)
>> > 				continue;
>> 
>> Not farmiliar with this situation. Is this often?
>Well, hard to tell how often that happens because that mostly depends
>on the Hardware in case of baremetal.
>Virtual systems can also have it though.
>

Ok, generally looks good to me.

Reviewed-by: Wei Yang <richard.weiyang@gmail.com>

>> 
>> > -			page = pfn_to_page(pfn);
>> > 			/* only scan if page is in use */
>> > 			if (page_count(page) == 0)
>> > 				continue;
>> > -- 
>> > 2.13.7
>> 
>> 
>-- 
>Oscar Salvador
>SUSE L3

-- 
Wei Yang
Help you, Help me
