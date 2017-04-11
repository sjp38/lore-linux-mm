Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 468C36B03AD
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 13:24:29 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id d203so5501731iof.20
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 10:24:29 -0700 (PDT)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id e34si6152675iod.56.2017.04.11.10.24.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 10:24:28 -0700 (PDT)
Date: Tue, 11 Apr 2017 12:24:25 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC 1/6] mm, page_alloc: fix more premature OOM due to race
 with cpuset update
In-Reply-To: <20170411140609.3787-2-vbabka@suse.cz>
Message-ID: <alpine.DEB.2.20.1704111152170.25069@east.gentwo.org>
References: <20170411140609.3787-1-vbabka@suse.cz> <20170411140609.3787-2-vbabka@suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Tue, 11 Apr 2017, Vlastimil Babka wrote:

> The root of the problem is that the cpuset's mems_allowed and mempolicy's
> nodemask can temporarily have no intersection, thus get_page_from_freelist()
> cannot find any usable zone. The current semantic for empty intersection is to
> ignore mempolicy's nodemask and honour cpuset restrictions. This is checked in
> node_zonelist(), but the racy update can happen after we already passed the

The fallback was only intended for a cpuset on which boundaries are not enforced
in critical conditions (softwall). A hardwall cpuset (CS_MEM_HARDWALL)
should fail the allocation.

> This patch fixes the issue by having __alloc_pages_slowpath() check for empty
> intersection of cpuset and ac->nodemask before OOM or allocation failure. If
> it's indeed empty, the nodemask is ignored and allocation retried, which mimics
> node_zonelist(). This works fine, because almost all callers of

Well that would need to be subject to the hardwall flag. Allocation needs
to fail for a hardwall cpuset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
