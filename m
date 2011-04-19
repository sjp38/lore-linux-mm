Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 798108D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 17:21:47 -0400 (EDT)
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <alpine.DEB.2.00.1104191530040.23077@router.home>
References: <20110415135144.GE8828@tiehlicka.suse.cz>
	 <alpine.LSU.2.00.1104171952040.22679@sister.anvils>
	 <20110418100131.GD8925@tiehlicka.suse.cz>
	 <20110418135637.5baac204.akpm@linux-foundation.org>
	 <20110419111004.GE21689@tiehlicka.suse.cz>
	 <1303228009.3171.18.camel@mulgrave.site>
	 <BANLkTimYrD_Sby_u-fPSwn-RJJyEVavU5w@mail.gmail.com>
	 <1303233088.3171.26.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104191213120.17888@router.home>
	 <1303235306.3171.33.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104191254300.19358@router.home>
	 <1303237217.3171.39.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104191325470.19358@router.home>
	 <1303242580.11237.10.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104191530040.23077@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 19 Apr 2011 16:21:43 -0500
Message-ID: <1303248103.11237.16.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, David Rientjes <rientjes@google.com>

On Tue, 2011-04-19 at 15:56 -0500, Christoph Lameter wrote:
> On Tue, 19 Apr 2011, James Bottomley wrote:
> 
> > > > I told you ... I forced an allocation into the first discontiguous
> > > > region.  That will return 1 for page_to_nid().
> > >
> > > How? The kernel has no concept of a node 1 without CONFIG_NUMA and so you
> > > cannot tell the page allocator to allocate from node 1.
> >
> > Yes, it does, as I explained in the email.
> 
> Looked through it and canot find it. How would that be possible to do
> with core kernel calls since the page allocator calls do not allow you to
> specify a node under !NUMA.

it's used under DISCONTIGMEM to identify the pfn array.

> > Don't be silly: alpha, ia64, m32r, m68k, mips, parisc, tile and even x86
> > all use the discontigmem memory model in some configurations.
> 
> I guess DISCONTIGMEM is typically used together with NUMA. Otherwise we
> would have run into this before.

Which bit of my telling you that six architectures already use it this
way did you not get?  I'm not really interested in reconciling your
theories with how we currently operate.  If you want to require NUMA
with DISCONTIGMEM, fine, we'll just define SLUB as broken if that's not
true ... that will fix my boot panic reports.

James

---

diff --git a/init/Kconfig b/init/Kconfig
index 56240e7..a7ad8fb 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -1226,6 +1226,7 @@ config SLAB
 	  per cpu and per node queues.
 
 config SLUB
+	depends on BROKEN || NUMA || !DISCONTIGMEM
 	bool "SLUB (Unqueued Allocator)"
 	help
 	   SLUB is a slab allocator that minimizes cache line usage


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
