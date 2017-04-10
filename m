Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0A35C6B0038
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 08:19:34 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k22so16160029wrk.5
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 05:19:33 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id l20si14070886wrc.333.2017.04.10.05.19.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Apr 2017 05:19:32 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id D367A99358
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 12:19:31 +0000 (UTC)
Date: Mon, 10 Apr 2017 13:19:31 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm, numa: Fix bad pmd by atomically check for
 pmd_trans_huge when marking page tables prot_numa
Message-ID: <20170410121931.ytuebes7lvjbwfim@techsingularity.net>
References: <20170410094825.2yfo5zehn7pchg6a@techsingularity.net>
 <e3a97c78-0016-318c-27b7-e6fc3a76c5a6@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <e3a97c78-0016-318c-27b7-e6fc3a76c5a6@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Apr 10, 2017 at 12:03:20PM +0200, Vlastimil Babka wrote:
> On 04/10/2017 11:48 AM, Mel Gorman wrote:
> > A user reported a bug against a distribution kernel while running
> > a proprietary workload described as "memory intensive that is not
> > swapping" that is expected to apply to mainline kernels. The workload
> > is read/write/modifying ranges of memory and checking the contents. They
> > reported that within a few hours that a bad PMD would be reported followed
> > by a memory corruption where expected data was all zeros.  A partial report
> > of the bad PMD looked like
> > 
> > [ 5195.338482] ../mm/pgtable-generic.c:33: bad pmd ffff8888157ba008(000002e0396009e2)
> > [ 5195.341184] ------------[ cut here ]------------
> > [ 5195.356880] kernel BUG at ../mm/pgtable-generic.c:35!
> > ....
> > [ 5195.410033] Call Trace:
> > [ 5195.410471]  [<ffffffff811bc75d>] change_protection_range+0x7dd/0x930
> > [ 5195.410716]  [<ffffffff811d4be8>] change_prot_numa+0x18/0x30
> > [ 5195.410918]  [<ffffffff810adefe>] task_numa_work+0x1fe/0x310
> > [ 5195.411200]  [<ffffffff81098322>] task_work_run+0x72/0x90
> > [ 5195.411246]  [<ffffffff81077139>] exit_to_usermode_loop+0x91/0xc2
> > [ 5195.411494]  [<ffffffff81003a51>] prepare_exit_to_usermode+0x31/0x40
> > [ 5195.411739]  [<ffffffff815e56af>] retint_user+0x8/0x10
> > 
> > Decoding revealed that the PMD was a valid prot_numa PMD and the bad PMD
> > was a false detection. The bug does not trigger if automatic NUMA balancing
> > or transparent huge pages is disabled.
> > 
> > The bug is due a race in change_pmd_range between a pmd_trans_huge and
> > pmd_nond_or_clear_bad check without any locks held. During the pmd_trans_huge
> > check, a parallel protection update under lock can have cleared the PMD
> > and filled it with a prot_numa entry between the transhuge check and the
> > pmd_none_or_clear_bad check.
> > 
> > While this could be fixed with heavy locking, it's only necessary to
> > make a copy of the PMD on the stack during change_pmd_range and avoid
> > races. A new helper is created for this as the check if quite subtle and the
> > existing similar helpful is not suitable. This passed 154 hours of testing
> > (usually triggers between 20 minutes and 24 hours) without detecting bad
> > PMDs or corruption. A basic test of an autonuma-intensive workload showed
> > no significant change in behaviour.
> > 
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> > Cc: stable@vger.kernel.org
> 
> It would be better if there was a Fixes: tag, or at least version hint. Assuming
> it's since autonuma balancing was merged?
> 

Fair point. It's all the way back to 3.15 rather than all the way back to
the introduction of automatic NUMA balancing so

Cc: stable@vger.kernel.org # 3.15+

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
