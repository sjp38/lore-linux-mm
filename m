Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 7E9F8900016
	for <linux-mm@kvack.org>; Thu,  4 Jun 2015 03:27:56 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so25129257pdb.0
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 00:27:56 -0700 (PDT)
Received: from mail-pd0-x22d.google.com (mail-pd0-x22d.google.com. [2607:f8b0:400e:c02::22d])
        by mx.google.com with ESMTPS id q2si4635164pap.44.2015.06.04.00.27.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Jun 2015 00:27:55 -0700 (PDT)
Received: by pdbqa5 with SMTP id qa5so25128973pdb.0
        for <linux-mm@kvack.org>; Thu, 04 Jun 2015 00:27:55 -0700 (PDT)
Date: Thu, 4 Jun 2015 16:28:16 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [RFC][PATCH 07/10] zsmalloc: introduce auto-compact support
Message-ID: <20150604072816.GB662@swordfish>
References: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
 <1432911928-14654-8-git-send-email-sergey.senozhatsky@gmail.com>
 <20150604045725.GI2241@blaptop>
 <20150604053056.GA662@swordfish>
 <20150604062712.GJ2241@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150604062712.GJ2241@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On (06/04/15 15:27), Minchan Kim wrote:
[..]
> 
> The problem is migration/freeing old zspage/allocating new zspage is
> not a cheap, either.
> If the system has no problem with small fragmented space, there is
> no point to keep such overheads.
>
> So, ideal is we should trigger compaction once we realized system
> is trouble but I don't have any good idea to detect it.
> That's why i wanted to rely on the decision from user via
> compact_threshold_ratio.

that'll be extremly hard to understand knob.

well, we can do something like
-- don't let the number of "CLASS_ALMOST_EMPTY" to become N times greater
than "CLASS_ALMOST_FULL".

or

-- don't let the number of pages in ZS_ALMOST_EMPTY pages to contribute 70%
of class memory usage. that is 70% of all pages allocated for this class belong
to ZS_ALMOST_EMPTY zspages, thus potentially we can compact it.

> > 
> > > It's simple design of mm/compaction.c to prevent pointless overhead
> > > but historically it made pains several times and required more
> > > complicated logics but it's still painful.
> > > 
> > > Other thing I found recently is that it's not always win zsmalloc
> > > for zram is not fragmented. The fragmented space could be used
> > > for storing upcoming compressed objects although it is wasted space
> > > at the moment but if we don't have any hole(ie, fragment space)
> > > via frequent compaction, zsmalloc should allocate a new zspage
> > > which could be allocated on movable pageblock by fallback of
> > > nonmovable pageblock request on highly memory pressure system
> > > so it accelerates fragment problem of the system memory.
> > 
> > yes, but compaction almost always leave classes fragmented. I think
> > it's a corner case, when the number of unused allocated objects was
> > exactly the same as the number of objects that we migrated and the
> > number of migrated objects was exactly N*maxobj_per_zspage, so we
> > left the class w/o any unused objects (OBJ_ALLOCATED == OBJ_USED).
> > classes have 'holes' after compaction.
> > 
> > 
> > > So, I want to pass the policy to userspace.
> > > If we found it's really trobule on userspace, then, we need more
> > > thinking.
> > 
> > well, it can be under config "aggressive compaction" or "automatic
> > compaction" option.
> > 
> 
> If you really want to do it automatically without any feedback
> form the userspace, we should find better algorithm.

ok. I'll drop auto-compaction part for now and will resend
general/minor zsmalloc tweaks today.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
