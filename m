Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8BD7B6B02C3
	for <linux-mm@kvack.org>; Wed, 31 May 2017 06:24:46 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b86so1555001wmi.6
        for <linux-mm@kvack.org>; Wed, 31 May 2017 03:24:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g15si6921122wrb.153.2017.05.31.03.24.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 31 May 2017 03:24:45 -0700 (PDT)
Date: Wed, 31 May 2017 12:24:42 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
Message-ID: <20170531102442.GF27783@dhcp22.suse.cz>
References: <20170530074408.GA7969@dhcp22.suse.cz>
 <20170530101921.GA25738@rapoport-lnx>
 <20170530103930.GB7969@dhcp22.suse.cz>
 <20170530140456.GA8412@redhat.com>
 <20170530143941.GK7969@dhcp22.suse.cz>
 <20170530145632.GL7969@dhcp22.suse.cz>
 <20170530160610.GC8412@redhat.com>
 <e371b76b-d091-72d0-16c3-5227820595f0@suse.cz>
 <20170531082414.GB27783@dhcp22.suse.cz>
 <20170531092659.GB25375@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170531092659.GB25375@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Wed 31-05-17 12:27:00, Mike Rapoport wrote:
> On Wed, May 31, 2017 at 10:24:14AM +0200, Michal Hocko wrote:
> > On Wed 31-05-17 08:30:08, Vlastimil Babka wrote:
> > > On 05/30/2017 06:06 PM, Andrea Arcangeli wrote:
> > > > 
> > > > I'm not sure if it should be considered a bug, the prctl is intended
> > > > to use normally by wrappers so it looks optimal as implemented this
> > > > way: affecting future vmas only, which will all be created after
> > > > execve executed by the wrapper.
> > > > 
> > > > What's the point of messing with the prctl so it mangles over the
> > > > wrapper process own vmas before exec? Messing with those vmas is pure
> > > > wasted CPUs for the wrapper use case which is what the prctl was
> > > > created for.
> > > > 
> > > > Furthermore there would be the risk a program that uses the prctl not
> > > > as a wrapper and then calls the prctl to clear VM_NOHUGEPAGE from
> > > > def_flags assuming the current kABI. The program could assume those
> > > > vmas that were instantiated before disabling the prctl are still with
> > > > VM_NOHUGEPAGE set (they would not after the change you propose).
> > > > 
> > > > Adding a scan of all vmas to PR_SET_THP_DISABLE to clear VM_NOHUGEPAGE
> > > > on existing vmas looks more complex too and less finegrined so
> > > > probably more complex for userland to manage
> > > 
> > > I would expect the prctl wouldn't iterate all vma's, nor would it modify
> > > def_flags anymore. It would just set a flag somewhere in mm struct that
> > > would be considered in addition to the per-vma flags when deciding
> > > whether to use THP.
> > 
> > Exactly. Something like the below (not even compile tested).
> 
> If we set aside the argument for keeping the kABI, this seems, hmm, a bit
> more complex than new madvise() :)

Yes, code wise it is more LOC which is not all that great but semantic
wise it make much more sense than the current implementation of
PR_SET_THP_DISABLE.

> It seems that for CRIU usecase such behaviour of prctl will work and it
> probably will be even more convenient than madvise(). Nonetheless, I think
> madvise() is the more elegant and correct solution.
> 
> > > We could consider whether MADV_HUGEPAGE should be
> > > able to override the prctl or not.
> > 
> > This should be a master override to any per vma setting.
> 
> Currently, MADV_HUGEPAGE overrides the prctl(PR_SET_THP_DISABLE)...
> AFAIU, the prctl was intended to work with applications unaware of THP and
> for the cases where addition of MADV_*HUGEPAGE to the application was not
> an option.

which makes it even more weird API IMHO.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
