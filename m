Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id F0CCE6B0390
	for <linux-mm@kvack.org>; Wed, 12 Apr 2017 17:25:34 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id c18so34656133ioa.8
        for <linux-mm@kvack.org>; Wed, 12 Apr 2017 14:25:34 -0700 (PDT)
Received: from resqmta-ch2-01v.sys.comcast.net (resqmta-ch2-01v.sys.comcast.net. [2001:558:fe21:29:69:252:207:33])
        by mx.google.com with ESMTPS id s143si6627840ita.88.2017.04.12.14.25.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Apr 2017 14:25:34 -0700 (PDT)
Date: Wed, 12 Apr 2017 16:25:32 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC 1/6] mm, page_alloc: fix more premature OOM due to race
 with cpuset update
In-Reply-To: <a86ae57a-3efc-6ae5-ddf0-fd64c53c20fa@suse.cz>
Message-ID: <alpine.DEB.2.20.1704121617040.28335@east.gentwo.org>
References: <20170411140609.3787-1-vbabka@suse.cz> <20170411140609.3787-2-vbabka@suse.cz> <alpine.DEB.2.20.1704111152170.25069@east.gentwo.org> <a86ae57a-3efc-6ae5-ddf0-fd64c53c20fa@suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-api@vger.kernel.org

On Tue, 11 Apr 2017, Vlastimil Babka wrote:

> > The fallback was only intended for a cpuset on which boundaries are not enforced
> > in critical conditions (softwall). A hardwall cpuset (CS_MEM_HARDWALL)
> > should fail the allocation.
>
> Hmm just to clarify - I'm talking about ignoring the *mempolicy's* nodemask on
> the basis of cpuset having higher priority, while you seem to be talking about
> ignoring a (softwall) cpuset nodemask, right? man set_mempolicy says "... if
> required nodemask contains no nodes that are allowed by the process's current
> cpuset context, the memory  policy reverts to local allocation" which does come
> down to ignoring mempolicy's nodemask.

I am talking of allocating outside of the current allowed nodes
(determined by mempolicy -- MPOL_BIND is the only concern as far as I can
tell -- as well as the current cpuset). One can violate the cpuset if its not
a hardwall but  the MPOL_MBIND node restriction cannot be violated.

Those allocations are also not allowed if the allocation was for a user
space page even if this is a softwall cpuset.

> >> This patch fixes the issue by having __alloc_pages_slowpath() check for empty
> >> intersection of cpuset and ac->nodemask before OOM or allocation failure. If
> >> it's indeed empty, the nodemask is ignored and allocation retried, which mimics
> >> node_zonelist(). This works fine, because almost all callers of
> >
> > Well that would need to be subject to the hardwall flag. Allocation needs
> > to fail for a hardwall cpuset.
>
> They still do, if no hardwall cpuset node can satisfy the allocation with
> mempolicy ignored.

If the memory policy is MPOL_MBIND then allocations outside of the given
nodes should fail. They can violate the cpuset boundaries only if they are
kernel allocations and we are not in a hardwall cpuset.

That was at least my understand when working on this code years ago.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
