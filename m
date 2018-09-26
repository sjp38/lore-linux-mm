Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4C3F98E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 03:17:13 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id j1-v6so750558edq.23
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 00:17:13 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 60-v6si6509643edy.200.2018.09.26.00.17.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Sep 2018 00:17:11 -0700 (PDT)
Date: Wed, 26 Sep 2018 09:17:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch v3] mm, thp: always specify disabled vmas as nh in smaps
Message-ID: <20180926071708.GB6278@dhcp22.suse.cz>
References: <alpine.DEB.2.21.1809241054050.224429@chino.kir.corp.google.com>
 <e2f159f3-5373-dda4-5904-ed24d029de3c@suse.cz>
 <alpine.DEB.2.21.1809241215170.239142@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1809241227370.241621@chino.kir.corp.google.com>
 <20180924195603.GJ18685@dhcp22.suse.cz>
 <20180924200258.GK18685@dhcp22.suse.cz>
 <0aa3eb55-82c0-eba3-b12c-2ba22e052a8e@suse.cz>
 <alpine.DEB.2.21.1809251248450.50347@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1809251449060.96762@chino.kir.corp.google.com>
 <20180926061247.GB18685@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180926061247.GB18685@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Alexey Dobriyan <adobriyan@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Wed 26-09-18 08:12:47, Michal Hocko wrote:
> On Tue 25-09-18 14:50:52, David Rientjes wrote:
> [...]
> Let's put my general disagreement with the approach asside for a while.
> If this is really the best way forward the is the implementation really
> correct?
> 
> > +	/*
> > +	 * Disabling thp is possible through both MADV_NOHUGEPAGE and
> > +	 * PR_SET_THP_DISABLE.  Both historically used VM_NOHUGEPAGE.  Since
> > +	 * the introduction of MMF_DISABLE_THP, however, userspace needs the
> > +	 * ability to detect vmas where thp is not eligible in the same manner.
> > +	 */
> > +	if (vma->vm_mm && test_bit(MMF_DISABLE_THP, &vma->vm_mm->flags)) {
> > +		flags &= ~VM_HUGEPAGE;
> > +		flags |= VM_NOHUGEPAGE;
> > +	}
> 
> Do we want to report all vmas nh? Shouldn't we limit that to THP-able
> mappings? It seems quite strange that an application started without
> PR_SET_THP_DISABLE wouldn't report nh for most mappings while it would
> otherwise. Also when can we have vma->vm_mm == NULL?

Hmm, after re-reading your documentation update to "A process mapping
may be advised to not be backed by transparent hugepages by either
madvise(MADV_NOHUGEPAGE) or prctl(PR_SET_THP_DISABLE)." the
implementation matches so scratch my comment.

As I've said, I am not happy about this approach but if there is a
general agreement this is really the best we can do I will not stand in
the way.
-- 
Michal Hocko
SUSE Labs
