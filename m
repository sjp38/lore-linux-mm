Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7258C7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 08:19:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9348D21873
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 08:19:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9348D21873
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.cz
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4458B6B0006; Wed, 24 Jul 2019 04:19:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3F87B8E0003; Wed, 24 Jul 2019 04:19:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 26FC38E0002; Wed, 24 Jul 2019 04:19:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CCE016B0006
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 04:19:36 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id o13so29746613edt.4
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 01:19:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language:content-transfer-encoding;
        bh=RmvqYJiF9TYuI7uVSd9BYdSkVwYXqPZvsC/0pOBzmi4=;
        b=gCyjoLzt2DWloqE7hlh2YE7ocercJ8JURj+J5x8EkuXz9Ehj7L6Dww2mex22AtXqV4
         5VoCPPIWKrqsVjeZYI/bgvswUoLhv83i9NLI3cSkyqx+p4ZXBLBNvi5XH7QfBCYya1ZX
         z0sJdBaMmO9V/llW5JoSImsa2gh90dK0tFFqWybhLjIOejdoo9Eb1tr4JvV9zM02xt+r
         R44PvwYGmrgbAi4g5TkaLDPDJvQmkuXgRFZAmb8OeU1IS3raUt+8596H2uIZY3725OJi
         EzbxUmIP7HsZX0ryg2MQY/2YbWIjFLQGpUTLf7gqz1Q4MJ4ephZ3456s6qbrjCVATBA1
         a3Tw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Gm-Message-State: APjAAAU9h23p3/rq0P98MS+28jD/0DPkiqMxFXepbMK1gxd+kPx+7TlX
	qy0Md1Ps44MNldB/HFVpIzr5ySnOmydgq7vmhqHiA4a94gAKOzd4mg1cJKmTjaGWj1nuzBbUTMC
	Ogzrz2XhPWqSROfFYyTC9hFXakkUchHR3VM8YPe4YdQ67YX5v1TXvtCL02BJITWAy5A==
X-Received: by 2002:a05:6402:14c4:: with SMTP id f4mr68907588edx.170.1563956376390;
        Wed, 24 Jul 2019 01:19:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwQka/bWOr9d3RhE+llGU+qfRtHnoFs8wK2kvh/10LnHSSwshQqRmhAE14TBx7AP9j9jydR
X-Received: by 2002:a05:6402:14c4:: with SMTP id f4mr68907551edx.170.1563956375662;
        Wed, 24 Jul 2019 01:19:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563956375; cv=none;
        d=google.com; s=arc-20160816;
        b=vaxRXqTeYo/qebc0Vkm0KbTqGRAbMw3I7k4ePWY1yE6dJSYhz8zLNvORw6m11J4nAc
         o6tisNTfr3bI/ZdZ0OXfsSJj7hJbZFZISG9B+EdXJxn9LLkVHcrDVeQ/DTw72O3nA4Xd
         H3/eoFinsKBuwaHBMRo9KuGumFYOfkVghJ3+Qo5DiYKLPMym/4PMRnXIZi6bubZ6iD2B
         B3uYlUx2TPRwuEGQuKxs0JTDlt1He9lEQtckjwYrkvukiKOvIWsDWqdx4dWttzAw0iX1
         GE5nMxJ0unTVT+POXJAGEeT8GkvMyqaR3uYk5dA+mq8mRUZszgkyAlMTBQCUoCP9eZYC
         comw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject;
        bh=RmvqYJiF9TYuI7uVSd9BYdSkVwYXqPZvsC/0pOBzmi4=;
        b=o/LB9D1UEFV6vQskJpRawUJM9gGIeLpRxgFX3GNhWaB2jWAWxAXEchJnsaoBGIhcbt
         lfAE9Um2VV1dPEipU2HpyT7zjk+BiHu5Z03OPyovlBW57N/E49OXq8rtTYm4wVo9U9sQ
         2S+gchRjVtxwtZQMbuJcWfpfHh7XTq6Bc2dbeKwG/w3OMd9/rPPsroZlqhLf4Pq1YaC+
         ip2293IUdzRONxBjMMrG9FW40sV4LwF9T8bj6NVevv8EGUlr00hIvqIhu2SUawcBA2tS
         /GJL2YlITigLrIml2Gvz6igjyO40o4oOHq2qbSIHgJcCdCtdy5nZDS6hu8VjwcnSq/Rb
         /Dlg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p15si6969543eju.348.2019.07.24.01.19.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 01:19:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of vbabka@suse.cz designates 195.135.220.15 as permitted sender) smtp.mailfrom=vbabka@suse.cz
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 86B9DAD8A;
	Wed, 24 Jul 2019 08:19:34 +0000 (UTC)
Subject: Re: [v4 PATCH 2/2] mm: mempolicy: handle vma with unmovable pages
 mapped correctly in mbind
To: Yang Shi <yang.shi@linux.alibaba.com>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: mhocko@kernel.org, mgorman@techsingularity.net, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
References: <1563556862-54056-1-git-send-email-yang.shi@linux.alibaba.com>
 <1563556862-54056-3-git-send-email-yang.shi@linux.alibaba.com>
 <6c948a96-7af1-c0d2-b3df-5fe613284d4f@suse.cz>
 <20190722180231.b7abbe8bdb046d725bdd9e6b@linux-foundation.org>
 <a9b8cae7-4bca-3c98-99f9-6b92de7e5909@linux.alibaba.com>
From: Vlastimil Babka <vbabka@suse.cz>
Openpgp: preference=signencrypt
Autocrypt: addr=vbabka@suse.cz; prefer-encrypt=mutual; keydata=
 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
Message-ID: <6aeca7cf-d9da-95cc-e6dc-a10c2978c523@suse.cz>
Date: Wed, 24 Jul 2019 10:19:34 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <a9b8cae7-4bca-3c98-99f9-6b92de7e5909@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/23/19 7:35 AM, Yang Shi wrote:
> 
> 
> On 7/22/19 6:02 PM, Andrew Morton wrote:
>> On Mon, 22 Jul 2019 09:25:09 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
>>
>>>> since there may be pages off LRU temporarily.  We should migrate other
>>>> pages if MPOL_MF_MOVE* is specified.  Set has_unmovable flag if some
>>>> paged could not be not moved, then return -EIO for mbind() eventually.
>>>>
>>>> With this change the above test would return -EIO as expected.
>>>>
>>>> Cc: Vlastimil Babka <vbabka@suse.cz>
>>>> Cc: Michal Hocko <mhocko@suse.com>
>>>> Cc: Mel Gorman <mgorman@techsingularity.net>
>>>> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
>>> Reviewed-by: Vlastimil Babka <vbabka@suse.cz>
>> Thanks.
>>
>> I'm a bit surprised that this doesn't have a cc:stable.  Did we
>> consider that?
> 
> The VM_BUG just happens on 4.9, and it is enabled only by CONFIG_VM. For 
> post-4.9 kernel, this fixes the semantics of mbind which should be not a 
> regression IMHO.

4.9 is a LTS kernel, so perhaps worth trying?

>>
>> Also, is this patch dependent upon "mm: mempolicy: make the behavior
>> consistent when MPOL_MF_MOVE* and MPOL_MF_STRICT were specified"?
>> Doesn't look that way..
> 
> No, it depends on patch #1.
> 
>>
>> Also, I have a note that you had concerns with "mm: mempolicy: make the
>> behavior consistent when MPOL_MF_MOVE* and MPOL_MF_STRICT were
>> specified".  What is the status now?
> 
> Vlastimil had given his Reviewed-by.

Yes, the concerns were resolved.

