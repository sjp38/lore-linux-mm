Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBE84C0650E
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 17:52:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B57BD2184C
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 17:52:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel-dk.20150623.gappssmtp.com header.i=@kernel-dk.20150623.gappssmtp.com header.b="dUVSYtdq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B57BD2184C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kernel.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A1C98E000E; Wed,  3 Jul 2019 13:52:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6517C8E0001; Wed,  3 Jul 2019 13:52:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 519FE8E000E; Wed,  3 Jul 2019 13:52:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1AD5D8E0001
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 13:52:30 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id q14so1935678pff.8
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 10:52:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=i2FMup8JP34BQXzcr9NEGjQytjFqnsavOY77a6JHYaA=;
        b=REiuvoU9vX81GimPpWdyi2gmZ+2ONM92GKHDwCt2id/fbEMhAmprbn9+OFGmiiSRWp
         UOiXcFcixEHJGa5qQfaaWbi8TwLIroHBljEyIJMDhAmmDKm5n0DpJOiSbfgzaQObWDRP
         SH7lwrkSD+lzhh4I8DbQOA0ZAlc4r1UFWnVd5bvHumxnDsKCqUwgAwyP/PTVXXwdRG4f
         +3UgBnRnP2bzhNEOSZpvW8v6nRoNmhKQl5EtAHBlEX7K/vJovUjdDd5E8BU63Bm7YhJZ
         t+IgwfaCJmxwLMhSnD4DHYmVA//qI6oUpblZpfE9cUIvgsmnuAXB/YTBuQU23d/lCES3
         T5Jg==
X-Gm-Message-State: APjAAAVdozHg/8PJIXHAhzlwjrzryOKkV47E+q2LYY9ommaqcjnLckMQ
	N8d6SdtmRb6XJlrgiC/mAS9t6i+bSHtDFikePDz8cgGDzezsLRXhQ6rHn31/fqtcx336fyMThii
	WsloWXWiEtww98Nd2VFk1ggd6HglpnByorWqpfmx7BxGsrIZ6SLG08MBhIFzptIZQ3Q==
X-Received: by 2002:a17:902:bd47:: with SMTP id b7mr491413plx.44.1562176349806;
        Wed, 03 Jul 2019 10:52:29 -0700 (PDT)
X-Received: by 2002:a17:902:bd47:: with SMTP id b7mr491363plx.44.1562176349218;
        Wed, 03 Jul 2019 10:52:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562176349; cv=none;
        d=google.com; s=arc-20160816;
        b=YQxKT567FMJ53bVnaYRGSkgWemfNE1DT1ghumEB0Se0JVZgNt1uwcWMvrnm1hcwomM
         WKr22oOcaRo2DzClV+GSvdktzMpdQ8BZxMe16VmJaPkV+CxB+10HeXHssctzCMdbm+bN
         +pmhfY7PLO8bkr1aROUV1UG0mcYbmvju3vwBu/Jw5pdafD+p9qWyxb1M0YjRdPTZzfxv
         CTxceiAHvsxnGPMRik60QOmywlbDhOhrMi6IOMA0EM1f9ppz2HXMeNXylpWXo6CLhTL5
         ExLa+tukl64BcvbiakwroRN7KGFZ+qTfKAREcOfY+ZmDiP9IYNnX78SogZ/utW+Ai8bt
         ODMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=i2FMup8JP34BQXzcr9NEGjQytjFqnsavOY77a6JHYaA=;
        b=Er4qGS/Ra5ukObhcsdVQ2eLW4n4Yd4OMBybnQSdCGwZDvIQ97RQKqQf3xD93KcqEkJ
         ubr1D4tm8fzY+x2blVk7RFkJZkt6zailMlzjmbv2Qyx4YcaEwQ5YsAe+3B1W3OELxT+J
         rJw/N+3o7Xd5kBPLW3upchxTM8QMcTMqcY6GS+0VA0HrZhYXJg5HCLsZoas7BW8s+u0h
         t6FaGnG5vhXIs0bCYdK/BLcaIfnpkjk5SwvXFsyAS+JFnYSKG41FN+eMuwmcXQf9lnBM
         GIUoNR+nZD8KMDCM1vCJr4bqY+6BoiTJ1fRPUnxlhTVzba5oilSRE9NSfC0vFIw4Zwm6
         l5hQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=dUVSYtdq;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d2sor3858945pln.13.2019.07.03.10.52.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jul 2019 10:52:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=dUVSYtdq;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kernel-dk.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=i2FMup8JP34BQXzcr9NEGjQytjFqnsavOY77a6JHYaA=;
        b=dUVSYtdqvWELrPwprF7PYmxJuQYJfr5zHCfcdHK7MgUCxdXIXE18mQZPha2oRFSboJ
         2JEuUzcRHXZwBNiPsfZ9HGt3oTgDxGniKiXECcXsuVdz07s1ejOJszha3vET9ucNUbWq
         AvQzJ7mBbieplSHs4iJzW0FoDL4dqAQ4a1okp57VswvSJQcK3FyxSJIATJdEz8wukAZ8
         slAtOY9mEGCOOPV7czTI9hT9OOdDUqcorfqMJDCCPHyGuqvslWC2JvingwTnF4oy79V2
         ACKpMHg3MXJzpARMp0eZILX8/q34GzbiDovr20Azud577yPDY4XlSltW0Py2NEsssb+L
         tiSA==
