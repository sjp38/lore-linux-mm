Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id B91F66B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 06:20:13 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id b126so108456985ite.3
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 03:20:13 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id n5si14279540pab.14.2016.06.16.03.20.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 03:20:13 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id hf6so3468479pac.2
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 03:20:13 -0700 (PDT)
Date: Thu, 16 Jun 2016 19:18:05 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [next-20160615] kernel BUG at mm/rmap.c:1251!
Message-ID: <20160616101805.GE432@swordfish>
References: <20160616084656.GB432@swordfish>
 <20160616085836.GC6836@dhcp22.suse.cz>
 <20160616092345.GC432@swordfish>
 <20160616094139.GE6836@dhcp22.suse.cz>
 <20160616095457.GD432@swordfish>
 <20160616101216.GT17127@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160616101216.GT17127@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (06/16/16 19:12), Minchan Kim wrote:
[..]
> > > > > Is this?
> > > > > page_add_new_anon_rmap:
> > > > > 	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma)
> > > > > [...]
> > > > 
> > > > I think it is
> > > > 
> > > > 1248 void page_add_new_anon_rmap(struct page *page,
> > > > 1249         struct vm_area_struct *vma, unsigned long address, bool compound)
> > > > 1250 {
> > > > 1251         int nr = compound ? hpage_nr_pages(page) : 1;
> > > > 1252
> > > > 1253         VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
> > > > 1254         __SetPageSwapBacked(page);
> > > > 
> > > > > > [  272.727842] BUG: sleeping function called from invalid context at include/linux/sched.h:2960
> > > > > 
> > > > > If yes then I am not sure we can do much about the this part. BUG_ON in
> > > > > an atomic context is unfortunate but the BUG_ON points out a real bug so
> > > > > we shouldn't drop it because of the potential atomic context. The above
> > > > > VM_BUG_ON should definitely be addressed. I thought that Vlastimil has
> > > > > pointed out some issues with the khugepaged lock inconsistencies which
> > > > > might lead to issues like this.
> > > > 
> > > > collapse_huge_page() ->mmap_sem fixup patch (http://marc.info/?l=linux-mm&m=146495692807404&w=2)
> > > > is in next-20160615. or do you mean some other patch?
> > > 
> > > Yes that's what I meant, but I haven't reviewed the patch to see whether
> > > it is correct/complete. It would be good to see whether the issue is
> > > related to those changes.
> > 
> > I'll copy-paste one more backtrace I swa today [originally was posted to another
> > mail thread].
> 
> Please, look at http://lkml.kernel.org/r/20160616100932.GS17127@bbox

oh, yes, sorry. sure, scheduled for testing a bit later today.

Cc Joonsoo, so we can keep the discussion in one place.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
