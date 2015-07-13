Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id CE4296B0256
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 11:00:27 -0400 (EDT)
Received: by wiga1 with SMTP id a1so72168568wig.0
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 08:00:27 -0700 (PDT)
Received: from lb3-smtp-cloud3.xs4all.net (lb3-smtp-cloud3.xs4all.net. [194.109.24.30])
        by mx.google.com with ESMTPS id sa13si30258691wjb.198.2015.07.13.08.00.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 13 Jul 2015 08:00:26 -0700 (PDT)
Message-ID: <55A3D24F.6090208@xs4all.nl>
Date: Mon, 13 Jul 2015 16:59:27 +0200
From: Hans Verkuil <hverkuil@xs4all.nl>
MIME-Version: 1.0
Subject: Re: [PATCH 0/9 v7] Helper to abstract vma handling in media layer
References: <1436799351-21975-1-git-send-email-jack@suse.com>
In-Reply-To: <1436799351-21975-1-git-send-email-jack@suse.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.com>
Cc: linux-media@vger.kernel.org, Mauro Carvalho Chehab <mchehab@osg.samsung.com>, linux-samsung-soc@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>

On 07/13/2015 04:55 PM, Jan Kara wrote:
> From: Jan Kara <jack@suse.cz>
> 
>   Hello,
> 
> I'm sending the seventh version of my patch series to abstract vma handling
> from the various media drivers. Since the previous version there are just
> minor cleanups and fixes (see detailed changelog at the end of the email).
> 
> After this patch set drivers have to know much less details about vmas, their
> types, and locking. Also quite some code is removed from them. As a bonus
> drivers get automatically VM_FAULT_RETRY handling. The primary motivation for
> this series is to remove knowledge about mmap_sem locking from as many places a
> possible so that we can change it with reasonable effort.
> 
> The core of the series is the new helper get_vaddr_frames() which is given a
> virtual address and it fills in PFNs / struct page pointers (depending on VMA
> type) into the provided array. If PFNs correspond to normal pages it also grabs
> references to these pages. The difference from get_user_pages() is that this
> function can also deal with pfnmap, and io mappings which is what the media
> drivers need.
> 
> I have tested the patches with vivid driver so at least vb2 code got some
> exposure. Conversion of other drivers was just compile-tested (for x86 so e.g.
> exynos driver which is only for Samsung platform is completely untested).
> 
> Hans, can you please pull the changes? Thanks!

Scheduled for Friday or the following Monday!

Thanks,

	Hans

> 
> 								Honza
> 
> Changes since v6:
> * Fixed compilation error introduced into exynos driver
> * Folded patch allowing get_vaddr_pfn() code to be selected by a config option
>   into previous patches
> * Rebased on top of linux-media tree
> 
> Changes since v5:
> * Moved mm helper into a separate file and behind a config option
> * Changed the first patch pushing mmap_sem down in videobuf2 core to avoid
>   possible deadlock
> 
> Changes since v4:
> * Minor cleanups and fixes pointed out by Mel and Vlasta
> * Added Acked-by tags
> 
> Changes since v3:
> * Added include <linux/vmalloc.h> into mm/gup.c as it's needed for some archs
> * Fixed error path for exynos driver
> 
> Changes since v2:
> * Renamed functions and structures as Mel suggested
> * Other minor changes suggested by Mel
> * Rebased on top of 4.1-rc2
> * Changed functions to get pointer to array of pages / pfns to perform
>   conversion if necessary. This fixes possible issue in the omap I may have
>   introduced in v2 and generally makes the API less errorprone.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-media" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
