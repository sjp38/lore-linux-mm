Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1D1886B0031
	for <linux-mm@kvack.org>; Thu, 27 Mar 2014 03:34:17 -0400 (EDT)
Received: by mail-lb0-f169.google.com with SMTP id q8so2353304lbi.28
        for <linux-mm@kvack.org>; Thu, 27 Mar 2014 00:34:17 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id q7si671446lbw.239.2014.03.27.00.34.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Mar 2014 00:34:16 -0700 (PDT)
Message-ID: <5333D472.2000606@parallels.com>
Date: Thu, 27 Mar 2014 11:34:10 +0400
From: Vladimir Davydov <vdavydov@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm 1/4] sl[au]b: do not charge large allocations to memcg
References: <cover.1395846845.git.vdavydov@parallels.com> <5a5b09d4cb9a15fc120b4bec8be168630a3b43c2.1395846845.git.vdavydov@parallels.com> <20140326215320.GA22656@dhcp22.suse.cz>
In-Reply-To: <20140326215320.GA22656@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, glommer@gmail.com
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>

Hi Michal,

On 03/27/2014 01:53 AM, Michal Hocko wrote:
> On Wed 26-03-14 19:28:04, Vladimir Davydov wrote:
>> We don't track any random page allocation, so we shouldn't track kmalloc
>> that falls back to the page allocator.
> Why did we do that in the first place? d79923fad95b (sl[au]b: allocate
> objects from memcg cache) didn't tell me much.

I don't know, we'd better ask Glauber about that.

> How is memcg_kmem_skip_account removal related?

The comment this patch removes along with the memcg_kmem_skip_account
check explains that pretty well IMO. In short, we only use
memcg_kmem_skip_account to prevent kmalloc's from charging, which is
crucial for recursion-avoidance in memcg_kmem_get_cache. Since we don't
charge pages allocated from a root (not per-memcg) cache, from the first
glance it would be enough to check for memcg_kmem_skip_account only in
memcg_kmem_get_cache and return the root cache if it's set. However, for
we can also kmalloc w/o issuing memcg_kmem_get_cache (kmalloc_large), we
also need this check in memcg_kmem_newpage_charge. This patch removes
kmalloc_large accounting, so we don't need this check anymore.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
