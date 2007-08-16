Received: by fk-out-0910.google.com with SMTP id 18so149102fkq
        for <linux-mm@kvack.org>; Thu, 16 Aug 2007 00:09:25 -0700 (PDT)
Message-ID: <5201e28f0708160009n2ef3ffc8ie4ce4133cc9c3a13@mail.gmail.com>
Date: Thu, 16 Aug 2007 09:09:24 +0200
From: "Stefan Bader" <Stefan.Bader@de.ibm.com>
Subject: Re: [dm-devel] Re: [PATCH] dm: Fix deadlock under high i/o load in raid1 setup.
In-Reply-To: <20070815201029.fb965871.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070813113340.GB30198@osiris.boeblingen.de.ibm.com>
	 <20070815155604.87318305.akpm@linux-foundation.org>
	 <20070815235956.GD8741@osiris.ibm.com>
	 <20070815201029.fb965871.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: device-mapper development <dm-devel@redhat.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>, Stefan Weinhuber <wein@de.ibm.com>, linux-mm@kvack.org, Daniel Kobras <kobras@linux.de>, Linus Torvalds <torvalds@linux-foundation.org>, Alasdair G Kergon <agk@redhat.com>
List-ID: <linux-mm.kvack.org>

>>> How come my computer is the only one with a reply button?

Hey, I've got one. ;-)

2007/8/16, Andrew Morton <akpm@linux-foundation.org>:
> On Thu, 16 Aug 2007 01:59:56 +0200 Heiko Carstens <heiko.carstens@de.ibm.com> wrote:
>
> > > So yes, I'd say this is a bug in DM.
> > >
> > > Also, __rh_alloc() is called under read_lock(), via __rh_find().  If
> > > __rh_alloc()'s mempool_alloc() fails, it will perform a sleeping allocation
> > > under read_lock(), which is deadlockable and will generate might_sleep()
> > > warnings
> >
> > The read_lock() is unlocked at the beginning of the function.
>
> Oh, OK.  Looks odd, but whatever.
>

The major trick, if I am not wrong, is to use GFP_ATOMIC on that
mempool_alloc(). This prevents the sleeping allocation but fails, if
memory as well as the pool is exhausted.

>
> It'd be better to fix the kmirrord design so that it can use mempools
> properly.  One possible way of doing that might be to notice when mempool
> exhaustion happens, submit whatever IO is thus-far buffered up and then do
> a sleeping mempool allocation, to wait for that memory to come free (via IO
> completion).
>
> That would be a bit abusive of the mempool intent though.  A more idiomatic
> fix would be to change kmirrord so that it no longer can consume all of the
> mempool's reserves without having submitted any I/O (which is what I assume
> it is doing).
>

The problem is, that only the same thread, that allocates from the
pool would return memory back. This would be done before the new
allocations. But, if there is very high memory pressure, the pool
might get drained in the allocation cycle. Then mempool_alloc() waits
to be woken from mempool_free(). And this never happens, since the
thread will be stuck. So I guess the fix would be to somehow separate
the allocation and freeing functionality. If I remember correctly
back, the patch was always seen as "not quite correctly, but seems to
work". However, due to lack of time, nobody ever came up with a better
solution.

Stefan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
