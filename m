Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96514C4321B
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 04:39:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 251C020679
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 04:39:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="dob0nTtT";
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="fC1I4+x5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 251C020679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 88DA06B0010; Tue, 11 Jun 2019 00:39:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8172D6B0266; Tue, 11 Jun 2019 00:39:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 68FBD6B0269; Tue, 11 Jun 2019 00:39:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2FFF26B0010
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 00:39:14 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id r142so7491897pfc.2
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 21:39:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:dmarc-filter
         :subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=n1P29tawGwg2a7tGFB+wjuiayFbebTKUZgu62JbwQyI=;
        b=MmTerzbCcdhoftVHMJTsVrbcmKfvvIovJBa+ZuXN7H6BglVx27MgyD7D0tsPmCRBsi
         K8C5mx2A9A/j/BdwiCuQfwkNx9fs8wlz2H2/N9DlHKA2f/86JmRH43zzP6SHS+5Tuw/X
         m8qnMqszlunwp12ta9QFNhM2xmUgeWzoN0mRG552R4lE0R9+UZC0f53VQG35W3tSda4f
         S0AzyExndnWs8Wr9QCDbXFVkQgoVcE/lcoxLzWERhZGR6RCPqMpcjZsFg5AC7WNEz+ya
         FnDOZK+O1FLmPrS6WgUJokgyw6twdENU312Tbj56kbJiAHGGemyFB2NAL/Q9X9imOuz+
         FoZQ==
X-Gm-Message-State: APjAAAVfAXjmMnK0Cf963P99e7Rjc1EFfVye5W09nOfcM4dyl23g3zZF
	vxo7lNph1HBX8WKD/Ju5enWhug3UPlT9HDyPadxsjUk2KFXSv+G84+uDSOabGgiTN4Hb3qvIrIw
	dWkRLpzpENXRXG2Pi6BsT9PGahK/F3eknvyVELr2VHhveP0QO2j+p39jIpU/OoHhQpQ==
X-Received: by 2002:a17:902:42e2:: with SMTP id h89mr71606170pld.271.1560227953739;
        Mon, 10 Jun 2019 21:39:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwz6qutlAUJQwQGPR11+HdlZjGVTID8PJUInjqvJO/5/txaf8EYllSyBKeyItfYfTGqf2OG
X-Received: by 2002:a17:902:42e2:: with SMTP id h89mr71606129pld.271.1560227952827;
        Mon, 10 Jun 2019 21:39:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560227952; cv=none;
        d=google.com; s=arc-20160816;
        b=bR4/V7UVHUmqRQwhhB2+qZDZZbRZnks6NkDXkuj2YitQuXMNZHHG7pD9g8F0Pk+EhV
         K6Tm1JQyNzYgzPb904g4a7nYlr0v8J0b/ENeOYBrujEFvovzoS4SbYY5x1Y1ZbYqsfu2
         G/oYnRX8GC4C6cCqdabJ1jx/Yu5ze9ULgn0ADq6SeydnPApmQPJ0riUBh/z5Gy76IthM
         GpksmVqqREKeo+R0kACGc9npq6ANwB5ZYFW5Nx9N2aeZ0MR19W06WfzE51zZF3e5wFzv
         riyNMZFz1uvgEzwq0EGjisTQrT1eINJwUdMd5EQ3WId9Pbht/x8mKDRGlfFLcAdEALh2
         UcAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dmarc-filter:dkim-signature:dkim-signature;
        bh=n1P29tawGwg2a7tGFB+wjuiayFbebTKUZgu62JbwQyI=;
        b=DQHqAR5xqUrVmAbIoVnXp6GN9tt57tpfETJnFXlYFLnluY9tICkKwxjxANgwxSrKkY
         FWMb8c5sw+vI/Yuwde+VJ9QuxxubdYzZq/SGGcqZVQMsvUUQRm3SFA3nnf39kNyFPkvd
         iYaVE1NpM2TLSkcAMp9+/GvZNY2LOJGIU+/NeQc3nuN+GbzT6p4XbKq8G211eAxrPNuU
         2zT4za3FH1AtAkrzv//+dzCP4gKSNRZfw/QHd2P2pAAj3FqLZqI/lKs47IDiyU7IK8eV
         W2aBoImq+LLY6xVTbBJejWxm8ZKREJ8X6RcLKMYj/6s5OMZk5yjyAyuLkAlGEtroTGHm
         PUDw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=dob0nTtT;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=fC1I4+x5;
       spf=pass (google.com: domain of gkohli@codeaurora.org designates 198.145.29.96 as permitted sender) smtp.mailfrom=gkohli@codeaurora.org
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id i96si1324225pje.4.2019.06.10.21.39.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 21:39:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of gkohli@codeaurora.org designates 198.145.29.96 as permitted sender) client-ip=198.145.29.96;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=dob0nTtT;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=fC1I4+x5;
       spf=pass (google.com: domain of gkohli@codeaurora.org designates 198.145.29.96 as permitted sender) smtp.mailfrom=gkohli@codeaurora.org
