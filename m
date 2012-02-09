Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 12DAC6B002C
	for <linux-mm@kvack.org>; Thu,  9 Feb 2012 14:54:02 -0500 (EST)
Date: Thu, 9 Feb 2012 13:53:58 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 02/15] mm: sl[au]b: Add knowledge of PFMEMALLOC reserve
 pages
In-Reply-To: <20120209125018.GN5938@suse.de>
Message-ID: <alpine.DEB.2.00.1202091345540.4413@router.home>
References: <1328568978-17553-1-git-send-email-mgorman@suse.de> <1328568978-17553-3-git-send-email-mgorman@suse.de> <alpine.DEB.2.00.1202071025050.30652@router.home> <20120208144506.GI5938@suse.de> <alpine.DEB.2.00.1202080907320.30248@router.home>
 <20120208163421.GL5938@suse.de> <alpine.DEB.2.00.1202081338210.32060@router.home> <20120208212323.GM5938@suse.de> <alpine.DEB.2.00.1202081557540.5970@router.home> <20120209125018.GN5938@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Pekka Enberg <penberg@cs.helsinki.fi>

On Thu, 9 Feb 2012, Mel Gorman wrote:

> Ok, I am working on a solution that does not affect any of the existing
> slab structures. Between that and the fact we check if there are any
> memalloc_socks after patch 12, the impact for normal systems is an additional
> branch in ac_get_obj() and ac_put_obj()

That sounds good in particular since some other things came up again,
sigh. Have not had time to see if an alternate approach works.

> > We have been down this road too many times. Logic is added to critical
> > paths and memory structures grow. This is not free. And for NBD swap
> > support? Pretty exotic use case.
> >
>
> NFS support is the real target. NBD is the logical starting point and
> NFS needs the same support.

But this is already a pretty strange use case on multiple levels. Swap is
really detrimental to performance. Its a kind of emergency outlet that
gets worse with every new step that increases the differential in
performance between disk and memory. On top of that you want to add
special code in various subsystems to also do that over the network.
Sigh. I think we agreed a while back that we want to limit the amount of
I/O triggered from reclaim paths? AFAICT many filesystems do not support
writeout from reclaim anymore because of all the issues that arise at that
level.

We have numerous other mechanisms that can compress swap etc and provide
ways to work around the problem without I/O which has always be
troublesome and these fixes are likely only to work in a very limited
way causing a lot of maintenance effort because (given the exotic
nature) it is highly likely that there are cornercases that only will be
triggered in rare cases.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
