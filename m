Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77292C282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 17:35:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 343152073F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 17:35:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 343152073F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A5BB06B0005; Wed, 17 Apr 2019 13:35:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A0B126B0006; Wed, 17 Apr 2019 13:35:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8FB0D6B0007; Wed, 17 Apr 2019 13:35:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5AF2D6B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 13:35:50 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id p13so15863254pll.20
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 10:35:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=EY31vcT5qc1leXFJy1w6o5I4JvfZh7xbKEGI1O7PIB4=;
        b=jGMzh5qqyYRHjhnoKK5STFIUB8ocJNB7TiT7eKFk0Ce4+breP9kBGErPdl93iRvX+k
         ZLMz0Ne2VCEbN4+IffW3TMrS6vGO6edOqKxMMHWtg7V8lbJGVifBduK+sF/MVvPJXKcm
         DTqo0LaZYF0OT5ZqUGAm2qoeM4aY9xnqhZ52ZavzQTrwzqpaCQHdC5FZXwv864GfgG4x
         nz5z5eo50VsbqJvd/QD0zXiQYBp29gM28lX6pDO39dxhI/uDFetUiQPmVe+VjQhoj9l4
         oB9hVENxOwFiogcHEEhXGoFWhuOKTAGWLJlvHsQQdmiDEJuStLYrGGPU6UJ/kxytUUgu
         DBxw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=keith.busch@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVShalC2SDjp3lvwzUKD8sonjkZtTbxGX/L7U6F2AZ9lo9DO7tY
	CmEBAVwIDM0NQ1GUM5f+opNw8ohxH9zhzWNCU6B5L8/bcLNFzmaUt5dwzgXGDJCZN/VAGSlz0rA
	O0lDB+r65vJZ56HfNLx44SWvaI+WuNMkBFfpwKanMxxLq4VlVrNXmdpEyyaeTcStDcw==
X-Received: by 2002:a17:902:110c:: with SMTP id d12mr62513826pla.47.1555522549867;
        Wed, 17 Apr 2019 10:35:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy+L8wOehoBwHgqoTVLSfE3lZNcXwLBIx801Qbx8nZP5qXOkqdRNLKZwFbwgfLFxWAUTEXz
X-Received: by 2002:a17:902:110c:: with SMTP id d12mr62513791pla.47.1555522549249;
        Wed, 17 Apr 2019 10:35:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555522549; cv=none;
        d=google.com; s=arc-20160816;
        b=E9+kk1kWfqPnsuFKN8wtuB0IEJkGjL2GqDtnksuV/Q94Mx8l5aDDulzUqDm25sEGgN
         SNnCOIb6CJU2wou9vvr43vTnIpF819yNwECaR0rjBLunm8G8zlrqzzbXwtOPdtFPZsd0
         TLihLZCSdRuUbvkupqrkd+AEO7oJegQe7l9uOuE8oDRAUn35ZIuvIO4o4tTyOAyCLtB0
         DqqPDT5H6g0b+StqS/YwvWZfBiH1K0xbvOEqHEuazrMsY5/gIm+NQKTHKArQ4V9lgHZe
         2hslaS/noJtvMz1gN/d+/GgvVLltCvnkzQBAIj6LQoyhsND2e+J51R8B1p0y5YB9UMAx
         77rA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=EY31vcT5qc1leXFJy1w6o5I4JvfZh7xbKEGI1O7PIB4=;
        b=asJwjcUMjqW6YbTm20hCWkx60yaFddok59amrk4eTkvHjymsVnuwLgYPTGEKK1ypo1
         uiTMsId4660VXAAO8QhqRxc6tKr7gjedSQGYaMlClq2jETSon6s2h7v5dM5H4QZ04tSA
         Xv5v53iZMZNnJok/UNvNPtlV1eksKTUAZ12jcN0CtBNJCJ9r5UiN+bFeRGE4ocKK4gpD
         wZGONzDH/DOqrqGue0pM4WNLX068B7raFhVhomIKrIK9xgMoJfrWhsc9zU3qKIaZc/Gv
         5+sV2iK9EuB3XD0DKvInse/cNL8RvaHprPNLp2gDVMwIVi089fQoiRKZ48LIih3TCWMi
         15Hg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id t7si50808217plo.163.2019.04.17.10.35.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 10:35:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of keith.busch@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of keith.busch@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=keith.busch@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from fmsmga007.fm.intel.com ([10.253.24.52])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 17 Apr 2019 10:35:48 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,362,1549958400"; 
   d="scan'208";a="143743233"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by fmsmga007.fm.intel.com with ESMTP; 17 Apr 2019 10:35:48 -0700
