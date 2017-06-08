Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 33D7C6B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 07:02:12 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id d64so3091314wmf.9
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 04:02:12 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k2si5288928wmg.93.2017.06.08.04.02.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Jun 2017 04:02:10 -0700 (PDT)
Subject: Re: [PATCH 2/3] mm/page_ref: Ensure page_ref_unfreeze is ordered
 against prior accesses
References: <1496771916-28203-1-git-send-email-will.deacon@arm.com>
 <1496771916-28203-3-git-send-email-will.deacon@arm.com>
 <b6677057-54d6-4336-93a0-5d0770434aa7@suse.cz>
 <20170608103402.GF6071@arm.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b9042a51-56de-2c39-7d0c-41f515633128@suse.cz>
Date: Thu, 8 Jun 2017 13:02:09 +0200
MIME-Version: 1.0
In-Reply-To: <20170608103402.GF6071@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mark.rutland@arm.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, Punit.Agrawal@arm.com, mgorman@suse.de, steve.capper@arm.com

On 06/08/2017 12:34 PM, Will Deacon wrote:
> On Thu, Jun 08, 2017 at 11:38:21AM +0200, Vlastimil Babka wrote:
>>
>> Undecided if it's really needed. This is IMHO not the classical case
>> from Documentation/core-api/atomic_ops.rst where we have to make
>> modifications visible before we let others see them? Here the one who is
>> freezing is doing it so others can't get their page pin and interfere
>> with the freezer's work. But maybe there are some (documented or not)
>> consistency guarantees to expect once you obtain the pin, that can be
>> violated, or they might be added later, so it would be safer to add the
>> barrier?
> 
> The problem comes if the unfreeze is reordered so that it happens before the
> freezer has performed its work. For example, in
> migrate_huge_page_move_mapping:
> 
> 
> 	if (!page_ref_freeze(page, expected_count)) {
> 		spin_unlock_irq(&mapping->tree_lock);
> 		return -EAGAIN;
> 	}
> 
> 	newpage->index = page->index;
> 	newpage->mapping = page->mapping;
> 
> 	get_page(newpage);
> 
> 	radix_tree_replace_slot(&mapping->page_tree, pslot, newpage);
> 
> 	page_ref_unfreeze(page, expected_count - 1);
> 
> 
> then there's nothing stopping the CPU (and potentially the compiler) from
> reordering the unfreeze call so that it effectively becomes:
> 
> 
> 	if (!page_ref_freeze(page, expected_count)) {
> 		spin_unlock_irq(&mapping->tree_lock);
> 		return -EAGAIN;
> 	}
> 
> 	page_ref_unfreeze(page, expected_count - 1);
> 
> 	newpage->index = page->index;
> 	newpage->mapping = page->mapping;
> 
> 	get_page(newpage);
> 
> 	radix_tree_replace_slot(&mapping->page_tree, pslot, newpage);
> 
> 
> which then means that the freezer's work is carried out without the page
> being frozen.

But in this example the modifications are for newpage and freezing is
for page, so I think it doesn't apply. But I get the point.

> Will
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
