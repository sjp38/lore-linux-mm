Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,
	UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E11A4C4321B
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 04:46:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9997D20820
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 04:46:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Wbxv9JvX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9997D20820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2BC546B0010; Tue, 11 Jun 2019 00:46:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 26C456B0266; Tue, 11 Jun 2019 00:46:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 15A2D6B0269; Tue, 11 Jun 2019 00:46:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id EA1876B0010
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 00:46:25 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id f22so9067581ioh.22
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 21:46:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:user-agent:mime-version:content-transfer-encoding;
        bh=pN1LjauC+CPRpWSlRyHgYDY9uUd71KnW85D+Xgmc0hA=;
        b=b9G/9zQcUbKEeFX72WlZ993dMd1MqMOe755QJHtEx28+ZdTHkax+TMedygxTfbZcSR
         gMzfohpsrApH7ncH9p2HhG1y+aH2LYA2klzKpPUQLY6+OaDvax0O5YEzKI5fPdQ6cPBH
         N4HCy7+WxoKI3K3x+T0lxgLDLPQD/aYNS9LmI4/nCKeD8ApvqOECDC78Zn46Ph10kCRb
         VT/fz/RqqE79LU0H7u7WVHoJyqqvfq9DaDCDFxr+eaxV5B3JzKj9ES+rb816qgUq6LGB
         FLR4r6RDP0nAFE4Cm/ikx8aMGPO3oMTx3LtdnpSNvWbZc1vwwe4RqQSByu0abNbMYe2X
         vbCA==
X-Gm-Message-State: APjAAAWqZ8uZ8Z9sc2eSAZiHlX1vl6Q75qAkwlVHm+ZaLacsztcaALEV
	3vKgyWXqPKnXfNJvxdQDqZwXA3aEh3CUQFHdWXK9WgCMGCtN7zMkqus9yO1HoQg4UKn6rsySwIH
	fa/Az2Lzjh4+5ocC47hbjG1y4cDR6ZeUn1N4v8uUgpbs3Ft2hkCaxwnzvtGWYkHct+A==
X-Received: by 2002:a6b:1604:: with SMTP id 4mr7298088iow.245.1560228385652;
        Mon, 10 Jun 2019 21:46:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyNSozJU54vz95vpbMLesnBh6eSTl9WZuntm4dKpX55LBLwoRzzR967QmO4Tb2hKWe2N8X7
X-Received: by 2002:a6b:1604:: with SMTP id 4mr7298063iow.245.1560228384936;
        Mon, 10 Jun 2019 21:46:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560228384; cv=none;
        d=google.com; s=arc-20160816;
        b=G2roCmshH1Jj9mN2RlvbSBpTc+q6nWFRqj0aV6s6ei6/g7lfLfKsrkUYdOYkyRMR20
         EbSYOvtzpZgiUninAsMnfRbvHDxNQbc4sE5Gy1nQ/yS59JI99o7FvawjcpKOOiJ5W0dy
         aS0MexwYXzNw0WCnO07AO4S1f1dK1Qe4g/io2yzCf76i0YhpZZLdTu53JBgRPi/nisOf
         6XJONGFHyDMjTX3DDpEiBgyeaQbeqgjYJwUcdn0mjmkw3vMVIoCw7FjJAqHhWb/74Ix4
         fbMT2+IsvgwnuOxCoU2o/99JfoPZoBRCiDHzGr/h9X8jYSa3H7RfenYUIOWJzz479Fw4
         HRqQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject:dkim-signature;
        bh=pN1LjauC+CPRpWSlRyHgYDY9uUd71KnW85D+Xgmc0hA=;
        b=0u4/GPdj11hgcIymYnb26OFnrsIxK8hzpQ2uo6doF8PUZxSYjJoaDBz9O/hf6k26xK
         gr7AFuJ9uSw59NGPYllXE5rh5Bfb6wA3wqV59ROiChBMdNJhc9C5IktqsuEZ5ETCanry
         h/e4fR9G5SVxzGOsk+kijtVjZYz79gZ1Wp0sBriBkMSm/H7RCDfTiyVoosUGsU3qW6Y3
         OAI5KRftrt5rnliRfOOzF7ExQ4ZYDDUg22K5qhRnc/a4SQq1QFxujRLWZd2TA7YipTR5
         mBUXvLGM9xP/N4gXS2j+gZhNh/ceHaHB9M8B+kn93J9de2bCMGk7E97Kh1BTdYmcLW28
         nQ7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Wbxv9JvX;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id n18si7524455iod.107.2019.06.10.21.46.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 21:46:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Wbxv9JvX;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5B4hbqV168941;
	Tue, 11 Jun 2019 04:46:16 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : mime-version : content-type :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=pN1LjauC+CPRpWSlRyHgYDY9uUd71KnW85D+Xgmc0hA=;
 b=Wbxv9JvX5jua5fmuVf4WLo6oJ0xopMG6S8aXI4zN/zs6GcRiHLoYZHkBF5Ah+etbHjTV
 t4okax2hJ3ZVZLDfOnry0LnaCkQXAxd8eqpU+iocpvfiiR1CWCg1NzVCJmaIfvWHV194
 QtqmADNFWvMmnihKxYNSgBTszEjVDoaUqvNZfvuCZjzUhsySldlo6UNBrTBJvmTEgx1f
 n+Vqqb4e4J8Mjiq9yPSu2kbcM443RIt0eblRTUvtpGYSQuclN4ep0QiNQ/dHErKEUpk9
 FkRZvBXQI3KN8CkkvkA43MSVuLyOkec/HAUj8mptHg+pR+i+IldvyaD5z8t5XdDV16Zd UA== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2120.oracle.com with ESMTP id 2t05nqjh5g-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 04:46:16 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5B4k8F4173710;
	Tue, 11 Jun 2019 04:46:15 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by aserp3020.oracle.com with ESMTP id 2t0p9r34ed-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Tue, 11 Jun 2019 04:46:15 +0000
