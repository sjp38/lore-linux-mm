Return-Path: <SRS0=K2Kt=QQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0544FC282C4
	for <linux-mm@archiver.kernel.org>; Sat,  9 Feb 2019 08:21:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9D42F20844
	for <linux-mm@archiver.kernel.org>; Sat,  9 Feb 2019 08:21:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9D42F20844
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=inria.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 30FBC8E00B0; Sat,  9 Feb 2019 03:21:12 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BD308E00AA; Sat,  9 Feb 2019 03:21:12 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 186ED8E00B0; Sat,  9 Feb 2019 03:21:12 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id B11838E00AA
	for <linux-mm@kvack.org>; Sat,  9 Feb 2019 03:21:11 -0500 (EST)
Received: by mail-wm1-f69.google.com with SMTP id y85so2613197wmc.7
        for <linux-mm@kvack.org>; Sat, 09 Feb 2019 00:21:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=p5iKeazvptNSIFUjGidqsQWP3E+EarnekfFF9xmzTao=;
        b=INgAP2oyPtfLMS7HcEER2N2PAdyv5mZ+yphXXdtMiYSSu73zk5gdSWmfa9KtH+dQSE
         TVhU4JpK3m/ZWVmhHbqsefdU1vZ2edEYuLt6UOuEsA9MmfcUHik2f4fD4mv7oZIm3bTK
         TNikclSKvwobtg4mvdArqAmN3R3b42vHeAnihzt5Gov9VMvLWmBYyWHqUBxANAdi4Usi
         Tq/WuYH9L+/p4BjCuGdegzRGXRzx1207vYArZSuQ82XjEPJYe1GNrqg2cboTscd4L9sJ
         aCxFgOCCZG9ejceBSAZ3BprBxE+K++K6kQbNkGvCzboqx985Cs26wdJuYh2xTCktk+TX
         nJqA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
X-Gm-Message-State: AHQUAubrEDtSO4SNwBEbnYLyQzjDHDfunw1A9cu9pCyeHULsm/G8tZNt
	e1/wsMS14onF6BEucsUxOE525kQDyYgXrVNx5/zRz2AvL4Ip4ENjYUE9YfxbERk1KlKpOr97qoz
	dtT5ZFYYx6iqncyRPT8d6hDMBKQLh81/44BOdB8so72XZTK2cgeU7Wglk3VFUX4JW0w==
X-Received: by 2002:a1c:b10a:: with SMTP id a10mr1963847wmf.148.1549700471183;
        Sat, 09 Feb 2019 00:21:11 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbcIhjnUEg9oIsnasJ85sRTTVXE27xnGUgslh5AaMXFQEscKUUnGkdkZu3aAYeCS3s9tcOz
X-Received: by 2002:a1c:b10a:: with SMTP id a10mr1963777wmf.148.1549700469963;
        Sat, 09 Feb 2019 00:21:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549700469; cv=none;
        d=google.com; s=arc-20160816;
        b=nY/P8vL+wlmca4rzf8nK3iV/iSNPCDC8mXMxi2y1FPAmuwb/0aFHtIaEN0CnH7074J
         vGhpWqlNdguX2aYOmVEiFW8cltoTJnjHz/D3IMrhZ9HAn96905eSMvOCX5IVwWHwegSk
         nIJVEeoDQ0zRKbAna3KuTD+xWDzrWiLTuPVWXW0iVRQ+e7dXUehpnxpBPPlKcbqxASrH
         OPvajK9W8rjQhqlTCc+xJSrxrgle/AmRSWJ4kNkJ/ZMFq/sWTCn+0dBItO/F8Np1XzXU
         69FnF7XJ34I5FrejYY7PAMdhUwIDw7HsddgOIXogH/ADMO277gVkbEIcmoytKHoacEAA
         3Zwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=p5iKeazvptNSIFUjGidqsQWP3E+EarnekfFF9xmzTao=;
        b=vfqw2pgMJOhm1wMckENftITh4hUu3rEfpWqDUhTAX9tGXZEwLq04hdgeszn5cT0SQ6
         zyLSj3zTIm0429VafcZyb8voOm4t/KsgbdqKIQd+wd0M+vFri9/Kxfupu6E9d8PXQYlq
         ZpW6URAV+yLjsYc+T50KgDS9IayhQezGDD+nVM1Sq/mHTQGNVRujRDYEeVkCcg9NDFgz
         Lx5wVog3cYQ4ixACxsQCOI0uK19ee7f5MB7tj8BkQyeDWWon3VDXL5dk6CBezFhiWGT8
         iLqJLHMMmujfKDv7+Dwh5rFXfP/HfbrW9PsNDawQUwzK6FFElfoNMaksVfiNXG9HxR5r
         U5bw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
Received: from mail3-relais-sop.national.inria.fr (mail3-relais-sop.national.inria.fr. [192.134.164.104])
        by mx.google.com with ESMTPS id o8si3297851wmf.127.2019.02.09.00.21.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Feb 2019 00:21:09 -0800 (PST)
Received-SPF: pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) client-ip=192.134.164.104;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
X-IronPort-AV: E=Sophos;i="5.58,350,1544482800"; 
   d="scan'208";a="295600747"
