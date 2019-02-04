Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 89F44C282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 18:25:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 494A120821
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 18:25:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="bvLVw1b4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 494A120821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFF1C8E0056; Mon,  4 Feb 2019 13:25:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D85278E001C; Mon,  4 Feb 2019 13:25:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C74008E0056; Mon,  4 Feb 2019 13:25:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9CF558E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 13:25:46 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id x82so1180835ita.9
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 10:25:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:in-reply-to:user-agent;
        bh=guEa4pAdTVI2vasSBUcrIKQQiPIM0OIavHgpDPBgRjM=;
        b=bC8FtwoVGSLXnbOWe0JTyogMC8K+n+wcnoXBnb738LNhF7AxAjRGdXo/lhT0ygL6Qd
         MkBgRb3lZICrhIC58ufUVJH0ilc7zySgZamW/E5nmIhcHeqVwqy0Ju7XOsLyA3wKRGcJ
         7IAgg6vEC0ba6QO5FCmWdO1ZkZxZBlR5n4R+xvqU5ZQsNVXYVCAPjR0m+d43XKKufA+M
         8LGhEE2VZv1fyy+Iyp9UbkjAwvapVmJWI41in6fxjE4pKGizVKT53/q340nXQkTi+rts
         Z3xtXd0RVeqi6m1d5LPWL/rMeyjJGYYAjG9nTYATwejJjUiQ+f8OQxtiwPhl+1SpgTK1
         lcKQ==
X-Gm-Message-State: AHQUAubt0VtTn25NXrlMcdztgm04QCVbzuDh8R1zJwBnljIO9nv714tL
	AW2t4mZGI43TvatvkkCyqE7+5hd8eIqsJTgcdcZvAVeioVtbroGvsMpBAG3AkjYtTaJI+coaJ6+
	wchYCVHPe6EAK27V1oKTKb5qH6wZvKLH71CHyX9SZWArOerMVmy1/zrT+ap0q32G/yg==
X-Received: by 2002:a6b:5902:: with SMTP id n2mr450288iob.262.1549304746376;
        Mon, 04 Feb 2019 10:25:46 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZHjICGd8BjjfIzay7Za8TsEKG5iXb9fJb0Yye+Y2s2Sxz+cQ3ANEmGpbk4a02ccen7mjcG
