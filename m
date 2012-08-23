Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id E4CA16B0044
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 18:14:25 -0400 (EDT)
Message-ID: <1345759998.29170.20.camel@pasglop>
Subject: Re: [PATCH 33/36] autonuma: powerpc port
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 24 Aug 2012 08:13:18 +1000
In-Reply-To: <1345698660.13399.23.camel@pasglop>
References: <1345647560-30387-1-git-send-email-aarcange@redhat.com>
	 <1345647560-30387-34-git-send-email-aarcange@redhat.com>
	 <1345672907.2617.44.camel@pasglop> <20120822223542.GG8107@redhat.com>
	 <1345698660.13399.23.camel@pasglop>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Tony Breeds <tbreeds@au1.ibm.com>, Kumar Gala <galak@kernel.crashing.org>

On Thu, 2012-08-23 at 15:11 +1000, Benjamin Herrenschmidt wrote:

> So we don't do protnone, and now that you mention it, I think that
> means
> that some of our embedded stuff is busted :-)
> 
> Basically PROT_NONE turns into _PAGE_PRESENT without _PAGE_USER for
> us.

 .../...

> Looks like the SW TLB handlers used on embedded should also check
> whether the address is a user or kernel address, and enforce
> _PAGE_USER
> in the former case. They might have done in the past, it's possible
> that
> it's code we lost, but as it is, it's broken.
> 
> The case of HW loaded TLB embedded will need a different definition of
> PAGE_NONE as well I suspect. Kumar, can you have a look ?

Ok, replying to myself... I wrote some of that stuff so I was all ready
to put the brown paper bag on etc... but in fact:

 - On Book3e.h, we have all 6 protection bits in the PTE (user R,W,X and
supervisor R,W,X). _PAGE_BASE has none of them and _PAGE_USER brings
both UR and SR. Since _PAGE_USER is not set for PROT_NONE we should be
fine. That's the one I wrote so here goes the brown paper bag :-)

 - 44x/47x is in trouble. _PAGE_USER is just a bit in the PTE that the
TLB load handler uses to copy the S bits into the U bits. So we need to
modify the code to also refuse to load a TLB entry with an EA below
PAGE_OFFSET if _PAGE_USER isn't set. I'll give a try at a patch today if
I get a chance, else it will have to wait til after I'm back from
Plumbers.

 - 8xx is probably in trouble, I don't know, I never touch that code, so
somebody from FSL should have a look if they care.

 - FSL BookE looks wrong after a quick look, I'll also let FSL take care
of it.

Cheers,
Ben.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
