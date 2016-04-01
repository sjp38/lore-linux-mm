Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id E6A526B025E
	for <linux-mm@kvack.org>; Fri,  1 Apr 2016 06:13:38 -0400 (EDT)
Received: by mail-wm0-f49.google.com with SMTP id p65so16824494wmp.0
        for <linux-mm@kvack.org>; Fri, 01 Apr 2016 03:13:38 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ws8si16072757wjc.16.2016.04.01.03.13.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Apr 2016 03:13:37 -0700 (PDT)
Subject: Re: UBIFS and page migration (take 2)
References: <1459461513-31765-1-git-send-email-richard@nod.at>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56FE49CD.1000302@suse.cz>
Date: Fri, 1 Apr 2016 12:13:33 +0200
MIME-Version: 1.0
In-Reply-To: <1459461513-31765-1-git-send-email-richard@nod.at>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>, linux-fsdevel@vger.kernel.org
Cc: linux-mtd@lists.infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, boris.brezillon@free-electrons.com, maxime.ripard@free-electrons.com, david@sigma-star.at, david@fromorbit.com, dedekind1@gmail.com, alex@nextthing.co, akpm@linux-foundation.org, sasha.levin@oracle.com, iamjoonsoo.kim@lge.com, rvaswani@codeaurora.org, tony.luck@intel.com, shailendra.capricorn@gmail.com, kirill.shutemov@linux.intel.com, hch@infradead.org, hughd@google.com, mgorman@techsingularity.net

On 03/31/2016 11:58 PM, Richard Weinberger wrote:
> During page migrations UBIFS gets confused. We triggered this by using CMA
> on two different targets.
> It turned out that fallback_migrate_page() is not suitable for UBIFS as it
> does not copy the PagePrivate flag.
> UBIFS is using this flag among with PageChecked to account free space.
> One possible solution is implementing a ->migratepage() function in UBIFS
> which does more or less the same as fallback_migrate_page() but also
> copies PagePrivate. I'm not at all sure whether this is they way to go.
> IMHO either page migration should not happen if ->migratepage() is not implement
> or fallback_migrate_page() has to work for all filesystems.

Yes, we could document more thoroughly the expectations of 
fallback_migrate_page() and audit the existing users, but still relying on every 
new address_space_operations instance to verify them isn't without risk. And I 
doubt there can be a default fallback that's guaranteed safe for all filesystems.

> Comments? Flames? :-)
>
> Thanks,
> //richard
>
> [PATCH 1/2] mm: Export migrate_page_move_mapping and
> [PATCH 2/2] UBIFS: Implement ->migratepage()
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
