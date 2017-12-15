Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 03FB16B025F
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 14:36:01 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id u4so16396755iti.2
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 11:36:00 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 135si6700436itp.126.2017.12.15.11.35.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 11:36:00 -0800 (PST)
Date: Fri, 15 Dec 2017 11:35:51 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [Question ]: Avoid kernel panic when killing an application if
 happen RAS page table error
Message-ID: <20171215193551.GD27160@bombadil.infradead.org>
References: <0184EA26B2509940AA629AE1405DD7F2019C8B36@DGGEMA503-MBS.china.huawei.com>
 <20171205165727.GG3070@tassilo.jf.intel.com>
 <0276f3b3-94a5-8a47-dfb7-8773cd2f99c5@huawei.com>
 <dedf9af6-7979-12dc-2a52-f00b2ec7f3b6@huawei.com>
 <0b7bb7b3-ae39-0c97-9c0a-af37b0701ab4@huawei.com>
 <eab54efe-0ab4-bf6a-5831-128ff02a018b@huawei.com>
 <5A3419F3.1030804@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5A3419F3.1030804@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Morse <james.morse@arm.com>
Cc: gengdongjiu <gengdongjiu@huawei.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Huangshaoyu <huangshaoyu@huawei.com>, Wuquanming <wuquanming@huawei.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Fri, Dec 15, 2017 at 06:52:35PM +0000, James Morse wrote:
> Leaking any memory that isn't marked as poisoned isn't a good idea.
> 
> What you would need is a way to know from the struct_page that: this page is
> is page-table, and which struct_mm it belongs to. (If its the kernel's init_mm:
> panic()).
> Next you need a way to find all the other pages of page-table without walking
> them. With these three pieces of information you can free all the unaffected
> memory, with even more work you can probably regenerate the corrupted page.
> 
> It's going to be complicated to do, I don't think its worth the effort.

We can find a bit in struct page that we guarantee will only be set if
this is allocated as a pagetable.  Bit 1 of the third union is currently
available (compound_head is a pointer if bit 0 is set, so nothing is
using bit 1).  We can put a pointer to the mm_struct in the same word.

Finding all the allocated pages will be the tricky bit.  We could put a
list_head into struct page; perhaps in the same spot as page_deferred_list
for tail pages.  Then we can link all the pagetables belonging to
this mm together and tear them all down if any of them get an error.
They'll repopulate on demand.  It won't be quick or scalable, but when
the alternative is death, it looks relatively attractive.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
