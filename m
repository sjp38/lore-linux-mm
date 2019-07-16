Return-Path: <SRS0=rp0W=VN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=FROM_EXCESS_BASE64,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E018DC76191
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 02:41:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B6CE20880
	for <linux-mm@archiver.kernel.org>; Tue, 16 Jul 2019 02:41:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B6CE20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28B296B0003; Mon, 15 Jul 2019 22:41:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 260536B0005; Mon, 15 Jul 2019 22:41:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 128636B0006; Mon, 15 Jul 2019 22:41:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id CE4EC6B0003
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 22:41:54 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id u1so11675969pgr.13
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 19:41:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=ji+RxCiqfOwJBxPZnDmtI1jJJX/5nQve591xbmY/5l0=;
        b=MFs82WiB6poj6u9yXlKU9B6Z4ds6sVoC2QxP93f/ta1UUYBmY+0nBKLFFxUgDh6h9R
         5xazVeLr2YAf/bTS7/fmBt8LX51zKc5jvlsxK2BDwODSCbiBysFFYCTtErI+kTMJZXCx
         v14e5W+U4aSX1zTjgXbpgMV3f/bOa2WuK8EdNmuh4YVLegr1ERSEd7Q1oDc1s+TWInfQ
         PpMUYCIlsT1xCxFE+7D3mRo5gXdtxbMG2C+49a5qvaPuKXNqaFNFJlXLnX7+tlLRhG/5
         2GFQjCkDm3UF/WGRdsC52WHEipRS2UBlWudlCMxdFEr/wfAoglkmveVRWpz4GHhnPcHC
         93pg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAUKNJRfVWeoXMv0DBXmVnHyuAluM6VTkBf7ij1DZwnsEyfiXh50
	S10Q4rl/fhnMEOc6SqxI4GyjVhY+S1hVyCg8qbU9WKkWMCb2VcUPdjHxUn0v9hnH8jFrJ7wDUJG
	N9RqtvVBW9yklhBNtpz8L9T7FFsKMjex6S5as6hyVwdvpw1NTA6tfr5344yqTYZHdlg==
X-Received: by 2002:a65:6256:: with SMTP id q22mr30262316pgv.408.1563244914445;
        Mon, 15 Jul 2019 19:41:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwfIJlMcdrMCrNc53c4FnJmjSgx6ByHlFf76or5epKOhHLaXYVn3OCpwGOcJ+fkC6Bpiyok
X-Received: by 2002:a65:6256:: with SMTP id q22mr30262217pgv.408.1563244913265;
        Mon, 15 Jul 2019 19:41:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563244913; cv=none;
        d=google.com; s=arc-20160816;
        b=cZbR9QzjkiVSp0W9v2GhtLyZoVUPdK8t6CpwrjeUmdpqeM+fuSTMqG8H9QTrDOGSLN
         QqhLRO6DPWPOyusyc8v8cGAmNd/FrA0pPO8tZDrjjUIdW3HfEO3FMvCM1xQ4XtUe4SGe
         ovFq/dT1/DjxMj5KQt6tB5HyETWq//5st1RT51o/AEzuYl6IXT7qke377NOEIxxQE6va
         ztwOWumtiFj74eboE6Cdi7uiyWNP91GyuPua9wwp9X3M1QsSake4lhcXNxyiMAYOlrNq
         hAAWcK+TYQAyV8cibYrSoX0iOcgNnOVKEV53fYfGxtHAplZg0+PueQOl9WLDQDYa/6cZ
         9opQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=ji+RxCiqfOwJBxPZnDmtI1jJJX/5nQve591xbmY/5l0=;
        b=g/RAMhpph/JiVfLqY2GIoMOUq8Ih9cyLqc1OeVK4iAUVogQqclIKjEkczPxPguM1FM
         QNq1gJY17ia8OM3T7Zr+6Bp1UYDe62HBEJQSkFPXXFd6YddNzktPTEG3M0nDGmTzIC+u
         eXwS+uUrgVJ86XAeSiGgLv9L0h6H7pUp3NG0ikTPQMjjgKviKHvEE2Z8UWUHFE9fEGkz
         BzJjzAD/ZDenL5rhOdYZl0sqXys++a6+bg55PV+c8VtVuGqaeYyeT1tUOBi195TGQYbE
         bV6vPu8WzXU8m36rxtkEJkSvcWI9sd9MGl6Kugs27A9v+bttFXdfE5xADIYOM4f6gHBw
         w4Zg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id go9si16998034plb.268.2019.07.15.19.41.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 15 Jul 2019 19:41:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of yun.wang@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yun.wang@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yun.wang@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R881e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04420;MF=yun.wang@linux.alibaba.com;NM=1;PH=DS;RN=14;SR=0;TI=SMTPD_---0TX1EVd9_1563244897;
