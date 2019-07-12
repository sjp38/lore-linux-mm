Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AEC5EC742A8
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 03:43:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C6D421530
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 03:43:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C6D421530
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F1C9F8E0113; Thu, 11 Jul 2019 23:43:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ECCBA8E00DB; Thu, 11 Jul 2019 23:43:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6CFC8E0113; Thu, 11 Jul 2019 23:43:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A0AA68E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 23:43:21 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id c18so4894746pgk.2
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 20:43:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=g8H/X8ff/A+QKjFqoSkOCnx1O+oH9fs8Jz3g8pAxk4E=;
        b=o23PET/oUXrdRTUJ37ulPUwxvZD6fR0EFkkt8hPiw1n5N9S3pynGBRVf4u6EshRIFE
         KWdRaksZo0Zp+8dXU3Cv0DscrzKGuCEQzC3OTtWw+AUKRs14GXlanZFvih5ZXkbb95pn
         745lLp/xpjCfKRxVM9XRC+Yp9WLy9UeolaNQ2YerIlWuRvVX9gv7rET7cC4AqlAsEQS5
         pHEzAhYi1ef6KV0HFT2TSKrn2avRdK5Dw3B4u2ApR4T1XsD201HcWGFP3+6u+B5WVt3a
         k/dG/ijCuNZIZjRvn8u3Lh55o8Aao22cQVQy+wRfD2ewut1SchsXbtenASrPFusKGpmS
         81cQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVID5QEWqs1/pGQNVlQmjR2IZL/eU9cEnUDZVjvLY48hdFR2nlf
	bzxRMZvMN75N9mPMLMnPI4SFrD53sx4pw7CIZofTUVuAopKBPCyJKUBb7pAcCPwm78flxALVWgt
	/CwIwoadXuIU8Ut2R+Ls8liUK8gKhwwDqLdX5x9BD7RI3hrm52QLaRv+bnehIAxwftA==
X-Received: by 2002:a17:902:7887:: with SMTP id q7mr8813938pll.129.1562903001355;
        Thu, 11 Jul 2019 20:43:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxsOHQkPjhWtVGizMU+/ZthsvA77NzoS1RgJRQY4vmQmy8HlrjBg6ifGOmv8Uxqt0BQqB5f
X-Received: by 2002:a17:902:7887:: with SMTP id q7mr8813882pll.129.1562903000621;
        Thu, 11 Jul 2019 20:43:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562903000; cv=none;
        d=google.com; s=arc-20160816;
        b=V0RLgndnvzArRuqW48J2yCEAgaee25yL3jpK3WXJmjoLJctEyVGAb6SjaPOGCdx4iJ
         N6SAjf9yVfIWQTHVj0xdmXynXDsk3pP++Ayle3g2pFHod3q2vpkRThgGS2qny5HxMbEr
         nY5z5xWtbdkRGi2XHDRNUOsadhTte9l1S26sAMDDDnycANQMZIjoCGtrkjn6GLtWxggm
         CTPlAxsKxws3RYS8jd/8q4eZxbzwza/KmRBpI4CfBGLHNFzewgsw6f2uxDhoRvcVXzZk
         NZTQyY/50ADq0sLOJN+zhLfACr5fENtJiJDLrJuOdjwD09+uWyS7xkNRuSNeZxS+tOxl
         Bl+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=g8H/X8ff/A+QKjFqoSkOCnx1O+oH9fs8Jz3g8pAxk4E=;
        b=XHnPCusgGg6D3ZD0vjqiCSJH0BuSQpv4iGseDBsKEjZooMg9ddHmCcPjwtsOkExdDd
         PFclZx+znW8F5GpGZ6mxB524/Xlhis5a0UGhL2PV/zPvcOxrWHr2jEaG7ZP3hPJH0Ba/
         phTffBgYq1Eb1rmq8WwggM+NK2szOsLtPj8Hk9/bjdfnDij4NnP0GJI01SgtUJPhTneN
         E3kshRLLjbPKz6Fjo26D4NGzEHl4plNNkqUCYmPVpU70j1ltOXc2PVP1WeWhsqEyAU5J
         R4nnI3VbEPEmcIuoMAhVrCyIZafC3w7zbyS3GN+79BOo+15a7THEiMqy5N8c4cddw5sM
         VgPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-133.freemail.mail.aliyun.com (out30-133.freemail.mail.aliyun.com. [115.124.30.133])
        by mx.google.com with ESMTPS id t31si6934371pjb.25.2019.07.11.20.43.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 20:43:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.133 as permitted sender) client-ip=115.124.30.133;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.133 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R171e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e07417;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TWfco61_1562902997;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TWfco61_1562902997)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 12 Jul 2019 11:43:18 +0800
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
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Message-ID: <b027f9cc-edd2-840c-3829-176a1e298446@linux.alibaba.com>
Date: Fri, 12 Jul 2019 11:43:17 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190711134754.GD3402@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019/7/11 下午9:47, Peter Zijlstra wrote:
[snip]
>> +	rcu_read_lock();
>> +	memcg = mem_cgroup_from_task(p);
>> +	if (idx != -1)
>> +		this_cpu_inc(memcg->stat_numa->locality[idx]);
> 
> I thought cgroups were supposed to be hierarchical. That is, if we have:
> 
>           R
> 	 / \
> 	 A
> 	/\
> 	  B
> 	  \
> 	   t1
> 
> Then our task t1 should be accounted to B (as you do), but also to A and
> R.

I get the point but not quite sure about this...

Not like pages there are no hierarchical limitation on locality, also tasks
running in a particular group have no influence to others, not to mention the
extra overhead, does it really meaningful to account the stuff hierarchically?

Regards,
Michael Wang

> 
>> +	rcu_read_unlock();
>> +}
>> +#endif

