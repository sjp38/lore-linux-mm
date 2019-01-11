Return-Path: <SRS0=ysF+=PT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96E76C43387
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 17:53:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 60BFD20874
	for <linux-mm@archiver.kernel.org>; Fri, 11 Jan 2019 17:53:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="pKSoOo23"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 60BFD20874
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D8A958E0003; Fri, 11 Jan 2019 12:53:25 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D39D98E0001; Fri, 11 Jan 2019 12:53:25 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C01E18E0003; Fri, 11 Jan 2019 12:53:25 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 99F178E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 12:53:25 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id p21so13718204iog.0
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 09:53:25 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=L3ihz0Ird+e4+UHksRLQl2xkZDvYaSIUNPIJGpUrwR4=;
        b=HzW/1b5FqLq7dgCdCX2rtXo/hwYTGz4+l5OOwBjlbT5L68nDVSQfjvLFmJyPMAJMiS
         UV2AvU9doLsR93Bfv5W3S+SbpcVqSK17LbTDKWTDmJB34LbcauBfYUWYM1Zbouf0H2Tz
         SPru9lzyigTnA0dUvtwAhZbjzY3KXi5mwn7y0XtNbHm1QqIDIPeUp+cbxe2RGBOwgWQD
         /mPJqpsF/mPqTUpn7SYcmW1Zqmw5NaCKdYyKS8cMs9RAaZmYouY+IKa44J3GwnJ/NM+8
         Y9RWHFpvIZDqdp5Bogv+uyLidHwdjDQ38YY/69vz03nrTF+J6K5stgYbzSiSfu+OJpO5
         Fi4w==
X-Gm-Message-State: AJcUukeszt5Lgh7dAURSvfFmJRN2UQjwZMDVKRVsdAtAV8Md8WQqBXDa
	q/OL6fNB3SvxxPUXOrN4ClbruUTcelmREOJKCOQgarR81YOpuYvbCLwDR9o5Wpsv6ebXWDlnLT/
	hiLT4WP2fJk/r6v0rjiqgHj5aeP0Gzg7bMZI7YpQQiGXLq+NwQnJOIN/94bpE53HlSA==
X-Received: by 2002:a24:3e43:: with SMTP id s64mr2010791its.111.1547229205365;
        Fri, 11 Jan 2019 09:53:25 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4HDYRNUmyHWMb5MUqVmlI1ziuBEzZ1KCe4l+pyYu8CxQivYRHY+n6tvU3Id1GmIBDP75A1
X-Received: by 2002:a24:3e43:: with SMTP id s64mr2010761its.111.1547229204705;
        Fri, 11 Jan 2019 09:53:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547229204; cv=none;
        d=google.com; s=arc-20160816;
        b=iL0gCRZNFQAfwk+W9JPDVv/QK0BFpbqRkix+0VJFPvPj+cvFUoBcrmaxCztr/T43dJ
         5VX8oDfCV+B0B/CjNM/Scy1PGUmvKI6+Req5xMOG17TEkxDNZlIkRgSt8130Q2S44tQg
         u/WBmpMY1kKXVwO9vPhYadv9B4mSFLMBeFYvaYZwgVgAj9IoYKMQHj7ryRkN0+QziXR/
         9K+Ay1w+8kw5n/8kJ0LV+X5kTM99u282bjdyvRx+fkoh8qKzFGfQ7boU9VRIll57tKNY
         Pcawr612Ck6SUZeyw5u/CrjEL+EnkhiHc275c0FgU5ofBKziC7Sjh9dJkZ/w+J0DMAvL
         sFSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=L3ihz0Ird+e4+UHksRLQl2xkZDvYaSIUNPIJGpUrwR4=;
        b=OryyaTaMsrgccFWcu9mEpAxfpLgeqwzHmn3tjSa+htTzEU/fWK0LVvNNJ/mqtfzoR1
         w4c1MZLP1xhmtL7Bf29Nb+QzEgF/9tN1v6p+kXY3ahziaqC96pAM86vX2TyfhUtupWCz
         X/NiRAgRibtr9xsxbJ2ko7Axd8sV3qRpY4VZrnqF17pgmCF/nwPAsaI5r7RxL2a6BlLU
         BX+3e3h6zl4IpB5l9yAdZqwKr0Xi821a/1JXIMzmhgaerpmUOYxcNCcpxFalzdtO/UhZ
         /+dm8fgliapOCNjVQ5jF8g4hT2bqXJFYYWHAi7tL/NQepG2GZGotfLiuDkLe05duT8LE
         98ag==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=pKSoOo23;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id k190si1345975ith.139.2019.01.11.09.53.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 09:53:24 -0800 (PST)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=pKSoOo23;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id x0BHcvS3129655;
	Fri, 11 Jan 2019 17:53:21 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=L3ihz0Ird+e4+UHksRLQl2xkZDvYaSIUNPIJGpUrwR4=;
 b=pKSoOo23bd9rQm7LCdqSKg1G3TbIQjAP5IxsKDKvbWCf27qE+Oo1cVc1Ev24h7ZQm95w
 NVH/B37nO4BBLl+Pbujb4ItV0IGuLEL549K+1kQ1XTMftflXMA/UJkHyw0Wp9tn/aYRi
 tM1J6AdjwzbxRDf72I9u37v74I8acuxEPO8oqpE1PLMkTXbmTqfBFG+QI++PZegDd49l
 ZuQPR9YBECsVKdR2QqhyFJQPQqxA7sZPo4Z2HKeY6a/jhX2X9CbOWckVyZdzRGr1dnZC
 YD0CbFc/4AaDsE7Vgy/XosNKYzhcP/m+58AWyBRs077+XSZs7tg97VTrFZMGRys2jXpD qg== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2120.oracle.com with ESMTP id 2ptn7re58j-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 11 Jan 2019 17:53:20 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x0BHr3Li015213
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 11 Jan 2019 17:53:03 GMT
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x0BHqijW009240;
	Fri, 11 Jan 2019 17:52:44 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 11 Jan 2019 09:52:44 -0800
Date: Fri, 11 Jan 2019 09:53:01 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Baptiste Lepers <baptiste.lepers@gmail.com>, mgorman@techsingularity.net,
        akpm@linux-foundation.org, dhowells@redhat.com, linux-mm@kvack.org,
        hannes@cmpxchg.org
Subject: Re: Lock overhead in shrink_inactive_list / Slow page reclamation
Message-ID: <20190111175301.csgxlwpbsfecuwug@ca-dmjordan1.us.oracle.com>
References: <CABdVr8R2y9B+2zzSAT_Ve=BQCa+F+E9_kVH+C28DGpkeQitiog@mail.gmail.com>
 <20190111135938.GG14956@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190111135938.GG14956@dhcp22.suse.cz>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9133 signatures=668680
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=788
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1901110144
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000298, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 11, 2019 at 02:59:38PM +0100, Michal Hocko wrote:
> On Fri 11-01-19 16:52:17, Baptiste Lepers wrote:
> > Hello,
> > 
> > We have a performance issue with the page cache. One of our workload
> > spends more than 50% of it's time in the lru_locks called by
> > shrink_inactive_list in mm/vmscan.c.
> 
> Who does contend on the lock? Are there direct reclaimers or is it
> solely kswapd with paths that are faulting the new page cache in?

Yes, and could you please post your performance data showing the time in
lru_lock?  Whatever you have is fine, but using perf with -g would give
callstacks and help answer Michal's question about who's contending.

Happy to help profile and debug offline.

