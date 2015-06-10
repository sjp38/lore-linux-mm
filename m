Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 043446B0032
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 17:59:32 -0400 (EDT)
Received: by pabqy3 with SMTP id qy3so41913152pab.3
        for <linux-mm@kvack.org>; Wed, 10 Jun 2015 14:59:31 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id xg10si15784457pbc.254.2015.06.10.14.59.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jun 2015 14:59:31 -0700 (PDT)
Date: Wed, 10 Jun 2015 14:59:29 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RESEND PATCH V2 0/3] Allow user to request memory to be locked
 on page fault
Message-Id: <20150610145929.b22be8647887ea7091b09ae1@linux-foundation.org>
In-Reply-To: <1433942810-7852-1-git-send-email-emunson@akamai.com>
References: <1433942810-7852-1-git-send-email-emunson@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, Michal Hocko <mhocko@suse.cz>, Michael Kerrisk <mtk.manpages@gmail.com>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On Wed, 10 Jun 2015 09:26:47 -0400 Eric B Munson <emunson@akamai.com> wrote:

> mlock() allows a user to control page out of program memory, but this
> comes at the cost of faulting in the entire mapping when it is

s/mapping/locked area/

> allocated.  For large mappings where the entire area is not necessary
> this is not ideal.
> 
> This series introduces new flags for mmap() and mlockall() that allow a
> user to specify that the covered are should not be paged out, but only
> after the memory has been used the first time.

The comparison with MCL_FUTURE is hiding over in the 2/3 changelog. 
It's important so let's copy it here.

: MCL_ONFAULT is preferrable to MCL_FUTURE for the use cases enumerated
: in the previous patch becuase MCL_FUTURE will behave as if each mapping
: was made with MAP_LOCKED, causing the entire mapping to be faulted in
: when new space is allocated or mapped.  MCL_ONFAULT allows the user to
: delay the fault in cost of any given page until it is actually needed,
: but then guarantees that that page will always be resident.

I *think* it all looks OK.  I'd like someone else to go over it also if
poss.


I guess the 2/3 changelog should have something like

: munlockall() will clear MCL_ONFAULT on all vma's in the process's VM.

It's pretty obvious, but the manpage delta should make this clear also.


Also the changelog(s) and manpage delta should explain that munlock()
clears MCL_ONFAULT.

And now I'm wondering what happens if userspace does
mmap(MAP_LOCKONFAULT) and later does munlock() on just part of that
region.  Does the vma get split?  Is this tested?  Should also be in
the changelogs and manpage.

Ditto mlockall(MCL_ONFAULT) followed by munlock().  I'm not sure that
even makes sense but the behaviour should be understood and tested.


What's missing here is a syscall to set VM_LOCKONFAULT on an arbitrary
range of memory - mlock() for lock-on-fault.  It's a shame that mlock()
didn't take a `mode' argument.  Perhaps we should add such a syscall -
that would make the mmap flag unneeded but I suppose it should be kept
for symmetry.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
