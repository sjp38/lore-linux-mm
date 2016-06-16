Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CA6E26B025E
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 05:23:46 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g62so93696201pfb.3
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 02:23:46 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id xs2si8154787pab.43.2016.06.16.02.23.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Jun 2016 02:23:46 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id i123so696753pfg.3
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 02:23:46 -0700 (PDT)
Date: Thu, 16 Jun 2016 18:23:45 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [next-20160615] kernel BUG at mm/rmap.c:1251!
Message-ID: <20160616092345.GC432@swordfish>
References: <20160616084656.GB432@swordfish>
 <20160616085836.GC6836@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160616085836.GC6836@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On (06/16/16 10:58), Michal Hocko wrote:
> > [..]
> > [  272.687656] vma ffff8800b855a5a0 start 00007f3576d58000 end 00007f3576f66000
> >                next ffff8800b977d2c0 prev ffff8800bdfb1860 mm ffff8801315ff200
> >                prot 8000000000000025 anon_vma ffff8800b7e583b0 vm_ops           (null)
> >                pgoff 7f3576d58 file           (null) private_data           (null)
> >                flags: 0x100073(read|write|mayread|maywrite|mayexec|account)
> > [  272.691793] ------------[ cut here ]------------
> > [  272.692820] kernel BUG at mm/rmap.c:1251!
> 
> Is this?
> page_add_new_anon_rmap:
> 	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma)
> [...]

I think it is

1248 void page_add_new_anon_rmap(struct page *page,
1249         struct vm_area_struct *vma, unsigned long address, bool compound)
1250 {
1251         int nr = compound ? hpage_nr_pages(page) : 1;
1252
1253         VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
1254         __SetPageSwapBacked(page);

> > [  272.727842] BUG: sleeping function called from invalid context at include/linux/sched.h:2960
> 
> If yes then I am not sure we can do much about the this part. BUG_ON in
> an atomic context is unfortunate but the BUG_ON points out a real bug so
> we shouldn't drop it because of the potential atomic context. The above
> VM_BUG_ON should definitely be addressed. I thought that Vlastimil has
> pointed out some issues with the khugepaged lock inconsistencies which
> might lead to issues like this.

collapse_huge_page() ->mmap_sem fixup patch (http://marc.info/?l=linux-mm&m=146495692807404&w=2)
is in next-20160615. or do you mean some other patch?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
