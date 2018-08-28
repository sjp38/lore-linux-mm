Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id C607D6B48BF
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 19:52:06 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id y130-v6so2884405qka.1
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 16:52:06 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k18-v6sor1258676qvi.62.2018.08.28.16.52.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Aug 2018 16:52:05 -0700 (PDT)
Date: Tue, 28 Aug 2018 19:52:03 -0400 (EDT)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: Re: [PATCH 01/10] cramfs: Convert to use vmf_insert_mixed
In-Reply-To: <20180828220427.GA11400@bombadil.infradead.org>
Message-ID: <nycvar.YSQ.7.76.1808281940360.10215@knanqh.ubzr>
References: <20180828145728.11873-1-willy@infradead.org> <20180828145728.11873-2-willy@infradead.org> <nycvar.YSQ.7.76.1808281235060.10215@knanqh.ubzr> <20180828220427.GA11400@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 28 Aug 2018, Matthew Wilcox wrote:

> On Tue, Aug 28, 2018 at 01:49:25PM -0400, Nicolas Pitre wrote:
> > On Tue, 28 Aug 2018, Matthew Wilcox wrote:
> > > -			ret = vm_insert_mixed(vma, vma->vm_start + off, pfn);
> > > +			vmf = vmf_insert_mixed(vma, vma->vm_start + off, pfn);
> > > +			if (vmf & VM_FAULT_ERROR) {
> > > +				pages = i;
> > > +				break;
> > > +			}
> > 
> > I'd suggest this to properly deal with errers instead:
> > 
> > -			ret = vm_insert_mixed(vma, vma->vm_start + off, pfn);
> > +			vmf = vmf_insert_mixed(vma, vma->vm_start + off, pfn);
> > +			if (vmf & VM_FAULT_ERROR)
> > +				ret = vm_fault_to_errno(vmf, 0);
> 
> By my reading of this function, the intent is actually to return 0
> here and allow demand paging to work.  Of course, I've spent all of
> twenty minutes staring at this function, so I defer to the maintainer.

Demand paging is used when the filesystem layout isn't amenable to a 
direct mapping.  It is not a fallback for when we're OOM or some other 
internal errors which ought to be reported immediately.

> I think you'd need to be running a make-memory-allocations-fail fuzzer
> to hit this, so it's likely never been tested.

Well, it has been tested sort of, e.g. when vm_insert_mixed() returned 
an error due to misaligned addresses during development.  Normally, 
vm_insert_mixed() and vmf_insert_mixed() should always succeed, and if 
they don't we certainly don't want to ignore it.


Nicolas
