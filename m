Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id F1ABC6B0114
	for <linux-mm@kvack.org>; Wed, 13 May 2009 11:22:39 -0400 (EDT)
Date: Wed, 13 May 2009 10:22:57 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [PATCH 4/4] zone_reclaim_mode is always 0 by default
Message-ID: <20090513152256.GM7601@sgi.com>
References: <20090513120155.5879.A69D9226@jp.fujitsu.com> <20090513120729.5885.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090513120729.5885.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 13, 2009 at 12:08:12PM +0900, KOSAKI Motohiro wrote:
> Subject: [PATCH] zone_reclaim_mode is always 0 by default
> 
> Current linux policy is, if the machine has large remote node distance,
>  zone_reclaim_mode is enabled by default because we've be able to assume to 
> large distance mean large server until recently.
> 
> Unfrotunately, recent modern x86 CPU (e.g. Core i7, Opeteron) have P2P transport
> memory controller. IOW it's NUMA from software view.
> 
> Some Core i7 machine has large remote node distance and zone_reclaim don't
> fit desktop and small file server. it cause performance degression.
> 
> Thus, zone_reclaim == 0 is better by default. sorry, HPC gusy. 
> you need to turn zone_reclaim_mode on manually now.

I am _VERY_ concerned about this change in behavior as it has been the
default for a considerable period of time.  I realize it is an easily
changed setting, but it is churn in the default behavior.  Are there
any benefits for these small servers to have zone_reclaim turned on?
If you have a large node distance, I would expect they should benefit
_MORE_ than those with small or no node distances.

Are you seeing an impact of the load not distributing pages evenly across
processors instead of a reclaim effect (ie, a single threaded process
faulting in more memory than is node local and expecting those pages
to come from the other node first before doing reclaim)?  Maybe there
is a different issue than the ones I am used to thinking about and I am
completely missing the point, please enlighten me.

If this proceeds forward, I would like to propose we at least leave
it on for SGI SN and UV hardware.  I can provide a quick patch that
may be a bit ugly because it will depend upon arch specific #defines.
I have not investigated this, but any alternative suggestions are
certainly welcome.  Currently, I am envisioning bringing something like
ia64_platform_is("sn2") and is_uv_system into page_alloc.c.

> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Cc: Rik van Riel <riel@redhat.com>

Please add me:

Cc: Robin Holt <holt@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
