Return-Path: <SRS0=NdlI=QR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5A4E0C282C2
	for <linux-mm@archiver.kernel.org>; Sun, 10 Feb 2019 17:20:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E2C5621736
	for <linux-mm@archiver.kernel.org>; Sun, 10 Feb 2019 17:20:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E2C5621736
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=huawei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3CF5F8E00B5; Sun, 10 Feb 2019 12:20:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37F6D8E00B4; Sun, 10 Feb 2019 12:20:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 296B08E00B5; Sun, 10 Feb 2019 12:20:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id F393B8E00B4
	for <linux-mm@kvack.org>; Sun, 10 Feb 2019 12:20:24 -0500 (EST)
Received: by mail-ot1-f72.google.com with SMTP id z6so8710167otm.10
        for <linux-mm@kvack.org>; Sun, 10 Feb 2019 09:20:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:organization
         :mime-version:content-transfer-encoding;
        bh=HqZvJM6+JPY85EPCm9RfM3Qu5HtHf+6QAOeu6OlM79Q=;
        b=JE3xWlJLmzXFZQFEjgRUnRO+MajSVB9qoe9RA15uPrHZCKjQ9CDGiFU2w0AtR0VEI1
         SHsR/K1nI7Qmt0u1YOhUIBAXGIDg7FxP5FUfJIzPSLxIN3emjq0J7XuTSTK0KlJvbIq9
         tWBcjtB33Sz3czI4DvUoNTxhAVJwVm3eZ5B4wqvMvKUxDF1NH6+b0TT+yK+aUkJvyhJc
         Zv+yLNlJ8kgv2BvH3SoV2HFwfNyv8SXO9TtJsJOgEG0na5s/NHH8NEGbd3I4l1EBZ3Qu
         +2xEJGBRZJGLTo3aePvUtHsC4MUR5m0ElJjbvaJNtKhdmRYTZGTWRX0++Km+L0hSuKHy
         f7ag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
X-Gm-Message-State: AHQUAuZ3YGnEmYsXnITr7t8g5GRymQeDsXwU3QB94IDX06B2RrP0XDkF
	2EDs35x3qwC6n1iAXLupIueCdxAzrrFLCSOL87GsYr7rWLuG4XxSmZPS/gd2Be5ayvYThdGPpm0
	3vmjoC6aDP2jFUItVEeL5Co18mtD/WLk7aTdG25ywhF38FzTWLY6swR5UdVfnulmsYA==
X-Received: by 2002:a9d:7a8c:: with SMTP id l12mr24178622otn.335.1549819224660;
        Sun, 10 Feb 2019 09:20:24 -0800 (PST)
X-Google-Smtp-Source: AHgI3IayCrcpBwf5s6kJd5ZAQPy6RLlyvR+aoQbME2YPsGzPSRxdfPcOElxKRn8mCUHTr5S0aSZ8
X-Received: by 2002:a9d:7a8c:: with SMTP id l12mr24178556otn.335.1549819223607;
        Sun, 10 Feb 2019 09:20:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549819223; cv=none;
        d=google.com; s=arc-20160816;
        b=XFLVyFV7zmKkMmZnLNuJCnixXAXJcnrSQtCTDRU62mGbDE0mybaFiFzl7RQ6MyfTZo
         kRtbjOQXsBcZuyay4y+v4DZhwnPPz6uNoPY0+IEoLLeAKy+BHaKs6EElxRUSDol3exb6
         ePR+IHVlz2cBmPCFLa7nKK1U7Oyf0Tmv4NGSUi8ZlvA8vZRREgquxAPL0whL5GcoxPIb
         gIgSWg+i4ks/WYcOyixOlAt3OkytxU9xAHCMS6pdw6LJGfoce+wbHhTzOiERZ2goomdt
         740CXZuxvd8Yt5yn10Ungel5bbPUK+heCj6zEei2AXZENBZfENtUTwiBCyqg24BVUOCW
         a2DQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:organization:references
         :in-reply-to:message-id:subject:cc:to:from:date;
        bh=HqZvJM6+JPY85EPCm9RfM3Qu5HtHf+6QAOeu6OlM79Q=;
        b=0AZf1yhH1LHMkbzl9ZEoUY2sV2E1G6SH6U2uNNOoPXg6mg/50B5R1f2uiJ54tOjNUA
         1ZDKjf+eQX4Oa6fb0J2QJBKUQKJSyr979AQ9wmSoYLM3uZ1FBBxJrGY8frnVagvPhFJd
         6qz7K65vifQFFDRbYOIYst8R8J0l+lb8Yryacb3mStuZFeZ4e93jIOoKc9Cryhr8/Q+g
         RHTQdxLHsrw3NMQJ6/qWyc4AM6f1lkotsrZx89LIkhbbN2w4yN2BO928+I8+uuM+CP/y
         agBq9ytnVdG/yepW8+tlj+Vhsd3XKE0fp7u+EHBBXkYBdiTa1/XOyZptS2Slk1/LCPf8
         D1/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id v71si3452102oia.154.2019.02.10.09.20.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Feb 2019 09:20:23 -0800 (PST)
