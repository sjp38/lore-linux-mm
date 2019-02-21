Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D54CC00319
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 254212083E
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:51:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 254212083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7DB388E00C8; Thu, 21 Feb 2019 18:50:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 73B6E8E00C9; Thu, 21 Feb 2019 18:50:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D9E88E00C8; Thu, 21 Feb 2019 18:50:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1AD4B8E00B5
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 18:50:59 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id g197so329671pfb.15
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 15:50:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=COL8a/bhLctZiKFBcotiJ8aqw2nEZHLXmYVqsv0DDyY=;
        b=djll7goSUe3a3gz9pLBP2NrlGn9ZHUaqJ1RNL6AzXt9RdnsgLz8jhSzZSSqYEmj5C7
         hsbze9y10Dn8KAxvQlg8Eew2PCHt8giMtyjONVMur/y56AKQ8WH09UDa58JzFjPz9pyu
         VdYkP4PiHz876G+Trd8Pcgz2vENq+qQuSYJKWbN32oO7idFPGXp9S0pN6mmrH0zaya1k
         h4L9YtL91IJhXPZH2FF31WsBkD3n3wjqK9PX29ucqZi6fz4JyG9hLaVDxkL8dKLEKKOa
         pV1PGZGeB+IRttwZ+AG0rW6m7lIcUZPlt7L6vdBwVCknz3OQNx+BetdoInrjNij3jTY2
         znNw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuZvCkSv9cE7kD4A1UXX+f4JiSkbmFobbeXM5Ep+/GJm6We0ZUHT
	29+l6bQzRqpY47B2NqhDNzoxpPhjyuIPDH8P53wg745g7rlIm7vHvRTXn4IwMPD6ZkI2LKhEdic
	lse3Tgx6f+k2Jd48kw7AqEzo/f0ATuxywibE3wKIV++al0aOY7MXqS3mB912ugPxOXg==
X-Received: by 2002:a63:534c:: with SMTP id t12mr1040221pgl.205.1550793058803;
        Thu, 21 Feb 2019 15:50:58 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbewAM/BbCd+D3ph6BAmALEu+Hjf7U/9v5jfsozTRZNvmfKHIBK4aO5KxODT5FDCbqQrRh6
X-Received: by 2002:a63:534c:: with SMTP id t12mr1040196pgl.205.1550793058105;
        Thu, 21 Feb 2019 15:50:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550793058; cv=none;
        d=google.com; s=arc-20160816;
        b=Scj8q8ihKkgdrKAFJwL210MNGkH9DIVxZdXOzuxjXO+h+bd3hftZ0aiXVJ2OBpjmWO
         XPPhluEFLW1BQS7025WJbTIHukVlcJyJKyhHQOtgNzw17GAqyg5fAgOn4L5GXcIqSAOE
         DJnhLuniWt2QdIO5Rp1xpMba9azgCdX6J4/z/J/k6CQ2TL+CtLI8UQMyv4sLWP8PKZBi
         HwoknTkYG2/9SSWHPNuYHNnFbDqdtNRhzN7Ls9rABMO7jvnoRI6EOudYn/KDBbUiN9MC
         95sEilF6oDcclkzxpYh3xw6iGrUiiVQL/WJFrWXP9S8PL0lQqNfMqjCGtM1UG6nFtOuR
         XL1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=COL8a/bhLctZiKFBcotiJ8aqw2nEZHLXmYVqsv0DDyY=;
        b=EtwUVUyK5GadYHrR6V4wSIaDgxwh5GzEU/VSJ+T8qPDd8y6Twbef9HCR6bW2jqXDPP
         Lc9/8HJcyTKrwkdspHkBha2V1XmcmX0+00c9TTqRGta7nhAmjm7JalsKZVC6liLbQ0Pt
         G1ULq7dyMt71W9MCmapuLFy6e8xrZeKRBH+OGdgqWoDSFHcW23neI57NV0jG5I85nv3u
         mWzU4jbWItqYzrRGQGihiDKy1H0SMiHEFqgyPQunfRnKQ4ej9MeDdYn662ROXOJNLQWy
         8JB0ZqRPW6ZGzwXMgMykLE4Pw6pRVf42PvRR+urXlvbAFpQdAo/xbCne4gWvNU4C0/vs
         NBQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id b3si221941pld.282.2019.02.21.15.50.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 15:50:58 -0800 (PST)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Feb 2019 15:50:57 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,397,1544515200"; 
   d="scan'208";a="301607231"
Received: from sthulasi-mobl1.amr.corp.intel.com (HELO [10.254.86.146]) ([10.254.86.146])
  by orsmga005.jf.intel.com with ESMTP; 21 Feb 2019 15:50:57 -0800
Subject: Re: question about page tables in DAX/FS/PMEM case
To: Larry Bassel <larry.bassel@oracle.com>, Jerome Glisse <jglisse@redhat.com>
Cc: linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
References: <20190220230622.GI19341@ubuette>
 <20190221204141.GB5201@redhat.com> <20190221225827.GA2764@ubuette>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <6e4a5296-0ad0-ab1e-40a0-c1f69d11300a@intel.com>
Date: Thu, 21 Feb 2019 15:51:05 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190221225827.GA2764@ubuette>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/21/19 2:58 PM, Larry Bassel wrote:
> AFAIK there is no hardware benefit from sharing the page table
> directory within different page table. So the only benefit is the
> amount of memory we save.

The hardware benefit from schemes like this is that the CPU caches are
better utilized.  If two processes share page tables, they don't share
TLB entries, but they *do* share the contents of the CPU's caches.  That
will make TLB misses faster.

It probably doesn't matter *that* much in practice because the page
walker doing TLB fills does a pretty good job of hiding all the latency,
but it might matter in extreme cases.

