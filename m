Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7A3D56B1F63
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 11:32:45 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id w23-v6so8109119pgv.1
        for <linux-mm@kvack.org>; Tue, 21 Aug 2018 08:32:45 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k24-v6si10400324pgn.574.2018.08.21.08.32.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Aug 2018 08:32:43 -0700 (PDT)
Subject: Re: [PATCH 0/2] fix for "pathological THP behavior"
References: <20180820032204.9591-1-aarcange@redhat.com>
 <20180820115818.mmeayjkplux2z6im@kshutemo-mobl1>
 <20180820151905.GB13047@redhat.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6120e1b6-b4d2-96cb-2555-d8fab65c23c8@suse.cz>
Date: Tue, 21 Aug 2018 17:30:11 +0200
MIME-Version: 1.0
In-Reply-To: <20180820151905.GB13047@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>

On 8/20/18 5:19 PM, Andrea Arcangeli wrote:
> Hi Kirill,
> 
> On Mon, Aug 20, 2018 at 02:58:18PM +0300, Kirill A. Shutemov wrote:
>> I personally prefer to prioritize NUMA locality over THP
>> (__GFP_COMPACT_ONLY variant), but I don't know page-alloc/compaction good
>> enough to Ack it.
> 
> If we go in this direction it'd be nice after fixing the showstopper
> bug, if we could then proceed with an orthogonal optimization by
> checking the watermarks and if the watermarks shows there are no
> PAGE_SIZEd pages available in the local node we should remove both
> __GFP_THISNODE and __GFP_COMPACT_ONLY.
> 
> If as opposed there's still PAGE_SIZEd free memory in the local node
> (not possible to compact for whatever reason), we should stick to
> __GFP_THISNODE | __GFP_COMPACT_ONLY.

If it's "not possible to compact" then the expected outcome of this is
to fail?

> It's orthogonal because the above addition would make sense also in
> the current (buggy) code.
> 
> The main implementation issue is that the watermark checking is not
> well done in mempolicy.c but the place to clear __GFP_THISNODE and
> __GFP_COMPACT_ONLY currently is there.

You could do that without calling watermark checking explicitly, but
it's rather complicated:

1. try alocating with __GFP_THISNODE and ~GFP_DIRECT_RECLAIM
2. if that fails, try PAGE_SIZE with same flags
3. if that fails, try THP size without __GFP_THISNODE
4. PAGE_SIZE without __GFP_THISNODE

Yeah, not possible in current alloc_pages_vma() which should return the
requested order. But the advantage is that it's not prone to races
between watermark checking and actual attempt.

> The case that the local node gets completely full and has not even 4k
> pages available should be totally common, because if you keep
> allocating and you allocate more than the size of a NUMA node
> eventually you will fill the local node with THP then consume all 4k
> pages and then you get into the case where the current code is totally
> unable to allocate THP from the other nodes and it would be totally
> possible to fix with the removal of __GFP_THISNODE |
> __GFP_COMPACT_ONLY, after the PAGE_SIZE watermark check.
> 
> I'm mentioning this optimization in this context, even if it's
> orthogonal, because the alternative patch that prioritizes THP over
> NUMA locality for MADV_HUGEPAGE and defer=always would solve that too
> with a one liner and there would be no need of watermark checking and
> flipping gfp bits whatsoever. Once the local node is full, THPs keeps
> being provided as expected.

Frankly, I would rather go with this option and assume that if someone
explicitly wants THP's, they don't care about NUMA locality that much.
(Note: I hate __GFP_THISNODE, it's an endless source of issues.)
Trying to be clever about "is there still PAGE_SIZEd free memory in the
local node" is imperfect anyway. If there isn't, is it because there's
clean page cache that we can easily reclaim (so it would be worth
staying local) or is it really exhausted? Watermark check won't tell...

Vlastimil

> Thanks,
> Andrea
> 
