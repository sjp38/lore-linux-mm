Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 779A16B003C
	for <linux-mm@kvack.org>; Wed, 23 Jul 2014 10:28:26 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id g10so1697115pdj.26
        for <linux-mm@kvack.org>; Wed, 23 Jul 2014 07:28:26 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id xp7si2712176pab.197.2014.07.23.07.28.25
        for <linux-mm@kvack.org>;
        Wed, 23 Jul 2014 07:28:25 -0700 (PDT)
Date: Wed, 23 Jul 2014 10:27:45 -0400
From: Matthew Wilcox <willy@linux.intel.com>
Subject: Re: [PATCH v8 05/22] Add vm_replace_mixed()
Message-ID: <20140723142745.GD6754@linux.intel.com>
References: <cover.1406058387.git.matthew.r.wilcox@intel.com>
 <b1052af08b49965fd0e6b87b6733b89294c8cc1e.1406058387.git.matthew.r.wilcox@intel.com>
 <20140723114540.GD10317@node.dhcp.inet.fi>
 <20140723135221.GA6754@linux.intel.com>
 <20140723142048.GA11963@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140723142048.GA11963@node.dhcp.inet.fi>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 23, 2014 at 05:20:48PM +0300, Kirill A. Shutemov wrote:
> On Wed, Jul 23, 2014 at 09:52:22AM -0400, Matthew Wilcox wrote:
> > I'd love to use a lighter-weight weapon!  What would you recommend using,
> > zap_pte_range()?
> 
> The most straight-forward way: extract body of pte cycle from
> zap_pte_range() to separate function -- zap_pte() -- and use it.

OK, I can do that.  What about the other parts of zap_page_range(),
do I need to call them?

        lru_add_drain();
        tlb_gather_mmu(&tlb, mm, address, end);
        update_hiwater_rss(mm);
        mmu_notifier_invalidate_range_start(mm, address, end);
[       unmap_single_vma(&tlb, vma, address, end, details);]
        mmu_notifier_invalidate_range_end(mm, address, end);
        tlb_finish_mmu(&tlb, address, end);

> > 	if ((fd = open(argv[1], O_CREAT|O_RDWR, 0666)) < 0) {
> > 		perror(argv[1]);
> > 		exit(1);
> > 	}
> > 
> > 	if (ftruncate(fd, 4096) < 0) {
> 
> Shouldn't this be ftruncate(fd, 0)? Otherwise the memcpy() below will
> fault in page from backing storage, not hole and write will not replace
> anything.

Ah, it was starting with a new file, hence the O_CREAT up above.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
