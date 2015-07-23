Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 754059003C7
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 06:03:43 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so200773847wib.0
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 03:03:42 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id sb12si7444884wjb.77.2015.07.23.03.03.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Jul 2015 03:03:40 -0700 (PDT)
Subject: Re: [PATCH V4 4/6] mm: mlock: Introduce VM_LOCKONFAULT and add mlock
 flags to enable it
References: <1437508781-28655-1-git-send-email-emunson@akamai.com>
 <1437508781-28655-5-git-send-email-emunson@akamai.com>
 <55AF6A73.1080500@suse.cz> <20150722184343.GA2351@akamai.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55B0BBF9.7050802@suse.cz>
Date: Thu, 23 Jul 2015 12:03:37 +0200
MIME-Version: 1.0
In-Reply-To: <20150722184343.GA2351@akamai.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Jonathan Corbet <corbet@lwn.net>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On 07/22/2015 08:43 PM, Eric B Munson wrote:
> On Wed, 22 Jul 2015, Vlastimil Babka wrote:
> 
>> 
>> Hi,
>> 
>> I think you should include a complete description of which
>> transitions for vma states and mlock2/munlock2 flags applied on them
>> are valid and what they do. It will also help with the manpages.
>> You explained some to Jon in the last thread, but I think there
>> should be a canonical description in changelog (if not also
>> Documentation, if mlock is covered there).
>> 
>> For example the scenario Jon asked, what happens after a
>> mlock2(MLOCK_ONFAULT) followed by mlock2(MLOCK_LOCKED), and that the
>> answer is "nothing". Your promised code comment for
>> apply_vma_flags() doesn't suffice IMHO (and I'm not sure it's there,
>> anyway?).
> 
> I missed adding that comment to the code, will be there in V5 along with
> the description in the changelog.

Thanks!

>> 
>> But the more I think about the scenario and your new VM_LOCKONFAULT
>> vma flag, it seems awkward to me. Why should munlocking at all care
>> if the vma was mlocked with MLOCK_LOCKED or MLOCK_ONFAULT? In either
>> case the result is that all pages currently populated are munlocked.
>> So the flags for munlock2 should be unnecessary.
> 
> Say a user has a large area of interleaved MLOCK_LOCK and MLOCK_ONFAULT
> mappings and they want to unlock only the ones with MLOCK_LOCK.  With
> the current implementation, this is possible in a single system call
> that spans the entire region.  With your suggestion, the user would have
> to know what regions where locked with MLOCK_LOCK and call munlock() on
> each of them.  IMO, the way munlock2() works better mirrors the way
> munlock() currently works when called on a large area of interleaved
> locked and unlocked areas.

Um OK, that scenario is possible in theory. But I have a hard time imagining
that somebody would really want to do that. I think much more people would
benefit from a simpler API.

> 
>> 
>> I also think VM_LOCKONFAULT is unnecessary. VM_LOCKED should be
>> enough - see how you had to handle the new flag in all places that
>> had to handle the old flag? I think the information whether mlock
>> was supposed to fault the whole vma is obsolete at the moment mlock
>> returns. VM_LOCKED should be enough for both modes, and the flag to
>> mlock2 could just control whether the pre-faulting is done.
>> 
>> So what should be IMHO enough:
>> - munlock can stay without flags
>> - mlock2 has only one new flag MLOCK_ONFAULT. If specified,
>> pre-faulting is not done, just set VM_LOCKED and mlock pages already
>> present.
>> - same with mmap(MAP_LOCKONFAULT) (need to define what happens when
>> both MAP_LOCKED and MAP_LOCKONFAULT are specified).
>> 
>> Now mlockall(MCL_FUTURE) muddles the situation in that it stores the
>> information for future VMA's in current->mm->def_flags, and this
>> def_flags would need to distinguish VM_LOCKED with population and
>> without. But that could be still solvable without introducing a new
>> vma flag everywhere.
> 
> With you right up until that last paragraph.  I have been staring at
> this a while and I cannot come up a way to handle the
> mlockall(MCL_ONFAULT) without introducing a new vm flag.  It doesn't
> have to be VM_LOCKONFAULT, we could use the model that Michal Hocko
> suggested with something like VM_FAULTPOPULATE.  However, we can't
> really use this flag anywhere except the mlock code becuase we have to
> be able to distinguish a caller that wants to use MLOCK_LOCK with
> whatever control VM_FAULTPOPULATE might grant outside of mlock and a
> caller that wants MLOCK_ONFAULT.  That was a long way of saying we need
> an extra vma flag regardless.  However, if that flag only controls if
> mlock pre-populates it would work and it would do away with most of the
> places I had to touch to handle VM_LOCKONFAULT properly.

