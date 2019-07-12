Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3FA6C742BD
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 13:58:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9905821721
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 13:58:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9905821721
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EE798E0151; Fri, 12 Jul 2019 09:58:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29EE58E00DB; Fri, 12 Jul 2019 09:58:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 167FD8E0151; Fri, 12 Jul 2019 09:58:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id D2B748E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 09:58:51 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id t19so5752151pgh.6
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 06:58:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=9TpJgcFwmFFa9wUtlLewze46Wl1OFkSN1KSwGPLfFnI=;
        b=oM1CUAa8KBuzmKRww37OilITuu7pHUisa+L1M8To7S8XlfLha9Hq9/5GHLSKgL6CKl
         poXE2H4kJ4+Q0D0zKnq3Oe0xDBwgzIDRlJseX3xkklQIEqjkZa7J550f7A6/Bgna6Wjq
         FdxFMQq0ub7IiB4naFV6nAkYf+MhLbwNgPbe4+AN/1F4VZhHM+5Ai9+/bvrHXKgTSll9
         aNSRzoE5GOcKeTCEh4kct2nBkcOfVOfOHoClPDT1sdNHL+S8p8NWdKBKJDT8/Nyd4pX6
         Ce4iyeuybk70AAaq/sjosm/zQxsih+ogGoOPjwL4m2wQFMkhobB0JEIwYJOZPKOUHbOB
         VRZw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUmNBxYhZ0LBpAXutSPStW6ygb+yomR+DpwUYAZG9AAfZvhL4PP
	h2z5LRal9tV4JboMmVv+8dhwUWNHKFXu0+4wZpJGNd/Xgzk2I9M0ddN9qz1vwRRIRm8l3cl5ana
	zMm97+xDHjyTEMFjagrmr43vAFJrcZrrVPwZbaB4U00WvfwFsFFM4tsSpk8TBW4Zf9Q==
X-Received: by 2002:a63:3112:: with SMTP id x18mr10996903pgx.385.1562939931458;
        Fri, 12 Jul 2019 06:58:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydl7gVY3+ch3aqI3CN0pCxpIU7ASuUYm6uq+ywwFJdVycIht5tpoBP84Vs1BMU5C7qjMEw
X-Received: by 2002:a63:3112:: with SMTP id x18mr10996845pgx.385.1562939930759;
        Fri, 12 Jul 2019 06:58:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562939930; cv=none;
        d=google.com; s=arc-20160816;
        b=H0/ZnmUcL0ITKS6l8pjf2DwUwhgpRN5M1ofZ+ImIKMgDoL0jtLATD/sn1hB1ZPRCcE
         EOCd7QO2nop2Pvxaq2Kt+hJwhieyNISQF1iJNLEfJS00E4cJn9n+pCcjjtuAH/tQiFMc
         q+Ats8Wzws6K24Yj6OBrDcMsi0lqiUZwleGn1zTggt7wtSqmrfNybgKPOUoxLF8TBhj/
         VdGPlWshbweHGcg7x8An1NV+b4zSFQKoRMOEH7W05FY4OhcvQlW7KhnRqIBhlayzfaeC
         oFad3cjqIRgELpZp/RXE/hA0Ku2OzKNKahqAL+QOEGYiRE7AtvCSUpOCkqhStvP47MyV
         oByg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=9TpJgcFwmFFa9wUtlLewze46Wl1OFkSN1KSwGPLfFnI=;
        b=c95ZjHiehTpK24X1s6Z0SJ6KIcs1fcYeaHPX9LmoXnwbA8yvrI9loEp7Cd0s1Ab+wx
         n0OglsUh5BMwqRD79FOr3EnFisHcg6pbaBv7v1Yil8EAgXn42EAqhdBpWdzCkkhwHWzN
         A6vvv9kAHEdbys+Jswy0ox4yQgaeaf306aMGm5ugIsfIwb+vgGtVIvCl0YU/bpOqyo/W
         BfqQ6eNpn/7jUfm7JGwL/6yaiDqbWUN1+7BpSxmAuB+jipBiHfRFygwLowZ/praR+YoB
         CBdMt27VJhSk9MPXSmIQXwU48OdgeTYnUgWbvaVBnWw4R1HwMMCckVl39PGtb9wInExF
         /Pvw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id v76si4140113pgb.311.2019.07.12.06.58.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 06:58:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) client-ip=134.134.136.100;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 134.134.136.100 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by orsmga105.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 12 Jul 2019 06:58:50 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,482,1557212400"; 
   d="scan'208";a="166684822"
Received: from smatond1-mobl1.amr.corp.intel.com (HELO [10.252.143.186]) ([10.252.143.186])
  by fmsmga008.fm.intel.com with ESMTP; 12 Jul 2019 06:58:48 -0700
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
To: Alexandre Chartre <alexandre.chartre@oracle.com>,
 Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, pbonzini@redhat.com,
 rkrcmar@redhat.com, mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
 dave.hansen@linux.intel.com, luto@kernel.org, kvm@vger.kernel.org,
 x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
 jwadams@google.com, graf@amazon.de, rppt@linux.vnet.ibm.com,
 Paul Turner <pjt@google.com>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
 <5cab2a0e-1034-8748-fcbe-a17cf4fa2cd4@intel.com>
 <alpine.DEB.2.21.1907120911160.11639@nanos.tec.linutronix.de>
 <61d5851e-a8bf-e25c-e673-b71c8b83042c@oracle.com>
 <20190712125059.GP3419@hirez.programming.kicks-ass.net>
 <a03db3a5-b033-a469-cc6c-c8c86fb25710@oracle.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <3ccae31c-da8d-86bd-c456-5665a1d4f5b0@intel.com>
Date: Fri, 12 Jul 2019 06:58:48 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <a03db3a5-b033-a469-cc6c-c8c86fb25710@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/12/19 6:43 AM, Alexandre Chartre wrote:
> The current approach is assuming that anything in the user address space
> can be sensitive, and so the user address space shouldn't be mapped in ASI.

Is this universally true?

There's certainly *some* mitigation provided by SMAP that would allow
userspace to remain mapped and still protected.

