Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46995C48BE2
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 08:11:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DB2632084B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 08:11:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DB2632084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D8CE6B0003; Thu, 20 Jun 2019 04:11:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 387E68E0002; Thu, 20 Jun 2019 04:11:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 276A38E0001; Thu, 20 Jun 2019 04:11:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id E43B16B0003
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 04:11:05 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id a5so1161149pla.3
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 01:11:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=YIYHgumkuE25m4LoOWtpQlHtO7S3xtW2cF3gchqq/WE=;
        b=GSrcZIooN2E9L3XIAiOpit8hEOHpaYDyjRpxsyYZSU5yejhNgyb9vyX6G3jb8ouyhT
         awiY/4NEOzpAQIhQWRGh9mZM1bGX6RpoSI9yWZlPth+knXOEOaJ4MENFkaNhwLp0XoxE
         LKyNijDk2ewnpRmQN6LlmVMvOA5pHhl5R18E59riOfcqOjZpCZL/BmZgxgcHzku8/vpa
         r90F28wxJGIDEUN1zpleUxNP8qGNSGkaFA24G04VN/m7roNgkvYY1UZl+/DE9KO351bm
         ZvW2mhh8XLK0bgEsbBWbINFmZHWUHZVgGZRALXUL6l7scOpToxfTuF6ww0hkPOE44hRa
         iMZw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of haiyanx.song@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=haiyanx.song@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVByfnevVGOY/X1O/V3fyMLdy96Ejlc7vOjN7qSV/QfeSemwMhJ
	lBbdITtWU9ihBzEvMWbVaXwX4i15dvL5qh6WZEuSoGolm9BgUoIQAK567+AYSJIThbL6opxa8vN
	xHqmhY7lMyHoJ628R3zKZSP5jRH7tjx5yChnf4O3WfV4tROfTnE9Xs50nIwAZ5h3hXA==
X-Received: by 2002:a17:90a:1a0d:: with SMTP id 13mr1685203pjk.99.1561018265577;
        Thu, 20 Jun 2019 01:11:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw62lo1FKhcoYvCWAk0RyP1pYvn8hGh4rQnQYcB3GnRlT4TX3m3NAf8VPZKt0YNMZD2rJmF
X-Received: by 2002:a17:90a:1a0d:: with SMTP id 13mr1685158pjk.99.1561018264727;
        Thu, 20 Jun 2019 01:11:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561018264; cv=none;
        d=google.com; s=arc-20160816;
        b=kKFcqcj7BHr3JclY/ywjb9AlMUQWMrJmwHCaXychKPtta87CdEyC8bNc9LEbpFvQR5
         ytD3IcLAjNDZgopJkiWrjZR+iVLThvWqyLEhzGbU7Th/tiClV4mLzYyzPTR7ietCXGcs
         3qEYQUFlRWrkq2XN4EAXGopdzE8U88RqBhcQcv8i4HVw6zcmq5sXOulZK3BM8/YMbGtg
         YjI+1HQ0zl1Si2ZaUroFdS/SG+MpWQXhfgHDoQmXw4ou10c11ZomUqjBC2bw6z12hxpP
         iyXVv+UBAVSDTgiF3jkafmS9mTUv0Ko8XrHF0M89Yy1npIvDLX8AMUvs3KDDqjCcIG+S
         NHkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=YIYHgumkuE25m4LoOWtpQlHtO7S3xtW2cF3gchqq/WE=;
        b=AZrv1eGY7pavrDE5fatVGvLqDmuRumEF70jKDIcMy1aGYwCSoKrDs8WPfEvizUwYAY
         9utdJBJSmBwzyvSLlkFk7XWA+N06CjtiSNkyjI/+4tj9fNzuioYLHEch0N2qA4eCFjuM
         dVceKETU4mgOZUPOSHHdOAzs9rbgltJck4bSx1hLO8RPKbS+m519J0lIL1jTwmSK/Bnl
         48ONVylaQ2aV/pMW1KXTXVR3cCKWz4xP8NfVzgqkxlZ030kjYBxVBRH2rOAnAt1wRL0M
         ZkEcxqGmJdb5eIeVc2ex4f8v1VtP1Qhadzu2hepXcqb6ERV+W3Kmk0zXiH8athhEFFVK
         34JA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of haiyanx.song@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=haiyanx.song@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id f7si5089234pgv.105.2019.06.20.01.11.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 01:11:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of haiyanx.song@intel.com designates 192.55.52.120 as permitted sender) client-ip=192.55.52.120;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of haiyanx.song@intel.com designates 192.55.52.120 as permitted sender) smtp.mailfrom=haiyanx.song@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: UNKNOWN
X-Amp-Original-Verdict: FILE UNKNOWN
X-Amp-File-Uploaded: False
Received: from orsmga007.jf.intel.com ([10.7.209.58])
  by fmsmga104.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 20 Jun 2019 01:11:03 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,396,1557212400"; 
   d="out'?scan'208";a="150857738"
Received: from haiyan.sh.intel.com ([10.239.48.70])
  by orsmga007.jf.intel.com with ESMTP; 20 Jun 2019 01:10:56 -0700
