Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2B7956B002C
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 16:39:26 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <3e84809b-a45d-4980-b342-c2d671f87f79@default>
Date: Wed, 12 Oct 2011 13:39:10 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH] staging: zcache: remove zcache_direct_reclaim_lock
References: <1318448460-5930-1-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1318448460-5930-1-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, gregkh@suse.de
Cc: cascardo@holoscopio.com, rdunlap@xenotime.net, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rcj@linux.vnet.ibm.com, brking@linux.vnet.ibm.com

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> Subject: [PATCH] staging: zcache: remove zcache_direct_reclaim_lock
>=20
> zcache_do_preload() currently does a spin_trylock() on the
> zcache_direct_reclaim_lock. Holding this lock intends to prevent
> shrink_zcache_memory() from evicting zbud pages as a result
> of a preload.
>
> However, it also prevents two threads from
> executing zcache_do_preload() at the same time.  The first
> thread will obtain the lock and the second thread's spin_trylock()
> will fail (an aborted preload) causing the page to be either lost
> (cleancache) or pushed out to the swap device (frontswap). It
> also doesn't ensure that the call to shrink_zcache_memory() is
> on the same thread as the call to zcache_do_preload().

Yes, this looks to be leftover code from early in kztmem/zcache
development.  Good analysis.
=20
> Additional, there is no need for this mechanism because all
> zcache_do_preload() calls that come down from cleancache already
> have PF_MEMALLOC set in the process flags which prevents
> direct reclaim in the memory manager. If the zcache_do_preload()

Might it be worthwhile to add a BUG/ASSERT for the presence
of PF_MEMALLOC, or at least a comment in the code?

> call is done from the frontswap path, we _want_ reclaim to be
> done (which it isn't right now).
>=20
> This patch removes the zcache_direct_reclaim_lock and related
> statistics in zcache.
>=20
> Based on v3.1-rc8
>=20
> Signed-off-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
> Reviewed-by: Dave Hansen <dave@linux.vnet.ibm.com>

With added code/comment per above...
Acked-by: Dan Magenheimer <dan.magenheimer@oracle.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
