Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f176.google.com (mail-qc0-f176.google.com [209.85.216.176])
	by kanga.kvack.org (Postfix) with ESMTP id C549C6B0095
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 19:35:22 -0500 (EST)
Received: by mail-qc0-f176.google.com with SMTP id i17so16522782qcy.35
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 16:35:22 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h10si22715690qcm.42.2015.01.05.16.35.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jan 2015 16:35:21 -0800 (PST)
Date: Mon, 5 Jan 2015 19:21:35 -0500
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v2] fs: proc: task_mmu: show page size in
 /proc/<pid>/numa_maps
Message-ID: <20150106002134.GC28105@t510.redhat.com>
References: <734bca19b3a8f4e191ccc9055ad4740744b5b2b6.1420464466.git.aquini@redhat.com>
 <20150105133500.e0ce4b090e6b378c3edc9c56@linux-foundation.org>
 <20150105225504.GC1795@t510.redhat.com>
 <20150105152037.5a33e34652db6b82fcfd46bf@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150105152037.5a33e34652db6b82fcfd46bf@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, jweiner@redhat.com, dave.hansen@linux.intel.com, rientjes@google.com, linux-mm@kvack.org

On Mon, Jan 05, 2015 at 03:20:37PM -0800, Andrew Morton wrote:
> On Mon, 5 Jan 2015 17:55:05 -0500 Rafael Aquini <aquini@redhat.com> wrote:
> 
> > On Mon, Jan 05, 2015 at 01:35:00PM -0800, Andrew Morton wrote:
> > > On Mon,  5 Jan 2015 12:44:31 -0500 Rafael Aquini <aquini@redhat.com> wrote:
> > > 
> > > > This patch introduces 'kernelpagesize_kB' line element to /proc/<pid>/numa_maps
> > > > report file in order to help identifying the size of pages that are backing
> > > > memory areas mapped by a given task. This is specially useful to
> > > > help differentiating between HUGE and GIGANTIC page backed VMAs.
> > > > 
> > > > This patch is based on Dave Hansen's proposal and reviewer's follow-ups
> > > > taken from the following dicussion threads:
> > > >  * https://lkml.org/lkml/2011/9/21/454
> > > 
> > > Dave's changelog contains useful information which this one lacked.  I
> > > stole some of it.
> > > 
> > > : The output of /proc/$pid/numa_maps is in terms of number of pages like
> > > : anon=22 or dirty=54.  Here's some output:
> > > : 
> > > : 7f4680000000 default file=/hugetlb/bigfile anon=50 dirty=50 N0=50
> > > : 7f7659600000 default file=/anon_hugepage\040(deleted) anon=50 dirty=50 N0=50
> > > : 7fff8d425000 default stack anon=50 dirty=50 N0=50
> > > : Looks like we have a stack and a couple of anonymous hugetlbfs
> > > : areas page which both use the same amount of memory.  They don't.
> > > : 
> > > : The 'bigfile' uses 1GB pages and takes up ~50GB of space.  The
> > > : anon_hugepage uses 2MB pages and takes up ~100MB of space while the stack
> > > : uses normal 4k pages.  You can go over to smaps to figure out what the
> > > : page size _really_ is with KernelPageSize or MMUPageSize.  But, I think
> > > : this is a pretty nasty and counterintuitive interface as it stands.
> > > : 
> > > : This patch introduces 'kernelpagesize_kB' line element to
> > > : /proc/<pid>/numa_maps report file in order to help identifying the size of
> > > : pages that are backing memory areas mapped by a given task.  This is
> > > : specially useful to help differentiating between HUGE and GIGANTIC page
> > > : backed VMAs.
> > > : 
> > > : This patch is based on Dave Hansen's proposal and reviewer's follow-ups
> > > : taken from the following dicussion threads:
> > > :  * https://lkml.org/lkml/2011/9/21/454
> > > :  * https://lkml.org/lkml/2014/12/20/66
> > > 
> > > 
> > > > +	seq_printf(m, " kernelpagesize_kB=%lu", vma_kernel_pagesize(vma) >> 10);
> > > 
> > > This changes the format of the numa_maps file and can potentially break
> > > existing parsers.  Please discuss.
> 
> ^^ ??
>
Sorry I overlooked it.

Parsers indeed would have to be adjusted to cope with an extra line element
(they already have to do so, similarly, for the conditional 'huge' hint).
Despite I don't think of it as a showstopper (as is), I think we can consider
moving it to EOL, if its actual printout position turns out to be an issue.
 

For instance, with this patch a numa_maps line would look like the following:

 7ff965200000 default file=/anon_hugepage\040(deleted) huge kernelpagesize_kB=2048 anon=5 dirty=5 N0=5


or it could look like this, if we decide to switch kernelpagesize_kB position to EOL,
for the sake of parsers:

 7ff965200000 default file=/anon_hugepage\040(deleted) huge anon=5 dirty=5 N0=5 kernelpagesize_kB=2048
 


Cheers,
-- Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
