Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id E21D16B0279
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 11:26:02 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id v102so8946395wrc.8
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 08:26:02 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e2si1567765wra.56.2017.06.09.08.26.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Jun 2017 08:26:01 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v59FNv7c143314
	for <linux-mm@kvack.org>; Fri, 9 Jun 2017 11:25:59 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2ayqjvvrys-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 09 Jun 2017 11:25:59 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 9 Jun 2017 16:25:57 +0100
Subject: Re: [RFC v4 00/20] Speculative page faults
References: <1497018069-17790-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170609150126.GI21764@dhcp22.suse.cz>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Fri, 9 Jun 2017 17:25:51 +0200
MIME-Version: 1.0
In-Reply-To: <20170609150126.GI21764@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <83cf1566-3e76-d3fa-10a8-d83bbf9fd568@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com

On 09/06/2017 17:01, Michal Hocko wrote:
> On Fri 09-06-17 16:20:49, Laurent Dufour wrote:
>> This is a port on kernel 4.12 of the work done by Peter Zijlstra to
>> handle page fault without holding the mm semaphore.
>>
>> http://linux-kernel.2935.n7.nabble.com/RFC-PATCH-0-6-Another-go-at-speculative-page-faults-tt965642.html#none
>>
>> Compared to the Peter initial work, this series introduce a try spin
>> lock when dealing with speculative page fault. This is required to
>> avoid dead lock when handling a page fault while a TLB invalidate is
>> requested by an other CPU holding the PTE. Another change due to a
>> lock dependency issue with mapping->i_mmap_rwsem.
>>
>> This series also protect changes to VMA's data which are read or
>> change by the page fault handler. The protections is done through the
>> VMA's sequence number.
>>
>> This series is functional on x86 and PowerPC.
>>
>> It's building on top of v4.12-rc4 and relies on the change done by
>> Paul McKenney to the SRCU code allowing better performance by
>> maintaining per-CPU callback lists:
>>
>> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=da915ad5cf25b5f5d358dd3670c3378d8ae8c03e
>>
>> Tests have been made using a large commercial in-memory database on a
>> PowerPC system with 752 CPUs. The results are very encouraging since
>> the loading of the 2TB database was faster by 20% with the speculative
>> page fault.
>>
>> Since tests are encouraging and running test suite didn't raise any
>> issue, I'd like this request for comment series to move to a patch
>> series soon. So please feel free to comment.
> 
> What other testing have you done? Other benchmarks (some numbers)? What
> about some standard worklaods like kbench? This is a pretty invasive
> change so I would expect much more numbers.

Thanks Michal for your feedback.

I mostly focused on this database workload since this is the one where
we hit the mmap_sem bottleneck when running on big node. On my usual
victim node, I checked for basic usage like kernel build time, but I
agree that's clearly not enough.

I try to find details about the 'kbench' you mentioned, but I didn't get
any valid entry.
Would you please point me on this or any other bench tool you think will
be useful here ?

> 
> It would also help to describe the highlevel design of the change here
> in the cover letter. This would make the review of specifics much
> easier.

You're right, I'll try to make a highlevel design.

Thanks,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
