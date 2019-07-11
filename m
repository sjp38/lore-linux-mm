Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41896C74A35
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:41:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1B0F20872
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 14:41:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="BolLQW7s"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1B0F20872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 77BC88E00DF; Thu, 11 Jul 2019 10:41:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 72C428E00DB; Thu, 11 Jul 2019 10:41:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 61AC28E00DF; Thu, 11 Jul 2019 10:41:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4056C8E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 10:41:09 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id k21so7024170ioj.3
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 07:41:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=aUfR+qijy4tbyJgfnbDDEc/MAxhGlji3qcIdztc9KJA=;
        b=q8S63NtzPSM0faPhzvcjzw9MRbeC6SJHMOiL2Cqz3JHENr2OuIBQhDSNxChYo1WECn
         IVkD2AXyAOmhLO96s7t3tm1fZbHh43xGiTDgJqKfrxlPtcYpGs3Gqx8cUh1eSmjdStcn
         0cHmBpbHzIHPyrZpXcVlFFW5uVd6GWmU1cix0W9hUsr9GDgRUMAsUhsMKFz1tkDjQTWQ
         6OaVKQ8CLl6mv40y+aIzSJw4B7uvLmT3rT7pSTiU/pq4Posw5Pp9ZMfmRsKCjv8p52+j
         d16rg9JZSQNrh8EmqwuSMEATQ+XZMX+xNu/2/C1C77V6oZuM8W1/o8SXJQKfwTgbqM1s
         ruPQ==
X-Gm-Message-State: APjAAAVps98PxW7AP0ZkumzMObtNAPBKrB0ExY5jxCu2t7DY6tqBbylh
	tr8Fhg195W5h+mdCp5u3ELsub7TwCFvVne/MDthzRus2rIjHSllGaElWNWvSsMiZuyCMvs3Rrtn
	Ct1bTtx5aWFdJLaTbtjktSBKprmoBySCVT1fe2ejBvh+QFhKKbCNylhLjh1wOtzKkcw==
X-Received: by 2002:a6b:ed09:: with SMTP id n9mr4487623iog.153.1562856068984;
        Thu, 11 Jul 2019 07:41:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyCBEQPJKVDS+Zle59gx81x70J7uRkvIu6EVHQf+4CZMT95anM5ZrYoCqnuXM3hCVuNCE19
X-Received: by 2002:a6b:ed09:: with SMTP id n9mr4487523iog.153.1562856067832;
        Thu, 11 Jul 2019 07:41:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562856067; cv=none;
        d=google.com; s=arc-20160816;
        b=i3aVLkAcXgVHueV6+ODnCkpmYFmrOiNEDm9J0txnZ4O8FcqKbPnYcJouLJ+xxbC9rQ
         HvWqMUqgteGp0oYC/X85lw2o3tviZp6Kni7KbA93jf1fNHArgvdln/li/DR9M0RqNqpI
         V0J+WMxzQyaOUvpynKCa2hEPe0W+4GSXXzTtZFXwu5W0N49ebRtz05pMv/8tX8SuEI2p
         V7YS2P0mM96vkeVErG58r816ArZ3XcgIpza82LYJ3O+V3csvgOVnqRuSRhRGPTZ8Y1bO
         BLwLq+s//ASAw9Y0K5QMbg02mC/iRm6l51DtK3A2CGCE/uelMoPss7za9aP/jUCw0euS
         vLfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=aUfR+qijy4tbyJgfnbDDEc/MAxhGlji3qcIdztc9KJA=;
        b=FYTRe7uFNdKbSRbGteDJyTt4kyxW07lY+I2tYkLjwq92XvRPDEwrrLu+fvWBwZKX+I
         TaGPYfD497O7xEa/a1vIl/QQ11ZX0gQa5jL0QG2b5FpvnRNsSwOuVcT3WW/IfhWloSh4
         8l211EFVsiYY8P7h8gccDoBbJJGM5gHHwHAF6yJ/e0jI/EGNv/GjChFj8GTwl8FgtrN9
         2+30XNl5JGrmqkbBom6reKP/NHbkfZry1Za6JBy1E+jampdSrJstfapTnbWawn7mrUiN
         qWRD1qfQxXg8wjhwxo4B2G3S0j3bZuExChbB0/Mp8KsQp24Psp/eKL2XAjDCn2xXied4
         qKRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=BolLQW7s;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id w8si7901876ioa.65.2019.07.11.07.41.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 07:41:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=BolLQW7s;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6BEcRb9014449;
	Thu, 11 Jul 2019 14:40:57 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=aUfR+qijy4tbyJgfnbDDEc/MAxhGlji3qcIdztc9KJA=;
 b=BolLQW7s71GGDrpThW56GMykHAPrCXu1SbDdp+PSZKqBiBUob2UNBKN+7+8CkMezaHBh
 rm4hInvYlO/F/nUTK7/ZTu7kSSOgThA7X3GUzIEp3MVu70lhTFEXZbEDNPKYpprTEtDA
 LLLtUVU40GmnBgYh2BzxIG9GUKLmTxmmYenEVdxoSih3S9p7/vHCNNYz82oAwemzqOUZ
 fm06DFLOh5XV+Y5VDgnUmFOwIr74S310SMHFPVf/kgiddpoYkigzPDo4RauwYbB1fgXk
 bEBk0RCboIrDA0gTPNuka/2hPMLrjuvnc+9nlaRmUhqgFrP4gJ1peWIGWPKJZsdhuj8l rg== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2130.oracle.com with ESMTP id 2tjk2u0gt7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Jul 2019 14:40:57 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6BEcIX6052568;
	Thu, 11 Jul 2019 14:40:57 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3020.oracle.com with ESMTP id 2tnc8th0hd-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Jul 2019 14:40:56 +0000
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x6BEetbM009351;
	Thu, 11 Jul 2019 14:40:55 GMT
