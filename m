Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE673C31E5B
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 15:30:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 723A721721
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 15:30:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 723A721721
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 120FD8E0002; Wed, 19 Jun 2019 11:30:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D0668E0001; Wed, 19 Jun 2019 11:30:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F011C8E0002; Wed, 19 Jun 2019 11:30:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id CD18E8E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 11:30:40 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id h198so16044813qke.1
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 08:30:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=doHiHlLdpZYETvUXJRdopeecWzdLK0lJ191H3n7YBfA=;
        b=cdLxNzQ3KQ6TnsoEqJwjJf5ZijYaZiRMy+DWaZImDYh9zfU9aKjlHpIdj3FtsF+3cl
         /FoSsusR1QTAj5Z84sSa4XhMSTeGLf+YYMyo924OXzvJ7tae4RcWMYarSQMI2dsHNt+P
         awOQqTP01yCadjH/VKY1GhB86WklwaXw/hmDWwn2uxSvF9UjQ3Ocb6iLFAnTVIHgUZaT
         VmYaXBIJKP92qd+FkPFTl5rso8jBs7Npdg4gcvtfiIRkhtzwcbv9gvE24E4Qehu/rjR9
         Ut1il1Pp95ne16Gp6yfGhX/cyzzjllWkyq7lISb1bQiMNAOj7zkLBvfR37/8BMJUIAUB
         pcnQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXBblNDcO49LtrynPnUmd9AkLtKKZ7qjk06X6LT11+Kv4wLX/wv
	+JrKCPbcTDnfjOEj5MqQ8ED2qtmhdkM66kfjfYE1FIVmiJ8DDmKkV4nT2zdz6BH7rXhLFhBHw1C
	3IIlEo1msS0adU3y4tnE3oJSGBh4842U21xUXw/aqY4kvaYbqxNua7r6+dEnjtsXELQ==
X-Received: by 2002:a37:47d6:: with SMTP id u205mr35183998qka.214.1560958240599;
        Wed, 19 Jun 2019 08:30:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwD4ftJH3Td8pgf0CtgDTZzBtaSdEhfOEFBbmoOP9WRfAQL3Fby2QsBxqPxhSqVI7jMMhpo
X-Received: by 2002:a37:47d6:: with SMTP id u205mr35183945qka.214.1560958240036;
        Wed, 19 Jun 2019 08:30:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560958240; cv=none;
        d=google.com; s=arc-20160816;
        b=BfLhqVd52ypcp9AOcT1tDdP+ZgRBlUkZwBFsWM49+TfqS8TRfIhd4hKPl71ZY04u6x
         LSPn5+yDlRlEnmMmYXd5ywWLKHXdlpj2JCxH8Sk9Uwe+p69q1iyuFR2ixEUBhUVlXwdo
         WdZSfO5q0HbLYzB/O6n6L7FX6opm0W4SHa2yPBnSLmLEIx0rtaXVXnKPmNBQEqXtnFsC
         3uSD3clKpI+ZpWjOo7cxAhoZzXJ2stATSgSqCgfvUIkNY55xZRY1whUWF2sQ2fn6RLum
         4nofiWcdwmK9qDL+Q0tUgehpKR1/JIpf9vqLlq9d/tia0N8Kn3j0vFg67La+ezfqzDy3
         TkzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=doHiHlLdpZYETvUXJRdopeecWzdLK0lJ191H3n7YBfA=;
        b=eMdJ8bSYB9Isph774jdY1mekv8+9Akh4Fib+4mmjeaJ1QxM08Z60wtQ8nNp3EUIiNH
         DpcpO2dwn7T9KtQ9UeyWHfEsCrtGY3eu+cAT5x7fE6//uxyE8eqy3MBqgzCdnZiFAcuc
         fA1oiYFf+et54Rh7R02CpcRE5xyawuuCOqeluDXvxJE+0Xf0a6yE1h1WEYMkMnZH03ES
         1/IcQfjpn+FEbwlo2r8KPYdIvvX+De2ODPlQGXaYH2PpsZzl8NyCGbAMsv6g6xIiZJte
         NCv2Jy4w1ktC8N+Ghh0pQXtJur20QlNakpqOzMv9W4JKcPVwa07WlTg+IVk0DwK4Hvsl
         84CQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u55si6188871qvg.168.2019.06.19.08.30.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 08:30:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7BC1030BB559;
	Wed, 19 Jun 2019 15:30:22 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-85.bos.redhat.com [10.18.17.85])
	by smtp.corp.redhat.com (Postfix) with ESMTP id BC5B319C79;
	Wed, 19 Jun 2019 15:30:16 +0000 (UTC)
Subject: Re: [PATCH] mm, memcg: Add a memcg_slabinfo debugfs file
To: Shakeel Butt <shakeelb@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>,
 LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>,
 Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>,
 Vladimir Davydov <vdavydov.dev@gmail.com>
References: <20190619144610.12520-1-longman@redhat.com>
 <CALvZod5yHbtYe2x3TGQKGtxjvTDpAGjvSc8Pvphbn00pdRfs2g@mail.gmail.com>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <20831975-590f-ecab-53db-5d7e6b1a053f@redhat.com>
Date: Wed, 19 Jun 2019 11:30:16 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CALvZod5yHbtYe2x3TGQKGtxjvTDpAGjvSc8Pvphbn00pdRfs2g@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Wed, 19 Jun 2019 15:30:34 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/19/19 11:18 AM, Shakeel Butt wrote:
> On Wed, Jun 19, 2019 at 7:46 AM Waiman Long <longman@redhat.com> wrote:
>> There are concerns about memory leaks from extensive use of memory
>> cgroups as each memory cgroup creates its own set of kmem caches. There
>> is a possiblity that the memcg kmem caches may remain even after the
>> memory cgroup removal. Therefore, it will be useful to show how many
>> memcg caches are present for each of the kmem caches.
>>
>> This patch introduces a new <debugfs>/memcg_slabinfo file which is
>> somewhat similar to /proc/slabinfo in format, but lists only slabs that
>> are in memcg kmem caches. Information available in /proc/slabinfo are
>> not repeated in memcg_slabinfo.
>>
> At Google, we have an interface /proc/slabinfo_full which shows each
> kmem cache (root and memcg) on a separate line i.e. no accumulation.
> This interface has helped us a lot for debugging zombies and memory
> leaks. The name of the memcg kmem caches include the memcg name, css
> id and "dead" for offlined memcgs. I think these extra information is
> much more useful for debugging. What do you think?
>
> Shakeel

Yes, I think that can be a good idea. My only concern is that it can be
very verbose. Will work on a v2 patch.

Thanks,
Longman

