Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 672796B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 06:45:37 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so20233809wib.1
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 03:45:36 -0700 (PDT)
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com. [209.85.212.177])
        by mx.google.com with ESMTPS id n3si26325367wib.44.2015.07.29.03.45.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jul 2015 03:45:35 -0700 (PDT)
Received: by wibud3 with SMTP id ud3so20130693wib.0
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 03:45:35 -0700 (PDT)
Date: Wed, 29 Jul 2015 12:45:32 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V5 0/7] Allow user to request memory to be locked on page
 fault
Message-ID: <20150729104532.GE15801@dhcp22.suse.cz>
References: <1437773325-8623-1-git-send-email-emunson@akamai.com>
 <55B5F4FF.9070604@suse.cz>
 <20150727133555.GA17133@akamai.com>
 <55B63D37.20303@suse.cz>
 <20150727145409.GB21664@akamai.com>
 <20150728111725.GG24972@dhcp22.suse.cz>
 <20150728134942.GB2407@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150728134942.GB2407@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Shuah Khan <shuahkh@osg.samsung.com>, Michael Kerrisk <mtk.manpages@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Ralf Baechle <ralf@linux-mips.org>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On Tue 28-07-15 09:49:42, Eric B Munson wrote:
> On Tue, 28 Jul 2015, Michal Hocko wrote:
> 
> > [I am sorry but I didn't get to this sooner.]
> > 
> > On Mon 27-07-15 10:54:09, Eric B Munson wrote:
> > > Now that VM_LOCKONFAULT is a modifier to VM_LOCKED and
> > > cannot be specified independentally, it might make more sense to mirror
> > > that relationship to userspace.  Which would lead to soemthing like the
> > > following:
> > 
> > A modifier makes more sense.
> >  
> > > To lock and populate a region:
> > > mlock2(start, len, 0);
> > > 
> > > To lock on fault a region:
> > > mlock2(start, len, MLOCK_ONFAULT);
> > > 
> > > If LOCKONFAULT is seen as a modifier to mlock, then having the flags
> > > argument as 0 mean do mlock classic makes more sense to me.
> > > 
> > > To mlock current on fault only:
> > > mlockall(MCL_CURRENT | MCL_ONFAULT);
> > > 
> > > To mlock future on fault only:
> > > mlockall(MCL_FUTURE | MCL_ONFAULT);
> > > 
> > > To lock everything on fault:
> > > mlockall(MCL_CURRENT | MCL_FUTURE | MCL_ONFAULT);
> > 
> > Makes sense to me. The only remaining and still tricky part would be
> > the munlock{all}(flags) behavior. What should munlock(MLOCK_ONFAULT)
> > do? Keep locked and poppulate the range or simply ignore the flag an
> > just unlock?
> > 
> > I can see some sense to allow munlockall(MCL_FUTURE[|MLOCK_ONFAULT]),
> > munlockall(MCL_CURRENT) resp. munlockall(MCL_CURRENT|MCL_FUTURE) but
> > other combinations sound weird to me.
> > 
> > Anyway munlock with flags opens new doors of trickiness.
> 
> In the current revision there are no new munlock[all] system calls
> introduced.  munlockall() unconditionally cleared both MCL_CURRENT and
> MCL_FUTURE before the set and now unconditionally clears all three.
> munlock() does the same for VM_LOCK and VM_LOCKONFAULT. 

OK if new munlock{all}(flags) is not introduced then this is much saner
IMO.

> If the user
> wants to adjust mlockall flags today, they need to call mlockall a
> second time with the new flags, this remains true for mlockall after
> this set and the same behavior is mirrored in mlock2. 

OK, this makes sense to me.

> The only
> remaining question I have is should we have 2 new mlockall flags so that
> the caller can explicitly set VM_LOCKONFAULT in the mm->def_flags vs
> locking all current VMAs on fault.  I ask because if the user wants to
> lock all current VMAs the old way, but all future VMAs on fault they
> have to call mlockall() twice:
> 
> 	mlockall(MCL_CURRENT);
> 	mlockall(MCL_CURRENT | MCL_FUTURE | MCL_ONFAULT);
> 
> This has the side effect of converting all the current VMAs to
> VM_LOCKONFAULT, but because they were all made present and locked in the
> first call, this should not matter in most cases. 

I think this is OK (worth documenting though) considering that ONFAULT
is just modifier for the current mlock* operation. The memory is locked
the same way for both - aka once the memory is present you do not know
whether it was done during mlock call or later during the fault.

> The catch is that,
> like mmap(MAP_LOCKED), mlockall() does not communicate if mm_populate()
> fails.  This has been true of mlockall() from the beginning so I don't
> know if it needs more than an entry in the man page to clarify (which I
> will add when I add documentation for MCL_ONFAULT).

Yes this is true but unlike mmap it seems fixable I guess. We do not have
to unmap and we can downgrade mmap_sem to read and the fault so nobody
can race with a concurent mlock.

> In a much less
> likely corner case, it is not possible in the current setup to request
> all current VMAs be VM_LOCKONFAULT and all future be VM_LOCKED.

Vlastimil has already pointed that out. MCL_FUTURE doesn't clear
MCL_CURRENT. I was quite surprised in the beginning but it makes a
perfect sense. mlockall call shouldn't lead into munlocking, that would
be just weird. Clearing MCL_FUTURE on MCL_CURRENT makes sense on the
other hand because the request is explicit about _current_ memory and it
doesn't lead to any munlocking.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
