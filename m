Return-Path: <SRS0=GuKW=WG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C561CC433FF
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 21:07:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62DFF2085B
	for <linux-mm@archiver.kernel.org>; Sat, 10 Aug 2019 21:07:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62DFF2085B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=redhazel.co.uk
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CFEDD6B0003; Sat, 10 Aug 2019 17:07:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB1556B0005; Sat, 10 Aug 2019 17:07:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9E866B0006; Sat, 10 Aug 2019 17:07:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6AEDB6B0003
	for <linux-mm@kvack.org>; Sat, 10 Aug 2019 17:07:52 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id m30so2916959eda.11
        for <linux-mm@kvack.org>; Sat, 10 Aug 2019 14:07:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=0F2uqHTrwVV0T1fS/2p0u20ixcdXgRaM2ovH7AfXBk4=;
        b=n8rBYaDXTpP3GiAgKzm+AA5eIt4BLXST3kZ+nwPdvZNJNLBaTF0O+k8NQiEB/dj/kc
         pfzv612/78i9Z/AG1zmbaa7rV4AkINcABHwqffa8wy8rav7aLempDSebE7aM7BuzKE1V
         74p96O2IK/DIAxvcOMK+cg46sXsWFTLjQaMqS2JogtV/8j4wo9oTwM6+2iDKHMBCKHgD
         rADcst1Qo/lAD3TJvrmwL8Z4+mXqg+8Xg2kDKnq1Yr8WPtWYXRy055rePmFq9URcqGJu
         HKMTtBGoB/yeI4kO1yVFPWwqhQU0T3yHyehcxzp67EkGC6GZDDcFeqSqFgypwj0czvGM
         mF1A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ndrw.xf@redhazel.co.uk designates 68.66.241.172 as permitted sender) smtp.mailfrom=ndrw.xf@redhazel.co.uk
X-Gm-Message-State: APjAAAXqvVGj9Cv8EEsWuyuNxEWIAtlJhUJukeQrnwBvRV4MnNJLU7O6
	mmA7RmSdu/8yNdkttG0e/Pn9+g8H34zVfzLt30b2FgR86BbjMTxXVJ1CL2WlXZAYYEJmEpDAXRm
	Pv7LGTlNuIpZF//hgrpYP0mS/RRk4nh5O796oA5KfMuIrUQztOGugsAxXvbcz0mnjzA==
X-Received: by 2002:a17:906:4b18:: with SMTP id y24mr24236859eju.108.1565471271963;
        Sat, 10 Aug 2019 14:07:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxYjTsbCQ+69ADB8vCIgUTPdQjPRDJQ88kpTEUAxo6+Mj/94+imuxkXJ6c6pAqUvyTTLe+G
X-Received: by 2002:a17:906:4b18:: with SMTP id y24mr24236821eju.108.1565471270901;
        Sat, 10 Aug 2019 14:07:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565471270; cv=none;
        d=google.com; s=arc-20160816;
        b=eRDD9QkCktbh4GrFhQeJRhZcpUyY8JK4lRnRPMZNPABn2V08Mm99i02WSveaMvT9pt
         FUnQSzWjhiZQwTHeH2QnvtnrpV3/oNmvsnW2HqlVn2mUAfxnCyQJA7pJI79gokflvd4U
         QisihuGJVvqJ2u69ec/wL42UVtmsfrcoYjZcKX+lR9uYEeKEAlT6CMUgncnHTaWHRqAm
         wfr1q/gSubij1R3dGjsb3m6tgzbJxeWc8e0kq9eCM+OAB496nVypupHXWo53NMdWH8tm
         Lcqx/5LFR/DQM4YANaDqbCWbcKGczcyYE64HAiahr/gAnxNaaNp7beJnpzbCHwypyND+
         4rBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=0F2uqHTrwVV0T1fS/2p0u20ixcdXgRaM2ovH7AfXBk4=;
        b=qwvblKIZnhgGv55m0vzIXBf/6QYRuavdxz7UfTMpRFNfQ5GlSkwqhx9Q9UcQMDIH1Q
         gROD+hd7lknwnBaFyU1LXXaoD3ErUANpvtrN24//I2vcqFOtRHAkjj04Jecj7c4l1JjD
         Gxco7C1ELv+IvRnYIOlZR99RNg1ZYxpXi3Qvc9Iyvm3PSRyFrYeuFvoVN3Kyhf/vSWmk
         HA2trAHCe64MGgATJMqRKIAf2Fnm/bWLD0ddcllbFfprCiyL0ZyA+hvhWIqq9bfp6kr1
         OVu0xFJAzJvG/j+cFLQF/lI1oCvPQVtK5mtzWQHeEPFNSdipUZKTPJ39vJOJT+RaIuA7
         8BIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ndrw.xf@redhazel.co.uk designates 68.66.241.172 as permitted sender) smtp.mailfrom=ndrw.xf@redhazel.co.uk
