Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66844C10F03
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 07:53:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 139B9217D7
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 07:53:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 139B9217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 923896B000A; Thu, 25 Apr 2019 03:53:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D1106B000C; Thu, 25 Apr 2019 03:53:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 798D96B000D; Thu, 25 Apr 2019 03:53:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 269266B000A
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 03:53:56 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f41so272932ede.1
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 00:53:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=fL2qqlWSLrmSIKAQesaWTIjh48Stn5l7NGtIShgdXME=;
        b=gaTFGTwRf9ggtXmKE8y/r7MhH34oQ7SRmZh90fXlwVT2VaPci4ATYBHfW3T2sMfaS6
         BkCs2E4KOOWXRDfP02pzqwveh/eMOHhjrn4aytyJbZoxNYFSdNxkQ7clcwgatjLyUEn7
         In1ipDpc049aj7GIPA2ohOC7OVDm2RcKNkZDhfFA7mGsA9X3+c0Hd/wL1tN7z6JxYiAY
         5RiPmG/aijzEQjR8iKSo4cgKBJKF2t2G7Q61+Gl2choX24pwrDQhm7x9koUjNhOXYMwX
         EANGnpobkvpxtDCZUtzt/S/vakDiDdaaYeRAKFEgShWDmo1BALhqQ6hSVsDNmEyh929h
         jcVw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVsomoejaFxql8tmJLr5o9ZBTiUD3Riwolgg5/fxbUErXeNcid/
	0v9tlr0xAng2nVsVob3y3Ut0H3HB2OExNhGReonx9Vvn54ERkzVmhJOPKQ5f/DwA5PQUbtc74Vq
	ejrzg7YTvMXrl1NNbd/JreYVsgaMh6qyH5AWMRigCcUalfGrhfv7pawfiLLlXj8U=
X-Received: by 2002:a17:906:29c1:: with SMTP id y1mr17932586eje.251.1556178835648;
        Thu, 25 Apr 2019 00:53:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxwii+GrRgQs4daiuIj9oUJIXgRRGuiTUQrZlOC+b0h+HkwPsp3pAhOUp9Er+xx6LM/Z7p3
X-Received: by 2002:a17:906:29c1:: with SMTP id y1mr17932557eje.251.1556178834863;
        Thu, 25 Apr 2019 00:53:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556178834; cv=none;
        d=google.com; s=arc-20160816;
        b=nMvpTI9h7SOBBwd949Bf699OPz/LkQyzjHR1FQQH67jmdcUGsc9iCaFbEjTfwQSyeG
         vCIJC9OP5QIh5OFwB1gBEZikq2vH0dqID6gJiUiieQvPqYbs7Iv0m9qwpfqnXJnT/9v5
         a+es3zCJOd6n8hrX/dk+ob/YD6XFF87po63YiPF75Te79HKk9hJ8ApgyFM7i+QoyBQjw
         HjU27nXR4/ZBNer/udT25+9opKK2qSlUiFPkBzmq18JB8eJLsKIqRc4idUzGvjIclf5Z
         yXLahxIN6EdqvpcJB3zmUREh1zAY1vuGAR22q1zl6kqJQOVXya6QNePQODZI7UYCcPVv
         Vsfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=fL2qqlWSLrmSIKAQesaWTIjh48Stn5l7NGtIShgdXME=;
        b=QBwEcx6C7maCNhp2uFDtGp86sU/N/YJAbuY1lL3I++Fq8Upa0JNDwkOc8ElNGFDP2D
         j0ZbHHMs8R4gKUywcSHULWAroIqg3IAi+qikptkYjjYxX1Q0rwowdhC8reH0XiCPHKeM
         XcLmcZehXVB03zC5jYd4yEKxIkCkASSfopghtArAIzjjjP60NQkcYn1zWJCRDSa9W4Wu
         r4yt0mYU2DAZmyUo3xEbSu+lVETN8uKBDAcZ3KpUu7ayV7oGFpxWsLw89vSniKx4/3hD
         QPHmNTyz1UW3j9B6vttsvgIPGdhmTMwQDITJheaX7dazppPoEQHEsxfS5HIZ8WZgG+yw
         L02w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d9si3241027edq.270.2019.04.25.00.53.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 00:53:54 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 66B4DAD7B;
	Thu, 25 Apr 2019 07:53:54 +0000 (UTC)
Date: Thu, 25 Apr 2019 09:53:53 +0200
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
Subject: Re: [RFC PATCH 0/5] New fallback workflow for heterogeneous memory
 system
Message-ID: <20190425075353.GO12751@dhcp22.suse.cz>
References: <1556155295-77723-1-git-send-email-fan.du@intel.com>
 <20190425063727.GJ12751@dhcp22.suse.cz>
 <5A90DA2E42F8AE43BC4A093BF067884825785EE8@SHSMSX104.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5A90DA2E42F8AE43BC4A093BF067884825785EE8@SHSMSX104.ccr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 25-04-19 07:41:40, Du, Fan wrote:
> 
> 
> >-----Original Message-----
> >From: Michal Hocko [mailto:mhocko@kernel.org]
> >Sent: Thursday, April 25, 2019 2:37 PM
> >To: Du, Fan <fan.du@intel.com>
> >Cc: akpm@linux-foundation.org; Wu, Fengguang <fengguang.wu@intel.com>;
> >Williams, Dan J <dan.j.williams@intel.com>; Hansen, Dave
> ><dave.hansen@intel.com>; xishi.qiuxishi@alibaba-inc.com; Huang, Ying
> ><ying.huang@intel.com>; linux-mm@kvack.org; linux-kernel@vger.kernel.org
> >Subject: Re: [RFC PATCH 0/5] New fallback workflow for heterogeneous
> >memory system
> >
> >On Thu 25-04-19 09:21:30, Fan Du wrote:
> >[...]
> >> However PMEM has different characteristics from DRAM,
> >> the more reasonable or desirable fallback style would be:
> >> DRAM node 0 -> DRAM node 1 -> PMEM node 2 -> PMEM node 3.
> >> When DRAM is exhausted, try PMEM then.
> >
> >Why and who does care? NUMA is fundamentally about memory nodes with
> >different access characteristics so why is PMEM any special?
> 
> Michal, thanks for your comments!
> 
> The "different" lies in the local or remote access, usually the underlying
> memory is the same type, i.e. DRAM.
> 
> By "special", PMEM is usually in gigantic capacity than DRAM per dimm, 
> while with different read/write access latency than DRAM.

You are describing a NUMA in general here. Yes access to different NUMA
nodes has a different read/write latency. But that doesn't make PMEM
really special from a regular DRAM. There are few other people trying to
work with PMEM as NUMA nodes and these kind of arguments are repeating
again and again. So far I haven't really heard much beyond hand waving.
Please go and read through those discussion so that we do not have to go
throug the same set of arguments again.

I absolutely do see and understand people want to find a way to use
their shiny NVIDIMs but please step back and try to think in more
general terms than PMEM is special and we have to treat it that way.
We currently have ways to use it as DAX device and a NUMA node then
focus on how to improve our NUMA handling so that we can get maximum out
of the HW rather than make a PMEM NUMA node a special snow flake.

Thank you.

-- 
Michal Hocko
SUSE Labs

