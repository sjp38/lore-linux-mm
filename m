Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 93FD66B0106
	for <linux-mm@kvack.org>; Sun, 23 Feb 2014 23:49:10 -0500 (EST)
Received: by mail-pa0-f49.google.com with SMTP id hz1so6005757pad.22
        for <linux-mm@kvack.org>; Sun, 23 Feb 2014 20:49:10 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id sh5si15303829pbc.260.2014.02.23.20.49.08
        for <linux-mm@kvack.org>;
        Sun, 23 Feb 2014 20:49:09 -0800 (PST)
Date: Mon, 24 Feb 2014 13:49:18 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 9/9] slab: remove a useless lockdep annotation
Message-ID: <20140224044918.GA14814@lge.com>
References: <1392361043-22420-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1392361043-22420-10-git-send-email-iamjoonsoo.kim@lge.com>
 <alpine.DEB.2.10.1402141248560.12887@nuc>
 <20140217061201.GA3468@lge.com>
 <alpine.DEB.2.10.1402181019550.28591@nuc>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1402181019550.28591@nuc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Feb 18, 2014 at 10:21:10AM -0600, Christoph Lameter wrote:
> On Mon, 17 Feb 2014, Joonsoo Kim wrote:
> 
> > > Why change the BAD_ALIEN_MAGIC?
> >
> > Hello, Christoph.
> >
> > BAD_ALIEN_MAGIC is only checked by slab_set_lock_classes(). We remove this
> > function in this patch, so returning BAD_ALIEN_MAGIC is useless.
> 
> Its not useless. The point is if there is a pointer deref then we will see
> this as a pointer value and know that it is realted to alien cache
> processing.
> 
> > And, in fact, BAD_ALIEN_MAGIC is already useless, because alloc_alien_cache()
> > can't be called on !CONFIG_NUMA. This function is called if use_alien_caches
> > is positive, but on !CONFIG_NUMA, use_alien_caches is always 0. So we don't
> > have any chance to meet this BAD_ALIEN_MAGIC in runtime.
> 
> Maybe it no longer serves a point. But note that caches may not be
> populated because processors/nodes are not up yet.

Hello,

Let me clarify about alloc_alien_cache().

alloc_alien_cache() has two definitions, one for !CONFIG_NUMA, and the other for
CONFIG_NUMA. BAD_ALIEN_MAGIC is only assigned on !CONFIG_NUMA definition. On
CONFIG_NUMA, alloc_alien_cache() doesn't use BAD_ALIEN_MAGIC. So it is sufficient
to consider just !CONFIG_NUMA case.

As I mentioned before, this function isn't called if use_alien_caches is zero
and use_alien_caches is always zero on !CONFIG_NUMA. Therefore we cannot see
BAD_ALIEN_MAGIC on any configuration. I don't know why BAD_ALIEN_MAGIC is
introduced, however, it no longer serves a point, so it is better to remove it.

There are lots of code to check whether processor/nodes are up or not and these
doesn't use BAD_ALIEN_MAGIC. Instead, it checks NULL on alien_cache of specific node.
So removing BAD_ALIEN_MAGIC doesn't harm anything here.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
