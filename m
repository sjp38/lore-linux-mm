Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f176.google.com (mail-qk0-f176.google.com [209.85.220.176])
	by kanga.kvack.org (Postfix) with ESMTP id 795136B0032
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 15:55:49 -0400 (EDT)
Received: by qkhg32 with SMTP id g32so7771105qkh.0
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 12:55:49 -0700 (PDT)
Received: from prod-mail-xrelay07.akamai.com (prod-mail-xrelay07.akamai.com. [72.246.2.115])
        by mx.google.com with ESMTP id g36si1608137qgd.123.2015.06.11.12.55.48
        for <linux-mm@kvack.org>;
        Thu, 11 Jun 2015 12:55:48 -0700 (PDT)
Message-ID: <5579E7C3.2020601@akamai.com>
Date: Thu, 11 Jun 2015 15:55:47 -0400
From: Eric B Munson <emunson@akamai.com>
MIME-Version: 1.0
Subject: Re: [RESEND PATCH V2 0/3] Allow user to request memory to be locked
 on page fault
References: <1433942810-7852-1-git-send-email-emunson@akamai.com>	<20150610145929.b22be8647887ea7091b09ae1@linux-foundation.org>	<5579DFBA.80809@akamai.com> <20150611123424.4bb07cffd0e5bb146cc92231@linux-foundation.org>
In-Reply-To: <20150611123424.4bb07cffd0e5bb146cc92231@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, Michal Hocko <mhocko@suse.cz>, Michael Kerrisk <mtk.manpages@gmail.com>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 06/11/2015 03:34 PM, Andrew Morton wrote:
> On Thu, 11 Jun 2015 15:21:30 -0400 Eric B Munson
> <emunson@akamai.com> wrote:
> 
>>> Ditto mlockall(MCL_ONFAULT) followed by munlock().  I'm not
>>> sure that even makes sense but the behaviour should be
>>> understood and tested.
>> 
>> I have extended the kselftest for lock-on-fault to try both of
>> these scenarios and they work as expected.  The VMA is split and
>> the VM flags are set appropriately for the resulting VMAs.
> 
> munlock() should do vma merging as well.  I *think* we implemented 
> that.  More tests for you to add ;)

I will add a test for this as well.  But the code is in place to merge
VMAs IIRC.

> 
> How are you testing the vma merging and splitting, btw?  Parsing 
> the profcs files?

To show the VMA split happened, I dropped a printk in mlock_fixup()
and the user space test simply checks that unlocked pages are not
marked as unevictable.  The test does not parse maps or smaps for
actual VMA layout.  Given that we want to check the merging of VMAs as
well I will add this.

> 
>>> What's missing here is a syscall to set VM_LOCKONFAULT on an 
>>> arbitrary range of memory - mlock() for lock-on-fault.  It's a 
>>> shame that mlock() didn't take a `mode' argument.  Perhaps we 
>>> should add such a syscall - that would make the mmap flag
>>> unneeded but I suppose it should be kept for symmetry.
>> 
>> Do you want such a system call as part of this set?  I would need
>> some time to make sure I had thought through all the possible
>> corners one could get into with such a call, so it would delay a
>> V3 quite a bit. Otherwise I can send a V3 out immediately.
> 
> I think the way to look at this is to pretend that mm/mlock.c
> doesn't exist and ask "how should we design these features".
> 
> And that would be:
> 
> - mmap() takes a `flags' argument: MAP_LOCKED|MAP_LOCKONFAULT.
> 
> - mlock() takes a `flags' argument.  Presently that's 
> MLOCK_LOCKED|MLOCK_LOCKONFAULT.
> 
> - munlock() takes a `flags' arument.
> MLOCK_LOCKED|MLOCK_LOCKONFAULT to specify which flags are being
> cleared.
> 
> - mlockall() and munlockall() ditto.
> 
> 
> IOW, LOCKED and LOCKEDONFAULT are treated identically and
> independently.
> 
> Now, that's how we would have designed all this on day one.  And I 
> think we can do this now, by adding new mlock2() and munlock2() 
> syscalls.  And we may as well deprecate the old mlock() and
> munlock(), not that this matters much.
> 
> *should* we do this?  I'm thinking "yes" - it's all pretty simple 
> boilerplate and wrappers and such, and it gets the interface
> correct, and extensible.
> 
> What do others think?
> 

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVeefAAAoJELbVsDOpoOa9930P/j32OhsgPdxt8pmlYddpHBJg
PJ4EOYZLoNJ0bWAoePRAQvb9Rd0UumXukkQKVdFCFW72QfMPkjqyMWWOA5BZ6dYl
q3h3FTzcnAtVHG7bqFheV+Ie9ZX0dplTmuGlqTZzEIVePry9VXzqp9BADbWn3bVR
ucq1CFikyEB2yu8pMtykJmEaz4CO7fzCHz6oB7RNX5oHElWmi9AieuUr5eAw6enQ
6ofuNy/N3rTCwcjeRfdL7Xhs6vn62u4nw1Jey6l9hBQUx/ujMktKcn4VwkDXIYCi
+h7lfXWruqOuC+lspBRJO7OL2e6nRdedpDWJypeUGcKXokxB2FEB25Yu31K9sk/8
jDfaKNqmcfgOseLHb+DjJqG6nq9lsUhozg8C17SJpT8qFwQ8q7iJe+1GhUF1EBsL
+DpqLU56geBY6fyIfurOfp/4Hsx2u1KzezkEnMYT/8LkbGwqbq7Zj4rquLMSHCUt
uG5j0MuhmP8/Fuf8OMsIHHUMjBHRjH4rTyaCKxNj3T8uSuLfcnIqEZiJu2qaSA8l
PxpQ6yy2szw9lDxPvxLnh8Rkx+SGEc1ciamyppDTI4LQRiCjMQ7bHAKo0RwAaPJL
ZSHrdlDnUHrYTnd0EZwg0peh8AgkROgxna/pLpfQTeW1g3erqPfbI0Ab8N0cu5j0
8+qA5C+DeSjaMAoMskTG
=82B8
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
