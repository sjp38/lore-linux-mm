Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1F55E6B484B
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 18:04:30 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id d40-v6so1206293pla.14
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 15:04:30 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v10-v6si2148040pfj.354.2018.08.28.15.04.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 Aug 2018 15:04:28 -0700 (PDT)
Date: Tue, 28 Aug 2018 15:04:27 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 01/10] cramfs: Convert to use vmf_insert_mixed
Message-ID: <20180828220427.GA11400@bombadil.infradead.org>
References: <20180828145728.11873-1-willy@infradead.org>
 <20180828145728.11873-2-willy@infradead.org>
 <nycvar.YSQ.7.76.1808281235060.10215@knanqh.ubzr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <nycvar.YSQ.7.76.1808281235060.10215@knanqh.ubzr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolas Pitre <nicolas.pitre@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 28, 2018 at 01:49:25PM -0400, Nicolas Pitre wrote:
> On Tue, 28 Aug 2018, Matthew Wilcox wrote:
> > -			ret = vm_insert_mixed(vma, vma->vm_start + off, pfn);
> > +			vmf = vmf_insert_mixed(vma, vma->vm_start + off, pfn);
> > +			if (vmf & VM_FAULT_ERROR) {
> > +				pages = i;
> > +				break;
> > +			}
> 
> I'd suggest this to properly deal with errers instead:
> 
> -			ret = vm_insert_mixed(vma, vma->vm_start + off, pfn);
> +			vmf = vmf_insert_mixed(vma, vma->vm_start + off, pfn);
> +			if (vmf & VM_FAULT_ERROR)
> +				ret = vm_fault_to_errno(vmf, 0);

By my reading of this function, the intent is actually to return 0
here and allow demand paging to work.  Of course, I've spent all of
twenty minutes staring at this function, so I defer to the maintainer.
I think you'd need to be running a make-memory-allocations-fail fuzzer
to hit this, so it's likely never been tested.
