Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 388D8C282CE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 05:57:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1F4F20870
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 05:57:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="WYgqC6pB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1F4F20870
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 50D676B0285; Mon,  8 Apr 2019 01:57:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4BD5E6B0286; Mon,  8 Apr 2019 01:57:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3ADFA6B0287; Mon,  8 Apr 2019 01:57:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1930C6B0285
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 01:57:10 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id n10so11835818qtk.9
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 22:57:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=wQX1rb1k/cm4XL6b3IKZuKbRnlB1j5P4QIaPgjZ0cxA=;
        b=QF2Hl2MDKX11Ny146iFLZ1bi0rQKYX7AWpdLm/Kt+dnNct1iD6+RaTUytXE/7B4JjC
         O9pT6jzkXqe8CDGtQHWcit/IqOwYGmKDatxIzCuLigCHXCFtkHIYI+Uiz618AhOAtevA
         avwC2DbzkZf+/Jy35CyFJfnFSIDYD2bvQ9H0gBNS/XjMvChEjgtjLEHdRkXZP2dGkBmK
         5NQT6xcqp24A+ASqwweUFlhVVttyncx2rbLBodzfjRJr/0clQWJNDHCG7uDcbU1sjv6Z
         p9Xh++0CR+2WOYqT1bLLfkOYfObYnyezVZMIQa6+6SPyeMNhnBQuSmOjasVKZhq8yqBA
         VpKw==
X-Gm-Message-State: APjAAAXi2JwDP2HZykk/XkJvkaqB4Mb6YHh4dITLPipivRQxDuHbI9uu
	HKJ4sKaeaY09mNpsLiWhPsLBIu78JBDQ07KkIJ+7rvD03jxPHzYwI8SKmruUYa+YJw9J2i8CbAw
	GvQavLeicV1+pxFyg1ZtU/6dtZWVjXIsBxaWHFeCwwhRfPCceLVfx8KTiZCQh4vAUXA==
X-Received: by 2002:a05:620a:103c:: with SMTP id a28mr20338160qkk.284.1554703029817;
        Sun, 07 Apr 2019 22:57:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzgEE+6RzZoyxIbEuvefsXZQ+9SBJ30wobuVh4e/7H+lZW2ujQ3EnhS70/pvBOHJ3YA6M6S
