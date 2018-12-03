Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E54956B6A0B
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 11:15:50 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id i55so6774810ede.14
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 08:15:50 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id h11si2273718edw.123.2018.12.03.08.15.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 08:15:49 -0800 (PST)
Date: Mon, 3 Dec 2018 08:15:38 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -V7 RESEND 08/21] swap: Support to read a huge swap
 cluster for swapin a THP
Message-ID: <20181203161538.gxleg2ugdj2woadr@ca-dmjordan1.us.oracle.com>
References: <20181120085449.5542-1-ying.huang@intel.com>
 <20181120085449.5542-9-ying.huang@intel.com>
 <20181130233201.6yuzbhymtjddvf3u@ca-dmjordan1.us.oracle.com>
 <8736rirsox.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8736rirsox.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

On Sat, Dec 01, 2018 at 08:34:06AM +0800, Huang, Ying wrote:
> Daniel Jordan <daniel.m.jordan@oracle.com> writes:
> > What do you think?
> 
> I think that swapoff() which is the main user of try_to_unuse() isn't a
> common operation in practical.  So it's not necessary to make it more
> complex for this.

Ok, probably not worth the surgery on try_to_unuse, even if swapoff can be
expensive when it does happen.

> In alloc_hugepage_direct_gfpmask(), the only information provided by vma
> is: vma->flags & VM_HUGEPAGE.  Because we have no vma available, I think
> it is OK to just assume that the flag is cleared.  That is, rely on
> system-wide THP settings only.
> 
> What do you think about this proposal?

Sounds like a good compromise.

So alloc_hugepage_direct_gfpmask will learn to make 'vma' optional?  Slightly
concerned that future callers that should be passing vma's might not and open a
way to ignore vma huge page hints, but probably not a big deal in practice.  
