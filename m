Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DD4ABC5B57A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 17:38:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B24D1208E3
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 17:38:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B24D1208E3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 35F4C6B0003; Fri, 28 Jun 2019 13:38:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 30F328E0003; Fri, 28 Jun 2019 13:38:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 225958E0002; Fri, 28 Jun 2019 13:38:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CBCA96B0003
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 13:38:16 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d27so9983596eda.9
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 10:38:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=MmfTpmZcI3acQ9BhMYG4Yl3MVtM2/XDpNgH3izCvOp8=;
        b=pJzxDU+LiR1p/lGd74b9RmiEF5JSNFJTJYMz843g+mDuuA5EzPocvmzUdPKpR5XkNC
         81J6EvCryUBozZV7U3kLxiwOhbCBaqjSd+R6BeXRoDC7NlJFL06xu44BlIHTv8zJQ3A+
         IvsGUJzWoS2nVfRghfLPdX+gOLL5tdWxlGFgNHwcP9vs4b2T4bvXxzy5B8vexpaveHB/
         7vIJo7NG+rKQHwBinUoeg3QBP8RdSa0WEGEASCtqh39moA5MZRX2E6NZge4rhRyWLX43
         Lvf0adGrN/t0gWprB2xVISWlJICblwqWN7F1qQCBM76mysTY3K3RToWdvJZfiJDFA6BP
         VgQA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Gm-Message-State: APjAAAV8Gm+qaX4jtkWcSVFaLaoKqwjHw1Eqj26didK7Of1zTnm+CeMA
	Qc26CcYFww1QTNrkq3x/FrqaH3cwJJHPNmqi5bC7mG6IqpXlUNWhmNdkeuW09Ns/W/2CJVty09Y
	rtGAH1TaVo3MvjsL3bzD5+nZUsGRdcNwtoNJVqIoppMebvsZGzgW/MmtufLpf4YXYyg==
X-Received: by 2002:a17:906:5284:: with SMTP id c4mr9769675ejm.184.1561743496228;
        Fri, 28 Jun 2019 10:38:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwz8ljQUs5i0woCGrwfl9AoXbArTQvo85RoG4Vg48Mrij6n9cmZRB37bkY7t0oVu85ij3AX
X-Received: by 2002:a17:906:5284:: with SMTP id c4mr9769615ejm.184.1561743495481;
        Fri, 28 Jun 2019 10:38:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561743495; cv=none;
        d=google.com; s=arc-20160816;
        b=CNhDcHXvXdNdgK2YXnnpUB9wt2JYIF5QzMPpadEV3/S88HEGOfpZSeeZ3N/gKz/BzJ
         0MRnL6vO/dvasaeQEKfO2tcWqPd2ElpZYfYW5GxFYYnfwrjYtjJeAg5iLzBAvGUY3ew/
         ZzcIVPvnWGH4rdWh/J4YCKP+5kgu8oyM8ElxehHJUWBGiwSPWVyAbwZT2CsbynNbFsG3
         oEfwNRUDEbG4kMA7l9+CdwCrbycsHx1dz0auN8+ye8bUV1DYj6br2LcH4Wbufw06bR7d
         lMPeYrFT1G3tQqDwc/NErRHIdrlRuWSF4f10Qb+bLqEnQKHqnM8iWsd/h2lifjfIk/6e
         ZmNA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=MmfTpmZcI3acQ9BhMYG4Yl3MVtM2/XDpNgH3izCvOp8=;
        b=qDGTs30S1CE+aBwSoYwyT37NUPApZebAw1YvEY7BTXQDsxuiHfyTARM87YeVt8Umhx
         bWw6qxE7YX3ZZaj/jbcFXxSUTCk1F0TVJBcknhpDOlZPKnGu62Uzt/ZQRUabH4rjLDIv
         f7PYJ8KBDkK1psj+FHLA3xOM03Cp9bWhmVY915X5F4iWG1Aw4O+RoM26fcGMpjJ7xYmF
         ubiKcwNw+ovv9FfTgecXrpXHZ2P309CYNiRNFLMxbKWmeqEprtrOeGHnBmROJvjlcIC5
         KJ3kdQaRnpWd2lyoht2PS4fHg7/wnAO5gKMdHD2E2GlhWptrf6yS7Zbl5B4975izlR/9
         lTig==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v1si2031342ejk.50.2019.06.28.10.38.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jun 2019 10:38:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id A22D9ADEA;
	Fri, 28 Jun 2019 17:38:14 +0000 (UTC)
Subject: Re: [PATCH] mm: fix regression with deferred struct page init
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Alexander Duyck <alexander.h.duyck@linux.intel.com>,
 xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org
References: <20190620160821.4210-1-jgross@suse.com>
 <20190628151749.GA2880@dhcp22.suse.cz>
From: Juergen Gross <jgross@suse.com>
Message-ID: <52a8e6d9-003e-c802-b8ff-327a8c7913a5@suse.com>
Date: Fri, 28 Jun 2019 19:38:13 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190628151749.GA2880@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 28.06.19 17:17, Michal Hocko wrote:
> On Thu 20-06-19 18:08:21, Juergen Gross wrote:
>> Commit 0e56acae4b4dd4a9 ("mm: initialize MAX_ORDER_NR_PAGES at a time
>> instead of doing larger sections") is causing a regression on some
>> systems when the kernel is booted as Xen dom0.
>>
>> The system will just hang in early boot.
>>
>> Reason is an endless loop in get_page_from_freelist() in case the first
>> zone looked at has no free memory. deferred_grow_zone() is always
> 
> Could you explain how we ended up with the zone having no memory? Is
> xen "stealing" memblock memory without adding it to memory.reserved?
> In other words, how do we end up with an empty zone that has non zero
> end_pfn?

Why do you think Xen is stealing the memory in an odd way?

Doesn't deferred_init_mem_pfn_range_in_zone() return false when no free
memory is found? So exactly if the memory was added to memory.reserved
that will happen.

I guess the difference to a bare metal boot is that a Xen dom0 will need
probably more memory in early boot phase, so that issue is more likely
to occur.

In my case the system had two zones, where the 2nd zone had some free
memory. The search never made it to the 2nd zone as the search ended in
an endless loop for the 1st zone.

> 
>> returning true due to the following code snipplet:
>>
>>    /* If the zone is empty somebody else may have cleared out the zone */
>>    if (!deferred_init_mem_pfn_range_in_zone(&i, zone, &spfn, &epfn,
>>                                             first_deferred_pfn)) {
>>            pgdat->first_deferred_pfn = ULONG_MAX;
>>            pgdat_resize_unlock(pgdat, &flags);
>>            return true;
>>    }
>>
>> This in turn results in the loop as get_page_from_freelist() is
>> assuming forward progress can be made by doing some more struct page
>> initialization.
> 
> The patch looks correct. The code is subtle but the comment helps.
> 
>> Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>> Fixes: 0e56acae4b4dd4a9 ("mm: initialize MAX_ORDER_NR_PAGES at a time instead of doing larger sections")
>> Suggested-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>> Signed-off-by: Juergen Gross <jgross@suse.com>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>

Thanks,

Juergen

