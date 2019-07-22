Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1F35C76196
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:50:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 907942235B
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 09:50:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 907942235B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3BC758E0003; Mon, 22 Jul 2019 05:50:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 345EC8E0001; Mon, 22 Jul 2019 05:50:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2853C8E0003; Mon, 22 Jul 2019 05:50:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E5E7E8E0001
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 05:50:49 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c31so25998093ede.5
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 02:50:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=gcLPzH5shdTXSIOTg1VDzV38iclkhwg0NnKuyt/TVZQ=;
        b=GRO1eehkkAMdb94PviKcFSyyBXF1PUO3Vp79ma83TtRLDGifW3nRpsGg2EVbaMeMN3
         Mt3A9bFUhP363bNMrLVbEvxBSvpTCJP4F3pARDWeMjYnOe5Y98beCNOsWLEcS3/eMK7X
         9E+oLECXSYThCdsRQrPIl0xxBacBZBl7nlUsdgteX6pepmGDonqR2qAbgn7uBOp8KC65
         5jC+hfJVg8vu3o4G0VuzFFksCBYkCzh9wCTeBxXz6ttHI/+T40Tu7ZYTc/wMO4XnQ4Pd
         ufDvfoB8BdCwPAl+GEa2zb2SrUzkUdJVF9+J97x1JXFpgqPBRjMGNYmEh0JZ506nfdll
         7vnw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAV1ZVsB51Ie9XbeFipOoGGyP+M6XsX5jPmQzyDpE0Y4K3MhtTxf
	GLcAFTEMCycXzPdxt70KoqDmXSU+PRO8I3VFeRyRBycRN+SCfLLDUY1lDbpSKfhYhQId6gjkQuf
	P5ZrQQa71KAnsVE6BEOE+27iPjBfz2GzAbLMQtRrVq+xoWUgOv5RTdSSjsygDPIypkA==
X-Received: by 2002:a17:906:d154:: with SMTP id br20mr50678102ejb.76.1563789049536;
        Mon, 22 Jul 2019 02:50:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzXbVVieFBLfQ+AjMlxMM25NCIkTtdt8iqVu4gtSg4H3IhD4xpZphvQKi1t0nNZfXPzGEw6
X-Received: by 2002:a17:906:d154:: with SMTP id br20mr50678070ejb.76.1563789048878;
        Mon, 22 Jul 2019 02:50:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563789048; cv=none;
        d=google.com; s=arc-20160816;
        b=fVczAr+Z/5nrwbgbbmFr8drs1n03+HuVEe1ph/GkYUP6GuQSxHJla6rqDl/GTItXat
         /Yhinze96f3j2845dSHdSyqFltlwT3q06dhenU6JYXuk/R2pncTMTg0Kkmp0SezJQovA
         57NNOzmNFm+4WAb4cA/Umebtj8LmukMWRD1EazsCaYq1syT2qFozJvNdKE2upHDwuA5S
         2Ruqi3YY+mZ9uhY8hY4EzJ169zEepkk+7iETejaHK3YHlgFg+nUVkAM8INbSRNaZDQNj
         0S71vbPj/G0J2P2HN0nYxngqvzu35Ih4vp8IfHdvMN3Qtp/NEI/qQhSwcmF39+0/43oV
         pZyQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=gcLPzH5shdTXSIOTg1VDzV38iclkhwg0NnKuyt/TVZQ=;
        b=wGTd4d0nMcH4mG21dCSzQ1XQDHF0rFpgWPt42r5odssw/pvK59YN4MD9+jWrtD6rzJ
         9Xo0htTKNmu8NrjWLfPeN1FACDshwmfUTsP80va2tnKkHcoJZgBD1T0mUzHCX3tXvwAu
         74jlwhhazP9s4IIdr1PPfbFM9BOXg6WfX3D26gY32wxEGZvU79Y7OUh1gDr4ZN6LuG7N
         CghwSU6/ZDGGeSx3Mq8qAMPSu4A6VmuUus/8X/sHLRUV2SLQl1qGOUivanR/HlB8brHh
         YJHLJKu0EWDIujvZt0DBFPvmFkpu2jyfaOjqWWAU8etZea9FiSR5sYfjFB5So81TTmqN
         zZew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id gy22si3896609ejb.300.2019.07.22.02.50.48
        for <linux-mm@kvack.org>;
        Mon, 22 Jul 2019 02:50:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id EB82128;
	Mon, 22 Jul 2019 02:50:47 -0700 (PDT)
Received: from [10.162.41.186] (p8cg001049571a15.blr.arm.com [10.162.41.186])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 4C5EB3F694;
	Mon, 22 Jul 2019 02:50:46 -0700 (PDT)
Subject: Re: [PATCH] memremap: move from kernel/ to mm/
To: Christoph Hellwig <hch@lst.de>, dan.j.williams@intel.com,
 akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-nvdimm@lists.01.org,
 linux-kernel@vger.kernel.org
References: <20190722094143.18387-1-hch@lst.de>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <9cd09b82-ec86-b0c0-79d5-e26ed5ed0b23@arm.com>
Date: Mon, 22 Jul 2019 15:21:23 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190722094143.18387-1-hch@lst.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 07/22/2019 03:11 PM, Christoph Hellwig wrote:
> memremap.c implements MM functionality for ZONE_DEVICE, so it really
> should be in the mm/ directory, not the kernel/ one.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>

This always made sense.

FWIW

Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>

