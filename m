Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BB764C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 10:39:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60E3020851
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 10:39:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60E3020851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A803C8E0003; Wed, 27 Feb 2019 05:39:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A05218E0001; Wed, 27 Feb 2019 05:39:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8A8458E0003; Wed, 27 Feb 2019 05:39:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 464B68E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 05:39:21 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id x23so9410431pfm.0
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 02:39:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=RQQgZMic52QfvbqFRAojYLCGILqsjm+7QYj9Oo+eoHA=;
        b=icsQNo4Useatthnlm/YhWQD5jwRJOSXk5RlvE8YdL8emOZm3uq/4J2vn+N+CgSX3Ea
         6xzOUmc0f3vvE1J11zbkvEKZ8TM5YvArk1SppyfwfYysGga0aa6laOGkb8BsrqpTsuHV
         3bJ6Vlu3EswY49PnUY7glK9Cl2TVF4TQYkFhKlhMFWBKbWJZNKs5c5KLs317E5lwkICh
         3/MrESc06DOiVxKekpAAnFbMKdT7Bgp//Vhz69yOVUHE8/2DrQezvcQmxw+uPdIIXa2H
         IFHq6Vcq9nlSF+rIa48XLL9XNgOLnbDEbGabUfSRjUM8BHI+AJrxc9ERC2uJinkJ62eF
         t6+A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AHQUAuZtF25+4chPIZFNcyytzhLDYm31U8JstENJtAuVvVyR8fS0Yds8
	kmXd5xDOZuQKdP74zIhEKcGRyGSh3oJ2R0U/h9h8iHfmWF5jt28KYq8Y3AreHGzFl9lmIII5OQu
	EhmtJ5vRuySFMei6bjEZlOhg/8pKDBS/s4cAlcGHyhWXQGflKiZHlR8tGJsuv8QAdyA==
X-Received: by 2002:a62:4817:: with SMTP id v23mr926514pfa.81.1551263960814;
        Wed, 27 Feb 2019 02:39:20 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib1XnakIuZTKvxmSE9qD5ANVLQ+++Dcni2X67PS3PmHo2fBsVj1MHTMdXcGJL4yGrlWecuB
X-Received: by 2002:a62:4817:: with SMTP id v23mr926436pfa.81.1551263959726;
        Wed, 27 Feb 2019 02:39:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551263959; cv=none;
        d=google.com; s=arc-20160816;
        b=inRlTvK44o5q50bObB1TupirBCBZOfqWfBfSopINx+g4SFzKFoZg6lJZebFq7m/aCi
         NvqcENRJSGwJVulww6XgKZZSz1Pcx2K2qJWJ8Fk2TCpa4Jo0fAgDhqykb1Kap6Rn5FLJ
         ZpekaxP9OmR0agVgTVyhsqtYzGqgTTTMsdVeaUAlTHOZzNi0RI8Dl1UirG7rwfx6rXAq
         XaohJCIzCoFOG18YW4AdlcwN7TK8X5u8Q4BMQ2cda7lgdKb6OBCYoJbL1rcndBH0JFFs
         lplLmQInp2kb7vxTz/KQHAVsFMy2s3WqY8JkLZ2O+oMh6gQcHm+Ilm198pqgD3LvcZyQ
         JZaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=RQQgZMic52QfvbqFRAojYLCGILqsjm+7QYj9Oo+eoHA=;
        b=lMLTRzb5Vrjc/M7pdHog+/YmfiYX1aQLHxVJhdvuVWLjIkzXdNgpoItRhrJKd78S7p
         yHnavH0O1WQcTxxLVhAE6/sygP3Qx/+GXoLV59VTRwiF+c5ze1U7tsi5j1D7tri9XLfE
         Koavr3s7nPUEzKoVhDvSvzMCOGZnHmP0R9PsD9vhCHbYx7BAPl5Ma+YzpBgKiwNWbx7m
         DrpQeRU/dfLbUsAtCF64Nx5NG1wLK08gQep8x27wlPwaSo6sJ23uy4nuAjkE1hUXmFaw
         3FuXsWRp/HosHBbdGcA6G417PE1/ZGEk+RXwev1uLFQYXEtop36uRQGvBSybX9ZX8gEq
         flvw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id q4si13844753pgv.338.2019.02.27.02.39.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Feb 2019 02:39:19 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav107.sakura.ne.jp (fsav107.sakura.ne.jp [27.133.134.234])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x1RAdGGe041382;
	Wed, 27 Feb 2019 19:39:16 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav107.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav107.sakura.ne.jp);
 Wed, 27 Feb 2019 19:39:16 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav107.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x1RAdGsF041379
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Wed, 27 Feb 2019 19:39:16 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: mm: Can we bail out p?d_alloc() loops upon SIGKILL?
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org
References: <201902270343.x1R3hpZl029621@www262.sakura.ne.jp>
 <20190227092136.GM10588@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <ccd9e864-0e47-b0e3-8d0e-9431937b604c@i-love.sakura.ne.jp>
Date: Wed, 27 Feb 2019 19:39:19 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190227092136.GM10588@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/02/27 18:21, Michal Hocko wrote:
> On Wed 27-02-19 12:43:51, Tetsuo Handa wrote:
>> I noticed that when a kdump kernel triggers the OOM killer because a too
>> small value was given to crashkernel= parameter, the OOM reaper tends to
>> fail to reclaim memory from OOM victims because they are in dup_mm() from
>> copy_mm() from copy_process() with mmap_sem held for write.
> 
> I would presume that a page table allocation would fail for the oom
> victim as soon as the oom memory reserves get depleted and then
> copy_page_range would bail out and release the lock. That being
> said, the oom_reaper might bail out before then but does sprinkling
> fatal_signal_pending checks into copy_*_range really help reliably?
> 

Yes, I think so. The OOM victim was just sleeping at might_sleep_if()
rather than continue allocations until ALLOC_OOM allocation fails.
Maybe the kdump kernel enables only one CPU somehow contributed that
the OOM reaper gave up before ALLOC_OOM allocation fails. But if the OOM
victim in a normal kernel had huge memory mapping where p?d_alloc() is
called for so many times, and kernel frequently prevented the OOM victim
 from continuing ALLOC_OOM allocations, it might not be rare cases (I
don't have a huge machine for testing intensive p?d_alloc() loop) to
hit this problem.

Technically, it would be possible to use a per task_struct flag
which allows __alloc_pages_nodemask() to check early and bail out:

  down_write(&current->mm->mmap_sem);
  current->no_oom_alloc = 1;
  while (...) {
      p?d_alloc();
  }
  current->no_oom_alloc = 0;
  up_write(&current->mm->mmap_sem);

