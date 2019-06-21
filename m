Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62484C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 23:57:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15A0620821
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 23:57:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="VYwNeL6i"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15A0620821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D0F88E0002; Fri, 21 Jun 2019 19:57:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A8FB8E0001; Fri, 21 Jun 2019 19:57:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8BE788E0002; Fri, 21 Jun 2019 19:57:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6CDE38E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 19:57:06 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id p18so8014531ywe.17
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 16:57:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:user-agent:mime-version:content-transfer-encoding;
        bh=fawPQY/UISfSH6DvrztcWabWXm47TtXieQJWSELxOKQ=;
        b=U9p2yYrewEzjAeRYxmGclFU9XomH+q7e8nktR9z5aXb/085wm6i7Ao0F1GnH0F0SW7
         yGGzda6c/g2E7hFt7pUjSLHCnDCqYwSmxNs551eB0L+XbTlTs+IEDMCAirF6hYXEzGWY
         Ghta7ewh5OE3OyJShPDylcW1AHJ2KrM6pSgBxJIXt3O7rf5wHF3fUMi4L0cGLtLBwJPJ
         kh2VSgMWZJsTXaVRxa0HGT7cH4hY7pwUaceBomriGUPL4IaXd09xAT/OqOJvgGd0Xb21
         Sd+3C1F+KJ6D4DG72iJHZ6PiMk945ClW5Dryp6KxeQAfKA7VhCjcKp55pNbEf+h3/MrC
         +y9w==
X-Gm-Message-State: APjAAAWkogUeHZBQKeOJQ4Jp6HOoRkg++v9b3bOP7zg+jJi7eddvQ0LR
	El8RNTvEo8yqauBmoF/NI43R/zlMaikjS44XysfHOnLU4PYbUwx9YStTFBxfMqyLuRDqzqM/eLn
	RLdcwC5OtsSik/Cwl8VbedMLTNm8AQSF2gslRF/DX21AiD+luAkNvlejvkKM7EdTEog==
X-Received: by 2002:a25:738f:: with SMTP id o137mr7050133ybc.438.1561161426155;
        Fri, 21 Jun 2019 16:57:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy6U4bw8XoUv9G72RLpOEVTbssvoWGnCnC7Tczx5iJKa3d392Q4S3hNEwKLbn9HQ0plIKCO
X-Received: by 2002:a25:738f:: with SMTP id o137mr7050118ybc.438.1561161425534;
        Fri, 21 Jun 2019 16:57:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561161425; cv=none;
        d=google.com; s=arc-20160816;
        b=ShKtTap9L14m1fPd1PUDw8GMvj41San0tT/SdgU07eQZUKmbtLAn1XIgfPxMVHyh/l
         gSwm+GfT+m3fhpzozuSIlmpyf+EVdf7JYm5RbCtRJ+ouLlv72bdE8TyDt1g81kk30dCg
         3Z1+i5I9ZNP6S3jN8jk7DHM1V+c3k6kmArXsMrEabV72xvBvrsRKUJOB+jPIHchEm61z
         hU8Xw1vdvI3WfwLWVVIZt1MK2Wc5Qb+3wcsp58eEk5sGgMSVQ1UpLgHysCVJr2fXlV56
         KRzN4hMgPX0v1AZBBXQoIyB+0GkqxJcaUVIfHdLDRYqvh4RXApxhkgIFicuRS8nIMSnu
         OL/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:message-id:date
         :cc:to:from:subject:dkim-signature;
        bh=fawPQY/UISfSH6DvrztcWabWXm47TtXieQJWSELxOKQ=;
        b=YSDpBs9lmZ2iqxRFkCTcTblsfgaCx1vFCn1w7oxIP4KeHj8OjOXKSW/WynGmEh3UXT
         rYrT7K1rpWE8VK6EyRRTK84bYviOoaGXdlyQMaj9oIWHOBuXCxRg/fenUNl+zT1DLcbf
         4aEjH6Dv9RSRWbaTlH5lfFxK+GqQU9Faczdad4SYQFXHuqCywYCG4C0TMIKWcLqX/RTu
         TZZoxrwtLwFsKwsYB95YcaQSVnIqr+hzXRDcwne9OoxUBIEa8eoTsLgrzmcuKZ0OrarT
         W5VcjqdbpAoFhRuTItlpzlhOIun+Eu+hzyGyDk4VfvRCY4LBCHQx6JZkOtw2P0AiQ8ZH
         uy1Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=VYwNeL6i;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id o145si1476120ywo.346.2019.06.21.16.57.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 16:57:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=VYwNeL6i;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5LNt5Xd059348;
	Fri, 21 Jun 2019 23:56:58 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : date : message-id : mime-version : content-type :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=fawPQY/UISfSH6DvrztcWabWXm47TtXieQJWSELxOKQ=;
 b=VYwNeL6ibPXVTEVoRkPUTgHJCT2wzrlt5vhgzdSSWt3OQjBNDlvSlcMAel/+5/qiR1of
 h2fH3k9W374Ek5nhUZh18oW2OLVU8FOtFCEtIVH579hK6M1M54/APh5/t3SUPGKy7t9V
 zr4flVMsY+8M+/9Er2kArmiUZJYRUJeMUa6Z3FeKdWFkw5uKS18otDCNc6AjwWI6ftkm
 Qf7O4LpTTnOL9WPw64vBXu6TFLd4bcXU3WYyHNH2O8UezLzZ+yDrtb1pzL64XMboTNNv
 P0vzfKCxcw4dY1NwEQj5N4JcCQ2pFTiMWGgyRXLO/ijggAoaKJ7wtQ0X968LtP9NJ5HD 2A== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2120.oracle.com with ESMTP id 2t7809rqup-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 21 Jun 2019 23:56:57 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5LNtKaA167994;
	Fri, 21 Jun 2019 23:56:57 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by aserp3030.oracle.com with ESMTP id 2t7rdy0604-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Fri, 21 Jun 2019 23:56:57 +0000
Received: from aserp3030.oracle.com (aserp3030.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x5LNuue9170472;
	Fri, 21 Jun 2019 23:56:56 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3030.oracle.com with ESMTP id 2t7rdy05yy-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 21 Jun 2019 23:56:56 +0000
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5LNurk8019074;
	Fri, 21 Jun 2019 23:56:53 GMT
Received: from localhost (/10.159.131.214)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 21 Jun 2019 16:56:53 -0700
Subject: [PATCH v4 0/7] vfs: make immutable files actually immutable
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
Date: Fri, 21 Jun 2019 16:56:50 -0700
Message-ID: <156116141046.1664939.11424021489724835645.stgit@magnolia>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9295 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906210182
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

I also discovered that userspace programs can write and create writable
memory mappings to active swap files.  This is extremely bad because
this allows anyone with write privileges to corrupt system memory.  The
final patch in this series closes off that hole, at least for swap
files.

If you're going to start using this mess, you probably ought to just
pull from my git trees, which are linked below.

This has been lightly tested with fstests.  Enjoy!
Comments and questions are, as always, welcome.

--D

kernel git tree:
https://git.kernel.org/cgit/linux/kernel/git/djwong/xfs-linux.git/log/?h=immutable-files

fstests git tree:
https://git.kernel.org/cgit/linux/kernel/git/djwong/xfstests-dev.git/log/?h=immutable-files

