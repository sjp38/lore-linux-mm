Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60933C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 16:28:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 127F7217D8
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 16:28:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 127F7217D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95E908E0006; Tue, 12 Mar 2019 12:28:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90DB58E0002; Tue, 12 Mar 2019 12:28:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D7498E0006; Tue, 12 Mar 2019 12:28:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3C7D08E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 12:28:58 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id 23so3561373pfj.18
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 09:28:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=HoFU5tV2TtDpaPJHtvs+dGcS7i852A7xTa1Tq4bjwK0=;
        b=hqGTgr5cGMeDmrCzoHEoQYlpw1hcCD4DwWIOkBcm6+78itbgiDbxrzLdr+ih2RxNJI
         SzOGUQbAo5egZmnddtL6yw0yiATcQkDcoPfaHUD8kAA7aBxIdUo3EBJ36AfwdO0CgMt8
         eDy03FhEu19qhBdx+1u67FYz7KtrFtNVl6NGrnfSuKwoCOisABj3uUZG+RQNaLkIzW8f
         QQvoBmb8LbdyIUSSm5FZwtHP4DS0pI9jm44sjrNCrQ/XYG8ZuetimiRsFTSyNei7fJKM
         PljB3WUleDCNZnscCUhYv6yYss7yFEYxC+eiztXtHQUQlpheve4nKUKms5cdJ2JEPXEE
         +9yA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWblYtbLPmwPSPUrCZVE5QqACHVnFnrgYEXqICDDmxLjGT5/sbt
	9JpaKg9KCk2YGJ4JeFZcy3MbWw29uSOeyLl232TSkBICxbMdfXy2te1Sro+dTrYQVavdPLKLOGM
	KVO7sGM0QPgLf+Vg1V6Yx0Y70RXuE9NpFYgumvUE7JC2yVfsTxT5bmpo19qlFOa64bg==
X-Received: by 2002:a63:470a:: with SMTP id u10mr36474635pga.17.1552408137813;
        Tue, 12 Mar 2019 09:28:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNbcsfwqInXlN1S2mLCDMyBvOrDTCvoXLC1hV9lIvccktWIK0CgDwaa7jUiTGE+Pq6MkBR
X-Received: by 2002:a63:470a:: with SMTP id u10mr36474559pga.17.1552408136768;
        Tue, 12 Mar 2019 09:28:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552408136; cv=none;
        d=google.com; s=arc-20160816;
        b=Jd4INsdAzRK+0uvVnKoRZcIGOXO/ZBc4EpyJWozLqpeU9R7+BksuGM6IVsDgsxPGI6
         aU+Gx9c8fmTjtmFxiwer23RVFvJFZiSCK3mXQkW8FhYRGAljHOjoqoVpqZbzXj7pQMSx
         2yj54T6NHlBD5YXEfcW2247gtcui2N92qQ5/YAGgvn/5pBMRnMWNxKHT17UWvRFhG6Yf
         D/4Q1ZrNCxuQZfAXWS2vtmHVSRlxKLQeV1wn+jiQZpx2RjATBfJ+8jEGxvAE+GW0TJo8
         Z85z8jlxMI/MYdipm+W9Yxd1And5O2RWNx/Aa/5ujs5DZ1Z+SYrsoA6n9K/0guyB7cY5
         Zwsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=HoFU5tV2TtDpaPJHtvs+dGcS7i852A7xTa1Tq4bjwK0=;
        b=zraZ0DZFPZMIUh1klwX/FKKIGUDBxFhgTQSKFErOmILeuAocmoAIo63i6g6mYqLtPr
         vZ9FlQTt2F8U8p8du7OV0sjFmykw9HtggsthDRZ0lqsuJ4gwg+LwqWnAGN9wyUeyJ213
         Y9VcKlN1LaG4vEcpJQOaUry6qO9u5VEZiHqfYsL1uzanj4tthY+y7Z+QtEn3dkJvnN1M
         RfAIUsxFNMryu6BAAmePlP8e8DRn3cjjKTt3Zp8xaD54AZL5pNz5LFV9koH7/tgGIoUP
         OhsWRCWJJpLDCC/3r1fhrVJ5PEa5a+OqiJBCqrAZ09vAdvFyZARKMv0Ve2Viha6M6VMC
         5MzA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id b15si8427828pfm.72.2019.03.12.09.28.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 09:28:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x2CGOqCX041508
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 12:28:55 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2r6dr4tsyc-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 12:28:55 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Tue, 12 Mar 2019 16:28:53 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp05.uk.ibm.com (192.168.101.135) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 12 Mar 2019 16:28:50 -0000
Received: from d06av21.portsmouth.uk.ibm.com (d06av21.portsmouth.uk.ibm.com [9.149.105.232])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x2CGSnfi12189780
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 12 Mar 2019 16:28:49 GMT
Received: from d06av21.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 4812352057;
	Tue, 12 Mar 2019 16:28:49 +0000 (GMT)
