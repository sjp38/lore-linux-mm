Return-Path: <SRS0=tO+N=VH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 384AAC74A35
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 23:37:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B4D8220665
	for <linux-mm@archiver.kernel.org>; Wed, 10 Jul 2019 23:37:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="kDswq2kM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B4D8220665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 25B268E009C; Wed, 10 Jul 2019 19:37:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 20B048E0032; Wed, 10 Jul 2019 19:37:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D3B28E009C; Wed, 10 Jul 2019 19:37:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id E03488E0032
	for <linux-mm@kvack.org>; Wed, 10 Jul 2019 19:37:09 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id f22so4683038ioj.9
        for <linux-mm@kvack.org>; Wed, 10 Jul 2019 16:37:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=0APovDijHG6PwMSfhaesG8TZJSRCkJcQP5cEbaYB8ww=;
        b=QkL1ZrBvsqrQsLFMTDWfH+apNrja13q1KutHWWsfNnYk/Y6Hfp+gJ3XcBDo+c2kwW+
         N9RgbfHWd6TZMNUS2Fg+VP4BDbYRzNdNylhFAXbXd8eQ1QUbUlcFdPNLSxvKrEiypRVq
         XhsdvdFXhesumh4y1pA8XQ7TqdoVmGhSAIS4gQUFqSAfWkD0EizIZM09fLDbXoHVyxcG
         1+ZBK9Yyn1zJ96tfgPDFAGWFFzpkEDSXaHm+VwOvgdXwARxDyeEbcWoYxqyi1DYsOVU4
         DdEgkvDt65v2CaZ81Tkl+MFIPP+apMT+7LGkONrrx/23oua+EA816V2PCVKAT3aEn5ed
         f+FA==
X-Gm-Message-State: APjAAAXg5YFV/cz5RFJkZLITs2b66OIW9Yq7RV0NHG+9DCJe6Vy+afBi
	N/OH5goGKrV2EBraZj5f7IU93RPU3sYwNVubcOUpTKY7I0qXs47Khon8EAEsSB5Md5sJP4CdzRE
	q/M2uyFTCob82xgqsg2gSyedsEwZC0daE41OOUFxOUfeoPLFH3eILnGnW031dH7L2Tw==
X-Received: by 2002:a6b:621a:: with SMTP id f26mr786396iog.127.1562801829637;
        Wed, 10 Jul 2019 16:37:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzA26No3PcPGS16VyeVaeOKpUt7Wufp3NYB0Wr3vIx58hib1mRkXDUFf2F7qHBt7bgCnLLp
X-Received: by 2002:a6b:621a:: with SMTP id f26mr786302iog.127.1562801828308;
        Wed, 10 Jul 2019 16:37:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562801828; cv=none;
        d=google.com; s=arc-20160816;
        b=bCuxeEgXSkjfhbLKHpt2TTidIWIHia186tMYHLFG1hTrZmSAU9gN4LxWQ8CqqyIw+Y
         Ag3t0J98opP/HWB+Yp9hXoP1UEOq5Yp4NkrlhdkIgF6DE3eizeHyC8UOcJrvyXOKh2KM
         vGmpb0tQa1d/mxrgzdwvh1xnuRd9+vUo4hLHxdu3JtPMoeRoMpmutIvbTf4zmZFCmJkR
         kvQ3m2FdHlXd8k/5ixUKsEgX+VakQGNSy94BoghDJhv8w6xnVO7QMF1jYQTgVmi19D68
         0M/rB2ultIHAjOD90dC//a4075XKEGk2GHa2gH2UxBC1GHNwf7x+K6eGaxleiGdAd3v6
         gqRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=0APovDijHG6PwMSfhaesG8TZJSRCkJcQP5cEbaYB8ww=;
        b=AkZ1JGvZtAjx/aPhvH0kW/ZeJcp8HKrWHa9d9BIZV+p92Cgxz93kY30ieMQjq73eGv
         5iIAPtDd3dXDmRECfMJIvk935X/VBA6Bnl7Ku4YpGmue9dZ9t0tGbemMrpuLEJECJSw9
         rOeucra7qFv3jPfq94v9bInv6kmCXqHraLP1rzJ+MYRWwguMRY93XIcGECcyue+sttWY
         6rbUaSfAMteTV9FVgodwgINnAOsQpZLEW2K0hVV1voX6qOEJiEjr0cyNRloQ6NcAn68O
         EV3tPLWgr+/0+S0Bnm/0WUtafwxydxevAxPi+4N01au9o5ll/31gX2VFaE2WtXRLg/fY
         0z5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=kDswq2kM;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id z1si5034764ior.144.2019.07.10.16.37.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Jul 2019 16:37:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=kDswq2kM;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6ANYiiS015651;
	Wed, 10 Jul 2019 23:37:05 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=0APovDijHG6PwMSfhaesG8TZJSRCkJcQP5cEbaYB8ww=;
 b=kDswq2kM9t+wCwvFNJYyU0TrxV21pjy/M9lYa3StIs3pnj3l4kJvj8zJCYnIOp4If51F
 Nr1dOTH+0YlC2OWMnZxMrjLnKIe/AOpLghBdk28iNkeBJmtjUmzUR0jkSmvfEWGtL4MS
 YRtCGDh5rSkJd51kXyPGhmY21vP4SxiBeoNbznJkeRd7JXnpBWDMZ02pHrKMPQKJdKKB
 E2Un0r3ziXKC04h5Z3MvHSyykh3cv4f2V1OvzJ6a6elKSlN+Ma/EXiIwwg3dUxq9YCqf
 ou/sRP15idTp6Bqm98Bs/FIdUxntZ/MMwP6ME7WdcEJxqusU75NyzyuPZsWKyAs+3o6e FQ== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by aserp2120.oracle.com with ESMTP id 2tjkkpvwtt-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 10 Jul 2019 23:37:04 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6ANXBMl092682;
	Wed, 10 Jul 2019 23:37:04 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3020.oracle.com with ESMTP id 2tmmh3twx4-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 10 Jul 2019 23:37:04 +0000
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x6ANaxxv003472;
	Wed, 10 Jul 2019 23:36:59 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 10 Jul 2019 16:36:59 -0700
