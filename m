Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1655C0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 08:51:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B12082089C
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 08:51:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B12082089C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 478326B0003; Mon,  1 Jul 2019 04:51:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 429AC8E0003; Mon,  1 Jul 2019 04:51:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F27E8E0002; Mon,  1 Jul 2019 04:51:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f78.google.com (mail-ed1-f78.google.com [209.85.208.78])
	by kanga.kvack.org (Postfix) with ESMTP id D1B576B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 04:51:47 -0400 (EDT)
Received: by mail-ed1-f78.google.com with SMTP id l14so16299574edw.20
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 01:51:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=3BdUfVEd81dmHCcAfu9rxgP9k79ld0D+v1HXvg6zKYk=;
        b=rcqCcfPRtcl7nBVYJuy6bd+/4Y7CgnnDL8tjj4MAKlcX1yqBUDoUPtE20qKrvutQxN
         dba8cAFqdx2wEqTAjlKlGTkQMbd4JLh48Cj8dRo8+FyzHQ36oI0zhSuBfvOW/eYDP6YL
         rQsahtY5gqw6QQXzQPL51KFy0cJn6mdjqiMearRPhIA6yiix6ovtBlS7YZgAg2eqz09h
         /+6M2AFQPW7bUZsiRboq6Ngt/XObU14NAhcMFu4TTZj2iNcRje3T27/rYkP4pBHS5Td5
         5jKCAfg4fcu4RAmbucRKt3D6N3oo0WhqogqAEHisb4ptYi9B9K4CpWldL4J6FWJMZtfI
         ja3g==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAX0scU7RUuKF+cKiIBqD+RKX1CilkWgnQEKIUQpswXWHCGgDb87
	rTxl2z+ipm9qMEsvW9aixWNg+V7t5OOWI1VgR4PwycY1eLxpMIfxs39EAVoWA7hGGRCAIRg08ji
	2pFuZft51z+gMErAucCEttwUOyW1BuYMzvGd56e+YabiMt5t9K9JiuD/hWWj3TiY=
X-Received: by 2002:a17:906:8053:: with SMTP id x19mr21931408ejw.306.1561971107416;
        Mon, 01 Jul 2019 01:51:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxtide12y7RmP/hwqfxEbB4Tq2e2Grk3Ccv5B5bliXqt8uo8kHhmaDqxuv1YUKX0JlEI6X6
X-Received: by 2002:a17:906:8053:: with SMTP id x19mr21931363ejw.306.1561971106582;
        Mon, 01 Jul 2019 01:51:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561971106; cv=none;
        d=google.com; s=arc-20160816;
        b=GNs675GrAOWQiBOOHPW43nGohRUEDA//qzxv7+mnlOo0ttPhVRDJJ/CShqAxepOCrn
         pjjNc/PS9unh5HAxzbxdmVpDgrbhbTUkwbbGphGPWXMYFP7yqJ8IDwuM8d5v5AkFzNZj
         A1uxHA6pWZ+Xc58ae/P02SCimyR3Zqy7HEgx+CLdyes/j4ud6bpLV8+OUTdkpNtaVCon
         dtvmCGtF6csm4hKalAyVI2Q9KAfoSHAST3CDKM5OORj2irxT74EyhZgrpxF62L0kvDu4
         /TgUSUgCGzy0NRQz7grTru2hOLcKP4jRCSQ6CJ+0cjiGSpi3S1KHsqEdCTPwmZqQSFWd
         5AWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=3BdUfVEd81dmHCcAfu9rxgP9k79ld0D+v1HXvg6zKYk=;
        b=t+YgupMprFXYc8T3yyvnTFRGIjnOwIw1dPpiiKARKBIij9odQBeTiq1xIsqyP9s1F7
         zB/XbVB+hGHLFY4ADK9td/+Nj4MQ0zxajThCD3KabhKa4qvLr+A43J/6RiG/CPgygAA3
         97wyFDn2L9FGqJJAaM7RsZE3cCCwR9FCgUdhqHaXb6Shj2CpGqee49J9lgnPlxwwsAOK
         p47M3Fk84Tw/Nbl4SzBbekOu311rbeKW/UtH1YZ5GSdT/PIxQvDXSmkxL5/Sdu1YXJ4m
         UpeG9EvlW4CRkLJmrlFwcPb5hvHPaXewSel3qc0gm2WwX4L7zZWCc2uI0LrTkjKidGBy
         dHwA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q36si8886926edd.153.2019.07.01.01.51.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 01:51:46 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 6455EAD23;
	Mon,  1 Jul 2019 08:51:45 +0000 (UTC)
Date: Mon, 1 Jul 2019 10:51:44 +0200
From: Michal Hocko <mhocko@kernel.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Alex Deucher <alexander.deucher@amd.com>,
	"David S. Miller" <davem@davemloft.net>,
	Mark Brown <broonie@kernel.org>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	Oscar Salvador <osalvador@suse.de>,
	Jonathan Cameron <Jonathan.Cameron@huawei.com>
Subject: Re: [PATCH v3 10/11] mm/memory_hotplug: Make
 unregister_memory_block_under_nodes() never fail
