Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2726F6B0005
	for <linux-mm@kvack.org>; Thu,  8 Mar 2018 17:55:07 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id w23so687231pgv.17
        for <linux-mm@kvack.org>; Thu, 08 Mar 2018 14:55:07 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 94-v6si15502150ple.694.2018.03.08.14.55.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 08 Mar 2018 14:55:05 -0800 (PST)
Date: Thu, 8 Mar 2018 14:55:01 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Change return type to vm_fault_t
Message-ID: <20180308225501.GC29073@bombadil.infradead.org>
References: <20180308130523.GA30642@jordon-HP-15-Notebook-PC>
 <20180308142658.285e0b2ab50b81449783cd4a@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180308142658.285e0b2ab50b81449783cd4a@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Souptick Joarder <jrdr.linux@gmail.com>, linux-mm@kvack.org

On Thu, Mar 08, 2018 at 02:26:58PM -0800, Andrew Morton wrote:
> On Thu, 8 Mar 2018 18:35:23 +0530 Souptick Joarder <jrdr.linux@gmail.com> wrote:
> 
> > Use new return type vm_fault_t for fault handler
> > in struct vm_operations_struct.
> 
> I can't find vm_fault_t?

Way down at the bottom, in mm_types.h.  mm.h is a bit heavyweight,
and we need vm_fault_t in vm_special_mapping->fault.

> > vmf_insert_mixed(), vmf_insert_pfn() and vmf_insert_page()
> > are newly added inline wrapper functions.
> 
> Why?

The various drivers that get converted will need them (or something
similar to them).  I think eventually we can convert vm_insert_foo() into
vmf_insert_foo() and remove these inline wrappers, but these are a good
intermediate step.

> Well if we're going to do this then we should convert all the
> .page_mkwrite() instances and a bunch of other stuff to use vm_fault_t.
> It's a lot of work.  Perhaps we should just keep using "int".

We've had bugs before where drivers returned -EFOO.  And we have this
silly inefficiency where vm_insert_foo() return an errno which (afaict)
every driver then converts into a VM_FAULT code.  Souptick's willing to do
the work; Michal Hocko agrees it's worth doing; I'm willing to supervise.
It seems worth faciitating.
