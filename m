Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E930E6B02B4
	for <linux-mm@kvack.org>; Wed,  9 Aug 2017 09:41:14 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id o82so62949878pfj.11
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 06:41:14 -0700 (PDT)
Received: from mail-pf0-x229.google.com (mail-pf0-x229.google.com. [2607:f8b0:400e:c00::229])
        by mx.google.com with ESMTPS id x3si2696051plb.978.2017.08.09.06.41.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Aug 2017 06:41:13 -0700 (PDT)
Received: by mail-pf0-x229.google.com with SMTP id t86so28059744pfe.2
        for <linux-mm@kvack.org>; Wed, 09 Aug 2017 06:41:13 -0700 (PDT)
Subject: Re: [PATCH] mm/ksm : Checksum calculation function change (jhash2 ->
 crc32)
References: <1501589255-9389-1-git-send-email-solee@os.korea.ac.kr>
 <20170801200550.GB24406@redhat.com>
 <bf406908-bf93-83dd-54e6-d2e3e5881db6@os.korea.ac.kr>
 <20170803132350.GI21775@redhat.com>
From: sioh Lee <solee@os.korea.ac.kr>
Message-ID: <df5c8e04-280b-c0eb-2820-eff2dce67582@os.korea.ac.kr>
Date: Wed, 9 Aug 2017 22:17:31 +0900
MIME-Version: 1.0
In-Reply-To: <20170803132350.GI21775@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: akpm@linux-foundation.org, mingo@kernel.org, zhongjiang@huawei.com, minchan@kernel.org, arvind.yadav.cs@gmail.com, imbrenda@linux.vnet.ibm.com, kirill.shutemov@linux.intel.com, linux-mm@kvack.org, hxy@os.korea.ac.kr, oslab@os.korea.ac.kr

Hello.
I am sending you the results of the experiments.
The experiment was done for two workloads.
The first is Kernel build (CPU Intensive) and the second is the iozone benchmark (I/O Intensive).
In the experiment, four VMs compile kernel at the same time.
I also experimented with iozone in the same way.


The values measured in the experiment are:
1. CoW count, 2. Checksum computation time, 3. pages_unshared, 4. pages_sharing, 5. (pages_unshared / pages_sharing).
The experiment was conducted twice for each workload and the average value was calculated.
Checksum computation time, pages_unshared, and pages_sharing are recorded every 1 second,
and the average of the recorded values is obtained after the end of the experiment.
The CoW was also recorded whenever CoW occurs on a shared page.

Experiment environment

test platform : openstack cloud platform (NEWTON version)
Experiment node : openstack based cloud compute node (CPU: Xeon E5-2650 v3 2.3Ghz 10core, memory : 64Gb)
VM : (2 VCPU, RAM 4GB, DISK 20GB) * 4
workload : Kernel Compile (kernel 4.47), iozone (read, write, random read and write for 2GB)
KSM setup - sleep_millisecs : 200ms, pages_to_scan : 1600

The experimental results are as follows. (All values are truncated to the second decimal place)

kernel build

Crc32

CoW count    Checksum time (ns)    pages_sharing    pages_unshared    unshared/sharing
  44036.5           903.58                  951660.82          265401.54             0.27

Jhash2
CoW count    Checksum time (ns)    pages_sharing    pages_unshared    unshared/sharing
  46114             4203.33                  949578.19          266564.98            0.28

Increase/Decrease percentage compared to jhash2 (I: Increase, D: Decrease)
CoW count    Checksum time (ns)    pages_sharing    pages_unshared    unshared/sharing
  4.5% D            78.5% D                 0.2% I             0.4% D             0.64% D

For the kernel build workload, the number of CoWs compared to jhash2 decreased by 4.5%, pages_sharing increased by 0.2%,
pages_unshared decreased by 0.4%, checksums computation decreased by 78.5%, and (pages_unshared / pages_sharing) decreased by 0.64%.

iozone

Crc32
CoW count    Checksum time (ns)    pages_sharing    pages_unshared    unshared/sharing
 4288702.5           1139.31             1441299.78         117746.22                0.14

Jhash2
CoW count    Checksum time (ns)    pages_sharing    pages_unshared    unshared/sharing
 4229174              4980.21            1446143.41         116153.12               0.13

Increase/Decrease percentage compared to jhash2 (I: Increase, D: Decrease)
CoW count    Checksum time (ns)    pages_sharing    pages_unshared    unshared/sharing
  1.4% I             77.1% D               0.33% D            1.37% I              1.89% I

For the iozone workload, the number of CoWs compared to jhash2 increased by 1.4%, pages_sharing decreased by 0.33%,
pages_unshared increased by 1.37%, checksums computation decreased by 77.1%, and (pages_unshared / pages_sharing) increased by 1.89%.


In summary, the experiment shows that crc32 has definite advantages over jhash2 for CPU intensive task.
For I/O intensive task, CoW increases only by 1.4% while the checksum computation time is significantly reduced by 77%.


 


2017-08-03 i??i?? 10:23i?? Andrea Arcangeli i?'(e??) i?' e,?:
> On Thu, Aug 03, 2017 at 02:26:27PM +0900, sioh Lee wrote:
>> Thank you very much for reading and responding to my commit.
>> I understand the problem with crc32 you describe.
>> I will investigate a?? as the first step, I will try to compare the number of CoWs with jhash2 and crc32. And I will send you the experiment results.
> Also the number of KSM merges and ideally in a non simple workload. If
> the hash triggers false positives it's not just that there will be
> more CoWs, but the unstable tree will get more unstable and its
> ability to find equality will decrease. This is why I don't like to
> weaken the hash with a crc and I'd rather prefer to keep a real hash
> there (doesn't need to be a crypto one, but it'd be even better if it
> was).
>
> The hash isn't used to find equality, it's only used to find which
> pages are updated frequently (and if an app overwrites the same value
> over and over, not even a crypto hash would be capable to detect it).
>
> There were attempts to replace the hashing with a dirty bit set in
> hardware in the pagetable in fact, that would be the ideal way, but
> it's quite more complicated that way.
>
> Thanks,
> Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
