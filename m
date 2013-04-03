Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 0F95B6B0005
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 13:47:29 -0400 (EDT)
Received: by mail-ob0-f171.google.com with SMTP id x4so1666819obh.2
        for <linux-mm@kvack.org>; Wed, 03 Apr 2013 10:47:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130403163348.GD28522@linux.vnet.ibm.com>
References: <3ae9b7e77e8428cfeb34c28ccf4a25708cbea1be.1364938782.git.jstancek@redhat.com>
	<alpine.DEB.2.02.1304021532220.25286@chino.kir.corp.google.com>
	<alpine.LNX.2.00.1304021600420.22412@eggly.anvils>
	<alpine.DEB.2.02.1304021643260.3217@chino.kir.corp.google.com>
	<20130403041447.GC4611@cmpxchg.org>
	<alpine.DEB.2.02.1304022122030.32184@chino.kir.corp.google.com>
	<20130403045814.GD4611@cmpxchg.org>
	<CAKOQZ8wPBO7so_b=4RZvUa38FY8kMzJcS5ZDhhS5+-r_krOAYw@mail.gmail.com>
	<20130403163348.GD28522@linux.vnet.ibm.com>
Date: Wed, 3 Apr 2013 10:47:28 -0700
Message-ID: <CAKOQZ8wd24AUCN2c6p9iLFeHMpJy=jRO2xoiKkH93k=+iYQpEA@mail.gmail.com>
Subject: Re: [PATCH] mm: prevent mmap_cache race in find_vma()
From: Ian Lance Taylor <iant@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul McKenney <paulmck@linux.vnet.ibm.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Jan Stancek <jstancek@redhat.com>, linux-mm@kvack.org

On Wed, Apr 3, 2013 at 9:33 AM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
> On Wed, Apr 03, 2013 at 06:45:51AM -0700, Ian Lance Taylor wrote:
>
>> The C language standard only describes how access to
>> volatile-qualified objects behave.  In this case x is (presumably) not
>> a volatile-qualifed object.  The standard never defines the behaviour
>> of volatile-qualified pointers.  That might seem like an oversight,
>> but it is not: using a non-volatile-qualified pointer to access a
>> volatile-qualified object is undefined behaviour.
>>
>> In short, casting a pointer to a non-volatile-qualified object to a
>> volatile-qualified pointer has no specific meaning in C.  It's true
>> that most compilers will behave as you wish, but there is no
>> guarantee.
>
> But we are not using a non-volatile-qualified pointer to access a
> volatile-qualified object.  We are doing the opposite.  I therefore
> don't understand the relevance of your comment about undefined behavior.

That was just a digression to explain why the standard does not need
to define the behaviour of volatile-qualified pointers.


>> If using a sufficiently recent version of GCC, you can get the
>> behaviour that I think you want by using
>>     __atomic_load(&x, __ATOMIC_RELAXED)
>
> If this maps to the memory_order_relaxed token defined in earlier versions
> of the C11 standard, then this absolutely does -not-, repeat -not-, work
> for ACCESS_ONCE().

Yes, I'm sorry, you are right.  It will work in practice today but
you're quite right that there is no reason to think that it will work
in principle.

This need suggests that GCC needs a new builtin function to implement
the functionality that you want.  Would you consider opening a request
for that at http://gcc.gnu.org/bugzilla/ ?

Ian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
