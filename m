Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EEC915F0019
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 12:44:54 -0400 (EDT)
Date: Wed, 3 Jun 2009 09:44:30 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Security fix for remapping of page 0 (was [PATCH] Change
 ZERO_SIZE_PTR to point at unmapped space)
In-Reply-To: <7e0fb38c0906030932o28d5c963y8059672e5c2c7ecf@mail.gmail.com>
Message-ID: <alpine.LFD.2.01.0906030936350.4880@localhost.localdomain>
References: <20090530192829.GK6535@oblivion.subreption.com>  <20090531022158.GA9033@oblivion.subreption.com>  <alpine.DEB.1.10.0906021130410.23962@gentwo.org>  <20090602203405.GC6701@oblivion.subreption.com>  <alpine.DEB.1.10.0906031047390.15621@gentwo.org>
  <alpine.LFD.2.01.0906030800490.4880@localhost.localdomain>  <alpine.DEB.1.10.0906031121030.15621@gentwo.org>  <alpine.LFD.2.01.0906030827580.4880@localhost.localdomain>  <7e0fb38c0906030922u3af8c2abi8a2cfdcd66151a5a@mail.gmail.com>
 <alpine.LFD.2.01.0906030925480.4880@localhost.localdomain> <7e0fb38c0906030932o28d5c963y8059672e5c2c7ecf@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Eric Paris <eparis@parisplace.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, "Larry H." <research@subreption.com>, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, pageexec@freemail.hu
List-ID: <linux-mm.kvack.org>



On Wed, 3 Jun 2009, Eric Paris wrote:
> >
> > We probably should, since the "capability" security version should
> > generally essentially emulate the regular non-SECURITY case for root.
> 
> Will poke/patch this afternoon.

Btw, a perhaps more interesting case would be to _really_ make the 
"!SECURITY" case just be essentially a hardcoding of the capability case.

Right now the Kconfig option is actually actively misleading, because it 
says that "if you don't enable SECURITY, the default security model will 
be used". 

And that's not automatically true, as shown by this example. You can 
easily get out of sync between security/capability.c and the hardcoded 
non-security rules in include/linux/security.h.

Wouldn't it be kind of nice if the "security/capability.c" file would work 
something like 

 - make the meat of it just a header file ("<linux/cap_security.h>")

 - if !SECURITY, the functions become inline functions named 
   "security_xyz()", and the header file gets included from 
   <linux/security.h>

 - if SECURITY, the functions become static functions named "cap_xyz()", 
   and get included from security/capability.c.

IOW, we'd _guarantee_ that the !SECURITY case is exactly the same as the 
SECURITY+default capabilities case, because we'd be sharing the source 
code.

Hmm? Wouldn't that be a nice way to always avoid the potential "oops, 
!SECURITY has different semantics than intended".

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
