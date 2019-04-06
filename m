Return-Path: <SRS0=nlaJ=SI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C49DCC10F06
	for <linux-mm@archiver.kernel.org>; Sat,  6 Apr 2019 06:40:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 729FF2186A
	for <linux-mm@archiver.kernel.org>; Sat,  6 Apr 2019 06:40:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 729FF2186A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F30B06B026E; Sat,  6 Apr 2019 02:40:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE03A6B0270; Sat,  6 Apr 2019 02:40:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA8AC6B0271; Sat,  6 Apr 2019 02:40:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id B852B6B026E
	for <linux-mm@kvack.org>; Sat,  6 Apr 2019 02:40:50 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id f15so7352654qtk.16
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 23:40:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state
         :content-transfer-encoding:from:mime-version:subject:message-id:date
         :references:to:in-reply-to:cc:thread-topic:thread-index;
        bh=KeXYMOcc/1z7pe+TgRs/JlYJfMep6qWo+eb4xyoE5rM=;
        b=A7ncCvlL7h0II3RJ525ESdSEJGdRziMs+rD5USXFPuo5Q4+OvOmlOach91AJ+rv+Xv
         EtEtuzM6wTMaRaEVxMT/3YIG8ivv2RMZDX5nHiqvOnySXnzUWQxprOTYwxDPd2WS1dy8
         jKG0JKC0t4joIJC4yJQV0+bsJdl3gszsH7z0YxVMSIzVWavw/4Q9PSTXPdZ8FDnv6ZgJ
         eyZKO6ywnXF5RcS8aftUyUT7usdPZb+944oRkkGRCzIylcR4lGQFvjU+kVC6ppbn6VLh
         gg9Z63WqyVvoZOA2p5Fj6m/Rx6MQhtjwOO+fQkh+dxLp0GnA7iBSZ7wa6iNRVwNiDggP
         ci2Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jcm@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jcm@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWVgBU1+QO/x0PGBp2sdPuZGd7hKcZvYmVROGvarXEWPyw7fQ4t
	I4Vw6Tx0wP8H6nHG9WJwhgm7JfE89svTDNzfaTbkWtVllW7IQUYXG8CvBpfB4l23Ym5GleozxSW
	p2nB9JOaqRNV/opu8JnlDp+bswD4fdDXIUmO5I6c38l9T+YAMFT4Qt4xaXGEEm6trEA==
X-Received: by 2002:a37:a656:: with SMTP id p83mr14396529qke.91.1554532850453;
        Fri, 05 Apr 2019 23:40:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYEOKRv32gyzspMrL0uCGC2z2sUbd8kM1rSkmMNAc4rjJp+/IQrEuNUjzo5p8itM+r/n9R
X-Received: by 2002:a37:a656:: with SMTP id p83mr14396480qke.91.1554532849288;
        Fri, 05 Apr 2019 23:40:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554532849; cv=none;
        d=google.com; s=arc-20160816;
        b=Vgd2SFhvUrhy2Rdv07pU0o9h8LCG3De/RNMjxBSNoGcmhTqzpvXUF92Jyd+J6ZmtfH
         /+xPbc3jOZiGCtfME9KrIIrRJkCC0DgYfPBjyBsaxGBuCVGYkYY2wYHgDBQdw169mKT3
         3Z1Pps6fan4y+8gVNoHZ4gRraRiSdrXvO9lxJ8VIsepgBWkNgnPEc0dRHXB9uoloMrop
         +t+wwYN8/RNTW50GrMq1gQpW2nBBoJwlvQBB8f5KseayM4wIvVFEetQcfC52xHJh8bSL
         OlQ9c6kgFrTfDjhVd0oefg0RJ3pATTFl+FyLhB73eMsFyep25MbrFF9lVVt7TNydieNo
         bZJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=thread-index:thread-topic:cc:in-reply-to:to:references:date
         :message-id:subject:mime-version:from:content-transfer-encoding;
        bh=KeXYMOcc/1z7pe+TgRs/JlYJfMep6qWo+eb4xyoE5rM=;
        b=xKTk32j+LaBdQEcQTmBYCEja9JDpTVUoWxdOoLvx2p11B2lglFPIKlSLjUJjEuZQ09
         NszOjguH1xOXJhGCU/sZlSABZP4XrjhXWQEgF3IFgZf8YcNSmhP6A1BXGdPTGMgikJRL
         Eqis2htoVtaBPxrKJ4HvG67a7VNccElMccNbvetxCFscca532crzqQJZPHDFJpSCzufT
         YmE2Lc3GwlqzSFOLLcZS/Qp0EFIxkKaskmGelWuwFsnVYqIt+RYO2KKeFzzicK6tMUoz
         +jBjmfk5t5XCzXzeVqKPVes8cX65Ze4F8ozMijXsaoeLLeXxrYn5KymIu4QcNFnrqkcu
         JQxw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jcm@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jcm@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i16si11400706qkk.141.2019.04.05.23.40.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Apr 2019 23:40:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of jcm@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jcm@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jcm@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8D36630820E4;
	Sat,  6 Apr 2019 06:40:47 +0000 (UTC)
