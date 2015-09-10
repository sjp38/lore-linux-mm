Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f169.google.com (mail-ig0-f169.google.com [209.85.213.169])
	by kanga.kvack.org (Postfix) with ESMTP id EDE206B0038
	for <linux-mm@kvack.org>; Thu, 10 Sep 2015 15:38:24 -0400 (EDT)
Received: by igcpb10 with SMTP id pb10so28569464igc.1
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 12:38:24 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id o75si11777853ioe.62.2015.09.10.12.38.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Sep 2015 12:38:24 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so52326967pac.2
        for <linux-mm@kvack.org>; Thu, 10 Sep 2015 12:38:23 -0700 (PDT)
Date: Thu, 10 Sep 2015 15:38:19 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 3/7] x86, gfp: Cache best near node for memory
 allocation.
Message-ID: <20150910193819.GJ8114@mtj.duckdns.org>
References: <1441859269-25831-1-git-send-email-tangchen@cn.fujitsu.com>
 <1441859269-25831-4-git-send-email-tangchen@cn.fujitsu.com>
 <20150910192935.GI8114@mtj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150910192935.GI8114@mtj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: jiang.liu@linux.intel.com, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, qiaonuohan@cn.fujitsu.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gu Zheng <guz.fnst@cn.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>

(cc'ing Christoph Lameter)

On Thu, Sep 10, 2015 at 03:29:35PM -0400, Tejun Heo wrote:
> Hello,
> 
> On Thu, Sep 10, 2015 at 12:27:45PM +0800, Tang Chen wrote:
> > diff --git a/include/linux/gfp.h b/include/linux/gfp.h
> > index ad35f30..1a1324f 100644
> > --- a/include/linux/gfp.h
> > +++ b/include/linux/gfp.h
> > @@ -307,13 +307,19 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
> >  	if (nid < 0)
> >  		nid = numa_node_id();
> >  
> > +	if (!node_online(nid))
> > +		nid = get_near_online_node(nid);
> > +
> >  	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
> >  }
> 
> Why not just update node_data[]->node_zonelist in the first place?
> Also, what's the synchronization rule here?  How are allocators
> synchronized against node hot [un]plugs?

Also, shouldn't kmalloc_node() or any public allocator fall back
automatically to a near node w/o GFP_THISNODE?  Why is this failing at
all?  I get that cpu id -> node id mapping changing messes up the
locality but allocations shouldn't fail, right?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
