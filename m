Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id D3EE16B0035
	for <linux-mm@kvack.org>; Thu, 27 Mar 2014 16:40:46 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id f8so6418985wiw.12
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 13:40:46 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dq1si3638609wib.75.2014.03.27.13.40.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 27 Mar 2014 13:40:45 -0700 (PDT)
Date: Thu, 27 Mar 2014 13:40:41 -0700
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -mm 1/4] sl[au]b: do not charge large allocations to memcg
Message-ID: <20140327204041.GB28590@dhcp22.suse.cz>
References: <cover.1395846845.git.vdavydov@parallels.com>
 <5a5b09d4cb9a15fc120b4bec8be168630a3b43c2.1395846845.git.vdavydov@parallels.com>
 <20140326215320.GA22656@dhcp22.suse.cz>
 <5333D472.2000606@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5333D472.2000606@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: glommer@gmail.com, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>

On Thu 27-03-14 11:34:10, Vladimir Davydov wrote:
> Hi Michal,
> 
> On 03/27/2014 01:53 AM, Michal Hocko wrote:
> > On Wed 26-03-14 19:28:04, Vladimir Davydov wrote:
> >> We don't track any random page allocation, so we shouldn't track kmalloc
> >> that falls back to the page allocator.
> > Why did we do that in the first place? d79923fad95b (sl[au]b: allocate
> > objects from memcg cache) didn't tell me much.
> 
> I don't know, we'd better ask Glauber about that.
> 
> > How is memcg_kmem_skip_account removal related?
> 
> The comment this patch removes along with the memcg_kmem_skip_account
> check explains that pretty well IMO. In short, we only use
> memcg_kmem_skip_account to prevent kmalloc's from charging, which is
> crucial for recursion-avoidance in memcg_kmem_get_cache. Since we don't
> charge pages allocated from a root (not per-memcg) cache, from the first
> glance it would be enough to check for memcg_kmem_skip_account only in
> memcg_kmem_get_cache and return the root cache if it's set. However, for
> we can also kmalloc w/o issuing memcg_kmem_get_cache (kmalloc_large), we
> also need this check in memcg_kmem_newpage_charge. This patch removes
> kmalloc_large accounting, so we don't need this check anymore.

Document that in the changelog please.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
