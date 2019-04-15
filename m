Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17ECCC10F12
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 22:14:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C33C320854
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 22:14:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C33C320854
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 610126B0005; Mon, 15 Apr 2019 18:14:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C0C36B0007; Mon, 15 Apr 2019 18:14:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 461746B0008; Mon, 15 Apr 2019 18:14:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1038C6B0005
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 18:14:50 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id f7so11189271pgi.20
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 15:14:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=B1mQmpgbq4jM/vREVhOSbh0LAmPOc4Kf9OM1+ma8qqg=;
        b=SR7v5Twls9I40QAHX77FUQAnm0YMWuMJ31QUvWEYjasLhr5ppANRl8xZo7pPEIM7RE
         lSxAxHXdd/IyjL90jTPG9vMgagjqmH+Rv7HUVINNdNHxZLTOURisOG1gmCX+iD2sAWL2
         kqmq0NX3bJTvPyeoKYmIpG3kO0hk7KnM7cXTysrelLGn99NY9Rrxl6+di+g0EHkn/Sng
         Bku2Em2R7dbDVjUzQM9uU5wgs4+FC2jzQW3myHpuLjVHeZnrUbuGOucjR5WILszGibQT
         LoexrMtGG3qy6IrsFCjKuSrvLgZLzuA1HFbtIwtK9qekRi5oVzWd4Eyybk3EaACTmiJh
         hCtg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAU4AJtrnCLh8IvECumQWMGBG/eUIFOkcrwUkLSfhONHBz8rsyvc
	G3enr/7gfV79EeUwmroF8LDhJzsv2+IXHT4abJHOvG4gcVOls+6cfQdsB12dwlQuFf/8YFaGJjR
	I5czrZbORVtkSzi6UTH1qcyCnXWX0+PbcM4LJXLK+swgd0kKbGSh7CKlPDpBrE/+uRA==
X-Received: by 2002:a17:902:b78c:: with SMTP id e12mr26112736pls.29.1555366489689;
        Mon, 15 Apr 2019 15:14:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqytLoLSIyghUK8EsfNFjsTaf+RaH2lmvmTPgPA6vyIoUqu5s8rccLAQFkQcPywVR56HQx15
X-Received: by 2002:a17:902:b78c:: with SMTP id e12mr26112702pls.29.1555366489143;
        Mon, 15 Apr 2019 15:14:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555366489; cv=none;
        d=google.com; s=arc-20160816;
        b=ej0o0M9YIB+AsSuc+XWplgw2Xwqq+sjg99Z1oU/rTPFVxAg/mwCS79GkPhwGXzX/BW
         tL4YctsizfKtwMB8fGbYA5ey1dxX1QobZ7BK/QSe7vv+mapcTssSL/TWpRKtXh0YR593
         ZxETK8WNK9hz0YD/1OqCL3+zxAdBJa3xF3EproTxYU7eGu7jL355p2wa1Ey6xBpYVx0I
         nCx+kbQ4l4zBUh0pm+wi/Ajx5Jtxm77KT9HxBdlKV9XyqcVat5pnzkq3Oslowh3Q90Xd
         ggH5Kgtd/sOYlIFMJHW/bfmf/Eq+2HJsiFRoO3rb2zcaMGFyHOo94ipKi/Mxo7Ppw0cS
         Uyaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=B1mQmpgbq4jM/vREVhOSbh0LAmPOc4Kf9OM1+ma8qqg=;
        b=XVJHCdAKZTwO80Xo54Q9P4cUd77PiStv3CYU3i52JdF2IvWqmeAuzFEuFVLX0eJpkH
         NII8410X+geAAx1QozbNtGPy4/xFykOUF8MSvd1NfY4U/KYNBSp+2gKDUBC6kPHEiYPY
         aa3zz1pVnhjG3t0Qv7wjgPDiBE4TQPiO2idw4tgorNyibYOjaCGdvyOTrx5cXMU9Wfs6
         0O2+TFYDYAqgUeNIDkQMTpwUV4eK/EXr2q8UQYg0Kixo6JVX9YLszAg4qU/ehoKjYykz
         AWPPDDMfpbqwVqcgPBZQvo5dEG2GHu632ZmmOmTYKy1iy6Dz0cRFGlSWqXvroDpzO4q5
         5oig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id a3si48660513pln.353.2019.04.15.15.14.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 15:14:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 15 Apr 2019 15:14:48 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,355,1549958400"; 
   d="scan'208";a="223807485"
Received: from ray.jf.intel.com (HELO [10.7.201.126]) ([10.7.201.126])
  by orsmga001.jf.intel.com with ESMTP; 15 Apr 2019 15:14:47 -0700
Subject: Re: [v2 PATCH 5/9] mm: vmscan: demote anon DRAM pages to PMEM node
To: Yang Shi <yang.shi@linux.alibaba.com>, mhocko@suse.com,
 mgorman@techsingularity.net, riel@surriel.com, hannes@cmpxchg.org,
 akpm@linux-foundation.org, keith.busch@intel.com, dan.j.williams@intel.com,
 fengguang.wu@intel.com, fan.du@intel.com, ying.huang@intel.com,
 ziy@nvidia.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1554955019-29472-1-git-send-email-yang.shi@linux.alibaba.com>
 <1554955019-29472-6-git-send-email-yang.shi@linux.alibaba.com>
 <bc4cd9b2-327d-199b-6de4-61561b45c661@intel.com>
 <0f4d092d-1421-7163-d937-f8aa681db594@linux.alibaba.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <42f2a561-f675-14d7-8d4f-87acfe0a18e9@intel.com>
Date: Mon, 15 Apr 2019 15:14:46 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <0f4d092d-1421-7163-d937-f8aa681db594@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/15/19 3:10 PM, Yang Shi wrote:
>> Also, I don't see anything in the code tying this to strictly demote
>> from DRAM to PMEM.  Is that the end effect, or is it really implemented
>> that way and I missed it?
> 
> No, not restrict to PMEM. It just tries to demote from "preferred node"
> (or called compute node) to a memory-only node. In the hardware with
> PMEM, PMEM would be the memory-only node.

If that's the case, your patch subject is pretty criminal. :)