Received: from [10.166.106.34] (/10.166.106.34)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 11 Jul 2019 07:40:54 -0700
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
To: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, graf@amazon.de, rppt@linux.vnet.ibm.com
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
From: Alexandre Chartre <alexandre.chartre@oracle.com>
Organization: Oracle Corporation
Message-ID: <426fe24d-2ae2-782e-fcc1-ad2ede9ee68b@oracle.com>
Date: Thu, 11 Jul 2019 16:40:50 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9314 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1907110165
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9314 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907110165
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


And I've just noticed that I've messed up the subject of the cover letter.
There are 26 patches, not 27. So it should have been 00/26 not 00/27.

Sorry about that.

alex.

On 7/11/19 4:25 PM, Alexandre Chartre wrote:
> Hi,
> 
> This is version 2 of the "KVM Address Space Isolation" RFC. The code
> has been completely changed compared to v1 and it now provides a generic
> kernel framework which provides Address Space Isolation; and KVM is now
> a simple consumer of that framework. That's why the RFC title has been
> changed from "KVM Address Space Isolation" to "Kernel Address Space
> Isolation".
> 
> Kernel Address Space Isolation aims to use address spaces to isolate some
> parts of the kernel (for example KVM) to prevent leaking sensitive data
> between hyper-threads under speculative execution attacks. You can refer
> to the first version of this RFC for more context:
> 
>     https://lkml.org/lkml/2019/5/13/515
> 
> The new code is still a proof of concept. It is much more stable than v1:
> I am able to run a VM with a full OS (and also a nested VM) with multiple
> vcpus. But it looks like there are still some corner cases which cause the
> system to crash/hang.
> 
> I am looking for feedback about this new approach where address space
> isolation is provided by the kernel, and KVM is a just a consumer of this
> new framework.
> 
> 
> Changes
> =======
> 
> - Address Space Isolation (ASI) is now provided as a kernel framework:
>    interfaces for creating and managing an ASI are provided by the kernel,
>    there are not implemented in KVM.
> 
> - An ASI is associated with a page-table, we don't use mm anymore. Entering
>    isolation is done by just updating CR3 to use the ASI page-table. Exiting
>    isolation restores CR3 with the CR3 value present before entering isolation.
> 
> - Isolation is exited at the beginning of any interrupt/exception handler,
>    and on context switch.
> 
> - Isolation doesn't disable interrupt, but if an interrupt occurs the
>    interrupt handler will exit isolation.
> 
> - The current stack is mapped when entering isolation and unmapped when
>    exiting isolation.
> 
> - The current task is not mapped by default, but there's an option to map it.
>    In such a case, the current task is mapped when entering isolation and
>    unmap when exiting isolation.
> 
> - Kernel code mapped to the ASI page-table has been reduced to:
>    . the entire kernel (I still need to test with only the kernel text)
>    . the cpu entry area (because we need the GDT to be mapped)
>    . the cpu ASI session (for managing ASI)
>    . the current stack
> 
> - Optionally, an ASI can request the following kernel mapping to be added:
>    . the stack canary
>    . the cpu offsets (this_cpu_off)
>    . the current task
>    . RCU data (rcu_data)
>    . CPU HW events (cpu_hw_events).
> 
>    All these optional mappings are used for KVM isolation.
>    
> 
> Patches:
> ========
> 
> The proposed patches provides a framework for creating an Address Space
> Isolation (ASI) (represented by a struct asi). The ASI has a page-table which
> can be populated by copying mappings from the kernel page-table. The ASI can
> then be entered/exited by switching between the kernel page-table and the
> ASI page-table. In addition, any interrupt, exception or context switch
> will automatically abort and exit the isolation. Finally patches use the
> ASI framework to implement KVM isolation.
> 
> - 01-03: Core of the ASI framework: create/destroy ASI, enter/exit/abort
>    isolation, ASI page-fault handler.
> 
> - 04-14: Functions to manage, populate and clear an ASI page-table.
> 
> - 15-20: ASI core mappings and optional mappings.
> 
> - 21: Make functions to read cr3/cr4 ASI aware
> 
> - 22-26: Use ASI in KVM to provide isolation for VMExit handlers.
> 
> 
> API Overview:
> =============
> Here is a short description of the main ASI functions provided by the framwork.
> 
> struct asi *asi_create(int map_flags)
> 
>    Create an Address Space Isolation (ASI). map_flags can be used to specify
>    optional kernel mapping to be added to the ASI page-table (for example,
>    ASI_MAP_STACK_CANARY to map the stack canary).
> 
> 
> void asi_destroy(struct asi *asi)
> 
>    Destroy an ASI.
> 
> 
> int asi_enter(struct asi *asi)
> 
>    Enter isolation for the specified ASI. This switches from the kernel page-table
>    to the page-table associated with the ASI.
> 
> 
> void asi_exit(struct asi *asi)
> 
>    Exit isolation for the specified ASI. This switches back to the kernel
>    page-table
> 
> 
> int asi_map(struct asi *asi, void *ptr, unsigned long size);
> 
>    Copy kernel mapping to the specified ASI page-table.
> 
> 
> void asi_unmap(struct asi *asi, void *ptr);
> 
>    Clear kernel mapping from the specified ASI page-table.
> 
> 
> ----
> Alexandre Chartre (23):
>    mm/x86: Introduce kernel address space isolation
>    mm/asi: Abort isolation on interrupt, exception and context switch
>    mm/asi: Handle page fault due to address space isolation
>    mm/asi: Functions to track buffers allocated for an ASI page-table
>    mm/asi: Add ASI page-table entry offset functions
>    mm/asi: Add ASI page-table entry allocation functions
>    mm/asi: Add ASI page-table entry set functions
>    mm/asi: Functions to populate an ASI page-table from a VA range
>    mm/asi: Helper functions to map module into ASI
>    mm/asi: Keep track of VA ranges mapped in ASI page-table
>    mm/asi: Functions to clear ASI page-table entries for a VA range
>    mm/asi: Function to copy page-table entries for percpu buffer
>    mm/asi: Add asi_remap() function
>    mm/asi: Handle ASI mapped range leaks and overlaps
>    mm/asi: Initialize the ASI page-table with core mappings
>    mm/asi: Option to map current task into ASI
>    rcu: Move tree.h static forward declarations to tree.c
>    rcu: Make percpu rcu_data non-static
>    mm/asi: Add option to map RCU data
>    mm/asi: Add option to map cpu_hw_events
>    mm/asi: Make functions to read cr3/cr4 ASI aware
>    KVM: x86/asi: Populate the KVM ASI page-table
>    KVM: x86/asi: Map KVM memslots and IO buses into KVM ASI
> 
> Liran Alon (3):
>    KVM: x86/asi: Introduce address_space_isolation module parameter
>    KVM: x86/asi: Introduce KVM address space isolation
>    KVM: x86/asi: Switch to KVM address space on entry to guest
> 
>   arch/x86/entry/entry_64.S          |   42 ++-
>   arch/x86/include/asm/asi.h         |  237 ++++++++
>   arch/x86/include/asm/mmu_context.h |   20 +-
>   arch/x86/include/asm/tlbflush.h    |   10 +
>   arch/x86/kernel/asm-offsets.c      |    4 +
>   arch/x86/kvm/Makefile              |    3 +-
>   arch/x86/kvm/mmu.c                 |    2 +-
>   arch/x86/kvm/vmx/isolation.c       |  231 ++++++++
>   arch/x86/kvm/vmx/vmx.c             |   14 +-
>   arch/x86/kvm/vmx/vmx.h             |   24 +
>   arch/x86/kvm/x86.c                 |   68 +++-
>   arch/x86/kvm/x86.h                 |    1 +
>   arch/x86/mm/Makefile               |    2 +
>   arch/x86/mm/asi.c                  |  459 +++++++++++++++
>   arch/x86/mm/asi_pagetable.c        | 1077 ++++++++++++++++++++++++++++++++++++
>   arch/x86/mm/fault.c                |    7 +
>   include/linux/kvm_host.h           |    7 +
>   kernel/rcu/tree.c                  |   56 ++-
>   kernel/rcu/tree.h                  |   56 +--
>   kernel/sched/core.c                |    4 +
>   security/Kconfig                   |   10 +
>   21 files changed, 2269 insertions(+), 65 deletions(-)
>   create mode 100644 arch/x86/include/asm/asi.h
>   create mode 100644 arch/x86/kvm/vmx/isolation.c
>   create mode 100644 arch/x86/mm/asi.c
>   create mode 100644 arch/x86/mm/asi_pagetable.c
> 

