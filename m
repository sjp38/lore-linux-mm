Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA801C10F03
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 07:48:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A673217D7
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 07:48:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A673217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 494BE6B000C; Thu, 25 Apr 2019 03:48:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 441096B000D; Thu, 25 Apr 2019 03:48:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 30A0B6B000E; Thu, 25 Apr 2019 03:48:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CF8056B000C
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 03:48:43 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id e22so11220522edd.9
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 00:48:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=vlwgYT+kNZGNtlhgcPt6OaoKxXU+/F17Asts9ky7DrU=;
        b=hdNmDGKhlO5jD6xSfsgm5K/sC79AyoLTBjdj9yCRC3sEbV88lXQVGO/0LTfmsLWnD5
         PjwO7UNbUzDZKGadDpd1iC/or20+i+7h0cCcZmhwEuwGlbtOJT9Fr/nnltxB+GKIy22T
         dlRIDItAz9xBJvJ18yqnk8J6yi+iY158YHuuJmpw1UkEBl+lHfbngvyDbGueOMhiarRP
         v5Z5s0NzWc/RLZ2ztQfSSXn44jajf6HPoRLpP7jHJBvo2EGoDIPQ8MdX4ATSmjRJUE/J
         0E+XMTzX1YoEJrc7LWxlcLaF7hIFhcCDhblP8nX07iQsW2txi/PDtuvmC0XkP1UBAKhA
         DjeA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWV6rTKrKim5LSQv0rcfQsoGWXLnujgp4cg19QkptwiuO+yYMP+
	hUY3LOcrAMkh82zJ916lUJEI6FiooSoqgqwfwxeXCac1epd8JZZ7r8vbrgsc7w8g8aCw6ne6VII
	fxT9XvL7u8mTDwZYPHSkLE/0SWPW+6SZb3UKRkPdFYuZLf/ISNfkqV3+lMd1n3IY=
X-Received: by 2002:a17:906:3e91:: with SMTP id a17mr18815289ejj.73.1556178523395;
        Thu, 25 Apr 2019 00:48:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzcbCal2/EwsfwLGLG/2uXE7qYo8K5rzLHIx5rmLy2JJJAEoZLrKGlnbKPolkoe4RWrLU/E
X-Received: by 2002:a17:906:3e91:: with SMTP id a17mr18815265ejj.73.1556178522668;
        Thu, 25 Apr 2019 00:48:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556178522; cv=none;
        d=google.com; s=arc-20160816;
        b=E5fLXB2CwrL0aaPBInY72xRpXVOx4cohaSEaH0A/CvU6JBrMy1NrPJhNk7K8V9MT2K
         DuFyV31+i5A5ymU5AW0O27Wn3Wi1M9WQB6pV8zwX074vrewzMMrUlRxiIO7VFeYv/sTv
         DtcJiSEGN8zIFsu6Zpz5xSKcnAsG6uu2y0SHVQm6z9thgvOAqLVyATD5/IqkzEDGEiIQ
         ckWrPkIVe54Cazmtrzmhjh+ki63sFiFWE26MkldoelseTG31hSWeBzCvEjqaIkKgAVej
         sJZqLEHxka5QPWP1uDLVo0vIq4Hqjz3GcuK4itcIjlwo2inGDGi0hMMOmkGSRg2rSO2x
         7QbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=vlwgYT+kNZGNtlhgcPt6OaoKxXU+/F17Asts9ky7DrU=;
        b=fU0Vc+ay4EEH7FNuiwmOfp6/jdlS+oUal7ud6uWEJ5PjJa3qIlcVhaFCqP9JpHOopK
         M5YSUmeeLiK2O7GylyVyV1a7tponyjBrpVRlNEm5meRqj3VpzwfXhI/u8ch8mOXIHcN/
         6iUap05GJk8N3HSWDpQMVIEKAaGu3ndByIrDecghr5DGxPaCNp4TeiWmLSNuHfMP1lcI
         Xs6wgc1DvYgVM+nYLu2fb1y5h9fbQCoHXg+AXmALce4OVbLUaUCQiE8I7uWqU0HlDDnJ
         wsHrz5SR/I9EfcmKHGPtLozP2ZH/biV4WRIHWPTYJKW3OEGIxxtgT+weO90CVj2lkT3q
         REYg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g5si1043192eje.144.2019.04.25.00.48.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 00:48:42 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 23A2AAF60;
	Thu, 25 Apr 2019 07:48:42 +0000 (UTC)
Date: Thu, 25 Apr 2019 09:48:41 +0200
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
Message-ID: <20190425074841.GN12751@dhcp22.suse.cz>
References: <1556155295-77723-1-git-send-email-fan.du@intel.com>
 <1556155295-77723-6-git-send-email-fan.du@intel.com>
 <20190425063807.GK12751@dhcp22.suse.cz>
 <5A90DA2E42F8AE43BC4A093BF067884825785F04@SHSMSX104.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5A90DA2E42F8AE43BC4A093BF067884825785F04@SHSMSX104.ccr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 25-04-19 07:43:09, Du, Fan wrote:
> 
> 
> >-----Original Message-----
> >From: Michal Hocko [mailto:mhocko@kernel.org]
> >Sent: Thursday, April 25, 2019 2:38 PM
> >To: Du, Fan <fan.du@intel.com>
> >Cc: akpm@linux-foundation.org; Wu, Fengguang <fengguang.wu@intel.com>;
> >Williams, Dan J <dan.j.williams@intel.com>; Hansen, Dave
> ><dave.hansen@intel.com>; xishi.qiuxishi@alibaba-inc.com; Huang, Ying
> ><ying.huang@intel.com>; linux-mm@kvack.org; linux-kernel@vger.kernel.org
> >Subject: Re: [RFC PATCH 5/5] mm, page_alloc: Introduce
> >ZONELIST_FALLBACK_SAME_TYPE fallback list
> >
> >On Thu 25-04-19 09:21:35, Fan Du wrote:
> >> On system with heterogeneous memory, reasonable fall back lists woul be:
> >> a. No fall back, stick to current running node.
> >> b. Fall back to other nodes of the same type or different type
> >>    e.g. DRAM node 0 -> DRAM node 1 -> PMEM node 2 -> PMEM node 3
> >> c. Fall back to other nodes of the same type only.
> >>    e.g. DRAM node 0 -> DRAM node 1
> >>
> >> a. is already in place, previous patch implement b. providing way to
> >> satisfy memory request as best effort by default. And this patch of
> >> writing build c. to fallback to the same node type when user specify
> >> GFP_SAME_NODE_TYPE only.
> >
> >So an immediate question which should be answered by this changelog. Who
> >is going to use the new gfp flag? Why cannot all allocations without an
> >explicit numa policy fallback to all existing nodes?
> 
> PMEM is good for frequently read accessed page, e.g. page cache(implicit page
> request), or user space data base (explicit page request)
> For now this patch create GFP_SAME_NODE_TYPE for such cases, additional
> Implementation will be followed up.

Then simply configure that NUMA node as movable and you get these
allocations for any movable allocation. I am not really convinced a new
gfp flag is really justified.
-- 
Michal Hocko
SUSE Labs

