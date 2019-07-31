Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41C8CC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 21:13:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 073292067D
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 21:13:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="sHCfQeB7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 073292067D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 852078E0006; Wed, 31 Jul 2019 17:13:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7DB2C8E0001; Wed, 31 Jul 2019 17:13:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 67B728E0006; Wed, 31 Jul 2019 17:13:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 455B98E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 17:13:53 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id l14so59088698qke.16
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 14:13:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=nk338iTHcZ5glQ9pVoR5sv06o3zifCdSyoAmg7k51eg=;
        b=C0Dx+Pg6vPjiezxXDWOIc5oNqTiRDMoFMbvkwymTJcGk1snFGnQXtY+BAcYT/SZh4y
         zZdb/oNEK/jy2ljteV9z4qdX66KclBwBXOQeT4oecc1n0mCiC/jzDxFJPUF7VHqGKryt
         BM4Vefi8rxn6XxV+Tjk2pCAnn1BcTDpRhPySNuY+G9DYqsY7NDktECtXabbCwqu0AWYM
         bUc9ZRAfTHh5Eez5h+ogv4/J1JkfUGpkrHPCezJRZ6sn6FeNIRMZJI8tg11GJewgcNFX
         3LcZUKSjq0adJZwirwvKWf1mLLUl60+WNt856qnnREugiIpqhZYEEIbyqBnN7XbcYMRa
         rKDQ==
X-Gm-Message-State: APjAAAWrAb2P4uSOUxTMRoziOGWhwmDgc8GHdLPLnB4QyWlv6R1vM1cS
	V22dPeR3Xqj4X2oOHmCgFy7q12IPaCAFcrT0Ttk6ZMluwUVa1n+pmT3SG5ZatU+c4+LNekZtpcM
	3KyP65riNzljF/wjgENZXgy4hYHP6CifGvK2+jKJY5mJBidPxVoKQwbuCMYH9+EMUfg==
X-Received: by 2002:ac8:252e:: with SMTP id 43mr87001312qtm.61.1564607633029;
        Wed, 31 Jul 2019 14:13:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVqpl9CfrY1kLvrmhUw0nTt0znDE4P4OctA/sQaUwGDWEFRZ6TEJhAcT67UZ4xwZrKO4nk
X-Received: by 2002:ac8:252e:: with SMTP id 43mr87001290qtm.61.1564607632579;
        Wed, 31 Jul 2019 14:13:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564607632; cv=none;
        d=google.com; s=arc-20160816;
        b=ghb5WMdWQpF8nlaNwE2V9/kOQvaE3D0jyO5SgE8+T1Qe4KavFRgF4uLUbCFa6rNI7g
         3tonIlXbrMraU1UXbKKFT8IBgrfbCTKetfBDmOFgbQo/Tz5cmLNwnsYMC9efAL6wihtI
         snbffuls16morsn5/xC5GbMLdyEqpWbEH5vgyT3izg4Qjy5chn3JIHknu1nFea1w/3Nf
         Ni1LYYdoIFU4GcrWVxiGxsRSQWKdg8L+VxxABUylTfg6nP/3tWWPQKfMuIxPBTZ0xf1M
         R4QAj2taIQNO9RdGnoOcJ7Ptt0nWRu2Df8ydHOtBnL2mX0hl/2toB99eK4ma0MfVhdCF
         ZClQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=nk338iTHcZ5glQ9pVoR5sv06o3zifCdSyoAmg7k51eg=;
        b=U3IQgy4LBamW9h/3kAHQlN5QSgUxip3b96JpMX/sHRRGKrsFZ1RABKkMX0VzsDQ8r1
         Zs0EO3H3Sdah1FZMMmtAWvPm5BpNLlyn3jMSDDwbrHU7Ur6O0PwAtcVtz8xfwZDx4FKd
         8KTK/Mqmqne+arP9jBzZfsZBMuMCzmE5r38+MsvnGStJ7NsnYJLZkqLY+OXsLSaaLNbW
         uNAiTx1QJ5eDz/JKRHh2MJ1/TnSOCbFnYDt8/Z55Vg+SkcLYKqLxodKbiohhpakcJOWi
         G30tnY6tBPtW//fMigtrVy6viq9ITL880g0J5pNwl025+Tq7Gsxz0A11fUoQc2T7eGCF
         Aebg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=sHCfQeB7;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id h20si3307272qtb.397.2019.07.31.14.13.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 14:13:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=sHCfQeB7;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6VL8sxc083461;
	Wed, 31 Jul 2019 21:13:48 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=nk338iTHcZ5glQ9pVoR5sv06o3zifCdSyoAmg7k51eg=;
 b=sHCfQeB7h4NMrSRZMCLP9KAHtS+eHmtI4MJM8u5wZoQngdtDpD+YvlXHN8iFnHeT7rFk
 Vu4cMWpJEMU4599m4FbPz93DAtZicMazt1OjMitmGAzPsx+tkZukXNixTTvkNA9FwchS
 kJX++LEY36kdbXBR6islJEFvKmm/HffgqNuktNXYFLpB75JmBHBTGKuNgpFahJFXuvRS
 RQA51To4x/0E9SIp4XTVd50E6iA7Lm+c6ilgidB/qBhxYizvIQF/H6qoLNLFm7HV6l3s
 DNPecn9sF5cC860u7+PS9puCPmKLriCeIbbg6o85Zd0pvpPat5WV2flmrDzeFjqG7Muz ow== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2130.oracle.com with ESMTP id 2u0e1tyyed-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 31 Jul 2019 21:13:48 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6VL7ill000805;
	Wed, 31 Jul 2019 21:13:47 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3020.oracle.com with ESMTP id 2u2exc4cfu-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 31 Jul 2019 21:13:47 +0000