Date: Thu, 20 Jun 2019 16:19:45 +0800
From: Haiyan Song <haiyanx.song@intel.com>
To: Laurent Dufour <ldufour@linux.ibm.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org,
	kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net,
	jack@suse.cz, Matthew Wilcox <willy@infradead.org>,
	aneesh.kumar@linux.ibm.com, benh@kernel.crashing.org,
	mpe@ellerman.id.au, paulus@samba.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, hpa@zytor.com,
	Will Deacon <will.deacon@arm.com>,
	Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	sergey.senozhatsky.work@gmail.com,
	Andrea Arcangeli <aarcange@redhat.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	kemi.wang@intel.com, Daniel Jordan <daniel.m.jordan@oracle.com>,
	David Rientjes <rientjes@google.com>,
	Jerome Glisse <jglisse@redhat.com>,
	Ganesh Mahendran <opensource.ganesh@gmail.com>,
	Minchan Kim <minchan@kernel.org>,
	Punit Agrawal <punitagrawal@gmail.com>,
	vinayak menon <vinayakm.list@gmail.com>,
	Yang Shi <yang.shi@linux.alibaba.com>,
	zhong jiang <zhongjiang@huawei.com>,
	Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
	Michel Lespinasse <walken@google.com>,
	Mike Rapoport <rppt@linux.ibm.com>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com,
	paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>,
	linuxppc-dev@lists.ozlabs.org, x86@kernel.org
Subject: Re: [PATCH v12 00/31] Speculative page faults
Message-ID: <20190620081945.hwj6ruqddefnxg6z@haiyan.sh.intel.com>
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190606065129.d5s3534p23twksgp@haiyan.sh.intel.com>
 <3d3cefa2-0ebb-e86d-b060-7ba67c48a59f@linux.ibm.com>
 <1c412ebe-c213-ee67-d261-c70ddcd34b79@linux.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="ghgds33dkojdyykr"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1c412ebe-c213-ee67-d261-c70ddcd34b79@linux.ibm.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--ghgds33dkojdyykr
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

Hi Laurent,

I downloaded your script and run it on Intel 2s skylake platform with spf-v12 patch
serials.

Here attached the output results of this script.

The following comparison result is statistics from the script outputs.

a). Enable THP
                                            SPF_0          change       SPF_1
will-it-scale.page_fault2.per_thread_ops    2664190.8      -11.7%       2353637.6      
will-it-scale.page_fault3.per_thread_ops    4480027.2      -14.7%       3819331.9     


b). Disable THP
                                            SPF_0           change      SPF_1
will-it-scale.page_fault2.per_thread_ops    2653260.7       -10%        2385165.8
will-it-scale.page_fault3.per_thread_ops    4436330.1       -12.4%      3886734.2 


Thanks,
Haiyan Song


On Fri, Jun 14, 2019 at 10:44:47AM +0200, Laurent Dufour wrote:
> Le 14/06/2019 à 10:37, Laurent Dufour a écrit :
> > Please find attached the script I run to get these numbers.
> > This would be nice if you could give it a try on your victim node and share the result.
> 
> Sounds that the Intel mail fitering system doesn't like the attached shell script.
> Please find it there: https://gist.github.com/ldu4/a5cc1a93f293108ea387d43d5d5e7f44
> 
> Thanks,
> Laurent.
> 

--ghgds33dkojdyykr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="page_fault2_threads.5.1.0-rc4-mm1-00300-g02c5a1f.out"

#### THP always
#### SPF 0
average:2628818
average:2732209
average:2728392
average:2550695
average:2689873
average:2691963
average:2627612
average:2558295
average:2707877
average:2726174
#### SPF 1
average:2426260
average:2145674
average:2117769
average:2292502
average:2350403
average:2483327
average:2467324
average:2335393
average:2437859
average:2479865
#### THP never
#### SPF 0
average:2712575
average:2711447
average:2672362
average:2701981
average:2668073
average:2579296
average:2662048
average:2637422
average:2579143
average:2608260
#### SPF 1
average:2348782
average:2203349
average:2312960
average:2402995
average:2318914
average:2543129
average:2390337
average:2490178
average:2416798
average:2424216

--ghgds33dkojdyykr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="page_fault3_threads.5.1.0-rc4-mm1-00300-g02c5a1f.out"

#### THP always
#### SPF 0
average:4370143
average:4245754
average:4678884
average:4665759
average:4665809
average:4639132
average:4210755
average:4330552
average:4290469
average:4703015
#### SPF 1
average:3810608
average:3918890
average:3758003
average:3965024
average:3578151
average:3822748
average:3687293
average:3998701
average:3915771
average:3738130
#### THP never
#### SPF 0
average:4505598
average:4672023
average:4701787
average:4355885
average:4338397
average:4446350
average:4360811
average:4653767
average:4016352
average:4312331
#### SPF 1
average:3685383
average:4029413
average:4051615
average:3747588
average:4058557
average:4042340
average:3971295
average:3752943
average:3750626
average:3777582

--ghgds33dkojdyykr--

