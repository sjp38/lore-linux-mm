Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 55A63C742B2
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 10:10:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 22AEA2084B
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 10:10:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 22AEA2084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B3D1F8E0134; Fri, 12 Jul 2019 06:10:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B1EBF8E00DB; Fri, 12 Jul 2019 06:10:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A2A5B8E0134; Fri, 12 Jul 2019 06:10:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 707008E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 06:10:30 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id x18so5280658pfj.4
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 03:10:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=REBvcJprToXHI3qdYqpmAjiRWd8w6Kmc0McC5wngh0E=;
        b=fLtX6qXpavRhXA0xhsOx0MxAy6X/MJZ9dlAIh/PNdA08jRo5szvVKiFUzafs9uLR9a
         GP9m5r1Qo65aBMlBqNe+lVkPPtGyGGuzQTonJSGi1rhQZYUVEZOb6HanwhT5IzB8lAD/
         a8mmat3x6w78v12oYeeFeWDk6+nACz7U0dmQ+0muYRcRziLE/H0cUp0RLak7vPjPTlXH
         1LMKpWH7QFMVgrObR0tIebOGA0UBP9RjTvE3g+tkYLXkGNzbN6fQEaHWlhrH/vKwz0bx
         xQop6jsZPkc+D65MEyKK6h5zJBWXLH3qvke/WI1on6lRFPYEH9R5GQ0Pwf+il3LF6kzN
         HVjQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAW8L3fFemB3KIQEZ8IsBQFG7UDBZbP5BnKCthvfMxFqD5lU7SO9
	cO7ikXOeb1r8+iHfGm5qzGxjO4LdVmglDdrtATRlIZirlsIcI7hnFenxS4Z2RjoNO84fdvYJRl3
	tdFO1+NdwngS2q0wC/uvoRmtrtvikBC3O6Mb6qey4mZ1Uli5MDphayvRtSWDqVv+aYQ==
X-Received: by 2002:a63:6103:: with SMTP id v3mr10267998pgb.161.1562926229913;
        Fri, 12 Jul 2019 03:10:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw66GUjC3rnOWeDRlXAraK2m2FblK/ZhjxcziJelKgZ5kUPB1+qAJ90yHz7y6aN8mbZoPg6
X-Received: by 2002:a63:6103:: with SMTP id v3mr10267938pgb.161.1562926229264;
        Fri, 12 Jul 2019 03:10:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562926229; cv=none;
        d=google.com; s=arc-20160816;
        b=DX4dagfv0AsftuNJk75PtdZTCe0pkes0EQdILY+nctuarQg0P/fHqMlLGBXY7oc3lq
         xvTTfaeHZoFpZUT61RZJmvT2ceQlPbLAR/8uVUBZ06ZE5EQ19CixlCb4UMb6nJDBmBak
         Oehp+/kbw0dyKBOu6tYhNacKFEQNrL5Skt7865WURU6Mb0TfOmnhiMv83avLoCrFalb2
         WD8Fj1/+kmcW38quOjlIOQ4wTTBhlqMQSx2+VxWtVuReTA5c4WdK0dNdU8gMZNOlF9cs
         2YOKOGXkk3mIh2zFI8t4VnfZSBpz5LwfKgbCdhhmALDnswkv6FFI9QM0CvBUmErsXOby
         Gk1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=REBvcJprToXHI3qdYqpmAjiRWd8w6Kmc0McC5wngh0E=;
        b=ls3HPrlx+73+2d6imIFtAfzPXE0vupwl+p18taKrsO+SnSbVFbXExWnhJFFxujYPkR
         vIAymAFEvHHVaO4f2V79P9phLueJSbDDGsFIyEe8+I00qjFVsl1L/7UJxtCUjrSP7o61
         xhmlIjEQBe5RDx/GSJ9lvZ3UbMiF0EJKGr/nrwTljfsG0mE5qOXGTXGEy4HT0NB12kHt
         IoVC8Ek3sV71gSRMTnM6+wLGbXrRbQS0YPdxGl4WrerzVr6J57/EW+wRvanNrnEjeU0m
         CMwRmGvVmwSh5BpK2fQgd6cLyfzZ40kWii5i4mNjFjn7no9NxbfQZ8SLLi8hxx4JmCUL
         DEow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-54.freemail.mail.aliyun.com (out30-54.freemail.mail.aliyun.com. [115.124.30.54])
        by mx.google.com with ESMTPS id g1si7506886plg.353.2019.07.12.03.10.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 03:10:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.54 as permitted sender) client-ip=115.124.30.54;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.54 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R681e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07486;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TWhPUDd_1562926224;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TWhPUDd_1562926224)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 12 Jul 2019 18:10:25 +0800
Subject: Re: [PATCH 1/4] numa: introduce per-cgroup numa balancing locality,
 statistic
To: Peter Zijlstra <peterz@infradead.org>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
 Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, mcgrof@kernel.org, keescook@chromium.org,
 linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
 Mel Gorman <mgorman@suse.de>, riel@surriel.com
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
 <3ac9b43a-cc80-01be-0079-df008a71ce4b@linux.alibaba.com>
 <20190711134754.GD3402@hirez.programming.kicks-ass.net>
 <b027f9cc-edd2-840c-3829-176a1e298446@linux.alibaba.com>
 <20190712075815.GN3402@hirez.programming.kicks-ass.net>
 <37474414-1a54-8e3a-60df-eb7e5e1cc1ed@linux.alibaba.com>
 <20190712094214.GR3402@hirez.programming.kicks-ass.net>
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Message-ID: <f8020f92-045e-d515-360b-faf9a149ab80@linux.alibaba.com>
Date: Fri, 12 Jul 2019 18:10:24 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190712094214.GR3402@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019/7/12 下午5:42, Peter Zijlstra wrote:
> On Fri, Jul 12, 2019 at 05:11:25PM +0800, 王贇 wrote:
>>
>>
>> On 2019/7/12 下午3:58, Peter Zijlstra wrote:
>> [snip]
>>>>>
>>>>> Then our task t1 should be accounted to B (as you do), but also to A and
>>>>> R.
>>>>
>>>> I get the point but not quite sure about this...
>>>>
>>>> Not like pages there are no hierarchical limitation on locality, also tasks
>>>
>>> You can use cpusets to affect that.
>>
>> Could you please give more detail on this?
> 
> Documentation/cgroup-v1/cpusets.txt
> 
> Look for mems_allowed.

This is the attribute belong to cpuset cgroup isn't it?

Forgive me but I have no idea on how to combined this
with memory cgroup's locality hierarchical update...
parent memory cgroup do not have influence on mems_allowed
to it's children, correct?

What about we just account the locality status of child
memory group into it's ancestors?

Regards,
Michael Wang

> 