Received: from abhmp0016.oracle.com (abhmp0016.oracle.com [141.146.116.22])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x6VLDkdg017301;
	Wed, 31 Jul 2019 21:13:46 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 31 Jul 2019 14:13:45 -0700
Subject: Re: [RFC PATCH 3/3] hugetlbfs: don't retry when pool page allocations
 start to fail
To: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        Hillf Danton <hdanton@sina.com>, Michal Hocko <mhocko@kernel.org>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Andrew Morton <akpm@linux-foundation.org>
References: <20190724175014.9935-1-mike.kravetz@oracle.com>
 <20190724175014.9935-4-mike.kravetz@oracle.com>
 <20190725081350.GD2708@suse.de>
 <6a7f3705-9550-e22f-efa1-5e3616351df6@oracle.com>
 <d4099d77-418b-4d4b-715f-7b37347d5f8d@suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <b7eb72a6-65a4-4785-39ec-a995d415fae3@oracle.com>
Date: Wed, 31 Jul 2019 14:13:44 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <d4099d77-418b-4d4b-715f-7b37347d5f8d@suse.cz>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9335 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1907310212
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9335 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1907310212
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/31/19 6:23 AM, Vlastimil Babka wrote:
> On 7/25/19 7:15 PM, Mike Kravetz wrote:
>> On 7/25/19 1:13 AM, Mel Gorman wrote:
>>> On Wed, Jul 24, 2019 at 10:50:14AM -0700, Mike Kravetz wrote:
>>>
>>> set_max_huge_pages can fail the NODEMASK_ALLOC() alloc which you handle
>>> *but* in the event of an allocation failure this bug can silently recur.
>>> An informational message might be justified in that case in case the
>>> stall should recur with no hint as to why.
>>
>> Right.
>> Perhaps a NODEMASK_ALLOC() failure should just result in a quick exit/error.
>> If we can't allocate a node mask, it is unlikely we will be able to allocate
>> a/any huge pages.  And, the system must be extremely low on memory and there
>> are likely other bigger issues.
> 
> Agreed. But I would perhaps drop __GFP_NORETRY from the mask allocation
> as that can fail for transient conditions.

Thanks, I was unsure if adding __GFP_NORETRY would be a good idea.

-- 
Mike Kravetz