X-Received: by 2002:a05:620a:103c:: with SMTP id a28mr20338137qkk.284.1554703029246;
        Sun, 07 Apr 2019 22:57:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554703029; cv=none;
        d=google.com; s=arc-20160816;
        b=S6+NOYdHuf3vQYD28ujn6hUPPoIK3qgD9NV74CS7UmQGZmKgvvGHo5Ej5K40hY9wZU
         e8IzJlEBSiZwofUxeX53hZHFK05AbLgif0dHmnyFf9hbmgY56lEqTBe/5g6FGVQsd8bv
         bH0Bx6fRmOYDGbp0mQO1hfunwuBN6SwRGM7j12hUmWDrynPifq8FtLT7fPoX4WZrrPgy
         /gVctoofBYsfuW4BA7wuCK1EINdSsF3W+9rEGfu3buau086b2hnzY5tuXgO7b4j9S/8M
         /p17CEUXPWh0XuQL7it5S/Q+ZFOcU0vKulKPNQaq/xnQETUUQrOF7xej67TjJUhG+TA5
         Z66A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=wQX1rb1k/cm4XL6b3IKZuKbRnlB1j5P4QIaPgjZ0cxA=;
        b=r4eqSbcQ6cMF5O/+X3q5Ej+vwU7tZk5WZtq3h4/Bok+/CI3jLX8OsHzrteLigY/FFm
         qjoS9gLD3DOGNf9CW3LgOuWsI5SBVrXacq1Ent5OjWJxBBiR2NSJ4KWZCdVRvLfU7StP
         hqjtUnS6skcMtdycvifzcTS3dtzJnsaQhnhPdfXu89rf3Pd6EHY30NEOPvdm0BMkOdWx
         uTPQnslkqHBq7OJmt/wi+/10fvEYQfK+X+zBP1nCTGUWMP/c+jsdKTcDCHV2mvo39tzq
         aNfO6dwNYHD44FNdOWDCWhCRkgUXCIuUCqrM4VVFbuln7XNpZsusPR/No2m3Q0ORkXtO
         ddGQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=WYgqC6pB;
       spf=pass (google.com: domain of allison.henderson@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=allison.henderson@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id 39si3821772qvt.189.2019.04.07.22.57.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Apr 2019 22:57:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of allison.henderson@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=WYgqC6pB;
       spf=pass (google.com: domain of allison.henderson@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=allison.henderson@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x385sgcb036045;
	Mon, 8 Apr 2019 05:57:08 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=wQX1rb1k/cm4XL6b3IKZuKbRnlB1j5P4QIaPgjZ0cxA=;
 b=WYgqC6pBPZUdvrMsxum++NTrKTxuFp/EcVWgRRGMKyAHjUhRVfD0ajXEie5Rf+9Gr/3x
 a11/1rH8/xmwcC4w753/o91DrpOACSZW1cKSyMJY3gZFdUUX8Y7/PQ4/Rw9nZ9+f2VMg
 Vfn+I+IwlTqD5LDMdONbWYcG6Lc9DPPngZfGj5hDV7MihFCCc+NTlibIbtiL1jK7lI2K
 FeEQhTgnaKDrWHpz9oc/8EiHVdW4xcglzM1vNsBEnErchJ4U5t9xjNJkhC1MFuo4qqbn
 6nMoBJhAEwyhCFqbeykYtxFwlk3s4dkuIP/PkyPFaq93HMCJQBrPtr//22kSWjldMugG yw== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2130.oracle.com with ESMTP id 2rphme47y6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 08 Apr 2019 05:57:07 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x385tTlo045835;
	Mon, 8 Apr 2019 05:57:07 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3030.oracle.com with ESMTP id 2rpj59t7b8-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 08 Apr 2019 05:57:07 +0000
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x385v7LK001151;
	Mon, 8 Apr 2019 05:57:07 GMT
Received: from [192.168.1.226] (/70.176.225.12)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Sun, 07 Apr 2019 22:57:06 -0700
Subject: Re: [PATCH 4/4] xfs: don't allow most setxattr to immutable files
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: david@fromorbit.com, linux-xfs@vger.kernel.org, linux-mm@kvack.org,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-btrfs@vger.kernel.org
References: <155466882175.633834.15261194784129614735.stgit@magnolia>
 <155466884962.633834.14320700092446721044.stgit@magnolia>
From: Allison Henderson <allison.henderson@oracle.com>
Message-ID: <4b6985a9-a386-90e9-63b4-b906d2cb216a@oracle.com>
Date: Sun, 7 Apr 2019 22:57:05 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <155466884962.633834.14320700092446721044.stgit@magnolia>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9220 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904080054
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9220 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904080054
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Looks ok:
Reviewed-by: Allison Henderson <allison.henderson@oracle.com>

On 4/7/19 1:27 PM, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> The chattr manpage has this to say about immutable files:
> 
> "A file with the 'i' attribute cannot be modified: it cannot be deleted
> or renamed, no link can be created to this file, most of the file's
> metadata can not be modified, and the file can not be opened in write
> mode."
> 
> However, we don't actually check the immutable flag in the setattr code,
> which means that we can update project ids and extent size hints on
> supposedly immutable files.  Therefore, reject a setattr call on an
> immutable file except for the case where we're trying to unset
> IMMUTABLE.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> ---
>   fs/xfs/xfs_ioctl.c |    8 ++++++++
>   1 file changed, 8 insertions(+)
> 
> 
> diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
> index 5a1b96dad901..1215713d7814 100644
> --- a/fs/xfs/xfs_ioctl.c
> +++ b/fs/xfs/xfs_ioctl.c
> @@ -1061,6 +1061,14 @@ xfs_ioctl_setattr_xflags(
>   	    !capable(CAP_LINUX_IMMUTABLE))
>   		return -EPERM;
>   
> +	/*
> +	 * If immutable is set and we are not clearing it, we're not allowed
> +	 * to change anything else in the inode.
> +	 */
> +	if ((ip->i_d.di_flags & XFS_DIFLAG_IMMUTABLE) &&
> +	    (fa->fsx_xflags & FS_XFLAG_IMMUTABLE))
> +		return -EPERM;
> +
>   	/* diflags2 only valid for v3 inodes. */
>   	di_flags2 = xfs_flags2diflags2(ip, fa->fsx_xflags);
>   	if (di_flags2 && ip->i_d.di_version < 3)
> 

