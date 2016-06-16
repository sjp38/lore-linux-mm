Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 14FD76B025E
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 06:12:07 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id z189so106754480itg.2
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 03:12:07 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id zq1si8299441pac.130.2016.06.16.03.12.05
        for <linux-mm@kvack.org>;
        Thu, 16 Jun 2016 03:12:06 -0700 (PDT)
Date: Thu, 16 Jun 2016 19:12:16 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [next-20160615] kernel BUG at mm/rmap.c:1251!
Message-ID: <20160616101216.GT17127@bbox>
References: <20160616084656.GB432@swordfish>
 <20160616085836.GC6836@dhcp22.suse.cz>
 <20160616092345.GC432@swordfish>
 <20160616094139.GE6836@dhcp22.suse.cz>
 <20160616095457.GD432@swordfish>
MIME-Version: 1.0
In-Reply-To: <20160616095457.GD432@swordfish>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Thu, Jun 16, 2016 at 06:54:57PM +0900, Sergey Senozhatsky wrote:
> On (06/16/16 11:41), Michal Hocko wrote:
> > On Thu 16-06-16 18:23:45, Sergey Senozhatsky wrote:
> > > On (06/16/16 10:58), Michal Hocko wrote:
> > > > > [..]
> > > > > [  272.687656] vma ffff8800b855a5a0 start 00007f3576d58000 end 00007f3576f66000
> > > > >                next ffff8800b977d2c0 prev ffff8800bdfb1860 mm ffff8801315ff200
> > > > >                prot 8000000000000025 anon_vma ffff8800b7e583b0 vm_ops           (null)
> > > > >                pgoff 7f3576d58 file           (null) private_data           (null)
> > > > >                flags: 0x100073(read|write|mayread|maywrite|mayexec|account)
> > > > > [  272.691793] ------------[ cut here ]------------
> > > > > [  272.692820] kernel BUG at mm/rmap.c:1251!
> > > > 
> > > > Is this?
> > > > page_add_new_anon_rmap:
> > > > 	VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma)
> > > > [...]
> > > 
> > > I think it is
> > > 
> > > 1248 void page_add_new_anon_rmap(struct page *page,
> > > 1249         struct vm_area_struct *vma, unsigned long address, bool compound)
> > > 1250 {
> > > 1251         int nr = compound ? hpage_nr_pages(page) : 1;
> > > 1252
> > > 1253         VM_BUG_ON_VMA(address < vma->vm_start || address >= vma->vm_end, vma);
> > > 1254         __SetPageSwapBacked(page);
> > > 
> > > > > [  272.727842] BUG: sleeping function called from invalid context at include/linux/sched.h:2960
> > > > 
> > > > If yes then I am not sure we can do much about the this part. BUG_ON in
> > > > an atomic context is unfortunate but the BUG_ON points out a real bug so
> > > > we shouldn't drop it because of the potential atomic context. The above
> > > > VM_BUG_ON should definitely be addressed. I thought that Vlastimil has
> > > > pointed out some issues with the khugepaged lock inconsistencies which
> > > > might lead to issues like this.
> > > 
> > > collapse_huge_page() ->mmap_sem fixup patch (http://marc.info/?l=linux-mm&m=146495692807404&w=2)
> > > is in next-20160615. or do you mean some other patch?
> > 
> > Yes that's what I meant, but I haven't reviewed the patch to see whether
> > it is correct/complete. It would be good to see whether the issue is
> > related to those changes.
> 
> I'll copy-paste one more backtrace I swa today [originally was posted to another
> mail thread].

Please, look at http://lkml.kernel.org/r/20160616100932.GS17127@bbox

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
