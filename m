Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6EC7DC4321A
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:46:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60D1A21479
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 21:46:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60D1A21479
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1F226B0005; Thu, 25 Apr 2019 17:46:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACD2E6B0006; Thu, 25 Apr 2019 17:46:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BC746B0007; Thu, 25 Apr 2019 17:46:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 622606B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:46:14 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id n5so575379pgk.9
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 14:46:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id;
        bh=4fAUxkdWNYGAT7DCHPa1+ld3depE7uaEwNtLIzCGQaM=;
        b=q+QmJt4rVnZ1+DxeHcER5rclVc1Ek7glCEcDF4UurX5nGJxU2ZjBsnNI78Phwo0WMF
         ugKO0jP5fpbfH+JsDosxnk42KAWsIXu4qTkTSe7gtmU46JffksVktK8kDFd1kQsQzOxz
         AQSeJeLGfeQqp/R9e37K4VsoPl4yBjJevUzD6odoSYk8F7yBYzd2QfdXODKRhpn7Ofqa
         nfnGMfLmKe9Q4YCCl5TrN/eIf/6fwg3O4QRGzzeGV2byrMS/r1wEEqJ0C2D6sYLl7wvV
         gtqJaCQI/yxTjdpAN1MZWKy8kwAqbDYtiV4kTIkewKtJ+oijosplrJcBGMgPhwaj4Gm7
         oifw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXXOVrPndyTAAjpIT97U26ml07QukHARto7QznQeMNtWLQHktiA
	A43vE+bAuDtm/wQ1+MQUUAZ8196QqmC4zoT5gReio/pcw/KhRlITpKfkLMIsBCYoOUh68Y7hH7w
	rU/6+zkH+311AkcS0ZWORlOc6dUj2NKQGhALvKtG+QcNFmKVKv1X7rom6Ntsx1lEPAg==
X-Received: by 2002:a65:6644:: with SMTP id z4mr7399581pgv.300.1556228773989;
        Thu, 25 Apr 2019 14:46:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxyWovMr1IJq0Vax29hY51A+ALkjI7hU69s+rrQ1JrOnS2fevyRruAwl/Ua9Gk8lmmX2s3n
X-Received: by 2002:a65:6644:: with SMTP id z4mr7399499pgv.300.1556228772827;
        Thu, 25 Apr 2019 14:46:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556228772; cv=none;
        d=google.com; s=arc-20160816;
        b=wHrHNeP4Py/Q6IpxqNnbtaRcmoW9dG4DeSfNh7uA5OSgeaUlaIJ1umAhvf0JnCsfkZ
         FzzUs6HvlJU1lb2z/5LVd/+cduxaUkMkjUION2gMjGRBSO7xXZpkVioSqqOZt9S0r6Wh
         mdT9z2SbfwYqAts7Gpyt759G/cbdxGJkr7RuF8ebxw98BW5H9Os5Es2p6+Trq03TmUYT
         Zp4b0dkRq8NYwcTR+wOZDHi0P1dC8vjgxcbpPMAqexLLIuWdhqVCgGCi1ADgCkfjVJOO
         y2gL1ssERHBiZVXd2E6MI+bReT/yLEQTvzXxzd4lR+mVSKX/FnryqLbP6RwlI480IHAy
         /J3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from;
        bh=4fAUxkdWNYGAT7DCHPa1+ld3depE7uaEwNtLIzCGQaM=;
        b=UaoWZrNaxqdVKOyKFScywn2c7DoX7KcPRnmZGJrN2s4o+Guk9l2lH0eOkSSqOAQJPO
         OyCdfDCGC2Yv1o2djnNgvpK2EH/f1j6DW5dHs93PlZKSHj5Mj6CHupmA3rZt1yOrbv0q
         E1O4SxwXm2r/QjYUEQEB8AGTr8MZ1NUcel3ZrV53iel9hIkT5AcgKj5gB3ODlw+gM6or
         QLZ9S/OX1i4g8iQ/Gi4iNkvuzeF6vJxM5FrVdp+4q1E7CJjavrmHjEWOqzHNTsHE7ZqT
         aHs7TxKb2fHEnNe4Jdhk9sppHnF6/JcMhga7rLkH/C5yn9YQZqXqXaa1uOvew3QPQkQ6
         IN/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p187si24724497pfp.89.2019.04.25.14.46.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 14:46:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rppt@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=rppt@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3PLdOOa090912
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:46:12 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2s3hf9r6xp-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 17:46:11 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Thu, 25 Apr 2019 22:46:09 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 25 Apr 2019 22:46:04 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3PLk38I61145270
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 25 Apr 2019 21:46:03 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 36671AE053;
	Thu, 25 Apr 2019 21:46:03 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id B5C44AE045;
	Thu, 25 Apr 2019 21:46:00 +0000 (GMT)
Received: from rapoport-lnx (unknown [9.148.204.209])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTPS;
	Thu, 25 Apr 2019 21:46:00 +0000 (GMT)
