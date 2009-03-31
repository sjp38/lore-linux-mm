Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2D5906B0047
	for <linux-mm@kvack.org>; Tue, 31 Mar 2009 12:25:40 -0400 (EDT)
Date: Tue, 31 Mar 2009 18:25:25 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 4/4] add ksm kernel shared memory driver.
Message-ID: <20090331162525.GU9137@random.random>
References: <1238457560-7613-5-git-send-email-ieidus@redhat.com> <49D17C04.9070307@codemonkey.ws> <49D20B63.8020709@redhat.com> <49D21B33.4070406@codemonkey.ws> <20090331142533.GR9137@random.random> <49D22A9D.4050403@codemonkey.ws> <20090331150218.GS9137@random.random> <49D23224.9000903@codemonkey.ws> <20090331151845.GT9137@random.random> <49D23CD1.9090208@codemonkey.ws>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <49D23CD1.9090208@codemonkey.ws>
Sender: owner-linux-mm@kvack.org
To: Anthony Liguori <anthony@codemonkey.ws>
Cc: Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm@kvack.org, avi@redhat.com, chrisw@redhat.com, riel@redhat.com, jeremy@goop.org, mtosatti@redhat.com, hugh@veritas.com, corbet@lwn.net, yaniv@redhat.com, dmonakhov@openvz.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 31, 2009 at 10:54:57AM -0500, Anthony Liguori wrote:
> You can still disable ksm and simply return ENOSYS for the MADV_ flag.  You 

-EINVAL if something, -ENOSYS would tell userland that it shall stop
trying to use madvise, including the other MADV_ too.

> could even keep it as a module if you liked by separating the madvise bits 
> from the ksm bits.  The madvise() bits could just provide the tracking 
> infrastructure for determine which vmas were currently marked as sharable.
> You could then have ksm as loadable module that consumed that interface to 
> then perform scanning.

What's the point of making ksm a module if one has part of ksm code
loaded in the kernel and not being possible to avoid compiling in?
People that says KSM=N in their .config (like embedded running with 1M
of ram), don't want that tracking overhead compiled into the kernel.

Returning -EINVAL would be an option but again I think madvise is core
syscall for SuS and I don't like that those core VM parts returns
-EINVAL at will depend on certain kernel modules being loaded.

> A number of MADV_ flags are Linux specific (like 
> MADV_DOFORK/MADV_DONTFORK).

But those aren't kernel module related, so they're in line with the
standard ones and could be adapted by other OS.

KSM is not a core VM functionality, madvise is a core VM
functionality, so I don't see fit. KSM as ioctl or KSM creating
/proc/<pid>/ksm when loaded, sounds fine to me instead. If open of
either one fails, application won't register in. It's up to you to
choose KSM=M/N, if you want it as core functionality just build as
KSM=Y but leave the option to others to save memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
