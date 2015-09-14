Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 003726B0253
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 14:20:36 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so143564816wic.0
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 11:20:36 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id w11si18806092wie.106.2015.09.14.11.20.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 11:20:35 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so151506756wic.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 11:20:35 -0700 (PDT)
Date: Mon, 14 Sep 2015 21:20:33 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: LTP regressions due to 6dc296e7df4c ("mm: make sure all file
 VMAs have ->vm_ops set")
Message-ID: <20150914182033.GA4165@node.dhcp.inet.fi>
References: <20150914105346.GB23878@arm.com>
 <20150914115800.06242CE@black.fi.intel.com>
 <20150914170547.GA28535@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150914170547.GA28535@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Will Deacon <will.deacon@arm.com>, hpa@zytor.com, luto@amacapital.net, dave.hansen@linux.intel.com, mingo@elte.hu, minchan@kernel.org, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Sep 14, 2015 at 07:05:47PM +0200, Oleg Nesterov wrote:
> On 09/14, Kirill A. Shutemov wrote:
> >
> > Fix is below. I don't really like it, but I cannot find any better
> > solution.
> 
> Me too...
> 
> But this change "documents" the nasty special "vm_file && !vm_ops" case, and
> I am not sure how we can remove it later...
> 
> So perhaps we should change vma_is_anonymous() back to check ->fault too,
> 
> 	 static inline bool vma_is_anonymous(struct vm_area_struct *vma)
> 	 {
> 	-	return !vma->vm_ops;
> 	+	return !vma->vm_ops || !vma->vm_ops->fault;

No. This would give a lot false positives from drives which setup page
tables upfront and don't use ->fault at all.

> 	 }
> 
> and remove the "vma->vm_file && !vma->vm_ops" checks in mmap_region() paths.
> 
> I dunno.
> 
> Oleg.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
