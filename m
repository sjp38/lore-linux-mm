Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1263FC10F11
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 18:01:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B5A3320835
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 18:01:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B5A3320835
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 416996B0005; Wed, 24 Apr 2019 14:01:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3ECD26B0006; Wed, 24 Apr 2019 14:01:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DC186B0007; Wed, 24 Apr 2019 14:01:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D35616B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 14:01:41 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k56so10324803edb.2
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 11:01:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=qj/1tEFPW+55bJRT6wqNSU5mPK2TPHsMj54JOcS/oZ8=;
        b=IbDpv3RH96qEnMx+tu+BpXoxTxDO8aGbKi7xEdMxJ+Nd1BAwwH7LDSqfRni7jrI/kv
         fxiYSDFGvr7BhilE1yvWAOGasnk+iVE/UgV9QRTIOmDumD7aF2i7wwRmYJurgpy8ZMDE
         UkxcVmMQVfrJYTiWZ83TYHe1qj8rV0K0e96s9sWECyb9yIn/RaLoli5CAOnsX2bQqXNA
         0q0EoJG9pmsj+4XpeeYcUge5gXRdwFV05IrX4P4TuBike+j5/Cklx0vn+3MN1kY1i1k9
         S0HnG2ncgGPAgdxzst+y6RNuh/lslAQVbg7SWtXNK7fCl5vZex/jTwK3wFZ0z4ZsKdAw
         /pCw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWN3tzTpt9wDwgvThj786E70hPoxD5YBEjD1a1FJ/9dVAFhf7GQ
	RWrCtuGBex1WdKyRqwTVZmoYGCGe75I3e+Oko3jKTRXUsr7K2iR7aZwXHs8S9o+ms6pVKkvnOfr
	SvxysJdEjBnqedSVPj2VSLzJwUC/cKa7TDdP2PKT5hvyWUXA8xkImp47jvx/iwZvaLQ==
X-Received: by 2002:a05:6402:180e:: with SMTP id g14mr16931072edy.149.1556128901383;
        Wed, 24 Apr 2019 11:01:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydO7tarkdNBzClUAnDhJ9bta6uRqP8CW+wZXNiKjvEOUC5bfGfaKrOW5m1OOeVozP/Pdoa
X-Received: by 2002:a05:6402:180e:: with SMTP id g14mr16931006edy.149.1556128900336;
        Wed, 24 Apr 2019 11:01:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556128900; cv=none;
        d=google.com; s=arc-20160816;
        b=rKkp5uOPQ28eq8rGHKBtRmkUQDYtE+mKhsFn3altbDdNVpaQCaWXHua2J5bS65cWVw
         QqCBdeypDRbmT5n4sYrXkLqfHMWLI/9Za1i2m4x/D9RnQXLwORK8rN6U5YdRO1WlNDni
         6xF9L5IUd5cuWnZFh+XObdEMEwfZJiXp710E+ZmpdrCeHJp9T43insXGocPydFgBHtdF
         OnCSWvV8acDmctDb1CxdsfKjduQJwEbp6X3kUDx2fst0f1LO2vdqsH7pbkh710uYNt9/
         x8sXQaMwDy9QR21AicSO8/gDD0zLLjYJYJsRNlu3E8ammResznvJqEEQwLngbSMiUR0Q
         iEJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=qj/1tEFPW+55bJRT6wqNSU5mPK2TPHsMj54JOcS/oZ8=;
        b=ZeyUmvfbidUES1G9eqeKT6x5oJcMjkrOGIkYw8WaMBDWDxuvjQbVMR1LCSB+UUplZA
         ZJjO6IO4GyY/E5YoHcJ4pE7Lo19F/3snDnuRnl2dAhukkyDkMn5eWH5gasOy93n/SYSZ
         qT3mpr3WdF1clleNwQL875u6Of6fF/9+SRTS38aN7RxiyO/IOD+8yapnSQM+OviZLbiJ
         p8Ki5cKoS19SQ2v7M2kI4l3JXxoQkd7GBfRyWKDLpSNcVaou5SWTrzRcLL/WGtkarkU/
         1AgtpYG9oaxd3p8NNcIrAd1DQJnfLBQFYjMifbBYwZTmhVbPnCO/dXmR9SQMpD21kuc3
         dkcA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b18si878528ejh.159.2019.04.24.11.01.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 11:01:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3OHsrYR160009
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 14:01:38 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2s2u1bw6p0-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 14:01:38 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Wed, 24 Apr 2019 19:01:36 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp04.uk.ibm.com (192.168.101.134) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Wed, 24 Apr 2019 19:01:26 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3OI1OxR42663952
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 24 Apr 2019 18:01:24 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 527D2AE057;
	Wed, 24 Apr 2019 18:01:24 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 688DDAE05F;
	Wed, 24 Apr 2019 18:01:21 +0000 (GMT)
