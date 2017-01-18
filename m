Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9340E6B0038
	for <linux-mm@kvack.org>; Wed, 18 Jan 2017 16:01:18 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id c80so26916169iod.4
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 13:01:18 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id a5si1290395pgg.89.2017.01.18.13.01.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jan 2017 13:01:17 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id 194so2235788pgd.0
        for <linux-mm@kvack.org>; Wed, 18 Jan 2017 13:01:17 -0800 (PST)
Date: Wed, 18 Jan 2017 13:01:15 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET v2] slab: make memcg slab destruction scalable
Message-ID: <20170118210115.GE9171@mtj.duckdns.org>
References: <20170114184834.8658-1-tj@kernel.org>
 <20170117001256.GB25218@js1304-P5Q-DELUXE>
 <20170117164913.GB28948@mtj.duckdns.org>
 <20170118075448.GA1255@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170118075448.GA1255@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: vdavydov.dev@gmail.com, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, jsvana@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, kernel-team@fb.com

Hello,

On Wed, Jan 18, 2017 at 04:54:48PM +0900, Joonsoo Kim wrote:
> That problem is caused by slow release path and then contention on the
> slab_mutex. With an ordered workqueue, kworker would not be created a
> lot but it can be possible that a lot of work items to create a new
> cache for memcg is pending for a long time due to slow release path.

How many work items are pending and how many workers are on them
shouldn't affect the actual completion time that much when most of
them are serialized by a mutex.  Anyways, this patchset moves all the
slow parts out of slab_mutex, so none of this is a problem anymore.

> Your patchset replaces optimization for release path so it's better to
> check that the work isn't pending for a long time in above workload.

Yeap, it seems to work fine.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
