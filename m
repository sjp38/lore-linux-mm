Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1B42B8D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 20:32:18 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 1D9DD3EE0AE
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 09:32:15 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 04BD845DE95
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 09:32:15 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D0E0145DE93
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 09:32:14 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C2363E08003
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 09:32:14 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B94F1DB8038
	for <linux-mm@kvack.org>; Tue, 26 Apr 2011 09:32:14 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] convert parisc to sparsemem (was Re: [PATCH v3] mm: make expand_downwards symmetrical to expand_upwards)
In-Reply-To: <1303583657.4116.11.camel@mulgrave.site>
References: <1303507985.2590.47.camel@mulgrave.site> <1303583657.4116.11.camel@mulgrave.site>
Message-Id: <20110426093328.F33D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue, 26 Apr 2011 09:32:13 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Dave Hansen <dave@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>, Tejun Heo <tj@kernel.org>, Mel Gorman <mel@csn.ul.ie>

Hi James,

 % make CROSS_COMPILE=hppa64-linux- ARCH=parisc
  CHK     include/linux/version.h
  CHK     include/generated/utsrelease.h
  CC      arch/parisc/kernel/asm-offsets.s
In file included from include/linux/topology.h:32:0,
                 from include/linux/sched.h:78,
                 from arch/parisc/kernel/asm-offsets.c:31:
include/linux/mmzone.h:916:27: fatal error: asm/sparsemem.h: No such file or directory

Parhaps, you forgot to quilt add?


> This is the preliminary conversion.  It's very nasty on parisc because
> the memory allocation isn't symmetric anymore: under DISCONTIGMEM, we
> push all memory into bootmem and then let free_all_bootmem() do the
> magic for us; now we have to do separate initialisations for ranges
> because SPARSEMEM can't do multi-range boot memory. It's also got the
> horrible hack that I only use the first found range for bootmem.  I'm
> not sure if this is correct (it won't be if the first found range can be
> under about 50MB because we'll run out of bootmem during boot) ... we
> might have to sort the ranges and use the larges, but that will involve
> us in even more hackery around the bootmem reservations code.
> 
> The boot sequence got a few seconds slower because now all of the loops
> over our pfn ranges actually have to skip through the holes (which takes
> time for 64GB).
> 
> All in all, I've not been very impressed with SPARSEMEM over
> DISCONTIGMEM.  It seems to have a lot of rough edges (necessitating
> exception code) which DISCONTIGMEM just copes with.
> 
> And before you say the code is smaller, that's because I converted us to
> generic show_mem().

Cool! I hoped to remove arch specific show_mem() long time.


And, nitpick comment.

Could you please use #ifdef CONFIG_FLAGMEM instead #ifndef CONFIG_SPARSEMEM?
MM gyes parse '#ifndef CONFIG_SPARSEMEM' as valid-both-flatmem-and-discontigmem.
but this code isn't.

If my quick grep is correct, all of your #ifndef SPARSEMEM can be converted
#ifdef FALTMEM.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
