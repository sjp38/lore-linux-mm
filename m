Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 57D316B0261
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 22:06:51 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id n128so5185273ith.1
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 19:06:51 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id a136si1440962ita.55.2016.08.22.19.06.48
        for <linux-mm@kvack.org>;
        Mon, 22 Aug 2016 19:06:49 -0700 (PDT)
Date: Tue, 23 Aug 2016 11:13:03 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3] mm/slab: Improve performance of gathering slabinfo
 stats
Message-ID: <20160823021303.GB17039@js1304-P5Q-DELUXE>
References: <1471458050-29622-1-git-send-email-aruna.ramakrishna@oracle.com>
 <20160818115218.GJ30162@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160818115218.GJ30162@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Aruna Ramakrishna <aruna.ramakrishna@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Aug 18, 2016 at 01:52:19PM +0200, Michal Hocko wrote:
> On Wed 17-08-16 11:20:50, Aruna Ramakrishna wrote:
> > On large systems, when some slab caches grow to millions of objects (and
> > many gigabytes), running 'cat /proc/slabinfo' can take up to 1-2 seconds.
> > During this time, interrupts are disabled while walking the slab lists
> > (slabs_full, slabs_partial, and slabs_free) for each node, and this
> > sometimes causes timeouts in other drivers (for instance, Infiniband).
> > 
> > This patch optimizes 'cat /proc/slabinfo' by maintaining a counter for
> > total number of allocated slabs per node, per cache. This counter is
> > updated when a slab is created or destroyed. This enables us to skip
> > traversing the slabs_full list while gathering slabinfo statistics, and
> > since slabs_full tends to be the biggest list when the cache is large, it
> > results in a dramatic performance improvement. Getting slabinfo statistics
> > now only requires walking the slabs_free and slabs_partial lists, and
> > those lists are usually much smaller than slabs_full. We tested this after
> > growing the dentry cache to 70GB, and the performance improved from 2s to
> > 5ms.
> 
> I am not opposing the patch (to be honest it is quite neat) but this
> is buggering me for quite some time. Sorry for hijacking this email
> thread but I couldn't resist. Why are we trying to optimize SLAB and
> slowly converge it to SLUB feature-wise. I always thought that SLAB
> should remain stable and time challenged solution which works reasonably
> well for many/most workloads, while SLUB is an optimized implementation
> which experiment with slightly different concepts that might boost the
> performance considerably but might also surprise from time to time. If
> this is not the case then why do we have both of them in the kernel. It
> is a lot of code and some features need tweaking both while only one
> gets testing coverage. So this is mainly a question for maintainers. Why
> do we maintain both and what is the purpose of them.

I don't know full history about it since I joined kernel communitiy
recently(?). Christoph would be a better candidate for this topic.
Anyway,

AFAIK, first plan at the time when SLUB is introduced was to remove
SLAB if SLUB beats SLAB completely. But, there are fundamental
differences in implementation detail so they cannot beat each other
for all the workloads. It is similar with filesystem case that various
filesystems exist for it's own workload.

Then, second plan was started. It is commonizing the code as much
as possible to develope new feature and maintain the code easily. The
code goes this direction, although it is slow. If it is achieved, we
don't need to worry about maintanance overhead.

Anyway, we cannot remove one without regression so we don't remove one
until now. In this case, there is no point to stop improving one.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
