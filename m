Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17AE5C10F0E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 04:16:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A09682083D
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 04:16:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A09682083D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E45616B0005; Thu, 18 Apr 2019 00:16:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF4EF6B0006; Thu, 18 Apr 2019 00:16:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CBBCE6B0007; Thu, 18 Apr 2019 00:16:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9ECFB6B0005
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 00:16:03 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id i23so629742pfa.0
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 21:16:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc:from
         :subject:message-id:date:user-agent:mime-version
         :content-transfer-encoding:content-language;
        bh=9SY1qAzxKpMF8iHv+8044Dyqs0gHQqkId888EM+sgPI=;
        b=E2/6UQpdwn4yGi4sXvTTLi1OWQwip9Ka9xF5q1exuQFWQISCzC69NQUxmQD/lQYDl9
         QgxWHDH/v5sx2BGWsVVsi6xzM+eEszjWPcBU4d/ydHHLrvjTSw/7VGe9KJQU3Fsb920+
         K/uaP4tz4Krp9xJmZp7a+NZK25wMesxb5WQ0t/Cl9xLX8vHFC2hBNMatO+t1MzcqwcFc
         u2a4kuMRnTc8HcnDwxjp5s0xJ1qwuFPQhQtt7Eq4oLuP5p2ljWEWP9K2qzTdv+YmD031
         ahXrspYG8LtB+fwvMZjF5EnTfphGVVONEGBEevpkTMV3wqmr6TntJI/ZqX926j1D8SqT
         HUrw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAX4fUWS0DBAmFwyxU8ZI9Q5Z506MgHHBfMcgSTFwW1EdqAiRibK
	ZeTGMzUydRiXZwQhcSAHIeTKS6rq4Ph26B+xvnas/BVCSZcaDXRazZ2oa9GRYMJmnbLp6BN2iIP
	OMbFH38PY+QtIIjgB6Mkp7QBmLnawMikrk5UHpHX8uHq6G3Bj8Q7QgrxYPXNestwrDQ==
X-Received: by 2002:a17:902:bf08:: with SMTP id bi8mr3858116plb.336.1555560963274;
        Wed, 17 Apr 2019 21:16:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw28YKVst1XJE99xXt9vTYT7lKu+yXDBnJz0tbxFuN7UjENAGYSwQFt7MkZUo671yg50Xqb
X-Received: by 2002:a17:902:bf08:: with SMTP id bi8mr3858052plb.336.1555560962410;
        Wed, 17 Apr 2019 21:16:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555560962; cv=none;
        d=google.com; s=arc-20160816;
        b=HGYoO3E/iFAnQIfluoBrzQp4/48NebTEJQqrWl3Nkr6aK29Kky0d0ONXlAbRnkSMNQ
         kpYqmkAK57iFFdW+gpiBqLLIZdhVALtEP+swl58mG1Boj4CKq1i3pD7yM0sJXZOHjo6D
         GZ8C8LnPNRAceOHds6VfqvZy83aC9O3yetUnBev3gd/qPgrcGVcRrMK42a5RWmpKQ8zY
         akFZoiFieTZzovu5SqKkP0BhWPxgO6i1SdGp3OTahCvx+lshHXyGwCAxnyVAKCnjXvz6
         oX3bD5NydaDMnLoluQmPdSHgavRwhOEz595oO8HQKIEI5W5NxMnCOgiJU0jiLdCOweFi
         2oVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:mime-version:user-agent
         :date:message-id:subject:from:cc:to;
        bh=9SY1qAzxKpMF8iHv+8044Dyqs0gHQqkId888EM+sgPI=;
        b=cMMTtOvcL0NfZJeIcpqYtVV5vkMXtCATjozOlUOPjbYqvZPyRDxdKrLx3WEdyq7cJp
         kWtqxRw+UEG3jAguaU6SIo/udJbHCB9iZRVs1PlQoBOHo2a63Wu9Fg6wVV85ZrSBnUSB
         kW2mxSYoM1s7+EuHuQLTwjCBXoDXh51npdXqvjr+BacRLlj0IAQtSMMdZiZhqRVnoxW/
         JL+GRcQJXDrUEB+geQo1JbjAUUGISIljhSVqxe2YZ0ASh8yDcpqMlDlWP3MYxyUPk1ps
         nmkpZK27CvAGHHB3GslE+9IUwUrga8vQXSJRSw2Q6uJyYA9kQZYEJk2gh3q7DAjbsS7X
         0fxg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-44.freemail.mail.aliyun.com (out30-44.freemail.mail.aliyun.com. [115.124.30.44])
        by mx.google.com with ESMTPS id e36si892554pgm.89.2019.04.17.21.16.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 21:16:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) client-ip=115.124.30.44;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.44 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R711e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04394;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TPc2a8C_1555560943;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TPc2a8C_1555560943)
          by smtp.aliyun-inc.com(127.0.0.1);
          Thu, 18 Apr 2019 12:15:58 +0800
To: Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>,
 Andrea Arcangeli <aarcange@redhat.com>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: YangShi <yang.shi@linux.alibaba.com>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 linux-kernel <linux-kernel@vger.kernel.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [QUESTIONS] THP allocation in NUMA fault migration path
Message-ID: <aa34f38e-5e55-bdb2-133c-016b91245533@linux.alibaba.com>
Date: Wed, 17 Apr 2019 21:15:41 -0700
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


I noticed that there might be new THP allocation in NUMA fault migration 
path (migrate_misplaced_transhuge_page()) even when THP is disabled (set 
to "never"). When THP is set to "never", there should be not any new THP 
allocation, but the migration path is kind of special. So I'm not quite 
sure if this is the expected behavior or not?


And, it looks this allocation disregards defrag setting too, is this 
expected behavior too?


Thanks,

Yang