Subject: Re: [Question] Should direct reclaim time be bounded?
To: Michal Hocko <mhocko@kernel.org>
Cc: Hillf Danton <hdanton@sina.com>, Vlastimil Babka <vbabka@suse.cz>,
        Mel Gorman <mgorman@suse.de>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        Johannes Weiner <hannes@cmpxchg.org>
References: <d38a095e-dc39-7e82-bb76-2c9247929f07@oracle.com>
 <80036eed-993d-1d24-7ab6-e495f01b1caa@oracle.com>
 <885afb7b-f5be-590a-00c8-a24d2bc65f37@oracle.com>
 <20190710194403.GR29695@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <9d6c8b74-3cf6-4b9e-d3cb-a7ef49f838c7@oracle.com>
Date: Wed, 10 Jul 2019 16:36:58 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190710194403.GR29695@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9314 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1907100274
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9314 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907100274
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/10/19 12:44 PM, Michal Hocko wrote:
> On Wed 10-07-19 11:42:40, Mike Kravetz wrote:
> [...]
>> As Michal suggested, I'm going to do some testing to see what impact
>> dropping the __GFP_RETRY_MAYFAIL flag for these huge page allocations
>> will have on the number of pages allocated.
> 
> Just to clarify. I didn't mean to drop __GFP_RETRY_MAYFAIL from the
> allocation request. I meant to drop the special casing of the flag in
> should_continue_reclaim. I really have hard time to argue for this
> special casing TBH. The flag is meant to retry harder but that shouldn't
> be reduced to a single reclaim attempt because that alone doesn't really
> help much with the high order allocation. It is more about compaction to
> be retried harder.

Thanks Michal.  That is indeed what you suggested earlier.  I remembered
incorrectly.  Sorry.

Removing the special casing for __GFP_RETRY_MAYFAIL in should_continue_reclaim
implies that it will return false if nothing was reclaimed (nr_reclaimed == 0)
in the previous pass.

When I make such a modification and test, I see long stalls as a result
of should_compact_retry returning true too often.  On a system I am currently
testing, should_compact_retry has returned true 36000000 times.  My guess
is that this may stall forever.  Vlastmil previously asked about this behavior,
so I am capturing the reason.  Like before [1], should_compact_retry is
returning true mostly because compaction_withdrawn() returns COMPACT_DEFERRED.

Total 36000000
      35437500	COMPACT_DEFERRED
        562500  COMPACT_PARTIAL_SKIPPED


[1] https://lkml.org/lkml/2019/6/5/643
-- 
Mike Kravetz

