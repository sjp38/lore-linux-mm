Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id B4BCD6B0032
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 15:21:32 -0400 (EDT)
Received: by qgg3 with SMTP id 3so4939134qgg.2
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 12:21:32 -0700 (PDT)
Received: from prod-mail-xrelay02.akamai.com (prod-mail-xrelay02.akamai.com. [72.246.2.14])
        by mx.google.com with ESMTP id o10si1537337qge.57.2015.06.11.12.21.31
        for <linux-mm@kvack.org>;
        Thu, 11 Jun 2015 12:21:31 -0700 (PDT)
Message-ID: <5579DFBA.80809@akamai.com>
Date: Thu, 11 Jun 2015 15:21:30 -0400
From: Eric B Munson <emunson@akamai.com>
MIME-Version: 1.0
Subject: Re: [RESEND PATCH V2 0/3] Allow user to request memory to be locked
 on page fault
References: <1433942810-7852-1-git-send-email-emunson@akamai.com> <20150610145929.b22be8647887ea7091b09ae1@linux-foundation.org>
In-Reply-To: <20150610145929.b22be8647887ea7091b09ae1@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, Michal Hocko <mhocko@suse.cz>, Michael Kerrisk <mtk.manpages@gmail.com>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

On 06/10/2015 05:59 PM, Andrew Morton wrote:
> On Wed, 10 Jun 2015 09:26:47 -0400 Eric B Munson
> <emunson@akamai.com> wrote:
> 
>> mlock() allows a user to control page out of program memory, but
>> this comes at the cost of faulting in the entire mapping when it
>> is
> 
> s/mapping/locked area/

Done.

> 
>> allocated.  For large mappings where the entire area is not
>> necessary this is not ideal.
>> 
>> This series introduces new flags for mmap() and mlockall() that
>> allow a user to specify that the covered are should not be paged
>> out, but only after the memory has been used the first time.
> 
> The comparison with MCL_FUTURE is hiding over in the 2/3 changelog.
>  It's important so let's copy it here.
> 
> : MCL_ONFAULT is preferrable to MCL_FUTURE for the use cases
> enumerated : in the previous patch becuase MCL_FUTURE will behave
> as if each mapping : was made with MAP_LOCKED, causing the entire
> mapping to be faulted in : when new space is allocated or mapped.
> MCL_ONFAULT allows the user to : delay the fault in cost of any
> given page until it is actually needed, : but then guarantees that
> that page will always be resident.

Done

> 
> I *think* it all looks OK.  I'd like someone else to go over it
> also if poss.
> 
> 
> I guess the 2/3 changelog should have something like
> 
> : munlockall() will clear MCL_ONFAULT on all vma's in the process's
> VM.

Done

> 
> It's pretty obvious, but the manpage delta should make this clear
> also.

Done

> 
> 
> Also the changelog(s) and manpage delta should explain that
> munlock() clears MCL_ONFAULT.

Done

> 
> And now I'm wondering what happens if userspace does 
> mmap(MAP_LOCKONFAULT) and later does munlock() on just part of
> that region.  Does the vma get split?  Is this tested?  Should also
> be in the changelogs and manpage.
> 
> Ditto mlockall(MCL_ONFAULT) followed by munlock().  I'm not sure
> that even makes sense but the behaviour should be understood and
> tested.

I have extended the kselftest for lock-on-fault to try both of these
scenarios and they work as expected.  The VMA is split and the VM
flags are set appropriately for the resulting VMAs.

> 
> 
> What's missing here is a syscall to set VM_LOCKONFAULT on an
> arbitrary range of memory - mlock() for lock-on-fault.  It's a
> shame that mlock() didn't take a `mode' argument.  Perhaps we
> should add such a syscall - that would make the mmap flag unneeded
> but I suppose it should be kept for symmetry.

Do you want such a system call as part of this set?  I would need some
time to make sure I had thought through all the possible corners one
could get into with such a call, so it would delay a V3 quite a bit.
Otherwise I can send a V3 out immediately.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJVed+3AAoJELbVsDOpoOa9eHwP+gO8QmNdUKN55wiTLxXdFTRo
TTm62MJ3Yk45+JJ+8xI1POMSUVEBAX7pxnL8TpNPmwp+UF6IQT/hAnnEFNud8/aQ
5bAxU9a5fRO6Q5533woaVpYfXZXwXAla+37MGQziL7O0VEi2aQ9abX7AKnkjmXwq
e1Fc3vutAycNCzSxg42GwZxqHw83TYztyv3C4Cc7lShbCezABYvaDvXcUZkGwhjG
KJxSPYS2E0nv0MEy995P0L0H1A/KHq6mCOFFKQw6aVbPDs8J/0RhvQIlp/BBCPMV
TqDVxMBpTpdWs6reJnUZpouKBTA11KTvUA2HBVn5B14u2V7Np+NBpLKH2DUqAP2v
Gyg4Nj0MknqB1rutaBjHjI0ZefrWK5o+zWAVKZs+wtq9WkmCvTYWp505XnlJO+qo
1CEnab2kX8P74UYcsJUrJxAtxc94t6oLh305KnJheQUdcx/ZNKboB2vl1+np10jj
oZLmP2RfajZoPojPZ/bI6mj9Ffqf/Ptau+kLQ56G1IuVmQRi4ZgQ9D1+BILXyKHi
uycKovcHVffiQ+z1Ama2b4wP1t5yjNdxBH0oV1KMeScCxfyYHPFuDBe36Krjo8FO
dDMyibNIRJMX6SeYNIRni40Eafon5h21I95/yWxUaq0FGBZ1NuuSTofxAA53wJJz
f0FUI7f53Oxk9EKk8nfg
=gfVJ
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
