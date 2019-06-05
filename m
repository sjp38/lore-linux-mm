Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F76AC28CC5
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 16:05:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02BF5206C3
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 16:05:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="RwobizMb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02BF5206C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 65E756B0266; Wed,  5 Jun 2019 12:05:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 610146B0269; Wed,  5 Jun 2019 12:05:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D6FC6B026A; Wed,  5 Jun 2019 12:05:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 16EEF6B0266
	for <linux-mm@kvack.org>; Wed,  5 Jun 2019 12:05:31 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id d7so18990134pfq.15
        for <linux-mm@kvack.org>; Wed, 05 Jun 2019 09:05:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=1vdDqwlpsmUpFZr2sH68Dl3KCcVcT+dZOWpsdlqCuuk=;
        b=GYyhKxIX9K0a34JbsmfE1jm70vWLKTXIKgGobIbZmTA9CDDgFX3T1W7BYwFxqcdtT1
         JFu51jJuqxtR1893gi+NVpI7B7xvcb/JGDxPtF3gTx9F9okFt4CscGqk0WS0qDapVEqK
         Hbjr9k6OliNbovm3ejovkijdsNjcFxtAwudXXPg5UoGFNs8H7W2aORiiTV99zQ7vX9tW
         Bvx+gqoxWDCIeB4DOU149kRASCgwAPTWzqX1LnQKAYW1avO8Hbn8x/73HhEFcY8Ae/iV
         XOuRkaiLdacLntaN+FByKutw6ywFLBFFAaCpB4FgGmxLq2aWlNdtnnw1kXABa+H5GojX
         gSGw==
X-Gm-Message-State: APjAAAXQGhbHakN+561DnADr9zBej56nH8DCjjNx8/dLX6JZqDeOPMOs
	SIyPBXabMKjCJ7Z9odvLuhXUQxy8o+8GmbxH28tdd6Onh0Hl2YLRDTNDJ9+JLvkU3dCF12BVGzH
	V6U5nD7hKWPX5MLpJphDlhQaDKM8Sixtk/Qo1fwUgFKI5bInCcaf4p0j39kaWnZzA1g==
X-Received: by 2002:aa7:942f:: with SMTP id y15mr48118748pfo.121.1559750730728;
        Wed, 05 Jun 2019 09:05:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBQWpwu021JP5FjZpvBZBNaeZf/cZzPCd7E5jv7IQIf2Mj3GT9bXCoXzig8dybbJ91DTwM
