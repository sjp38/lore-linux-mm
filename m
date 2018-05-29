Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1BF8B6B0003
	for <linux-mm@kvack.org>; Tue, 29 May 2018 09:58:13 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id l29-v6so3106712qkh.1
        for <linux-mm@kvack.org>; Tue, 29 May 2018 06:58:13 -0700 (PDT)
Received: from a9-112.smtp-out.amazonses.com (a9-112.smtp-out.amazonses.com. [54.240.9.112])
        by mx.google.com with ESMTPS id q33-v6si1270282qvc.14.2018.05.29.06.58.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 29 May 2018 06:58:11 -0700 (PDT)
Date: Tue, 29 May 2018 13:58:11 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v2] mm: fix race between kmem_cache destroy, create and
 deactivate
In-Reply-To: <20180526185837.k5ztrillokpi65qj@esperanza>
Message-ID: <01000163ac3122e8-e705287a-17f4-4ff6-8eae-1ad310676096-000000@email.amazonses.com>
References: <20180522201336.196994-1-shakeelb@google.com> <20180526185837.k5ztrillokpi65qj@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Shakeel Butt <shakeelb@google.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Linux MM <linux-mm@kvack.org>, cgroups@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Sat, 26 May 2018, Vladimir Davydov wrote:

> > The reference counting is only implemented for root kmem_caches for
> > simplicity. The reference of a root kmem_cache is elevated on sharing or
> > while its memcg kmem_cache creation or deactivation request is in the
> > fly and thus it is made sure that the root kmem_cache is not destroyed
> > in the middle. As the reference of kmem_cache is elevated on sharing,
> > the 'shared_count' does not need any locking protection as at worst it
> > can be out-dated for a small window which is tolerable.
>
> I wonder if we could fix this problem without introducing reference
> counting for kmem caches (which seems a bit of an overkill to me TBO),
> e.g. by flushing memcg_kmem_cache_wq before root cache destruction?

Would prefer that too but the whole memcg handling is something of a
mystery to me.
