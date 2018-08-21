Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id E6C236B1FDF
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 13:26:57 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id a23-v6so9968824pfo.23
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 10:26:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u73-v6sor1018889pgb.358.2018.08.21.10.26.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 Aug 2018 10:26:56 -0700 (PDT)
Date: Tue, 21 Aug 2018 10:26:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 0/2] fix for "pathological THP behavior"
In-Reply-To: <6120e1b6-b4d2-96cb-2555-d8fab65c23c8@suse.cz>
Message-ID: <alpine.DEB.2.21.1808211021110.258924@chino.kir.corp.google.com>
References: <20180820032204.9591-1-aarcange@redhat.com> <20180820115818.mmeayjkplux2z6im@kshutemo-mobl1> <20180820151905.GB13047@redhat.com> <6120e1b6-b4d2-96cb-2555-d8fab65c23c8@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>

On Tue, 21 Aug 2018, Vlastimil Babka wrote:

> Frankly, I would rather go with this option and assume that if someone
> explicitly wants THP's, they don't care about NUMA locality that much.
> (Note: I hate __GFP_THISNODE, it's an endless source of issues.)
> Trying to be clever about "is there still PAGE_SIZEd free memory in the
> local node" is imperfect anyway. If there isn't, is it because there's
> clean page cache that we can easily reclaim (so it would be worth
> staying local) or is it really exhausted? Watermark check won't tell...
> 

MADV_HUGEPAGE (or defrag == "always") would now become a combination of 
"try to compact locally" and "allocate remotely if necesary" without the 
ability to avoid the latter absent a mempolicy that affects all memory 
allocations.  I think the complete solution would be a MPOL_F_HUGEPAGE 
flag that defines mempolicies for hugepage allocations.  In my experience 
thp falling back to remote nodes for intrasocket latency is a win but 
intersocket or two-hop intersocket latency is a no go.
