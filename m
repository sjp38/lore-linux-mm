Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9D4EC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 10:59:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F7252175B
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 10:59:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F7252175B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B453A6B0003; Wed, 20 Mar 2019 06:59:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF33A6B0006; Wed, 20 Mar 2019 06:59:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0A336B0007; Wed, 20 Mar 2019 06:59:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8252B6B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 06:59:24 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id c2so1638615ioh.11
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 03:59:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ycICQOOMlMirl8Ygz0OWOM1s2tUooMo9WIQjH1NTjzg=;
        b=Y7zZpNFG/HreI0MR59EqBpFuNVcBp6IPZi23HvPOienYSD77NFGlqf4Ov90WgUpYiO
         7je59deUmPwOQJwt6Yr364jBEWp8z/edVZyT9yO29+XZzu321A+9Yiptct3TPfE3AVbN
         6PUM/iywKOTB8bzAwZ7P9ejRO9kPlHmGekV+F0NgkwAESMWRwMznzHv8sTpIVJjWT8Bh
         5i5GDhyoP8nn+LHh2mr+4iBVlnrVsVBpBx9dTFK6ETfkBfwX7jDmixlvEzsCcy5iroum
         xr+VhhwhVLhZFLjWG53raEQEwLYtDk6IKPEcn+/QejOSAJyl9UhPlRRopZFI/+xsv+Tv
         jcPw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAVfoHU5LefCffDuG8jobq26SlbaegzSakdH7fPBeWl98cadMz36
	Uqlyd7eIzDwHKwmop4YptqxoK/kTZUgVkR6CbvjI9qL4CG2X/cEhYZeIsYs0/OX1+XHE3SZKOb+
	nfcrodIzkAQHKmcqirol9jkjMOevGdhd3COGvEp7ZFY6xje5HWwK/dFy1ZaLNhJedUg==
X-Received: by 2002:a6b:1495:: with SMTP id 143mr4538395iou.201.1553079564313;
        Wed, 20 Mar 2019 03:59:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxResN1mISoBSiXgWnFm9BBPoFqPmJMx/U0gWRWbzErF9isSaSmAWpvMQEUZN5L/6dUXEM0
