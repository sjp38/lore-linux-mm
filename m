Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6CC6B0279
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 08:27:08 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 8so9617738wms.11
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 05:27:08 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w13si19181608edf.60.2017.06.01.05.27.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 05:27:07 -0700 (PDT)
Date: Thu, 1 Jun 2017 14:27:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: introduce MADV_CLR_HUGEPAGE
Message-ID: <20170601122703.GB9091@dhcp22.suse.cz>
References: <20170530074408.GA7969@dhcp22.suse.cz>
 <20170530101921.GA25738@rapoport-lnx>
 <20170530103930.GB7969@dhcp22.suse.cz>
 <20170530140456.GA8412@redhat.com>
 <20170530143941.GK7969@dhcp22.suse.cz>
 <20170530145632.GL7969@dhcp22.suse.cz>
 <20170530160610.GC8412@redhat.com>
 <e371b76b-d091-72d0-16c3-5227820595f0@suse.cz>
 <20170531082414.GB27783@dhcp22.suse.cz>
 <20170601110048.GE30495@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170601110048.GE30495@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@virtuozzo.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>

On Thu 01-06-17 14:00:48, Mike Rapoport wrote:
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
> I did a quick go with the patch, compiles just fine :)
> It worked for my simple examples, the THP is enabled/disabled as expected
> and the vma->vm_flags are indeed unaffected.
> 
> > > We could consider whether MADV_HUGEPAGE should be
> > > able to override the prctl or not.
> > 
> > This should be a master override to any per vma setting.
> 
> Here you've introduced a change to the current behaviour. Consider the
> following sequence:
> 
> {
> 	prctl(PR_SET_THP_DISABLE);
> 	address = mmap(...);
> 	madvise(address, len, MADV_HUGEPAGE);
> }
>
> Currently, for the vma that backs the address
> transparent_hugepage_enabled(vma) will return true, and after your patch it
> will return false.
> The new behaviour may be more correct, I just wanted to bring the change to
> attention. 

The system wide disable should override any VMA specific setting
IMHO. Why would we disable the THP for the whole process otherwise?
Anyway this needs to be discussed at linux-api mailing list. I will try
to make my change into a proper patch and post it there.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
