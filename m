Return-Path: <SRS0=2ZuM=SU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70E39C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 13:05:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A26520674
	for <linux-mm@archiver.kernel.org>; Thu, 18 Apr 2019 13:05:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A26520674
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BCD9E6B000A; Thu, 18 Apr 2019 09:05:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B80926B000D; Thu, 18 Apr 2019 09:05:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A96766B000E; Thu, 18 Apr 2019 09:05:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5EC826B000A
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 09:05:36 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k56so1218188edb.2
        for <linux-mm@kvack.org>; Thu, 18 Apr 2019 06:05:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:message-id;
        bh=CA7nKj6cXWX2K2ZEnHqn1G5dSNvdpij3k5GjBfdMQYI=;
        b=afKyhrIzp4fidl0Kf9Cqko7lgbI8MUegn7BxYWnpDY8nKZ2SmHn9g+2QTIrEAD3lEz
         N0+Rscwd3IKDW7gfw55ujz4czQ8H6XmoviEb7xpbHGvyVqoBYYvGX70N0Gkw7lUlyUsI
         xkaC0gq+LBNixWpQR1LUG6iLOL84JASTIRQ/FRXZOAm3En34afyKzqPkDBAuKMhsOSjb
         MmSI8mcbK7LHOvqxHuNAuCFNNQI/5SL8JZL0Szx4PfZUAgZVmq1jA69AoKIqw6WaNZN3
         dG3Sr3HYPILVqKOtTND3xjM3qrA9/jNB37A3XPXpufusCBqoOsiLm9+0dDzMy9C7w573
         P46w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWx+RpldKhNVzPyxAxxbZDB55QXcDyC/dBk6JNUkE6XoGtJbDfV
	A38O5COfimgjEEQUidVUE0pshpSiY+BpN5RzIDbu0C9+x88ncj/DnPLM3Dv31eQeQ/tULk4N0kj
	5v+sdy88LL0FtTN3/iS0qqHs7xpzSUECYqwrDlBU4NpxpMnVEXeXx2oMxDO11mJl9sw==
X-Received: by 2002:a17:906:9415:: with SMTP id q21mr51960983ejx.27.1555592735917;
        Thu, 18 Apr 2019 06:05:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwwkdO1sPSa8suBRGJw+YTFlfUut9i+nI8WcqsAB653hvohQWI1SMdXH+crmWiqQ+ZsZKJL
X-Received: by 2002:a17:906:9415:: with SMTP id q21mr51960952ejx.27.1555592735211;
        Thu, 18 Apr 2019 06:05:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555592735; cv=none;
        d=google.com; s=arc-20160816;
        b=jioXs9o5DxktSGanU/kxoPYN3/ELBrCSXjcY40aiA/FaER7LNkx4hdJtqPT7GCxv0s
         bTGOs6KQSlLXRLdKSSRmMy+/r8t3jIFFRRlISH6n6H/FBMdpIluLwVb5MJF5wmt6xfkL
         V0Jtd/3gx9iklEntG2/zt7Lx2+57p/o3NHsfUWy6PqDw4VdaKAAhlxgpKfRPpSU71FwG
         Xs2wLAHfj2+2Wurif+wV6CMgZdT9dS2qo1pI66yCOr91PdhYVIDhuSmTcg4GUSdYNdKQ
         w+svyAWYuOCmfPfOI4e6v7/7MX8ouI+00eA1fQt5TH3QSJDP7QXMil0GwdRClvSBzE3j
         /gCA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:from:references:cc:to:subject;
        bh=CA7nKj6cXWX2K2ZEnHqn1G5dSNvdpij3k5GjBfdMQYI=;
        b=ps1NVeLVlrxErndoHzBKbBSJc/CW7ANRsK/lBPVpVtJfm6s0eGpizI+I8s2+77OEYl
         zrm5BPIM/p0PUYg0PfBmuOV6BZJV7GUlvFzV5Iu1tnovrAEHeZu8z0YuYIRA9So83eAZ
         1mE8ArI/CoxYb7MYHyG5HGml6L7gdwgbchVmjJ3u4ii5YM0GnHQ+zaPIk4jIOfAdqGEc
         56XTRVMNmt6W+f1b4lHPc4vD+DqNiCniNS5gtiv/LfvwawK9O+2Ii2btLPI0ZLB7d/Wn
         1+sPne9V8+43mopseG4CZ8OWoz/YuunPjzkTeNZSXX7JnZlY4NKuz7XP0lntXuX3BZvr
         Epcw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id w47si455916edw.19.2019.04.18.06.05.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Apr 2019 06:05:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ldufour@linux.ibm.com designates 148.163.156.1 as permitted sender) smtp.mailfrom=ldufour@linux.ibm.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3ID0H3u092046
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 09:05:33 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2rxr6fvrr0-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 18 Apr 2019 09:05:30 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.ibm.com>;
	Thu, 18 Apr 2019 14:05:26 +0100