X-Google-Smtp-Source: APXvYqy8BByQqGDcL3JfHMPSKyTFXUsjXfOB5EQTLI+UaM5WG4+T7r6FSEVp5tAO6P3kSH3FLSjJiA==
X-Received: by 2002:a17:902:8d92:: with SMTP id v18mr44400466plo.211.1562176348809;
        Wed, 03 Jul 2019 10:52:28 -0700 (PDT)
Received: from [192.168.1.121] (66.29.164.166.static.utbb.net. [66.29.164.166])
        by smtp.gmail.com with ESMTPSA id l31sm6823400pgm.63.2019.07.03.10.52.26
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jul 2019 10:52:27 -0700 (PDT)
Subject: Re: [PATCH] block: fix a crash in do_task_dead()
To: Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>,
 Qian Cai <cai@lca.pw>, hch@lst.de, gkohli@codeaurora.org, mingo@redhat.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1559161526-618-1-git-send-email-cai@lca.pw>
 <20190530080358.GG2623@hirez.programming.kicks-ass.net>
 <82e88482-1b53-9423-baad-484312957e48@kernel.dk>
 <20190603123705.GB3419@hirez.programming.kicks-ass.net>
 <ddf9ee34-cd97-a62b-6e91-6b4511586339@kernel.dk>
 <alpine.LSU.2.11.1906301542410.1105@eggly.anvils>
 <97d2f5cc-fe98-f28e-86ce-6fbdeb8b67bd@kernel.dk>
 <20190702150615.1dfbbc2345c1c8f4d2a235c0@linux-foundation.org>
 <20190703173546.GB21672@redhat.com>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <c2596766-4b9c-9e84-b13e-efec3fe4d3f7@kernel.dk>
Date: Wed, 3 Jul 2019 11:52:25 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190703173546.GB21672@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/3/19 11:35 AM, Oleg Nesterov wrote:
> On 07/02, Andrew Morton wrote:
> 
>> On Mon, 1 Jul 2019 08:22:32 -0600 Jens Axboe <axboe@kernel.dk> wrote:
>>
>>> Andrew, can you queue Oleg's patch for 5.2? You can also add my:
>>>
>>> Reviewed-by: Jens Axboe <axboe@kernel.dk>
>>
>> Sure.  Although things are a bit of a mess.  Oleg, can we please have a
>> clean resend with signoffs and acks, etc?
> 
> OK, will do tomorrow. This cleanup can be improved, we can avoid get/put_task_struct
> altogether, but need to recheck.

I'd just send it again as-is. We're removing the blk wakeup special case
anyway for 5.3.

-- 
Jens Axboe