Yes, it would be a good way. Adding a new vma flag is probably cleanest after
all, but the flag would be set *in addition* to VM_LOCKED, *just* to prevent
pre-faulting. The places that check VM_LOCKED for the actual page mlocking (i.e.
try_to_unmap_one) would just keep checking VM_LOCKED. The places where VM_LOCKED
is checked to trigger prepopulation, would skip that if VM_LOCKONFAULT is also
set. Having VM_LOCKONFAULT set without also VM_LOCKED itself would be invalid state.

This should work fine with the simplified API as I proposed so let me reiterate
and try fill in the blanks:

- mlock2 has only one new flag MLOCK_ONFAULT. If specified, VM_LOCKONFAULT is
set in addition to VM_LOCKED and no prefaulting is done
  - old mlock syscall naturally behaves as mlock2 without MLOCK_ONFAULT
  - calling mlock/mlock2 on an already-mlocked area (if that's permitted
already?) will add/remove VM_LOCKONFAULT as needed. If it's removing,
prepopulate whole range. Of course adding VM_LOCKONFAULT to a vma that was
already prefaulted doesn't make any difference, but it's consistent with the rest.
- munlock removes both VM_LOCKED and VM_LOCKONFAULT
- mmap could treat MAP_LOCKONFAULT as a modifier to MAP_LOCKED to be consistent?
or not? I'm not sure here, either way subtly differs from mlock API anyway, I
just wish MAP_LOCKED never existed...
- mlockall(MCL_CURRENT) sets or clears VM_LOCKONFAULT depending on
MCL_LOCKONFAULT, mlockall(MCL_FUTURE) does the same on mm->def_flags
- munlockall2 removes both, like munlock. munlockall2(MCL_FUTURE) does that to
def_flags

> I picked VM_LOCKONFAULT because it is explicit about what it is for and
> there is little risk of someone coming along in 5 years and saying "why
> not overload this flag to do this other thing completely unrelated to
> mlock?".  A flag for controling speculative population is more likely to
> be overloaded outside of mlock().

Sure, let's make clear the name is related to mlock, but the behavior could
still be additive to MAP_LOCKED.

> If you have a sane way of handling mlockall(MCL_ONFAULT) without a new
> VMA flag, I am happy to give it a try, but I haven't been able to come
> up with one that doesn't have its own gremlins.

Well we could store the MCL_FUTURE | MCL_ONFAULT bit elsewhere in mm_struct than
the def_flags field. The VM_LOCKED field is already evaluated specially from all
the other def_flags. We are nearing the full 32bit space for vma flags. I think
all I've proposed above wouldn't change much if we removed per-vma
VM_LOCKONFAULT flag from the equation. Just that re-mlocking area already
mlocked *withouth* MLOCK_ONFAULT wouldn't know that it was alread prepopulated,
and would have to re-populate in either case (I'm not sure, maybe it's already
done by current implementation anyway so it's not a potential performance
regression).
Only mlockall(MCL_FUTURE | MCL_ONFAULT) should really need the ONFAULT info to
"stick" somewhere in mm_struct, but it doesn't have to be def_flags?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
