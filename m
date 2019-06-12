Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF602C31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 17:08:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78B9C21019
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 17:08:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=amazon.de header.i=@amazon.de header.b="VNtqycDt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78B9C21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=amazon.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1FC806B0008; Wed, 12 Jun 2019 13:08:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 185FC6B000A; Wed, 12 Jun 2019 13:08:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 04CD86B000D; Wed, 12 Jun 2019 13:08:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id D85966B0008
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 13:08:56 -0400 (EDT)
Received: by mail-vs1-f72.google.com with SMTP id j77so5612607vsd.3
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 10:08:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=fPeaXeipXyI0A+eKQSQDQfcK52xXXH3ZvhYN21vIRx0=;
        b=Ai1+uqbDnLxG4QmnEEGquqjPRZVVvzGdRRPQxJ9hVp3qfmCvAO30i1GDtqwwBTBmdJ
         dHJm9FjXEo2WbQQDDIgkw7j1MZaC6w1HmabVtMbHKaZHH79TmHOIsk2Cwgom/P64y6qb
         1dZEXlMZciyG30I0RZ8e7+xwiIUMkAbMdYKL5+HEy0+mCpNJnFfGAh5M1PU8Ce/5HsoL
         gRZGQEibvRubS11y21h9ja1nij3tw9Fcj0R5jXzj1nXnEdJlpQg/F8YRL2Qp9jXimpdc
         raev5v3mUreBhzp3bH3ofI/qpXsFl56tnDii8Y6owCoylt4CvbIm1bZK7FFHjPJxilWT
         IVjA==
X-Gm-Message-State: APjAAAWsMHzv578CjcQ5Wwnv8O+o+GJQ3s5S61usCR1iMQ2rKkKVcE8u
	fgjYECmt5YiSjFdXL/HUtjZRsQqHB9DR+aYLTHUXEfZ1CJjbfaCpueo+Zkm4uEBZVA6ohQCQ07m
	RLJfwVMtw+QcDfuHxYLwrTSXQryzWiihe81fz+iLnqdADIVHcacziKFL4UULnplbG1w==
X-Received: by 2002:a9f:3c1c:: with SMTP id u28mr38548993uah.74.1560359336381;
        Wed, 12 Jun 2019 10:08:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwOS3cvixXLxr3iCcDD4q0Vg+fIMbnpIhmpg360zAHmBE0GcRfP37bKpmD9wRdst4DSCPmE