Received: from vps.redhazel.co.uk ([68.66.241.172])
        by mx.google.com with ESMTPS id rn14si35847744ejb.296.2019.08.10.14.07.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Aug 2019 14:07:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of ndrw.xf@redhazel.co.uk designates 68.66.241.172 as permitted sender) client-ip=68.66.241.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ndrw.xf@redhazel.co.uk designates 68.66.241.172 as permitted sender) smtp.mailfrom=ndrw.xf@redhazel.co.uk
Received: from [192.168.1.66] (unknown [212.159.68.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by vps.redhazel.co.uk (Postfix) with ESMTPSA id 1E5011C02B32;
	Sat, 10 Aug 2019 22:07:50 +0100 (BST)
Subject: Re: Let's talk about the elephant in the room - the Linux kernel's
 inability to gracefully handle low memory pressure
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>,
 Suren Baghdasaryan <surenb@google.com>, Vlastimil Babka <vbabka@suse.cz>,
 "Artem S. Tashkinov" <aros@gmx.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
References: <CAJuCfpFmOzj-gU1NwoQFmS_pbDKKd2XN=CS1vUV4gKhYCJOUtw@mail.gmail.com>
 <20190806220150.GA22516@cmpxchg.org> <20190807075927.GO11812@dhcp22.suse.cz>
 <20190807205138.GA24222@cmpxchg.org> <20190808114826.GC18351@dhcp22.suse.cz>
 <806F5696-A8D6-481D-A82F-49DEC1F2B035@redhazel.co.uk>
 <20190808163228.GE18351@dhcp22.suse.cz>
 <5FBB0A26-0CFE-4B88-A4F2-6A42E3377EDB@redhazel.co.uk>
 <20190808185925.GH18351@dhcp22.suse.cz>
 <08e5d007-a41a-e322-5631-b89978b9cc20@redhazel.co.uk>
 <20190809085748.GN18351@dhcp22.suse.cz>
From: ndrw <ndrw.xf@redhazel.co.uk>
Message-ID: <5fcf237c-d270-26e5-e995-02755695b459@redhazel.co.uk>
Date: Sat, 10 Aug 2019 22:07:49 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190809085748.GN18351@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 09/08/2019 09:57, Michal Hocko wrote:
> This is a useful feedback! What was your workload? Which kernel version? 

With 16GB zram swap and swappiness=60 I get the avg10 memory PSI numbers 
of about 10 when swap is half filled and ~30 immediately before the 
freeze. Swapping with zram has less effect on system responsiveness 
comparing to swapping to an ssd, so, if combined with the proposed PSI 
triggered OOM killer, this could be a viable solution.

Still, using swap only to make PSI sensing work when triggering OOM 
killer at non-zero available memory would do the job just as well is a 
bit of an overkill. I don't really need these extra few GB or memory, 
just want to get rid of system freezes. Perhaps we could have both 
heuristics.

Best regards,

ndrw


