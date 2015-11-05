Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id CE2C482F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 03:17:35 -0500 (EST)
Received: by wimw2 with SMTP id w2so4797336wim.1
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 00:17:35 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k197si8508343wmg.106.2015.11.05.00.17.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 05 Nov 2015 00:17:34 -0800 (PST)
Subject: Re: [PATCH 3/5] mm, page_owner: copy page owner info during migration
References: <1446649261-27122-1-git-send-email-vbabka@suse.cz>
 <1446649261-27122-4-git-send-email-vbabka@suse.cz>
 <20151105081005.GB25938@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <563B109D.6030001@suse.cz>
Date: Thu, 5 Nov 2015 09:17:33 +0100
MIME-Version: 1.0
In-Reply-To: <20151105081005.GB25938@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>

On 11/05/2015 09:10 AM, Joonsoo Kim wrote:
> On Wed, Nov 04, 2015 at 04:00:59PM +0100, Vlastimil Babka wrote:
>> +void __copy_page_owner(struct page *oldpage, struct page *newpage)
>> +{
>> +	struct page_ext *old_ext = lookup_page_ext(oldpage);
>> +	struct page_ext *new_ext = lookup_page_ext(newpage);
>> +	int i;
>> +
>> +	new_ext->order = old_ext->order;
>> +	new_ext->gfp_mask = old_ext->gfp_mask;
>> +	new_ext->nr_entries = old_ext->nr_entries;
>> +
>> +	for (i = 0; i < ARRAY_SIZE(new_ext->trace_entries); i++)
>> +		new_ext->trace_entries[i] = old_ext->trace_entries[i];
>> +
>> +	__set_bit(PAGE_EXT_OWNER, &new_ext->flags);
>> +}
>> +
> 
> Need to clear PAGE_EXT_OWNER bit in oldppage.

Hm, I thought that the freeing of the oldpage, which follows the migration,
would take care of that. And if it hit some bug and dump_page before being
freed, we would still have some info to print?

Thanks

> Thanks.
> 
>>  static ssize_t
>>  print_page_owner(char __user *buf, size_t count, unsigned long pfn,
>>  		struct page *page, struct page_ext *page_ext)
>> -- 
>> 2.6.2
>> 
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
