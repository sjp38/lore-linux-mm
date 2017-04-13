Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B00666B0397
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 01:43:27 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p81so26033452pfd.12
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 22:43:27 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f7si22807812pfd.13.2017.04.12.22.43.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Apr 2017 22:43:26 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v3D5diWY046753
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 01:43:26 -0400
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com [202.81.31.142])
	by mx0a-001b2d01.pphosted.com with ESMTP id 29t0e05red-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 01:43:26 -0400
Received: from localhost
	by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 13 Apr 2017 15:43:23 +1000
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v3D5hEDZ37814380
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 15:43:22 +1000
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v3D5gn3w009921
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 15:42:50 +1000
Subject: Re: [RFC 1/6] mm, page_alloc: fix more premature OOM due to race with
 cpuset update
References: <20170411140609.3787-1-vbabka@suse.cz>
 <20170411140609.3787-2-vbabka@suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Thu, 13 Apr 2017 11:12:16 +0530
MIME-Version: 1.0
In-Reply-To: <20170411140609.3787-2-vbabka@suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <95469f35-56e9-7dc4-b7fd-a3e8c25bdff3@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On 04/11/2017 07:36 PM, Vlastimil Babka wrote:
> Commit e47483bca2cc ("mm, page_alloc: fix premature OOM when racing with cpuset
> mems update") has fixed known recent regressions found by LTP's cpuset01
> testcase. I have however found that by modifying the testcase to use per-vma
> mempolicies via bind(2) instead of per-task mempolicies via set_mempolicy(2),
> the premature OOM still happens and the issue is much older.

Meanwhile while we are discussing this RFC, will it be better to WARN
out these situations where we dont have node in the intersection,
hence no usable zone during allocation. That might actually give
a hint to the user before a premature OOM/allocation failure comes.

> 
> The root of the problem is that the cpuset's mems_allowed and mempolicy's
> nodemask can temporarily have no intersection, thus get_page_from_freelist()
> cannot find any usable zone. The current semantic for empty intersection is to
> ignore mempolicy's nodemask and honour cpuset restrictions. This is checked in
> node_zonelist(), but the racy update can happen after we already passed the
> check. Such races should be protected by the seqlock task->mems_allowed_seq,
> but it doesn't work here, because 1) mpol_rebind_mm() does not happen under
> seqlock for write, and doing so would lead to deadlock, as it takes mmap_sem
> for write, while the allocation can have mmap_sem for read when it's taking the
> seqlock for read. And 2) the seqlock cookie of callers of node_zonelist()
> (alloc_pages_vma() and alloc_pages_current()) is different than the one of
> __alloc_pages_slowpath(), so there's still a potential race window.
> 
> This patch fixes the issue by having __alloc_pages_slowpath() check for empty
> intersection of cpuset and ac->nodemask before OOM or allocation failure. If
> it's indeed empty, the nodemask is ignored and allocation retried, which mimics
> node_zonelist(). This works fine, because almost all callers of
> __alloc_pages_nodemask are obtaining the nodemask via node_zonelist(). The only
> exception is new_node_page() from hotplug, where the potential violation of
> nodemask isn't an issue, as there's already a fallback allocation attempt
> without any nodemask. If there's a future caller that needs to have its specific
> nodemask honoured over task's cpuset restrictions, we'll have to e.g. add a gfp
> flag for that.

Did you really mean node_zonelist() in both the instances above. Because
that function just picks up either FALLBACK_ZONELIST or NOFALLBACK_ZONELIST
depending upon the passed GFP flags in the allocation request and does not
deal with ignoring the passed nodemask.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
