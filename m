Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82BB8C10F0E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 12:32:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3433D214AF
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 12:32:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="bax0dq5n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3433D214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ECE1A6B0003; Thu,  4 Apr 2019 08:32:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E7EED6B0005; Thu,  4 Apr 2019 08:32:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6D8A6B0006; Thu,  4 Apr 2019 08:32:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8B22E6B0003
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 08:32:43 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y17so1313117edd.20
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 05:32:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=gZDsPgT54iopIB/5RFZJdDu4VB62KWX4j1imZ+6IIlg=;
        b=BWSn0xOT4nPOO4QoizmBfOSouBxK1D/VBtr6eJYnrZ0QXFRzspr4KGpqoLJS2dEcMK
         pkgttdiOsjJk9C/0fP4cFgd2b5vklHWUwcoCjUVloRhFn/Kn1qBOPeLkR448faByk+uE
         FYV1jlTRZ5aAmYZFvaGF2nSBIskdTsZzKA1X+B17ylOXNlDAgGs5vYKMeJNojRZJf9sd
         yPcj+y9XOhmIR+iDI1x5xrTkDzYHhAWoX32RKSacBABrbAo4RUF2rVfMPaYVoLfFb2wr
         CgZs5B1XKASdwx1r0cdgjABBuh8YVmdZeZZGCUAOS2CJZ9C8BXWcKa2xcaZdN5cHImeu
         mxQw==
X-Gm-Message-State: APjAAAVtDg9j6jm5kbzAzumytlBaJpmmAsJI2BvfHW2BD3loReaLG4tg
	Um6AvWJ2hTNiZQgwOx7gF6J+GKM/HGI3WK8QdwLIkZCTUMB0dKfHlnAVuO5rJK7ooIuAkPaGN0T
	aLCm8ieKBHmmKo8kRjUS8K86jo1gdFdNJCtVx3LhJWKyl2Ib5ht5JYidLsSbwPA3zXg==
X-Received: by 2002:a17:906:5d4:: with SMTP id t20mr3492774ejt.80.1554381163010;
        Thu, 04 Apr 2019 05:32:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxsy5F4fObLVTCWj1rDmGEOnoJCkXubF4lvXaQCrFGL9rlAFzokmS5uiGU7tCJv3kDSqXkN
X-Received: by 2002:a17:906:5d4:: with SMTP id t20mr3492704ejt.80.1554381161746;
        Thu, 04 Apr 2019 05:32:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554381161; cv=none;
        d=google.com; s=arc-20160816;
        b=n2iW91RHFYZ4ahnDp8jvoguM7oqO0OHYO9aIIUaIi/Ue9zWJ9tuAgUNogOlAxgkLCM
         k+SveK4vSdOdidqw0aivTorU8FjSCBKxWdq0bimV9TjzseTr67YTgxgufIpQ/2Hde+Sn
         h8W+1quUtNijzfn5QWZgGLlf+XAcwn0bP7oCSM5i9KMLwoT+LeQI5SjGEg03ygYXAc+Y
         cn0NgzKJzJ1PZznjM1dd4zXmBvJo2NjwyKkwEdszBuchuSaW0KGdEynAPjAFg+1RKHaw
         Qg3AhOujXJoZidHQzRf89qhS51bXWaFqL4U79nZUickkaKif4/qUj8Foi7IY6FIic0lC
         k5jg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=gZDsPgT54iopIB/5RFZJdDu4VB62KWX4j1imZ+6IIlg=;
        b=yhCGJgbVGfuW93SH7ExycyH7gR1Y0wZrDe8b6zgFr7ZViwTOyJHhIFzWRIxaPHMVWK
         qdyhA1Zfvtv6yrWgMYZoLjJStlMYkbSFVS6g+nqE9McoDQHFvh1mcKqxxdO970q2l9HG
         by7H/Z0L9dOMLsvRyM8TrJfflYfQYlOfI9Piat9GbsEFKKQTUQg/OFX3ASrzT3m6dKAe
         oi5avMHAOHZYljPmHLFsCCQPl4utFXYWVipf0ubL+WRpAvkLj3rlAT2EpHwNK6vS5hWX
         q9TfGnTjakNCzxNlg39pPXLETHThBo3Zcv2Sa6aWkwOMJdKbSHSMQUVVZktRCv1RMBFE
         p7UA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=bax0dq5n;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id b21si654608ejb.190.2019.04.04.05.32.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 05:32:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=bax0dq5n;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x34CNjbc071171;
	Thu, 4 Apr 2019 12:32:24 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=gZDsPgT54iopIB/5RFZJdDu4VB62KWX4j1imZ+6IIlg=;
 b=bax0dq5nz+zCq5Hh7heAKm3Gbajh0ndp+yIi20Cow+AmZ+Lr7DaGACQ7H8tgSPqHisfT
 ETobWq7+yda4aVXVZ06xWALV2SuByLIvVjYn2aAhXnB+KC4R6/ddKCr7ywZ6rJFj7p2v
 bhVnWVBHmDccGgfSKUreKrdCd5H7Z+jg2Rp3fP9j9MOC5as9iN9F8Qhm7t5vw+BbPLKD
 U+TSFv2R5j8/h1Pvz74I6kp91birLPir3o15lbzFw1xDtn0ASLHUbAcVbyXMpvhMH7aP
 LYfedp9l4sJG6gJgP+qXAO96Jn3p5QElwbmsPNKRlWJStxokMwFotPB4+SgcyEAHkFil PQ== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2rhyvtet9e-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 04 Apr 2019 12:32:24 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x34CVP7L092445;
	Thu, 4 Apr 2019 12:32:23 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3020.oracle.com with ESMTP id 2rm9mjkea0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 04 Apr 2019 12:32:23 +0000
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x34CWL3L024622;
	Thu, 4 Apr 2019 12:32:21 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 04 Apr 2019 05:32:21 -0700
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.8\))
Subject: Re: [PATCH] mm/gup.c: fix the wrong comments
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190404072347.3440-1-sjhuang@iluvatar.ai>
Date: Thu, 4 Apr 2019 06:32:20 -0600
Cc: akpm@linux-foundation.org, ira.weiny@intel.com, sfr@canb.auug.org.au,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org
Content-Transfer-Encoding: 7bit
Message-Id: <3D9A544A-D447-4FD2-87A5-211588D6F3E5@oracle.com>
References: <20190404072347.3440-1-sjhuang@iluvatar.ai>
To: Huang Shijie <sjhuang@iluvatar.ai>
X-Mailer: Apple Mail (2.3445.104.8)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=590
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904040083
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=650 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904040083
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000144, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Apr 4, 2019, at 1:23 AM, Huang Shijie <sjhuang@iluvatar.ai> wrote:
> 
> 
> + * This function is different from the get_user_pages_unlocked():
> + *      The @pages may has different page order with the result
> + *      got by get_user_pages_unlocked().
> + *

I suggest a slight rewrite of the comment, something like:

* Note this routine may fill the pages array with entries in a
* different order than get_user_pages_unlocked(), which may cause
* issues for callers expecting the routines to be equivalent.

