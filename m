Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id CEFB66B006C
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 08:19:34 -0400 (EDT)
Received: by wgbdm7 with SMTP id dm7so54047897wgb.1
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 05:19:34 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ul19si12514722wib.116.2015.04.07.05.19.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 07 Apr 2015 05:19:33 -0700 (PDT)
Date: Tue, 7 Apr 2015 14:19:32 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -v2] mm, memcg: sync allocation and memcg charge gfp
 flags for THP
Message-ID: <20150407121932.GE7935@dhcp22.suse.cz>
References: <1426514892-7063-1-git-send-email-mhocko@suse.cz>
 <55098D0A.8090605@suse.cz>
 <20150318150257.GL17241@dhcp22.suse.cz>
 <55099C72.1080102@suse.cz>
 <20150318155905.GO17241@dhcp22.suse.cz>
 <5509A31C.3070108@suse.cz>
 <20150318161407.GP17241@dhcp22.suse.cz>
 <alpine.DEB.2.10.1504031832490.18005@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1504031832490.18005@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri 03-04-15 18:34:18, David Rientjes wrote:
> On Wed, 18 Mar 2015, Michal Hocko wrote:
> 
> > memcg currently uses hardcoded GFP_TRANSHUGE gfp flags for all THP
> > charges. THP allocations, however, might be using different flags
> > depending on /sys/kernel/mm/transparent_hugepage/{,khugepaged/}defrag
> > and the current allocation context.
> > 
> > The primary difference is that defrag configured to "madvise" value will
> > clear __GFP_WAIT flag from the core gfp mask to make the allocation
> > lighter for all mappings which are not backed by VM_HUGEPAGE vmas.
> > If memcg charge path ignores this fact we will get light allocation but
> > the a potential memcg reclaim would kill the whole point of the
> > configuration.
> > 
> > Fix the mismatch by providing the same gfp mask used for the
> > allocation to the charge functions. This is quite easy for all
> > paths except for hugepaged kernel thread with !CONFIG_NUMA which is
> > doing a pre-allocation long before the allocated page is used in
> > collapse_huge_page via khugepaged_alloc_page. To prevent from cluttering
> > the whole code path from khugepaged_do_scan we simply return the current
> > flags as per khugepaged_defrag() value which might have changed since
> > the preallocation. If somebody changed the value of the knob we would
> > charge differently but this shouldn't happen often and it is definitely
> > not critical because it would only lead to a reduced success rate of
> > one-off THP promotion.
> > 
> > Acked-by: Vlastimil Babka <vbabka@suse.cz>
> > Signed-off-by: Michal Hocko <mhocko@suse.cz>
> 
> Acked-by: David Rientjes <rientjes@google.com>

Thanks!

> I'm slightly surprised that this issue never got reported before.

I am afraid not many people are familiar with the effect of
/sys/kernel/mm/transparent_hugepage/{,khugepaged/}defrag knob(s).

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
