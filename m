Return-Path: <SRS0=+Baj=UH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6642DC28CC5
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 08:39:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00942212F5
	for <linux-mm@archiver.kernel.org>; Sat,  8 Jun 2019 08:39:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel-dk.20150623.gappssmtp.com header.i=@kernel-dk.20150623.gappssmtp.com header.b="DjoWrOsW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00942212F5
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kernel.dk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5DC1C6B026F; Sat,  8 Jun 2019 04:39:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 58C626B0271; Sat,  8 Jun 2019 04:39:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47AF36B0273; Sat,  8 Jun 2019 04:39:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id F17676B026F
	for <linux-mm@kvack.org>; Sat,  8 Jun 2019 04:39:36 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id r4so1189906wrt.13
        for <linux-mm@kvack.org>; Sat, 08 Jun 2019 01:39:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=J6Xt9h1a4Wghl2N6CbS4VR7OOrvB5+AthvQVEUPg01E=;
        b=F9AXaSHk2kec3pRD9OqZ4Q1OmEnjWXjFHRfvQPv3cA+KOyC57+vHnLeYRGjXjP3QdX
         gAQOcR72S1GvzyWwDtZB1vt9PVbUmFdId78k7IqyYQwS1I+OpV9OXnCTbMQG3XL1AxeQ
         e4Tgza+fjoXfsfH2bqRIzE+H83a5TEVqY2kwRS90PE8GxR4VXGlIvYg5qgq0Y9YcHu1m
         v25XUuzgzLacE/7new9oImRB6lsBCcoqX6lfsTfoTdWyOEcvuSkSLNo3zLEytT7JY1Am
         uRB6Az7+P3BpEN2K8BvtlkjSOE1ImZ545L5CnPpCJcjXgwqfLuHy4+o87+eMG6zeOh2l
         kbeg==
X-Gm-Message-State: APjAAAWvuS2CzLk13XaF8Z9vZVmoW4uDQInlC5SboUR9ltMpzU8S/Cpo
	xietVMy7ducN/4wst/Q4USDHWRl9B75X6QWenqSWCJARn0kirkKBbqYs54lMgp5pl716LMOVYyU
	wcVU/5rj92Hg5+pbuEQ9K7y3ftSh75EfUz4KbY4Q0hK+TrWY14TQNvZlzZIXraVy7hg==
X-Received: by 2002:adf:9ed3:: with SMTP id b19mr14044266wrf.292.1559983176247;
        Sat, 08 Jun 2019 01:39:36 -0700 (PDT)
X-Received: by 2002:adf:9ed3:: with SMTP id b19mr14044216wrf.292.1559983175397;
        Sat, 08 Jun 2019 01:39:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559983175; cv=none;
        d=google.com; s=arc-20160816;
        b=fXjqENRKrIcLAZcRjtxKYlVS4Mi3r/HbgQZjZkg5ozBbOG7e2e/N4pMvdaAfUeK9YR
         38mrxS02E6k0rx+MydTBLPW9b/xvH0qChKRxprU04AQ1qzhYglWpdln0x5U/Cd2Npt2j
         058h25z7XQuuw9tGEbjUug2IJ10I47fYMWg1AX6LeLgf063A5fFv1nT1r0ULEixemLKD
         ++5psFknxOiY5jzryzXKFNRfmqcnEE30Bg1dWo6KtvNCp2w2x82UJ4MNjjA8eL+0J4eA
         qAXGNciOi/kXFql8VUsMfKDLym+Lng34yycLVDPyIvDk+F8tXmkymR3jKAMC4lfLVhkp
         NlVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=J6Xt9h1a4Wghl2N6CbS4VR7OOrvB5+AthvQVEUPg01E=;
        b=UU5QGxhqpB7bq5usOFgSpcyCkJHTIRZVa59WOfruqkSwA9n93LdGelaRAf0Hf/yzIY
         y+dzy1CG/WCAzavriDV/zBO+Mhq4EUBjYcMjOITOJs7zQYs2jO1O2cbn1lUF0Q2s3TKM
         9lu+L5ruQndudspXE+ezGpo4kzvgi7cVgMSt+pyl9q8/AvfSThttCExHPdkCYViv/0fp
         uVA/oZfujENdbj+Tj8upFINlPBxlUY0CvBq8Q06xtRZavTyTI8TBhmM8tzyvX71utGq+
         5dMBTfptDPgMLOPevpcqsi3FBx19yYbtr7R9A34iDlDXlkrOYwSmAlsRWsvX+ctLt76x
         tobg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=DjoWrOsW;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u3sor1984728wri.3.2019.06.08.01.39.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 08 Jun 2019 01:39:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel-dk.20150623.gappssmtp.com header.s=20150623 header.b=DjoWrOsW;
       spf=pass (google.com: domain of axboe@kernel.dk designates 209.85.220.65 as permitted sender) smtp.mailfrom=axboe@kernel.dk
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=kernel-dk.20150623.gappssmtp.com; s=20150623;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=J6Xt9h1a4Wghl2N6CbS4VR7OOrvB5+AthvQVEUPg01E=;
        b=DjoWrOsWVY/yC9JXffrTjpdqyGovJRi2Buug8N5SOGLhoS1LCUpAtYv9PesOQViJbC
         hOFboN/QlHdA/zBDZ80nYSDB5L4vTRpz9My5cgMRUI1xbL8rlAnhlS9+wX/Xa/skpfc1
         sRDDD28K/u7NL3Lgi5PURTUxf9DEDl0Ue7zA1A4uo8ltMNIVodqzxbCPKoos8hZ7sr/n
         ZQMdlgNBVCx/hwuofBC3pv5Lt28pAjkUNVjrxxpHCX39a5ApT/I7pPF2mvmlqNV2LcR4
         XZTxiN0oSjU10rLrPc4OXo7OBYSeEHsUET3Bhoa9EwAprRjWoEwejl+3bo41EqOBmxEz
         RGpQ==
