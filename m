Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DF65C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 18:35:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 225FC20828
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 18:35:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="WWSHrZeT"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 225FC20828
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C339A8E0007; Fri, 28 Jun 2019 14:35:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BE4D08E0002; Fri, 28 Jun 2019 14:35:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AAC868E0007; Fri, 28 Jun 2019 14:35:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f208.google.com (mail-yb1-f208.google.com [209.85.219.208])
	by kanga.kvack.org (Postfix) with ESMTP id 8541D8E0002
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 14:35:22 -0400 (EDT)
Received: by mail-yb1-f208.google.com with SMTP id c15so11723993ybk.2
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 11:35:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:user-agent:mime-version:content-transfer-encoding;
        bh=X31Rdwe/fJpCbRhxiN4E1CTNpfH8gWc+Lmuymkd/7tU=;
        b=QNn020pvCVDOc18jsaYzisx1a5VluAMq/myIrCuq0oXMhdzU5k0K+T+mq4pFGpzmKw
         YzNvpQg3BgdCMDPG4jXypavcXPxcpqmMsiAiZ9PczemyNL0+CCJmTltaeVcyw+PmOecx
         y35BN6jBQyRBEYqlXWa50EvimIC6oGtMvfn3gDKrpSNBBN46SnwU+XjIy7ce5xv6Wrag
         cvqWcUGnFUFJS+lPM9GZlqgpAZhMCVwS0TFKocZAQ13T4CIJ5KmyQIjyPhIyKti1zvR6
         dJJsGxMeapzW6jWqFmZgTpolUCksArS5RAA0v0tJLyXhdcELR7VMNDw4Qj/wwRTYgV0S
         3FsA==
X-Gm-Message-State: APjAAAUruEu2F/sKQMY6QDUgO04+MTvKziMi+KBesUWGi68qIltDIdd/
	ci9xxuZCIaHWKtXBTadXdB5Z6N3PjnMgpyj55uVGO3cCv3a9F5JV5lF0VHZa/0YnwtoO4wXR59u
	U8xfAvyooSQyTLRivRlOVfPSt3HVMIWLVMRz/GNvX5/m/jM9HP881/JGx/LKpcz+amg==
X-Received: by 2002:a25:77d3:: with SMTP id s202mr7159096ybc.326.1561746922294;
        Fri, 28 Jun 2019 11:35:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7bUCrhpsGd2Nhbv+d2YYZUg9X1fFDoPNpYesOVvYsdQyQeD6k4Frn89iwnBBtuxFXhoen
X-Received: by 2002:a25:77d3:: with SMTP id s202mr7159073ybc.326.1561746921810;
        Fri, 28 Jun 2019 11:35:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561746921; cv=none;
        d=google.com; s=arc-20160816;
        b=BnD6n/iX1vdYDQQ2se5kqJjjJ6NHeAfDhyEqPyhE0etO5gtrkZsmow6mFVxDgGS9Aj
         Tk9LL8aXUXWaQTSLI/FumjBxdfNGBJYMA9oOxlnXX/BwPLoe4OSs6XsejqaHl5aENCMp
         8btRw4RMNxa1EhksudezK4FXZE7/r6Onjb+EGGSyasxf7L5JoqMeRKPS3rsUhNouRnWk
         CQjeBrXS20ckIxtMP5Cf6l6Wl1/W4jLT1eK51IhSp9R0JZSbnrm2vhnDle/zbBv7PoWB
         e1NiPbJCwkkgKxCA/EwGKYoY5mDquuJJFccL2gtMo8frup6yzWkSV4JHHmg5p6C1Vq+7
         LgQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject:dkim-signature;
        bh=X31Rdwe/fJpCbRhxiN4E1CTNpfH8gWc+Lmuymkd/7tU=;
        b=IgflmfzkV+AsDrh6+ShVwjs/fmk0cfCxN95wfUQr+esfsX4OQgeccGfKPzsPhEmuRn
         W3PAybaxS3kTL8O1bRGYMt9binWKTHzgREZl2xdncm7w1r92M+WxEMYYEXgVgHhg274S
         7dxUljXi7b8A1fMScAzqOjBy9m2PBQyTIeCF7g8wQLdYIOXZxwFMeUovZUzom9p6Ms+b
         iU4cMWo4Oqa1cLRcvZZBNEMUW2+XDZPAvGkaPP/IIpdRE2PKqxHVnSgI32VhDiYjMqpw
         uKSq4XPUP4P8lVhuq/Mc2xVN2FgpUovqrjg5ENVuP3C5jYr8QgPwDC33zIlHvvzoTT8x
         LOKw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=WWSHrZeT;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 84si1111658ywd.51.2019.06.28.11.35.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jun 2019 11:35:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=WWSHrZeT;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5SIYK1M108856;
	Fri, 28 Jun 2019 18:35:14 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : mime-version : content-type :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=X31Rdwe/fJpCbRhxiN4E1CTNpfH8gWc+Lmuymkd/7tU=;
 b=WWSHrZeTQOM2DQMjPusLnbXcDxVxeA7M7u1P3I/zNSt4gy9JnK7FgAfgnlSMApe7aoCf
 UrjDRHAnOJSBfQz+kwR193dOjvcS/GSszyqd+ONkce1jQZPFLIc3vqR1Db9gKVE0gHAR
 w2CCi2s3uloN0ogQYmAz9DbxZmZDx8yOSbDiNfwtsfWFxWfVPk2Ny1aPtA7Bw/XcmhTF
 OwA72SmJsRoonPVrE56vGDCCt7L9Pjed/Y2RRHx9FrpohlEeoYdL5sWbWPOswBHNtWiM
 n5ce9/hTY/ZxX1MoMaAAZK2Bg3jIUbqSGNjuzE1Q7keq4fbTzhLB3bQgK/nAoJ0iOFqe tw== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2t9brtq3k0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 28 Jun 2019 18:35:14 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5SIYwDR152445;
	Fri, 28 Jun 2019 18:35:13 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3020.oracle.com with ESMTP id 2t9p6w237k-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 28 Jun 2019 18:35:13 +0000
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5SIZCEb027315;
	Fri, 28 Jun 2019 18:35:13 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 28 Jun 2019 11:35:12 -0700
Subject: [PATCH v2 0/2] vfs: make active swap files unwritable
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: hch@infradead.org, akpm@linux-foundation.org, tytso@mit.edu,
        viro@zeniv.linux.org.uk, darrick.wong@oracle.com
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org
Date: Fri, 28 Jun 2019 11:35:11 -0700
Message-ID: <156174691124.1557844.14293659081769020256.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9302 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906280209
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9302 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906280210
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

I discovered that it's possible for userspace to write to active swap
files and swap devices.  While activated, the kernel effectively holds
an irrevocable (except by swapoff) longterm lease on the storage
associated with the swap device, so we need to shut down this vector for
memory corruption of userspace programs.

If you're going to start using this mess, you probably ought to just
pull from my git trees, which are linked below.

This has been lightly tested with fstests.  Enjoy!
Comments and questions are, as always, welcome.

--D

kernel git tree:
https://git.kernel.org/cgit/linux/kernel/git/djwong/xfs-linux.git/log/?h=immutable-swapfiles

fstests git tree:
https://git.kernel.org/cgit/linux/kernel/git/djwong/xfstests-dev.git/log/?h=immutable-swapfiles

