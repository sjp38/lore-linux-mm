Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DC7B2C0650F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 01:48:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8EF4420C01
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 01:48:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="CFQd/O0T"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8EF4420C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C11C96B0006; Mon,  5 Aug 2019 21:48:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B75F06B000A; Mon,  5 Aug 2019 21:48:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 77C646B000C; Mon,  5 Aug 2019 21:48:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 39C4E6B0006
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 21:48:12 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id x17so74386574qkf.14
        for <linux-mm@kvack.org>; Mon, 05 Aug 2019 18:48:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:mime-version:content-transfer-encoding;
        bh=PksSkVmoG9RKY5k8FKRMXWO1ygGnlV7x3HQDnLYr2FU=;
        b=jYdKqG355vFkxrhxz/Fq1cmFSpEsl+eH58is6RUQjmEkkdNXHcRTr2DOeP0UVJx0UJ
         VbrP0+GVi59SILpJsM/DtNTYRyIcK662XlKDlK60J/PEZIx5YALHQM6o/mqSJkWbEWr5
         UQJVO2e1a1aA4lsiUgKrPafo8o3wkT7quHeimn7lSrG9RQ+ZGe6KtG/I98iXK6gvD/Ul
         ucpIzjL+rrouqxyj2j0Zi8tJ8VD/viC8d32RaJSN1VFOxTOu/i9M6sI4NN0L5xsznY9v
         KKQbTWGddMersOFY1Vhz47Xu/iI9NQmNmPdm2wvEmLqNgl+Mac42eQMKS8xGl26qin//
         YVWQ==
X-Gm-Message-State: APjAAAW3bqllEG0Fzrfw1Vsx6Wg4AjwEonkbJOHeqI2SJmPWkPTuQ/LS
	K2i6QnKVOwrrty46/VDvc2I3tSz4VqSlXE6+hPTTBFwEg7CfFOUjzZkpUpCxnyjAYEW7jKkRsW9
	48Cz2LqAxxSaUpfthfmmcTx8r3G/QmowRa5WUnuvagc/WMXK1mt98hl+wjTNiVB3tFg==
X-Received: by 2002:ac8:72d7:: with SMTP id o23mr907211qtp.98.1565056091969;
        Mon, 05 Aug 2019 18:48:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqydwq80s40SvCC/XarsFBMQfZVjCajzaot/kI5+bONt0XFEWCC0ROk9EwKLP+Pma2tb2rR2
X-Received: by 2002:ac8:72d7:: with SMTP id o23mr907189qtp.98.1565056091253;
        Mon, 05 Aug 2019 18:48:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565056091; cv=none;
        d=google.com; s=arc-20160816;
        b=MC//HUhduA7/pd9eAqKISrmbuYMJQIP67HUftLvrGD1yr1WvlrvGpS3Wih+IR0mRgn
         4U4dn9g4ONr+2Zv87ckG172UQokmQcujq1ioVMXNrWcwJn23ptc71/Mqz2RjWf+70lpl
         AZvwoQhWBEcJKsYiRwzqclKz8lWHKYtPL/tjyz7Dd/bIM4LyJdiXX9Ir2Ndg+zbHZoOa
         Y4FMDNVJAsbwbWv1HxNyQaRR7056+ADYdLwMImjj9Cd7qluWfQ4LaniyC6d15G/e29B/
         P118X963ZqApSfFOfDRandSJ+VUuI/IqxkQXK6pMyc4Fysu4pIwis8EhkC4L6eTsqC0v
         KEeQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:dkim-signature;
        bh=PksSkVmoG9RKY5k8FKRMXWO1ygGnlV7x3HQDnLYr2FU=;
        b=gXVZPiKEL5SK59I6iooE0GlftYtN9uoZXRBXfzxDmBVwmXaS9n2x7yjNtRcQLz8ha5
         g/LFGvU/9lcuWwjrZej0XlXN49wfIYniLpyPVDcvXOt6T3gmkR8+GAsZO9f2/if6WhpV
         vp3WVuw5dOf3l7GbJzzH4MEFT5RHM4Br4rXQRiaNcCIqLb5vFE63i5kxMYT0R6+ZgRas
         bxh7mCuU0t8yGtxyN86NvL2Gkwv2hLznxE2Qn1Ka0vqHCMjNWNxCBvTOG4R7icWyHlx2
         kvj0vKntezEKoer5GsmNjTABfWBnvKHkVFxh2KhL9PogCX6c55Lt0V7XBSVoxm9gd6wN
         FZSw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="CFQd/O0T";
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id i1si5780267qvq.100.2019.08.05.18.48.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Aug 2019 18:48:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="CFQd/O0T";
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x761j1x2152776;
	Tue, 6 Aug 2019 01:48:04 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : mime-version : content-transfer-encoding;
 s=corp-2018-07-02; bh=PksSkVmoG9RKY5k8FKRMXWO1ygGnlV7x3HQDnLYr2FU=;
 b=CFQd/O0TdL+fJb035wg6lmymH5MX9AHuF4oVojbk+VxMLMspY/DNPeS9dkdWIQ4FJqc2
 eCIYep9sP3irX1q6LyutjUmOFekjEnPB80LwBIDMPeefJ9SPm4oIPJiHt4T5KsL0T5YQ
 est/H9CCbwCFcXnYR+JmPegsB8Q4rMxeEOjy+VnBFMoym8uJHqy5zbE4bS7mAcxJ42RX
 2VDgUaT7acIwZrctN2S+CbvI5qMeXM/qXeeNR3skj6Nh8gMMrCDbccP4G2rmcZvCUvBb
 vbR6v0Y6f9mWr3NW9Md414D/WMd98TmdLlNbD0MXm4pNy4wEyWu/B3REyaYowbvQWpnT /Q== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by aserp2120.oracle.com with ESMTP id 2u527pjm9k-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 06 Aug 2019 01:48:04 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x761m4Tu012645;
	Tue, 6 Aug 2019 01:48:04 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3020.oracle.com with ESMTP id 2u5233qged-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 06 Aug 2019 01:48:03 +0000
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x761lpsf017771;
	Tue, 6 Aug 2019 01:47:52 GMT
