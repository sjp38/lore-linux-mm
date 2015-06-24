Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id DAFC06B0070
	for <linux-mm@kvack.org>; Wed, 24 Jun 2015 04:50:16 -0400 (EDT)
Received: by wicgi11 with SMTP id gi11so39483781wic.0
        for <linux-mm@kvack.org>; Wed, 24 Jun 2015 01:50:16 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id it9si1657621wid.64.2015.06.24.01.50.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 24 Jun 2015 01:50:15 -0700 (PDT)
Date: Wed, 24 Jun 2015 10:50:13 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RESEND PATCH V2 1/3] Add mmap flag to request pages are locked
 after page fault
Message-ID: <20150624085013.GB32756@dhcp22.suse.cz>
References: <1433942810-7852-1-git-send-email-emunson@akamai.com>
 <1433942810-7852-2-git-send-email-emunson@akamai.com>
 <20150618152907.GG5858@dhcp22.suse.cz>
 <20150618203048.GB2329@akamai.com>
 <20150619145708.GG4913@dhcp22.suse.cz>
 <20150619164333.GD2329@akamai.com>
 <20150622123826.GF4430@dhcp22.suse.cz>
 <20150622141806.GE2329@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150622141806.GE2329@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On Mon 22-06-15 10:18:06, Eric B Munson wrote:
> On Mon, 22 Jun 2015, Michal Hocko wrote:
> 
> > On Fri 19-06-15 12:43:33, Eric B Munson wrote:
[...]
> > > Are you objecting to the addition of the VMA flag VM_LOCKONFAULT, or the
> > > new MAP_LOCKONFAULT flag (or both)? 
> > 
> > I thought the MAP_FAULTPOPULATE (or any other better name) would
> > directly translate into VM_FAULTPOPULATE and wouldn't be tight to the
> > locked semantic. We already have VM_LOCKED for that. The direct effect
> > of the flag would be to prevent from population other than the direct
> > page fault - including any speculative actions like fault around or
> > read-ahead.
> 
> I like the ability to control other speculative population, but I am not
> sure about overloading it with the VM_LOCKONFAULT case.  Here is my
> concern.  If we are using VM_FAULTPOPULATE | VM_LOCKED to denote
> LOCKONFAULT, how can we tell the difference between someone that wants
> to avoid read-ahead and wants to use mlock()?

Not sure I understand. Something like?
addr = mmap(VM_FAULTPOPULATE) # To prevent speculative mappings into the vma
[...]
mlock(addr, len) # Now I want the full mlock semantic

and the later to have the full mlock semantic and populate the given
area regardless of VM_FAULTPOPULATE being set on the vma? This would
be an interesting question because mlock man page clearly states the
semantic and that is to _always_ populate or fail. So I originally
thought that it would obey VM_FAULTPOPULATE but this needs a more
thinking.

> This might lead to some
> interesting states with mlock() and munlock() that take flags.  For
> instance, using VM_LOCKONFAULT mlock(MLOCK_ONFAULT) followed by
> munlock(MLOCK_LOCKED) leaves the VMAs in the same state with
> VM_LOCKONFAULT set. 

This is really confusing. Let me try to rephrase that. So you have
mlock(addr, len, MLOCK_ONFAULT)
munlock(addr, len, MLOCK_LOCKED)

IIUC you would expect the vma still being MLOCK_ONFAULT, right? Isn't
that behavior strange and unexpected? First of all, munlock has
traditionally dropped the lock on the address range (e.g. what should
happen if you did plain old munlock(addr, len)). But even without
that. You are trying to unlock something that hasn't been locked the
same way. So I would expect -EINVAL at least, if the two modes should be
really represented by different flags.

Or did you mean the both types of lock like:
mlock(addr, len, MLOCK_ONFAULT) | mmap(MAP_LOCKONFAULT)
mlock(addr, len, MLOCK_LOCKED)
munlock(addr, len, MLOCK_LOCKED)

and that should keep MLOCK_ONFAULT?
This sounds even more weird to me because that means that the vma in
question would be locked by two different mechanisms. MLOCK_LOCKED with
the "always populate" semantic would rule out MLOCK_ONFAULT so what
would be the meaning of the other flag then? Also what should regular
munlock(addr, len) without flags unlock? Both?

> If we use VM_FAULTPOPULATE, the same pair of calls
> would clear VM_LOCKED, but leave VM_FAULTPOPULATE.  It may not matter in
> the end, but I am concerned about the subtleties here.

This sounds like the proper behavior to me. munlock should simply always
drop VM_LOCKED and the VM_FAULTPOPULATE can live its separate life.

Btw. could you be more specific about semantic of m{un}lock(addr, len, flags)
you want to propose? The more I think about that the more I am unclear
about it, especially munlock behavior and possible flags.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
