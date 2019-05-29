Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56A2FC28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 14:01:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0C1EB233FC
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 14:01:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="nMlg+I8J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0C1EB233FC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 832436B000E; Wed, 29 May 2019 10:01:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BBB26B0010; Wed, 29 May 2019 10:01:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65ABE6B0266; Wed, 29 May 2019 10:01:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3FA046B000E
	for <linux-mm@kvack.org>; Wed, 29 May 2019 10:01:16 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id b189so2158452ywa.19
        for <linux-mm@kvack.org>; Wed, 29 May 2019 07:01:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=096L/LOXEdmc+XaWi2V/0dCL3u92z1sdlldyNO1mdgI=;
        b=U1NTW8QuVbtv3KImZnssCtHzwTYb55n7uv8PJxno1dLodm+BYXf/LqXQgcV2L+wbrj
         9wJmg5XtpuxhXu6n5AzLRsqXr9YiDg3l9feZs1NgO/w0O42nB07BxoPoVF9IKm/LanDc
         eH8Bh3mmRx1iP4aqtMwrD2oL+qE3x968ikWmfXQK0/b5wyI94M+Nemh8VRL2c0NX9pfk
         DyUnKsFwQwytF891Ov2a0RH5fajoyzEf1kjt5uTv7abDaSWDvXrsdlDfgs2scKQSrE3t
         yTJlzCUXzjxvMFHD/H2iXYW1xZgpoAlbqS8FpGGOJK7q8h0iGNvJsJdRmU2g7Se9ULjM
         JAHA==
X-Gm-Message-State: APjAAAVVcCIybbeEQY9qsxw/ox/8N8OTgevZN/+TBL4gjRDY0wHGgfLx
	O/r/BayL7u6551yT2KzUqMOiymSSgX/XX/YlrkiA3UxD9eGXn9xFWr8dINHQX0zjIiJHV89OJNT
	uSL8ENl28TSgoMTq6PHIbTNiLuCoQowH3Q/PE1/It4pVjER8l52Tg5LFsm2E1pN9OKQ==
X-Received: by 2002:a81:120c:: with SMTP id 12mr64281159yws.74.1559138475909;
        Wed, 29 May 2019 07:01:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyHM4qBa0YG3sUA/ip/PGvstI4UxZzMzsxltEbf73KtgbF/xX4flumjFv8mt6yGhRUSlcrF
