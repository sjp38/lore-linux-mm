Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m7JHhuws028821
	for <linux-mm@kvack.org>; Tue, 19 Aug 2008 13:43:56 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7JHfCnq179284
	for <linux-mm@kvack.org>; Tue, 19 Aug 2008 13:41:12 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7JHfBC7032673
	for <linux-mm@kvack.org>; Tue, 19 Aug 2008 13:41:11 -0400
Subject: Re: [discuss] memrlimit - potential applications that can use
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <48AAF8C0.1010806@linux.vnet.ibm.com>
References: <48AA73B5.7010302@linux.vnet.ibm.com>
	 <1219161525.23641.125.camel@nimitz>  <48AAF8C0.1010806@linux.vnet.ibm.com>
Content-Type: text/plain
Date: Tue, 19 Aug 2008 10:41:09 -0700
Message-Id: <1219167669.23641.156.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Paul Menage <menage@google.com>, Dave Hansen <haveblue@us.ibm.com>, Andrea Righi <righi.andrea@gmail.com>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux kernel mailing list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2008-08-19 at 22:15 +0530, Balbir Singh wrote:
> Dave Hansen wrote:
> > On Tue, 2008-08-19 at 12:48 +0530, Balbir Singh wrote:
> >> 1. To provide a soft landing mechanism for applications that exceed their memory
> >> limit. Currently in the memory resource controller, we swap and on failure OOM.
> >> 2. To provide a mechanism similar to memory overcommit for control groups.
> >> Overcommit has finer accounting, we just account for virtual address space usage.
> >> 3. Vserver will directly be able to port over on top of memrlimit (their address
> >> space limitation feature)
> > 
> > Balbir,
> > 
> > This all seems like a little bit too much hand waving to me.  I don't
> 
> Dave, there is no hand waving, just an honest discussion. Although, you may not
> see it in the background, we still need overcommit protection and we have it
> enabled by default for the system. There are applications that can deal with the
> constraints setup by the administrator and constraints of the environment,
> please see http://en.wikipedia.org/wiki/Autonomic_computing.

OK, let's get back to describing the basic problem here.  What is the
basic problem being solved?  Applications basically want to get a
failure back from malloc() when the machine is (nearly?) out of memory
so they can stop consuming?

Is this the only way to do autonomic computing with memory?  Or, are
there other or better approaches?

Surely an autonomic computing app could keep track of its own memory
footprint.  

> > really see a single concrete user in the "potential applications" here.
> > I really don't understand why you're pushing this so hard if you don't
> > have anyone to actually use it.
> > 
> > I just don't see anyone that *needs* it.  There's a lot of "it would be
> > nice", but no "needs".
> 
> If you see the original email, I've sent - I've mentioned that we need
> overcommit support (either via memrlimit or by porting over the overcommit
> feature) and the exploiters you are looking for is the same as the ones who need
> overcommit and RLIMIT_AS support.
> 
> On the memory overcommit front, please see PostgreSQL Server Administrator's
> Guide at
> http://www.network-theory.co.uk/docs/postgresql/vol3/LinuxMemoryOvercommit.html
> 
> The guide discusses turning off memory overcommit so that the database is never
> OOM killed, how do we provide these guarantees for a particular control group?
> We can do it system wide, but ideally we want the control point to be per
> control group.

Heh.  That suggestion is, at best, working around a kernel bug.  The DB
guys are just saying to do that because they're the biggest memory users
and always seem to get OOM killed first.

The base problem here is the OOM killer, not an application that truly
uses memory overcommit restriction in an interesting way.

> As far as other users are concerned, I've listed users of the memory limit
> feature, in the original email I sent out. To try and understand your viewpoint
> better, could you please tell me if
> 
> 1. You are opposed to overcommit and RLIMIT_AS as features
> 
> OR
> 
> 2. Expanding them to control groups

I think that too many of the users of (1) probably fall into the
PostgreSQL category.  They found that turning it on "fixed" their bugs,
but it really just swept them under the rug.

So, before we expand the use of those features to control groups by
adding a bunch of new code, let's make sure that there will be users for
it and that those users have no better way of doing it.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