X-Received: by 2002:a6b:5902:: with SMTP id n2mr450255iob.262.1549304745694;
        Mon, 04 Feb 2019 10:25:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549304745; cv=none;
        d=google.com; s=arc-20160816;
        b=aJUcyMkXzCo58KUSe8+W3l2zKay75KBoqR+sBCJtehDlZUHwxK8ppBIi6A3gDvT3mJ
         BJJJkRWHvwaECYX9YTGWyg1ryD3zqQ449jhOHWqKDWeVXjIt88EpimfFvJgJXH6Z7+zO
         BDq4XW7RNqvkNlwwMPk9zFfGGm8/x/jT6s4Ck1/aI7drh161bDJrhQ09fY/TSpp4ccP/
         UnH0NWepeO8F+pvMc9fKrsObON5Z8ZJcMnbzyaEgYt4TUcoNagbCnKqHhSyHMLB1lIJC
         z7NirOk1TxNvBBZ3eBtuf3hn4S8xmeDMq6I2GyT/Z8kv9wxCybem6jxZM7ASRTDqf0ay
         N7EA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=guEa4pAdTVI2vasSBUcrIKQQiPIM0OIavHgpDPBgRjM=;
        b=jmKzr3A7byFRSgtXGi9SuqCsU0bJAI2cn/GIUgWAhSvYiiWnYQJtEo5XtqBfoDuXg7
         Tpc07OYAz+Apbq37L54nYo4Mr/vH0PLHuLK+ShjCWLsoNVx6831ujp3xE+RdhvaYb1lT
         sAYNViu94BbIQGiDYef6qj2q7cc/kAjgwx/4oOf1Utkj+lb2pEklTdYgpahgux91Cvcf
         JRQU5Hqib4cctSWmOmQsE5a2A1Lo6XhnD8lyYvK4v8ciAVG5Cy3aqH+lWKyb+soy1rJr
         pJwD8c2udKg2R4fnoGYUppinGSVqJYT+APVsHFUcVYOTushYanDHzLeK69i842uyJATL
         Ny9Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=bvLVw1b4;
       spf=pass (google.com: domain of dan.carpenter@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=dan.carpenter@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id g12si374119ita.133.2019.02.04.10.25.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 10:25:45 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.carpenter@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=bvLVw1b4;
       spf=pass (google.com: domain of dan.carpenter@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=dan.carpenter@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x14INmG5068339;
	Mon, 4 Feb 2019 18:25:39 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : mime-version : content-type : in-reply-to;
 s=corp-2018-07-02; bh=guEa4pAdTVI2vasSBUcrIKQQiPIM0OIavHgpDPBgRjM=;
 b=bvLVw1b4DoAfTWs1UqbNPyuxP4NgDc8/4239FJmOvU1SWVtC9/5b6rsNnTeiR8Jn6Y5q
 r8FgSzlZwPsTBLrxc/4No03OnX2o+wPAFwX/AC29GMt7z/epS4VF+3ymANI8NSS6LgpV
 qZPE7/lclzXOZRkfH/O0IRqs82VPpPgJcJ4z9ts7NQRoyB5Knva0FEqDpjPE4Sjy+5K9
 yWY5IH/iNTUEmUcjfnd8rXWyhjjY89HKcLEw40li8Y21vRBjGc1oyzQaUV0DrrD/x0kM
 5cSSEFxzWRxKZIyactgXWpGt6PQ70oxNKhp/A2JWvjZvx9TGi/FcZ6FYJgvfqLcZi8nq nQ== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2130.oracle.com with ESMTP id 2qd97eptn8-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 04 Feb 2019 18:25:39 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x14IPcxX020616
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 4 Feb 2019 18:25:38 GMT
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x14IPcfX013011;
	Mon, 4 Feb 2019 18:25:38 GMT
Received: from kadam (/197.157.0.20)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 04 Feb 2019 18:25:32 +0000
Date: Mon, 4 Feb 2019 21:24:21 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, kernel-janitors@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Stephen Rothwell <sfr@canb.auug.org.au>
Subject: [PATCH v2] mm/hmm: potential deadlock in nonblocking code
Message-ID: <20190204182304.GA8756@kadam>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190204132043.GA16485@kadam>
X-Mailer: git-send-email haha only kidding
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9157 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902040141
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There is a deadlock bug when these functions are used in nonblocking
mode.

The else side of the if/else statement is only meant to be taken in when
the code is used in blocking mode.  But, unfortunately, the way the
code is now, if we're in non-blocking mode and we succeed in taking the
lock then we do the else statement.  The else side tries to take lock a
second time which results in a deadlock.

Fixes: a3402cb621c1 ("mm/hmm: improve driver API to work and wait over a range")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
V2: improve the style and tweak the commit description

 hmm.c |   15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index e14e0aa4d2cb..3c9781037918 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -207,11 +207,12 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 	update.event = HMM_UPDATE_INVALIDATE;
 	update.blockable = nrange->blockable;
 
-	if (!nrange->blockable && !mutex_trylock(&hmm->lock)) {
+	if (nrange->blockable)
+		mutex_lock(&hmm->lock);
+	else if (!mutex_trylock(&hmm->lock)) {
 		ret = -EAGAIN;
 		goto out;
-	} else
-		mutex_lock(&hmm->lock);
+	}
 	hmm->notifiers++;
 	list_for_each_entry(range, &hmm->ranges, list) {
 		if (update.end < range->start || update.start >= range->end)
@@ -221,12 +222,12 @@ static int hmm_invalidate_range_start(struct mmu_notifier *mn,
 	}
 	mutex_unlock(&hmm->lock);
 
-
-	if (!nrange->blockable && !down_read_trylock(&hmm->mirrors_sem)) {
+	if (nrange->blockable)
+		down_read(&hmm->mirrors_sem);
+	else if (!down_read_trylock(&hmm->mirrors_sem)) {
 		ret = -EAGAIN;
 		goto out;
-	} else
-		down_read(&hmm->mirrors_sem);
+	}
 	list_for_each_entry(mirror, &hmm->mirrors, list) {
 		int ret;
 

