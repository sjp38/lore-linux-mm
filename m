Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D4DAC31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:30:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EEFE1208C3
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 16:30:47 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EEFE1208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C8A76B027A; Tue,  6 Aug 2019 12:30:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 979866B027C; Tue,  6 Aug 2019 12:30:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 840926B027D; Tue,  6 Aug 2019 12:30:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4CC116B027A
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 12:30:47 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 6so56251675pfi.6
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 09:30:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=l584KyE9rpCvZet0nUy/dgub6TiTca54EThUDpsiB2Y=;
        b=Z+vp+USnlrCw9uk6kvybQA6/GkarhFl+Xt+FlXud1HEBWIMcvptU3BajwYwww0wDzB
         pUoXFB7q08m2iH9uSV0W/LVRsAigNXGNsV8kCaxwYsrJQr9Gs2ZZhbcpo7zKvmvdGWbh
         bV64TMNYcHHBGObkLDQtpl0pS/YZ/3qEJNKifnfRrsg9jjHl3ClyEyxzfZTV/82EjKDW
         ftevTuafMW7a07KGbDem+3MpyZ5TEoA/K3lx/ukLQd+NbOkkPJk56qdN5GeKGqKa8Lxk
         tkfNxl3GI2qTt7NU3LaTgHdD3fEd8QlRf7T4uYzWXCWCxS0gEBtU1aCaMSuV1TCfrOG3
         fWIA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVYsh62RgSFD+ovddWYQxrkW2Nf3TOF1oqf41ZzgcKS7IYya9qK
	E+VlSp3BtjSc2wqzbaFI161U21IoIG4743JuJVmnKMRi74kVduRy2wufX3XCKKAOOb1a9bSSyxD
	/De+ChwN/6Jrh1a3akCCQXpghw6W+49GuhRzUCEkbldIWsLExn1saMRAaLTJYQ4SDfQ==
X-Received: by 2002:aa7:9713:: with SMTP id a19mr4590752pfg.64.1565109047011;
        Tue, 06 Aug 2019 09:30:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzpqbBubg+iIXoiNdth5+qAcdnWti63L89MQDICAeYJWncam8J4ve9AA9uKrUVykQisk7H2
X-Received: by 2002:aa7:9713:: with SMTP id a19mr4590667pfg.64.1565109046215;
        Tue, 06 Aug 2019 09:30:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565109046; cv=none;
        d=google.com; s=arc-20160816;
        b=vk1cm7MZNFLdOlsNzNUgKHUI3iVVBbVxdYQxyIQNyMrd2EEjqnj8C8S4lYuJMinwu5
         fhMeTJ8hqzesP9wZuykoTr9LynDJjOP/gIJsUVC0sJHFYT8ENcM4otMNE7jTcXa1+myA
         SE8I1A5TpFskZjtLvd3pW4Z2nsx+rmWmrXUvrisVmCsqma22/6Bw+VaBu3UjRwLuMx2x
         92y6THa049FHZ2EN2pgXJynKuP4VnCjYMBVgt1wfToI9oXOPXvMAz+I+Qm7Lh6j07agt
         zrP+g5KlItaAiGhFgovzbfJNR8CM7WyiQhMoOYv14Tz/xv/P1R1A2r7RO3EISet+PsXO
         TnpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=l584KyE9rpCvZet0nUy/dgub6TiTca54EThUDpsiB2Y=;
        b=Bk9eBTq4v4txQMzpSpBNRrBilZILkNzrCgNhl6TXGiG/m9U7ms/9MRecVKDlHVTuL+
         C7AMXUjnC9IW8H5zf7TfTZgmA2daJleZrxCToX7Wpx4UrLvooVLLr+EWDCjT+MK3ecEt
         0Mg7RNOyRrfLL0Lx08QiLiWVMczZZ59jQZdqDEnIsd8z8dWSu/BldZLdPKevTrwQCO22
         vN5twxAWUN4n1kLSCJmDUM904yL+9zpBXIYY5JN8FSYhjWsmzbuZ6OPIM/XChvPPnVDA
         pHQaQruZY8BSw0E7mXFRTNjdvba+Jzi3IPBX4fPcEwn5NI8kYA5hFanltq5CImiZ4Fye
         /amw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id 31si44493493plk.342.2019.08.06.09.30.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 09:30:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Aug 2019 09:30:45 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.64,353,1559545200"; 
   d="scan'208";a="179200133"
Received: from unknown (HELO [10.7.201.140]) ([10.7.201.140])
  by orsmga006.jf.intel.com with ESMTP; 06 Aug 2019 09:30:45 -0700
Subject: Re: [PATCH V2] fork: Improve error message for corrupted page tables
To: Sai Praneeth Prakhya <sai.praneeth.prakhya@intel.com>,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Ingo Molnar <mingo@kernel.org>, Vlastimil Babka <vbabka@suse.cz>,
 Peter Zijlstra <peterz@infradead.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Anshuman Khandual <anshuman.khandual@arm.com>
References: <3ef8a340deb1c87b725d44edb163073e2b6eca5a.1565059496.git.sai.praneeth.prakhya@intel.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <73b77479-cdd2-6d53-14ae-25ec4c4c3d25@intel.com>
Date: Tue, 6 Aug 2019 09:30:45 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <3ef8a340deb1c87b725d44edb163073e2b6eca5a.1565059496.git.sai.praneeth.prakhya@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/5/19 8:05 PM, Sai Praneeth Prakhya wrote:
> +static const char * const resident_page_types[NR_MM_COUNTERS] = {
> +	[MM_FILEPAGES]		= "MM_FILEPAGES",
> +	[MM_ANONPAGES]		= "MM_ANONPAGES",
> +	[MM_SWAPENTS]		= "MM_SWAPENTS",
> +	[MM_SHMEMPAGES]		= "MM_SHMEMPAGES",
> +};

One trick to ensure that this gets updated if the names are ever
updated.  You can do:

#define NAMED_ARRAY_INDEX(x)	[x] = __stringify(x),

and

static const char * const resident_page_types[NR_MM_COUNTERS] = {
	NAMED_ARRAY_INDEX(MM_FILE_PAGES),
	NAMED_ARRAY_INDEX(MM_SHMEMPAGES),
	...
};

That makes sure that any name changes make it into the strings.  Then
stick a:

	BUILD_BUG_ON(NR_MM_COUNTERS != ARRAY_SIZE(resident_page_types));

somewhere.  That makes sure that any new array indexes get a string
added in the array.  Otherwise you get nice, early, compile-time errors.

