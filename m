Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 81E618E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 17:32:41 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id t18-v6so3863385ite.1
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 14:32:41 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 203-v6si3609634ioo.226.2018.09.28.14.32.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Sep 2018 14:32:40 -0700 (PDT)
Date: Fri, 28 Sep 2018 14:32:24 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -V5 RESEND 03/21] swap: Support PMD swap mapping in
 swap_duplicate()
Message-ID: <20180928213224.tjff2rtfmxmnz5nq@ca-dmjordan1.us.oracle.com>
References: <20180925071348.31458-1-ying.huang@intel.com>
 <20180925071348.31458-4-ying.huang@intel.com>
 <20180925191953.4ped5ki7u3ymafmd@ca-dmjordan1.us.oracle.com>
 <874lecifj4.fsf@yhuang-dev.intel.com>
 <20180926145145.6xp2kxpngyd54f6i@ca-dmjordan1.us.oracle.com>
 <87r2hfhger.fsf@yhuang-dev.intel.com>
 <20180927211238.ly3e7cyvfu3rswcv@ca-dmjordan1.us.oracle.com>
 <87lg7mf30o.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87lg7mf30o.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

On Fri, Sep 28, 2018 at 04:19:03PM +0800, Huang, Ying wrote:
> Daniel Jordan <daniel.m.jordan@oracle.com> writes:
> > One way is to change
> > copy_one_pte's return to int so we can just pass the error code back to
> > copy_pte_range so it knows whether to try adding the continuation.
> 
> There may be even more problems.  After add_swap_count_continuation(),
> copy_one_pte() will be retried, and the CPU may hang with dead loop.

That's true, it would do that.

> But before the changes in this patchset, the behavior is,
> __swap_duplicate() return an error that isn't -ENOMEM, such as -EEXIST.
> Then copy_one_pte() would thought the operation has been done
> successfully, and go to call set_pte_at().  This will cause the system
> state become inconsistent, and the system may panic or hang somewhere
> later.
> 
> So per my understanding, if we thought page table corruption isn't a
> real problem (that is, __swap_duplicate() will never return e.g. -EEXIST
> if copied by copy_one_pte() indirectly), both the original and the new
> code should be OK.
> 
> If we thought it is a real problem, we need to fix the original code and
> keep it fixed in the new code.  Do you agree?

Yes, if it was a real problem, which seems less and less the case the more I
stare at this.

> There's several ways to fix the problem.  But the page table shouldn't
> be corrupted in practice, unless there's some programming error.  So I
> suggest to make it as simple as possible via adding,
> 
> VM_BUG_ON(error != -ENOMEM);
> 
> in swap_duplicate().
> 
> Do you agree?

Yes, I'm ok with that, adding in -ENOTDIR along with it.

The error handling in __swap_duplicate (before this series) still leaves
something to be desired IMHO.  Why all the different returns when callers
ignore them or only specifically check for -ENOMEM or -EEXIST?  Could maybe
stand a cleanup, but outside this series.
