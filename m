Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f177.google.com (mail-yk0-f177.google.com [209.85.160.177])
	by kanga.kvack.org (Postfix) with ESMTP id 0EA176B0038
	for <linux-mm@kvack.org>; Sat, 26 Sep 2015 13:53:48 -0400 (EDT)
Received: by ykdt18 with SMTP id t18so141568979ykd.3
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 10:53:47 -0700 (PDT)
Received: from mail-yk0-x22f.google.com (mail-yk0-x22f.google.com. [2607:f8b0:4002:c07::22f])
        by mx.google.com with ESMTPS id p5si4446731ykf.3.2015.09.26.10.53.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 26 Sep 2015 10:53:47 -0700 (PDT)
Received: by ykdt18 with SMTP id t18so141568790ykd.3
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 10:53:47 -0700 (PDT)
Date: Sat, 26 Sep 2015 13:53:37 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 3/7] x86, gfp: Cache best near node for memory
 allocation.
Message-ID: <20150926175337.GB3572@htj.duckdns.org>
References: <1441859269-25831-1-git-send-email-tangchen@cn.fujitsu.com>
 <1441859269-25831-4-git-send-email-tangchen@cn.fujitsu.com>
 <20150910192935.GI8114@mtj.duckdns.org>
 <560665DB.7020301@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <560665DB.7020301@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: jiang.liu@linux.intel.com, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, qiaonuohan@cn.fujitsu.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello, Tang.

On Sat, Sep 26, 2015 at 05:31:07PM +0800, Tang Chen wrote:
> >>@@ -307,13 +307,19 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
> >>  	if (nid < 0)
> >>  		nid = numa_node_id();
> >>+	if (!node_online(nid))
> >>+		nid = get_near_online_node(nid);
> >>+
> >>  	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
> >>  }
> >Why not just update node_data[]->node_zonelist in the first place?
> 
> zonelist will be rebuilt in __offline_pages() when the zone is not populated
> any more.
> 
> Here, getting the best near online node is for those cpus on memory-less
> nodes.
> 
> In the original code, if nid is NUMA_NO_NODE, the node the current cpu
> resides in
> will be chosen. And if the node is memory-less node, the cpu will be mapped
> to its
> best near online node.
> 
> But this patch-set will map the cpu to its original node, so numa_node_id()
> may return
> a memory-less node to allocator. And then memory allocation may fail.

Correct me if I'm wrong but the zonelist dictates which memory areas
the page allocator is gonna try to from, right?  What I'm wondering is
why we aren't handling memory-less nodes by simply updating their
zonelists.  I mean, if, say, node 2 is memory-less, its zonelist can
simply point to zones from other nodes, right?  What am I missing
here?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
