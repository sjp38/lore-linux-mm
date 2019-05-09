Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFAE1C04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 16:09:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 801632173B
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 16:09:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="c5sPk/UW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 801632173B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 166EF6B000A; Thu,  9 May 2019 12:09:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1181B6B000C; Thu,  9 May 2019 12:09:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 006DD6B000D; Thu,  9 May 2019 12:09:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id D39B56B000A
	for <linux-mm@kvack.org>; Thu,  9 May 2019 12:09:25 -0400 (EDT)
Received: by mail-it1-f200.google.com with SMTP id t196so2550912ita.7
        for <linux-mm@kvack.org>; Thu, 09 May 2019 09:09:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=0ju7H5Gj2niL871BBOn8Ga4UpgCjBl63hHSs8faALiA=;
        b=Lt4dMdwFjQrtI5UBlqgd1HzU5VlgqoAE0S02nMCXwdFh761ByTLQuanO9xMDWlrUVy
         qPHciq0EdWJeO46oG0KXY4nkz8EZZC1yn9690x3N9Q4TD/XpLvUPBVJIb38OsLKi4kO2
         XYi1FDAhV6/D27v94Z0IO9ouXFfLzDpYF+LHMY5oYMYHTLVfL5mKm8NbwWYC1jsqT/15
         X9TQhkuKFdH8HrfS8tDNRVHkX+P0nDjov2P5dD7qyFhlI9MSc7kj9bBpXDsQMXz0p8ul
         48K7HMjIYN9ZFBJFUFG9/wwPuuL15JNgB7ka5r775r/tGM4RdbWtnSB7PU6OfTKPZQgD
         ZR/Q==
X-Gm-Message-State: APjAAAUwD5y1OlDsrnIwa6J3XH7qy/Xn3Wggh2TkKyFwDyRHep9BB8jX
	r4nLd1ODwiPw23ChihPdGrCq4OLfq2Kdt0cap04H2G3qY46dkk0/XeBwuSTz9hC74SFhFmt8Em1
	sBo3DW9TWoSS8mE+j6ggk9BXymp4Fe7vdJZV0YM0X5MX0tmUnKBFDqzV2YOvF9cxBwA==
X-Received: by 2002:a24:c2c1:: with SMTP id i184mr3620843itg.82.1557418165568;
        Thu, 09 May 2019 09:09:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwa++UOUVCPNK13RQsnG7otqWZbUYq+g2/xuasvfxKn11JrxOghWfbZl/e9maCefWAQaxaw
X-Received: by 2002:a24:c2c1:: with SMTP id i184mr3620797itg.82.1557418164934;
        Thu, 09 May 2019 09:09:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557418164; cv=none;
        d=google.com; s=arc-20160816;
        b=0phZ0/KnLy0dBGYBpvxVQfXbZzIgDd6jCOZbUj/pdlGNaZpgHJ2p9vbHUrQE0EmXFk
         JKuxeWcKYhfF3YfcyhMu85Oq5BchSavJGp8y2XfsCPW9uEdbNttfnANutunI44JOq1R1
         R3eZmNBOIUgMWBNbzXpjAiJzaSLnqAv+35lUFDGpvig5CiGeTQG78/M3TZto2ioxmal6
         IAVYeADhkFQRAftK+V22z5wAwA9vTrdXt0Z9izU5Yhs4bkfdks32pBvoLcuVZvqnMAll
         gsHR0uGJJFVis/PsJ/rOwCJv5Xv+YQ8X7EkRLWRFoC6sO3rse0H66PcMNimMCiFkyETT
         4YUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=0ju7H5Gj2niL871BBOn8Ga4UpgCjBl63hHSs8faALiA=;
        b=qW/nylIhHNdaCtOPMaiuGh+sc8LmPmoN2RfB1It4FoNqDXEHiLRZ2ZKyiuwhn5U+2d
         PQSkhqxfE2tUt4VvClSTPLBB7/GBWWHnv2rqvoxuu2qiAWLTwaHFJQRZLU58EDJrS3S0
         nAaD5Mk/MHTf68yPVNygx3aTX5qjTnx9MJVgxrg6AD4FR5wdwZoeji2bw1m0Fzd91Y9s
         yyF6x9mWlCy+u5p9UhJW8cs/F9hDqdj85MTJgUxNcn4XcQ2jl9SEbr6QihTSlDnBz0P6
         +JI9puyf8KemK6jdDmoluT3UtUt7C9NWv2ro/0a/OL/T/NfQqOdwdvJy9EYNjtUC4U8T
         dGng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="c5sPk/UW";
       spf=pass (google.com: domain of larry.bassel@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=larry.bassel@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id n7si1873379jah.63.2019.05.09.09.09.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 May 2019 09:09:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of larry.bassel@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="c5sPk/UW";
       spf=pass (google.com: domain of larry.bassel@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=larry.bassel@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x49G41OP084863;
	Thu, 9 May 2019 16:09:20 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=0ju7H5Gj2niL871BBOn8Ga4UpgCjBl63hHSs8faALiA=;
 b=c5sPk/UWjvgCBKfpceUko8ZPiLjVtYZaJKfjeFrS72vCgisTcb/wqPpU408mjOlf1zAt
 N1dzXSOlBOYvO2FncI11/uZ6nX23dOWmdBrDMUjR1+aL79jZzdLe0yfSDijwAMGgDo7t
 Jwd8WePcB86Gdcg6BPC/D+blKGY+7lLdlbQc2A15l75HX8D8fJUSlZ9YvE3sij/XmWAR
 XtmMALWB/8Q2p3irGRUnm4mJb2te+1BFPLTPjInczB9VrVVJKnEKiaBZLN9I5+4vaK3N
 qmmdijdE3imqVZbniq7DGl8Ig6/MmEpd721BGHN8sPajfXcxwCio29Ce9ZhcvXUEPi2z tA== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2s94bgc066-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 09 May 2019 16:09:19 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x49G75FA107183;
	Thu, 9 May 2019 16:07:19 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3030.oracle.com with ESMTP id 2scpy5rqhu-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 09 May 2019 16:07:19 +0000
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x49G7G0I017023;
	Thu, 9 May 2019 16:07:16 GMT
Received: from oracle.com (/75.80.107.76)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 09 May 2019 09:07:16 -0700
From: Larry Bassel <larry.bassel@oracle.com>
To: mike.kravetz@oracle.com, willy@infradead.org, dan.j.williams@intel.com,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        linux-nvdimm@lists.01.org
Cc: Larry Bassel <larry.bassel@oracle.com>
Subject: [PATCH, RFC 1/2] Add config option to enable FS/DAX PMD sharing
Date: Thu,  9 May 2019 09:05:32 -0700
Message-Id: <1557417933-15701-2-git-send-email-larry.bassel@oracle.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1557417933-15701-1-git-send-email-larry.bassel@oracle.com>
References: <1557417933-15701-1-git-send-email-larry.bassel@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9252 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905090092
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9252 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905090092
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

If enabled, sharing of FS/DAX PMDs will be attempted.

Signed-off-by: Larry Bassel <larry.bassel@oracle.com>
---
 arch/x86/Kconfig | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index e721273..e11702e 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -297,6 +297,9 @@ config ARCH_SUSPEND_POSSIBLE
 config ARCH_WANT_HUGE_PMD_SHARE
 	def_bool y
 
+config MAY_SHARE_FSDAX_PMD
+	def_bool y
+
 config ARCH_WANT_GENERAL_HUGETLB
 	def_bool y
 
-- 
1.8.3.1

