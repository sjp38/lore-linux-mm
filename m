Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 03FAE6B0007
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 10:22:00 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 31so5072410wrr.2
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 07:21:59 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x25si766853edb.276.2018.04.13.07.21.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Apr 2018 07:21:58 -0700 (PDT)
Subject: Re: [PATCH 3/3] dcache: account external names as indirectly
 reclaimable memory
References: <20180305133743.12746-1-guro@fb.com>
 <20180305133743.12746-5-guro@fb.com>
 <20180413133519.GA213834@rodete-laptop-imager.corp.google.com>
 <20180413135923.GT17484@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <13f1f5b5-f3f8-956c-145a-4641fb996048@suse.cz>
Date: Fri, 13 Apr 2018 16:20:00 +0200
MIME-Version: 1.0
In-Reply-To: <20180413135923.GT17484@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Minchan Kim <minchan@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On 04/13/2018 03:59 PM, Michal Hocko wrote:
> On Fri 13-04-18 22:35:19, Minchan Kim wrote:
>> On Mon, Mar 05, 2018 at 01:37:43PM +0000, Roman Gushchin wrote:
> [...]
>>> @@ -1614,9 +1623,11 @@ struct dentry *__d_alloc(struct super_block *sb, const struct qstr *name)
>>>  		name = &slash_name;
>>>  		dname = dentry->d_iname;
>>>  	} else if (name->len > DNAME_INLINE_LEN-1) {
>>> -		size_t size = offsetof(struct external_name, name[1]);
>>> -		struct external_name *p = kmalloc(size + name->len,
>>> -						  GFP_KERNEL_ACCOUNT);
>>> +		struct external_name *p;
>>> +
>>> +		reclaimable = offsetof(struct external_name, name[1]) +
>>> +			name->len;
>>> +		p = kmalloc(reclaimable, GFP_KERNEL_ACCOUNT);
>>
>> Can't we use kmem_cache_alloc with own cache created with SLAB_RECLAIM_ACCOUNT
>> if they are reclaimable? 
> 
> No, because names have different sizes and so we would basically have to
> duplicate many caches.

We would need kmalloc-reclaimable-X variants. It could be worth it,
especially if we find more similar usages. I suspect they would be more
useful than the existing dma-kmalloc-X :)

Maybe create both (dma and reclaimable) on demand?
