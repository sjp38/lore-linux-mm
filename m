Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 35CACC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 18:09:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3E8D205C9
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 18:09:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3E8D205C9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 897BE8E0127; Fri, 22 Feb 2019 13:09:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8466E8E0123; Fri, 22 Feb 2019 13:09:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 737588E0127; Fri, 22 Feb 2019 13:09:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2DFE38E0123
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 13:09:44 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id y8so2264904pgk.2
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 10:09:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=gMk4jGpRItRnXFBu+jiiDmsy4COVXf6cHv/nAsxNCLQ=;
        b=bjnBv909RE9lj5FT0Y3KGSZNtjro6UFYf9T2jIyEhiM2fzR/LXp1B5Ts5CrSYCFHG6
         /MOuQUt2vXrMkziFHg1OJ3G/vR8o+V93cpc4iv1sxXJxvVxZW23gKkJiu/mW67JumWCU
         ME+lw1h1lwyXreu3fyNd696LNOPXq5VdaSDWxpzsere7sSwcnosALKGwsGe5BnF4rHnd
         r7/z+YvbWdDMmzBQcX2tLoTcZh/wTMEyYIk3//2PpP/L0pvhniBTAi81wakmgIZ73VRz
         d5ylGfQQjDpB6Nx5b7vZ5hcHGhD7AgGgyN/5pLLPVGWsEMkp2xVzdhW74myM4fDb73v+
         9h9w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuboUgUL92iozEpCjJqfz4tPs2/q407/ST6mawa3gQ7ldd0LhC7L
	/UrnG+841lbk0n6pDL3H3e1/5iRyd/J5AGutl8/lDUjw7UFiLoqlfeIWdfHPLwSTToKnTNU+z+w
	SivKVcEJ3Xq/Jan+BIrLAdE3yHCw9eGs5rfKBVzFrDRFPHS3dM/TCXMThczQynsq1rA==
X-Received: by 2002:a63:8948:: with SMTP id v69mr5255263pgd.140.1550858983781;
        Fri, 22 Feb 2019 10:09:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZC/bBTcDyfuXFHp7ACoOm4Xn9YOYa2Kv274Wk4Ogy3b77QXX2Mpw4X90nyJ+u/+/W1+fJk
X-Received: by 2002:a63:8948:: with SMTP id v69mr5255193pgd.140.1550858982943;
        Fri, 22 Feb 2019 10:09:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550858982; cv=none;
        d=google.com; s=arc-20160816;
        b=dWHaXDtxwc/GddNph8q+uNmUVMCkW8YMcgFzlRuJSDk7beOIDfZM2uedIMtAzIlssV
         r3gsFBtotYXlEjvyz2O1niW39CWF+x9GXtpqf9QMdfEUi4JMxV23v+QNXTdgulX/19NR
         MSdVNFoGI4qtkY9HbS/Hwt1AADAZKdfk4LsemnY9y4QRfF6+4aEFmAPWDaK6JOieQ8Zt
         c9Z/N/oUkvpyvS5HeUW3OcB4SijjhokLtrMYBDy76UB/gaJaMT0HdZsVtePptgZOU+/G
         vD1jDHnxcGN87pXUXcqt9hWn/VqlaXg21s9Xe+fgXVhHC34YPkP/UghKBq19gZvPJHad
         qo1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=gMk4jGpRItRnXFBu+jiiDmsy4COVXf6cHv/nAsxNCLQ=;
        b=rlIJv3vvkwkIeoRQs34X+Oo13KU7UXrvu++XmM30BZK24o21hg+3YHYbP8qTwK+tIQ
         gA8K18WdyxWpn9Rb3G/jtErPKCbm+3lOzBsdaZ19m7YwMX7j8vjpdoO/YvvLgozKKIuP
         GOlDaoTWVfuPR9r/WL3ulmlPx1+Ym96SsFhvDcHpm33vNbg7oL2yPdp9TzWVwttQyn0p
         mb9NzkTNKOcDHTEcrHVmo9nf+EVF+zfVdIeX+gm+GAoOyOIpp3yYoC2XGHbwUtL1BcCr
         cOAXEv7rj5UTrtaL1SIyS8nKB8DfEL1oSySx5fzlh1ld8lj8e7ZDYmh0sTAowhkGoraM
         opLg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id r138si1846427pgr.370.2019.02.22.10.09.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 10:09:42 -0800 (PST)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga003.fm.intel.com ([10.253.24.29])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Feb 2019 10:09:42 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,400,1544515200"; 
   d="scan'208";a="135579394"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by FMSMGA003.fm.intel.com with ESMTP; 22 Feb 2019 10:09:41 -0800
Date: Fri, 22 Feb 2019 11:09:45 -0700
From: Keith Busch <keith.busch@intel.com>
To: Brice Goglin <Brice.Goglin@inria.fr>
Cc: linux-kernel@vger.kernel.org, linux-acpi@vger.kernel.org,
	linux-mm@kvack.org, linux-api@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Rafael Wysocki <rafael@kernel.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCHv6 06/10] node: Add memory-side caching attributes
Message-ID: <20190222180944.GD10237@localhost.localdomain>
References: <20190214171017.9362-1-keith.busch@intel.com>
 <20190214171017.9362-7-keith.busch@intel.com>
 <29336223-b86e-3aca-ee5a-276d1c404b96@inria.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <29336223-b86e-3aca-ee5a-276d1c404b96@inria.fr>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 22, 2019 at 11:12:38AM +0100, Brice Goglin wrote:
> Le 14/02/2019 à 18:10, Keith Busch a écrit :
> > +What:		/sys/devices/system/node/nodeX/memory_side_cache/indexY/size
> > +Date:		December 2018
> > +Contact:	Keith Busch <keith.busch@intel.com>
> > +Description:
> > +		The size of this memory side cache in bytes.
> 
> 
> Hello Keith,
> 
> CPU-side cache size is reported in kilobytes:
> 
> $ cat
> /sys/devices/system/cpu/cpu0/cache/index*/size                                             
> 
> 32K
> 32K
> 256K
> 4096K
> 
> Can you do the same of memory-side caches instead of reporting bytes?

Ok, will do.

