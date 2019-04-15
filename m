Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECA92C10F0E
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 15:43:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6D0720880
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 15:43:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6D0720880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 38CD46B0003; Mon, 15 Apr 2019 11:43:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 33C316B0006; Mon, 15 Apr 2019 11:43:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 22B506B0007; Mon, 15 Apr 2019 11:43:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id DED5F6B0003
	for <linux-mm@kvack.org>; Mon, 15 Apr 2019 11:43:25 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id cs14so11541379plb.5
        for <linux-mm@kvack.org>; Mon, 15 Apr 2019 08:43:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=1C/AdOFPt5lhx19izKJU0NHngsr1Eym1PiCRsgBHoTQ=;
        b=fGZqo92NHTUCYSwtCYFkaO48EHpI48meYIJC/L82fM1aRedFTY5Zd/dyqOm/Nx9W/T
         ZFo06bHVMmLUh4fdYVigE6u4Yn1huGhmGhffVA5e5QbGIKoFOCUawwWFI/iRK/zSx0v8
         LGBXTLeXqGZXWTA+CI2fsI8dVAgCTQ2UKASt+1HLVQ6t6nSgvr6nAOx3DvE9kgFcyp6e
         rJNPgmIMn01I7jLAUy/ADNF1STycsQrMef3akDsLIukQpEU7jGb7Fz4lKprY92OwRHlV
         Jga3PdTTy/wGp3Cyl56FA0wE0PUQJjKUwPP9DmtBdVz5JJX9F9CgB19P2L9V9p1jHS4h
         T/UA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUXQf4ORXFsq38MXG1TDuoNaDZxAQGHfxzBUwkMpmSBk20G740i
	cfK8Ydh8wniuAymC8FyuF8Sbt9zyx60juJEPzminHbnhXCGaOdNekV//f70abCVbOy7QwIjXIED
	krTNOcQ+urqvwXE8tDUACWUjMHvd+etunlluTgxuir32VRYnWp08jPkrwt/IeqM6wOA==
X-Received: by 2002:a63:1749:: with SMTP id 9mr68160504pgx.94.1555343004372;
        Mon, 15 Apr 2019 08:43:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz/40ONZF3vFbbiGYe8Y3cQEgI1hnsaQ0H9ZpGklC9nQCJCW+31D9VVeY+E6MGVJRd3RxR+
X-Received: by 2002:a63:1749:: with SMTP id 9mr68160114pgx.94.1555342999810;
        Mon, 15 Apr 2019 08:43:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555342999; cv=none;
        d=google.com; s=arc-20160816;
        b=04S4K4zilfDBYZ8XfAoXT2KxcnY9OyFGUsYyU2AXsZi+DptVMdcdD4Gl3rm8QrqQvQ
         tYoixnqisUAgimaVRu+/qqkJ+/AJ3IApfZeI2k4oimp/2COdBTzqYa6AoRIU+Qe+4ITt
         qF4HJv+HbF+F3C0UTNZvhIGOV7zgEnbq48NraGWHJqOaj0cgX/NiSm2gvsNwxN3sig7G
         AJ6CkzXLABKPSMA5gH2E7ttdoS/cZeTVCx+NBgbaQabB9HB+Bn1NYBNVT7/GecCNLUW7
         H8g8n//Fu9SnzNiFWCLAu9dJiZKFUDbVWjFOfUL3eQBFPB7yOp1EXK8aGUQR9d5vnwaI
         Q1zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=1C/AdOFPt5lhx19izKJU0NHngsr1Eym1PiCRsgBHoTQ=;
        b=cVA4wb6fpIkVDO7An7w/kFKgw6OiysR8LaCqZBcr4VDrVg0DEAyeUYh5GOPuXuJJU5
         SZCAQQ/9HCY/CGZPlk5ZfGYdJK3t/lwUsTHgtLdlXknQUX/HJa7dEuKozeygmAhFQgBz
         lgda8dxbK+BPLk8/+BtjYgReGOV1gvwjnNVAfFVG9H6Pbn3qcYCffqIYv+zXD2vL3B9p
         3rBkx2gWKXubUCz99d24WyEkzrWoIMvAB83QX+qn0w3hOrPjVuoLJ9ya8IaSMdJJiyHX
         Nn2tUcHDhYDnUN+aN1ASMp3Y/y5bUnK9AhkKaorH0D/G7vZY75U7VVIJfjciH0Hd75GB
         E19w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id o8si15915200pll.391.2019.04.15.08.43.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Apr 2019 08:43:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of dave.hansen@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=dave.hansen@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga003.jf.intel.com ([10.7.209.27])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 15 Apr 2019 08:43:19 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,354,1549958400"; 
   d="scan'208";a="142906558"
Received: from unknown (HELO [10.7.201.126]) ([10.7.201.126])
  by orsmga003.jf.intel.com with ESMTP; 15 Apr 2019 08:43:18 -0700
Subject: Re: [PATCH 0/2] x86, numa: always initialize all possible nodes
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>, Peter Zijlstra
 <peterz@infradead.org>, x86@kernel.org,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>,
 linuxppc-dev@lists.ozlabs.org, linux-ia64@vger.kernel.org,
 LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
References: <20190212095343.23315-1-mhocko@kernel.org>
 <20190226131201.GA10588@dhcp22.suse.cz>
 <20190415114209.GJ3366@dhcp22.suse.cz>
From: Dave Hansen <dave.hansen@intel.com>
Openpgp: preference=signencrypt
Autocrypt: addr=dave.hansen@intel.com; keydata=
 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
Message-ID: <77b364e5-a30c-964a-6985-00b759dac128@intel.com>
Date: Mon, 15 Apr 2019 08:43:18 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190415114209.GJ3366@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/15/19 4:42 AM, Michal Hocko wrote:
>> Friendly ping. I haven't heard any complains so can we route this via
>> tip/x86/mm or should we go via mmotm.
> It seems that Dave is busy. Let's add Andrew. Can we get this [1] merged
> finally, please?

Sorry these slipped through the cracks.

These look sane to me.  Because it pokes around mm/page_alloc.c a bit,
and could impact other architectures, my preference would be for Andrew
to pick these up for -mm.  But, I don't feel that strongly about it.

Reviewed-by: Dave Hansen <dave.hansen@intel.com>

