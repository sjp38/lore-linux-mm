Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 759B0C282DF
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 15:20:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B93E20821
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 15:20:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B93E20821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1E76C6B0005; Wed, 17 Apr 2019 11:20:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 195D86B0006; Wed, 17 Apr 2019 11:20:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 037E76B0007; Wed, 17 Apr 2019 11:20:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id BB32B6B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 11:20:06 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id n63so16470015pfb.14
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 08:20:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Twk2K+2igBzjl+TRSdTc/mSY+wKHlj/1n/pzYuuisuU=;
        b=P0YZhIwyR5No4LGLKanvDWr3ap2p8B6+2Og1Hr23DQFB7TpQqe7XLhS7Q7ZuHirdfS
         CMmljU4cCVOqvZTS0/uRQaEbIGypDYOyP574hzm301cj4aX1a0uosfmKKgM0NKCZae9S
         E+9VkaxlnsMwEzhVZ7OdOWodgfTtoF6953Mf65pi3Zklj7D8h71OBAIPLClKnmlsY2F7
         cBUYBShfBl8teeU3tGVdY4k1K9pZrU5FiTE3wd+8nbsnwShzP2nB16SqOPstW4DSitBU
         +e3a338oCu8ZbJ1deJGv4WXMBa97IJMxJKuvoSiqwIwdZnGKDqaL+LkdtfN6TJGwSEIX
         h/KA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXwA8wiFK6exSeka5ZYv3wCN2hHgQz+QKC37Lfmh9c+TcTXYSrk
	o5pWl/f0q1Fkqctvcd806n8BzeoCCujgCZ2JzD6OxCma3bjpkqYXyiz7sIEu3Gsn6Rv69OzCosk
	vlimxAGUCQ4m9/RqGeVWYD0vn3d/qmU6g+qnQ8+Dg/VE4jTGZ00vwUpJa80Bw/tDkkw==
X-Received: by 2002:a17:902:6bc2:: with SMTP id m2mr66575372plt.194.1555514405829;
        Wed, 17 Apr 2019 08:20:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyrg3YjdWUMt2oP1SbBUzFUhmzMbhUMFkOx9Vrd6Y9JlWUFsl0OtehjN1gtdgHFAuaZqJ25
X-Received: by 2002:a17:902:6bc2:: with SMTP id m2mr66575281plt.194.1555514404886;
        Wed, 17 Apr 2019 08:20:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555514404; cv=none;
        d=google.com; s=arc-20160816;
        b=Kj67DU+IT2a9cqVGBza6rqj0XK99XexrCiGW8ROla8o3M+LDhF0ZAAj+LpC9vFnnx0
         osBIc80lS1xzcQBkcxbu4aVbyD1xKTwql0Wpf/5F2GlqJ8cSH0GURQgrA6XuUbk0Nk7b
         +c1tZmULaHBJ9RLLQ25hCn+qc7ezMGXzlavP+atitmn+b0KIOnkehp18K9OMfUS7WYWy
         9BHOBlxAAT18+Pl4o6AF9iLQe4lo5JlIbhQiGF64woMKkxTVcOqokRc0Cji8bV2vPJCd
         RSzS/XBx88UUecQcDwRGS0Euh1aOyKH0WTKRrEenfQJ9444IKVv8jMKNjr33giQC1UsH
         1vrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=Twk2K+2igBzjl+TRSdTc/mSY+wKHlj/1n/pzYuuisuU=;
        b=z5+aT/tFhOmtVMEgE+ZFi2tDCEIpTgA+GsPsv9idEns3/54YjiJIEsDztrwfJzgvbc
         lCd1NFDUf/M1jG0lU0dwn7j908x72/l3C9demRlpkLhOG1/aaF3iBuOcaOvAMKJhxnnD
         oHZjZaexnL6RoP6/hK74G/P3KNUOnanfTvDPBswxjXcBk5RYhxoxFE2zD9X4Q7YQAlmv
         UmtwFY1H9WFiqZ4FlZJuYUJq+aheVCT/umtIcYUijMsSSpgvKJxq4M/gXsjZH4+kHoju
         NKmamoTRemjuh++yWv+l4pk8vFDwd9Fwa2qVL8lUjgXf8Wwe5NHsyiyQY2iJWSLWTbIe
         iZoQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id v6si49956620pgk.320.2019.04.17.08.20.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 08:20:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Apr 2019 08:20:04 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,362,1549958400"; 
   d="scan'208";a="316758568"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by orsmga005.jf.intel.com with ESMTP; 17 Apr 2019 08:20:02 -0700
Date: Wed, 17 Apr 2019 09:13:47 -0600
From: Keith Busch <keith.busch@intel.com>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@kernel.org>,
	mgorman@techsingularity.net, riel@surriel.com, hannes@cmpxchg.org,
	akpm@linux-foundation.org, dan.j.williams@intel.com,
	fengguang.wu@intel.com, fan.du@intel.com, ying.huang@intel.com,
	ziy@nvidia.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
Message-ID: <20190417151347.GA4786@localhost.localdomain>
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190412084702.GD13373@dhcp22.suse.cz>
 <a68137bb-dcd8-4e4a-b3a9-69a66f9dccaf@linux.alibaba.com>
 <20190416074714.GD11561@dhcp22.suse.cz>
 <876768ad-a63a-99c3-59de-458403f008c4@linux.alibaba.com>
 <a0bf6b61-1ec2-6209-5760-80c5f205d52e@intel.com>
 <99320338-d9d3-74ca-5b07-6c3ca718800f@linux.alibaba.com>
 <1556283f-de69-ce65-abf8-22f6f8d7d358@intel.com>
 <8bc32012-b747-3827-1814-91942357d170@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <8bc32012-b747-3827-1814-91942357d170@linux.alibaba.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 16, 2019 at 04:17:44PM -0700, Yang Shi wrote:
> On 4/16/19 4:04 PM, Dave Hansen wrote:
> > On 4/16/19 2:59 PM, Yang Shi wrote:
> > > On 4/16/19 2:22 PM, Dave Hansen wrote:
> > > > Keith Busch had a set of patches to let you specify the demotion order
> > > > via sysfs for fun.  The rules we came up with were:
> > > > 1. Pages keep no history of where they have been
> > > > 2. Each node can only demote to one other node
> > > Does this mean any remote node? Or just DRAM to PMEM, but remote PMEM
> > > might be ok?
> > In Keith's code, I don't think we differentiated.  We let any node
> > demote to any other node you want, as long as it follows the cycle rule.
> 
> I recall Keith's code let the userspace define the target node.

Right, you have to opt-in in my original proposal since it may be a
bit presumptuous of the kernel to decide how a node's memory is going
to be used. User applications have other intentions for it.

It wouldn't be too difficult to make HMAT to create a reasonable initial
migration graph too, and that can also make that an opt-in user choice.

> Anyway, we may need add one rule: not migrate-on-reclaim from PMEM
> node.  Demoting from  PMEM to DRAM sounds pointless.

I really don't think we should be making such hard rules on PMEM. It
makes more sense to consider performance and locality for migration
rules than on a persistence attribute.