X-Received: by 2002:a81:120c:: with SMTP id 12mr64281079yws.74.1559138475052;
        Wed, 29 May 2019 07:01:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559138475; cv=none;
        d=google.com; s=arc-20160816;
        b=HlLI8AmYDMB3G1Jh5GQ6/t9SmrgDX3lK3XB4cwEzd6oRBDo+50yDhoKtiB7jENZP8D
         tks92zinQEtgxvRGw0CWkHxThjvXEM+N8MWXAx/iSIw8INnQgx2bKqEaOzA67IlVc4U6
         qXYlPFulUYSXaBO3ZRJ6d098kF68MrgH4F0TVO0yHPZ5be83T1gw5EHbMAT+es9I9SM1
         RAudZkOYZ+ZcVoH5iqIDqdx2JtohgDx6GxV8XCp+2O5ZiaAJzW6tR2ivG8TdX1Yhk/2W
         FME+WbYDpVdNLLTcapoQLUYPxonPGlvUQ9H6wPoc4MzRSHTaWStcyvhyduLG136Vxs8U
         R7bw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=096L/LOXEdmc+XaWi2V/0dCL3u92z1sdlldyNO1mdgI=;
        b=ewTsWO6+LJoWGbMEO+t8TJdYrCdWxMcWAMBmzuWg5/G5Avd+m8hu5Bz1uk28CWeB9k
         +kdTeGsv+e8rb4/j//m7q9pa1fUEa2kwGt7wcuSC/CdokGv4Uj7HbzY9eTSJ0+OcRL3I
         Z8vJANei0iIKecC9wcDoDNzsHIP5nmkRp9mDysGpIjRMU/iAvmwxVADcDB8znPBprmTL
         PCaMHih+SFXVfOoIQgwOB6rwl/sRzfdR3SBF16YoB/BBY8OOX2/FS8K0YTVykvGYcP/q
         UsPrffphAoE4hWZkM4eZFseHS+4LgrYsFfC3wzYTA2r9bIqrpyPcRUGzqX8mpoMjm3iS
         3FjQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=nMlg+I8J;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id v7si2500335ywg.157.2019.05.29.07.01.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 07:01:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=nMlg+I8J;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4TDrJA7001159;
	Wed, 29 May 2019 14:01:08 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=096L/LOXEdmc+XaWi2V/0dCL3u92z1sdlldyNO1mdgI=;
 b=nMlg+I8J1a0BUCwqzV37xbUI5/URaP1WCX6i4ybMyd2pIT5QV/ccJEJGoB8N2X4Vg5Tz
 Wc2y5oa4ocs5lGXdDZE6hHEmfm4jpAUNYiZ/dlkl4spLqRe1QwiSQC4w3lMbwKO18Wuy
 U7e3yBLQmyf/5Yd540pZEL5T6gQ0olmU2OTLtr3OJkLXKvYShLe1ja3Ewd3oLNb36NOK
 RyBvaQ7gfrXKRDWcPkTF5QmQ25+dbFT9bsj/uNvod2xON8nY31ZUsKQ5j/84uoPjv9yD
 8AmYvTV7IMhZX3S2LhCWRmGayuH8lUKTVBB8sEmR/QeElO+WwjzMVDjRsk1vlxv+dCjz wQ== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2130.oracle.com with ESMTP id 2spu7dj5tg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 29 May 2019 14:01:08 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4TE03Ll058476;
	Wed, 29 May 2019 14:01:07 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3020.oracle.com with ESMTP id 2sr31v9chy-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 29 May 2019 14:01:07 +0000
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4TE11MY017847;
	Wed, 29 May 2019 14:01:01 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 29 May 2019 07:01:01 -0700
Date: Wed, 29 May 2019 10:01:02 -0400
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, daniel.m.jordan@oracle.com, mhocko@suse.com,
        hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: Fix recent_rotated history
Message-ID: <20190529140102.xfxeiv3fvcw555tv@ca-dmjordan1.us.oracle.com>
References: <155905972210.26456.11178359431724024112.stgit@localhost.localdomain>
 <0354e97d-ecc5-f150-7b36-410984c666db@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0354e97d-ecc5-f150-7b36-410984c666db@virtuozzo.com>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9271 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905290092
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9271 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905290092
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 29, 2019 at 11:30:09AM +0300, Kirill Tkhai wrote:
> Missed Johannes :(
> 
> CC
> 
> On 28.05.2019 19:09, Kirill Tkhai wrote:
> > Johannes pointed that after commit 886cf1901db9
> > we lost all zone_reclaim_stat::recent_rotated
> > history. This commit fixes that.

Ugh, good catch.

I took another pass through this series but didn't notice anything else.

> > 
> > Fixes: 886cf1901db9 "mm: move recent_rotated pages calculation to shrink_inactive_list()"
> > Reported-by: Johannes Weiner <hannes@cmpxchg.org>
> > Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> > ---
> >  mm/vmscan.c |    4 ++--
> >  1 file changed, 2 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index d9c3e873eca6..1d49329a4d7d 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -1953,8 +1953,8 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
> >  	if (global_reclaim(sc))
> >  		__count_vm_events(item, nr_reclaimed);
> >  	__count_memcg_events(lruvec_memcg(lruvec), item, nr_reclaimed);
> > -	reclaim_stat->recent_rotated[0] = stat.nr_activate[0];
> > -	reclaim_stat->recent_rotated[1] = stat.nr_activate[1];
> > +	reclaim_stat->recent_rotated[0] += stat.nr_activate[0];
> > +	reclaim_stat->recent_rotated[1] += stat.nr_activate[1];
> >  
> >  	move_pages_to_lru(lruvec, &page_list);
> >  
> > 
> 

