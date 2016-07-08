Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E62D1828E1
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 06:15:34 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id r190so9055103wmr.0
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 03:15:34 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id 201si2206594wms.49.2016.07.08.03.15.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Jul 2016 03:15:32 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id 8DC222F80D5
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 10:15:32 +0000 (UTC)
Date: Fri, 8 Jul 2016 11:15:31 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 2/9] mm: implement new pkey_mprotect() system call
Message-ID: <20160708101530.GE11498@techsingularity.net>
References: <20160707124719.3F04C882@viggo.jf.intel.com>
 <20160707124722.DE1EE343@viggo.jf.intel.com>
 <20160707144031.GY11498@techsingularity.net>
 <577E88A8.8030909@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <577E88A8.8030909@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, dave.hansen@linux.intel.com, arnd@arndb.de, hughd@google.com, viro@zeniv.linux.org.uk

On Thu, Jul 07, 2016 at 09:51:52AM -0700, Dave Hansen wrote:
> > Looks like MASK could have been statically defined and be a simple shift
> > and mask known at compile time. Minor though.
> 
> The VM_PKEY_BIT*'s are only ever defined as masks and not bit numbers.
> So, if you want to use a mask, you end up doing something like:
> 
> 	unsigned long mask = (NR_PKEYS-1) << ffz(~VM_PKEY_BIT0);
> 
> Which ends up with the same thing, but I think ends up being pretty on
> par for ugliness.
> 

Fair enough.

> >> +/*
> >> + * When setting a userspace-provided value, we need to ensure
> >> + * that it is valid.  The __ version can get used by
> >> + * kernel-internal uses like the execute-only support.
> >> + */
> >> +int arch_set_user_pkey_access(struct task_struct *tsk, int pkey,
> >> +		unsigned long init_val)
> >> +{
> >> +	if (!validate_pkey(pkey))
> >> +		return -EINVAL;
> >> +	return __arch_set_user_pkey_access(tsk, pkey, init_val);
> >> +}
> > 
> > There appears to be a subtle bug fixed for validate_key. It appears
> > there wasn't protection of the dedicated key before but nothing could
> > reach it.
> 
> Right.  There was no user interface that took a key and we trusted that
> the kernel knew what it was doing.
> 

Ok. I was fairly sure that was the thinking behind it but wanted to be suire.

> > The arch_max_pkey and PKEY_DEDICATE_EXECUTE_ONLY interaction is subtle
> > but I can't find a problem with it either.
> > 
> > That aside, the validate_pkey check looks weak. It might be a number
> > that works but no guarantee it's an allocated key or initialised
> > properly. At this point, garbage can be handed into the system call
> > potentially but maybe that gets fixed later.
> 
> It's called in three paths:
> 1. by the kernel when setting up execute-only support
> 2. by pkey_alloc() on the pkey we just allocated
> 3. by pkey_set() on a pkey we just checked was allocated
> 
> So, it isn't broken, but it's also not clear at all why it is safe and
> what validate_pkey() is actually validating.
> 
> But, that said, this does make me realize that with
> pkey_alloc()/pkey_free(), this is probably redundant.  We verify that
> the key is allocated, and we only allow valid keys to be allocated.
> 
> IOW, I think I can remove validate_pkey(), but only if we keep pkey_alloc().
> 

Ok, it's not a major problem. I simply worried that the protection of
key slots is pretty weak as it can be interfered with from userspace.
On the other hand, the kernel never interprets the information so it's
unlikely to cause a security problem. Applications can still shoot
themselves in the foot but hopefully the developers are aware that the
protection they get with keys is not absolute.

> ...
> >> -		newflags = calc_vm_prot_bits(prot, pkey);
> >> +		new_vma_pkey = arch_override_mprotect_pkey(vma, prot, pkey);
> >> +		newflags = calc_vm_prot_bits(prot, new_vma_pkey);
> >>  		newflags |= (vma->vm_flags & ~(VM_READ | VM_WRITE | VM_EXEC));
> >>  
> > 
> > On CPUs that do not support the feature, arch_override_mprotect_pkey
> > returns 0 and the normal protections are used. It's not clear how an
> > application is meant to detect if the operation succeeded or not. What
> > if the application relies on pkeys to be working?
> 
> It actually shows up as -ENOSPC from pkey_alloc().  This sounds goofy,
> but it teaches programs something very important: they always have to
> look for ENOSPC, and must always be prepared to function without
> protection keys.

Ok, that makes sense. I don't think it's goofy. Sure, they cannot detect
the CPU support directly from the interface but it's close enough.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
