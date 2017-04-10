Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 77A526B0390
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 14:07:16 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id w30so9836930wrc.2
        for <linux-mm@kvack.org>; Mon, 10 Apr 2017 11:07:16 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id u108si9858594wrb.323.2017.04.10.11.07.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Apr 2017 11:07:15 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id CEA0D1C222D
	for <linux-mm@kvack.org>; Mon, 10 Apr 2017 19:07:14 +0100 (IST)
Date: Mon, 10 Apr 2017 19:07:14 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm, numa: Fix bad pmd by atomically check for
 pmd_trans_huge when marking page tables prot_numa
Message-ID: <20170410180714.7yfnxl7qin72jcob@techsingularity.net>
References: <20170410094825.2yfo5zehn7pchg6a@techsingularity.net>
 <84B5E286-4E2A-4DE0-8351-806D2102C399@cs.rutgers.edu>
 <20170410172056.shyx6qzcjglbt5nd@techsingularity.net>
 <8A6309F4-DB76-48FA-BE7F-BF9536A4C4E5@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <8A6309F4-DB76-48FA-BE7F-BF9536A4C4E5@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Apr 10, 2017 at 12:49:40PM -0500, Zi Yan wrote:
> On 10 Apr 2017, at 12:20, Mel Gorman wrote:
> 
> > On Mon, Apr 10, 2017 at 11:45:08AM -0500, Zi Yan wrote:
> >>> While this could be fixed with heavy locking, it's only necessary to
> >>> make a copy of the PMD on the stack during change_pmd_range and avoid
> >>> races. A new helper is created for this as the check if quite subtle and the
> >>> existing similar helpful is not suitable. This passed 154 hours of testing
> >>> (usually triggers between 20 minutes and 24 hours) without detecting bad
> >>> PMDs or corruption. A basic test of an autonuma-intensive workload showed
> >>> no significant change in behaviour.
> >>>
> >>> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> >>> Cc: stable@vger.kernel.org
> >>
> >> Does this patch fix the same problem fixed by Kirill's patch here?
> >> https://lkml.org/lkml/2017/3/2/347
> >>
> >
> > I don't think so. The race I'm concerned with is due to locks not being
> > held and is in a different path.
> 
> I do not agree. Kirill's patch is fixing the same race problem but in
> zap_pmd_range().
> 
> The original autoNUMA code first clears PMD then sets it to protnone entry.
> pmd_trans_huge() does not return TRUE because it saw cleared PMD, but
> pmd_none_or_clear_bad() later saw the protnone entry and reported it as bad.
> Is this the problem you are trying solve?
> 
> Kirill's patch will pmdp_invalidate() the PMD entry, which keeps _PAGE_PSE bit,
> so pmd_trans_huge() will return TRUE. In this case, it also fixes
> your race problem in change_pmd_range().
> 
> Let me know if I miss anything.
> 

Ok, now I see. I think you're correct and I withdraw the patch.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
