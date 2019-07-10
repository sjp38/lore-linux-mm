Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DDC1C74A2B
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 17:02:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1921320665
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 17:02:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1921320665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 927098E007E; Wed, 10 Jul 2019 13:02:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D7758E0032; Wed, 10 Jul 2019 13:02:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 779258E007E; Wed, 10 Jul 2019 13:02:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 434348E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 13:02:03 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id 71so1630130pld.1
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 10:02:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=wmcNoSxNtrBptqi0z2LQMIAZHCkkrDwAPrDjrOGNN8I=;
        b=YaaFR1bbUIak0l59hzVn2MNipzH1M2Axx+++qV4pZT34YjawJoBte31CYH2ErFM0Vf
         y/2lVSPQuLFks9/54kL2NEX5k+XErl3gJvJnJ2SuRTICb9DEau8keRJqQth3zCj3tc9G
         M51ao8smg4QsLNj64Ton+A58Z2ciUB6MrXo44hcw7RlRbDEj7KRjYLnZoAmHM3J5tIRJ
         f6WWc/yYIuTINj52VlF585cedGZ++ZXT/aw6JMF8wAAdMSbrhuplnnwnCdSt2QgfSuov
         Zq9Ajq1CXjzsegVJGosoIEq7GcNq4zU+fGZlmkLlFPDcVxFzgiB3s7sQAAuhOAaYKotX
         SxVA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVpOsENvGgDrJk92LoqErxFJ9cnBgFEi8qGscJ+5ylOnZyHfksV
	hB1IRHVaja4LGZ0Vvl3eHqxkgYba+a8+/CtIRUQg8xsR039q8o4gxxmhFBH+7o/cdbgQ88efMAu
	TdJHEZfp1xM2ZUv7D6byM+NtuCDVK1RKDKlXT8GslxXwnsH7zhzDBq+rU5yW3y+oLYg==
X-Received: by 2002:a63:fc52:: with SMTP id r18mr37968865pgk.378.1562778122796;
        Wed, 10 Jul 2019 10:02:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy87l05t5ewGNpAveH0n929aO+1grVXs7GN1tUrawPljRbjuw9oa6VIA5MVJF6kgL0Smh81
X-Received: by 2002:a63:fc52:: with SMTP id r18mr37968777pgk.378.1562778121848;
        Wed, 10 Jul 2019 10:02:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562778121; cv=none;
        d=google.com; s=arc-20160816;
        b=t6GbNaW9oCbKwDwKoErEQPMkB7tvJHgWudRQtofbbciuv0LpEwNJx8zLUAct3PtpRV
         siZsmnjnH4sjpqbCHTpcArMBxH606RebSTElpssNgV9oTmDl2HUA0rWO5tyw85+/3Jq5
         HOjXaI7g4DKe+02yMpRdA3NIljDuGQS+xwGOnqRSu2JLVR5JsnGwWolU1d80hYFy8GU7
         wW4GX8aE9tvn9uAaM5glSP/++XOpyNgARFz05NjlBTv82VsMQSfaQJnlJztD0/MqrQjq
         AmebE6dVeHAHv+Vh/Q3+ZLynNqX2paqPSM9T52unTgZzdWYFAmXHcKoGFHlr59GGUALk
         1AOA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=wmcNoSxNtrBptqi0z2LQMIAZHCkkrDwAPrDjrOGNN8I=;
        b=dnpaBf+BEKGYXY7p2Uhunfr9FB3k8wwJwqqSCCgtBhyOpSBGaBKtDhbnPzGcF9zoJM
         hmiq9k7dvUtOTjnNfquTfOjR6C29bIgNqCEOOgm5H5a6dCL9uxYNJf7LQ0GoSSiA9emL
         5ww9uJI9vVwo5K/6uJSP60/xTXRKwO1PAQz48zF2C6bV6bU5g1OUgFnLcq2bbEblzsNu
         SIlyNrhhOtY2U5LZBPrGvW9ph12+v6cUnQ20IbDMB4f8Beo9js9ae3YAviDmF6NmVWCs
         +zdbWEHiWDmXGt02BEgdWLG9cbWEsK+EeCC4CeHYEUC8yITYA8n1CSAKDhR10Gy+EwpS
         q6/g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id t8si2694435pgu.288.2019.07.10.10.02.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jul 2019 10:02:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.31 as permitted sender) client-ip=134.134.136.31;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.31 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga104.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 10 Jul 2019 10:02:01 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,475,1557212400"; 
   d="scan'208";a="159817142"
Received: from akraina-mobl1.amr.corp.intel.com (HELO [10.251.14.235]) ([10.251.14.235])
  by orsmga008.jf.intel.com with ESMTP; 10 Jul 2019 10:02:00 -0700
Subject: Re: Memory compaction and mlockall()
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Cc: linux-mm@kvack.org, tglx@linutronix.de
References: <20190710144138.qyn4tuttdq6h7kqx@linutronix.de>
 <66785c4b-b1cc-7b5a-a756-041068e3bec6@intel.com>
 <20190710164521.vlcrrfovphd5fp7f@linutronix.de>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <b7689560-2254-6cba-16fe-d52829cf42df@intel.com>
Date: Wed, 10 Jul 2019 10:02:00 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190710164521.vlcrrfovphd5fp7f@linutronix.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/10/19 9:45 AM, Sebastian Andrzej Siewior wrote:
> It says "lock virtual address space into into RAM". I assumed that there
> will be no page faults because everything is locked.
> 
> The problem (besides the delay caused by the context switch and fix up)
> is that a major fault (with might have happened at the same time in
> another thread) will block this minor fault even longer.

Yeah, I totally agree this behavior can be problematic and
counterintuitive.  Making it better would be nice.

I just wanted to point out that it's probably not strictly required, though.

