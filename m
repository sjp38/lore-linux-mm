Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4AA146B000C
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 14:36:24 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id az8-v6so3006177plb.15
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 11:36:24 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 188-v6si4091584pfg.154.2018.07.18.11.36.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 18 Jul 2018 11:36:23 -0700 (PDT)
Date: Wed, 18 Jul 2018 11:36:21 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v2] mm: disallow mapping that conflict for
 devm_memremap_pages()
Message-ID: <20180718183621.GE4949@bombadil.infradead.org>
References: <152909478401.50143.312364396244072931.stgit@djiang5-desk3.ch.intel.com>
 <x49efg04cx8.fsf@segfault.boston.devel.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <x49efg04cx8.fsf@segfault.boston.devel.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Moyer <jmoyer@redhat.com>
Cc: Dave Jiang <dave.jiang@intel.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

On Wed, Jul 18, 2018 at 02:27:31PM -0400, Jeff Moyer wrote:
> Hi, Dave,
> 
> Dave Jiang <dave.jiang@intel.com> writes:
> 
> > When pmem namespaces created are smaller than section size, this can cause
> > issue during removal and gpf was observed:
> >
> > Add code to check whether we have mapping already in the same section and
> > prevent additional mapping from created if that is the case.
> >
> > Signed-off-by: Dave Jiang <dave.jiang@intel.com>
> > ---
> >
> > v2: Change dev_warn() to dev_WARN() to provide helpful backtrace. (Robert E)
> 
> OK, I can reproduce the issue.  What I don't like about your patch is
> that you can still get yourself into trouble.  Just create a namespace
> with a size that isn't aligned to 128MB, and then all further
> create-namespace operations will fail.  The only "fix" is to delete the
> odd-sized namespace and try again.  And that warning message doesn't
> really help the administrator to figure this out.
> 
> Why can't we simply round up to the next section automatically?  Either
> that, or have the kernel export a minimum namespace size of 128MB, and
> have ndctl enforce it?  I know we had some requests for 4MB namespaces,
> but it doesn't sound like those will be very useful if they're going to
> waste 124MB of space.
> 
> Or, we could try to fix this problem of having multiple namespace
> co-exist in the same memblock section.  That seems like the most obvious
> fix, but there must be a reason you didn't pursue it.
> 
> Dave, what do you think is the most viable option?

Just as a reminder, the desire for small pmem devices comes from cloud
usecases where you have teeny tiny layers, each of which might contain a
single package (eg a webserver or a database).  Because you're going to
run tens of thousands of instances, you don't want each machine to keep
a copy of the program text in pagecache; you want to have it in-memory
once and then DAX-map it in each guest.

While it's OK to waste a certain amount of each guest's physical memory,
when you have hundreds or thousands of these tiny layers, it adds up.
