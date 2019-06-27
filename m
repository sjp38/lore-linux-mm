Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0017FC4321A
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 21:32:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A97F4208E3
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 21:32:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A97F4208E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5125A6B0003; Thu, 27 Jun 2019 17:32:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C25D8E0003; Thu, 27 Jun 2019 17:32:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B1398E0002; Thu, 27 Jun 2019 17:32:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1B0856B0003
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 17:32:28 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id s22so3810177qtb.22
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 14:32:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=CP7aLAnfYTbOJpGmh7JL6TuaJuswBWhgp3QhrdQbne4=;
        b=rxVWFViYKJoYdIw334rBSSsaZ+wD+P8WHDorcjmR4SCfTxSTYm0MtJnyyQeU2LQRXL
         Lau8gPEW0l9KDn/zO+Ss6r1cLhXDeaeKR6YCxQ+khMMopXu24NhDhsgYPGJblqdRIbAq
         +I9t2qnxjon5saEHcsPHpW/hXo5SvDDQAzLrvEFPurwT0WIkCsmv2WI4sxDvv+e7L/Fx
         TX/PJURCJMkXyiJC4hbBh6wbM7e4himlfsnJo/Un7dwDqGN7HQL2h0puK0GQ8CqXij+w
         HoiKKD8D1+FEAt8Zc+8LrBhQa9iT+dQLRUGUJTvdXOtxJXysnCHNq5oXiUBlubr1rq1g
         oS/Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUBQ6dcZQHazA0UAc8onLv59xKjJasn24k+9I8oVHR9aQVSM4WR
	ukRmc5hMdWN8B359GkdAP8rdqf7dLD0zbU/aTM75GaY+VKjk3uonSYjCLpKTYs2olxKy4yYVZ+o
	C8jJTS50SWxfJyn1dpADfDtAHxft4cnP879BgfwWFsAQoZdUm61IhzUiUR9WIafBhdw==
X-Received: by 2002:ae9:eb96:: with SMTP id b144mr5214082qkg.321.1561671147914;
        Thu, 27 Jun 2019 14:32:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwn3YVzMH1/qdW9j4/XGouD3arI0NffGsIRojkPpcNczzWcHc5e3z8Ut7hup0LgFqgJPqLd
X-Received: by 2002:ae9:eb96:: with SMTP id b144mr5214049qkg.321.1561671147473;
        Thu, 27 Jun 2019 14:32:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561671147; cv=none;
        d=google.com; s=arc-20160816;
        b=SBCXKAbNSwHkdPT4mDgBFs5JUklQUTXqmPSgV2dovCu1qjsulUt3lKaMtHXHoGPUBA
         rIpKDrxis0qzObLEZVPfQRTP8oqMK0vn1DmxfqGRsTtpxOvqzUSd4ZiFtkDcu70UPXsZ
         heq7PmrALcfMRpARz7DPIuT6ENOs1M/z6YlBilL5jue7nYdzhqwfgq9QSRP1qEO3nHkx
         ps0imIZOl/hF5vxij2PYJTceHiePjTkQ+BoBULoFSVHlq4ou61pcnE6fBHLqQ8wrjzUp
         D8p3ddSQIblwSD/E3sA07lKMp1UnH0SpvW6m0gDiwBPU9m8LRsgoPH9g3dcMhJ5pZgWC
         U0Dg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=CP7aLAnfYTbOJpGmh7JL6TuaJuswBWhgp3QhrdQbne4=;
        b=Eb/TMce/alCkV+G3MFtGLjgQGcRv3DOn1uI6u7oK/qsOS/8pTOPc5mgctgtkNsNjOf
         a2fMBw6VQjptgLEpocHugQAhk3XMwUqPCHM9UO1bAgBRP7QY68SLV2Vctr/EXmd/aMK7
         Jszjsq1Na/EG0P9wuT4Zho2yBWdMyLz+Uaoa9qPnFpbD5S/WGBADwDZuGsHm9YjLxFnR
         eBgRuEqhXbl5hD1TVGZHmSopTkngrpYHb4M+QnpQhLEx4HClRNTcP/Z44/zs4Bi36fXV
         qdvCFYmFBWzxCvVRbvM7ytp45yIXNj6YDuHT8+1jOnmIi3dAnYLrn1S1wJ7/frKies4d
         8V0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c4si267214qvu.107.2019.06.27.14.32.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 14:32:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id CBC2558E5C;
	Thu, 27 Jun 2019 21:32:06 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-85.bos.redhat.com [10.18.17.85])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 28CB85D9D2;
	Thu, 27 Jun 2019 21:31:59 +0000 (UTC)
Subject: Re: [PATCH 2/2] mm, slab: Extend vm/drop_caches to shrink kmem slabs
To: Roman Gushchin <guro@fb.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Andrew Morton <akpm@linux-foundation.org>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>,
 Luis Chamberlain <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>,
 Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
 Vladimir Davydov <vdavydov.dev@gmail.com>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
 "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
 "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Shakeel Butt <shakeelb@google.com>, Andrea Arcangeli <aarcange@redhat.com>
References: <20190624174219.25513-1-longman@redhat.com>
 <20190624174219.25513-3-longman@redhat.com>
 <20190626201900.GC24698@tower.DHCP.thefacebook.com>
 <063752b2-4f1a-d198-36e7-3e642d4fcf19@redhat.com>
 <20190627212419.GA25233@tower.DHCP.thefacebook.com>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <73f18141-7e74-9630-06ff-ac8cf9688e6e@redhat.com>
Date: Thu, 27 Jun 2019 17:31:58 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190627212419.GA25233@tower.DHCP.thefacebook.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Thu, 27 Jun 2019 21:32:26 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/27/19 5:24 PM, Roman Gushchin wrote:
>>> 2) what's your long-term vision here? do you think that we need to shrink
>>>    kmem_caches periodically, depending on memory pressure? how a user
>>>    will use this new sysctl?
>> Shrinking the kmem caches under extreme memory pressure can be one way
>> to free up extra pages, but the effect will probably be temporary.
>>> What's the problem you're trying to solve in general?
>> At least for the slub allocator, shrinking the caches allow the number
>> of active objects reported in slabinfo to be more accurate. In addition,
>> this allow to know the real slab memory consumption. I have been working
>> on a BZ about continuous memory leaks with a container based workloads.
>> The ability to shrink caches allow us to get a more accurate memory
>> consumption picture. Another alternative is to turn on slub_debug which
>> will then disables all the per-cpu slabs.
> I see... I agree with Michal here, that extending drop_caches sysctl isn't
> the best idea. Isn't it possible to achieve the same effect using slub sysfs?

Yes, using the slub sysfs interface can be a possible alternative.

Cheers,
Longman