Received: from testdeMacBook-Pro.local(mailfrom:yun.wang@linux.alibaba.com fp:SMTPD_---0TX1EVd9_1563244897)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 16 Jul 2019 10:41:37 +0800
Subject: Re: [PATCH 1/4] numa: introduce per-cgroup numa balancing locality,
 statistic
To: =?UTF-8?Q?Michal_Koutn=c3=bd?= <mkoutny@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>, keescook@chromium.org,
 hannes@cmpxchg.org, vdavydov.dev@gmail.com, mcgrof@kernel.org,
 mhocko@kernel.org, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>,
 riel@surriel.com, Mel Gorman <mgorman@suse.de>, cgroups@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
References: <209d247e-c1b2-3235-2722-dd7c1f896483@linux.alibaba.com>
 <60b59306-5e36-e587-9145-e90657daec41@linux.alibaba.com>
 <3ac9b43a-cc80-01be-0079-df008a71ce4b@linux.alibaba.com>
 <20190711134754.GD3402@hirez.programming.kicks-ass.net>
 <b027f9cc-edd2-840c-3829-176a1e298446@linux.alibaba.com>
 <20190712075815.GN3402@hirez.programming.kicks-ass.net>
 <37474414-1a54-8e3a-60df-eb7e5e1cc1ed@linux.alibaba.com>
 <20190712094214.GR3402@hirez.programming.kicks-ass.net>
 <f8020f92-045e-d515-360b-faf9a149ab80@linux.alibaba.com>
 <20190715121025.GN9035@blackbody.suse.cz>
From: =?UTF-8?B?546L6LSH?= <yun.wang@linux.alibaba.com>
Message-ID: <ecd21563-539c-06b1-92f2-26a111163174@linux.alibaba.com>
Date: Tue, 16 Jul 2019 10:41:36 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.13; rv:60.0)
 Gecko/20100101 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190715121025.GN9035@blackbody.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Michal,

Thx for the comments :-)

On 2019/7/15 下午8:10, Michal Koutný wrote:
> Hello Yun.
> 
> On Fri, Jul 12, 2019 at 06:10:24PM +0800, 王贇  <yun.wang@linux.alibaba.com> wrote:
>> Forgive me but I have no idea on how to combined this
>> with memory cgroup's locality hierarchical update...
>> parent memory cgroup do not have influence on mems_allowed
>> to it's children, correct?
> I'd recommend to look at the v2 of the cpuset controller that implements
> the hierarchical behavior among configured memory node sets.

Actually whatever the memory node sets or cpu allow sets is, it will
take effect on task's behavior regarding memory location and cpu
location, while the locality only care about the results rather than
the sets.

For example if we bind tasks to cpus of node 0 and memory allow only
the node 1, by cgroup controller or madvise, then they will running
on node 0 with all the memory on node 1, on each PF for numa balancing,
the task will access page on node 1 from node 0 remotely, so the
locality will always be 0.

> 
> (My comment would better fit to 
>     [PATCH 3/4] numa: introduce numa group per task group
> IIUC, you could use cpuset controller to constraint memory nodes.)
> 
> For the second part (accessing numa statistics, i.e. this patch), I
> wonder wheter this information wouldn't be better presented under the
> cpuset controller too.

Yeah, we realized the cpu cgroup could be a better place to hold these
new statistics, both locality and exectime are task's running behavior,
related to memory location but not the memory behavior, will apply in
next version.

Regards,
Michael Wang

> 
> HTH,
> Michal
> 

