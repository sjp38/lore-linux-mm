Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0E9158D003B
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 17:42:34 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p3KLgUUo021932
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 14:42:30 -0700
Received: from pxi11 (pxi11.prod.google.com [10.243.27.11])
	by wpaz33.hot.corp.google.com with ESMTP id p3KLgSIU017101
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 20 Apr 2011 14:42:29 -0700
Received: by pxi11 with SMTP id 11so827374pxi.7
        for <linux-mm@kvack.org>; Wed, 20 Apr 2011 14:42:28 -0700 (PDT)
Date: Wed, 20 Apr 2011 14:42:26 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
In-Reply-To: <alpine.DEB.2.00.1104201018360.9266@router.home>
Message-ID: <alpine.DEB.2.00.1104201437180.31768@chino.kir.corp.google.com>
References: <20110420102314.4604.A69D9226@jp.fujitsu.com>  <BANLkTi=mxWwLPEnB+rGg29b06xNUD0XvsA@mail.gmail.com>  <20110420161615.462D.A69D9226@jp.fujitsu.com>  <BANLkTimfpY3gq8oY6bPDajBW7JN6Hp+A0A@mail.gmail.com>  <20110420112020.GA31296@parisc-linux.org>
 <BANLkTim+m-v-4k17HUSOYSbmNFDtJTgD6g@mail.gmail.com>  <1303308938.2587.8.camel@mulgrave.site>  <alpine.DEB.2.00.1104200943580.9266@router.home> <1303311779.2587.19.camel@mulgrave.site> <alpine.DEB.2.00.1104201018360.9266@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, Pekka Enberg <penberg@kernel.org>, Matthew Wilcox <matthew@wil.cx>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>, linux-arch@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>

On Wed, 20 Apr 2011, Christoph Lameter wrote:

> There is barely any testing going on at all of this since we have had this
> issue for more than 5 years and have not noticed it. The absence of bug
> reports therefore proves nothing. Code inspection of the VM shows
> that this is an issue that arises in multiple subsystems and that we have
> VM_BUG_ONs in the page allocator that should trigger for these situations.
> 
> Usage of DISCONTIGMEM and !NUMA is not safe and should be flagged as such.
> 

We don't actually have any bug reports in front of us that show anything 
else in the VM other than slub has issues with this configuration, so 
marking them as broken is probably premature.  The parisc config that 
triggered this debugging enables CONFIG_SLAB by default, so it probably 
has gone unnoticed just because nobody other than James has actually tried 
it on hppa64.

Let's see if KOSAKI-san's fixes to Kconfig (even though I'd prefer the 
simpler and implicit "config NUMA def_bool ARCH_DISCONTIGMEM_ENABLE" over 
his config NUMA) and my fix to parisc to set the bit in N_NORMAL_MEMORY 
so that CONFIG_SLUB initializes kmem_cache_node correctly works and then 
address issues in the core VM as they arise.  Presumably someone has been 
running DISCONTIGMEM on hppa64 in the past five years without issues with 
defconfig, so the issue here may just be slub.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
