Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id D46026B00A3
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 00:58:24 -0400 (EDT)
Date: Wed, 3 Apr 2013 00:58:14 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm: prevent mmap_cache race in find_vma()
Message-ID: <20130403045814.GD4611@cmpxchg.org>
References: <3ae9b7e77e8428cfeb34c28ccf4a25708cbea1be.1364938782.git.jstancek@redhat.com>
 <alpine.DEB.2.02.1304021532220.25286@chino.kir.corp.google.com>
 <alpine.LNX.2.00.1304021600420.22412@eggly.anvils>
 <alpine.DEB.2.02.1304021643260.3217@chino.kir.corp.google.com>
 <20130403041447.GC4611@cmpxchg.org>
 <alpine.DEB.2.02.1304022122030.32184@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1304022122030.32184@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hughd@google.com>, Jan Stancek <jstancek@redhat.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ian Lance Taylor <iant@google.com>, linux-mm@kvack.org

On Tue, Apr 02, 2013 at 09:25:40PM -0700, David Rientjes wrote:
> On Wed, 3 Apr 2013, Johannes Weiner wrote:
> 
> > The definition of ACCESS_ONCE() relies on gcc's current
> > implementation, the users of ACCESS_ONCE() only rely on ACCESS_ONCE()
> > being defined.
> > 
> > Should it ever break you have to either fix it at the implementation
> > level or remove/replace the abstraction in its entirety, how does the
> > individual callsite matter in this case?
> > 
> 
> As stated, it doesn't.  I made the comment "for what it's worth" that 
> ACCESS_ONCE() doesn't do anything to "prevent the compiler from 
> re-fetching" as the changelog insists it does.

That's exactly what it does:

/*
 * Prevent the compiler from merging or refetching accesses.

This is the guarantee ACCESS_ONCE() gives, users should absolutely be
allowed to rely on this literal definition.  The underlying gcc
implementation does not matter one bit.  That's the whole point of
abstraction!

> I'd much rather it refer to gcc's implementation, which we're
> counting on here,

No, we really don't.  There is no

  "(*(volatile typeof(x)*)&(x))"

anywhere in this patch.

> to avoid any confusion since I know a couple people have thought
> that ACCESS_ONCE() forces the compiler to load memory onto the stack
> and that belief is completely and utterly wrong.

Maybe "forces the compiler to load memory onto the stack" should be
removed from the documentation of ACCESS_ONCE() then?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
