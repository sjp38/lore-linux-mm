Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 3EBC96B0032
	for <linux-mm@kvack.org>; Thu,  4 Dec 2014 01:49:07 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id v10so11621820pde.26
        for <linux-mm@kvack.org>; Wed, 03 Dec 2014 22:49:06 -0800 (PST)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id zs6si9670477pac.109.2014.12.03.22.49.04
        for <linux-mm@kvack.org>;
        Wed, 03 Dec 2014 22:49:05 -0800 (PST)
Message-ID: <548003F1.2080004@lge.com>
Date: Thu, 04 Dec 2014 15:49:21 +0900
From: =?UTF-8?B?IuuwleyKue2YuC/ssYXsnoTsl7Dqtazsm5AvU1cgUGxhdGZvcm0o7JewKQ==?=
 =?UTF-8?B?QU9U7YyAKHNldW5naG8xLnBhcmtAbGdlLmNvbSki?=
 <seungho1.park@lge.com>
MIME-Version: 1.0
Subject: Re: [RFC 0/6] zsmalloc support compaction
References: <1417488587-28609-1-git-send-email-minchan@kernel.org>
In-Reply-To: <1417488587-28609-1-git-send-email-minchan@kernel.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Dan Streetman <ddstreet@ieee.org>, Seth Jennings <sjennings@variantweb.net>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Luigi Semenzato <semenzato@google.com>, Jerome Marchand <jmarchan@redhat.com>, juno.choi@lge.com

Hi, Minchan.

I have a question.
The problem mentioned can't be resolved with compaction?
Is there any reason that zsmalloc pages can't be moved by compaction
operation in direct reclaim?

2014-12-02 i??i ? 11:49i?? Minchan Kim i?'(e??) i?' e,?:
> Recently, there was issue about zsmalloc fragmentation and
> I got a report from Juno that new fork failed although there
> are plenty of free pages in the system.
> His investigation revealed zram is one of the culprit to make
> heavy fragmentation so there was no more contiguous 16K page
> for pgd to fork in the ARM.
>
> This patchset implement *basic* zsmalloc compaction support
> and zram utilizes it so admin can do
> 	"echo 1 > /sys/block/zram0/compact"
>
> Actually, ideal is that mm migrate code is aware of zram pages and
> migrate them out automatically without admin's manual opeartion
> when system is out of contiguous page. Howver, we need more thinking
> before adding more hooks to migrate.c. Even though we implement it,
> we need manual trigger mode, too so I hope we could enhance
> zram migration stuff based on this primitive functions in future.
>
> I just tested it on only x86 so need more testing on other arches.
> Additionally, I should have a number for zsmalloc regression
> caused by indirect layering. Unfortunately, I don't have any
> ARM test machine on my desk. I will get it soon and test it.
> Anyway, before further work, I'd like to hear opinion.
>
> Pathset is based on v3.18-rc6-mmotm-2014-11-26-15-45.
>
> Thanks.
>
> Minchan Kim (6):
>    zsmalloc: expand size class to support sizeof(unsigned long)
>    zsmalloc: add indrection layer to decouple handle from object
>    zsmalloc: implement reverse mapping
>    zsmalloc: encode alloced mark in handle object
>    zsmalloc: support compaction
>    zram: support compaction
>
>   drivers/block/zram/zram_drv.c |  24 ++
>   drivers/block/zram/zram_drv.h |   1 +
>   include/linux/zsmalloc.h      |   1 +
>   mm/zsmalloc.c                 | 596 +++++++++++++++++++++++++++++++++++++-----
>   4 files changed, 552 insertions(+), 70 deletions(-)
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
