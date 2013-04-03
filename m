Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 6A1256B0005
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 18:11:37 -0400 (EDT)
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 3 Apr 2013 16:11:36 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 2409A3E4004E
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 16:11:21 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r33MBWEE115726
	for <linux-mm@kvack.org>; Wed, 3 Apr 2013 16:11:32 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r33MEGbA032173
	for <linux-mm@kvack.org>; Wed, 3 Apr 2013 16:14:17 -0600
Date: Wed, 3 Apr 2013 15:11:29 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: prevent mmap_cache race in find_vma()
Message-ID: <20130403221129.GL28522@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <3ae9b7e77e8428cfeb34c28ccf4a25708cbea1be.1364938782.git.jstancek@redhat.com>
 <alpine.DEB.2.02.1304021532220.25286@chino.kir.corp.google.com>
 <alpine.LNX.2.00.1304021600420.22412@eggly.anvils>
 <alpine.DEB.2.02.1304021643260.3217@chino.kir.corp.google.com>
 <20130403041447.GC4611@cmpxchg.org>
 <alpine.DEB.2.02.1304022122030.32184@chino.kir.corp.google.com>
 <20130403045814.GD4611@cmpxchg.org>
 <CAKOQZ8wPBO7so_b=4RZvUa38FY8kMzJcS5ZDhhS5+-r_krOAYw@mail.gmail.com>
 <20130403163348.GD28522@linux.vnet.ibm.com>
 <CAKOQZ8wd24AUCN2c6p9iLFeHMpJy=jRO2xoiKkH93k=+iYQpEA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKOQZ8wd24AUCN2c6p9iLFeHMpJy=jRO2xoiKkH93k=+iYQpEA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ian Lance Taylor <iant@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Jan Stancek <jstancek@redhat.com>, linux-mm@kvack.org

On Wed, Apr 03, 2013 at 10:47:28AM -0700, Ian Lance Taylor wrote:
> On Wed, Apr 3, 2013 at 9:33 AM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> > On Wed, Apr 03, 2013 at 06:45:51AM -0700, Ian Lance Taylor wrote:
> >
> >> The C language standard only describes how access to
> >> volatile-qualified objects behave.  In this case x is (presumably) not
> >> a volatile-qualifed object.  The standard never defines the behaviour
> >> of volatile-qualified pointers.  That might seem like an oversight,
> >> but it is not: using a non-volatile-qualified pointer to access a
> >> volatile-qualified object is undefined behaviour.
> >>
> >> In short, casting a pointer to a non-volatile-qualified object to a
> >> volatile-qualified pointer has no specific meaning in C.  It's true
> >> that most compilers will behave as you wish, but there is no
> >> guarantee.
> >
> > But we are not using a non-volatile-qualified pointer to access a
> > volatile-qualified object.  We are doing the opposite.  I therefore
> > don't understand the relevance of your comment about undefined behavior.
> 
> That was just a digression to explain why the standard does not need
> to define the behaviour of volatile-qualified pointers.
> 
> 
> >> If using a sufficiently recent version of GCC, you can get the
> >> behaviour that I think you want by using
> >>     __atomic_load(&x, __ATOMIC_RELAXED)
> >
> > If this maps to the memory_order_relaxed token defined in earlier versions
> > of the C11 standard, then this absolutely does -not-, repeat -not-, work
> > for ACCESS_ONCE().
> 
> Yes, I'm sorry, you are right.  It will work in practice today but
> you're quite right that there is no reason to think that it will work
> in principle.
> 
> This need suggests that GCC needs a new builtin function to implement
> the functionality that you want.  Would you consider opening a request
> for that at http://gcc.gnu.org/bugzilla/ ?

How about a request for gcc to formally honor the current uses of volatile?

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
