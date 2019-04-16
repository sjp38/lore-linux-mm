Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3CF96C10F13
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 14:31:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC08920821
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 14:31:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC08920821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8645C6B02A6; Tue, 16 Apr 2019 10:31:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 812916B02A8; Tue, 16 Apr 2019 10:31:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 702716B02A9; Tue, 16 Apr 2019 10:31:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4A9026B02A6
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 10:31:46 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id x9so15709854ybj.7
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 07:31:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=u9A+Ec0h8JaWP7cKtSbHVFDbY3vwvh4jzXpWikOupHg=;
        b=o4fD9pgCsDfgACExHK37J4OdiY8ZePS/PPu+XsS6M4q/0qHm6LcV0cOmXgQg4x736f
         /QZuJIU4ipKKvIf6Z3yAasC3EzoHjiDd16I7XeXZbinTh7j5ROZEie6c6E8Mo7Iej/DG
         6C/XZ86uy9d9LsbxBBIeGtNfLbhwa5D3uzNVOYPYBl1I9hr/FkaycTi9+xENm+ZNmsFN
         IvdWBDWX1WGqi9daR05ve6zGImoYF980gmQFnkJPAOb881Qmk3wucdJrt8zXgrkj/lvd
         rWVBw9nKH9uhFOi0unBzu+4piNCLVn/ngou1qKsJTTOsjYQoE07NkcNcRwdruxysLj1b
         fyWQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAXOxdN7/TzrzxSkmH1LA8gtZ3+EQF7rpMPzmlvCxsGNyuIaJSp0
	lhFCr98SxLJEP1KjIq8DD3TwlyfrAMC5huQ1TgDZ8aaZUDvz8yJVubD+FnLuZHAAfQTwd3NxeF4
	cmJE/HZOU5eZRO+9KfRineWtVmopBb+NKflVgbsoHYo67TrGUjkKaBZA4eCOdCMSK1Q==
X-Received: by 2002:a0d:d58d:: with SMTP id x135mr66193079ywd.396.1555425106038;
        Tue, 16 Apr 2019 07:31:46 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw16uTBwBf9KlODrGGdUMDKNt3rykKjDkN4paAQjYUZgtkFktrSw5tkvslUJUV+LLywD1cK
X-Received: by 2002:a0d:d58d:: with SMTP id x135mr66193019ywd.396.1555425105273;
        Tue, 16 Apr 2019 07:31:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555425105; cv=none;
        d=google.com; s=arc-20160816;
        b=OlRwtNW/103XqVeVEXBXW0dszTUC+vK0U9p8rV8vcqM8m/J91vubv7t2EBJjdwBhZ6
         B1zQ4IpYVnd6yvLOiqa6SL/wAaWC00SiogNlOVf9NKdslV/ovMTFG64hvrYB4f6puJ8g
         mMFAg/7/nDU1FMuAU4oIY0JER2OpTfwy8YPHtAUJpUXMkaup1msAvOEpZopRHlJlzlna
         PY3dSUoF5GmHZIEzDfhZsNArCJ7CGi042jhEAssvlxsas1Vtv0nB9ImDwxcu+o/0d45m
         qiZP4oRJHigJXa4xDqrAJz/8fqNIj/xhnbLfUKl5nUsK73uEwHVNVaW3roEtjVYBnReB
         gZdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=u9A+Ec0h8JaWP7cKtSbHVFDbY3vwvh4jzXpWikOupHg=;
        b=LROy9dWqbJu6RngwSDWYnNkRGrJDk4dTJ5fVgHOtHn384MVIjfeuYEwJXVQQfEMGzN
         XuD29iAvt+4goD7fz7EMxq5jLts/NxHGwFuSylWfx96u07oesH4ozLJPEWywDQFmIN0z
         FccQsFTB4bTsA9G02vbthj2XpMDN8s1kgKOcuyUmkfCSFoR77/fHydum5LvMo5wEPDY2
         f1rafCEdUve3JMks8XprFXVbMk8OSlc+fkn/ydMeG9x/OzgOBzXqEjHarQvnGi8gVuMC
         H1Y10398cMPnbJ6bMwWLxa707RI1YzO2xealnJpgXXjESItWN20V/ZcvsYUtiWYKM7Sy
         JtMw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id y184si36285359yba.312.2019.04.16.07.31.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 07:31:45 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3GEQpWn129714
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 10:31:45 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2rwfbaw45t-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 10:31:44 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 16 Apr 2019 15:31:41 +0100
Received: from b06cxnps3075.portsmouth.uk.ibm.com (9.149.109.195)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 16 Apr 2019 15:31:32 +0100
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (b06wcsmtp001.portsmouth.uk.ibm.com [9.149.105.160])
	by b06cxnps3075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3GEVU7X61407244
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 16 Apr 2019 14:31:30 GMT
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 72875A4062;
	Tue, 16 Apr 2019 14:31:30 +0000 (GMT)