Message-ID: <20190701085144.GJ6376@dhcp22.suse.cz>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-11-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527111152.16324-11-david@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 27-05-19 13:11:51, David Hildenbrand wrote:
> We really don't want anything during memory hotunplug to fail.
> We always pass a valid memory block device, that check can go. Avoid
> allocating memory and eventually failing. As we are always called under
> lock, we can use a static piece of memory. This avoids having to put
> the structure onto the stack, having to guess about the stack size
> of callers.
> 
> Patch inspired by a patch from Oscar Salvador.
> 
> In the future, there might be no need to iterate over nodes at all.
> mem->nid should tell us exactly what to remove. Memory block devices
> with mixed nodes (added during boot) should properly fenced off and never
> removed.

Yeah, we do not allow to offline multi zone (node) ranges so the current
code seems to be over engineered.

Anyway, I am wondering why do we have to strictly check for already
removed nodes links. Is the sysfs code going to complain we we try to
remove again?
 
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: "Rafael J. Wysocki" <rafael@kernel.org>
> Cc: Alex Deucher <alexander.deucher@amd.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Mark Brown <broonie@kernel.org>
> Cc: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: David Hildenbrand <david@redhat.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>

Anyway
Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  drivers/base/node.c  | 18 +++++-------------
>  include/linux/node.h |  5 ++---
>  2 files changed, 7 insertions(+), 16 deletions(-)
> 
> diff --git a/drivers/base/node.c b/drivers/base/node.c
> index 04fdfa99b8bc..9be88fd05147 100644
> --- a/drivers/base/node.c
> +++ b/drivers/base/node.c
> @@ -803,20 +803,14 @@ int register_mem_sect_under_node(struct memory_block *mem_blk, void *arg)
>  
>  /*
>   * Unregister memory block device under all nodes that it spans.
> + * Has to be called with mem_sysfs_mutex held (due to unlinked_nodes).
>   */
> -int unregister_memory_block_under_nodes(struct memory_block *mem_blk)
> +void unregister_memory_block_under_nodes(struct memory_block *mem_blk)
>  {
> -	NODEMASK_ALLOC(nodemask_t, unlinked_nodes, GFP_KERNEL);
>  	unsigned long pfn, sect_start_pfn, sect_end_pfn;
> +	static nodemask_t unlinked_nodes;
>  
> -	if (!mem_blk) {
> -		NODEMASK_FREE(unlinked_nodes);
> -		return -EFAULT;
> -	}
> -	if (!unlinked_nodes)
> -		return -ENOMEM;
> -	nodes_clear(*unlinked_nodes);
> -
> +	nodes_clear(unlinked_nodes);
>  	sect_start_pfn = section_nr_to_pfn(mem_blk->start_section_nr);
>  	sect_end_pfn = section_nr_to_pfn(mem_blk->end_section_nr);
>  	for (pfn = sect_start_pfn; pfn <= sect_end_pfn; pfn++) {
> @@ -827,15 +821,13 @@ int unregister_memory_block_under_nodes(struct memory_block *mem_blk)
>  			continue;
>  		if (!node_online(nid))
>  			continue;
> -		if (node_test_and_set(nid, *unlinked_nodes))
> +		if (node_test_and_set(nid, unlinked_nodes))
>  			continue;
>  		sysfs_remove_link(&node_devices[nid]->dev.kobj,
>  			 kobject_name(&mem_blk->dev.kobj));
>  		sysfs_remove_link(&mem_blk->dev.kobj,
>  			 kobject_name(&node_devices[nid]->dev.kobj));
>  	}
> -	NODEMASK_FREE(unlinked_nodes);
> -	return 0;
>  }
>  
>  int link_mem_sections(int nid, unsigned long start_pfn, unsigned long end_pfn)
> diff --git a/include/linux/node.h b/include/linux/node.h
> index 02a29e71b175..548c226966a2 100644
> --- a/include/linux/node.h
> +++ b/include/linux/node.h
> @@ -139,7 +139,7 @@ extern int register_cpu_under_node(unsigned int cpu, unsigned int nid);
>  extern int unregister_cpu_under_node(unsigned int cpu, unsigned int nid);
>  extern int register_mem_sect_under_node(struct memory_block *mem_blk,
>  						void *arg);
> -extern int unregister_memory_block_under_nodes(struct memory_block *mem_blk);
> +extern void unregister_memory_block_under_nodes(struct memory_block *mem_blk);
>  
>  extern int register_memory_node_under_compute_node(unsigned int mem_nid,
>  						   unsigned int cpu_nid,
> @@ -175,9 +175,8 @@ static inline int register_mem_sect_under_node(struct memory_block *mem_blk,
>  {
>  	return 0;
>  }
> -static inline int unregister_memory_block_under_nodes(struct memory_block *mem_blk)
> +static inline void unregister_memory_block_under_nodes(struct memory_block *mem_blk)
>  {
> -	return 0;
>  }
>  
>  static inline void register_hugetlbfs_with_node(node_registration_func_t reg,
> -- 
> 2.20.1

-- 
Michal Hocko
SUSE Labs