Received-SPF: pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) client-ip=45.249.212.35;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jonathan.cameron@huawei.com designates 45.249.212.35 as permitted sender) smtp.mailfrom=jonathan.cameron@huawei.com
Received: from DGGEMS410-HUB.china.huawei.com (unknown [172.30.72.58])
	by Forcepoint Email with ESMTP id 646346BB552E6B6B1F0;
	Mon, 11 Feb 2019 01:20:18 +0800 (CST)
Received: from localhost (10.47.91.52) by DGGEMS410-HUB.china.huawei.com
 (10.3.19.210) with Microsoft SMTP Server id 14.3.408.0; Mon, 11 Feb 2019
 01:20:12 +0800
Date: Sun, 10 Feb 2019 17:19:58 +0000
From: Jonathan Cameron <jonathan.cameron@huawei.com>
To: Brice Goglin <Brice.Goglin@inria.fr>
CC: Keith Busch <keith.busch@intel.com>, <linux-kernel@vger.kernel.org>,
	<linux-acpi@vger.kernel.org>, <linux-mm@kvack.org>, Greg Kroah-Hartman
	<gregkh@linuxfoundation.org>, Rafael Wysocki <rafael@kernel.org>, "Dave
 Hansen" <dave.hansen@intel.com>, Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCHv4 10/13] node: Add memory caching attributes
Message-ID: <20190210171958.00003ab2@huawei.com>
In-Reply-To: <4a7d1c0c-c269-d7b2-11cb-88ad62b70a06@inria.fr>
References: <20190116175804.30196-1-keith.busch@intel.com>
	<20190116175804.30196-11-keith.busch@intel.com>
	<4a7d1c0c-c269-d7b2-11cb-88ad62b70a06@inria.fr>
Organization: Huawei
X-Mailer: Claws Mail 3.17.3 (GTK+ 2.24.32; i686-w64-mingw32)
MIME-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
X-Originating-IP: [10.47.91.52]
X-CFilter-Loop: Reflected
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 9 Feb 2019 09:20:53 +0100
Brice Goglin <Brice.Goglin@inria.fr> wrote:

> Hello Keith
>=20
> Could we ever have a single side cache in front of two NUMA nodes ? I
> don't see a way to find that out in the current implementation. Would we
> have an "id" and/or "nodemap" bitmask in the sidecache structure ?

This is certainly a possible thing for hardware to do.

ACPI IIRC doesn't provide any means of representing that - your best
option is to represent it as two different entries, one for each of the
memory nodes.  Interesting question of whether you would then claim
they were half as big each, or the full size.  Of course, there are
other possible ways to get this info beyond HMAT, so perhaps the interface
should allow it to be exposed if available?

Also, don't know if it's just me, but calling these sidecaches is
downright confusing.  In ACPI at least they are always
specifically referred to as Memory Side Caches.
I'd argue there should even by a hyphen Memory-Side Caches, the point
being that that they are on the memory side of the interconnected
rather than the processor side.  Of course an implementation
choice might be to put them off to the side (as implied by sidecaches)
in some sense, but it's not the only one.

</terminology rant> :)

Jonathan

