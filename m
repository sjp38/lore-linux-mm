Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7510C742BA
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 12:51:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5E16F20665
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 12:51:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="NX3566Q5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5E16F20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 03B7A8E0148; Fri, 12 Jul 2019 08:51:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F07548E00DB; Fri, 12 Jul 2019 08:51:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D82518E0148; Fri, 12 Jul 2019 08:51:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id B643F8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 08:51:37 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id h4so10544770iol.5
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 05:51:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=8vLEs/JBMWlFWXGIz+UNcNz5pVXTEU4KP1e0LBWVMWA=;
        b=GVitJ1yzrmgvGrKUWFKydcmvLtqTnUjDZflKfNmGlpaFUizVy4VnXTdHNJI1agzF42
         8L4H3FRBV7usv/7KMBBETgjoH3EyLcrWvGSHOZRXkCL4xyDFi2c4SvN/6U+CnpUB7I4B
         9YguBz+lE0eIzcSXz4osVYYOe62F/JgGjJDUakUYOLzIwnF6MMD7C83Yl8xdGyeKAqu7
         Bhzl9HHD40n3M9FYqe3bvQTdUxuLKgKilPG1QU7RTsAlT2mIQXPYNYARXzEI1FJeyXXT
         qWDVgb7MByE2EGe5EXUy789z/ewUJOyo3+nwB5Osu3lR7nKlNXHkBIwB+vm2AvNmT57L
         26cA==
X-Gm-Message-State: APjAAAXV1G1bsklfu0+RFdVeT1DKmSQkjvU7gGXEb1as/T1jTvRUeYj2
	wMO+Nhjz+9lvsel5xlUSkWgDJqVAvLYiNNs6hq4AXe+eAIVuyHdiO6sMMOe+8Mrq6fRsMt4Z3cN
	PItKCllku7jLYpx+JPRGCPjztqQfQXF75UC/KPhG2GaZncX7JYgSbo8/OtDRig9v00Q==
X-Received: by 2002:a6b:d81a:: with SMTP id y26mr9984369iob.126.1562935897469;
        Fri, 12 Jul 2019 05:51:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyo/33rzjOCHuFS2yOX+UpEkZ1olWtFKgpM7HW5YK9cTS5h1+hMtJ6AAekiyr5FTPqTLHJE
