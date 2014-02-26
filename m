Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 092C76B00A4
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 02:52:27 -0500 (EST)
Received: by mail-pd0-f172.google.com with SMTP id p10so603246pdj.31
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 23:52:27 -0800 (PST)
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com. [122.248.162.6])
        by mx.google.com with ESMTPS id o7si69382pbh.302.2014.02.25.23.52.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 25 Feb 2014 23:52:27 -0800 (PST)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 26 Feb 2014 13:22:22 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id C73EF3940060
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 13:22:19 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s1Q7qKJB49610970
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 13:22:21 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s1Q7qHJD023983
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 13:22:18 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: numa: bugfix for LAST_CPUPID_NOT_IN_PAGE_FLAGS
In-Reply-To: <20140213152009.b16a30d2a5b5c5706fc8952a@linux-foundation.org>
References: <1391563546-26052-1-git-send-email-pingfank@linux.vnet.ibm.com> <20140213152009.b16a30d2a5b5c5706fc8952a@linux-foundation.org>
Date: Wed, 26 Feb 2014 13:22:16 +0530
Message-ID: <87k3cifgzz.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Liu Ping Fan <qemulist@gmail.com>
Cc: linux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org

Andrew Morton <akpm@linux-foundation.org> writes:

> On Wed,  5 Feb 2014 09:25:46 +0800 Liu Ping Fan <qemulist@gmail.com> wrote:
>
>> When doing some numa tests on powerpc, I triggered an oops bug. I find
>> it is caused by using page->_last_cpupid.  It should be initialized as
>> "-1 & LAST_CPUPID_MASK", but not "-1". Otherwise, in task_numa_fault(),
>> we will miss the checking (last_cpupid == (-1 & LAST_CPUPID_MASK)).
>> And finally cause an oops bug in task_numa_group(), since the online cpu is
>> less than possible cpu.
>
> I grabbed this.  I added this to the changelog:
>
> : PPC needs the LAST_CPUPID_NOT_IN_PAGE_FLAGS case because ppc needs to
> : support a large physical address region, up to 2^46 but small section size
> : (2^24).  So when NR_CPUS grows up, it is easily to cause
> : not-in-page-flags.
>
> to hopefully address Peter's observation.
>
> How should we proceed with this?  I'm getting the impression that numa
> balancing on ppc is a dead duck in 3.14, so perhaps this and 
>
> powerpc-mm-add-new-set-flag-argument-to-pte-pmd-update-function.patch
> mm-dirty-accountable-change-only-apply-to-non-prot-numa-case.patch
> mm-use-ptep-pmdp_set_numa-for-updating-_page_numa-bit.patch
>

All these are already in 3.14  ?

> are 3.15-rc1 material?
>

We should push the first hunk to 3.14. I will wait for Liu to redo the
patch. BTW this should happen only when SPARSE_VMEMMAP is not
specified. Srikar had reported the issue here

http://mid.gmane.org/20140219180200.GA29257@linux.vnet.ibm.com

#if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
#define SECTIONS_WIDTH		SECTIONS_SHIFT
#else
#define SECTIONS_WIDTH		0
#endif

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
