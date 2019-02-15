Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AC13BC10F02
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:16:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 74FDC2190C
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:16:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 74FDC2190C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E72A8E0004; Fri, 15 Feb 2019 12:16:40 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 095648E0001; Fri, 15 Feb 2019 12:16:40 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E773F8E0004; Fri, 15 Feb 2019 12:16:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9FEB28E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 12:16:39 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id l9so7286407plt.7
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 09:16:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=3TkYxXz1cCrttC/GyAwAscymYZ9JXXxgKlqP0alrrHc=;
        b=RHh7kzVH6UbaELOBOUkPI7OsFFZEdwN+gNMq9XTJaFamNPNgYmxuCkbCXTxrBioik0
         zQQk1Zmx42yEn1w1zBbVDm2s8XBBuHSuLVS3UaD867EtvoKuDnsXmEMqBDeM6sbAj2ue
         3Z2qcFHgX7wsNUxltq46Tk+EHpVWZtB07p11M5K8BjrlBN0umJ6ln5fG4BgvUWT/+LUG
         p+QLtf/sK5vpbUDRtfgQJeQUaYxVohuPEsPgpaT562g9SF+huKz/1KJqgGoilAEb7xvP
         4I02KHHh0cohscgoPU9ZKJBwDsyBbLYrrMZn/LLJsFf60pB3ql9qSo42ZOzI31aMpYW8
         OZbQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: AHQUAuaINU0SrcdLM0vpD9ZDbJERw7oSCBEUmKj2McclgoQfT39a52XE
	Q3mLcI9Jo0iTkdoVQBT6RhaDEIq76nC3Rvne3ygcGEwquiu37reRcauhILZ7WX8M2U48kPrZw0N
	Pab9+vGyaK6lyASc/JorNfM7Ok967ZIGI0/sH0/5lb7BdoIyR/seDKrMyxvK3DIV2Sg==
X-Received: by 2002:a17:902:c05:: with SMTP id 5mr11331882pls.155.1550250999334;
        Fri, 15 Feb 2019 09:16:39 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZUXcFhFdejZMhPo6mr+eK7mCU4Q0bEJA/jUOQchtFrFR4ruB4weHC2fHGIrqk/YDYRu+WT
X-Received: by 2002:a17:902:c05:: with SMTP id 5mr11331835pls.155.1550250998685;
        Fri, 15 Feb 2019 09:16:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550250998; cv=none;
        d=google.com; s=arc-20160816;
        b=C3uy4+oHPx52lz8+EDN2cg2P5n6lhaOPgn1UdR0mKGvPs6BnAaEeyEaiEurLaq8/Ul
         /sCWvHPFNP7IvLdCKGDP/2ktnBQT0Bwb1j4//FkVjgCRb45tRIQPuubmUZl1kGaZyS+K
         QnM3EqUU8xpve3Rsv/+RaDbLOz9KyMGEOOp323YTNf8C6EcIsnVzJFmXIpfukqPgbYxW
         CqCrg3TGo6u6DwmCGGe5QcyCDyeA7MpucthV9sD3bYjmw5VPYmvNKBhqmD8mXpA2hBXn
         DzsOBRxy/2X8RVd5vtUHQN2hKdoM0fra7HuRdrILPYcrv4yxt2mHpx1uny5dt31VHVCK
         Ydew==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=3TkYxXz1cCrttC/GyAwAscymYZ9JXXxgKlqP0alrrHc=;
        b=EW+N1C4juFKO8vqnFjzVe4/3x2RLzLyNke3hhDKt/HCs9uWG1F2mP+F+XjUbhD+SPW
         jwIQTpQ3N+I5u7Aa5fslC7vMBnwEF6zdxwt8kyAfsmyODSfZoe7ER9cIjM4LhUcBDUiG
         QNd52KsImvXOXOI9rfiQ7pEps9UNv3BKB9M/x3MDNYZtvnMLLjIMJrJNU8r/XD5C3+Kz
         aO9k/SBe4W06EWFzA90brlPgbxDXGdUFDjCIbvMusiWV+KP6r6sSEhKpQKAvujpSYkaE
         uEa22P+8+TWB/E7juEqvsaV5CtUeXRqw94odQE3lWEqZxvhs0MQfu7Yn/pjdqzqYdTT4
         0acg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id y7si5766956pga.296.2019.02.15.09.16.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Feb 2019 09:16:38 -0800 (PST)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) client-ip=192.55.52.151;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.151 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga107.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 15 Feb 2019 09:16:37 -0800
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.58,373,1544515200"; 
   d="scan'208";a="138945667"
Received: from unknown (HELO [10.7.201.17]) ([10.7.201.17])
  by orsmga001.jf.intel.com with ESMTP; 15 Feb 2019 09:16:36 -0800
Subject: Re: [PATCH 13/13] x86: mm: Convert dump_pagetables to use
 walk_page_range
To: Steven Price <steven.price@arm.com>, linux-mm@kvack.org
Cc: Andy Lutomirski <luto@kernel.org>,
 Ard Biesheuvel <ard.biesheuvel@linaro.org>, Arnd Bergmann <arnd@arndb.de>,
 Borislav Petkov <bp@alien8.de>, Catalin Marinas <catalin.marinas@arm.com>,
 Dave Hansen <dave.hansen@linux.intel.com>, Ingo Molnar <mingo@redhat.com>,
 James Morse <james.morse@arm.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
 Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will.deacon@arm.com>,
 x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
References: <20190215170235.23360-1-steven.price@arm.com>
 <20190215170235.23360-14-steven.price@arm.com>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <59a6d402-e383-b9d0-499a-7d65b9a2d402@intel.com>
Date: Fri, 15 Feb 2019 09:16:37 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190215170235.23360-14-steven.price@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/15/19 9:02 AM, Steven Price wrote:
>  arch/x86/mm/dump_pagetables.c | 281 ++++++++++++++++++----------------
>  1 file changed, 146 insertions(+), 135 deletions(-)

I'll look through this in more detail in a bit.  But, I'm a bit bummed
out by the diffstat.  When I see patches add a bunch of infrastructure,
I *really* hope for code simplification.

Looking at the diff, I think it gets there.  The code you add is
simpler than the code you remove.  But, the diffstat is misleading.

I'd probably address this disparity for each patch in the changelogs.

