Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id A92836B0005
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 07:52:25 -0500 (EST)
Received: by mail-wm0-f54.google.com with SMTP id n186so35265544wmn.1
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 04:52:25 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cg14si37149055wjb.226.2016.03.01.04.52.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Mar 2016 04:52:24 -0800 (PST)
Date: Tue, 1 Mar 2016 12:52:16 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC] Support for 1GB THP
Message-ID: <20160301125216.GM2747@suse.de>
References: <20160301070911.GD3730@linux.intel.com>
 <20160301102541.GD27666@quack.suse.cz>
 <20160301110055.GK2747@suse.de>
 <20160301115136.GL2747@suse.de>
 <20160301120919.GA19559@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160301120919.GA19559@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org

On Tue, Mar 01, 2016 at 03:09:19PM +0300, Kirill A. Shutemov wrote:
> On Tue, Mar 01, 2016 at 11:51:36AM +0000, Mel Gorman wrote:
> > While I know some of these points can be countered and discussed further,
> > at the end of the day, the benefits to huge page usage are reduced memory
> > usage on page tables, a reduction of TLB pressure and reduced TLB fill
> > costs. Until such time as it's known that there are realistic workloads
> > that cannot fit in memory due to the page table usage and workloads that
> > are limited by TLB pressure, the complexity of huge pages is unjustified
> > and the focus should be on the basic features working correctly.
> 
> Size of page table can be limiting factor now for workloads that tries to
> migrate from 2M hugetlb with shared page tables to DAX. 1G pages is a way
> to lower the overhead.
> 

That is only a limitation for users of hugetlbfs replacing hugetlbfs pages
with DAX and even then only in the case where the workload is precisely
sized to available memory. It's a potential limitation in a specialised
configuration which may or may not be a problem in practice. Even the
benefits of reduced memory usage and TLB pressure is not guaranteed to
be offset by problems such as flushing the cache lines of the entire huge
page during writeback or the necessity of allocating huge blocks on disk
for a file that may or may not need it. Huge pages fix some problems but
cause others. It may be better in practice for a workload to shrink the
size of the shared region that was previously using hugetlbfs for example.

Granted, I've not been following the development of persistent memory
closely but from what I've seen, I think it's more important to get
persistent memory, DAX and related features working correctly first and
then worry about page table memory usage and TLB pressure *if* it's a
problem in practice. If there are problems with fault scalability then it
would be better to fix that instead of working around it with huge pages.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
