Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 44AAD6B0389
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 04:15:12 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id 186so2511884oid.2
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 01:15:12 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id o190si4188473ioo.207.2017.02.23.01.15.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Feb 2017 01:15:11 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1N9DoVv120907
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 04:15:11 -0500
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28sdf63q4f-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 23 Feb 2017 04:15:10 -0500
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 23 Feb 2017 09:15:08 -0000
Subject: Re: [PATCH 2/2] mm/cgroup: delay soft limit data allocation
References: <1487779091-31381-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1487779091-31381-3-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170223011644.GB8841@balbir.ozlabs.ibm.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Thu, 23 Feb 2017 10:15:03 +0100
MIME-Version: 1.0
In-Reply-To: <20170223011644.GB8841@balbir.ozlabs.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <d301eb31-9c95-60c2-3d41-fc2fcb53f2eb@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 23/02/2017 02:16, Balbir Singh wrote:
> On Wed, Feb 22, 2017 at 04:58:11PM +0100, Laurent Dufour wrote:
>> Until a soft limit is set to a cgroup, the soft limit data are useless
>> so delay this allocation when a limit is set.
>>
>> Suggested-by: Michal Hocko <mhocko@kernel.org>
>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>> ---
> <snip>
>> @@ -3000,6 +3035,8 @@ static ssize_t mem_cgroup_write(struct kernfs_open_file *of,
>>  		}
>>  		break;
>>  	case RES_SOFT_LIMIT:
>> +		if (!soft_limit_initialized)
>> +			soft_limit_initialize();
> 
> What happens if this fails? Do we disable this interface?
> It's a good idea, but I wonder if we can deal with certain
> memory cgroups not supporting soft limits due to memory
> shortage at the time of using them.

Thanks Balbir for the review.

Regarding this point, Michal sent a new proposal which will return
-ENOMEM in the case the initialization failed. I'll send a new series in
that way.

> 
>>  		memcg->soft_limit = nr_pages;
>>  		ret = 0;
>>  		break;
> 
> Balbir Singh.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
