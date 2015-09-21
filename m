Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 697936B0255
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 11:27:48 -0400 (EDT)
Received: by igcpb10 with SMTP id pb10so81071464igc.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 08:27:48 -0700 (PDT)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com. [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id k102si17405068ioi.138.2015.09.21.08.27.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 08:27:47 -0700 (PDT)
Received: by igbkq10 with SMTP id kq10so81123188igb.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 08:27:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAMJBoFNmK94yPL7GkRPyeyETn8_dC+zCvd8efEH=ncgPDyuJuQ@mail.gmail.com>
References: <20150916134857.e4a71f601a1f68cfa16cb361@gmail.com>
 <20150916135048.fbd50fac5e91244ab9731b82@gmail.com> <55FAB985.9060705@suse.cz>
 <CAMJBoFNmK94yPL7GkRPyeyETn8_dC+zCvd8efEH=ncgPDyuJuQ@mail.gmail.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Mon, 21 Sep 2015 11:27:08 -0400
Message-ID: <CALZtONA=z_NniVg9jz+vESL0QgSvLZsDU+oBkQrJRmco=Yv24g@mail.gmail.com>
Subject: Re: [PATCH 1/2] zbud: allow PAGE_SIZE allocations
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Fri, Sep 18, 2015 at 4:03 AM, Vitaly Wool <vitalywool@gmail.com> wrote:
>> I don't know how zsmalloc handles uncompressible PAGE_SIZE allocations, but
>> I wouldn't expect it to be any more clever than this? So why duplicate the
>> functionality in zswap and zbud? This could be handled e.g. at the zpool
>> level? Or maybe just in zram, as IIRC in zswap (frontswap) it's valid just
>> to reject a page and it goes to physical swap.

zpool doesn't actually store pages anywhere; zbud and zsmalloc do the
storing, and they do it in completely different ways.  Storing an
uncompressed page has to be done in zbud and zsmalloc, not zpool.  And
zram can't do it either; zram doesn't actually store pages either, it
relies on zsmalloc to store all its pages.

>
> From what I can see, zsmalloc just allocates pages and puts them into
> a linked list. Using the beginning of a page for storing an internal
> struct is zbud-specific, and so is this patch.

zsmalloc has size "classes" that allow storing "objects" of a specific
size range (i.e. the last class size + 1, up to class size).  the max
size class is:
#define ZS_MAX_ALLOC_SIZE PAGE_SIZE

so zsmalloc is able to store "objects" up to, and including, PAGE_SIZE.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
