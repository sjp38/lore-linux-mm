Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9CC7C282E1
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 08:09:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92D69217D7
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 08:09:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92D69217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40E296B0005; Thu, 25 Apr 2019 04:09:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 395176B0006; Thu, 25 Apr 2019 04:09:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2374C6B0007; Thu, 25 Apr 2019 04:09:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BE46F6B0005
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 04:09:39 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id f42so11251647edd.0
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 01:09:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=7gkg/7Xeis9rc+EVTWp9bsr+pgBSXPMB56OaXhmvYhM=;
        b=q43XyXrggGe1HG+6xy1JMUe0ziXSevNgyOwaS1HTuvlIm9QXCit2kiD44M6XRcbarN
         8uHkXL9SXOwReC8L6Tv8S4AWcxnMTzS9lAIjDizuw9yPxNtQMw+BOLEBmyOFILaIh4e1
         H4i/Y242CBDejDMjWz+LKnpd6qgzsu57WO+qLZ1kuU8wdBjWFStH48NApc8Fa/LLctmp
         b9ibnBo3W/U7M/S7r/RCXTAgL0b2qsnNwPG5ns6PZ8ZvUnweaKn97IbL8Ld4sSsQze0p
         ABeNMxa7Ze1FNb4qqGI4Ta5pg5Xiqr8Ujh4qgCsaJgpx7bzi+WcfCUlr/lD7QJEa8Fj4
         W0kQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAUOgVYdMlMPia20PYW1b7vZB/yLpeOwaSkpVhCbCfFezKm7ekKz
	eE+AOupZIjpkncnFoe0Sdw2rq1bd2qLhAP6LzM4e24kwSdXBSXdAnqJfk9V8HGsgwnNEPUjCgtC
	mtM78Lw6l9iAAaX6c+1ouKwi2WI0uihnmFcOR9RfrPA/XRMiumLEe1/F+9davfNA=
X-Received: by 2002:a05:6402:6d9:: with SMTP id n25mr23504419edy.288.1556179779136;
        Thu, 25 Apr 2019 01:09:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9QqGyixH9/+301Z5d2KtV9WhyKaMjBYQzJrLVN9Ew/TdKOiCpjUlBvWKv2lFVuRYprVGm
X-Received: by 2002:a05:6402:6d9:: with SMTP id n25mr23504385edy.288.1556179778376;
        Thu, 25 Apr 2019 01:09:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556179778; cv=none;
        d=google.com; s=arc-20160816;
        b=JW9jPnt6uTN8W7o6d+xgRt6gi/kjJ4oGQ1yTB5vELPS3b7Up9mm3RMNrYy/3ttEEgK
         cS8h526eZVAUuViUR+O/AIzSp2GqToC8gnq8bjoCSQrSUW53uhKgkc+q0tkXBYpD2w2S
         hwJxVGmJBc3jxC/LyOgJvmpi8fkiyXdQEoqDSyA0Iq1kkvJJRA8/ujNV5YWr0xZ0Msfz
         ZalqGZ+sjgcw9egrBZ9AZ4AOijbBPwjI0Rrk8TJoqGXyspVDBOdanSGo/LpmmsarCTJW
         ufbOXPDoHBhjM22Gdt/biR30IwR1utxCzg8pTSUgjtvqZs8SZBQy/Yrdt7dbMwZWdP5v
         gKIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=7gkg/7Xeis9rc+EVTWp9bsr+pgBSXPMB56OaXhmvYhM=;
        b=ZQI6tyvi6m+FGsMYgCVUfXLmXCeGSy4JmMCkrIlOSt/6pCJZ8gX2nYPmabvkxFySsm
         4dPJp52TDM0d5NVsZLUkPSNvP2C6SgW/tkG9VRkyFZgqq+WIn19nPxzs7xj4UMAPNb30
         thMfBHQ9fTFG304F51ZMOHWEcYTwOQlyeOEqqOKlsLO8oL0HzZBRy7KoBkyjFkhBbaOD
         S0YtHIZc360Cs7zPI+ez1c5ArxVfIQtZJF8+sq2FYZ9Cxjr4SpP8RculXV9xOwSKPg1l
         mKG5WQp0SyHOuVJn80xXv9CEMWw8dMP/LLJmzhxVMjmUFuTskjp0RrIer9JJt7RAv3OM
         KKRw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s6si2947449eju.160.2019.04.25.01.09.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 01:09:38 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8E5FCAF58;
	Thu, 25 Apr 2019 08:09:37 +0000 (UTC)
Date: Thu, 25 Apr 2019 10:09:36 +0200
From: Michal Hocko <mhocko@kernel.org>
To: "Du, Fan" <fan.du@intel.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"Wu, Fengguang" <fengguang.wu@intel.com>,
	"Williams, Dan J" <dan.j.williams@intel.com>,
	"Hansen, Dave" <dave.hansen@intel.com>,
	"xishi.qiuxishi@alibaba-inc.com" <xishi.qiuxishi@alibaba-inc.com>,
	"Huang, Ying" <ying.huang@intel.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [RFC PATCH 5/5] mm, page_alloc: Introduce
 ZONELIST_FALLBACK_SAME_TYPE fallback list
Message-ID: <20190425080936.GP12751@dhcp22.suse.cz>
References: <1556155295-77723-1-git-send-email-fan.du@intel.com>
 <1556155295-77723-6-git-send-email-fan.du@intel.com>
 <20190425063807.GK12751@dhcp22.suse.cz>
 <5A90DA2E42F8AE43BC4A093BF067884825785F04@SHSMSX104.ccr.corp.intel.com>
 <20190425074841.GN12751@dhcp22.suse.cz>
 <5A90DA2E42F8AE43BC4A093BF067884825785F50@SHSMSX104.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5A90DA2E42F8AE43BC4A093BF067884825785F50@SHSMSX104.ccr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 25-04-19 07:55:58, Du, Fan wrote:
> >> PMEM is good for frequently read accessed page, e.g. page cache(implicit
> >> page
> >> request), or user space data base (explicit page request)
> >> For now this patch create GFP_SAME_NODE_TYPE for such cases, additional
> >> Implementation will be followed up.
> >
> >Then simply configure that NUMA node as movable and you get these
> >allocations for any movable allocation. I am not really convinced a new
> >gfp flag is really justified.
> 
> Case 1: frequently write and/or read accessed page deserved to DRAM

NUMA balancing

> Case 2: frequently read accessed page deserved to PMEM

memory reclaim to move those pages to a more distant node (e.g. a PMEM).

Btw. none of the above is a static thing you would easily know at the
allocation time.

Please spare some time reading surrounding discussions - e.g.
http://lkml.kernel.org/r/1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com
-- 
Michal Hocko
SUSE Labs

