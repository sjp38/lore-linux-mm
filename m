Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05478C48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 18:25:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BCE732086D
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 18:25:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BCE732086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5CF996B0005; Tue, 25 Jun 2019 14:25:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5597D8E0003; Tue, 25 Jun 2019 14:25:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3F9ED8E0002; Tue, 25 Jun 2019 14:25:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 06ED86B0005
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 14:25:54 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id s4so12178852pgr.3
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 11:25:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=v6ARLDtcnnjLvrbs+a2P4XQFugqnr2nmlsAPAahsDFY=;
        b=lU10pPD9r0VHGHcjuZvCtPY9ZLbDvqesOO+EVDFae1oCXCGArNfLiHTtPUjtPiS3Px
         +hPaEHuDdFuha5sd3K3FTeeWT7Nwkg6M8+0z8HD4S8CVwaFfIfntfHVSh26HfwRSSjbp
         2G8dDHam+O8Pb+aWw1eb5xS7uA2Ixj1oECuLpr7Q7s029QGLpslGxhKOtWgiWFf/Bdwt
         ynT3ADTBFSGtix1Eg15ah+J/7SK2TQWIdifk1wxAoFboODKRgS+reTd4Jbq3ViDUtJDr
         xmrGInoc7JOT+Z2UaVh845mtiqGBcVm/YZSUxIYjBcigw5uakRfOOiR/FVEp9xGvWIpg
         PkOQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVLa8YlO70tfYOaEgqDuxHO8CcgfxmjtCPQZMXEzLQMsQmZql6B
	ZcH2UulP9fmaygxey2f/Sl9zcy2ISHE72ugp1UNpjzpXBPxpbLS+fKilf5lBACPbYnGhfLyFiLS
	kFXpONah/r6RhR8paVWY/f6/Hn0ME4Yahm+54CkrO0f8jZs/fiBW/on2XnzDEUnycEg==
X-Received: by 2002:a17:902:ab8f:: with SMTP id f15mr60540plr.159.1561487153737;
        Tue, 25 Jun 2019 11:25:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxvwkhxFDDadEI7ZbA1KHX9dE2yb1jPloustKbDfAyKxlNIMx4CMjfhh7CoyM4VhCoFmHhI
X-Received: by 2002:a17:902:ab8f:: with SMTP id f15mr60491plr.159.1561487153167;
        Tue, 25 Jun 2019 11:25:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561487153; cv=none;
        d=google.com; s=arc-20160816;
        b=l+6/FGl2NoAGjCnO5DGHXwLr93YbSVDD4L6kDLmy0ruMzqtWTfKoLx5CYhVDN9o0j9
         e7EjyDP3rqNrKxnnJ1FnJPLYj2Fx5Ft8Kh8fO1FPps4r9N7L1DzDIJdVmwFDFoGxNUW7
         GsKXiclwn15gc9aFwaNMC+wMczPRqGa7tolQlHl5juoPimJZOO5cIEZgzgx7I20mnNq4
         wzjh98FCLUsiKaRq7Zv0Gl+95NjYaEvEyAank2mcYzyyjqkePIaaSGxy2JwrWvU/AGLG
         6O8H461ePceELKJaIxPUHc57lz5yzGfc4kL1VDI/vx/6Bxpt659kk7Fb0L1bqvszXl3v
         3YfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=v6ARLDtcnnjLvrbs+a2P4XQFugqnr2nmlsAPAahsDFY=;
        b=iz4VQtVf1CECjK7Rduqb7IsQVdDyeFmjHgfVvYTx+ILyBMAfpCHNOTAe53rboWKHMq
         vVlvNFNwtTd+M5mwRvt2ixE5JNOW0GNjuMwblAyWczyBSPcS1nYyYyqiku23jvysWRIs
         U8ii1c6ZY0DRDssiVj4+5e1JXah2o5+5s2UE4epNqs93779nTRP3y+VKcUTRmueR1VOt
         CrcPGi22lUY8EedVe2/rM01ujplcqIlveJANPKdSWJu+54ZcSR8vqIIViMxVrkBTl8+D
         KuDHBdj2dHv/HlhiRcNobTzq8LRNtY1xuumMQT9K+US9u7inbrpwENBBrdcTYY3fTYms
         zYmg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id b20si9681344pfo.108.2019.06.25.11.25.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 11:25:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 25 Jun 2019 11:25:52 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,416,1557212400"; 
   d="scan'208";a="172455613"
Received: from ray.jf.intel.com (HELO [10.7.201.139]) ([10.7.201.139])
  by orsmga002.jf.intel.com with ESMTP; 25 Jun 2019 11:25:51 -0700
Subject: Re: [PATCH v1 1/6] mm: Adjust shuffle code to allow for future
 coalescing
To: Alexander Duyck <alexander.duyck@gmail.com>, nitesh@redhat.com,
 kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
References: <20190619222922.1231.27432.stgit@localhost.localdomain>
 <20190619223302.1231.51136.stgit@localhost.localdomain>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <dd694406-6384-d859-6ac6-ec6e6cffe4e8@intel.com>
Date: Tue, 25 Jun 2019 11:25:51 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.1
MIME-Version: 1.0
In-Reply-To: <20190619223302.1231.51136.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/19/19 3:33 PM, Alexander Duyck wrote:
> 
> This patch is meant to move the head/tail adding logic out of the shuffle
> code and into the __free_one_page function since ultimately that is where
> it is really needed anyway. By doing this we should be able to reduce the
> overhead and can consolidate all of the list addition bits in one spot.

