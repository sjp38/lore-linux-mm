Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7287C8E0001
	for <linux-mm@kvack.org>; Fri, 28 Sep 2018 20:50:34 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id y8-v6so7113689pfl.11
        for <linux-mm@kvack.org>; Fri, 28 Sep 2018 17:50:34 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id s16-v6si6029820pgg.19.2018.09.28.17.50.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Sep 2018 17:50:33 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -V5 RESEND 03/21] swap: Support PMD swap mapping in swap_duplicate()
References: <20180925071348.31458-1-ying.huang@intel.com>
	<20180925071348.31458-4-ying.huang@intel.com>
	<20180925191953.4ped5ki7u3ymafmd@ca-dmjordan1.us.oracle.com>
	<874lecifj4.fsf@yhuang-dev.intel.com>
	<20180926145145.6xp2kxpngyd54f6i@ca-dmjordan1.us.oracle.com>
	<87r2hfhger.fsf@yhuang-dev.intel.com>
	<20180927211238.ly3e7cyvfu3rswcv@ca-dmjordan1.us.oracle.com>
	<87lg7mf30o.fsf@yhuang-dev.intel.com>
	<20180928213224.tjff2rtfmxmnz5nq@ca-dmjordan1.us.oracle.com>
Date: Sat, 29 Sep 2018 08:50:29 +0800
In-Reply-To: <20180928213224.tjff2rtfmxmnz5nq@ca-dmjordan1.us.oracle.com>
	(Daniel Jordan's message of "Fri, 28 Sep 2018 14:32:24 -0700")
Message-ID: <877ej5f7oq.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Zi Yan <zi.yan@cs.rutgers.edu>

Daniel Jordan <daniel.m.jordan@oracle.com> writes:

> On Fri, Sep 28, 2018 at 04:19:03PM +0800, Huang, Ying wrote:
>> Daniel Jordan <daniel.m.jordan@oracle.com> writes:
>> > One way is to change
>> > copy_one_pte's return to int so we can just pass the error code back to
>> > copy_pte_range so it knows whether to try adding the continuation.
>> 
>> There may be even more problems.  After add_swap_count_continuation(),
>> copy_one_pte() will be retried, and the CPU may hang with dead loop.
>
> That's true, it would do that.
>
>> But before the changes in this patchset, the behavior is,
>> __swap_duplicate() return an error that isn't -ENOMEM, such as -EEXIST.
>> Then copy_one_pte() would thought the operation has been done
>> successfully, and go to call set_pte_at().  This will cause the system
>> state become inconsistent, and the system may panic or hang somewhere
>> later.
>> 
>> So per my understanding, if we thought page table corruption isn't a
>> real problem (that is, __swap_duplicate() will never return e.g. -EEXIST
>> if copied by copy_one_pte() indirectly), both the original and the new
>> code should be OK.
>> 
>> If we thought it is a real problem, we need to fix the original code and
>> keep it fixed in the new code.  Do you agree?
>
> Yes, if it was a real problem, which seems less and less the case the more I
> stare at this.
>
>> There's several ways to fix the problem.  But the page table shouldn't
>> be corrupted in practice, unless there's some programming error.  So I
>> suggest to make it as simple as possible via adding,
>> 
>> VM_BUG_ON(error != -ENOMEM);
>> 
>> in swap_duplicate().
>> 
>> Do you agree?
>
> Yes, I'm ok with that, adding in -ENOTDIR along with it.

Sure.  I will do this.

> The error handling in __swap_duplicate (before this series) still leaves
> something to be desired IMHO.  Why all the different returns when callers
> ignore them or only specifically check for -ENOMEM or -EEXIST?  Could maybe
> stand a cleanup, but outside this series.

Yes.  Maybe.  I guess you will work on this?

Best Regards,
Huang, Ying
