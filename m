Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 97E1E6B0038
	for <linux-mm@kvack.org>; Fri, 13 Nov 2015 01:14:38 -0500 (EST)
Received: by pasz6 with SMTP id z6so93195814pas.2
        for <linux-mm@kvack.org>; Thu, 12 Nov 2015 22:14:38 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id iu1si25177437pbd.163.2015.11.12.22.14.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Nov 2015 22:14:37 -0800 (PST)
Date: Fri, 13 Nov 2015 15:15:11 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 01/17] mm: support madvise(MADV_FREE)
Message-ID: <20151113061511.GB5235@bbox>
References: <1447302793-5376-1-git-send-email-minchan@kernel.org>
 <1447302793-5376-2-git-send-email-minchan@kernel.org>
 <CALCETrWA6aZC_3LPM3niN+2HFjGEm_65m9hiEdpBtEZMn0JhwQ@mail.gmail.com>
 <564421DA.9060809@gmail.com>
MIME-Version: 1.0
In-Reply-To: <564421DA.9060809@gmail.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Micay <danielmicay@gmail.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jason Evans <je@fb.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Shaohua Li <shli@kernel.org>, Michal Hocko <mhocko@suse.cz>, yalin wang <yalin.wang2010@gmail.com>

On Thu, Nov 12, 2015 at 12:21:30AM -0500, Daniel Micay wrote:
> > I also think that the kernel should commit to either zeroing the page
> > or leaving it unchanged in response to MADV_FREE (even if the decision
> > of which to do is made later on).  I think that your patch series does
> > this, but only after a few of the patches are applied (the swap entry
> > freeing), and I think that it should be a real guaranteed part of the
> > semantics and maybe have a test case.
> 
> This would be a good thing to test because it would be required to add
> MADV_FREE_UNDO down the road. It would mean the same semantics as the
> MEM_RESET and MEM_RESET_UNDO features on Windows, and there's probably
> value in that for the sake of migrating existing software too.

So, do you mean that we could implement MADV_FREE_UNDO with "read"
opearation("just access bit marking) easily in future?

If so, it would be good reason to change MADV_FREE from dirty bit to
access bit. Okay, I will look at that.

> 
> For one example, it could be dropped into Firefox:
> 
> https://dxr.mozilla.org/mozilla-central/source/memory/volatile/VolatileBufferWindows.cpp
> 
> And in Chromium:
> 
> https://code.google.com/p/chromium/codesearch#chromium/src/base/memory/discardable_shared_memory.cc
> 
> Worth noting that both also support the API for pinning/unpinning that's
> used by Android's ashmem too. Linux really needs a feature like this for
> caches. Firefox simply doesn't drop the memory at all on Linux right now:
> 
> https://dxr.mozilla.org/mozilla-central/source/memory/volatile/VolatileBufferFallback.cpp
> 
> (Lock == pin, Unlock == unpin)
> 
> For reference:
> 
> https://msdn.microsoft.com/en-us/library/windows/desktop/aa366887(v=vs.85).aspx
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
