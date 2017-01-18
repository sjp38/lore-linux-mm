Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B89036B0033
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 02:48:49 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id f144so7887255pfa.3
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 23:48:49 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id p11si27555387pgc.326.2017.01.17.23.48.48
        for <linux-mm@kvack.org>;
        Tue, 17 Jan 2017 23:48:48 -0800 (PST)
Date: Wed, 18 Jan 2017 16:54:48 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCHSET v2] slab: make memcg slab destruction scalable
Message-ID: <20170118075448.GA1255@js1304-P5Q-DELUXE>
References: <20170114184834.8658-1-tj@kernel.org>
 <20170117001256.GB25218@js1304-P5Q-DELUXE>
 <20170117164913.GB28948@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170117164913.GB28948@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: vdavydov.dev@gmail.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com

On Tue, Jan 17, 2017 at 08:49:13AM -0800, Tejun Heo wrote:
> Hello,
> 
> On Tue, Jan 17, 2017 at 09:12:57AM +0900, Joonsoo Kim wrote:
> > Could you confirm that your series solves the problem that is reported
> > by Doug? It would be great if the result is mentioned to the patch
> > description.
> > 
> > https://bugzilla.kernel.org/show_bug.cgi?id=172991
> 
> So, that's an issue in the creation path which is already resolved by
> switching to an ordered workqueue (it'd probably be better to use
> per-cpu wq w/ @max_active == 1 tho).  This patchset is about relesae
> path.  slab_mutex contention would definitely go down with this but
> I don't think there's more connection to it than that.

That problem is caused by slow release path and then contention on the
slab_mutex. With an ordered workqueue, kworker would not be created a
lot but it can be possible that a lot of work items to create a new
cache for memcg is pending for a long time due to slow release path.

Your patchset replaces optimization for release path so it's better to
check that the work isn't pending for a long time in above workload.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