Received: from nimbus.lab.toulouse-stg.fr.ibm.com (unknown [9.101.4.33])
	by d06av21.portsmouth.uk.ibm.com (Postfix) with ESMTP id 808BA5204F;
	Tue, 12 Mar 2019 16:28:48 +0000 (GMT)
Subject: Re: [PATCH] mm/slab: protect cache_reap() against CPU and memory hot
 plug operations
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org,
        Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
        David Rientjes <rientjes@google.com>,
        Joonsoo Kim <iamjoonsoo.kim@lge.com>,
        Andrew Morton <akpm@linux-foundation.org>
References: <20190311191701.24325-1-ldufour@linux.ibm.com>
 <20190312145813.GS5721@dhcp22.suse.cz>
From: Laurent Dufour <ldufour@linux.ibm.com>
Date: Tue, 12 Mar 2019 17:28:47 +0100
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190312145813.GS5721@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19031216-0020-0000-0000-00000321B665
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19031216-0021-0000-0000-00002173E2BF
Message-Id: <b2b80faf-2670-da69-60d9-f244d1597139@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-03-12_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1903120114
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Le 12/03/2019 à 15:58, Michal Hocko a écrit :
> On Mon 11-03-19 20:17:01, Laurent Dufour wrote:
>> The commit 95402b382901 ("cpu-hotplug: replace per-subsystem mutexes with
>> get_online_cpus()") remove the CPU_LOCK_ACQUIRE operation which was use to
>> grap the cache_chain_mutex lock which was protecting cache_reap() against
>> CPU hot plug operations.
>>
>> Later the commit 18004c5d4084 ("mm, sl[aou]b: Use a common mutex
>> definition") changed cache_chain_mutex to slab_mutex but this didn't help
>> fixing the missing the cache_reap() protection against CPU hot plug
>> operations.
>>
>> Here we are stopping the per cpu worker while holding the slab_mutex to
>> ensure that cache_reap() is not running in our back and will not be
>> triggered anymore for this cpu.
>>
>> This patch fixes that race leading to SLAB's data corruption when CPU
>> hotplug are triggered. We hit it while doing partition migration on PowerVM
>> leading to CPU reconfiguration through the CPU hotplug mechanism.
> 
> What is the actual race? slab_offline_cpu calls cancel_delayed_work_sync
> so it removes a pending item and waits for the item to finish if they run
> concurently. So why do we need an additional lock?

You're right.
Reading cancel_delayed_work_sync() again I can't see how this could help.

The tests done with that patch were successful, while we were seeing a 
SLAB data corruption without it, but this needs to be investigated 
further since this one should not help. This was perhaps a lucky side 
effect.

Please forgot about this one.

> 
>> This fix is covering kernel containing to the commit 6731d4f12315 ("slab:
>> Convert to hotplug state machine"), ie 4.9.1, earlier kernel needs a
>> slightly different patch.
>>
>> Cc: stable@vger.kernel.org
>> Cc: Christoph Lameter <cl@linux.com>
>> Cc: Pekka Enberg <penberg@kernel.org>
>> Cc: David Rientjes <rientjes@google.com>
>> Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
>> ---
>>   mm/slab.c | 2 ++
>>   1 file changed, 2 insertions(+)
>>
>> diff --git a/mm/slab.c b/mm/slab.c
>> index 28652e4218e0..ba499d90f27f 100644
>> --- a/mm/slab.c
>> +++ b/mm/slab.c
>> @@ -1103,6 +1103,7 @@ static int slab_online_cpu(unsigned int cpu)
>>   
>>   static int slab_offline_cpu(unsigned int cpu)
>>   {
>> +	mutex_lock(&slab_mutex);
>>   	/*
>>   	 * Shutdown cache reaper. Note that the slab_mutex is held so
>>   	 * that if cache_reap() is invoked it cannot do anything
>> @@ -1112,6 +1113,7 @@ static int slab_offline_cpu(unsigned int cpu)
>>   	cancel_delayed_work_sync(&per_cpu(slab_reap_work, cpu));
>>   	/* Now the cache_reaper is guaranteed to be not running. */
>>   	per_cpu(slab_reap_work, cpu).work.func = NULL;
>> +	mutex_unlock(&slab_mutex);
>>   	return 0;
>>   }
>>   
>> -- 
>> 2.21.0
> 