X-Received: by 2002:a6b:d81a:: with SMTP id y26mr9984322iob.126.1562935896865;
        Fri, 12 Jul 2019 05:51:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562935896; cv=none;
        d=google.com; s=arc-20160816;
        b=Vxj4gy81Jd99ZNsMHM6qfVDho/8xQN0NcgW3gkgMT+wDvY+f2bnTjyYEFLd/zn1PHK
         1D7unJUesRLorCZmKRl/JhPM32mOxIKneC4ViYIVjKOlMyCCAcUXcPw0cwuWrz+Q5+D4
         kCGXbRCPR5SLVqoGro7lkoqD8powpNk3k+Jz7329k0Oziu5KysgM7GkqwkbvVrJrt4C0
         bx8p0OlZs9h16vgwcSn5z59tJOq0BBuoGVGC0rs7cm55FrImooCy+R3UhCEevqU02/j6
         HnNNlRh7YefKoJc4P+7M0UpeWbB6i5tZ3ZL8CSmj/zVOcM5AHW0LVeUn+Ug2BQTIID2b
         cNVg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=8vLEs/JBMWlFWXGIz+UNcNz5pVXTEU4KP1e0LBWVMWA=;
        b=gQgZhdXTXE4qbRoNRVjsOq2UQJ3xhm1QjdOPCktnCoUqHiyaXzGrUUkWFhuFWcx/Eo
         qHp9TJeY3F19pzyu4lSdRmFq7jiGyBfjH8AsmMdOmwKDVAlmbBp2TZegjLfm1HHbOnlA
         ITGriCOr+vvaGvnUTuZhXJS/vfhKqJf/gCbfE8gO2yA2wxqF7yFPsN3GWIzZ0qXkMEuf
         nEGLatlv5/DvZzq+gRXB69/z4/iL6y26MKN/a3zxwRZMpK1OwuyADBwoyZyeYb6FZNFo
         +wBMsQ7pkhxRsRyuPatbse2BBqxufKCn2Ia6nEY7b0bjwkDLs2qoYUfZuj4AVRY81spv
         uJVQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=NX3566Q5;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id g20si14229669jac.56.2019.07.12.05.51.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 05:51:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=NX3566Q5;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6CCnDU5044556;
	Fri, 12 Jul 2019 12:51:25 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=8vLEs/JBMWlFWXGIz+UNcNz5pVXTEU4KP1e0LBWVMWA=;
 b=NX3566Q5oHi6CcoRFVXeDCUAd2SUixaEFsGt/kWj+xlLRBG3Q0bb+0+ZcHXax9tbOrma
 jOavemz+RkRm9sLFEAI2a1//NAu+YVa9CqE9l4XddjHl4H+J2Iza83IToF7sZlPa5Jl1
 R5SmSPrUfve8+ZaabvSmPvKDvrGmKLnixX7lh0PGQqqrcZpGPBpouxXXYzBhAP3PsGZ9
 w0bsi8u3/mNn9/eHzLLYkLYgVSdw2Ina+tuTbPSQuew6n0ClflQVEIXepzBnHXtJjz1y
 2qSJiTotkYAYun7ywTdz/2kTzUMnJAwmiWu1PYLPMJSQcv+5VEpzK0QyM/Ec5kxuqsrz WQ== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2120.oracle.com with ESMTP id 2tjm9r5e0f-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 12 Jul 2019 12:51:25 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6CClhL5192025;
	Fri, 12 Jul 2019 12:51:24 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3020.oracle.com with ESMTP id 2tpefd2wwt-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 12 Jul 2019 12:51:24 +0000
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x6CCpLW1010069;
	Fri, 12 Jul 2019 12:51:21 GMT
Received: from [10.166.106.34] (/10.166.106.34)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 12 Jul 2019 05:47:27 -0700
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
To: Peter Zijlstra <peterz@infradead.org>
Cc: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, kvm@vger.kernel.org,
        x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        konrad.wilk@oracle.com, jan.setjeeilers@oracle.com,
        liran.alon@oracle.com, jwadams@google.com, graf@amazon.de,
        rppt@linux.vnet.ibm.com, Paul Turner <pjt@google.com>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
 <20190712114458.GU3402@hirez.programming.kicks-ass.net>
 <1f97f1d9-d209-f2ab-406d-fac765006f91@oracle.com>
 <20190712123653.GO3419@hirez.programming.kicks-ass.net>
From: Alexandre Chartre <alexandre.chartre@oracle.com>
Organization: Oracle Corporation
Message-ID: <b1b7f85f-dac3-80a3-c05c-160f58716ce8@oracle.com>
Date: Fri, 12 Jul 2019 14:47:23 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190712123653.GO3419@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9315 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1907120139
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9315 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907120140
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/12/19 2:36 PM, Peter Zijlstra wrote:
> On Fri, Jul 12, 2019 at 02:17:20PM +0200, Alexandre Chartre wrote:
>> On 7/12/19 1:44 PM, Peter Zijlstra wrote:
> 
>>> AFAIK3 this wants/needs to be combined with core-scheduling to be
>>> useful, but not a single mention of that is anywhere.
>>
>> No. This is actually an alternative to core-scheduling. Eventually, ASI
>> will kick all sibling hyperthreads when exiting isolation and it needs to
>> run with the full kernel page-table (note that's currently not in these
>> patches).
>>
>> So ASI can be seen as an optimization to disabling hyperthreading: instead
>> of just disabling hyperthreading you run with ASI, and when ASI can't preserve
>> isolation you will basically run with a single thread.
> 
> You can't do that without much of the scheduler changes present in the
> core-scheduling patches.
> 

We hope we can do that without the whole core-scheduling mechanism. The idea
is to send an IPI to all sibling hyperthreads. This IPI will interrupt these
sibling hyperthreads and have them wait for a condition that will allow them
to resume execution (for example when re-entering isolation). We are
investigating this in parallel to ASI.

alex.

