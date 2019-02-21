Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 97644C00319
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:14:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FB312077B
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 23:14:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FB312077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A89DF8E00BF; Thu, 21 Feb 2019 18:14:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A39598E00B5; Thu, 21 Feb 2019 18:14:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 928568E00BF; Thu, 21 Feb 2019 18:14:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4FC5A8E00B5
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 18:14:51 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id a6so284781pgj.4
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 15:14:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=ZtLaalkDTqQ1h9i4NLGncbmxKu9Ou+uPxS8O3Sw8HfA=;
        b=Xk7wNaFsJj/U2epdYS4FSljsILVYRsX4dAHskYl3tUQK5VHeE9L4t2fuWY6+waj46R
         OiuynHFVGF7wl0QDN+d+oGXlEb5bE304kGbNujV9u8r7tCT7ThYhKBsZtTX//Xz+bB9R
         T2p2ve61jh86t2nRMRhyEaKz72VT2kmvWiTLj91/OXyeCknnJOR9JYWlfWgs8g9oiwwF
         6i0Xd0dZJ6lPn0h0dLu75Wn+auZITRkD4B1gC9PQMMGwgjyeU7TQ+JjVnRZjn+wU5uQ9
         sGDiVjw0l9RJ7kPgdIlAxoehmxVXonscXY2WeQZNSAuXvEhpQ8qm0BoA1sJtkTe2Xg9Q
         UP5g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAubR9WFhqYrp0+HgCvh0Ayqu8+Xhefq62zhexRQUtQmt0KnnReMI
	konnq24Y3VEwPWmN7/ZKlJs4rbASg4klovzRPsfXm7tHYrutzJLGoyfn/03PaMWVeQ6ZlTUiAiM
	tIN+3fUcBGG1pCnxCDljMDdZxgGJew86ohtTiAhjRyqwWlGB+tDvLf7cXVed3eLAStw==
X-Received: by 2002:a63:eb56:: with SMTP id b22mr931054pgk.287.1550790890994;
        Thu, 21 Feb 2019 15:14:50 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZWmQ3w3psT4xnxw+RVKYFSAk9M/lssQHFu8mqJCb285ycuiT5qvUVDyGwgmTJYKTMAjG8/
X-Received: by 2002:a63:eb56:: with SMTP id b22mr931014pgk.287.1550790890299;
        Thu, 21 Feb 2019 15:14:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550790890; cv=none;
        d=google.com; s=arc-20160816;
        b=I3VpiC/i1o+eymH0Go155DdXsEbuZ2I7yZNadRJW5OZY7xqlv7CPknBKi9T7ArPk4G
         szj8jrBGCZxmC3ADz8lDpvMveHmNH5hwR/57n8gTQxNNIKz6EEWm/7iKeilFU+gjWYda
         lZ6SmPoAHm3dZUXp5tgUxuzAl6fhlCioHLTsh+28t8Cs3y7OrjzDT1jQVdBO/N71cTMB
         0eWwn+UsPwCxu0YBrU5EbxbSMy2nTuEXf4QOfZeHh4OJoA+VUu381tNaWYDrOiQndp5o
         aoc3K7AofrN6k6VoK4MLFK/5PV5G3JIs+YbVW4CxEa3Ac1RpvIHsvSo30d8R2P+xjvak
         16HQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=ZtLaalkDTqQ1h9i4NLGncbmxKu9Ou+uPxS8O3Sw8HfA=;
        b=tjr6ROPEtjo5bIIPNoaa57iz+UHay4fHYrYz7/KV2tbAUtCn5d0IQks0sV5+gwIKHn
         zhPixXj9oEgPKVgrsr9MOlHC04apNB1OGhnYBtEB8FGlbQFzO1zs7TNZfLE72RAPSblx
         SOVur3Wl4USQL/m3J7y4Dee9NlBjXAcQ56fGgkSEKWipcq0RqaQQv6S63hQMhNjRc+0w
         tOskCsTRPyFXi/aTk54rVN622Zbx3U8/4owQuSJi1vAUaWW/uolyANq8lcBWfOAxZUsq
         SJf6hOd85iEsi0g3/SSeXr5oZ/Q0LLEqQ46CPl0QnwE0fFu89Ifg4rT9xK5Ok4bqp6IP
         ZuaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id w12si157465pld.183.2019.02.21.15.14.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 15:14:50 -0800 (PST)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) client-ip=134.134.136.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.65 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga006.fm.intel.com ([10.253.24.20])
  by orsmga103.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 21 Feb 2019 15:14:49 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,397,1544515200"; 
   d="scan'208";a="321058367"
Received: from sthulasi-mobl1.amr.corp.intel.com (HELO [10.254.86.146]) ([10.254.86.146])
  by fmsmga006.fm.intel.com with ESMTP; 21 Feb 2019 15:14:48 -0800
Subject: Re: [LSF/MM TOPIC] Page Cache Flexibility for NVM
To: Adam Manzanares <Adam.Manzanares@wdc.com>,
 "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 "willy@infradead.org" <willy@infradead.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "yang.shi@linux.alibaba.com" <yang.shi@linux.alibaba.com>,
 "dan.j.williams@intel.com" <dan.j.williams@intel.com>,
 "cl@linux.com" <cl@linux.com>, "jglisse@redhat.com" <jglisse@redhat.com>,
 "mhocko@suse.com" <mhocko@suse.com>, "jack@suse.cz" <jack@suse.cz>
References: <85ddda85755bf15ed2e56bce21f711ae8154d304.camel@wdc.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <43c53a7a-63cc-1968-eb5f-59115f918441@intel.com>
Date: Thu, 21 Feb 2019 15:14:55 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <85ddda85755bf15ed2e56bce21f711ae8154d304.camel@wdc.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/21/19 3:11 PM, Adam Manzanares wrote:
> I am proposing that as an alternative to using NVMs as a NUMA node
> we expose the NVM through the page cache or a viable alternative and
> have userspace applications mmap the NVM and hand out memory with
> their favorite userspace memory allocator.

Are you proposing that the kernel manage this memory (it's managed in
the buddy lists, for instance) or that something else manage the memory,
like we do for device-dax or HMM?