Received: from 91-160-5-165.subs.proxad.net (HELO [192.168.44.23]) ([91.160.5.165])
  by mail3-relais-sop.national.inria.fr with ESMTP/TLS/AES128-SHA; 09 Feb 2019 09:20:53 +0100
Subject: Re: [PATCHv4 10/13] node: Add memory caching attributes
To: Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org,
 linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>,
 Dan Williams <dan.j.williams@intel.com>
References: <20190116175804.30196-1-keith.busch@intel.com>
 <20190116175804.30196-11-keith.busch@intel.com>
From: Brice Goglin <Brice.Goglin@inria.fr>
Openpgp: preference=signencrypt
Autocrypt: addr=Brice.Goglin@inria.fr; prefer-encrypt=mutual; keydata=
 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
Message-ID: <4a7d1c0c-c269-d7b2-11cb-88ad62b70a06@inria.fr>
Date: Sat, 9 Feb 2019 09:20:53 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190116175804.30196-11-keith.busch@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Keith

Could we ever have a single side cache in front of two NUMA nodes ? I
don't see a way to find that out in the current implementation. Would we
have an "id" and/or "nodemap" bitmask in the sidecache structure ?

Thanks

Brice



Le 16/01/2019 à 18:58, Keith Busch a écrit :
> System memory may have side caches to help improve access speed to
> frequently requested address ranges. While the system provided cache is
> transparent to the software accessing these memory ranges, applications
> can optimize their own access based on cache attributes.
>
> Provide a new API for the kernel to register these memory side caches
> under the memory node that provides it.
>
> The new sysfs representation is modeled from the existing cpu cacheinfo
> attributes, as seen from /sys/devices/system/cpu/cpuX/side_cache/.
> Unlike CPU cacheinfo, though, the node cache level is reported from
> the view of the memory. A higher number is nearer to the CPU, while
> lower levels are closer to the backing memory. Also unlike CPU cache,
> it is assumed the system will handle flushing any dirty cached memory
> to the last level on a power failure if the range is persistent memory.
>
> The attributes we export are the cache size, the line size, associativity,
> and write back policy.
>
> Signed-off-by: Keith Busch <keith.busch@intel.com>
> ---
>  drivers/base/node.c  | 142 +++++++++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/node.h |  39 ++++++++++++++
>  2 files changed, 181 insertions(+)
>
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 1e909f61e8b1..7ff3ed566d7d 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -191,6 +191,146 @@ void node_set_perf_attrs(unsigned int nid, struct node_hmem_attrs *hmem_attrs,
>  		pr_info("failed to add performance attribute group to node %d\n",
>  			nid);
>  }
> +
> +struct node_cache_info {
> +	struct device dev;
> +	struct list_head node;
> +	struct node_cache_attrs cache_attrs;
> +};
> +#define to_cache_info(device) container_of(device, struct node_cache_info, dev)
> +
> +#define CACHE_ATTR(name, fmt) 						\
> +static ssize_t name##_show(struct device *dev,				\
> +			   struct device_attribute *attr,		\
> +			   char *buf)					\
> +{									\
> +	return sprintf(buf, fmt "\n", to_cache_info(dev)->cache_attrs.name);\
> +}									\
> +DEVICE_ATTR_RO(name);
> +
> +CACHE_ATTR(size, "%llu")
> +CACHE_ATTR(level, "%u")
> +CACHE_ATTR(line_size, "%u")
> +CACHE_ATTR(associativity, "%u")
> +CACHE_ATTR(write_policy, "%u")
> +
> +static struct attribute *cache_attrs[] = {
> +	&dev_attr_level.attr,
> +	&dev_attr_associativity.attr,
> +	&dev_attr_size.attr,
> +	&dev_attr_line_size.attr,
> +	&dev_attr_write_policy.attr,
> +	NULL,
> +};
> +ATTRIBUTE_GROUPS(cache);
> +
> +static void node_cache_release(struct device *dev)
> +{
> +	kfree(dev);
> +}
> +
> +static void node_cacheinfo_release(struct device *dev)
> +{
> +	struct node_cache_info *info = to_cache_info(dev);
> +	kfree(info);
> +}
> +
> +static void node_init_cache_dev(struct node *node)
> +{
> +	struct device *dev;
> +
> +	dev = kzalloc(sizeof(*dev), GFP_KERNEL);
> +	if (!dev)
> +		return;
> +
> +	dev->parent = &node->dev;
> +	dev->release = node_cache_release;
> +	if (dev_set_name(dev, "side_cache"))
> +		goto free_dev;
> +
> +	if (device_register(dev))
> +		goto free_name;
> +
> +	pm_runtime_no_callbacks(dev);
> +	node->cache_dev = dev;
> +	return;
> +free_name:
> +	kfree_const(dev->kobj.name);
> +free_dev:
> +	kfree(dev);
> +}
> +
> +void node_add_cache(unsigned int nid, struct node_cache_attrs *cache_attrs)
> +{
> +	struct node_cache_info *info;
> +	struct device *dev;
> +	struct node *node;
> +
> +	if (!node_online(nid) || !node_devices[nid])
> +		return;
> +
> +	node = node_devices[nid];
> +	list_for_each_entry(info, &node->cache_attrs, node) {
> +		if (info->cache_attrs.level == cache_attrs->level) {
> +			dev_warn(&node->dev,
> +				"attempt to add duplicate cache level:%d\n",
> +				cache_attrs->level);
> +			return;
> +		}
> +	}
> +
> +	if (!node->cache_dev)
> +		node_init_cache_dev(node);
> +	if (!node->cache_dev)
> +		return;
> +
> +	info = kzalloc(sizeof(*info), GFP_KERNEL);
> +	if (!info)
> +		return;
> +
> +	dev = &info->dev;
> +	dev->parent = node->cache_dev;
> +	dev->release = node_cacheinfo_release;
> +	dev->groups = cache_groups;
> +	if (dev_set_name(dev, "index%d", cache_attrs->level))
> +		goto free_cache;
> +
> +	info->cache_attrs = *cache_attrs;
> +	if (device_register(dev)) {
> +		dev_warn(&node->dev, "failed to add cache level:%d\n",
> +			 cache_attrs->level);
> +		goto free_name;
> +	}
> +	pm_runtime_no_callbacks(dev);
> +	list_add_tail(&info->node, &node->cache_attrs);
> +	return;
> +free_name:
> +	kfree_const(dev->kobj.name);
> +free_cache:
> +	kfree(info);
> +}
> +
> +static void node_remove_caches(struct node *node)
> +{
> +	struct node_cache_info *info, *next;
> +
> +	if (!node->cache_dev)
> +		return;
> +
> +	list_for_each_entry_safe(info, next, &node->cache_attrs, node) {
> +		list_del(&info->node);
> +		device_unregister(&info->dev);
> +	}
> +	device_unregister(node->cache_dev);
> +}
> +
> +static void node_init_caches(unsigned int nid)
> +{
> +	INIT_LIST_HEAD(&node_devices[nid]->cache_attrs);
> +}
> +#else
> +static void node_init_caches(unsigned int nid) { }
> +static void node_remove_caches(struct node *node) { }
>  #endif
>  
>  #define K(x) ((x) << (PAGE_SHIFT - 10))
> @@ -475,6 +615,7 @@ void unregister_node(struct node *node)
>  {
>  	hugetlb_unregister_node(node);		/* no-op, if memoryless node */
>  	node_remove_classes(node);
> +	node_remove_caches(node);
>  	device_unregister(&node->dev);
>  }
>  
> @@ -755,6 +896,7 @@ int __register_one_node(int nid)
>  	INIT_LIST_HEAD(&node_devices[nid]->class_list);
>  	/* initialize work queue for memory hot plug */
>  	init_node_hugetlb_work(nid);
> +	node_init_caches(nid);
>  
>  	return error;
>  }
> diff --git a/include/linux/node.h b/include/linux/node.h
> index e22940a593c2..8cdf2b2808e4 100644
> --- a/include/linux/node.h
> +++ b/include/linux/node.h
> @@ -37,12 +37,47 @@ struct node_hmem_attrs {
>  };
>  void node_set_perf_attrs(unsigned int nid, struct node_hmem_attrs *hmem_attrs,
>  			 unsigned class);
> +
> +enum cache_associativity {
> +	NODE_CACHE_DIRECT_MAP,
> +	NODE_CACHE_INDEXED,
> +	NODE_CACHE_OTHER,
> +};
> +
> +enum cache_write_policy {
> +	NODE_CACHE_WRITE_BACK,
> +	NODE_CACHE_WRITE_THROUGH,
> +	NODE_CACHE_WRITE_OTHER,
> +};
> +
> +/**
> + * struct node_cache_attrs - system memory caching attributes
> + *
> + * @associativity:	The ways memory blocks may be placed in cache
> + * @write_policy:	Write back or write through policy
> + * @size:		Total size of cache in bytes
> + * @line_size:		Number of bytes fetched on a cache miss
> + * @level:		Represents the cache hierarchy level
> + */
> +struct node_cache_attrs {
> +	enum cache_associativity associativity;
> +	enum cache_write_policy write_policy;
> +	u64 size;
> +	u16 line_size;
> +	u8  level;
> +};
> +void node_add_cache(unsigned int nid, struct node_cache_attrs *cache_attrs);
>  #else
>  static inline void node_set_perf_attrs(unsigned int nid,
>  				       struct node_hmem_attrs *hmem_attrs,
>  				       unsigned class)
>  {
>  }
> +
> +static inline void node_add_cache(unsigned int nid,
> +				  struct node_cache_attrs *cache_attrs)
> +{
> +}
>  #endif
>  
>  struct node {
> @@ -51,6 +86,10 @@ struct node {
>  #if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_HUGETLBFS)
>  	struct work_struct	node_work;
>  #endif
> +#ifdef CONFIG_HMEM_REPORTING
> +	struct list_head cache_attrs;
> +	struct device *cache_dev;
> +#endif
>  };
>  
>  struct memory_block;

