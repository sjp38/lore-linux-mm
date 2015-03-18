Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 655836B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 11:59:08 -0400 (EDT)
Received: by wibg7 with SMTP id g7so94166070wib.1
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 08:59:07 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ex9si4378659wic.44.2015.03.18.08.59.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Mar 2015 08:59:07 -0700 (PDT)
Date: Wed, 18 Mar 2015 16:59:05 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm, memcg: sync allocation and memcg charge gfp flags
 for THP
Message-ID: <20150318155905.GO17241@dhcp22.suse.cz>
References: <1426514892-7063-1-git-send-email-mhocko@suse.cz>
 <55098D0A.8090605@suse.cz>
 <20150318150257.GL17241@dhcp22.suse.cz>
 <55099C72.1080102@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55099C72.1080102@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 18-03-15 16:40:34, Vlastimil Babka wrote:
> On 03/18/2015 04:02 PM, Michal Hocko wrote:
> >On Wed 18-03-15 15:34:50, Vlastimil Babka wrote:
> >>On 03/16/2015 03:08 PM, Michal Hocko wrote:
> >>>@@ -1080,6 +1080,7 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
> >>>  	unsigned long haddr;
> >>>  	unsigned long mmun_start;	/* For mmu_notifiers */
> >>>  	unsigned long mmun_end;		/* For mmu_notifiers */
> >>>+	gfp_t huge_gfp = GFP_TRANSHUGE;	/* for allocation and charge */
> >>
> >>This value is actually never used. Is it here because the compiler emits a
> >>spurious non-initialized value warning otherwise? It should be easy for it
> >>to prove that setting new_page to something non-null implies initializing
> >>huge_gfp (in the hunk below), and NULL new_page means it doesn't reach the
> >>mem_cgroup_try_charge() call?
> >
> >No, I haven't tried to workaround the compiler. It just made the code
> >more obvious to me. I can remove the initialization if you prefer, of
> >course.
> 
> Yeah IMHO it would be better to remove it, if possible. Leaving it has the
> (albeit small) chance that future patch will again use the value in the code
> before it's determined based on defrag setting.
 
Wouldn't an uninitialized value be used in such a case?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