Date: Wed, 17 Apr 2019 11:29:33 -0600
From: Keith Busch <keith.busch@intel.com>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: Michal Hocko <mhocko@kernel.org>, Dave Hansen <dave.hansen@intel.com>,
	mgorman@techsingularity.net, riel@surriel.com, hannes@cmpxchg.org,
	akpm@linux-foundation.org, dan.j.williams@intel.com,
	fengguang.wu@intel.com, fan.du@intel.com, ying.huang@intel.com,
	ziy@nvidia.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v2 RFC PATCH 0/9] Another Approach to Use PMEM as NUMA Node
Message-ID: <20190417172932.GA6176@localhost.localdomain>
References: <a68137bb-dcd8-4e4a-b3a9-69a66f9dccaf@linux.alibaba.com>
 <20190416074714.GD11561@dhcp22.suse.cz>
 <876768ad-a63a-99c3-59de-458403f008c4@linux.alibaba.com>
 <a0bf6b61-1ec2-6209-5760-80c5f205d52e@intel.com>
 <20190417092318.GG655@dhcp22.suse.cz>
 <20190417152345.GB4786@localhost.localdomain>
 <20190417153923.GO5878@dhcp22.suse.cz>
 <20190417153739.GD4786@localhost.localdomain>
 <20190417163911.GA9523@dhcp22.suse.cz>
 <fcb30853-8039-8154-7ae0-706930642576@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fcb30853-8039-8154-7ae0-706930642576@linux.alibaba.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 10:26:05AM -0700, Yang Shi wrote:
> On 4/17/19 9:39 AM, Michal Hocko wrote:
> > On Wed 17-04-19 09:37:39, Keith Busch wrote:
> > > On Wed, Apr 17, 2019 at 05:39:23PM +0200, Michal Hocko wrote:
> > > > On Wed 17-04-19 09:23:46, Keith Busch wrote:
> > > > > On Wed, Apr 17, 2019 at 11:23:18AM +0200, Michal Hocko wrote:
> > > > > > On Tue 16-04-19 14:22:33, Dave Hansen wrote:
> > > > > > > Keith Busch had a set of patches to let you specify the demotion order
> > > > > > > via sysfs for fun.  The rules we came up with were:
> > > > > > I am not a fan of any sysfs "fun"
> > > > > I'm hung up on the user facing interface, but there should be some way a
> > > > > user decides if a memory node is or is not a migrate target, right?
> > > > Why? Or to put it differently, why do we have to start with a user
> > > > interface at this stage when we actually barely have any real usecases
> > > > out there?
> > > The use case is an alternative to swap, right? The user has to decide
> > > which storage is the swap target, so operating in the same spirit.
> > I do not follow. If you use rebalancing you can still deplete the memory
> > and end up in a swap storage. If you want to reclaim/swap rather than
> > rebalance then you do not enable rebalancing (by node_reclaim or similar
> > mechanism).
> 
> I'm a little bit confused. Do you mean just do *not* do reclaim/swap in
> rebalancing mode? If rebalancing is on, then node_reclaim just move the
> pages around nodes, then kswapd or direct reclaim would take care of swap?
> 
> If so the node reclaim on PMEM node may rebalance the pages to DRAM node?
> Should this be allowed?
> 
> I think both I and Keith was supposed to treat PMEM as a tier in the reclaim
> hierarchy. The reclaim should push inactive pages down to PMEM, then swap.
> So, PMEM is kind of a "terminal" node. So, he introduced sysfs defined
> target node, I introduced N_CPU_MEM.

Yeah, I think Yang and I view "demotion" as a separate feature from
numa rebalancing.

