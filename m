Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f169.google.com (mail-vc0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 552216B0074
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 11:56:33 -0400 (EDT)
Received: by mail-vc0-f169.google.com with SMTP id id10so442539vcb.28
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 08:56:33 -0700 (PDT)
Received: from mail-qa0-x22a.google.com (mail-qa0-x22a.google.com. [2607:f8b0:400d:c00::22a])
        by mx.google.com with ESMTPS id 91si21313930qgm.102.2014.10.27.08.56.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Oct 2014 08:56:32 -0700 (PDT)
Received: by mail-qa0-f42.google.com with SMTP id cs9so4055765qab.29
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 08:56:32 -0700 (PDT)
Date: Mon, 27 Oct 2014 11:56:29 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH RESEND 2/4] cpuset: simplify cpuset_node_allowed API
Message-ID: <20141027155629.GS4436@htj.dyndns.org>
References: <cover.1413804554.git.vdavydov@parallels.com>
 <c52e3c30a61d29da40b69b602c41c2d91868c3ae.1413804554.git.vdavydov@parallels.com>
 <20141027151806.GR4436@htj.dyndns.org>
 <20141027153654.GF17258@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141027153654.GF17258@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Dan Carpenter <dan.carpenter@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Zefan Li <lizefan@huawei.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Oct 27, 2014 at 06:36:54PM +0300, Vladimir Davydov wrote:
> Hi Tejun,
> 
> On Mon, Oct 27, 2014 at 11:18:06AM -0400, Tejun Heo wrote:
> > On Mon, Oct 20, 2014 at 03:50:30PM +0400, Vladimir Davydov wrote:
> > > Current cpuset API for checking if a zone/node is allowed to allocate
> > > from looks rather awkward. We have hardwall and softwall versions of
> > > cpuset_node_allowed with the softwall version doing literally the same
> > > as the hardwall version if __GFP_HARDWALL is passed to it in gfp flags.
> > > If it isn't, the softwall version may check the given node against the
> > > enclosing hardwall cpuset, which it needs to take the callback lock to
> > > do.
> > > 
> > > Such a distinction was introduced by commit 02a0e53d8227 ("cpuset:
> > > rework cpuset_zone_allowed api"). Before, we had the only version with
> > > the __GFP_HARDWALL flag determining its behavior. The purpose of the
> > > commit was to avoid sleep-in-atomic bugs when someone would mistakenly
> > > call the function without the __GFP_HARDWALL flag for an atomic
> > > allocation. The suffixes introduced were intended to make the callers
> > > think before using the function.
> > > 
> > > However, since the callback lock was converted from mutex to spinlock by
> > > the previous patch, the softwall check function cannot sleep, and these
> > > precautions are no longer necessary.
> > > 
> > > So let's simplify the API back to the single check.
> > > 
> > > Suggested-by: David Rientjes <rientjes@google.com>
> > > Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> > > Acked-by: Christoph Lameter <cl@linux.com>
> > > Acked-by: Zefan Li <lizefan@huawei.com>
> > 
> > Applied 1-2 to cgroup/for-3.19-cpuset-api-simplification which
> > contains only these two patches on top of v3.18-rc2 and will stay
> > stable.  sl[au]b trees can pull it in or I can take the other two
> > patches too.  Please let me know how the other two should be routed.
> 
> JFYI, Andrew merged all four patches in his mmotm tree.
> 
> FWIW, there's a typo in this patch recently found and fixed by Dan
> Carpenter. The fix is below.

Ah, cool.  I'll keep the cpuset patches and the fix in the cgroup tree
so that future dependent changes don't collide with them in -mm.
Andrew, please note that the first two patches in this series and
Dan's fix will appear in cgroup/for-3.19.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
