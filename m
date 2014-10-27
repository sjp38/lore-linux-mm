Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id 4A75E6B0069
	for <linux-mm@kvack.org>; Mon, 27 Oct 2014 11:18:13 -0400 (EDT)
Received: by mail-qc0-f181.google.com with SMTP id w7so1382058qcr.40
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 08:18:13 -0700 (PDT)
Received: from mail-qa0-x231.google.com (mail-qa0-x231.google.com. [2607:f8b0:400d:c00::231])
        by mx.google.com with ESMTPS id c3si21158525qan.79.2014.10.27.08.18.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 27 Oct 2014 08:18:12 -0700 (PDT)
Received: by mail-qa0-f49.google.com with SMTP id i13so2003586qae.8
        for <linux-mm@kvack.org>; Mon, 27 Oct 2014 08:18:09 -0700 (PDT)
Date: Mon, 27 Oct 2014 11:18:06 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH RESEND 2/4] cpuset: simplify cpuset_node_allowed API
Message-ID: <20141027151806.GR4436@htj.dyndns.org>
References: <cover.1413804554.git.vdavydov@parallels.com>
 <c52e3c30a61d29da40b69b602c41c2d91868c3ae.1413804554.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c52e3c30a61d29da40b69b602c41c2d91868c3ae.1413804554.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Zefan Li <lizefan@huawei.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Oct 20, 2014 at 03:50:30PM +0400, Vladimir Davydov wrote:
> Current cpuset API for checking if a zone/node is allowed to allocate
> from looks rather awkward. We have hardwall and softwall versions of
> cpuset_node_allowed with the softwall version doing literally the same
> as the hardwall version if __GFP_HARDWALL is passed to it in gfp flags.
> If it isn't, the softwall version may check the given node against the
> enclosing hardwall cpuset, which it needs to take the callback lock to
> do.
> 
> Such a distinction was introduced by commit 02a0e53d8227 ("cpuset:
> rework cpuset_zone_allowed api"). Before, we had the only version with
> the __GFP_HARDWALL flag determining its behavior. The purpose of the
> commit was to avoid sleep-in-atomic bugs when someone would mistakenly
> call the function without the __GFP_HARDWALL flag for an atomic
> allocation. The suffixes introduced were intended to make the callers
> think before using the function.
> 
> However, since the callback lock was converted from mutex to spinlock by
> the previous patch, the softwall check function cannot sleep, and these
> precautions are no longer necessary.
> 
> So let's simplify the API back to the single check.
> 
> Suggested-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> Acked-by: Christoph Lameter <cl@linux.com>
> Acked-by: Zefan Li <lizefan@huawei.com>

Applied 1-2 to cgroup/for-3.19-cpuset-api-simplification which
contains only these two patches on top of v3.18-rc2 and will stay
stable.  sl[au]b trees can pull it in or I can take the other two
patches too.  Please let me know how the other two should be routed.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
