Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 925B66B0036
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 09:45:52 -0400 (EDT)
Received: by mail-ob0-f172.google.com with SMTP id tb18so1409583obb.3
        for <linux-mm@kvack.org>; Wed, 03 Apr 2013 06:45:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130403045814.GD4611@cmpxchg.org>
References: <3ae9b7e77e8428cfeb34c28ccf4a25708cbea1be.1364938782.git.jstancek@redhat.com>
	<alpine.DEB.2.02.1304021532220.25286@chino.kir.corp.google.com>
	<alpine.LNX.2.00.1304021600420.22412@eggly.anvils>
	<alpine.DEB.2.02.1304021643260.3217@chino.kir.corp.google.com>
	<20130403041447.GC4611@cmpxchg.org>
	<alpine.DEB.2.02.1304022122030.32184@chino.kir.corp.google.com>
	<20130403045814.GD4611@cmpxchg.org>
Date: Wed, 3 Apr 2013 06:45:51 -0700
Message-ID: <CAKOQZ8wPBO7so_b=4RZvUa38FY8kMzJcS5ZDhhS5+-r_krOAYw@mail.gmail.com>
Subject: Re: [PATCH] mm: prevent mmap_cache race in find_vma()
From: Ian Lance Taylor <iant@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Jan Stancek <jstancek@redhat.com>, Paul McKenney <paulmck@linux.vnet.ibm.com>, linux-mm@kvack.org

On Tue, Apr 2, 2013 at 9:58 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Tue, Apr 02, 2013 at 09:25:40PM -0700, David Rientjes wrote:
>
>> As stated, it doesn't.  I made the comment "for what it's worth" that
>> ACCESS_ONCE() doesn't do anything to "prevent the compiler from
>> re-fetching" as the changelog insists it does.
>
> That's exactly what it does:
>
> /*
>  * Prevent the compiler from merging or refetching accesses.
>
> This is the guarantee ACCESS_ONCE() gives, users should absolutely be
> allowed to rely on this literal definition.  The underlying gcc
> implementation does not matter one bit.  That's the whole point of
> abstraction!

If the definition of ACCESS_ONCE is indeed

#define ACCESS_ONCE(x) (*(volatile typeof(x) *)&(x))

then its behaviour is compiler-specific.

The C language standard only describes how access to
volatile-qualified objects behave.  In this case x is (presumably) not
a volatile-qualifed object.  The standard never defines the behaviour
of volatile-qualified pointers.  That might seem like an oversight,
but it is not: using a non-volatile-qualified pointer to access a
volatile-qualified object is undefined behaviour.

In short, casting a pointer to a non-volatile-qualified object to a
volatile-qualified pointer has no specific meaning in C.  It's true
that most compilers will behave as you wish, but there is no
guarantee.

If using a sufficiently recent version of GCC, you can get the
behaviour that I think you want by using
    __atomic_load(&x, __ATOMIC_RELAXED)

Ian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
