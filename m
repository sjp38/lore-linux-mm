Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id l6DLcuX4006982
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 22:38:58 +0100
Received: from an-out-0708.google.com (anac3.prod.google.com [10.100.54.3])
	by zps75.corp.google.com with ESMTP id l6DLck2c029502
	for <linux-mm@kvack.org>; Fri, 13 Jul 2007 14:38:46 -0700
Received: by an-out-0708.google.com with SMTP id c3so143603ana
        for <linux-mm@kvack.org>; Fri, 13 Jul 2007 14:38:46 -0700 (PDT)
Message-ID: <b040c32a0707131438q64b7f526x6805ec3ee1d0c190@mail.gmail.com>
Date: Fri, 13 Jul 2007 14:38:46 -0700
From: "Ken Chen" <kenchen@google.com>
Subject: Re: [PATCH 5/5] [hugetlb] Try to grow pool for MAP_SHARED mappings
In-Reply-To: <Pine.LNX.4.64.0707131427140.25414@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070713151621.17750.58171.stgit@kernel>
	 <20070713151717.17750.44865.stgit@kernel>
	 <20070713130508.6f5b9bbb.pj@sgi.com>
	 <1184360742.16671.55.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0707131427140.25414@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Adam Litke <agl@us.ibm.com>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, mel@skynet.ie, apw@shadowen.org, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 7/13/07, Christoph Lameter <clameter@sgi.com> wrote:
> On Fri, 13 Jul 2007, Adam Litke wrote:
>
> > To be honest, I just don't think a global hugetlb pool and cpusets are
> > compatible, period.  I wonder if moving to the mempool interface and
>
> Sorry no. We always had per node pools. There is no need to have per
> cpuset pools.

Yeah, per node pool is fine.  But we need per cpuset reservation to
preserve current hugetlb semantics on shared mapping.


> > Hmm, I see what you mean, but cpusets are already broken because we use
> > the global resv_huge_pages counter.  I realize that's what the
> > cpuset_mems_nr() thing was meant to address but it's not correct.
>
> Well the global reserve counter causes a big reduction in performance
> since it requires the serialization of the hugetlb faults. Could we please
> get this straigthened out? This serialization somehow snuck in when I was
> not looking and it screws up multiple things.

Sadly, global serialization has some nice property.  It is now used in
three paths that I'm aware of:
(1) shared mapping reservation count
(2) linked list protection in unmap_hugepage_range
(3) shared page table on hugetlb mapping.

i suppose (2) and (3) can be moved into per-inode lock?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
