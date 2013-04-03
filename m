Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id EA64A6B0006
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 12:41:32 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 3 Apr 2013 12:41:31 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 374C26E8044
	for <linux-mm@kvack.org>; Wed,  3 Apr 2013 12:41:26 -0400 (EDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r33GfQUc270976
	for <linux-mm@kvack.org>; Wed, 3 Apr 2013 12:41:27 -0400
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r33GhmhD017271
	for <linux-mm@kvack.org>; Wed, 3 Apr 2013 10:43:49 -0600
Date: Wed, 3 Apr 2013 09:41:01 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: prevent mmap_cache race in find_vma()
Message-ID: <20130403164101.GA20957@linux.vnet.ibm.com>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130403163348.GD28522@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ian Lance Taylor <iant@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, Hugh Dickins <hughd@google.com>, Jan Stancek <jstancek@redhat.com>, linux-mm@kvack.org

On Wed, Apr 03, 2013 at 09:33:48AM -0700, Paul E. McKenney wrote:
> On Wed, Apr 03, 2013 at 06:45:51AM -0700, Ian Lance Taylor wrote:

[ . . . ]

> > If using a sufficiently recent version of GCC, you can get the
> > behaviour that I think you want by using
> >     __atomic_load(&x, __ATOMIC_RELAXED)
> 
> If this maps to the memory_order_relaxed token defined in earlier versions
> of the C11 standard, then this absolutely does -not-, repeat -not-, work
> for ACCESS_ONCE().  The relaxed load instead guarantees is that the load
> will be atomic with respect to other atomic stores to that same variable,
> in other words, it will prevent "load tearing" and "store tearing".  I
> also believe that it prevents reloading ...

In addition, even if the semantics of relaxed loads now guarantee against
load combining, note that ACCESS_ONCE() is also used to prevent combining
and splitting of stores, for example:

	ACCESS_ONCE(p) = give_me_a_pointer();

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
