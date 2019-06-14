Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05E9AC31E44
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 08:45:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B963F2133D
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 08:45:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B963F2133D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 53FB36B0005; Fri, 14 Jun 2019 04:45:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F00E6B0006; Fri, 14 Jun 2019 04:45:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B8BE6B0007; Fri, 14 Jun 2019 04:45:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1582E6B0005
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 04:45:06 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id v67so2026957yba.11
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 01:45:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=gMcmfehS+q6BAMkgDQDcfUGchOwbG5CF6FFiOFL6VNY=;
        b=lPYcSRQPgqGDjEowLdRAQuGKFfgAou96Ong0EDEyFqhWr+N/XcfPzHEqv8wZGhiG36
         i/FxbSuhiQUIkLzfIccMsLXPI4JZLbb4SJ+gv43dEeBQy+ifzM9xaK7iIs9YMey9c6L8
         9FrvCnhpu0AKOTCkSmG1Tjs/lIcda2FRTV3XlX8DT+yzjxE3QxnYMdd8oDxVNkkmjy2d
         ZZ2p8WU2LL6T3W7YQyL8Mk3pxtaWGRYF7M3hw3WmskG1QQ9VHWXmDVcf5s//HnIRKUkt
         RNgXaBmqZnN/EC1mx+x3qE9RE2fUX0B0rAclrs2y9Zk0xXKUjRnJlq8fXBJF+Q1d3/LW
         nF1w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWF1PZr+G+pBvSQulhe1pLWaoiwuJww1zWzwouJYRbJt56XyH5u
	DQ15qnY5QLzsnBhTHFyYJD82ZzHtJ6ifot4GS8j7VKuexVdWxvniss5zAU4VuPBg07ZN28B1DhR
	8JlRIuOoGBhzTQNmdaitikMaeFcphd5Zr8I2+q+doJC7+kc0zxvfxXY69QNXK0DZJ9A==
X-Received: by 2002:a25:6085:: with SMTP id u127mr13747975ybb.491.1560501905868;
        Fri, 14 Jun 2019 01:45:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxvSti6pfX3C/hgC9VuP3ywC/0wjDfCbUbH3VoilS6PvH5VrA0JM4p98Z5xhrsxNQp4yENY
X-Received: by 2002:a25:6085:: with SMTP id u127mr13747962ybb.491.1560501905309;
        Fri, 14 Jun 2019 01:45:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560501905; cv=none;
        d=google.com; s=arc-20160816;
        b=cMfH///aKjiGX04Dfp7kAQqLNx7kiYceSkE5HDKIGKCg9jv3i8ETRoY+g0wRGad4+p
         Bi3wK5iPw+vVMeilObW8BCRHyXkfSR61GRZAalZY/EdAUkl0xLs6QXzMQ+L8aw97bFma
         /27qEQ1qVZCG7rntQqv4Z2gzPR1LXITfnaMQTKs4fgzKnlwPfMrPCTyLiPaAY3+sBjrt
         koVclxM1pqcqkymk7Zr5TcEiEmawnCHCEktXZiJcdp4lcuxq1lCMUWe6Gg60U2LvOafm
         gH5U/dIgRhbB10uniud4bM4M3z1rJgnC9sSnKSDesJ/qgaQ6zvBQY30lmrbhCWMIcTjT
         Z1RA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:references:cc:to:from:subject;
        bh=gMcmfehS+q6BAMkgDQDcfUGchOwbG5CF6FFiOFL6VNY=;
        b=gj2xZZ25vjJKPB5EVzUBntXcRrvhPzUPDhXZVVEIDmrtJxEVlYMzNs/js9nPywngxx
         yinY55YkW0y5fRVYxzv1P9KO6UXZIbqGMkxZBGpstsrjSYWBFzGqkIf7FMCWZAoZZG77
         xrSN27Y3W2ZOHpYExUBx7/tvUvVNqKjN81f2w8wIlHMnH+fSwBAVjnhampCl+eqot3Nz
         iAGIBA/gXpSO3gRfHRd524JHh1LDO0RaS7AG2b0/If2VopMVdOkFFgziy1FX4KNQiTls
         MVTrKB7CwQJ/OtEFnsvgXHVxsFwjatDsDzJoz7joWVtaM2I1N2Rkq+zWPPWQwAs39oi8
         RL2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d185si803081ywh.85.2019.06.14.01.45.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 01:45:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) client-ip=148.163.158.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.158.5 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5E8hMkK130291
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 04:45:05 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2t488787my-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 04:45:04 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Fri, 14 Jun 2019 09:45:02 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp02.uk.ibm.com (192.168.101.132) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Fri, 14 Jun 2019 09:44:52 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x5E8ioUG58589432
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 14 Jun 2019 08:44:50 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id C533CAE051;
	Fri, 14 Jun 2019 08:44:50 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 641BDAE045;
	Fri, 14 Jun 2019 08:44:48 +0000 (GMT)
Received: from [9.145.160.23] (unknown [9.145.160.23])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Fri, 14 Jun 2019 08:44:48 +0000 (GMT)
Subject: Re: [PATCH v12 00/31] Speculative page faults
From: Laurent Dufour <ldufour@linux.ibm.com>
To: Haiyan Song <haiyanx.song@intel.com>
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
        Balbir Singh <bsingharora@gmail.com>, sj38.park@gmail.com,
        Michel Lespinasse <walken@google.com>,
        Mike Rapoport <rppt@linux.ibm.com>, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, haren@linux.vnet.ibm.com, npiggin@gmail.com,
        paulmck@linux.vnet.ibm.com, Tim Chen <tim.c.chen@linux.intel.com>,
        linuxppc-dev@lists.ozlabs.org, x86@kernel.org
References: <20190416134522.17540-1-ldufour@linux.ibm.com>
 <20190606065129.d5s3534p23twksgp@haiyan.sh.intel.com>
 <3d3cefa2-0ebb-e86d-b060-7ba67c48a59f@linux.ibm.com>
Date: Fri, 14 Jun 2019 10:44:47 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <3d3cefa2-0ebb-e86d-b060-7ba67c48a59f@linux.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19061408-0008-0000-0000-000002F3B0D9
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19061408-0009-0000-0000-00002260BA09
Message-Id: <1c412ebe-c213-ee67-d261-c70ddcd34b79@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-14_05:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=772 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906140071
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Le 14/06/2019 à 10:37, Laurent Dufour a écrit :
> Please find attached the script I run to get these numbers.
> This would be nice if you could give it a try on your victim node and share the result.

Sounds that the Intel mail fitering system doesn't like the attached shell script.
Please find it there: https://gist.github.com/ldu4/a5cc1a93f293108ea387d43d5d5e7f44

Thanks,
Laurent.

