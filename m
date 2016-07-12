Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5CFD56B025F
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 21:46:54 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r190so2707481wmr.0
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 18:46:54 -0700 (PDT)
Received: from mail-lf0-x22d.google.com (mail-lf0-x22d.google.com. [2a00:1450:4010:c07::22d])
        by mx.google.com with ESMTPS id 81si12768214ljf.14.2016.07.11.18.46.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jul 2016 18:46:52 -0700 (PDT)
Received: by mail-lf0-x22d.google.com with SMTP id q132so1053088lfe.3
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 18:46:52 -0700 (PDT)
Date: Tue, 12 Jul 2016 04:46:50 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: a question about protection_map[]
Message-ID: <20160712014650.GA18041@node>
References: <5783710E.3070602@huawei.com>
 <20160711133015.GA8028@node.shutemov.name>
 <57844872.1060806@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57844872.1060806@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: alan@lxorguk.ukuu.org.uk, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 12, 2016 at 09:31:30AM +0800, Xishi Qiu wrote:
> On 2016/7/11 21:30, Kirill A. Shutemov wrote:
> 
> > On Mon, Jul 11, 2016 at 06:12:30PM +0800, Xishi Qiu wrote:
> >> Hi,
> >>
> >> We can use mprotect to set read only or read/write.
> >>
> >> mprotect_fixup()
> >> 	vma_set_page_prot()
> >> 		vm_pgprot_modify()
> >> 			vm_get_page_prot()
> >> 				protection_map[vm_flags & (VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)]
> >>
> >> The following code shows that prots from __P001(PROT_READ) and __P010(PROT_WRITE)
> >> are the same, so how does it distinguish read only or read/write from mprotect?
> > 
> > It doesn't.
> > 
> > Write protection will be removed by fault handler on next write access to
> > the page. Somewhat suboptiomal, but zero page implemenation relies on this
> > to work properly.
> > 
> 
> Hi Kirill,
> 
> I know, PAGE_READONLY and PAGE_COPY are both missed _PAGE_RW,
> so it will cause page fault, then we will set new prot flag from
> vma, right?

Yes. See wp_page_reuse().

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