Received: by rapoport-lnx (sSMTP sendmail emulation); Fri, 26 Apr 2019 00:45:59 +0300
From: Mike Rapoport <rppt@linux.ibm.com>
To: linux-kernel@vger.kernel.org
Cc: Alexandre Chartre <alexandre.chartre@oracle.com>,
        Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
        James Bottomley <James.Bottomley@hansenpartnership.com>,
        Jonathan Adams <jwadams@google.com>, Kees Cook <keescook@chromium.org>,
        Paul Turner <pjt@google.com>, Peter Zijlstra <peterz@infradead.org>,
        Thomas Gleixner <tglx@linutronix.de>, linux-mm@kvack.org,
        linux-security-module@vger.kernel.org, x86@kernel.org,
        Mike Rapoport <rppt@linux.ibm.com>
Subject: [RFC PATCH 0/7] x86: introduce system calls addess space isolation
Date: Fri, 26 Apr 2019 00:45:47 +0300
X-Mailer: git-send-email 2.7.4
X-TM-AS-GCONF: 00
x-cbid: 19042521-0020-0000-0000-000003360BFD
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042521-0021-0000-0000-000021887A3B
Message-Id: <1556228754-12996-1-git-send-email-rppt@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-25_18:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=577 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904250133
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Address space isolation has been used to protect the kernel from the
userspace and userspace programs from each other since the invention of the
virtual memory.

Assuming that kernel bugs and therefore vulnerabilities are inevitable it
might be worth isolating parts of the kernel to minimize damage that these
vulnerabilities can cause.

The idea here is to allow an untrusted user access to a potentially
vulnerable kernel in such a way that any kernel vulnerability they find to
exploit is either prevented or the consequences confined to their isolated
address space such that the compromise attempt has minimal impact on other
tenants or the protected structures of the monolithic kernel.  Although we
hope to prevent many classes of attack, the first target we're looking at
is ROP gadget protection.

These patches implement a "system call isolation (SCI)" mechanism that
allows running system calls in an isolated address space with reduced page
tables to prevent ROP attacks.

ROP attacks involve corrupting the stack return address to repoint it to a
segment of code you know exists in the kernel that can be used to perform
the action you need to exploit the system.

The idea behind the prevention is that if we fault in pages in the
execution path, we can compare target address against the kernel symbol
table.  So if we're in a function, we allow local jumps (and simply falling
of the end of a page) but if we're jumping to a new function it must be to
an external label in the symbol table.  Since ROP attacks are all about
jumping to gadget code which is effectively in the middle of real
functions, the jumps they induce are to code that doesn't have an external
symbol, so it should mostly detect when they happen.

This is very early POC, it's able to run the simple dummy system calls and
a little bit beyond that, but it's not yet stable and robust enough to boot
a system with system call isolation enabled for all system calls. Still, we
wanted to get some feedback about the concept in general as early as
possible.
 
At this time we are not suggesting any API that will enable the system
calls isolation. Because of the overhead required for this, it should only
be activated for processes or containers we know should be untrusted. We
still have no actual numbers, but surely forcing page faults during system
call execution will not come for free.

One possible way is to create a namespace, and force the system calls
isolation on all the processes in that namespace. Another thing that came
to mind was to use a seccomp filter to allow fine grained control of this
feature.

The current implementation is pretty much x86-centric, but the general idea
can be used on other architectures.

A brief TOC of the set:
* patch 1 adds  definitions of X86_FEATURE_SCI
* patch 2 is the core implementation of system calls isolation (SCI)
* patches 3-5 add hooks to SCI at entry paths and in the page fault
  handler 
* patch 6 enables the SCI in Kconfig
* patch 7 includes example dummy system calls that are used to
  demonstrate the SCI in action.

Mike Rapoport (7):
  x86/cpufeatures: add X86_FEATURE_SCI
  x86/sci: add core implementation for system call isolation
  x86/entry/64: add infrastructure for switching to isolated syscall
    context
  x86/sci: hook up isolated system call entry and exit
  x86/mm/fault: hook up SCI verification
  security: enable system call isolation in kernel config
  sci: add example system calls to exercse SCI

 arch/x86/entry/calling.h                 |  65 ++++
 arch/x86/entry/common.c                  |  65 ++++
 arch/x86/entry/entry_64.S                |  13 +-
 arch/x86/entry/syscalls/syscall_64.tbl   |   3 +
 arch/x86/include/asm/cpufeatures.h       |   1 +
 arch/x86/include/asm/disabled-features.h |   8 +-
 arch/x86/include/asm/processor-flags.h   |   8 +
 arch/x86/include/asm/sci.h               |  55 +++
 arch/x86/include/asm/tlbflush.h          |   8 +-
 arch/x86/kernel/asm-offsets.c            |   7 +
 arch/x86/kernel/process_64.c             |   5 +
 arch/x86/mm/Makefile                     |   1 +
 arch/x86/mm/fault.c                      |  28 ++
 arch/x86/mm/init.c                       |   2 +
 arch/x86/mm/sci.c                        | 608 +++++++++++++++++++++++++++++++
 include/linux/sched.h                    |   5 +
 include/linux/sci.h                      |  12 +
 kernel/Makefile                          |   2 +-
 kernel/exit.c                            |   3 +
 kernel/sci-examples.c                    |  52 +++
 security/Kconfig                         |  10 +
 21 files changed, 956 insertions(+), 5 deletions(-)
 create mode 100644 arch/x86/include/asm/sci.h
 create mode 100644 arch/x86/mm/sci.c
 create mode 100644 include/linux/sci.h
 create mode 100644 kernel/sci-examples.c

-- 
2.7.4