Received: from aserp3020.oracle.com (aserp3020.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5B4kFaV174053;
	Tue, 11 Jun 2019 04:46:15 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3020.oracle.com with ESMTP id 2t0p9r34e7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 04:46:15 +0000
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5B4kCRS002575;
	Tue, 11 Jun 2019 04:46:12 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 10 Jun 2019 21:46:11 -0700
Subject: [PATCH v3 0/6] vfs: make immutable files actually immutable
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: matthew.garrett@nebula.com, yuchao0@huawei.com, tytso@mit.edu,
        darrick.wong@oracle.com, ard.biesheuvel@linaro.org,
        josef@toxicpanda.com, clm@fb.com, adilger.kernel@dilger.ca,
        viro@zeniv.linux.org.uk, jack@suse.com, dsterba@suse.com,
        jaegeuk@kernel.org, jk@ozlabs.org
Cc: reiserfs-devel@vger.kernel.org, linux-efi@vger.kernel.org,
        devel@lists.orangefs.org, linux-kernel@vger.kernel.org,
        linux-f2fs-devel@lists.sourceforge.net, linux-xfs@vger.kernel.org,
        linux-mm@kvack.org, linux-nilfs@vger.kernel.org,
        linux-mtd@lists.infradead.org, ocfs2-devel@oss.oracle.com,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-btrfs@vger.kernel.org
Date: Mon, 10 Jun 2019 21:46:09 -0700
Message-ID: <156022836912.3227213.13598042497272336695.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9284 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906110033
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

The chattr(1) manpage has this to say about the immutable bit that
system administrators can set on files:

"A file with the 'i' attribute cannot be modified: it cannot be deleted
or renamed, no link can be created to this file, most of the file's
metadata can not be modified, and the file can not be opened in write
mode."

Given the clause about how the file 'cannot be modified', it is
surprising that programs holding writable file descriptors can continue
to write to and truncate files after the immutable flag has been set,
but they cannot call other things such as utimes, fallocate, unlink,
link, setxattr, or reflink.

Since the immutable flag is only settable by administrators, resolve
this inconsistent behavior in favor of the documented behavior -- once
the flag is set, the file cannot be modified, period.  We presume that
administrators must be trusted to know what they're doing, and that
cutting off programs with writable fds will probably break them.

Therefore, add immutability checks to the relevant VFS functions, then
refactor the SETFLAGS and FSSETXATTR implementations to use common
argument checking functions so that we can then force pagefaults on all
the file data when setting immutability.

Note that various distro manpages points out the inconsistent behavior
of the various Linux filesystems w.r.t. immutable.  This fixes all that.

If you're going to start using this mess, you probably ought to just
pull from my git trees, which are linked below.

This has been lightly tested with fstests.  Enjoy!
Comments and questions are, as always, welcome.

--D

kernel git tree:
https://git.kernel.org/cgit/linux/kernel/git/djwong/xfs-linux.git/log/?h=immutable-files

fstests git tree:
https://git.kernel.org/cgit/linux/kernel/git/djwong/xfstests-dev.git/log/?h=immutable-files

