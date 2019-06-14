Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9706DC31E4A
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:20:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 56E4A21537
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 00:20:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56E4A21537
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F1DBD6B000D; Thu, 13 Jun 2019 20:20:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ECF5A6B000E; Thu, 13 Jun 2019 20:20:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D96906B0266; Thu, 13 Jun 2019 20:20:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id A52366B000D
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 20:20:57 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id n1so518668plk.11
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 17:20:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=9GRYlXivdEr74K/wndUGJ2qTpEbl/sqkOSmfbHR27ZI=;
        b=ZORiqkW4HUduMxhR1N2PSTaYk1SebbbtsrQ2chKxxKbLQCeWW31uvUynMCpbN1KK0m
         IiW77urJ+P5KnKH6UKNJ2uVOqvGadpW2VcE1DSmXhuBO+MlGi5yvg2dGUw3weRfSAk7i
         SjBnn0bPGoLPstQa0F/ZZDdmqN//J+bYINtQvaJXr/nnEonX+er7nhNCq1OxlzCunHse
         Z2qG/R8BNVC5aIBrhP2J8PWaraxEQtFldpKVakS07bfyohZUrY9q+tYXnBSEbHsyxYFO
         Dc+D1FaLr/L5UnSNOzNCahzaEH+pv5VNytZPOFmRSt9P5hwhFIWyGlF7pqFkuBAxhZ7E
         4/mA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXwClc+UXF4reGa6c0I+R5RTGdOGxlYRaBiJl0BKIHvl/6kDEVb
	swQgXoD/cH8iR0IsMqjyTbIJdDYvSp/dqR/KzdZ+0lb5euJcQnhUnHlqH3PDm3lLqRvVrtPYjuK
	jpOzWheBKTmJx27g0iufThXM7P8zL0bgvusp5kllVAIvorD4sGq2U5FDyQi2ge7zzTA==
X-Received: by 2002:a62:4d04:: with SMTP id a4mr95444540pfb.177.1560471657332;
        Thu, 13 Jun 2019 17:20:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyCndVxd34J/dOqc3vb38qHEDJtb7wwcU6BGHzka6bQOEQJgfOazqjZ8Qs99oP6sZCYevrW
X-Received: by 2002:a62:4d04:: with SMTP id a4mr95444510pfb.177.1560471656588;
        Thu, 13 Jun 2019 17:20:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560471656; cv=none;
        d=google.com; s=arc-20160816;
        b=VcJpVawoY8SBoAWKHSzVrHj7EzquYU7fgTln3g4Yyg4sQI6+HD+auy2nAt18o48LjX
         Ul3LYNHo3PNsGwNVlqOmcJk6U9oBC/a63UCCXmPSr75bObK+W6wfUax2R0JVjsj5tgSm
         RCFEHZe5Fbp3dutFGQuEgEPqIA6obyzNXSvnSm3hEeEA7y7IeE+hJSr+mwEf6yvOJ1vH
         CsYyxzfX0bb3poUHWTYuPjzMSiOdbupVpQckqhq9NnbqY5ADT9ydP5u9Pa2ozbJN6MND
         tIfvWCqnu6cffgbB3kzLZonKVXFgSYRteUgRxjXzbRDhxadACBMFnLDXtxjJMpsLRs0T
         alUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=9GRYlXivdEr74K/wndUGJ2qTpEbl/sqkOSmfbHR27ZI=;
        b=Ql2ofpaIHw91CJJ5gN+Vp0re8YjL/JN3iQsGo7D/5FpTZOYDEAytcZpCrjTVVMIcrV
         pGgCwX366/3zRJ5U64/N4oXjipXweXLQqo+Tr422nei2f6hDBFuJ01mwcbyZu5vwrG0U
         MDtRHSJJXu9NaYgo2f+ICXVSBZ/d53zM/E2DdOa2qJsbLjCDV1un7O0J91tB6DaLNAAS
         Kf6kaBgLKQoPrRfWz8EVShAF0PlY5fSrKikckKHAJnuPM1kbAsOaouavni5TJsgk1IPa
         PFDS9Fv3WfWNFizbTzlyz7Sz68sjpTE01gigF/IfPdIP2wdeqL1XK6cBg2MpHi58wvJk
         /PSw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id b7si875921pfp.4.2019.06.13.17.20.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 17:20:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) client-ip=134.134.136.126;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 134.134.136.126 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga106.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Jun 2019 17:20:56 -0700
X-ExtLoop1: 1
Received: from iweiny-desk2.sc.intel.com ([10.3.52.157])
  by FMSMGA003.fm.intel.com with ESMTP; 13 Jun 2019 17:20:55 -0700
Date: Thu, 13 Jun 2019 17:22:17 -0700
From: Ira Weiny <ira.weiny@intel.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	linux-nvdimm@lists.01.org, linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, nouveau@lists.freedesktop.org
Subject: Re: [PATCH 13/22] device-dax: use the dev_pagemap internal refcount
Message-ID: <20190614002217.GB783@iweiny-DESK2.sc.intel.com>
References: <20190613094326.24093-1-hch@lst.de>
 <20190613094326.24093-14-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190613094326.24093-14-hch@lst.de>
