Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 4074A2802AF
	for <linux-mm@kvack.org>; Mon,  6 Jul 2015 09:49:38 -0400 (EDT)
Received: by pacgz10 with SMTP id gz10so22154877pac.3
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 06:49:38 -0700 (PDT)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com. [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id ja7si3448138pbd.141.2015.07.06.06.49.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jul 2015 06:49:37 -0700 (PDT)
Received: by pdbdz6 with SMTP id dz6so11258695pdb.0
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 06:49:37 -0700 (PDT)
Date: Mon, 6 Jul 2015 22:48:50 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH v5 6/7] zsmalloc: account the number of compacted pages
Message-ID: <20150706134850.GB663@swordfish>
References: <1436185070-1940-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1436185070-1940-7-git-send-email-sergey.senozhatsky@gmail.com>
 <20150706132249.GA16529@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150706132249.GA16529@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (07/06/15 22:22), Minchan Kim wrote:
> On Mon, Jul 06, 2015 at 09:17:49PM +0900, Sergey Senozhatsky wrote:
> > Compaction returns back to zram the number of migrated objects,
> > which is quite uninformative -- we have objects of different
> > sizes so user space cannot obtain any valuable data from that
> > number. Change compaction to operate in terms of pages and
> > return back to compaction issuer the number of pages that
> > were freed during compaction. So from now on `num_compacted'
> > column in zram<id>/mm_stat represents more meaningful value:
> > the number of freed (compacted) pages.
> 
> Fair enough.
>  
> The main reason I introduced num_migrated is to investigate
> the effieciency of compaction. ie, num_freed / num_migrated.
> However, I didn't put num_freed at that time so I can't get 
> my goal with only num_migrated.
>  
> We could put new knob num_compacted as well as num_migrated
> but I don't think we need it now. Zram's compaction would be
> much efficient compared to VM's compaction because we don't
> have any non-movable objects in zspages and we can account
> exact number of free slots.
> 
> So, I want to change name from num_migrated to num_compacted
> and maintain only it which is more useful for admin, you said.
> 
> It's not far since we introduced num_migrated so I don't think
> change name wouldn't be a big problem for userspace,(I hope).
> 

Hello,

Yes, num_migrated rename patch was on my table.
I was thinking about two variants:

struct zs_pool
  atomic_long_t		pages_allocated;
  unsigned long		num_compacted;

or

struct zs_pool
  atomic_long_t		pages_allocated;
  unsigned long		pages_compacted;

the latter looks even better I think. But I didn't come up with a
sane API name to get these stats-- zs_get_pages_compacted() is a bit
misleading. So I decided to keep num_compacted to make the patch set
smaller.

Hm, exporting a new `struct zs_pool_stat' to zram is probably a good
way to go.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
