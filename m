Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E3314C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 22:44:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DE4E2075E
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 22:44:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DE4E2075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 30F3A6B0006; Thu, 28 Mar 2019 18:44:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BE556B0007; Thu, 28 Mar 2019 18:44:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1AD816B0008; Thu, 28 Mar 2019 18:44:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id CDC2E6B0006
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 18:44:37 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id j10so68413pfn.13
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 15:44:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=hoXTOMqs77/aDHAbNEOXTowKIcFUiYOGUIvRdh/SNQo=;
        b=RkML3x7rTxIRXVdVRYamSWIvstUuA+xDmfC1nlpo9d0+ki6VGa5vwmGAAmWIAmTqiA
         6Dv56DX5cQ4NqR9vdZv3rVqQG0Re6PqzoCfuuFLU4Vv1+m1k1bpyFWolm/2mpGbLVUVT
         UbRIPPE8NiiAgcbU64Q9jWgWNS0V/o8xHjj4+USug8OI10l6YwS0To8yheR1Vh2YMaHR
         MjgfyoMoZsYJwEscWfUMu2hooOtbbqtIdqr37wc7pUuEyPPMv1rSTtyt2jyDOXhFLyAt
         4WbFwfVzPqcF1hKYW4RjJ7Jx0U/P1HfzEVWLKSulrIZGBv1sTnEoVuQdCfFoAopncKpM
         zkTw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 134.134.136.31 as permitted sender) smtp.mailfrom=kbusch@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVoApa01g1nCfftITqKaD0JTkvzeZkDvYF+6phSe3Dr5G4pmJ21
	ppvwUaPXExA4w+/yy/GB71TEPy2d19jyiuaCD8mmqr+T3//cWM0ejlxNRaWc7RFmKCOHEFFev5n
	PlRgDjMmSajhE4uZMP5ZfktDoUtehb6qFxt7psm/5YeLZ7eBEzwwwqD8PkTapFjo=
X-Received: by 2002:a65:6148:: with SMTP id o8mr1711248pgv.153.1553813077539;
        Thu, 28 Mar 2019 15:44:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw9AsE12zx/fU3P8smaHjDDeZSIdb/Unq5OqUF3fDaUj7G2HiglGK37df10lPPmDF3sKTYI
X-Received: by 2002:a65:6148:: with SMTP id o8mr1711222pgv.153.1553813076848;
        Thu, 28 Mar 2019 15:44:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553813076; cv=none;
        d=google.com; s=arc-20160816;
        b=mmkAhdiuzd67SbOileFnFs0hLJtEX4i/qm4E3+YAmdokM9ribMrTZM7o38eXuiienS
         G1EcEFdyOiYdJgMMeS3Hefibvm5aRYeSEKcIyS4hnQ9Cd7cqbQ+9YjNQUnBomm0Fzov4
         HueCh5E9dtDEI/Y/Kgwjzml/CKQjNlOmX5lEkk7VNhOCvKGpqqOJ6QRCd+PqeWN/hjrW
         0Xc/ihD+4V/Q4NLSotbZOk7LUIBCmWa+xlN8OHsQjd+H6uJ3ckiDapPDG5J9OXsixhVz
         hbSgTg7t5PDvIEO3uWj9Lsw1c/mvq7xNTvmxfQ69dkTLgrJ7JVSIEVBVune39Cjt0bnO
         xapw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=hoXTOMqs77/aDHAbNEOXTowKIcFUiYOGUIvRdh/SNQo=;
        b=oe5ErXuyFuOUSZ90uuxuNQzdbYGH01eRypyfl4UtI6ysOyzHjRec/8owjrksOnCvpE
         ZMLb6ZAArZEQqV0Ox5IVnXP5Apn/dDl5Qa7/QC1OM5gfOSMviGFlAtru8bhcnS7GD500
         B5QOhCXfqyKQ4EQ+N55jWjW43UU2KNSAGVCpOR/Vijyn2RyE4gfmf/EIbQqeAcaT/KT6
         kfagQUWNmRCNxq79/qHxeXKWuchggu7Xi5H2rBopxYFXMtmrVUTzRMkQwJo8v53h9tqh
         p4xJHd4PRF2KUreMjNuZPdlcyysfoe08emG2u8nRPLV9U0OuaSia78UOiIqtyE5iXcss
         NTUw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 134.134.136.31 as permitted sender) smtp.mailfrom=kbusch@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id h125si339509pgc.290.2019.03.28.15.44.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 15:44:36 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning kbusch@kernel.org does not designate 134.134.136.31 as permitted sender) smtp.mailfrom=kbusch@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Amp-Result: UNSCANNABLE
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 28 Mar 2019 15:44:36 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,282,1549958400"; 
   d="scan'208";a="126781810"
Received: from unknown (HELO localhost.localdomain) ([10.232.112.69])
  by orsmga007.jf.intel.com with ESMTP; 28 Mar 2019 15:44:35 -0700
Date: Thu, 28 Mar 2019 16:45:50 -0600
From: Keith Busch <kbusch@kernel.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: "mhocko@suse.com" <mhocko@suse.com>,
	"mgorman@techsingularity.net" <mgorman@techsingularity.net>,
	"riel@surriel.com" <riel@surriel.com>,
	"hannes@cmpxchg.org" <hannes@cmpxchg.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"Hansen, Dave" <dave.hansen@intel.com>,
	"Busch, Keith" <keith.busch@intel.com>,
	"Williams, Dan J" <dan.j.williams@intel.com>,
	"Wu, Fengguang" <fengguang.wu@intel.com>,
	"Du, Fan" <fan.du@intel.com>, "Huang, Ying" <ying.huang@intel.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 06/10] mm: vmscan: demote anon DRAM pages to PMEM node
Message-ID: <20190328224549.GA11100@localhost.localdomain>
References: <1553316275-21985-1-git-send-email-yang.shi@linux.alibaba.com>
 <1553316275-21985-7-git-send-email-yang.shi@linux.alibaba.com>
 <20190324222040.GE31194@localhost.localdomain>
 <ceec5604-b1df-2e14-8966-933865245f1c@linux.alibaba.com>
 <20190327003541.GE4328@localhost.localdomain>
 <39d8fb56-df60-9382-9b47-59081d823c3c@linux.alibaba.com>
 <20190327130822.GD7389@localhost.localdomain>
 <599849e6-05b6-1e4d-7578-5cf8825963d2@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <599849e6-05b6-1e4d-7578-5cf8825963d2@linux.alibaba.com>
User-Agent: Mutt/1.9.1 (2017-09-22)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 02:59:30PM -0700, Yang Shi wrote:
> Yes, it still could fail. I can't tell which way is better for now. I 
> just thought scanning another round then migrating should be still 
> faster than swapping off the top of my head.

I think it depends on the relative capacities between your primary and
migration tiers and how it's used. Applications may allocate and pin
directly out of pmem if they wish, so it's not a dedicated fallback
memory space like swap.

