Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0AD298D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 12:06:46 -0400 (EDT)
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <alpine.DEB.2.00.1104201437180.31768@chino.kir.corp.google.com>
References: <20110420102314.4604.A69D9226@jp.fujitsu.com>
	 <BANLkTi=mxWwLPEnB+rGg29b06xNUD0XvsA@mail.gmail.com>
	 <20110420161615.462D.A69D9226@jp.fujitsu.com>
	 <BANLkTimfpY3gq8oY6bPDajBW7JN6Hp+A0A@mail.gmail.com>
	 <20110420112020.GA31296@parisc-linux.org>
	 <BANLkTim+m-v-4k17HUSOYSbmNFDtJTgD6g@mail.gmail.com>
	 <1303308938.2587.8.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104200943580.9266@router.home>
	 <1303311779.2587.19.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104201018360.9266@router.home>
	 <alpine.DEB.2.00.1104201437180.31768@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 21 Apr 2011 11:06:36 -0500
Message-ID: <1303401997.4025.8.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Matthew Wilcox <matthew@wil.cx>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>, linux-arch@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>

On Wed, 2011-04-20 at 14:42 -0700, David Rientjes wrote:
> On Wed, 20 Apr 2011, Christoph Lameter wrote:
> 
> > There is barely any testing going on at all of this since we have had this
> > issue for more than 5 years and have not noticed it. The absence of bug
> > reports therefore proves nothing. Code inspection of the VM shows
> > that this is an issue that arises in multiple subsystems and that we have
> > VM_BUG_ONs in the page allocator that should trigger for these situations.
> > 
> > Usage of DISCONTIGMEM and !NUMA is not safe and should be flagged as such.
> > 
> 
> We don't actually have any bug reports in front of us that show anything 
> else in the VM other than slub has issues with this configuration, so 
> marking them as broken is probably premature.  The parisc config that 
> triggered this debugging enables CONFIG_SLAB by default, so it probably 
> has gone unnoticed just because nobody other than James has actually tried 
> it on hppa64.
> 
> Let's see if KOSAKI-san's fixes to Kconfig (even though I'd prefer the 
> simpler and implicit "config NUMA def_bool ARCH_DISCONTIGMEM_ENABLE" over 
> his config NUMA) and my fix to parisc to set the bit in N_NORMAL_MEMORY 
> so that CONFIG_SLUB initializes kmem_cache_node correctly works and then 
> address issues in the core VM as they arise.  Presumably someone has been 
> running DISCONTIGMEM on hppa64 in the past five years without issues with 
> defconfig, so the issue here may just be slub.

Actually, we can fix slub.  As far as all my memory hammer tests go, the
one liner below is the actual fix (it just forces slub get_node() to
return the zero node always on !NUMA).  That, as far as a code
inspection goes, seems to make SLUB as good as SLAB ... as long as
no-one uses hugepages or VM DEBUG, which, I think we've demonstrated, is
the case for all the current DISCONTIGMEM users.

I think either the above or just marking slub broken in DISCONTIGMEM & !
NUMA is sufficient for stable.  The fix is getting urgent, because
debian (which is what most of our users are running) has made SLUB the
default allocator, which is why we're now starting to run into these
panic reports.

The set memory range fix looks good for a backport too ... at least the
page cache is now no-longer reluctant to use my upper 1GB ...

I worry a bit more about backporting the selection of NUMA as a -stable
fix because it's a larger change (and requires changes to all the
architectures, since NUMA is an arch local Kconfig variable)

James

----

diff --git a/mm/slub.c b/mm/slub.c
index 94d2a33..243bd9c 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -235,7 +235,11 @@ int slab_is_available(void)
 
 static inline struct kmem_cache_node *get_node(struct kmem_cache *s, int node)
 {
+#ifdef CONFIG_NUMA
 	return s->node[node];
+#else
+	return s->node[0];
+#endif
 }
 
 /* Verify that a pointer has an address that is valid within a slab page */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
