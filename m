Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 69EACC742A5
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 03:10:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3B20A21019
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 03:10:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3B20A21019
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CEBFD8E0110; Thu, 11 Jul 2019 23:10:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C9B4B8E00DB; Thu, 11 Jul 2019 23:10:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B88E18E0110; Thu, 11 Jul 2019 23:10:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9AA7A8E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 23:10:15 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id 132so9036751iou.0
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 20:10:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=8yIBI6EFnDFXxbPYKj916DCtzCtMurdycLFwzVm1XTU=;
        b=Tfpe71srCcznBUse81V0hlq7rkWjsPMuuh+QxM82R3TzADdwGggjuo/AnrHOBQr6rJ
         TPfcqMW8r062ACtFSqT+BgDShHU0cYiL7jGUIcnZS+NyrOY/qpd8belP2h38s4jIqvP1
         SRsRikjkEN6ZejUBaFGtv6hwqKYCWIgANI5MzDvSHT62QDtTX3FgWt9rCpYhQAVWd2EZ
         BQYCKO6LVzSvOxHf5pz7QAQxWNMcMh/ltyeOPPluZUh+dwvURQIUXMBsSwXWYWafN2Qh
         YOq/OVLU+OGNdF2Uk2T9Agal957zxVAgtVR7LXjtn3TYAWEpVgtuHyEMduYPcd0MXQDb
         qtyA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVT3wCN/l9qSIiI4po3Oh07HjbUOW9BpLSWyafBs7wgvsFsRmWL
	yifOFZgcZo6eJofD20Ki1krGCnLIEkHaUsAOp53yPyhay9UU63cNgd6Pz3zB2GGhULiFVS13Wph
	Qz9r9/eBMrtCQ5+31MUyEvAW4pwRNDjlfiPeE9J0K0qcE9Wmr3QNCfP8uiYmbRMnh3Q==
X-Received: by 2002:a5d:8905:: with SMTP id b5mr8383660ion.291.1562901015429;
        Thu, 11 Jul 2019 20:10:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw2LAkKiyDI0X0t9z5DZEtP9PBuZa4VeOG6rJh2iMLcdPiwsbhPuqzWXYXOgJrwOZAAQHBI
X-Received: by 2002:a5d:8905:: with SMTP id b5mr8383618ion.291.1562901014832;
        Thu, 11 Jul 2019 20:10:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562901014; cv=none;
        d=google.com; s=arc-20160816;
        b=jg5fsSoeIn78hi/cg5dqIqGIjjKPYX+b5V3Ta54MJmd4fQNE15SBGPCYcQWZk6oiU8
         Upx/glxFSpkPNHG53dax33GoXdtrFPAYk7aSySatw9qazhJa3Cl8R+mkpcRZuckhn6OI
         Tc3+3N5OnkwxyKkCdYJvH+t/3eagxjqUCMBfasKG+waqF79F60Bek+GAm0IRsJi8trsl
         0ji6DjfZ/bitiY8COymYJux3QnwZHCXp9lGC+ngHS1xc1n66UfTvds8dUzQEv/52sBmV
         iQLcaaLF42hPkn1n/2bzjSu5O81ofggCTrCIT8ocvkTrmRG7PSpULyJIsM1ZqGERxROV
         dv4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=8yIBI6EFnDFXxbPYKj916DCtzCtMurdycLFwzVm1XTU=;
        b=J3Qpi2XfCvXzak0VAWUK3I2xGCDVWK6dPqbAS4zGCQEMoE/O5P4lc3fVXP31gX3hXy
         nbZG9ZfhJPDEqXwAcg/KELdlPH98aVlvBQXw4eUVIKU6SQT+fSHQ6Meqk4fk59rH7szG
         7LWVBtpTjUi1pIWyuF2CqvJbxCg090EDNaQdOLfRkGK7aylGgDonOyV7tgT18RYdcT4e
         ekavBLy63Rhzzu8o4xLlR4KT0NQqFw2LHOVEVtl2LVyKEyxNppU3qbrswLx/VUfxAGX9
         grzmz61QtSyIdobf6ckZATnrvaNBTxPjz9VU6d2jtgb91QpUGqF8AFq3CfFXf/a/bxfX
         hCGw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id z26si10483739ioe.90.2019.07.11.20.10.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 20:10:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.131 as permitted sender) client-ip=115.124.30.131;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 115.124.30.131 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R121e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04394;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=13;SR=0;TI=SMTPD_---0TWfcINf_1562901008;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TWfcINf_1562901008)
          by smtp.aliyun-inc.com(127.0.0.1);
          Fri, 12 Jul 2019 11:10:09 +0800
Subject: Re: [PATCH 4/4] numa: introduce numa cling feature
To: Peter Zijlstra <peterz@infradead.org>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov.dev@gmail.com,
 Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, mcgrof@kernel.org, keescook@chromium.org,
 linux-fsdevel@vger.kernel.org, cgroups@vger.kernel.org,
 Mel Gorman <mgorman@suse.de>, riel@surriel.com
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
 <9a440936-1e5d-d3bb-c795-ef6f9839a021@linux.alibaba.com>
 <20190711142728.GF3402@hirez.programming.kicks-ass.net>
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Message-ID: <82f42063-ce51-dd34-ba95-5b32ee733de7@linux.alibaba.com>
Date: Fri, 12 Jul 2019 11:10:08 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190711142728.GF3402@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019/7/11 下午10:27, Peter Zijlstra wrote:
[snip]
>> Thus we introduce the numa cling, which try to prevent tasks leaving
>> the preferred node on wakeup fast path.
> 
> 
>> @@ -6195,6 +6447,13 @@ static int select_idle_sibling(struct task_struct *p, int prev, int target)
>>  	if ((unsigned)i < nr_cpumask_bits)
>>  		return i;
>>
>> +	/*
>> +	 * Failed to find an idle cpu, wake affine may want to pull but
>> +	 * try stay on prev-cpu when the task cling to it.
>> +	 */
>> +	if (task_numa_cling(p, cpu_to_node(prev), cpu_to_node(target)))
>> +		return prev;
>> +
>>  	return target;
>>  }
> 
> Select idle sibling should never cross node boundaries and is thus the
> entirely wrong place to fix anything.

Hmm.. in our early testing the printk show both select_task_rq_fair() and
task_numa_find_cpu() will call select_idle_sibling with prev and target on
different node, thus we pick this point to save few lines.

But if the semantics of select_idle_sibling() is to return cpu on the same
node of target, what about move the logical after select_idle_sibling() for
the two callers?

Regards,
Michael Wang

> 

