Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21204C76190
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 22:01:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BBA51229F9
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 22:01:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="zelHaYCV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BBA51229F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 545026B000D; Thu, 25 Jul 2019 18:01:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 526A78E0003; Thu, 25 Jul 2019 18:01:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 40BE88E0002; Thu, 25 Jul 2019 18:01:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 206216B0007
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 18:01:51 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id h3so56447036iob.20
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 15:01:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=7FptRZmjEs2pVIwTHSlVNGQPR98w4TY5Ui3dappIUrg=;
        b=JyVfSSVCN0Ghno5FpM5qcya4GEpdoRGCgeET9Y06zjcOcDlIV9EDf0nRR7eXhDo8+Y
         lVs6neSPa5aw0R3jzOISPbSQ89GhlAIFQQnzTICX5v87lpzGNAsIAOeHOtcErzfkRMfb
         akv2e6vHO0yPQ345COXXX/3vkVBWr2boqlZNhKGv1w43hPluOOFbLAo0r3/Zj60EMPWi
         20S4hFYDvHDW4mIA8nSR0L/9b1h6iee2WxqXKPy2HAOumcCobsyUuEjSwLzKMW8EERQx
         2Wy+ifH239BlHaiuH/jfd9m58OH63IalJVsTqtvv59laUEXWgSZwRc9+Gb/zVbWWX7xB
         j5Dw==
X-Gm-Message-State: APjAAAVGkkvko9TKQSzNNLeoJEZZaVcVcX4To9T0uU69ajoaebC1RmeD
	0YBNhzk8vsbJonykIovrxd37IoE+7vr8mq0oQJjsxiwAsTjdLHgfKzZU8cFUhFMUJi7BwpespS4
	eV3na+NfUn/q4gtBzIA1si132ZGvJWPWf5aL7Ptt1Rn0/gBKzX42BgQ+7+D/CJjFtpg==
X-Received: by 2002:a02:ce35:: with SMTP id v21mr4465921jar.108.1564092110852;
        Thu, 25 Jul 2019 15:01:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx2i8dEm0NK3o+NJ6+PXVpjPAfKXiBs6ekhTTj0w8sqiCWVK74OnfAhs9FJpM86EJ0CGmoB
X-Received: by 2002:a02:ce35:: with SMTP id v21mr4465841jar.108.1564092110143;
        Thu, 25 Jul 2019 15:01:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564092110; cv=none;
        d=google.com; s=arc-20160816;
        b=h5Z0QexeMuCY6XEQ42zywgidxTDfCxScDk0MmDtpuCec9BrZFvhWtqO850zOcEL6LC
         WDebDyyujGZrVQv8Dr9Pi80ezxk+cOxwU32bv5sY0o9nQCmk2DaQGmIUiE4f0U4Ts6ij
         YaEkk/tqwF+2WLGxi1WTUR0tF1tHM10S0e7mYngN91IxhSLDJ7qSxHUpT8BUiWgQMYYj
         sUW7Vm5rd4vQXf2iqJm97dXqnzNqIKKm/JgqA9MS5nHlevxaJ4sM68Z33QrXgCXhramk
         JAmVoC48iCL0ey8PBiyF2VjuL8QO6xfkRfjhnOPE21jpte+9JRAWyw8T8fZkAWWb4KUm
         BDvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=7FptRZmjEs2pVIwTHSlVNGQPR98w4TY5Ui3dappIUrg=;
        b=vZJDqxczxVkrKC06fgZyaNkMSqPHpsdfJlUMtVHvJYHImn9BDCsrStNQINgWLeG0h7
         Qcdb5qt7dn9oKryG2p+3rHuRibMiFWeV4I2vO5cna2+R6VmaOGT7WPu2hkI/WIhXOENj
         JidlTaiaQG20WIIYx+lZFf+hnxqgL3v5j06R+5CUXkBAcU9sbEnpJZZMj+dnsV2Ab1Lc
         Z9TnQMwfzN9l3EnV6ldfboBtaeranJlmaq2LfdSIRA4E6ZB9DmhhVcX6mHIWsrvus3LU
         RrjMiI6Wrxnv0OXUFPz/IOH6rJ2TFskiB7zNLz3LiIsPRd7zPd355FMT/1T724f5cICV
         eNvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=zelHaYCV;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id e8si75628077jaj.110.2019.07.25.15.01.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 15:01:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=zelHaYCV;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6PLnBY4047100;
	Thu, 25 Jul 2019 22:01:47 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id; s=corp-2018-07-02;
 bh=7FptRZmjEs2pVIwTHSlVNGQPR98w4TY5Ui3dappIUrg=;
 b=zelHaYCV1Eo2luXTb4NIC4ATeklX43FoLNIg+/v93pLzkx4YdPoO3fyCiM3L0fPupdyi
 U852W0/B/wTmHXmjk2GwVN78cODCp6JFURtLPB/JVE5cNpCMDJU5izjBJ52Pf04F4POy
 bv4XKNPSKbv1P/Wmn0xTL6YZeNo+iPnhKDOvgWpma4fbUlMbmdnA5r8PXxPLv2+9KB7O
 tNfOWJi83IepiGbtaooOLI6NBnqJwhGiSyaYAQ7vnSKXLxkPBTdhx96K7Q/hQWzx5lt5
 iroEHCwjWevK5I1aeJgvH6+PlR/vjvWG7DK9jwhcmMB/BjD7IkfxzgCngaJL+pzplMCB tQ== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2130.oracle.com with ESMTP id 2tx61c6r9g-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 25 Jul 2019 22:01:47 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6PLqUDr117787;
	Thu, 25 Jul 2019 22:01:47 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3030.oracle.com with ESMTP id 2tx60yjmj1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 25 Jul 2019 22:01:47 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x6PM1jni011429;
	Thu, 25 Jul 2019 22:01:45 GMT
Received: from brm-x32-03.us.oracle.com (/10.80.150.35)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 25 Jul 2019 15:01:45 -0700
From: Jane Chu <jane.chu@oracle.com>
To: n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: linux-nvdimm@lists.01.org
Subject: [PATCH v3 0/2] mm/memory-failure: Poison read receives SIGKILL instead of SIGBUS issue 
Date: Thu, 25 Jul 2019 16:01:39 -0600
Message-Id: <1564092101-3865-1-git-send-email-jane.chu@oracle.com>
X-Mailer: git-send-email 1.8.3.1
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9329 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=968
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1907250263
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9329 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1907250263
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changes in v3:
 - move **tk cleanup to its own patch

Changes in v2:
 - move 'tk' allocations internal to add_to_kill(), suggested by Dan;
 - ran checkpatch.pl check, pointed out by Matthew;
 - Noaya pointed out that v1 would have missed the SIGKILL
   if "tk->addr == -EFAULT", since the code returns early.
   Incorporated Noaya's suggestion, also, skip VMAs where
   "tk->size_shift == 0" for zone device page, and deliver SIGBUS
   when "tk->size_shift != 0" so the payload is helpful;
 - added Suggested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Jane Chu (2):
  mm/memory-failure.c clean up around tk pre-allocation
  mm/memory-failure: Poison read receives SIGKILL instead of SIGBUS if
    mmaped more than once

 mm/memory-failure.c | 62 ++++++++++++++++++++++-------------------------------
 1 file changed, 26 insertions(+), 36 deletions(-)

-- 
1.8.3.1

