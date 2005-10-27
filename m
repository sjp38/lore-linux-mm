Date: Thu, 27 Oct 2005 22:16:27 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [RFC] madvise(MADV_TRUNCATE)
Message-ID: <20051027201627.GU5091@opteron.random>
References: <1130366995.23729.38.camel@localhost.localdomain> <200510271038.52277.ak@suse.de> <20051027131725.GI5091@opteron.random> <1130425212.23729.55.camel@localhost.localdomain> <20051027151123.GO5091@opteron.random> <20051027112054.10e945ae.akpm@osdl.org> <1130438135.23729.111.camel@localhost.localdomain> <20051027115050.7f5a6fb7.akpm@osdl.org> <20051027200515.GB12407@thunk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20051027200515.GB12407@thunk.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Theodore Ts'o <tytso@mit.edu>
Cc: Andrew Morton <akpm@osdl.org>, Badari Pulavarty <pbadari@us.ibm.com>, ak@suse.de, hugh@veritas.com, jdike@addtoit.com, dvhltc@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Ted,

On Thu, Oct 27, 2005 at 04:05:15PM -0400, Theodore Ts'o wrote:
> Does this sound like an idea that would be workable?  I'm not a VM
> expert, but it doesn't sound like it's that hard, and I don't see any
> obvious flaws with this plan.

AFIK, the closest thing today is a MADV_DONTNEED.

Actually our MADV_DONTNEED is equivalent to the Slowlaris MADV_FREE. Our
MADV_DONTNEED is too aggressive for anonymous memory (IIRC their
MADV_DONTNEED is not destructive).

So in short our linux MADV_DONTNEED already does what you suggested for
anonymous memory and it effectively implements the MADV_FREE (actually
our MADV_DONTNEED also works on non-anymous vmas, but it's not
destructive for the non anonymous vmas, our MADV_DONTNEED is destructive
only for the anonymous vmas).

Our MADV_DONTNEED is a bit heavy though, not as heavy as an munmap but
quite heavy too since it will walk all the pagetables for the region you
unmap. No syscall is still cheaper than MADV_DONTNEED ;)

I think we should rename our MADV_DONTNEED to MADV_FREE since we already
match the semantics of MADV_FREE, the only difference is that our
MADV_DONTNEED doesn't return -EINVAL if the mapping is not anonymous
(i.e. filebacked).

The place where MADV_TRUNCATE kicks in is for the filebacked vmas, for
the anonymous vmas our MADV_DONTNEED already works.

Not sure if we should change MADV_TRUNCATE to transparently fallback to
MADV_FREE for the anonymous vmas. That would provide an universal
destructive API that works anywhere (as long as there's some vma mapped
in the region). OTOH forcing people to use MADV_TRUNCATE for filebacked
vmas, and MADV_FREE for anonymous vmas would be more strict behaviour,
but then it's less handy to use.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
