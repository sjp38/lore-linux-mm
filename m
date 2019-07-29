Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA0EBC433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 21:42:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DC3D20679
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 21:42:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DC3D20679
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1439A8E0003; Mon, 29 Jul 2019 17:42:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 11B7C8E0002; Mon, 29 Jul 2019 17:42:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 02F718E0003; Mon, 29 Jul 2019 17:42:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id D2AD88E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 17:42:24 -0400 (EDT)
Received: by mail-vs1-f69.google.com with SMTP id x22so16444811vsj.1
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 14:42:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=vA0RUcGnOsNwMHxKlpsyfm3KKPd5xhRHpuGm3uKT3t0=;
        b=JVpuq2kFc8ac0Ea8jlxq+9VSNTs4FQ/7Ib7kDApoFjhfPgOzpVSR1bLeibhAOSL/Jf
         To6OAoDajkKr32sakqF0K15p1XdG8lE1Lwt/jkRIQrUyPoUZ7YD+qyyExEQIKCBNizwq
         zgn5gjASCuOCaUHZTc0U9S3J7AzY4bvFa3nTHFCJmiXydoj7BN1Rps8ZykwFUXaM8dGU
         nzQbPdcGIrVK03CbhGWkVPVYmvYAlR9d8Nw3D9tDhEC38q2zj8BqrpBJMsVY0Y+slft5
         24Zoziucb+gwly3l9eaO022zSzTKxDkHq8mNw1wL0BOco+I5bBxUYW1dQRa5xRARbnrU
         3O1w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV1bQKPRdCGMylnojQeXhNkUh7JJw0cAsYt3ZNmYNfSjshIqWGj
	hkB4CjkGiIF0kavXrO110Jhej9V5kCh0+gz+/26mEEzpVifdkdAQen5efd+UkjxdvBn0sff/lDd
	QQylE3yUtyUVd1DLNWPJTiAsCeF/++HJUKuRiBL+/zOqQzr55M+BQOE3eds4HcsBDGA==
X-Received: by 2002:a1f:bf07:: with SMTP id p7mr43683662vkf.8.1564436544522;
        Mon, 29 Jul 2019 14:42:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzqVVcTImQFIKVTEXa4vlTzJIRNccRq0+BmoCI+aYKhQkFWm89sLSGYAKxSVHmFHWa5Bx9y
X-Received: by 2002:a1f:bf07:: with SMTP id p7mr43683633vkf.8.1564436543915;
        Mon, 29 Jul 2019 14:42:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564436543; cv=none;
        d=google.com; s=arc-20160816;
        b=Ku/2DlPHfrl+DHS8q/NXAM6JJPsd1J5iTtKY4LgMdEjYTdJObEJxOQJQINaHx5P9Es
         et2UQh/W9xBizjILBPKvZ+3j6qU5Hs6aCcb9x4i6X0XGzxPi592/8TLuej/BFgf9vvwO
         myEjPxx08e50VglR4ZhR6q4o1NvbToYEskzuWUM1DchyagjtwfIB1Z3Rf5Z4gTf7Bwgn
         7rDB0jE2wfKMU7pEm8GjLJZJ7n4nH7HJ50FfESs71S1fpShpD6rDwQmw8iycDN+yY6OQ
         EBJUOsYerbPlyQIQwkwMx/uuiW0zRYfmiOX52l2kHkzDg7jXTBreuLfd2D/ZguNeYsz0
         dv9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=vA0RUcGnOsNwMHxKlpsyfm3KKPd5xhRHpuGm3uKT3t0=;
        b=RUS02fhcvsGU1kKJBc2n8YgNJ3Pv/B68hogyzWclDOmCTGx+P+smwJnf6Bh373JOTr
         Xh7ygpmsXxohwIdd1jH4KBb/+iqbGH+DwUwRjf7w5f695MQ44fE+kaVI6O0fB4uaEx2q
         /Tzhk5oV+8Dlm3wdNlQJvRGAkMArxuIkBlXZI7+rXpWSZhU5w49RSVMwvXFPUiosACY2
         NGbpMl9plvpHC3pVbLYyX1pQX66fd2kcuRNhq4um9EVCGljoI6M+qqVFKJ1dODejXGSw
         TvfZkFiuWoCmIl92a/Q811nHn9n+Csehz3DlJj7eg27ziRNBLco+xssUP8zCLO2fB0PX
         evVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h6si13878645uac.127.2019.07.29.14.42.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 14:42:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 0D74D308FC47;
	Mon, 29 Jul 2019 21:42:23 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-160.bos.redhat.com [10.18.17.160])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 7831260167;
	Mon, 29 Jul 2019 21:42:21 +0000 (UTC)
Subject: Re: [PATCH v3] sched/core: Don't use dying mm as active_mm of
 kthreads
To: Rik van Riel <riel@surriel.com>, Peter Zijlstra <peterz@infradead.org>,
 Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Andrew Morton <akpm@linux-foundation.org>, Phil Auld <pauld@redhat.com>,
 Michal Hocko <mhocko@kernel.org>
References: <20190729210728.21634-1-longman@redhat.com>
 <ec9effc07a94b28ecf364de40dee183bcfb146fc.camel@surriel.com>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <3e2ff4c9-c51f-8512-5051-5841131f4acb@redhat.com>
Date: Mon, 29 Jul 2019 17:42:20 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <ec9effc07a94b28ecf364de40dee183bcfb146fc.camel@surriel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Mon, 29 Jul 2019 21:42:23 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/29/19 5:21 PM, Rik van Riel wrote:
> On Mon, 2019-07-29 at 17:07 -0400, Waiman Long wrote:
>> It was found that a dying mm_struct where the owning task has exited
>> can stay on as active_mm of kernel threads as long as no other user
>> tasks run on those CPUs that use it as active_mm. This prolongs the
>> life time of dying mm holding up some resources that cannot be freed
>> on a mostly idle system.
> On what kernels does this happen?
>
> Don't we explicitly flush all lazy TLB CPUs at exit
> time, when we are about to free page tables?

There are still a couple of calls that will be done until mm_count
reaches 0:

- mm_free_pgd(mm);
- destroy_context(mm);
- mmu_notifier_mm_destroy(mm);
- check_mm(mm);
- put_user_ns(mm->user_ns);

These are not big items, but holding it off for a long time is still not
a good thing.

> Does this happen only on the CPU where the task in
> question is exiting, or also on other CPUs?

What I have found is that a long running process on a mostly idle system
with many CPUs is likely to cycle through a lot of the CPUs during its
lifetime and leave behind its mm in the active_mm of those CPUs.  My
2-socket test system have 96 logical CPUs. After running the test
program for a minute or so, it leaves behind its mm in about half of the
CPUs with a mm_count of 45 after exit. So the dying mm will stay until
all those 45 CPUs get new user tasks to run.


>
> If it is only on the CPU where the task is exiting,
> would the TASK_DEAD handling in finish_task_switch()
> be a better place to handle this?

I need to switch the mm off the dying one. mm switching is only done in
context_switch(). I don't think finish_task_switch() is the right place.

-Longman

