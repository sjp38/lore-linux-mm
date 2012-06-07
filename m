Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 888DB6B006E
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 17:00:45 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [ 08/82] mm: pmd_read_atomic: fix 32bit PAE pmd walk vs pmd_populate SMP race condition
Date: Thu,  7 Jun 2012 23:00:32 +0200
Message-Id: <1339102833-12358-1-git-send-email-aarcange@redhat.com>
In-Reply-To: <20120607190414.GF21339@redhat.com>
References: <20120607190414.GF21339@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>
Cc: 676360@bugs.debian.org, xen-devel@lists.xensource.com, Jonathan Nieder <jrnieder@gmail.com>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org Konrad Rzeszutek Wilk" <konrad.wilk@oracle.com>, stable@vger.kernel.org, alan@lxorguk.ukuu.org.uk, Ulrich Obergfell <uobergfe@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Larry Woodman <lwoodman@redhat.com>, Petr Matousek <pmatouse@redhat.com>, Rik van Riel <riel@redhat.com>, Jan Beulich <jbeulich@suse.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>

Hi,

this should avoid the cmpxchg8b (to make Xen happy) but without
reintroducing the race condition. It's actually going to be faster
too, but it's conceptually more complicated as the pmd high/low may be
inconsistent at times, but at those times we're going to declare the
pmd unstable and ignore it anyway so it's ok.

NOTE: in theory I could also drop the high part when THP=y thanks to
the barrier() in the caller (and the barrier is needed for the generic
version anyway):

static inline pmd_t pmd_read_atomic(pmd_t *pmdp)
{
	pmdval_t ret;
	u32 *tmp = (u32 *)pmdp;

	ret = (pmdval_t) (*tmp);
+#ifndef CONFIG_TRANSPARENT_HUGEPAGE
	if (ret) {
		/*
		 * If the low part is null, we must not read the high part
		 * or we can end up with a partial pmd.
		 */
		smp_rmb();
		ret |= ((pmdval_t)*(tmp + 1)) << 32;
	}
+#endif

	return (pmd_t) { ret };
}

But it's not worth the extra complexity. It looks cleaner if we deal
with "good" pmds if they're later found pointing to a pte (even if we
discard them and force pte_offset to re-read the *pmd).

Andrea Arcangeli (1):
  thp: avoid atomic64_read in pmd_read_atomic for 32bit PAE

 arch/x86/include/asm/pgtable-3level.h |   30 +++++++++++++++++-------------
 include/asm-generic/pgtable.h         |   10 ++++++++++
 2 files changed, 27 insertions(+), 13 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
