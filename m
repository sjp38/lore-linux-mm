Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06929C282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 15:43:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C524F205F4
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 15:43:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C524F205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F5786B0005; Wed, 17 Apr 2019 11:43:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57C756B0006; Wed, 17 Apr 2019 11:43:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 41D016B0007; Wed, 17 Apr 2019 11:43:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 049916B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 11:43:57 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id u2so14857353pgi.10
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 08:43:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=1tzss/eTAlkwslHVAdew1DA7WfJBCr7rAadPs81a+mw=;
        b=EljAxlnuuy4Vtd9Xo7nf5mIBJ7a/QvVZ49ir4KHy91cdGnaDOeunEY0zOrGkzNyehZ
         +nNqOJOg0blFNLl2oH/E3VSDr90myqNg1RuO784gCUWzl+KBdrf+QH1jqnA8fl5MqEvj
         cbSdnEoi8suAv0GSIXrSMpBv4l3hNS07jCBIZSFeTvkRjBrXKg9wx066IhmI7/KDiIBL
         +fZ3J2LoG9sOKseUMpf+C4WANmeV3faB3Ub/4cQHQEIp094c63sBUw+PwOWuRTkeBkgH
         EyhgdINLowq7bG8/zM+uyguiK78GkDcn7X9a26h19o7IhIyRE6XgnJqgJrZXoH3B013O
         r5NQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVkG60LqXajfo0rv1wHDGyAiczGRhBRk22W5cNIAG0UTj34sXeI
	4ZVf7FEXZ066mOSGFUXEzTzwJ88X7t6UH+8HcEHqExuaXiIcLkgX7PrtLyfovqQSV8JmuBR7kgp
	nIfy9TIXGbsvT36fOI3eF3BrbsEiKzg0Q8qffuOntqLEIKjCz05QE5Rm5kCghu4UJ0A==
X-Received: by 2002:a62:2687:: with SMTP id m129mr88882237pfm.204.1555515836591;
        Wed, 17 Apr 2019 08:43:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx4jPxPGBwXq2NVah8ySBpDe7cHDZh9JF8jwevu5dj6SlTDJa5cHLiNG553U+Bn+mn7ybcA
X-Received: by 2002:a62:2687:: with SMTP id m129mr88882189pfm.204.1555515836038;
        Wed, 17 Apr 2019 08:43:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555515836; cv=none;
        d=google.com; s=arc-20160816;
        b=Eqj+LXKZY6QRJsEvg5WmTFxlJn0CG3bx5HhyMaiwyugReNlsNHNtHZ6IHAYJrn1wWw
         /9f4KYbsow+HOhs0SYOaJG5rEtdwwOEVBGN5g+fq1H3FpgN6NUqsxRN11pS21r9iMmQq
         qEiyS+LmUcNQHgYzrjmgPaxPGTV0FrBJ7DKgsVg0DRSKewZKZuuMmreH4xdoUpYMXDQ+
         0Cqg2qWG16FdEDI4r5VvtqKoFFX4cbquU4QfwT7XEKdMuKcCKqkWl64XVIfjjj5REqIJ
         Z0enUs/gRLzAsmd0yOwzoFLlxuhXgXAfHjm5h1Nf2PmVILbk4hTaXr450Z37l7XzSRsf
         w8bQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=1tzss/eTAlkwslHVAdew1DA7WfJBCr7rAadPs81a+mw=;
        b=PU9ENmBrLGKeRyYHPiAa02H1fMz2S8gxQ7rCigbFxu/yvOspsJziuzBBl+sVGZfjdp
         RW+/XZBmdBi4podh8iWPrk5q4n/A6SQNKdYZpqyKtFsEicHg1wFsG5LC+D7BRtS1eFcZ
         y7cUM6mTSvQr+DGbm01e0ytEHvAl7fLrYs8TB5ViDIECSt0Ljpui78+iEmTDQ6ozIRYa
         dINgPmUcxUg1QhVE9Vh+9kEPig7n0lriyRX102FY1UmZPUZ43jDIVYX5IL8Cc1mMJVIp
         MBQvfFDXR9IRL0aH74YwZxCa35smfPv2jtNSudRGUmc/kziuxWPGB6OsJtnDPYk9PUJc
         2E/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id k5si50295546plt.179.2019.04.17.08.43.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 08:43:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 134.134.136.24 as permitted sender) client-ip=134.134.136.24;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 134.134.136.24 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from fmsmga004.fm.intel.com ([10.253.24.48])
  by orsmga102.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Apr 2019 08:43:55 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,362,1549958400"; 
   d="scan'208";a="162731832"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by fmsmga004.fm.intel.com with ESMTP; 17 Apr 2019 08:43:54 -0700
Date: Wed, 17 Apr 2019 09:37:39 -0600
From: Keith Busch <keith.busch@intel.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Hansen <dave.hansen@intel.com>,
	Yang Shi <yang.shi@linux.alibaba.com>, mgorman@techsingularity.net,
	riel@surriel.com, hannes@cmpxchg.org, akpm@linux-foundation.org,
	dan.j.williams@intel.com, fengguang.wu@intel.com, fan.du@intel.com,
	ying.huang@intel.com, ziy@nvidia.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
Message-ID: <20190417153739.GD4786@localhost.localdomain>
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190412084702.GD13373@dhcp22.suse.cz>
 <a68137bb-dcd8-4e4a-b3a9-69a66f9dccaf@linux.alibaba.com>
 <20190416074714.GD11561@dhcp22.suse.cz>
 <876768ad-a63a-99c3-59de-458403f008c4@linux.alibaba.com>
 <a0bf6b61-1ec2-6209-5760-80c5f205d52e@intel.com>
 <20190417092318.GG655@dhcp22.suse.cz>
 <20190417152345.GB4786@localhost.localdomain>
 <20190417153923.GO5878@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190417153923.GO5878@dhcp22.suse.cz>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 05:39:23PM +0200, Michal Hocko wrote:
> On Wed 17-04-19 09:23:46, Keith Busch wrote:
> > On Wed, Apr 17, 2019 at 11:23:18AM +0200, Michal Hocko wrote:
> > > On Tue 16-04-19 14:22:33, Dave Hansen wrote:
> > > > Keith Busch had a set of patches to let you specify the demotion order
> > > > via sysfs for fun.  The rules we came up with were:
> > > 
> > > I am not a fan of any sysfs "fun"
> > 
> > I'm hung up on the user facing interface, but there should be some way a
> > user decides if a memory node is or is not a migrate target, right?
> 
> Why? Or to put it differently, why do we have to start with a user
> interface at this stage when we actually barely have any real usecases
> out there?

The use case is an alternative to swap, right? The user has to decide
which storage is the swap target, so operating in the same spirit.

