Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id A4CC26B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 10:48:35 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id w91so5126687wrb.13
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 07:48:35 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o21si5099579wro.277.2017.06.08.07.48.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 08 Jun 2017 07:48:34 -0700 (PDT)
Date: Thu, 8 Jun 2017 16:48:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Sleeping BUG in khugepaged for i586
Message-ID: <20170608144831.GA19903@dhcp22.suse.cz>
References: <968ae9a9-5345-18ca-c7ce-d9beaf9f43b6@lwfinger.net>
 <20170605144401.5a7e62887b476f0732560fa0@linux-foundation.org>
 <caa7a4a3-0c80-432c-2deb-3480df319f65@suse.cz>
 <1e883924-9766-4d2a-936c-7a49b337f9e2@lwfinger.net>
 <9ab81c3c-e064-66d2-6e82-fc9bac125f56@suse.cz>
 <alpine.DEB.2.10.1706071352100.38905@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1706071352100.38905@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Larry Finger <Larry.Finger@lwfinger.net>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed 07-06-17 13:56:01, David Rientjes wrote:
> On Wed, 7 Jun 2017, Vlastimil Babka wrote:
> 
> > >> Hmm I'd expect such spin lock to be reported together with mmap_sem in
> > >> the debugging "locks held" message?
> > > 
> > > My bisection of the problem is about half done. My latest good version is commit 
> > > 7b8cd33 and the latest bad one is 2ea659a. Only about 7 steps to go.
> > 
> > Hmm, your bisection will most likely just find commit 338a16ba15495
> > which added the cond_resched() at mm/khugepaged.c:655. CCing David who
> > added it.
> > 
> 
> I agree it's probably going to bisect to 338a16ba15495 since it's the 
> cond_resched() at the line number reported, but I think there must be 
> something else going on.  I think the list of locks held by khugepaged is 
> correct because it matches with the implementation.  The preempt_count(), 
> as suggested by Andrew, does not.  If this is reproducible, I'd like to 
> know what preempt_count() is.

collapse_huge_page
  pte_offset_map
    kmap_atomic
      kmap_atomic_prot
        preempt_disable
  __collapse_huge_page_copy
  pte_unmap
    kunmap_atomic
      __kunmap_atomic
        preempt_enable

I suspect, so cond_resched seems indeed inappropriate on 32b systems.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
