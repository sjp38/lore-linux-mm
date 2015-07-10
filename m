Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id C3B776B0038
	for <linux-mm@kvack.org>; Fri, 10 Jul 2015 01:34:11 -0400 (EDT)
Received: by pdbep18 with SMTP id ep18so177958875pdb.1
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 22:34:11 -0700 (PDT)
Received: from mail-pd0-x235.google.com (mail-pd0-x235.google.com. [2607:f8b0:400e:c02::235])
        by mx.google.com with ESMTPS id pn8si12046366pbb.126.2015.07.09.22.34.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 22:34:11 -0700 (PDT)
Received: by pdbqm3 with SMTP id qm3so34170028pdb.0
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 22:34:10 -0700 (PDT)
Date: Fri, 10 Jul 2015 14:34:41 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zsmalloc: consider ZS_ALMOST_FULL as migrate source
Message-ID: <20150710053441.GD692@swordfish>
References: <1436491929-6617-1-git-send-email-minchan@kernel.org>
 <20150710015828.GA692@swordfish>
 <20150710022910.GA18266@blaptop>
 <20150710041929.GC692@swordfish>
 <20150710052113.GA11329@bgram>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150710052113.GA11329@bgram>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Nitin Gupta <ngupta@vflare.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On (07/10/15 14:21), Minchan Kim wrote:
> > I mean I find your argument that some level of fragmentation
> > can be of use to be valid, to some degree.
> 
> The benefit I had in mind was to prevent failure of allocation.
> 

Sure. I tested the patch.

cat /sys/block/zram0/mm_stat
3122102272 2882639758 2890366976        0 2969432064       55    79294

cat /sys/block/zram0/stat
    7212        0    57696       73  7513254        0 60106032    52096     0    52106    52113

Compaction stats:

[14637.002961] compaction nr:89 (full:528 part:3027)  ~= 0.148

Nothing `alarming'.


> > I'm thinking now, does it make sense to try harder here? if we
> > failed to alloc_zspage(), then may be we can try any of unused
> > objects from a 'upper' (larger/next) class?  there might be a
> > plenty of them.
> 
> I actually thought about that but I didn't have any report from
> community and product division of my compamy until now.
> But with auto-compaction, the chance would be higher than old
> so let's keep an eye on it(I think users can find it easily because
> swap layer emits "write write failure").
> 
> If it happens(ie, any report from someone), we could try to compact
> and then if it fails, we could fall back to upper class as a last
> resort.
> 

OK.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
