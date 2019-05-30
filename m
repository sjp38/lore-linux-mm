Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 542C6C072B1
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 06:58:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 23EBB247D1
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 06:58:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 23EBB247D1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8F756B028B; Thu, 30 May 2019 02:58:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3F2F6B028E; Thu, 30 May 2019 02:58:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 92E326B028F; Thu, 30 May 2019 02:58:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 65D856B028B
	for <linux-mm@kvack.org>; Thu, 30 May 2019 02:58:03 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 77so3944552pfu.1
        for <linux-mm@kvack.org>; Wed, 29 May 2019 23:58:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc:from
         :subject:message-id:date:user-agent:mime-version
         :content-transfer-encoding:content-language;
        bh=abHXjwG+GNQ6C0couQcjq+hkyulADiyFawJBFOKmlog=;
        b=pFUdXe3aQYUYF+Uj737/cOr7kCrd4/j+kKWkLz0PbKQ/OIFpK0PUhbBydSU4LLvVUD
         x2RqkDhoWI6XpE3JLn6/WvgFL3fyPJVDSsQVmimSkGruJgy7TC6YjGb4lNbKqZmgbjEE
         lVGmdzLkD64i7xsYt84wjyJVQzWQjAuzE9kbHIkWwg+5fSE2X0LLVaHlxoZounvoehQl
         N6cu8hTyRtlM8iD+aHIY5kSFKDGF7ckv/4XtJnwspSp0ouRBN1PuzLca9k9bc+01znEa
         Auh76BtSr/XfdVaszeMuRiy6pq1ShEB7nQgN6JM8Xd8deC7H3FVIyJ5R6PquYDF9cnZ+
         VSpA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAXbuONh5Fw9+Bp+18YgweUyDPieWDqz4GeZXJhxX7h0atKbUalg
	cUr4S9oMgpDTgjNf2p6hVTxo7+PeV8OCRsyV83bHU1c44X25Bh1zsT/4DjfjVC/n917zSOWcEmm
	FoYqg35yfzev28gNVJvpmjdsoEdkW0i5oQCkH0Id/+FnBJQ+7K1gv+vn8NIoDQXhWnA==
X-Received: by 2002:a17:90a:be0b:: with SMTP id a11mr2309690pjs.88.1559199483038;
        Wed, 29 May 2019 23:58:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwh2ZCk1FY7TCNQMCKmhBaZDDrNCqRH0nAS3NHRSuXT8GpWSDxky/r8CVl0v+FTF7Xqbrfg
X-Received: by 2002:a17:90a:be0b:: with SMTP id a11mr2309646pjs.88.1559199482139;
        Wed, 29 May 2019 23:58:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559199482; cv=none;
        d=google.com; s=arc-20160816;
        b=PCiQKCMzZqmv4FeTB7+8n5YMzD0lBFOEZMrHLaDT5yPqynAvSyLeBNVy8c6vlpa5AF
         lNgKhEjeqydjhipR4k0F14SyQeidaWw9oEiEC34DokHnntk7KKRmXdPjJLgUNV5ZeJ64
         w8MEeXcxEuaeiU9m2VKlYAGKQTybhTVXeg5MulEisthjF9HkJyWrlosW4k8bnBDBCXrY
         8c+Y3i/KjHr8puQo1RyrHf6vDI3BxIyJGrRI8QfhUN4d0TGAmMN1sx+STyacVesidohT
         fWcKuCF9Het1axARbau8B16bpeygrmAGlUejf82EYg3/+2/NE8GPJ/8T17f4v93AyuaB
         f4LQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:mime-version:user-agent
         :date:message-id:subject:from:cc:to;
        bh=abHXjwG+GNQ6C0couQcjq+hkyulADiyFawJBFOKmlog=;
        b=Wxk1BzQn6IEdNnWL+WQgzvzDSvkiff3DvwNtq2ozBZ66LqeB/15649QKCU8wbM11nt
         E3ZS/D5vlOgIqib7jvO4uLH/cJYgJi7G+63zzxd9kH0knLnRB7x76MjmIOq/3BMxXOns
         RscpYoTiuFzEjdggE0XO5SZeN/oLQWLsKZqcb4ZN8aPyQGisihnkBDiBQ/+6q6ql0K43
         47kUVeaHWLVqkxdUJ9BLGh50x2Hh/b2lD4oB0ouhqDyIz1gZjBlUur7uoGr9GVTeFisH
         +M+R+cwBT3LjpKC80fCTA2qAHPtp05eg11c504bHnH7yf+Z5NM5r849w4PDy4gFgpzmx
         sTyg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id b41si2227717pla.409.2019.05.29.23.58.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 23:58:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) client-ip=47.88.44.37;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 47.88.44.37 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R141e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04395;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=5;SR=0;TI=SMTPD_---0TT.K-Od_1559199467;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TT.K-Od_1559199467)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 30 May 2019 14:57:47 +0800
To: Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
 linux-kernel <linux-kernel@vger.kernel.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [HELP] How to get task_struct from mm
Message-ID: <5cf71366-ba01-8ef0-3dbd-c9fec8a2b26f@linux.alibaba.com>
Date: Thu, 30 May 2019 14:57:46 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi folks,


As what we discussed about page demotion for PMEM at LSF/MM, the 
demotion should respect to the mempolicy and allowed mems of the process 
which the page (anonymous page only for now) belongs to.


The vma that the page is mapped to can be retrieved from rmap walk 
easily, but we need know the task_struct that the vma belongs to. It 
looks there is not such API, and container_of seems not work with 
pointer member.


Any suggestion?


Thanks,

Yang