Received: from colo-mx.corp.redhat.com (colo-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.20])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 1BF9A5C207;
	Sat,  6 Apr 2019 06:40:45 +0000 (UTC)
Received: from zmail26.collab.prod.int.phx2.redhat.com (zmail26.collab.prod.int.phx2.redhat.com [10.5.83.33])
	by colo-mx.corp.redhat.com (Postfix) with ESMTP id 303E31819AFD;
	Sat,  6 Apr 2019 06:40:40 +0000 (UTC)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: quoted-printable
From: Jon Masters <jcm@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH v9 00/13] Add support for eXclusive Page Frame Ownership
Message-Id: <80680B91-4EB8-4F23-B8CE-0156BC2C7DCA@redhat.com>
Date: Sat, 6 Apr 2019 02:40:39 -0400 (EDT)
References: <cover.1554248001.git.khalid.aziz@oracle.com>
To: Khalid Aziz <khalid.aziz@oracle.com>
In-Reply-To: <cover.1554248001.git.khalid.aziz@oracle.com>
Cc: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com,
 liran.alon@oracle.com, keescook@google.com, akpm@linux-foundation.org,
 konrad.wilk@oracle.com, deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
 tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
 boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com,
 joao.m.martins@oracle.com, jmattson@google.com, pradeep.vincent@oracle.com,
 john.haxby@oracle.com, tglx@linutronix.de, kirill.shutemov@linux.intel.com,
 hch@lst.de, steven.sistare@oracle.com, labbott@redhat.com, luto@kernel.org,
 dave.hansen@intel.com, peterz@infradead.org, aaron.lu@intel.com,
 alexander.h.duyck@linux.intel.com, amir73il@gmail.com, andreyknvl@google.com,
 aneesh.kumar@linux.ibm.com, anthony.yznaga@oracle.com,
 ard.biesheuvel@linaro.org, arnd@arndb.de, arunks@codeaurora.org,
 ben@decadent.org.uk, bigeasy@linutronix.de, bp@alien8.de, brgl@bgdev.pl,
 catalin.marinas@arm.com, corbet@lwn.net, cpandya@codeaurora.org,
 daniel.vetter@ffwll.ch, dan.j.williams@intel.com, gregkh@linuxfoundation.org,
 guro@fb.com, hannes@cmpxchg.org, hpa@zytor.com, iamjoonsoo.kim@lge.com,
 james.morse@arm.com, jannh@google.com, jgross@suse.com, jkosina@suse.cz,
 jmorris@namei.org, joe@perches.com, jrdr.linux@gmail.com, jroedel@suse.de,
 keith.busch@intel.com, khlebnikov@yandex-team.ru, logang@deltatee.com,
 marco.antonio.780@gmail.com, mark.rutland@arm.com,
 mgorman@techsingularity.net, mhocko@suse.com, mhocko@suse.cz,
 mike.kravetz@oracle.com, mingo@redhat.com, mst@redhat.com,
 m.szyprowski@samsung.com, npiggin@gmail.com, osalvador@suse.de,
 paulmck@linux.vnet.ibm.com, pavel.tatashin@microsoft.com,
 rdunlap@infradead.org, richard.weiyang@gmail.com, riel@surriel.com,
 rientjes@google.com, robin.murphy@arm.com, rostedt@goodmis.org,
 rppt@linux.vnet.ibm.com, sai.praneeth.prakhya@intel.com, serge@hallyn.com,
 steve.capper@arm.com, thymovanbeers@gmail.com, vbabka@suse.cz,
 will.deacon@arm.com, willy@infradead.org, yang.shi@linux.alibaba.com,
 yaojun8558363@gmail.com, ying.huang@intel.com, zhangshaokun@hisilicon.com,
 khalid@gonehiking.org, iommu@lists.linux-foundation.org, x86@kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-security-module@vger.kernel.org