Received: from b06cxnps4074.portsmouth.uk.ibm.com (9.149.109.196)
	by e06smtp07.uk.ibm.com (192.168.101.137) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Thu, 18 Apr 2019 14:05:24 +0100
Received: from d06av25.portsmouth.uk.ibm.com (d06av25.portsmouth.uk.ibm.com [9.149.105.61])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x3ID5NKZ42008590
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 18 Apr 2019 13:05:23 GMT
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 13D6411C04A;
	Thu, 18 Apr 2019 13:05:23 +0000 (GMT)
Received: from d06av25.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 10A6711C064;
	Thu, 18 Apr 2019 13:05:22 +0000 (GMT)
Received: from [9.145.32.15] (unknown [9.145.32.15])
	by d06av25.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Thu, 18 Apr 2019 13:05:21 +0000 (GMT)
Subject: Re: [PATCH] mm: use mm.arg_lock in get_cmdline()
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, Yang Shi <yang.shi@linux.alibaba.com>,
        Michal Koutny <mkoutny@suse.com>
References: <20190418125827.57479-1-ldufour@linux.ibm.com>
 <20190418130310.GJ6567@dhcp22.suse.cz>
From: Laurent Dufour <ldufour@linux.ibm.com>
Date: Thu, 18 Apr 2019 15:05:21 +0200
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:60.0)
 Gecko/20100101 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190418130310.GJ6567@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-TM-AS-GCONF: 00
x-cbid: 19041813-0028-0000-0000-00000362388D
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19041813-0029-0000-0000-00002421792A
Message-Id: <749b8c73-a97d-b568-c0e5-a7bda77090c9@linux.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-18_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=765 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904180093
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Le 18/04/2019 à 15:03, Michal Hocko a écrit :
> Michal has posted the same patch few days ago http://lkml.kernel.org/r/20190417120347.15397-1-mkoutny@suse.com

Oups, sorry for the noise, I missed it.

> On Thu 18-04-19 14:58:27, Laurent Dufour wrote:
>> The commit 88aa7cc688d4 ("mm: introduce arg_lock to protect arg_start|end
>> and env_start|end in mm_struct") introduce the spinlock arg_lock to protect
>> the arg_* and env_* field of the mm_struct structure.
>>
>> While reading the code, I found that this new spinlock was not used in
>> get_cmdline() to protect access to these fields.
>>
>> Fixing this even if there is no issue reported yet for this.
>>
>> Fixes: 88aa7cc688d4 ("mm: introduce arg_lock to protect arg_start|end and env_start|end in mm_struct")
>> Cc: Yang Shi <yang.shi@linux.alibaba.com>
>> Signed-off-by: Laurent Dufour <ldufour@linux.ibm.com>
>> ---
>>   mm/util.c | 4 ++--
>>   1 file changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/mm/util.c b/mm/util.c
>> index 05a464929b3e..789760c3028b 100644
>> --- a/mm/util.c
>> +++ b/mm/util.c
>> @@ -758,12 +758,12 @@ int get_cmdline(struct task_struct *task, char *buffer, int buflen)
>>   	if (!mm->arg_end)
>>   		goto out_mm;	/* Shh! No looking before we're done */
>>   
>> -	down_read(&mm->mmap_sem);
>> +	spin_lock(&mm->arg_lock);
>>   	arg_start = mm->arg_start;
>>   	arg_end = mm->arg_end;
>>   	env_start = mm->env_start;
>>   	env_end = mm->env_end;
>> -	up_read(&mm->mmap_sem);
>> +	spin_unlock(&mm->arg_lock);
>>   
>>   	len = arg_end - arg_start;
>>   
>> -- 
>> 2.21.0
> 

