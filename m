Date: Thu, 9 Mar 2006 11:42:59 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC] Migrate-on-fault prototype 0/5 V0.1 - Overview
In-Reply-To: <1141932602.6393.68.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0603091135200.17789@schroedinger.engr.sgi.com>
References: <1141928905.6393.10.camel@localhost.localdomain>
 <Pine.LNX.4.64.0603091104280.17622@schroedinger.engr.sgi.com>
 <1141932602.6393.68.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 9 Mar 2006, Lee Schermerhorn wrote:

> I'm wondering if applications keep changing the policy as you describe
> to "finesse" the system--e.g., because they don't have fine enough
> control over the policies.  Perhaps I read it wrong, but it appears to
> me that we can't set the policy for subranges of a vm area.  So maybe

We can set the policies for subranges. See mempolicy.c

> applications have to set the policy for the [entire] vma, touch a few
> pages to get them placed, change the policy for the [entire] vma, touch
> a few more pages, ...   Of course, storing policies on subranges of vmas
> takes more mechanism that we current have, and increases the cost of
> node computation on each allocation.  Probably why we don't have it
> currently.

We have it currently for anonymous pages. Its just not implemented yet for 
file backed pages.

> Anyway, with the patches I sent, pages would only migrate on fault if
> they had no mappings at the time of fault.  If an application had
> explicitly placed them by touching them, they could only have zero map
> count if something happened to pull them out of the task's pte.  I would
> think that if they cared, they'd mlock them so that wouldn't happen?

Currently page migration may remove ptes for file mapped pages relying on
the fault handler to restore ptes. Hopefully we will restore all ptes in 
the future but as long as that the current situation persist you may 
potentially move pages belonging (well, in some loose fashion since there 
is no pte) to another process.

> Yes, that could happen.  That's what I was trying to explain.  I don't
> LIKE that, but I haven't thought about how to distinguish a page that
> just go read in and is likely on the right node [an acceptable one,
> anyway] and one that has zero mappings because it hasn't been referenced
> in a while.  Any ideas?

Implement the vma policies for file mapped pages and you can just rely on 
that mechanism to correctly place your pages without any need for 
checking. Plus we will have fixed a major open issue for memory policies. 

> I just sent another one to myself, and got it just fine.  I copied you
> in addition to the list.  Was that copy borked, too?  If so, I'll try
> sending you copies with good ol' mail(1).

Have not seen it yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