>=20
> Thanks
>=20
> Brice
>=20
>=20
>=20
> Le 16/01/2019 =E0 18:58, Keith Busch a =E9crit=A0:
> > System memory may have side caches to help improve access speed to
> > frequently requested address ranges. While the system provided cache is
> > transparent to the software accessing these memory ranges, applications
> > can optimize their own access based on cache attributes.
> >
> > Provide a new API for the kernel to register these memory side caches
> > under the memory node that provides it.
> >
> > The new sysfs representation is modeled from the existing cpu cacheinfo
> > attributes, as seen from /sys/devices/system/cpu/cpuX/side_cache/.
> > Unlike CPU cacheinfo, though, the node cache level is reported from
> > the view of the memory. A higher number is nearer to the CPU, while
> > lower levels are closer to the backing memory. Also unlike CPU cache,
> > it is assumed the system will handle flushing any dirty cached memory
> > to the last level on a power failure if the range is persistent memory.
> >
> > The attributes we export are the cache size, the line size, associativi=
ty,
> > and write back policy.
> >
> > Signed-off-by: Keith Busch <keith.busch@intel.com>
> > ---
> >  drivers/base/node.c  | 142 +++++++++++++++++++++++++++++++++++++++++++=
++++++++
> >  include/linux/node.h |  39 ++++++++++++++
> >  2 files changed, 181 insertions(+)
> >
> > diff --git a/drivers/base/node.c b/drivers/base/node.c
> > index 1e909f61e8b1..7ff3ed566d7d 100644
> > --- a/drivers/base/node.c
> > +++ b/drivers/base/node.c
> > @@ -191,6 +191,146 @@ void node_set_perf_attrs(unsigned int nid, struct=
 node_hmem_attrs *hmem_attrs,
> >  		pr_info("failed to add performance attribute group to node %d\n",
> >  			nid);
> >  }
> > +
> > +struct node_cache_info {
> > +	struct device dev;
> > +	struct list_head node;
> > +	struct node_cache_attrs cache_attrs;
> > +};
> > +#define to_cache_info(device) container_of(device, struct node_cache_i=
nfo, dev)
> > +
> > +#define CACHE_ATTR(name, fmt) 						\
> > +static ssize_t name##_show(struct device *dev,				\
> > +			   struct device_attribute *attr,		\
> > +			   char *buf)					\
> > +{									\
> > +	return sprintf(buf, fmt "\n", to_cache_info(dev)->cache_attrs.name);\
> > +}									\
> > +DEVICE_ATTR_RO(name);
> > +
> > +CACHE_ATTR(size, "%llu")
> > +CACHE_ATTR(level, "%u")
> > +CACHE_ATTR(line_size, "%u")
> > +CACHE_ATTR(associativity, "%u")
> > +CACHE_ATTR(write_policy, "%u")
> > +
> > +static struct attribute *cache_attrs[] =3D {
> > +	&dev_attr_level.attr,
> > +	&dev_attr_associativity.attr,
> > +	&dev_attr_size.attr,
> > +	&dev_attr_line_size.attr,
> > +	&dev_attr_write_policy.attr,
> > +	NULL,
> > +};
> > +ATTRIBUTE_GROUPS(cache);
> > +
> > +static void node_cache_release(struct device *dev)
> > +{
> > +	kfree(dev);
> > +}
> > +
> > +static void node_cacheinfo_release(struct device *dev)
> > +{
> > +	struct node_cache_info *info =3D to_cache_info(dev);
> > +	kfree(info);
> > +}
> > +
> > +static void node_init_cache_dev(struct node *node)
> > +{
> > +	struct device *dev;
> > +
> > +	dev =3D kzalloc(sizeof(*dev), GFP_KERNEL);
> > +	if (!dev)
> > +		return;
> > +
> > +	dev->parent =3D &node->dev;
> > +	dev->release =3D node_cache_release;
> > +	if (dev_set_name(dev, "side_cache"))
> > +		goto free_dev;
> > +
> > +	if (device_register(dev))
> > +		goto free_name;
> > +
> > +	pm_runtime_no_callbacks(dev);
> > +	node->cache_dev =3D dev;
> > +	return;
> > +free_name:
> > +	kfree_const(dev->kobj.name);
> > +free_dev:
> > +	kfree(dev);
> > +}
> > +
> > +void node_add_cache(unsigned int nid, struct node_cache_attrs *cache_a=
ttrs)
> > +{
> > +	struct node_cache_info *info;
> > +	struct device *dev;
> > +	struct node *node;
> > +
> > +	if (!node_online(nid) || !node_devices[nid])
> > +		return;
> > +
> > +	node =3D node_devices[nid];
> > +	list_for_each_entry(info, &node->cache_attrs, node) {
> > +		if (info->cache_attrs.level =3D=3D cache_attrs->level) {
> > +			dev_warn(&node->dev,
> > +				"attempt to add duplicate cache level:%d\n",
> > +				cache_attrs->level);
> > +			return;
> > +		}
> > +	}
> > +
> > +	if (!node->cache_dev)
> > +		node_init_cache_dev(node);
> > +	if (!node->cache_dev)
> > +		return;
> > +
> > +	info =3D kzalloc(sizeof(*info), GFP_KERNEL);
> > +	if (!info)
> > +		return;
> > +
> > +	dev =3D &info->dev;
> > +	dev->parent =3D node->cache_dev;
> > +	dev->release =3D node_cacheinfo_release;
> > +	dev->groups =3D cache_groups;
> > +	if (dev_set_name(dev, "index%d", cache_attrs->level))
> > +		goto free_cache;
> > +
> > +	info->cache_attrs =3D *cache_attrs;
> > +	if (device_register(dev)) {
> > +		dev_warn(&node->dev, "failed to add cache level:%d\n",
> > +			 cache_attrs->level);
> > +		goto free_name;
> > +	}
> > +	pm_runtime_no_callbacks(dev);
> > +	list_add_tail(&info->node, &node->cache_attrs);
> > +	return;
> > +free_name:
> > +	kfree_const(dev->kobj.name);
> > +free_cache:
> > +	kfree(info);
> > +}
> > +
> > +static void node_remove_caches(struct node *node)
> > +{
> > +	struct node_cache_info *info, *next;
> > +
> > +	if (!node->cache_dev)
> > +		return;
> > +
> > +	list_for_each_entry_safe(info, next, &node->cache_attrs, node) {
> > +		list_del(&info->node);
> > +		device_unregister(&info->dev);
> > +	}
> > +	device_unregister(node->cache_dev);
> > +}
> > +
> > +static void node_init_caches(unsigned int nid)
> > +{
> > +	INIT_LIST_HEAD(&node_devices[nid]->cache_attrs);
> > +}
> > +#else
> > +static void node_init_caches(unsigned int nid) { }
> > +static void node_remove_caches(struct node *node) { }
> >  #endif
> > =20
> >  #define K(x) ((x) << (PAGE_SHIFT - 10))
> > @@ -475,6 +615,7 @@ void unregister_node(struct node *node)
> >  {
> >  	hugetlb_unregister_node(node);		/* no-op, if memoryless node */
> >  	node_remove_classes(node);
> > +	node_remove_caches(node);
> >  	device_unregister(&node->dev);
> >  }
> > =20
> > @@ -755,6 +896,7 @@ int __register_one_node(int nid)
> >  	INIT_LIST_HEAD(&node_devices[nid]->class_list);
> >  	/* initialize work queue for memory hot plug */
> >  	init_node_hugetlb_work(nid);
> > +	node_init_caches(nid);
> > =20
> >  	return error;
> >  }
> > diff --git a/include/linux/node.h b/include/linux/node.h
> > index e22940a593c2..8cdf2b2808e4 100644
> > --- a/include/linux/node.h
> > +++ b/include/linux/node.h
> > @@ -37,12 +37,47 @@ struct node_hmem_attrs {
> >  };
> >  void node_set_perf_attrs(unsigned int nid, struct node_hmem_attrs *hme=
m_attrs,
> >  			 unsigned class);
> > +
> > +enum cache_associativity {
> > +	NODE_CACHE_DIRECT_MAP,
> > +	NODE_CACHE_INDEXED,
> > +	NODE_CACHE_OTHER,
> > +};
> > +
> > +enum cache_write_policy {
> > +	NODE_CACHE_WRITE_BACK,
> > +	NODE_CACHE_WRITE_THROUGH,
> > +	NODE_CACHE_WRITE_OTHER,
> > +};
> > +
> > +/**
> > + * struct node_cache_attrs - system memory caching attributes
> > + *
> > + * @associativity:	The ways memory blocks may be placed in cache
> > + * @write_policy:	Write back or write through policy
> > + * @size:		Total size of cache in bytes
> > + * @line_size:		Number of bytes fetched on a cache miss
> > + * @level:		Represents the cache hierarchy level
> > + */
> > +struct node_cache_attrs {
> > +	enum cache_associativity associativity;
> > +	enum cache_write_policy write_policy;
> > +	u64 size;
> > +	u16 line_size;
> > +	u8  level;
> > +};
> > +void node_add_cache(unsigned int nid, struct node_cache_attrs *cache_a=
ttrs);
> >  #else
> >  static inline void node_set_perf_attrs(unsigned int nid,
> >  				       struct node_hmem_attrs *hmem_attrs,
> >  				       unsigned class)
> >  {
> >  }
> > +
> > +static inline void node_add_cache(unsigned int nid,
> > +				  struct node_cache_attrs *cache_attrs)
> > +{
> > +}
> >  #endif
> > =20
> >  struct node {
> > @@ -51,6 +86,10 @@ struct node {
> >  #if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_HUGETLBFS)
> >  	struct work_struct	node_work;
> >  #endif
> > +#ifdef CONFIG_HMEM_REPORTING
> > +	struct list_head cache_attrs;
> > +	struct device *cache_dev;
> > +#endif
> >  };
> > =20
> >  struct memory_block; =20
>=20