X-Google-Smtp-Source: APXvYqy0hclAVRC3uhRV9+kiDoq5y/xu4oRXxLZnqP/wlFsxFYuIAZE/t6VVhRF/UOV3+UhOCrDfrA==
X-Received: by 2002:adf:df91:: with SMTP id z17mr30066569wrl.336.1559983175080;
        Sat, 08 Jun 2019 01:39:35 -0700 (PDT)
Received: from [10.97.4.179] (aputeaux-682-1-82-78.w90-86.abo.wanadoo.fr. [90.86.61.78])
        by smtp.gmail.com with ESMTPSA id z6sm4787119wrw.2.2019.06.08.01.39.34
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Jun 2019 01:39:34 -0700 (PDT)
Subject: Re: [PATCH] block: fix a crash in do_task_dead()
To: Peter Zijlstra <peterz@infradead.org>
Cc: Qian Cai <cai@lca.pw>, akpm@linux-foundation.org, hch@lst.de,
 oleg@redhat.com, gkohli@codeaurora.org, mingo@redhat.com,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1559161526-618-1-git-send-email-cai@lca.pw>
 <20190530080358.GG2623@hirez.programming.kicks-ass.net>
 <82e88482-1b53-9423-baad-484312957e48@kernel.dk>
 <20190603123705.GB3419@hirez.programming.kicks-ass.net>
 <ddf9ee34-cd97-a62b-6e91-6b4511586339@kernel.dk>
 <20190607133541.GJ3436@hirez.programming.kicks-ass.net>
 <20190607142332.GF3463@hirez.programming.kicks-ass.net>
From: Jens Axboe <axboe@kernel.dk>
Message-ID: <c0b19bdd-c68f-3f1f-2cd2-1732e8a508b6@kernel.dk>
Date: Sat, 8 Jun 2019 02:39:33 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190607142332.GF3463@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/7/19 8:23 AM, Peter Zijlstra wrote:
> On Fri, Jun 07, 2019 at 03:35:41PM +0200, Peter Zijlstra wrote:
>> On Wed, Jun 05, 2019 at 09:04:02AM -0600, Jens Axboe wrote:
>>> How about the following plan - if folks are happy with this sched patch,
>>> we can queue it up for 5.3. Once that is in, I'll kill the block change
>>> that special cases the polled task wakeup. For 5.2, we go with Oleg's
>>> patch for the swap case.
>>
>> OK, works for me. I'll go write a proper patch.
> 
> I now have the below; I'll queue that after the long weekend and let
> 0-day chew on it for a while and then push it out to tip or something.

LGTM, thanks Peter!

-- 
Jens Axboe