Thread-Topic: Add support for eXclusive Page Frame Ownership
Thread-Index: 6OWDXOTXtuH6TAHWQlrXs03dvCq3eA==
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Sat, 06 Apr 2019 06:40:48 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Khalid,

Thanks for these patches. We will test them on x86 and investigate the Arm p=
ieces highlighted.

Jon.

--=20
Computer Architect


> On Apr 4, 2019, at 00:37, Khalid Aziz <khalid.aziz@oracle.com> wrote:
>=20
> This is another update to the work Juerg, Tycho and Julian have
> done on XPFO. After the last round of updates, we were seeing very
> significant performance penalties when stale TLB entries were
> flushed actively after an XPFO TLB update.  Benchmark for measuring
> performance is kernel build using parallel make. To get full
> protection from ret2dir attackes, we must flush stale TLB entries.
> Performance penalty from flushing stale TLB entries goes up as the
> number of cores goes up. On a desktop class machine with only 4
> cores, enabling TLB flush for stale entries causes system time for
> "make -j4" to go up by a factor of 2.61x but on a larger machine
> with 96 cores, system time with "make -j60" goes up by a factor of
> 26.37x!  I have been working on reducing this performance penalty.
>=20
> I implemented two solutions to reduce performance penalty and that
> has had large impact. XPFO code flushes TLB every time a page is
> allocated to userspace. It does so by sending IPIs to all processors
> to flush TLB. Back to back allocations of pages to userspace on
> multiple processors results in a storm of IPIs.  Each one of these
> incoming IPIs is handled by a processor by flushing its TLB. To
> reduce this IPI storm, I have added a per CPU flag that can be set
> to tell a processor to flush its TLB. A processor checks this flag
> on every context switch. If the flag is set, it flushes its TLB and
> clears the flag. This allows for multiple TLB flush requests to a
> single CPU to be combined into a single request. A kernel TLB entry
> for a page that has been allocated to userspace is flushed on all
> processors unlike the previous version of this patch. A processor
> could hold a stale kernel TLB entry that was removed on another
> processor until the next context switch. A local userspace page
> allocation by the currently running process could force the TLB
> flush earlier for such entries.
>=20
> The other solution reduces the number of TLB flushes required, by
> performing TLB flush for multiple pages at one time when pages are
> refilled on the per-cpu freelist. If the pages being addedd to
> per-cpu freelist are marked for userspace allocation, TLB entries
> for these pages can be flushed upfront and pages tagged as currently
> unmapped. When any such page is allocated to userspace, there is no
> need to performa a TLB flush at that time any more. This batching of
> TLB flushes reduces performance imapct further. Similarly when
> these user pages are freed by userspace and added back to per-cpu
> free list, they are left unmapped and tagged so. This further
> optimization reduced performance impact from 1.32x to 1.28x for
> 96-core server and from 1.31x to 1.27x for a 4-core desktop.
>=20
> I measured system time for parallel make with unmodified 4.20
> kernel, 4.20 with XPFO patches before these patches and then again
> after applying each of these patches. Here are the results:
>=20
> Hardware: 96-core Intel Xeon Platinum 8160 CPU @ 2.10GHz, 768 GB RAM
> make -j60 all
>=20
> 5.0                    913.862s
> 5.0+this patch series            1165.259ss    1.28x
>=20
>=20
> Hardware: 4-core Intel Core i5-3550 CPU @ 3.30GHz, 8G RAM
> make -j4 all
>=20
> 5.0                    610.642s
> 5.0+this patch series            773.075s    1.27x
>=20
> Performance with this patch set is good enough to use these as
> starting point for further refinement before we merge it into main
> kernel, hence RFC.
>=20
> I have restructurerd the patches in this version to separate out
> architecture independent code. I folded much of the code
> improvement by Julian to not use page extension into patch 3.=20
>=20
> What remains to be done beyond this patch series:
>=20
> 1. Performance improvements: Ideas to explore - (1) kernel mappings
>   private to an mm, (2) Any others??
> 2. Re-evaluate the patch "arm64/mm: Add support for XPFO to swiotlb"
>   from Juerg. I dropped it for now since swiotlb code for ARM has
>   changed a lot since this patch was written. I could use help
>   from ARM experts on this.
> 3. Extend the patch "xpfo, mm: Defer TLB flushes for non-current
>   CPUs" to other architectures besides x86.
> 4. Change kmap to not map the page back to physmap, instead map it
>   to a new va similar to what kmap_high does. Mapping page back
>   into physmap re-opens the ret2dir security for the duration of
>   kmap. All of the kmap_high and related code can be reused for this
>   but that will require restructuring that code so it can be built for
>   64-bits as well. Any objections to that?
>=20
> ---------------------------------------------------------
>=20
> Juerg Haefliger (6):
>  mm: Add support for eXclusive Page Frame Ownership (XPFO)
>  xpfo, x86: Add support for XPFO for x86-64
>  lkdtm: Add test for XPFO
>  arm64/mm: Add support for XPFO
>  swiotlb: Map the buffer if it was unmapped by XPFO
>  arm64/mm, xpfo: temporarily map dcache regions
>=20
> Julian Stecklina (1):
>  xpfo, mm: optimize spinlock usage in xpfo_kunmap
>=20
> Khalid Aziz (2):
>  xpfo, mm: Defer TLB flushes for non-current CPUs (x86 only)
>  xpfo, mm: Optimize XPFO TLB flushes by batching them together
>=20
> Tycho Andersen (4):
>  mm: add MAP_HUGETLB support to vm_mmap
>  x86: always set IF before oopsing from page fault
>  mm: add a user_virt_to_phys symbol
>  xpfo: add primitives for mapping underlying memory
>=20
> .../admin-guide/kernel-parameters.txt         |   6 +
> arch/arm64/Kconfig                            |   1 +
> arch/arm64/mm/Makefile                        |   2 +
> arch/arm64/mm/flush.c                         |   7 +
> arch/arm64/mm/mmu.c                           |   2 +-
> arch/arm64/mm/xpfo.c                          |  66 ++++++
> arch/x86/Kconfig                              |   1 +
> arch/x86/include/asm/pgtable.h                |  26 +++
> arch/x86/include/asm/tlbflush.h               |   1 +
> arch/x86/mm/Makefile                          |   2 +
> arch/x86/mm/fault.c                           |   6 +
> arch/x86/mm/pageattr.c                        |  32 +--
> arch/x86/mm/tlb.c                             |  39 ++++
> arch/x86/mm/xpfo.c                            | 185 +++++++++++++++++
> drivers/misc/lkdtm/Makefile                   |   1 +
> drivers/misc/lkdtm/core.c                     |   3 +
> drivers/misc/lkdtm/lkdtm.h                    |   5 +
> drivers/misc/lkdtm/xpfo.c                     | 196 ++++++++++++++++++
> include/linux/highmem.h                       |  34 +--
> include/linux/mm.h                            |   2 +
> include/linux/mm_types.h                      |   8 +
> include/linux/page-flags.h                    |  23 +-
> include/linux/xpfo.h                          | 191 +++++++++++++++++
> include/trace/events/mmflags.h                |  10 +-
> kernel/dma/swiotlb.c                          |   3 +-
> mm/Makefile                                   |   1 +
> mm/compaction.c                               |   2 +-
> mm/internal.h                                 |   2 +-
> mm/mmap.c                                     |  19 +-
> mm/page_alloc.c                               |  19 +-
> mm/page_isolation.c                           |   2 +-
> mm/util.c                                     |  32 +++
> mm/xpfo.c                                     | 170 +++++++++++++++
> security/Kconfig                              |  27 +++
> 34 files changed, 1047 insertions(+), 79 deletions(-)
> create mode 100644 arch/arm64/mm/xpfo.c
> create mode 100644 arch/x86/mm/xpfo.c
> create mode 100644 drivers/misc/lkdtm/xpfo.c
> create mode 100644 include/linux/xpfo.h
> create mode 100644 mm/xpfo.c
>=20
> --=20
> 2.17.1
>=20

