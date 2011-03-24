Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3B29E8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 15:51:43 -0400 (EDT)
Date: Thu, 24 Mar 2011 14:51:38 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [GIT PULL] SLAB changes for v2.6.39-rc1
In-Reply-To: <AANLkTinBwKT3s=1En5Urs56gmt_zCNgPXnQzzy52Tgdo@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1103241451060.5576@router.home>
References: <alpine.DEB.2.00.1103241300420.32226@router.home> <AANLkTi=KZQd-GrXaq4472V3XnEGYqnCheYcgrdPFE0LJ@mail.gmail.com> <alpine.DEB.2.00.1103241312280.32226@router.home> <1300990853.3747.189.camel@edumazet-laptop> <alpine.DEB.2.00.1103241346060.32226@router.home>
 <AANLkTik3rkNvLG-rgiWxKaPc-v9sZQq96ok0CXfAU+r_@mail.gmail.com> <20110324185903.GA30510@elte.hu> <AANLkTi=66Q-8=AV3Y0K28jZbT3ddCHy9azWedoCC4Nrn@mail.gmail.com> <alpine.DEB.2.00.1103241404490.5576@router.home> <AANLkTimWYCHEsZjswLpD-xDcu_cL=GqsMshKRtkHt5Vn@mail.gmail.com>
 <20110324193647.GA7957@elte.hu> <AANLkTinBwKT3s=1En5Urs56gmt_zCNgPXnQzzy52Tgdo@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Ingo Molnar <mingo@elte.hu>, Eric Dumazet <eric.dumazet@gmail.com>, torvalds@linux-foundation.org, akpm@linux-foundation.org, tj@kernel.org, npiggin@kernel.dk, rientjes@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 24 Mar 2011, Pekka Enberg wrote:

> Thanks, Ingo! Christoph, may I have your sign-off for the patch and
> I'll send it to Linus?


Subject: SLUB: Write to per cpu data when allocating it

It turns out that the cmpxchg16b emulation has to access vmalloced
percpu memory with interrupts disabled. If the memory has never
been touched before then the fault necessary to establish the
mapping will not to occur and the kernel will fail on boot.

Fix that by reusing the CONFIG_PREEMPT code that writes the
cpu number into a field on every cpu. Writing to the per cpu
area before causes the mapping to be established before we get
to a cmpxchg16b emulation.

Tested-by: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-03-24 14:03:10.000000000 -0500
+++ linux-2.6/mm/slub.c	2011-03-24 14:04:08.000000000 -0500
@@ -1604,7 +1604,7 @@ static inline void note_cmpxchg_failure(

 void init_kmem_cache_cpus(struct kmem_cache *s)
 {
-#if defined(CONFIG_CMPXCHG_LOCAL) && defined(CONFIG_PREEMPT)
+#ifdef CONFIG_CMPXCHG_LOCAL
 	int cpu;

 	for_each_possible_cpu(cpu)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
