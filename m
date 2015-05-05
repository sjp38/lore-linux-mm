Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id CC66E6B0038
	for <linux-mm@kvack.org>; Tue,  5 May 2015 09:45:27 -0400 (EDT)
Received: by qgej70 with SMTP id j70so81131027qge.2
        for <linux-mm@kvack.org>; Tue, 05 May 2015 06:45:27 -0700 (PDT)
Received: from mail-qc0-x229.google.com (mail-qc0-x229.google.com. [2607:f8b0:400d:c01::229])
        by mx.google.com with ESMTPS id i74si15773938qge.99.2015.05.05.06.45.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 May 2015 06:45:26 -0700 (PDT)
Received: by qcyk17 with SMTP id k17so87966600qcy.1
        for <linux-mm@kvack.org>; Tue, 05 May 2015 06:45:25 -0700 (PDT)
Date: Tue, 5 May 2015 09:45:21 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/2] kernfs: do not account ino_ida allocations to memcg
Message-ID: <20150505134521.GL1971@htj.duckdns.org>
References: <fdf631b3fa95567a830ea4f3e19d0b3b2fc99662.1430819044.git.vdavydov@parallels.com>
 <0cf48f4219721952f182715a61910f626d7c4aca.1430819044.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0cf48f4219721952f182715a61910f626d7c4aca.1430819044.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, May 05, 2015 at 12:45:43PM +0300, Vladimir Davydov wrote:
> root->ino_ida is used for kernfs inode number allocations. Since IDA has
> a layered structure, different IDs can reside on the same layer, which
> is currently accounted to some memory cgroup. The problem is that each
> kmem cache of a memory cgroup has its own directory on sysfs (under
> /sys/fs/kernel/<cache-name>/cgroup). If the inode number of such a
> directory or any file in it gets allocated from a layer accounted to the
> cgroup which the cache is created for, the cgroup will get pinned for
> good, because one has to free all kmem allocations accounted to a cgroup
> in order to release it and destroy all its kmem caches. That said we
> must not account layers of ino_ida to any memory cgroup.
> 
> Since per net init operations may create new sysfs entries directly
> (e.g. lo device) or indirectly (nf_conntrack creates a new kmem cache
> per each namespace, which, in turn, creates new sysfs entries), an easy
> way to reproduce this issue is by creating network namespace(s) from
> inside a kmem-active memory cgroup.
> 
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

Man, that's nasty.  For the kernfs part,

Acked-by: Tejun Heo <tj@kernel.org>

Can you please repost this patch w/ Greg KH cc'd?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
