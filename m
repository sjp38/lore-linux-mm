Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 643F3C10F0C
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 13:03:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2DC902075E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 13:03:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DC902075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0D686B0003; Thu,  4 Apr 2019 09:03:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ABE5F6B0005; Thu,  4 Apr 2019 09:03:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B0456B0007; Thu,  4 Apr 2019 09:03:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4892D6B0003
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 09:03:16 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c41so1367050edb.7
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 06:03:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=WPlEIfMarxdMuwuQN+csUicmM1PpW6F5XI6wi3gLWA0=;
        b=Vbi0K2xTIa25YjAx52/7VwF8kEqSls4OUeBmcRMPuRr5TUs7yeSovrCfMT64RSBQpl
         Q5kT6P8rXsntG+IPRi9fXkNLNW0Rqyw34QyQ7vqoSUDkwLsxJxmsy4BXAB9YGCtE1D3Z
         dPnbtoKC5IY+/qX8t/zCD7PalwHJJch8X1FCoJtaXIJUpgeT2sPRdTPN2n+87rgrgsGt
         bM+4oVgYA3omH7CYozGgu+HA9Ll/HxjVS4pVzvAKMfhvAOlmz10MpYvZBVAcy8Jj0CcK
         wRn9uWU2EwqH2kb6LqxrKYKSVqS7sRqgcs/svMaqo28EYrc7KVWku4e3c446CS37LKXY
         Pc+Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAVJaasOk+RHXJhkWhYh9etTVdsta5W4QfBteKHekRuPbcJ/OpGt
	JRfLBfCNVXony/QkQhPQeoKlQ3KEg3SU0O5qtPEIMonsnvq/rvt3ZwDXDz77ZXlyKr+J8UfNKGd
	4ZxHle05E9gz2zqEIXN9ny2aACHqsq7qKqroQM+2Op6DjqDYMULL5X9h7B1D+zoWVpw==
X-Received: by 2002:a50:b6d5:: with SMTP id f21mr3762178ede.105.1554382995852;
        Thu, 04 Apr 2019 06:03:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw14MJCPQZ+jP+hOZ5OQuuMpbcQMLZ23hd3v9ucNShHyarkYT44jXyufGYv07dOJtcIE1DQ
X-Received: by 2002:a50:b6d5:: with SMTP id f21mr3762105ede.105.1554382994671;
        Thu, 04 Apr 2019 06:03:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554382994; cv=none;
        d=google.com; s=arc-20160816;
        b=kbKH8KJsYD/Kf93ZaX+topbL9jkgR6tpNx+6mH0mE+nMaKayw9Ko1GZJXIKfCGxwEg
         TCVp3nxrW7rRwd1C26wXIcScSQ5LQvVDlTrjWWsNQKwUWPV+4DOxEDvOrHzU0qrKE6ca
         ympi3QbYBig8lEDQVyQn3BzyCIgaEwTSICvzCbnHzozWq/4JE9GrWwdvY2ywwwEV8SiC
         RHeN5P0Bk0gnpprwq81mqSdbpOST5xUYcnNVaYYBitlIlAAduF8HXu+bx8ndpSEB+6iB
         B8NPXs8sjWAIE4y9GSN0ZvzZAtAXwj3Geyl0HRZah5QxlAwZTReoHaS7IW0ovfkqK+Z9
         S+OA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=WPlEIfMarxdMuwuQN+csUicmM1PpW6F5XI6wi3gLWA0=;
        b=Ou8xU6b4VvGn30Kk5y7f81baUgYcCOAJkfhr8mQvWM+rt5U7FG/zrqyc8isUMDuAS5
         qpitVYT/UQEpgHCmYWUShLA0X0hlsMSPz67PeM3nHg9zENXekPfQ2qPx9zXQw0x+fm2V
         ibuRvRnAwNNZ9r8uXdIZvXZpxYB7bEYcBzgzCj2Z9zhAP4360v+6jxEoNTE4VZ5UOyvS
         8ogb1R8qTrUQetV27Sle7Re7+xm5Ytv7xBjwIgVnT5F4S00ID8RVUjAHQHIl7js9K6Ng
         0bqQq2muO9II6q3NrJw7aDoCOjhTax/DuZ6Y7ikQgtF+6+F+14931ntBewpWTgP+SRmR
         AhTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w20si6895105eji.303.2019.04.04.06.03.14
        for <linux-mm@kvack.org>;
        Thu, 04 Apr 2019 06:03:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7D90AA78;
	Thu,  4 Apr 2019 06:03:13 -0700 (PDT)
Received: from [10.162.40.100] (p8cg001049571a15.blr.arm.com [10.162.40.100])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C40303F68F;
	Thu,  4 Apr 2019 06:03:07 -0700 (PDT)
Subject: Re: [PATCH 2/6] arm64/mm: Enable memory hot remove
To: Oscar Salvador <osalvador@suse.de>
Cc: Robin Murphy <robin.murphy@arm.com>, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
 akpm@linux-foundation.org, will.deacon@arm.com, catalin.marinas@arm.com,
 mhocko@suse.com, mgorman@techsingularity.net, james.morse@arm.com,
 mark.rutland@arm.com, cpandya@codeaurora.org, arunks@codeaurora.org,
 dan.j.williams@intel.com, logang@deltatee.com, pasha.tatashin@oracle.com,
 david@redhat.com, cai@lca.pw, Steven Price <steven.price@arm.com>
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
 <1554265806-11501-3-git-send-email-anshuman.khandual@arm.com>
 <ed4ceac4-b92c-47f4-33b0-ed1d0833b40d@arm.com>
 <55278a57-39bc-be27-5999-81d0da37b746@arm.com>
 <20190404115815.gzk3sgg34eofyxfv@d104.suse.de>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <0c2b5096-a6df-b4ac-ac3b-3fec274837d3@arm.com>
Date: Thu, 4 Apr 2019 18:33:09 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190404115815.gzk3sgg34eofyxfv@d104.suse.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 04/04/2019 05:28 PM, Oscar Salvador wrote:
> On Thu, Apr 04, 2019 at 11:09:22AM +0530, Anshuman Khandual wrote:
>>> Do these need to be __meminit? AFAICS it's effectively redundant with the containing #ifdef, and removal feels like it's inherently a later-than-init thing anyway.
>>
>> I was confused here a bit but even X86 does exactly the same. All these functions
>> are still labeled __meminit and all wrapped under CONFIG_MEMORY_HOTPLUG. Is there
>> any concern to have __meminit here ?
> 
> We do not really need it as long as the code is within #ifdef CONFIG_MEMORY_HOTPLUG.
> __meminit is being used when functions that are going to be need for hotplug need
> to stay around.

Makes sense.

> 
> /* Used for MEMORY_HOTPLUG */
> #define __meminit        __section(.meminit.text) __cold notrace \
>                                                   __latent_entropy
> 
> #if defined(CONFIG_MEMORY_HOTPLUG)
> #define MEM_KEEP(sec)    *(.mem##sec)
> #define MEM_DISCARD(sec)
> #else
> #define MEM_KEEP(sec)
> #define MEM_DISCARD(sec) *(.mem##sec)
> #endif
> 
> So it is kind of redundant to have both.
> I will clean it up when reposting [1] and [2].
> 
> [1] https://patchwork.kernel.org/patch/10875019/
> [2] https://patchwork.kernel.org/patch/10875021/
> 

Sure. Will remove them from the proposed functions next time around.

