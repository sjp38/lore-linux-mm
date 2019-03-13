Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2279C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 22:00:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 82FEA2087C
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 22:00:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 82FEA2087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 167948E0007; Wed, 13 Mar 2019 18:00:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 117578E0001; Wed, 13 Mar 2019 18:00:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED43E8E0007; Wed, 13 Mar 2019 18:00:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id AA7BD8E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 18:00:30 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id b15so3696441pfo.12
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 15:00:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=XGKmkwxf0ciRj00PDAYTBmIJo3ZCtO/Uxh5bTcn3rgY=;
        b=EWvlDyxoF8R1wOKUmLc8VisvBQiodRuJe7RJ1UCEw+gtNhbil3XpYLXynsVeGTr1A/
         PWFezxLP3EldoQCyde3NRNDR8nwU/bEXS9/bcCMqBZ9lMNSYumExtmqRfrqMz3/Ma9Av
         fZ6KWQGtDAsKPCqC/P7fJKHgeGpKyDJGAkThzbkD2bktbKb/qEq+AQZaxj+bDl+gn4wn
         fFqfkFfbcCh/+p1zepfLDLszuOCNmV3/1NqKRhuc9jTphdptiIHk38hSY/cwLzBIbsaW
         +4dHghLvUKPmzbiKHilzpVUy6AzALOrRGkaTDQdqdrTJYSySpoaoEa90HxDRRqoQincM
         /oBw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAV9Q2Tye4Liq3XP8xRh5Tv5Av4jhv/kOCachnDor8susaSxH7io
	f/Fn7S6IGp8SZ/K7Kk21sjT4HMKumxHWO1YJO+At8+qsW3i6UQP6nhyBYGH/3SAu4uqe92qHBtu
	ToSWXebhE1ITo0wpzUXcrChcV+mcdkm+jYHGhNXz/PFXrzNjoKcKLwwB5/uVSrXKbMg==
X-Received: by 2002:a65:63d9:: with SMTP id n25mr775099pgv.243.1552514430274;
        Wed, 13 Mar 2019 15:00:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKlI8Q8yKieJ3nGPfu12teTOAxSeiRto69CEietbf8Bv4g5QoQMPNy43oS53fD4NG9/moy
X-Received: by 2002:a65:63d9:: with SMTP id n25mr775028pgv.243.1552514429093;
        Wed, 13 Mar 2019 15:00:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552514429; cv=none;
        d=google.com; s=arc-20160816;
        b=XfmUXlTYioffUI4+daVVP63j9t2VIfJItMJ05Ojd8R2L53s0ZsgTT8fDCZ2lirVHqr
         fUdOxSsRTYipETGe6mEVqvvYqiZOHmIQxk5ypbgErpn3GWI1i0uhI/osT9djDJwcQ0Pm
         JjaLfcJVuYlfqk9cCYuwNsGI7jY4M+8M5PDrfOdN5lymVkEYaxo6qGjNAwi/xxCvg8Wc
         YqKzciNJ6TXwQcwkJUIamWT6mF91a4xGMiqFo9BPzSQN/vjSCyuSfeBMhwvlF1G+Aqb9
         u8WFqG2jOnZHyCW9INQpLcuWfG1RLwMXxnRN9UIJBdIxxfo93ZxB5wErqrDQ6QOzx1HR
         L9QQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=XGKmkwxf0ciRj00PDAYTBmIJo3ZCtO/Uxh5bTcn3rgY=;
        b=j3rpgDXlfbFTJd+N0Vzv+RdCnfpxmjmJWpZJokj0JxuKzGrDYM9Wd2BQkii3TjVde3
         GjYN+2r3Y4gUa/BJrtIEI2VnTJGDCkJn1CvX/y294GZjMEaCZDMzhpABt27KivxeGwyj
         zne6eQBCzRfrVPnGPBddcZuaDZVKLGJ6UocnTW1EzX+X6p+KLn/A+3Gn6uAXM/EIumb7
         f+Kn5VfhAfbCUsnr4y4X7YUwDsgQK6sHe2og5wAF+FlpHdMKdG0g6CcH9GNvZYQncrzS
         nFAr5Z1dZqj+JAEw/W0LcOny4HepIYzy3iAramyIF2E1BWKQXboRk871qBpzXlWH11K0
         r/Gw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id a2si1726886pgq.341.2019.03.13.15.00.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 15:00:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 13 Mar 2019 15:00:28 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,475,1544515200"; 
   d="scan'208";a="125250152"
Received: from ray.jf.intel.com (HELO [10.7.201.16]) ([10.7.201.16])
  by orsmga008.jf.intel.com with ESMTP; 13 Mar 2019 15:00:28 -0700
Subject: Re: Kernel bug with MPX?
To: Michal Hocko <mhocko@kernel.org>
Cc: Richard Biener <rguenther@suse.de>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
References: <alpine.LSU.2.20.1903060944550.7898@zhemvz.fhfr.qr>
 <ba1d2d3c-e616-611d-3cff-acf6b8aaeb66@intel.com>
 <20190308071249.GJ30234@dhcp22.suse.cz>
 <20190308073949.GA5232@dhcp22.suse.cz>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <e6392ccd-4318-795e-2e8c-85fbe62bb4e3@intel.com>
Date: Wed, 13 Mar 2019 15:00:28 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190308073949.GA5232@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/7/19 11:41 PM, Michal Hocko wrote:
> And this seems real leak because I just hit some bugons later
> 
> [112423.206497] BUG: Bad rss-counter state mm:000000007aa9c8a7 idx:1 val:25593
> [113601.595093] page:ffffea00041a07c0 count:2 mapcount:1 mapping:ffff88818d70e9a1 index:0x7f821adf6
> [113601.595102] anon 

FWIW, I was able to reproduce this.  No idea what the problem is, yet,
but I'm looking at it.