Received: by smtp.codeaurora.org (Postfix, from userid 1000)
	id 4CE95604BE; Tue, 11 Jun 2019 04:39:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1560227952;
	bh=GxvWGt9BSFpOm0HBYOLwuO1UUTw67j40yC2FZPp7lcY=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=dob0nTtTztsKrzbG99s2RNDLafJK+yaBUpEXQ50HfnN1Smzg9myH8GKQJ2MZoaVQj
	 G5hQwVyQ6pj1OUJIYTClnu/jnu1+MXJy5foM5B8pC2yesIggzo9qY84y4cXZ7tRIsa
	 ONChedqqzDeYrgyxUVbFO/uyAAU4Trs/UqGlaTNo=
Received: from [10.204.79.142] (blr-c-bdr-fw-01_globalnat_allzones-outside.qualcomm.com [103.229.19.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: gkohli@smtp.codeaurora.org)
	by smtp.codeaurora.org (Postfix) with ESMTPSA id 3DE0460261;
	Tue, 11 Jun 2019 04:39:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1560227951;
	bh=GxvWGt9BSFpOm0HBYOLwuO1UUTw67j40yC2FZPp7lcY=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=fC1I4+x5OBGfNCBsYpH8gEdI1mu+JvSeL2VIuUVgwIHFBfoBqyhXRLlk8Ynaruyiv
	 DVZbPNoB5Po6eIKDJG9vrTPtDHHB2v3kvXeJz5kR44kDeTFJIQg0b1HiIkPfmageka
	 zvesMBiGovazHRLrl/FJLMoQiHGOnNA9IEj0zBLg=
DMARC-Filter: OpenDMARC Filter v1.3.2 smtp.codeaurora.org 3DE0460261
Authentication-Results: pdx-caf-mail.web.codeaurora.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: pdx-caf-mail.web.codeaurora.org; spf=none smtp.mailfrom=gkohli@codeaurora.org
Subject: Re: [PATCH] block: fix a crash in do_task_dead()
To: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Jens Axboe <axboe@kernel.dk>,
 Qian Cai <cai@lca.pw>, akpm@linux-foundation.org, hch@lst.de,
 mingo@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
References: <1559161526-618-1-git-send-email-cai@lca.pw>
 <20190530080358.GG2623@hirez.programming.kicks-ass.net>
 <82e88482-1b53-9423-baad-484312957e48@kernel.dk>
 <20190603123705.GB3419@hirez.programming.kicks-ass.net>
 <ddf9ee34-cd97-a62b-6e91-6b4511586339@kernel.dk>
 <20190607133541.GJ3436@hirez.programming.kicks-ass.net>
 <20190607142332.GF3463@hirez.programming.kicks-ass.net>
 <16419960-3703-5988-e7ea-9d3a439f8b05@codeaurora.org>
 <20190610144641.GA8127@redhat.com>
From: Gaurav Kohli <gkohli@codeaurora.org>
Message-ID: <154008a8-9d29-2411-28a0-0284a95b4481@codeaurora.org>
Date: Tue, 11 Jun 2019 10:09:06 +0530
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190610144641.GA8127@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


>>> +
>>
>> Hi Peter, Jen,
>>
>> As we are not taking pi_lock here , is there possibility of same task dead
>> call comes as this point of time for current thread, bcoz of which we have
>> seen earlier issue after this commit 0619317ff8ba
>> [T114538]  do_task_dead+0xf0/0xf8
>> [T114538]  do_exit+0xd5c/0x10fc
>> [T114538]  do_group_exit+0xf4/0x110
>> [T114538]  get_signal+0x280/0xdd8
>> [T114538]  do_notify_resume+0x720/0x968
>> [T114538]  work_pending+0x8/0x10
>>
>> Is there a chance of TASK_DEAD set at this point of time?
> 
> In this case try_to_wake_up(current, TASK_NORMAL) will do nothing, see the
> if (!(p->state & state)) above.
> 
> See also the comment about set_special_state() above. It disables irqs and
> this is enough to ensure that try_to_wake_up(current) from irq can't race
> with set_special_state(TASK_DEAD).

Thanks Oleg,

I missed that part(both thread and interrupt is in same core only), So 
that situation would never come.
> 
> Oleg.
> 

-- 
Qualcomm India Private Limited, on behalf of Qualcomm Innovation Center,
Inc. is a member of the Code Aurora Forum,
a Linux Foundation Collaborative Project.

