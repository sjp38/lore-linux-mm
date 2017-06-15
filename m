Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C629F6B0338
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 04:32:29 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id u101so1909112wrc.2
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 01:32:29 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 2si2905549wrk.174.2017.06.15.01.32.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Jun 2017 01:32:28 -0700 (PDT)
Date: Thu, 15 Jun 2017 10:32:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Sleeping BUG in khugepaged for i586
Message-ID: <20170615083226.GA4649@dhcp22.suse.cz>
References: <968ae9a9-5345-18ca-c7ce-d9beaf9f43b6@lwfinger.net>
 <20170605144401.5a7e62887b476f0732560fa0@linux-foundation.org>
 <caa7a4a3-0c80-432c-2deb-3480df319f65@suse.cz>
 <1e883924-9766-4d2a-936c-7a49b337f9e2@lwfinger.net>
 <9ab81c3c-e064-66d2-6e82-fc9bac125f56@suse.cz>
 <alpine.DEB.2.10.1706071352100.38905@chino.kir.corp.google.com>
 <20170608144831.GA19903@dhcp22.suse.cz>
 <alpine.DEB.2.10.1706141809390.124136@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1706141809390.124136@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Larry Finger <Larry.Finger@lwfinger.net>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed 14-06-17 18:12:06, David Rientjes wrote:
> On Thu, 8 Jun 2017, Michal Hocko wrote:
> 
> > collapse_huge_page
> >   pte_offset_map
> >     kmap_atomic
> >       kmap_atomic_prot
> >         preempt_disable
> >   __collapse_huge_page_copy
> >   pte_unmap
> >     kunmap_atomic
> >       __kunmap_atomic
> >         preempt_enable
> > 
> > I suspect, so cond_resched seems indeed inappropriate on 32b systems.
> > 
> 
> Seems to be an issue for i386 and arm with ARM_LPAE.  I'm slightly 
> surprised we can get away with __collapse_huge_page_swapin() for 
> VM_FAULT_RETRY, unless that hasn't been encountered yet.

I do not see what you mean here or how is it related.
__collapse_huge_page_swapin is called outside of
pte_offset_map/pte_unmap section

> I think the cond_resched() in __collapse_huge_page_copy() could be
> done only for !in_atomic() if we choose.

in_atomic() depends on having PREEMPT_COUNT enabled to work properly AFAIR.
I haven't double checked and something might have changed since I've
looked the last time.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
