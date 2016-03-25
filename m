Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id DC52E6B007E
	for <linux-mm@kvack.org>; Fri, 25 Mar 2016 18:53:54 -0400 (EDT)
Received: by mail-wm0-f52.google.com with SMTP id l68so30100313wml.0
        for <linux-mm@kvack.org>; Fri, 25 Mar 2016 15:53:54 -0700 (PDT)
Received: from radon.swed.at (a.ns.miles-group.at. [95.130.255.143])
        by mx.google.com with ESMTPS id om5si16642471wjc.58.2016.03.25.15.53.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 25 Mar 2016 15:53:53 -0700 (PDT)
Subject: Re: [PATCH] UBIFS: Implement ->migratepage()
References: <56E9C658.1020903@nod.at>
 <1458168919-11597-1-git-send-email-richard@nod.at> <56EA7F95.4090703@suse.cz>
From: Richard Weinberger <richard@nod.at>
Message-ID: <56F5C17A.2080707@nod.at>
Date: Fri, 25 Mar 2016 23:53:46 +0100
MIME-Version: 1.0
In-Reply-To: <56EA7F95.4090703@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-mtd@lists.infradead.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, boris.brezillon@free-electrons.com, maxime.ripard@free-electrons.com, david@sigma-star.at, david@fromorbit.com, dedekind1@gmail.com, alex@nextthing.co, akpm@linux-foundation.org, sasha.levin@oracle.com, iamjoonsoo.kim@lge.com, rvaswani@codeaurora.org, tony.luck@intel.com, shailendra.capricorn@gmail.com, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@techsingularity.net>

Am 17.03.2016 um 10:57 schrieb Vlastimil Babka:
> +CC Hugh, Mel
> 
> On 03/16/2016 11:55 PM, Richard Weinberger wrote:
>> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>>
>> When using CMA during page migrations UBIFS might get confused
> 
> It shouldn't be CMA specific, the same code runs from compaction, autonuma balancing...
> 
>> and the following assert triggers:
>> UBIFS assert failed in ubifs_set_page_dirty at 1451 (pid 436)
>>
>> UBIFS is using PagePrivate() which can have different meanings across
>> filesystems. Therefore the generic page migration code cannot handle this
>> case correctly.
>> We have to implement our own migration function which basically does a
>> plain copy but also duplicates the page private flag.
> 
> Lack of PagePrivate() migration is surely a bug, but at a glance of how UBIFS uses the flag, it's more about accounting, it shouldn't prevent a page from being marked PageDirty()?
> I suspect your initial bug (which is IIUC the fact that there's a dirty pte, but PageDirty(page) is false) comes from the generic fallback_migrate_page() which does:
> 
>         if (PageDirty(page)) {
>                 /* Only writeback pages in full synchronous migration */
>                 if (mode != MIGRATE_SYNC)
>                         return -EBUSY;
>                 return writeout(mapping, page);
>         }
> 
> And writeout() seems to Clear PageDirty() through clear_page_dirty_for_io() but I'm not so sure about the pte (or pte's in all rmaps). But this comment in the latter function:
> 
>                  * Yes, Virginia, this is indeed insane.
> 
> scared me enough to not investigate further. Hopefully the people I CC'd understand more about page migration than me. I'm just an user :)
> 
> In any case, this patch would solve both lack of PageDirty() transfer, and avoid the path leading from fallback_migrate_page() to writeout(). But I'm not confident enough here to
> ack it.

Hugh? Mel? Anyone? :-)

It is still not clear to me whether this needs fixing in MM or UBIFS.

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
