Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1B7886B03C0
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 15:00:21 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u3so3278857pgn.12
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 12:00:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 140si5378487wmf.2.2017.04.11.12.00.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Apr 2017 12:00:20 -0700 (PDT)
Subject: Re: [RFC 1/6] mm, page_alloc: fix more premature OOM due to race with
 cpuset update
References: <20170411140609.3787-1-vbabka@suse.cz>
 <20170411140609.3787-2-vbabka@suse.cz>
 <alpine.DEB.2.20.1704111152170.25069@east.gentwo.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <a86ae57a-3efc-6ae5-ddf0-fd64c53c20fa@suse.cz>
Date: Tue, 11 Apr 2017 21:00:21 +0200
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1704111152170.25069@east.gentwo.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Li Zefan <lizefan@huawei.com>, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-api@vger.kernel.org

+CC linux-api

On 11.4.2017 19:24, Christoph Lameter wrote:
> On Tue, 11 Apr 2017, Vlastimil Babka wrote:
> 
>> The root of the problem is that the cpuset's mems_allowed and mempolicy's
>> nodemask can temporarily have no intersection, thus get_page_from_freelist()
>> cannot find any usable zone. The current semantic for empty intersection is to
>> ignore mempolicy's nodemask and honour cpuset restrictions. This is checked in
>> node_zonelist(), but the racy update can happen after we already passed the
> 
> The fallback was only intended for a cpuset on which boundaries are not enforced
> in critical conditions (softwall). A hardwall cpuset (CS_MEM_HARDWALL)
> should fail the allocation.

Hmm just to clarify - I'm talking about ignoring the *mempolicy's* nodemask on
the basis of cpuset having higher priority, while you seem to be talking about
ignoring a (softwall) cpuset nodemask, right? man set_mempolicy says "... if
required nodemask contains no nodes that are allowed by the process's current
cpuset context, the memory  policy reverts to local allocation" which does come
down to ignoring mempolicy's nodemask.

>> This patch fixes the issue by having __alloc_pages_slowpath() check for empty
>> intersection of cpuset and ac->nodemask before OOM or allocation failure. If
>> it's indeed empty, the nodemask is ignored and allocation retried, which mimics
>> node_zonelist(). This works fine, because almost all callers of
> 
> Well that would need to be subject to the hardwall flag. Allocation needs
> to fail for a hardwall cpuset.

They still do, if no hardwall cpuset node can satisfy the allocation with
mempolicy ignored.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
