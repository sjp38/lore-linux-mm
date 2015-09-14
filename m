Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 740066B0253
	for <linux-mm@kvack.org>; Mon, 14 Sep 2015 13:08:42 -0400 (EDT)
Received: by qkfq186 with SMTP id q186so60860653qkf.1
        for <linux-mm@kvack.org>; Mon, 14 Sep 2015 10:08:42 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i201si12886006qhc.95.2015.09.14.10.08.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Sep 2015 10:08:41 -0700 (PDT)
Date: Mon, 14 Sep 2015 19:05:47 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: LTP regressions due to 6dc296e7df4c ("mm: make sure all file
	VMAs have ->vm_ops set")
Message-ID: <20150914170547.GA28535@redhat.com>
References: <20150914105346.GB23878@arm.com> <20150914115800.06242CE@black.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150914115800.06242CE@black.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Will Deacon <will.deacon@arm.com>, hpa@zytor.com, luto@amacapital.net, dave.hansen@linux.intel.com, mingo@elte.hu, minchan@kernel.org, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 09/14, Kirill A. Shutemov wrote:
>
> Fix is below. I don't really like it, but I cannot find any better
> solution.

Me too...

But this change "documents" the nasty special "vm_file && !vm_ops" case, and
I am not sure how we can remove it later...

So perhaps we should change vma_is_anonymous() back to check ->fault too,

	 static inline bool vma_is_anonymous(struct vm_area_struct *vma)
	 {
	-	return !vma->vm_ops;
	+	return !vma->vm_ops || !vma->vm_ops->fault;
	 }

and remove the "vma->vm_file && !vma->vm_ops" checks in mmap_region() paths.

I dunno.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
