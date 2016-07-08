Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E006E6B0005
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 11:15:29 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f126so14715422wma.3
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 08:15:29 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id b19si3266973wmf.40.2016.07.08.08.15.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jul 2016 08:15:28 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 76E5F1C3108
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 16:15:27 +0100 (IST)
Date: Fri, 8 Jul 2016 16:15:19 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [RFC][PATCH] x86, pkeys: scalable pkey_set()/pkey_get()
Message-ID: <20160708151518.GA9806@techsingularity.net>
References: <20160707230922.ED44A9DA@viggo.jf.intel.com>
 <20160708103526.GG11498@techsingularity.net>
 <577FBEAC.9050500@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <577FBEAC.9050500@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, mingo@kernel.org, dave.hansen@intel.com

On Fri, Jul 08, 2016 at 07:54:36AM -0700, Dave Hansen wrote:
> > Userspace may have no choice other than to serialise itself but the
> > documentation needs to be clear that the above race is possible.
> 
> Yeah, I'll clarify the documentation.  But, I do think this is one of
> those races like an stat().  A stat() tells you that a file was once
> there with so and so properties, but it does not mean that it is there
> any more or that what _is_ there is the same thing you stat()'d.
> 

Thanks, that would be a perfect example to put in. My initial impression
what that pkeys would give all sorts of guarantees when the reality is
a bit more relaxed and still depends on application correctness. While
that is admittedly due to my lack of familiarity with the specifics,
it's reasonable to assume that application developers may make the same
mistake unless the documentation is explicit.

> >> diff -puN arch/x86/include/asm/pkeys.h~pkeys-119-fast-set-get arch/x86/include/asm/pkeys.h
> >> --- a/arch/x86/include/asm/pkeys.h~pkeys-119-fast-set-get	2016-07-07 12:26:19.265421712 -0700
> >> +++ b/arch/x86/include/asm/pkeys.h	2016-07-07 15:18:15.391642423 -0700
> >> @@ -35,18 +35,47 @@ extern int __arch_set_user_pkey_access(s
> >>  
> >>  #define ARCH_VM_PKEY_FLAGS (VM_PKEY_BIT0 | VM_PKEY_BIT1 | VM_PKEY_BIT2 | VM_PKEY_BIT3)
> >>  
> >> +#define PKEY_MAP_SET	1
> >> +#define PKEY_MAP_CLEAR	2
> >>  #define mm_pkey_allocation_map(mm)	(mm->context.pkey_allocation_map)
> >> -#define mm_set_pkey_allocated(mm, pkey) do {		\
> >> -	mm_pkey_allocation_map(mm) |= (1U << pkey);	\
> >> +static inline
> >> +void mm_modify_pkey_alloc_map(struct mm_struct *mm, int pkey, int setclear)
> >> +{
> >> +	u16 new_map = mm_pkey_allocation_map(mm);
> >> +	if (setclear == PKEY_MAP_SET)
> >> +		new_map |= (1U << pkey);
> >> +	else if (setclear == PKEY_MAP_CLEAR)
> >> +		new_map &= ~(1U << pkey);
> >> +	else
> >> +		BUILD_BUG_ON(1);
> >> +	/*
> >> +	 * Make sure that mm_pkey_is_allocated() callers never
> >> +	 * see intermediate states by using WRITE_ONCE().
> >> +	 * Concurrent calls to this function are excluded by
> >> +	 * down_write(mm->mmap_sem) so we only need to protect
> >> +	 * against readers.
> >> +	 */
> >> +	WRITE_ONCE(mm_pkey_allocation_map(mm), new_map);
> >> +}
> > 
> > What prevents two pkey_set operations overwriting each others change with
> > WRITE_ONCE? Does this not need to be a cmpxchg read-modify-write loops?
> 
> pkey_set() only reads the allocation map and only writes to PKRU which
> is thread-local.
> 

My bad, thanks for the clarification.

It's ok to put my ack on the patches up to but not including the
pkey_[set|get] one, even with the fix on top. It's not a reviewed-by because
reviewed-by's for me are rare and only happen if I've actually tested them.

For pkey_[set|get], I'm still a little cagey until I know more about how
glibc intends to use them and I've still not 100% convinced myself they
are necessary even though I like the additional protection they give,
races or otherwise. I didn't read the documentation patch closely (I just
read your HTML version) and I didn't read the selftests at all so an ack
would be inappropriate. I'll read the documentation patch and probably ack
it if I see more details there about the potential races and why userspace
has to be careful.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