Received: from [9.145.176.48] (unknown [9.145.176.48])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Wed, 24 Apr 2019 18:01:21 +0000 (GMT)
Subject: Re: [PATCH v12 00/31] Speculative page faults
To: Michel Lespinasse <walken@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Michal Hocko <mhocko@kernel.org>,
        Peter Zijlstra <peterz@infradead.org>,
        "Kirill A. Shutemov" <kirill@shutemov.name>,
        Andi Kleen
 <ak@linux.intel.com>, dave@stgolabs.net,
        Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>,
        aneesh.kumar@linux.ibm.com,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>, mpe@ellerman.id.au,
        Paul Mackerras <paulus@samba.org>,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        "H. Peter Anvin" <hpa@zytor.com>, Will Deacon <will.deacon@arm.com>,
        Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
        sergey.senozhatsky.work@gmail.com,
        Andrea Arcangeli <aarcange@redhat.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com,
        Daniel Jordan <daniel.m.jordan@oracle.com>,
        David Rientjes <rientjes@google.com>,
        Jerome Glisse <jglisse@redhat.com>,
        Ganesh Mahendran <opensource.ganesh@gmail.com>,
        Minchan Kim <minchan@kernel.org>,
        Punit Agrawal <punitagrawal@gmail.com>,
        vinayak menon <vinayakm.list@gmail.com>,
        Yang Shi <yang.shi@linux.alibaba.com>,
        zhong jiang <zhongjiang@huawei.com>,
        Haiyan Song <haiyanx.song@intel.com>,
        Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
        Mike Rapoport <rppt@linux.ibm.com>,
        LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
        haren@linux.vnet.ibm.com, Nick Piggin <npiggin@gmail.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org,
        x86@kernel.org
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <CANN689F1h9XoHPzr_FQY2WfN5bb2TTd6M3HLqoJ-DQuHkNbA7g@mail.gmail.com>
From: Laurent Dufour <ldufour@linux.ibm.com>
Date: Wed, 24 Apr 2019 20:01:20 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <CANN689F1h9XoHPzr_FQY2WfN5bb2TTd6M3HLqoJ-DQuHkNbA7g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19042418-0016-0000-0000-00000273657C
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042418-0017-0000-0000-000032CFD8D0
Message-Id: <aadc7b03-9121-6800-341b-6f2849088a09@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-24_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904240131
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Le 22/04/2019 à 23:29, Michel Lespinasse a écrit :
> Hi Laurent,
> 
> Thanks a lot for copying me on this patchset. It took me a few days to
> go through it - I had not been following the previous iterations of
> this series so I had to catch up. I will be sending comments for
> individual commits, but before tat I would like to discuss the series
> as a whole.

Hi Michel,

Thanks for reviewing this series.

> I think these changes are a big step in the right direction. My main
> reservation about them is that they are additive - adding some complexity
> for speculative page faults - and I wonder if it'd be possible, over the
> long term, to replace the existing complexity we have in mmap_sem retry
> mechanisms instead of adding to it. This is not something that should
> block your progress, but I think it would be good, as we introduce spf,
> to evaluate whether we could eventually get all the way to removing the
> mmap_sem retry mechanism, or if we will actually have to keep both.

Until we get rid of the mmap_sem which seems to be a very long story, I 
can't see how we could get rid of the retry mechanism.

> The proposed spf mechanism only handles anon vmas. Is there a
> fundamental reason why it couldn't handle mapped files too ?
> My understanding is that the mechanism of verifying the vma after
> taking back the ptl at the end of the fault would work there too ?
> The file has to stay referenced during the fault, but holding the vma's
> refcount could be made to cover that ? the vm_file refcount would have
> to be released in __free_vma() instead of remove_vma; I'm not quite sure
> if that has more implications than I realize ?

The only concern is the flow of operation  done in the vm_ops->fault() 
processing. Most of the file system relie on the generic filemap_fault() 
which should be safe to use. But we need a clever way to identify fault 
processing which are compatible with the SPF handler. This could be done 
using a tag/flag in the vm_ops structure or in the vma's flags.

This would be the next step.


> The proposed spf mechanism only works at the pte level after the page
> tables have already been created. The non-spf page fault path takes the
> mm->page_table_lock to protect against concurrent page table allocation
> by multiple page faults; I think unmapping/freeing page tables could
> be done under mm->page_table_lock too so that spf could implement
> allocating new page tables by verifying the vma after taking the
> mm->page_table_lock ?

I've to admit that I didn't dig further here.
Do you have a patch? ;)

> 
> The proposed spf mechanism depends on ARCH_HAS_PTE_SPECIAL.
> I am not sure what is the issue there - is this due to the vma->vm_start
> and vma->vm_pgoff reads in *__vm_normal_page() ?

Yes that's the reason, no way to guarantee the value of these fields in 
the SPF path.

> 
> My last potential concern is about performance. The numbers you have
> look great, but I worry about potential regressions in PF performance
> for threaded processes that don't currently encounter contention
> (i.e. there may be just one thread actually doing all the work while
> the others are blocked). I think one good proxy for measuring that
> would be to measure a single threaded workload - kernbench would be
> fine - without the special-case optimization in patch 22 where
> handle_speculative_fault() immediately aborts in the single-threaded case.

I'll have to give it a try.

> Reviewed-by: Michel Lespinasse <walken@google.com>
> This is for the series as a whole; I expect to do another review pass on
> individual commits in the series when we have agreement on the toplevel
> stuff (I noticed a few things like out-of-date commit messages but that's
> really minor stuff).

Thanks a lot for reviewing this long series.

> 
> I want to add a note about mmap_sem. In the past there has been
> discussions about replacing it with an interval lock, but these never
> went anywhere because, mostly, of the fact that such mechanisms were
> too expensive to use in the page fault path. I think adding the spf
> mechanism would invite us to revisit this issue - interval locks may
> be a great way to avoid blocking between unrelated mmap_sem writers
> (for example, do not delay stack creation for new threads while a
> large mmap or munmap may be going on), and probably also to handle
> mmap_sem readers that can't easily use the spf mechanism (for example,
> gup callers which make use of the returned vmas). But again that is a
> separate topic to explore which doesn't have to get resolved before
> spf goes in.
> 

