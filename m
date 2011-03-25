Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 05B388D0040
	for <linux-mm@kvack.org>; Fri, 25 Mar 2011 11:47:20 -0400 (EDT)
Date: Fri, 25 Mar 2011 10:45:24 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [GIT PULL] SLAB changes for v2.6.39-rc1
In-Reply-To: <20110325151353.GG1409@htj.dyndns.org>
Message-ID: <alpine.DEB.2.00.1103251041240.27814@router.home>
References: <AANLkTik3rkNvLG-rgiWxKaPc-v9sZQq96ok0CXfAU+r_@mail.gmail.com> <20110324185903.GA30510@elte.hu> <AANLkTi=66Q-8=AV3Y0K28jZbT3ddCHy9azWedoCC4Nrn@mail.gmail.com> <alpine.DEB.2.00.1103241404490.5576@router.home> <AANLkTimWYCHEsZjswLpD-xDcu_cL=GqsMshKRtkHt5Vn@mail.gmail.com>
 <20110324193647.GA7957@elte.hu> <AANLkTinBwKT3s=1En5Urs56gmt_zCNgPXnQzzy52Tgdo@mail.gmail.com> <alpine.DEB.2.00.1103241451060.5576@router.home> <1300997290.2714.2.camel@edumazet-laptop> <alpine.DEB.2.00.1103241541560.8108@router.home>
 <20110325151353.GG1409@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Pekka Enberg <penberg@kernel.org>, Ingo Molnar <mingo@elte.hu>, torvalds@linux-foundation.org, akpm@linux-foundation.org, npiggin@kernel.dk, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 25 Mar 2011, Tejun Heo wrote:

> I've looked through the code but can't figure out what the difference
> is.  The memset code is in mm/percpu-vm.c::pcpu_populate_chunk().
>
> 	for_each_possible_cpu(cpu)
> 		memset((void *)pcpu_chunk_addr(chunk, cpu, 0) + off, 0, size);
>
> (pcpu_chunk_addr(chunk, cpu, 0) + off) is the same vaddr as will be
> obtained by per_cpu_ptr(ptr, cpu), so all allocated memory regions are
> accessed before being returned.  Dazed and confused (seems like the
> theme of today for me).
>
> Could it be that the vmalloc page is taking more than one faults?

The vmalloc page only contains per cpu data from a single cpu right?

Could anyone have set write access restrictions that would require a fault
to get rid of?

Or does an access from a different cpu require a "page table sync"?

There is some rather strange looking code in arch/x86/mm/fault.c:vmalloc_fault



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