Received: from monkey.oracle.com (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 05 Aug 2019 18:47:51 -0700
From: Mike Kravetz <mike.kravetz@oracle.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Hillf Danton <hdanton@sina.com>, Vlastimil Babka <vbabka@suse.cz>,
        Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@suse.de>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Andrea Arcangeli <aarcange@redhat.com>,
        David Rientjes <rientjes@google.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH v2 0/4] address hugetlb page allocation stalls
Date: Mon,  5 Aug 2019 18:47:40 -0700
Message-Id: <20190806014744.15446-1-mike.kravetz@oracle.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9340 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908060020
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9340 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908060019
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Allocation of hugetlb pages via sysctl or procfs can stall for minutes
or hours.  A simple example on a two node system with 8GB of memory is
as follows:

echo 4096 > /sys/devices/system/node/node1/hugepages/hugepages-2048kB/nr_hugepages
echo 4096 > /proc/sys/vm/nr_hugepages

Obviously, both allocation attempts will fall short of their 8GB goal.
However, one or both of these commands may stall and not be interruptible.
The issues were initially discussed in mail thread [1] and RFC code at [2].

This series addresses the issues causing the stalls.  There are two distinct
fixes, a cleanup, and an optimization.  The reclaim patch by Hillf and
compaction patch by Vlasitmil address corner cases in their respective areas.
hugetlb page allocation could stall due to either of these issues.  Vlasitmil
added a cleanup patch after Hillf's modifications.  The hugetlb patch by
Mike is an optimization suggested during the debug and development process.

v2 changes/modifications are mentioned in each of the patches.

[1] http://lkml.kernel.org/r/d38a095e-dc39-7e82-bb76-2c9247929f07@oracle.com
[2] http://lkml.kernel.org/r/20190724175014.9935-1-mike.kravetz@oracle.com

Hillf Danton (1):
  mm, reclaim: make should_continue_reclaim perform dryrun detection

Mike Kravetz (1):
  hugetlbfs: don't retry when pool page allocations start to fail

Vlastimil Babka (2):
  mm, reclaim: cleanup should_continue_reclaim()
  mm, compaction: raise compaction priority after it withdrawns

 include/linux/compaction.h | 22 +++++++---
 mm/hugetlb.c               | 89 +++++++++++++++++++++++++++++++++-----
 mm/page_alloc.c            | 16 +++++--
 mm/vmscan.c                | 57 ++++++++++--------------
 4 files changed, 130 insertions(+), 54 deletions(-)

-- 
2.20.1