X-Received: by 2002:aa7:942f:: with SMTP id y15mr48118645pfo.121.1559750729944;
        Wed, 05 Jun 2019 09:05:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559750729; cv=none;
        d=google.com; s=arc-20160816;
        b=AsH5hj8DpBopS/CNdyB8m8roRQUklt/C+OQa3w107Mu69A2CXe7duPmI15ex72nxF3
         EkutnOm2A1AAVevLPW2tx9WnFrcy3hNkuZ61mW1mjAUq0PXEQZkQkP/BL+3Y4wpH6zzH
         +IeLb3GEOSHWZk/mErwlhiUfSUdYUEZzOZ2Uo8JzbbHIs0+03akLaKVk1p7q57KeWg0m
         MPCgikgRtfrGazv8tiFhj3EI7XgCP8A1RIXiSHF1+KJNGPDxTjiBMWYVhoOcs4sUI10j
         ZUwY/HgqDz+Wz0aKzef/VtkdlJ3Hhki7pNZHwKSNngQY4SFGZAKDSiAXwYa7ZYK4+Tpl
         IU/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=1vdDqwlpsmUpFZr2sH68Dl3KCcVcT+dZOWpsdlqCuuk=;
        b=cHEuMEJPKJXuKNza8G5iYrT9m3pwpvYyPMsux4QDfxtOlo5bNth0WWxnzKrfthAefk
         bEhYcXAVe1ZxlWh1J3q1e9ZqX9OmIH/A7BXppcrARsUxJamgMDL3btQ8gRyl73U3KlZK
         sQ/YcgTQGxJ1781Q0kg4l69CvBWWeOsbQ/X9LR8oIb/XKu8oNoJsMq55QbTf2r0FNgiO
         4hFu3xidIByWnYmpmpfuhiw1VcZD9jhAwI2TAVgOXrL83lM3KQyR1T3i2TqtViz3SuRW
         bBfQT35AW4j27qioUJKL+X8oA4jkxI1dYVmpK7YymzT7wKCo68eLcG3so8Cd7iFHcMaT
         Rdew==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=RwobizMb;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id r25si22600121pga.294.2019.06.05.09.05.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Jun 2019 09:05:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=RwobizMb;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x55FxDiW087274;
	Wed, 5 Jun 2019 16:05:25 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=1vdDqwlpsmUpFZr2sH68Dl3KCcVcT+dZOWpsdlqCuuk=;
 b=RwobizMb+qO6Ig04WCxpayxl+qZzJtAGKgx+NxYcyWIUmpDmSWlDwyar655Jr4coh3/N
 hy1cFArG3e41Hst86GQWrpoAqTGLpd8oQYf3MjOxh4OE9E/M+3wY1cLgyLavvAMonD/K
 MTVZQsWsJ8Xud7KaYm3ycIibo/9e6o83Jo0RR/rkGAZWq72oGeRTdvKzbBdox4tzuoyN
 SPRlD8dODPNEgLldfmZYbOsVOpjtDzxWW7hZWCVNxG6AgdEzfQQ+sbK/r7cbAc89120B
 B8iiLZQtk1GD5DhfgF/sgHtZgoTxaXAwLrm8QEl2gjFVxad/y4O760iuoZzrkLc1X1XP Ag== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by aserp2130.oracle.com with ESMTP id 2suevdkwdc-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 05 Jun 2019 16:05:24 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x55G52pL055753;
	Wed, 5 Jun 2019 16:05:24 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3030.oracle.com with ESMTP id 2swngm15yj-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 05 Jun 2019 16:05:24 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x55G5MMO007220;
	Wed, 5 Jun 2019 16:05:22 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 05 Jun 2019 09:05:22 -0700
Subject: Re: question: should_compact_retry limit
To: Vlastimil Babka <vbabka@suse.cz>,
        "linux-mm@kvack.org"
 <linux-mm@kvack.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
Cc: Michal Hocko <mhocko@kernel.org>
References: <6377c199-2b9e-e30d-a068-c304d8a3f706@oracle.com>
 <908c1454-6ae5-87ca-c6a5-e542fbafa866@suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <3bc00340-1e81-4f08-37f8-28388b7fba3b@oracle.com>
Date: Wed, 5 Jun 2019 09:05:21 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <908c1454-6ae5-87ca-c6a5-e542fbafa866@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9279 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906050100
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9279 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906050100
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/5/19 12:58 AM, Vlastimil Babka wrote:
> On 6/5/19 1:30 AM, Mike Kravetz wrote:
>> While looking at some really long hugetlb page allocation times, I noticed
>> instances where should_compact_retry() was returning true more often that
>> I expected.  In one allocation attempt, it returned true 765668 times in a
>> row.  To me, this was unexpected because of the following:
>>
>> #define MAX_COMPACT_RETRIES 16
>> int max_retries = MAX_COMPACT_RETRIES;
>>
>> However, if should_compact_retry() returns true via the following path we
>> do not increase the retry count.
>>
>> 	/*
>> 	 * make sure the compaction wasn't deferred or didn't bail out early
>> 	 * due to locks contention before we declare that we should give up.
>> 	 * But do not retry if the given zonelist is not suitable for
>> 	 * compaction.
>> 	 */
>> 	if (compaction_withdrawn(compact_result)) {
>> 		ret = compaction_zonelist_suitable(ac, order, alloc_flags);
>> 		goto out;
>> 	}
>>
>> Just curious, is this intentional?
> 
> Hmm I guess we didn't expect compaction_withdrawn() to be so
> consistently returned. Do you know what value of compact_result is there
> in your test?

Added some instrumentation to record values and ran test,

557904 Total

549186 COMPACT_DEFERRED
  8718 COMPACT_PARTIAL_SKIPPED

Do note that this is not my biggest problem with these allocations.  That is
should_continue_reclaim returning true more often that in should.  Still
trying to get more info on that.  This was just something curious I also
discovered.
-- 
Mike Kravetz

