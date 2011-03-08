Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A8D2D8D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 05:27:21 -0500 (EST)
From: "Guan Xuetao" <gxt@mprc.pku.edu.cn>
References: <20110302175004.222724818@chello.nl>	 <20110302175200.883953013@chello.nl>	 <03ca01cbda63$31930fd0$94b92f70$@mprc.pku.edu.cn> <1299241020.2428.13504.camel@twins>
In-Reply-To: <1299241020.2428.13504.camel@twins>
Subject: RE: [PATCH 09/13] unicore: mmu_gather rework
Date: Tue, 8 Mar 2011 18:25:57 +0800
Message-ID: <010601cbdd7b$3e388b00$baa9a100$@mprc.pku.edu.cn>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Peter Zijlstra' <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, 'Benjamin Herrenschmidt' <benh@kernel.crashing.org>, 'David Miller' <davem@davemloft.net>, 'Hugh Dickins' <hugh.dickins@tiscali.co.uk>, 'Mel Gorman' <mel@csn.ul.ie>, 'Nick Piggin' <npiggin@kernel.dk>, 'Paul McKenney' <paulmck@linux.vnet.ibm.com>, 'Yanmin Zhang' <yanmin_zhang@linux.intel.com>, 'Andrea Arcangeli' <aarcange@redhat.com>, 'Avi Kivity' <avi@redhat.com>, 'Thomas Gleixner' <tglx@linutronix.de>, 'Rik van Riel' <riel@redhat.com>, 'Ingo Molnar' <mingo@elte.hu>, akpm@linux-foundation.org, 'Linus Torvalds' <torvalds@linux-foundation.org>, 'Arnd Bergmann' <arnd@arndb.de>



> -----Original Message-----
> From: Peter Zijlstra [mailto:a.p.zijlstra@chello.nl]
> Sent: Friday, March 04, 2011 8:17 PM
> To: Guan Xuetao
> Cc: linux-kernel@vger.kernel.org; linux-arch@vger.kernel.org; =
linux-mm@kvack.org; 'Benjamin Herrenschmidt'; 'David Miller'; 'Hugh
> Dickins'; 'Mel Gorman'; 'Nick Piggin'; 'Paul McKenney'; 'Yanmin =
Zhang'; 'Andrea Arcangeli'; 'Avi Kivity'; 'Thomas Gleixner'; 'Rik van =
Riel';
> 'Ingo Molnar'; akpm@linux-foundation.org; 'Linus Torvalds'; Arnd =
Bergmann
> Subject: RE: [PATCH 09/13] unicore: mmu_gather rework
>=20
> On Fri, 2011-03-04 at 19:56 +0800, Guan Xuetao wrote:
>=20
> > Thanks Peter.
> > It looks good to me, though it is dependent on your patch set "mm: =
Preemptible mmu_gather"
>=20
> It is indeed, the split-out per arch is purely to ease review. The =
final
> commit should be a merge of the first 10 patches so as not to break
> bisection.
>=20
> > While I have another look to include/asm-generic/tlb.h, I found it =
is also suitable for unicore32.
> > And so, I rewrite the tlb.h to use asm-generic version, and then =
your patch set will also work for me.
>=20
> Awesome, I notice you're loosing flush_tlb_range() support for this, =
if
> you're fine with that I'm obviously not going to argue, but if its
> better for your platform to keep doing this we can work on that as =
well
> as I'm trying to add generic support for range tracking into the =
generic
> tlb code.
Yes, I think flush_tlb_range() have no effect in unicore32 architecture.
Or perhaps, it is because no optimization, just as you point it below.

>=20
> More importantly, you seem to loose your call to flush_cache_range()
> which isn't a NOP on your platform.
IMO, flush_cache_range() is only used in self-modified codes when =
cachetype is vipt.
So, it could be neglected here.
Perhaps it's wrong.
=20
>=20
> Furthermore, while arch/unicore32/mm/tlb-ucv2.S is mostly magic to me, =
I
> see unicore32 is one of the few architectures that actually uses
> vm_flags in flush_tlb_range(). Do you have independent I/D-TLB flushes
> or are you flushing I-cache on VM_EXEC?
We have both independent and global I/D TLB flushes.
And flushing I-cache on VM_EXEC is also needed in self-modified codes, =
IMO.

>=20
> Also, I notice your flush_tlb_range() implementation looks to be a =
loop
> invalidating individual pages, which I can imagine is cheaper for =
small
> ranges but large ranges might be better of with a full invalidate. Did
> you think about this?
>=20
Yes, it should be optimized.
However, I doubt its effect in unicore32 which has no asid support.

Thanks & Regards.

Guan Xuetao

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