X-Received: by 2002:a9f:3c1c:: with SMTP id u28mr38548907uah.74.1560359335515;
        Wed, 12 Jun 2019 10:08:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560359335; cv=none;
        d=google.com; s=arc-20160816;
        b=iOKWrCMe5SpViMIwWcgYM+5LpXvsS8NWXroCVYokiEnGPe1bOSkAYNzopvxn//+MSG
         vddJCI0Wg2AYPktAsaVGWkHsHvqyAXzB8Qt49reqO7rK510KP58LEOkuJy9R0ImKy2Ej
         slyJ1RQZ+lSDQZAH1mDS+X7fi0Qxgjxa1iHL8y8oE/SQtOzSKwPqUDeTE899Ptvjh7qP
         6gLGAmkr7TGxbE6X3a2dO2QjHjOTr0LRaAXIWB3DiR42Nb/OrHNYQvm2nxDvsYFxmQgN
         KsI67vUQMsNiO2hpEoVosRRCw7EJDnmq/eCLJBWA78B8/I3H+7Uod/0RXNUOVfFIqNYo
         SAsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=fPeaXeipXyI0A+eKQSQDQfcK52xXXH3ZvhYN21vIRx0=;
        b=lJQ8ij9BaaMhV3KTtI1KBYv0FGiMvtWuryl7NdRZTnrp6TyMFWJzNkQ+dU3dN2UGzH
         f+LMCVfaNhqW+bfW/rdWoSXZsT7Dc9kDjJNW240BU7OXoLoKJt/eZv1f85hwZX3v8Ado
         EP+xHxQujNDJTvZf5tuaRS8dqVY69fxmXJ1/9A74wQGt9Z0yHEVfgDYDe5DtsnjLIZaj
         7vFnoqt/KHAhaRDd//nyrnn56OTm+YMtR4effyhUKFlbhV6aN5T9w7tiVO95r3cJ5bcq
         UX5EjnilbS19ZqBW6WSLbhuXaReoLX7VhkXul+FGHhjLRi7sk4TBz10GYmhODlOPzFf+
         GXYw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@amazon.de header.s=amazon201209 header.b=VNtqycDt;
       spf=pass (google.com: domain of prvs=059bff19d=mhillenb@amazon.com designates 207.171.184.29 as permitted sender) smtp.mailfrom="prvs=059bff19d=mhillenb@amazon.com";
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amazon.de
Received: from smtp-fw-9102.amazon.com (smtp-fw-9102.amazon.com. [207.171.184.29])
        by mx.google.com with ESMTPS id u15si71676uah.1.2019.06.12.10.08.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 10:08:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=059bff19d=mhillenb@amazon.com designates 207.171.184.29 as permitted sender) client-ip=207.171.184.29;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@amazon.de header.s=amazon201209 header.b=VNtqycDt;
       spf=pass (google.com: domain of prvs=059bff19d=mhillenb@amazon.com designates 207.171.184.29 as permitted sender) smtp.mailfrom="prvs=059bff19d=mhillenb@amazon.com";
       dmarc=pass (p=QUARANTINE sp=QUARANTINE dis=NONE) header.from=amazon.de
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.de; i=@amazon.de; q=dns/txt; s=amazon201209;
  t=1560359335; x=1591895335;
  h=from:to:cc:subject:date:message-id:mime-version:
   content-transfer-encoding;
  bh=fPeaXeipXyI0A+eKQSQDQfcK52xXXH3ZvhYN21vIRx0=;
  b=VNtqycDtevtVhR1NkxjmCBa7gwdmzas+toINv+kFaeqzJ5qtXxte1ClK
   pXdzFNpH+Gd+DfOF8IsXXKEvWOLoNWLZ2haMEzX5cb3OADmH1qtlGdTpa
   SNyt7hWvUJmV6ObIe6Bz4HteCbRXIwePur11CobhHk3i9eFQ+2bRIst+4
   U=;
X-IronPort-AV: E=Sophos;i="5.62,366,1554768000"; 
   d="scan'208";a="679555407"
Received: from sea3-co-svc-lb6-vlan3.sea.amazon.com (HELO email-inbound-relay-1a-7d76a15f.us-east-1.amazon.com) ([10.47.22.38])
  by smtp-border-fw-out-9102.sea19.amazon.com with ESMTP; 12 Jun 2019 17:08:52 +0000
Received: from ua08cfdeba6fe59dc80a8.ant.amazon.com (iad7-ws-svc-lb50-vlan2.amazon.com [10.0.93.210])
	by email-inbound-relay-1a-7d76a15f.us-east-1.amazon.com (Postfix) with ESMTPS id 0BA54A2896;
	Wed, 12 Jun 2019 17:08:50 +0000 (UTC)
Received: from ua08cfdeba6fe59dc80a8.ant.amazon.com (ua08cfdeba6fe59dc80a8.ant.amazon.com [127.0.0.1])
	by ua08cfdeba6fe59dc80a8.ant.amazon.com (8.15.2/8.15.2/Debian-3) with ESMTP id x5CH8mwU016469;
	Wed, 12 Jun 2019 19:08:48 +0200
Received: (from mhillenb@localhost)
	by ua08cfdeba6fe59dc80a8.ant.amazon.com (8.15.2/8.15.2/Submit) id x5CH8l1v016468;
	Wed, 12 Jun 2019 19:08:47 +0200
From: Marius Hillenbrand <mhillenb@amazon.de>
To: kvm@vger.kernel.org
Cc: Marius Hillenbrand <mhillenb@amazon.de>, linux-kernel@vger.kernel.org,
        kernel-hardening@lists.openwall.com, linux-mm@kvack.org,
        Alexander Graf <graf@amazon.de>, David Woodhouse <dwmw@amazon.co.uk>
