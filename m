Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 688F7828DF
	for <linux-mm@kvack.org>; Fri, 15 Jan 2016 23:10:57 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id ho8so143584581pac.2
        for <linux-mm@kvack.org>; Fri, 15 Jan 2016 20:10:57 -0800 (PST)
Received: from mail-pa0-x243.google.com (mail-pa0-x243.google.com. [2607:f8b0:400e:c03::243])
        by mx.google.com with ESMTPS id wu1si21111512pab.71.2016.01.15.20.10.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Jan 2016 20:10:56 -0800 (PST)
Received: by mail-pa0-x243.google.com with SMTP id pv5so31200070pac.0
        for <linux-mm@kvack.org>; Fri, 15 Jan 2016 20:10:56 -0800 (PST)
Date: Sat, 16 Jan 2016 13:09:13 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v2] zsmalloc: fix migrate_zspage-zs_free race condition
Message-ID: <20160116040913.GA566@swordfish>
References: <1452843551-4464-1-git-send-email-junil0814.lee@lge.com>
 <20160115143434.GA25332@blaptop.local>
 <56991514.9000609@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56991514.9000609@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Minchan Kim <minchan@kernel.org>, Junil Lee <junil0814.lee@lge.com>, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky@gmail.com

On (01/15/16 16:49), Vlastimil Babka wrote:
[..]
> 
> Could you please also help making the changelog more clear?
> 
> >
> >>+		free_obj |= BIT(HANDLE_PIN_BIT);
> >>  		record_obj(handle, free_obj);
> 
> I think record_obj() should use WRITE_ONCE() or something like that.
> Otherwise the compiler is IMHO allowed to reorder this, i.e. first to assign
> free_obj to handle, and then add the PIN bit there.

good note.

... or do both things in record_obj() (per Minchan)

	record_obj(handle, obj)
	{
	        *(unsigned long)handle = obj & ~(1<<HANDLE_PIN_BIT);
	}

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