Received: from b06wcsmtp001.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id CF977A405B;
	Tue, 16 Apr 2019 14:31:27 +0000 (GMT)
Received: from nimbus.lab.toulouse-stg.fr.ibm.com (unknown [9.101.4.33])
	by b06wcsmtp001.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 16 Apr 2019 14:31:27 +0000 (GMT)
Subject: Re: [PATCH v12 04/31] arm64/mm: define
 ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
To: Mark Rutland <mark.rutland@arm.com>
Cc: akpm@linux-foundation.org, mhocko@kernel.org, peterz@infradead.org,
        kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net,
        jack@suse.cz, Matthew Wilcox <willy@infradead.org>,
        aneesh.kumar@linux.ibm.com, benh@kernel.crashing.org,
        mpe@ellerman.id.au, paulus@samba.org,
        Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
        hpa@zytor.com, Will Deacon <will.deacon@arm.com>,
        Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
        sergey.senozhatsky.work@gmail.com,
        Andrea Arcangeli <aarcange@redhat.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com,
        Daniel Jordan <daniel.m.jordan@oracle.com>,
        David Rientjes <rientjes@google.com>,
        Jerome Glisse <jglisse@redhat.com>,
        Ganesh Mahendran <opensource.ganesh@gmail.com>,
        Minchan Kim <minchan@kernel.org>,
        Punit Agrawal <punitagrawal@gmail.com>,
        vinayak menon <vinayakm.list@gmail.com>,
        Yang Shi <yang.shi@linux.alibaba.com>,
        zhong jiang <zhongjiang@huawei.com>,
        Haiyan Song <haiyanx.song@intel.com>,
        Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
        Michel Lespinasse <walken@google.com>,
        Mike Rapoport <rppt@linux.ibm.com>, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com,
        paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>,
        linuxppc-dev@lists.ozlabs.org, x86@kernel.org
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190416134522.17540-5-ldufour@linux.ibm.com>
 <20190416142710.GA54515@lakrids.cambridge.arm.com>
From: Laurent Dufour <ldufour@linux.ibm.com>
Date: Tue, 16 Apr 2019 16:31:27 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190416142710.GA54515@lakrids.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041614-0008-0000-0000-000002DA7437
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041614-0009-0000-0000-00002246AD08
Message-Id: <4ef9ff4b-2230-0644-2254-c1de22d41e6c@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-16_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904160097
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Le 16/04/2019 à 16:27, Mark Rutland a écrit :
> On Tue, Apr 16, 2019 at 03:44:55PM +0200, Laurent Dufour wrote:
>> From: Mahendran Ganesh <opensource.ganesh@gmail.com>
>>
>> Set ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT for arm64. This
>> enables Speculative Page Fault handler.
>>
>> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
> 
> This is missing your S-o-B.

You're right, I missed that...

> 
> The first patch noted that the ARCH_SUPPORTS_* option was there because
> the arch code had to make an explicit call to try to handle the fault
> speculatively, but that isn't addeed until patch 30.
> 
> Why is this separate from that code?

Andrew was recommended this a long time ago for bisection purpose. This 
allows to build the code with CONFIG_SPECULATIVE_PAGE_FAULT before the 
code that trigger the spf handler is added to the per architecture's code.

Thanks,
Laurent.

> Thanks,
> Mark.
> 
>> ---
>>   arch/arm64/Kconfig | 1 +
>>   1 file changed, 1 insertion(+)
>>
>> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
>> index 870ef86a64ed..8e86934d598b 100644
>> --- a/arch/arm64/Kconfig
>> +++ b/arch/arm64/Kconfig
>> @@ -174,6 +174,7 @@ config ARM64
>>   	select SWIOTLB
>>   	select SYSCTL_EXCEPTION_TRACE
>>   	select THREAD_INFO_IN_TASK
>> +	select ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
>>   	help
>>   	  ARM 64-bit (AArch64) Linux support.
>>   
>> -- 
>> 2.21.0
>>
> 