Subject: [RFC 00/10] Process-local memory allocations for hiding KVM secrets
Date: Wed, 12 Jun 2019 19:08:24 +0200
Message-Id: <20190612170834.14855-1-mhillenb@amazon.de>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The Linux kernel has a global address space that is the same for any
kernel code. This address space becomes a liability in a world with
processor information leak vulnerabilities, such as L1TF. With the right
cache load gadget, an attacker-controlled hyperthread pair can leak
arbitrary data via L1TF. Disabling hyperthreading is one recommended
mitigation, but it comes with a large performance hit for a wide range
of workloads.

An alternative mitigation is to not make certain data in the kernel
globally visible, but only when the kernel executes in the context of
the process where this data belongs to.

This patch series proposes to introduce a region for what we call
process-local memory into the kernel's virtual address space. Page
tables and mappings in that region will be exclusive to one address
space, instead of implicitly shared between all kernel address spaces.
Any data placed in that region will be out of reach of cache load
gadgets that execute in different address spaces. To implement
process-local memory, we introduce a new interface kmalloc_proclocal() /
kfree_proclocal() that allocates and maps pages exclusively into the
current kernel address space. As a first use case, we move architectural
state of guest CPUs in KVM out of reach of other kernel address spaces.

The patch set is a prototype for x86-64 that we have developed on top of
kernel 4.20.17 (with cherry-picked commit d253ca0c3865 "x86/mm/cpa: Add
set_direct_map_*() functions"). I am aware that the integration with KVM
will see some changes while rebasing to 5.x. Patches 7 and 8, in
particular, help make patch 9 more readable, but will be dropped in
rebasing. We have tested the code on both Intel and AMDs, launching VMs
in a loop. So far, we have not done in-depth performance evaluation.
Impact on starting VMs was within measurement noise.

---

Julian Stecklina (2):
  kvm, vmx: move CR2 context switch out of assembly path
  kvm, vmx: move register clearing out of assembly path

Marius Hillenbrand (8):
  x86/mm/kaslr: refactor to use enum indices for regions
  x86/speculation, mm: add process local virtual memory region
  x86/mm, mm,kernel: add teardown for process-local memory to mm cleanup
  mm: allocate virtual space for process-local memory
  mm: allocate/release physical pages for process-local memory
  kvm/x86: add support for storing vCPU state in process-local memory
  kvm, vmx: move gprs to process local memory
  kvm, x86: move guest FPU state into process local memory

 Documentation/x86/x86_64/mm.txt         |  11 +-
 arch/x86/Kconfig                        |   1 +
 arch/x86/include/asm/kvm_host.h         |  40 ++-
 arch/x86/include/asm/page_64.h          |   4 +
 arch/x86/include/asm/pgtable_64_types.h |  12 +
 arch/x86/include/asm/proclocal.h        |  11 +
 arch/x86/kernel/head64.c                |   8 +
 arch/x86/kvm/Kconfig                    |  10 +
 arch/x86/kvm/kvm_cache_regs.h           |   4 +-
 arch/x86/kvm/svm.c                      | 104 +++++--
 arch/x86/kvm/vmx.c                      | 213 ++++++++++-----
 arch/x86/kvm/x86.c                      |  31 ++-
 arch/x86/mm/Makefile                    |   1 +
 arch/x86/mm/dump_pagetables.c           |   9 +
 arch/x86/mm/fault.c                     |  19 ++
 arch/x86/mm/kaslr.c                     |  63 ++++-
 arch/x86/mm/proclocal.c                 | 136 +++++++++
 include/linux/mm_types.h                |  13 +
 include/linux/proclocal.h               |  35 +++
 kernel/fork.c                           |   6 +
 mm/Makefile                             |   1 +
 mm/proclocal.c                          | 348 ++++++++++++++++++++++++
 security/Kconfig                        |  18 ++
 23 files changed, 978 insertions(+), 120 deletions(-)
 create mode 100644 arch/x86/include/asm/proclocal.h
 create mode 100644 arch/x86/mm/proclocal.c
 create mode 100644 include/linux/proclocal.h
 create mode 100644 mm/proclocal.c

-- 
2.21.0