User-Agent: Mutt/1.11.1 (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 13, 2019 at 11:43:16AM +0200, Christoph Hellwig wrote:
> The functionality is identical to the one currently open coded in
> device-dax.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  drivers/dax/dax-private.h |  4 ---
>  drivers/dax/device.c      | 52 +--------------------------------------
>  2 files changed, 1 insertion(+), 55 deletions(-)
> 
> diff --git a/drivers/dax/dax-private.h b/drivers/dax/dax-private.h
> index a45612148ca0..ed04a18a35be 100644
> --- a/drivers/dax/dax-private.h
> +++ b/drivers/dax/dax-private.h
> @@ -51,8 +51,6 @@ struct dax_region {
>   * @target_node: effective numa node if dev_dax memory range is onlined
>   * @dev - device core
>   * @pgmap - pgmap for memmap setup / lifetime (driver owned)
> - * @ref: pgmap reference count (driver owned)
> - * @cmp: @ref final put completion (driver owned)
>   */
>  struct dev_dax {
>  	struct dax_region *region;
> @@ -60,8 +58,6 @@ struct dev_dax {
>  	int target_node;
>  	struct device dev;
>  	struct dev_pagemap pgmap;
> -	struct percpu_ref ref;
> -	struct completion cmp;
>  };
>  
>  static inline struct dev_dax *to_dev_dax(struct device *dev)
> diff --git a/drivers/dax/device.c b/drivers/dax/device.c
> index e23fa1bd8c97..a9d7c90ecf1e 100644
> --- a/drivers/dax/device.c
> +++ b/drivers/dax/device.c
> @@ -14,37 +14,6 @@
>  #include "dax-private.h"
>  #include "bus.h"
>  
> -static struct dev_dax *ref_to_dev_dax(struct percpu_ref *ref)
> -{
> -	return container_of(ref, struct dev_dax, ref);
> -}
> -
> -static void dev_dax_percpu_release(struct percpu_ref *ref)
> -{
> -	struct dev_dax *dev_dax = ref_to_dev_dax(ref);
> -
> -	dev_dbg(&dev_dax->dev, "%s\n", __func__);
> -	complete(&dev_dax->cmp);
> -}
> -
> -static void dev_dax_percpu_exit(void *data)
> -{
> -	struct percpu_ref *ref = data;
> -	struct dev_dax *dev_dax = ref_to_dev_dax(ref);
> -
> -	dev_dbg(&dev_dax->dev, "%s\n", __func__);
> -	wait_for_completion(&dev_dax->cmp);
> -	percpu_ref_exit(ref);
> -}
> -
> -static void dev_dax_percpu_kill(struct dev_pagemap *pgmap)
> -{
> -	struct dev_dax *dev_dax = container_of(pgmap, struct dev_dax, pgmap);
> -
> -	dev_dbg(&dev_dax->dev, "%s\n", __func__);
> -	percpu_ref_kill(pgmap->ref);
> -}
> -
>  static int check_vma(struct dev_dax *dev_dax, struct vm_area_struct *vma,
>  		const char *func)
>  {
> @@ -442,10 +411,6 @@ static void dev_dax_kill(void *dev_dax)
>  	kill_dev_dax(dev_dax);
>  }
>  
> -static const struct dev_pagemap_ops dev_dax_pagemap_ops = {
> -	.kill		= dev_dax_percpu_kill,
> -};
> -
>  int dev_dax_probe(struct device *dev)
>  {
>  	struct dev_dax *dev_dax = to_dev_dax(dev);
> @@ -463,24 +428,9 @@ int dev_dax_probe(struct device *dev)
>  		return -EBUSY;
>  	}
>  
> -	init_completion(&dev_dax->cmp);
> -	rc = percpu_ref_init(&dev_dax->ref, dev_dax_percpu_release, 0,
> -			GFP_KERNEL);
> -	if (rc)
> -		return rc;
> -
> -	rc = devm_add_action_or_reset(dev, dev_dax_percpu_exit, &dev_dax->ref);
> -	if (rc)
> -		return rc;
> -
> -	dev_dax->pgmap.ref = &dev_dax->ref;

I don't think this exactly correct.  pgmap.ref is a pointer to the dev_dax ref
structure.  Taking it away will cause devm_memremap_pages() to fail AFAICS.

I think you need to change struct dev_pagemap as well:

diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index f0628660d541..5e2120589ddf 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -90,7 +90,7 @@ struct dev_pagemap {
        struct vmem_altmap altmap;
        bool altmap_valid;
        struct resource res;
-       struct percpu_ref *ref;
+       struct percpu_ref ref;
        void (*kill)(struct percpu_ref *ref);
        struct device *dev;
        void *data;

And all usages of it, right?

Ira

> -	dev_dax->pgmap.ops = &dev_dax_pagemap_ops;
>  	addr = devm_memremap_pages(dev, &dev_dax->pgmap);
> -	if (IS_ERR(addr)) {
> -		devm_remove_action(dev, dev_dax_percpu_exit, &dev_dax->ref);
> -		percpu_ref_exit(&dev_dax->ref);
> +	if (IS_ERR(addr))
>  		return PTR_ERR(addr);
> -	}
>  
>  	inode = dax_inode(dax_dev);
>  	cdev = inode->i_cdev;
> -- 
> 2.20.1
> 
> _______________________________________________
> Linux-nvdimm mailing list
> Linux-nvdimm@lists.01.org
> https://lists.01.org/mailman/listinfo/linux-nvdimm

