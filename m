Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id A583F6B0038
	for <linux-mm@kvack.org>; Fri, 14 Apr 2017 16:37:58 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id e132so775315ite.19
        for <linux-mm@kvack.org>; Fri, 14 Apr 2017 13:37:58 -0700 (PDT)
Received: from resqmta-ch2-07v.sys.comcast.net (resqmta-ch2-07v.sys.comcast.net. [2001:558:fe21:29:69:252:207:39])
        by mx.google.com with ESMTPS id u128si3782048ioe.3.2017.04.14.13.37.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Apr 2017 13:37:57 -0700 (PDT)
Date: Fri, 14 Apr 2017 15:37:54 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC 1/6] mm, page_alloc: fix more premature OOM due to race
 with cpuset update
In-Reply-To: <cf9628e9-20ed-68b0-6cbd-48af5133138c@suse.cz>
Message-ID: <alpine.DEB.2.20.1704141526260.17435@east.gentwo.org>
References: <20170411140609.3787-1-vbabka@suse.cz> <20170411140609.3787-2-vbabka@suse.cz> <alpine.DEB.2.20.1704111152170.25069@east.gentwo.org> <a86ae57a-3efc-6ae5-ddf0-fd64c53c20fa@suse.cz> <alpine.DEB.2.20.1704121617040.28335@east.gentwo.org>
 <cf9628e9-20ed-68b0-6cbd-48af5133138c@suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-api@vger.kernel.org

On Thu, 13 Apr 2017, Vlastimil Babka wrote:

>
> I doubt we can change that now, because that can break existing
> programs. It also makes some sense at least to me, because a task can
> control its own mempolicy (for performance reasons), but cpuset changes
> are admin decisions that the task cannot even anticipate. I think it's
> better to continue working with suboptimal performance than start
> failing allocations?

If the expected semantics (hardwall) are that allocations should fail then
lets be consistent and do so.

Adding more and more exceptions gets this convoluted mess into an even
worse shape. Adding the static binding of nodes was already a screwball
if used within a cpuset because now one has to anticipate how a user would
move the nodes of a cpuset and how the static bindings would work in such
a context.

The admin basically needs to know how the application has used memory
policies if one still wants to move the applications within a cpuset with
the fixed bindings.

Maybe the best way to handle this is to give up on cpuset migration of
live applications? After all this can be done with a script in the same
way as the kernel is doing:

1. Extend the cpuset to include the new nodes.

2. Loop over the processes and use the migrate_pages() to move the apps
one by one.

3. Remove the nodes no longer to be used.

Then forget about translating memory policies. If an application that is
supposed to run in a cpuset and supposed to be moveable has fixed bindings
then the application should be aware of that and be equipped with
some logic to rebind its memory on its own.

Such an application typically already has such logic and executes a
binding after discovering its numa node configuration on startup. It would
have to be modified to redo that action when it gets some sort of a signal
from the script telling it that the node config would be changed.

Having this logic in the application instead of the kernel avoids all the
kernel messes that we keep on trying to deal with and IMHO is much
cleaner.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
