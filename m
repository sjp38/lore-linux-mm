Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E258C282DD
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 15:36:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B470A218B0
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 15:36:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B470A218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 512906B0005; Tue, 23 Apr 2019 11:36:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 49BE76B0007; Tue, 23 Apr 2019 11:36:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 316866B0008; Tue, 23 Apr 2019 11:36:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CE7F76B0005
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 11:36:52 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id m57so4572504edc.7
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 08:36:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=pZwX9peIRTUKgZAF9oYGb+y+EMluadNrs4xWtWNCLm8=;
        b=PwRU4SsSyG0A+ctcaRmXo64mjrqvAR0GT4K1LTD+2+AUhzl6fWsnC5eoQje3DY4mQO
         4TyVWZLn9IsypyyejSQxeA5L0ZzpYNuh+kHHW3b8L4i7jJZ9pAaf5eJoVxnNY+DPK21j
         webOKPgW4rZeeJFneWIErbPeJc2QwS9qwum1erL8TnfFRV+betuKwajFv5ty6CfjDyNx
         Ki2qzm0cG9BNKDUMIGNr5p0rW4t8KrXgHVUY0b7a1l2cBIbcNz9bY3NoVspfuldwENLU
         XsF9Qy99Wkx0vi0Z+BX37G9Y9ZmlO8TOG90Xy4rlpAPjj7lwaJAzwlNroZ7hMltXAobR
         PRNQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAX6BbSNbSVi+TOtRzK4NrCugd8RHN1jO61iHFPzoagPbL3sx/vn
	QwYpPTDmrSf6puV/nxiZZHi/jQVT4/wVCCFylgh3/QQBcFD9t3uAKzJOo4cHnUSLzyL8LC2ZIF7
	tiDq+NvwX0JQGkbq2mIwpbOxZcGLz/itg+FxnYNFvobYqZYjF2aqDlJwUPHwfh0AQ7w==
X-Received: by 2002:a50:ed0a:: with SMTP id j10mr15713052eds.188.1556033812418;
        Tue, 23 Apr 2019 08:36:52 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyd1gkmTwbMzpk+r7+p/LeunwgYTj2Qj4MJkXeA7kIOb9HVVxpNbM8G/sH9rwUbebDofD7A
X-Received: by 2002:a50:ed0a:: with SMTP id j10mr15713005eds.188.1556033811541;
        Tue, 23 Apr 2019 08:36:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556033811; cv=none;
        d=google.com; s=arc-20160816;
        b=AoaRic7Xy3L2Z+81qrc3902dR/ruv9Dnmf+jTLYpW4Un0dxLZDPI1+ny6u+0E8Qb+O
         L+sS3XZQuDx7FFG5RsQ7dg5RSnzB3fxfm2OPlEWebd0V6utz4yHltXg3PgYhsBnDUBk8
         /aR3kW/A+aLhvB/uVtEufjFFGYiFB+YgTRBHCJJ4Havr1YGGrxoQtcYqIhTN5Hvkq7Uh
         iqmtMsVvf/lEKbJuQw8QIjpCdGxzuTCSYYNXhiu93WPBrUssV5I6VrRkaEeFoIzjKo8S
         D8orb/4mRL3wwCyOb0Hzk9Di6KzEHqt2EnUaBI2oFw7X19CClkMltk43SVhWdAPL7UeC
         7//A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=pZwX9peIRTUKgZAF9oYGb+y+EMluadNrs4xWtWNCLm8=;
        b=nCNyTMgUQ/OJtY6k15q5nXsTxquGK5wqmUFoTrffeMBQRxXrroMXLj3m/xLhL4WWjJ
         yRWrFf0wvyDsPTeyy1gy/ceRuPc1A2ZehIJYAfa28JJBYKc3CZltJP9ygdITWMy0+JKA
         Ul6UWJmxnG33yBwnN1gePIfKA29v8gxrIgwoyeGkb6nDdaB3OAbUb+ptVVlWI7oGqCuR
         8muPMN8GFe74ZcavFGW3iZ9560i3i7h6uAIWhTgkEJkwPeA1mwAF7jf7446iqjOZi/da
         o4zZiPZ31NOKyXxk/i9MY53JteVvEQq+VWbs/Fh4xGLiGjxzESrwXDbVwldWIGt490Rt
         Esgg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i44si1651536ede.123.2019.04.23.08.36.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 08:36:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3NFYatp119589
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 11:36:50 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2s238yq0pk-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 11:36:49 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 23 Apr 2019 16:36:46 +0100
Received: from b06cxnps4076.portsmouth.uk.ibm.com (9.149.109.198)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 23 Apr 2019 16:36:35 +0100
Received: from d06av24.portsmouth.uk.ibm.com (mk.ibm.com [9.149.105.60])
	by b06cxnps4076.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3NFaY6g51773584
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 23 Apr 2019 15:36:34 GMT
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 310C142041;
	Tue, 23 Apr 2019 15:36:34 +0000 (GMT)
