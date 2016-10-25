Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1A80D6B0272
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 13:31:20 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t25so142811000pfg.3
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 10:31:20 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y71si21771596pfb.71.2016.10.25.10.31.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 10:31:19 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9PHSkmr123567
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 13:31:18 -0400
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26a61djjkf-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 13:31:18 -0400
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 25 Oct 2016 11:31:17 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC 0/8] Define coherent device memory node
In-Reply-To: <20161025153256.GB6131@gmail.com>
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com> <20161024170902.GA5521@gmail.com> <877f8xaurp.fsf@linux.vnet.ibm.com> <20161025153256.GB6131@gmail.com>
Date: Tue, 25 Oct 2016 23:01:08 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87shrkjpyb.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, bsingharora@gmail.com

Jerome Glisse <j.glisse@gmail.com> writes:

> On Tue, Oct 25, 2016 at 10:29:38AM +0530, Aneesh Kumar K.V wrote:
>> Jerome Glisse <j.glisse@gmail.com> writes:
>> > On Mon, Oct 24, 2016 at 10:01:49AM +0530, Anshuman Khandual wrote:
>
> [...]
>
>> > You can take a look at hmm-v13 if you want to see how i do non LRU page
>> > migration. While i put most of the migration code inside hmm_migrate.c it
>> > could easily be move to migrate.c without hmm_ prefix.
>> >
>> > There is 2 missing piece with existing migrate code. First is to put memory
>> > allocation for destination under control of who call the migrate code. Second
>> > is to allow offloading the copy operation to device (ie not use the CPU to
>> > copy data).
>> >
>> > I believe same requirement also make sense for platform you are targeting.
>> > Thus same code can be use.
>> >
>> > hmm-v13 https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-v13
>> >
>> > I haven't posted this patchset yet because we are doing some modifications
>> > to the device driver API to accomodate some new features. But the ZONE_DEVICE
>> > changes and the overall migration code will stay the same more or less (i have
>> > patches that move it to migrate.c and share more code with existing migrate
>> > code).
>> >
>> > If you think i missed anything about lru and page cache please point it to
>> > me. Because when i audited code for that i didn't see any road block with
>> > the few fs i was looking at (ext4, xfs and core page cache code).
>> >
>> 
>> The other restriction around ZONE_DEVICE is, it is not a managed zone.
>> That prevents any direct allocation from coherent device by application.
>> ie, we would like to force allocation from coherent device using
>> interface like mbind(MPOL_BIND..) . Is that possible with ZONE_DEVICE ?
>
> To achieve this we rely on device fault code path ie when device take a page fault
> with help of HMM it will use existing memory if any for fault address but if CPU
> page table is empty (and it is not file back vma because of readback) then device
> can directly allocate device memory and HMM will update CPU page table to point to
> newly allocated device memory.
>

That is ok if the device touch the page first. What if we want the
allocation touched first by cpu to come from GPU ?. Should we always
depend on GPU driver to migrate such pages later from system RAM to GPU
memory ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