X-Received: by 2002:a6b:1495:: with SMTP id 143mr4538371iou.201.1553079563652;
        Wed, 20 Mar 2019 03:59:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553079563; cv=none;
        d=google.com; s=arc-20160816;
        b=NMAWM9X734F8LKkP6BxOcsgx3/rfaWdECSnlwHFK0zSqnEQEauqOxT4bwaJa/uLdFa
         guSDOIOws+jdq2HpWe0FU2MSdUVIBIgWKK5Mil7xffTHczIQGbaVUFdpXb2t9tVjdpYz
         kEVFUcXCLGRbW1vrrOtJi4Kq482dvqNnPSLfA2EqxFZZNi+2ll6TZ749K3ybXN6keO+e
         e5c8ymT8WLT5IDiUNdA/vb8hW7RpmLx8kp1wMgiT3Nwf3DJsU+vmZSELxca0QKXNMAuU
         mrsrc9qDhpRsXkmDve9RIhg1F5M4VETYr/pFjESJNUmcXM4e7WczsHVRQJR0F/jOmDMA
         2JMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=ycICQOOMlMirl8Ygz0OWOM1s2tUooMo9WIQjH1NTjzg=;
        b=kQJ9kT7BVQZ6f/HSq7WfkH7nl9fyNhTKvh2/qRA+6ZtFv29XbzQ5fL3GkS4h4y4omd
         ouso7z5mknt0RkHoBvBAM9Pz34LRSAdlkCEoBGv4Uc7laYxpoQyZRnreGyPV+BFai0O9
         IrkvN3zGvyXm6Qk55vNSWdrDVncDisMYeTFEC1A+asjpumWWjqT/MNyW/BB26I6UpG5s
         3MU/MsxqqSj4P0mLJRpN1jClcuzCCHnSTe7fc9JpYwRJgD5tXrKygpondd+mqr5TDRFG
         yxjfHpxuCS37XYzjcrd4OX33PzFcZLVMK8W5KLRHgINmpzDFLQ9sYOlfvY0WetAB0Hub
         VGfA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id j1si730310jal.92.2019.03.20.03.59.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Mar 2019 03:59:23 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav402.sakura.ne.jp (fsav402.sakura.ne.jp [133.242.250.101])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x2KAwoWH033716;
	Wed, 20 Mar 2019 19:58:50 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav402.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav402.sakura.ne.jp);
 Wed, 20 Mar 2019 19:58:50 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav402.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126094122116.bbtec.net [126.94.122.116])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x2KAwn1v033709
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Wed, 20 Mar 2019 19:58:50 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: kernel panic: corrupted stack end in wb_workfn
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
        syzbot <syzbot+ec1b7575afef85a0e5ca@syzkaller.appspotmail.com>,
        Andrew Morton <akpm@linux-foundation.org>, Qian Cai <cai@lca.pw>,
        David Miller <davem@davemloft.net>, guro@fb.com,
        Johannes Weiner <hannes@cmpxchg.org>, Josef Bacik <jbacik@fb.com>,
        Kirill Tkhai <ktkhai@virtuozzo.com>,
        LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
        linux-sctp@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>,
        Michal Hocko <mhocko@suse.com>, netdev <netdev@vger.kernel.org>,
        Neil Horman <nhorman@tuxdriver.com>,
        Shakeel Butt <shakeelb@google.com>,
        syzkaller-bugs <syzkaller-bugs@googlegroups.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Vladislav Yasevich <vyasevich@gmail.com>,
        Matthew Wilcox <willy@infradead.org>, Xin Long <lucien.xin@gmail.com>
References: <000000000000db3d130584506672@google.com>
 <d9e4e36d-1e7a-caaf-f96e-b05592405b5f@virtuozzo.com>
 <CACT4Y+Zj=35t2djhKoq+e1SH3Zu3389Pns7xX6MiMWZ=PFpShA@mail.gmail.com>
 <426293c3-bf63-88ad-06fb-83927ab0d7c0@I-love.SAKURA.ne.jp>
 <CACT4Y+Zh8eA50egLquE4LPffTCmF+30QR0pKTpuz_FpzsXVmZg@mail.gmail.com>
 <CACT4Y+Z2FL=t8cHceXMGvG2QfChKdJYprVvBonu9X+jJaL0HMQ@mail.gmail.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <a06830e7-e396-6dd5-d9d5-2a7b1df9efc1@i-love.sakura.ne.jp>
Date: Wed, 20 Mar 2019 19:58:48 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <CACT4Y+Z2FL=t8cHceXMGvG2QfChKdJYprVvBonu9X+jJaL0HMQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/03/20 19:42, Dmitry Vyukov wrote:
>> I mean, yes, I agree, kernel bug bisection won't be perfect. But do
>> you see anything actionable here?

Allow users to manually tell bisection range when
automatic bisection found a wrong commit.

Also, allow users to specify reproducer program
when automatic bisection found a wrong commit.

Yes, this is anti automation. But since automation can't become perfect,
I'm suggesting manual adjustment. Even if we involve manual adjustment,
the syzbot's plenty CPU resources for building/testing kernels is highly
appreciated (compared to doing manual bisection by building/testing kernels
on personal PC environments).

> 
> I see the larger long term bisection quality improvement (for syzbot
> and for everybody else) in doing some actual testing for each kernel
> commit before it's being merged into any kernel tree, so that we have
> less of these a single program triggers 3 different bugs, stray
> unrelated bugs, broken release boots, etc. I don't see how reliable
> bisection is possible without that.
> 

syzbot currently cannot test kernels with custom patches (unless "#syz test:" requests).
Are you saying that syzbot will become be able to test kernels with custom patches?