Received: from d06av24.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 96ED342042;
	Tue, 23 Apr 2019 15:36:31 +0000 (GMT)
Received: from [9.145.7.116] (unknown [9.145.7.116])
	by d06av24.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue, 23 Apr 2019 15:36:31 +0000 (GMT)
Subject: Re: [PATCH v12 04/31] arm64/mm: define
 ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT
To: Jerome Glisse <jglisse@redhat.com>, Mark Rutland <mark.rutland@arm.com>
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
 <4ef9ff4b-2230-0644-2254-c1de22d41e6c@linux.ibm.com>
 <20190416144156.GB54708@lakrids.cambridge.arm.com>
 <20190418215113.GD11645@redhat.com>
From: Laurent Dufour <ldufour@linux.ibm.com>
Date: Tue, 23 Apr 2019 17:36:31 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190418215113.GD11645@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19042315-4275-0000-0000-0000032AEC6A
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19042315-4276-0000-0000-0000383A3230
Message-Id: <73a3650d-7e9f-bc9e-6ea1-2cef36411b0c@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-23_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904230105
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Le 18/04/2019 à 23:51, Jerome Glisse a écrit :
> On Tue, Apr 16, 2019 at 03:41:56PM +0100, Mark Rutland wrote:
>> On Tue, Apr 16, 2019 at 04:31:27PM +0200, Laurent Dufour wrote:
>>> Le 16/04/2019 à 16:27, Mark Rutland a écrit :
>>>> On Tue, Apr 16, 2019 at 03:44:55PM +0200, Laurent Dufour wrote:
>>>>> From: Mahendran Ganesh <opensource.ganesh@gmail.com>
>>>>>
>>>>> Set ARCH_SUPPORTS_SPECULATIVE_PAGE_FAULT for arm64. This
>>>>> enables Speculative Page Fault handler.
>>>>>
>>>>> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
>>>>
>>>> This is missing your S-o-B.
>>>
>>> You're right, I missed that...
>>>
>>>> The first patch noted that the ARCH_SUPPORTS_* option was there because
>>>> the arch code had to make an explicit call to try to handle the fault
>>>> speculatively, but that isn't addeed until patch 30.
>>>>
>>>> Why is this separate from that code?
>>>
>>> Andrew was recommended this a long time ago for bisection purpose. This
>>> allows to build the code with CONFIG_SPECULATIVE_PAGE_FAULT before the code
>>> that trigger the spf handler is added to the per architecture's code.
>>
>> Ok. I think it would be worth noting that in the commit message, to
>> avoid anyone else asking the same question. :)
> 
> Should have read this thread before looking at x86 and ppc :)
> 
> In any case the patch is:
> 
> Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

Thanks Mark and Jérôme for reviewing this.

Regarding the change in the commit message, I'm wondering if this would 
be better to place it in the Series's letter head.

But I'm fine to put it in each architecture's commit.


