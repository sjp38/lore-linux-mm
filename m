Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 586CB6B0031
	for <linux-mm@kvack.org>; Sat, 10 Aug 2013 13:48:27 -0400 (EDT)
Message-ID: <1376156903.2156.30.camel@dabdike.int.hansenpartnership.com>
Subject: Re: [patch 1/2] [PATCH] mm: Save soft-dirty bits on swapped pages
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Sat, 10 Aug 2013 10:48:23 -0700
In-Reply-To: <20130807132156.e97bbcc3d543cf88d5a0997d@linux-foundation.org>
References: <20130730204154.407090410@gmail.com>
	 <20130730204654.844299768@gmail.com>
	 <20130807132156.e97bbcc3d543cf88d5a0997d@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-15"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, luto@amacapital.net, gorcunov@openvz.org, xemul@parallels.com, mpm@selenic.com, xiaoguangrong@linux.vnet.ibm.com, mtosatti@redhat.com, kosaki.motohiro@gmail.com, sfr@canb.auug.org.au, peterz@infradead.org, aneesh.kumar@linux.vnet.ibm.com

On Wed, 2013-08-07 at 13:21 -0700, Andrew Morton wrote:
> On Wed, 31 Jul 2013 00:41:55 +0400 Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> 
> > Andy Lutomirski reported that in case if a page with _PAGE_SOFT_DIRTY
> > bit set get swapped out, the bit is getting lost and no longer
> > available when pte read back.
> > 
> > To resolve this we introduce _PTE_SWP_SOFT_DIRTY bit which is
> > saved in pte entry for the page being swapped out. When such page
> > is to be read back from a swap cache we check for bit presence
> > and if it's there we clear it and restore the former _PAGE_SOFT_DIRTY
> > bit back.
> > 
> > One of the problem was to find a place in pte entry where we can
> > save the _PTE_SWP_SOFT_DIRTY bit while page is in swap. The
> > _PAGE_PSE was chosen for that, it doesn't intersect with swap
> > entry format stored in pte.
> 
> So the implication is that if another architecture wants to support
> this (and, realistically, wants to support CRIU),

To be clear, CRIU is usable for basic checkpoint/restore without soft
dirty.  It's using CRIU as an engine for process migration between nodes
that won't work efficiently without soft dirty.  What happens without
soft dirty is that we have to freeze the source process state, transfer
the bits and then begin execution on the target ... that means the
process can be suspended for minutes (and means that customers notice
and your SLAs get blown).  Using soft dirty, we can iteratively build up
the process image on the target while the source process is still
executing meaning the actual transfer between source and target takes
only seconds (when the delta is small enough, we freeze the source,
transfer the remaining changed bits and begin on the target).

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
