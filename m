Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56800C282CE
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 05:48:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EBE7C2083E
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 05:48:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="30i86vTV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EBE7C2083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F50D6B0281; Mon,  8 Apr 2019 01:48:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A7816B0282; Mon,  8 Apr 2019 01:48:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 893EA6B0283; Mon,  8 Apr 2019 01:48:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 52EEB6B0281
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 01:48:15 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id m35so6593071pgl.6
        for <linux-mm@kvack.org>; Sun, 07 Apr 2019 22:48:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=bpcuepE/sfIV6VxX60D/u4EXmRumruXZ3zEG1txNU3I=;
        b=XsDGWCn3vmbMJiqxKNpqU87RVfouFaCgbAQgtYKrV6c93yVeluxh4htXwDoXYhvPc0
         CiIKFrv7V1Cm5DT4gRBdgvkeH/WEOdBBgwpAao2P26tQlRv/ZIBVpiEB0vgjXcVPDOqq
         MmboYyA49Y/MnnL148hXS2CQLpQvXldVOH8mzf6Iu+u8/yQPG+84NXdSGJrx7QCV+8Hr
         kdzF6c+qlLPlfVCGfSNSFVlFGPb7pgBmrZ646TA5BTQ/jQPYyep29jCrYnGOL2Ngg7ZW
         nWFjMDqP4NS0r+tuCR/YIg2TBy4nF4ir4C98DgB2dzzievaRtgvCXUrtp0P1hLwiKl1p
         Cf9w==
X-Gm-Message-State: APjAAAWYsmR+gYCGNzN4tOYOlle53fVuyHuLnX7hxXwvHg5qNAPkHbJ7
	4FYtdvVjJX2Ll+DM8RqwLxZS6sz+xCwr2sCufIykh92vzHMd3J3BNrDBp3MfqTksX8bf/GeIKU4
	+CvqlGGRcAkQIDHmJtGIqoaxBfBsNUcjJW/2sPos+PyE+TNZE1HDqp1qDQ4yZK+SpcA==
X-Received: by 2002:a63:1a42:: with SMTP id a2mr25379697pgm.358.1554702494732;
        Sun, 07 Apr 2019 22:48:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxWZI75NWBmf3jZQU3PqoyXB2ZQ5oepZqrsUEGOKAP0SYHLMyvTu0zCmBUEmLxRZoBWPOjA
X-Received: by 2002:a63:1a42:: with SMTP id a2mr25379662pgm.358.1554702494081;
        Sun, 07 Apr 2019 22:48:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554702494; cv=none;
        d=google.com; s=arc-20160816;
        b=ZVn2Ll6nvoi+nhFOIa+p1Yzfo2IfFE20sJEa4k3XcBDmq7v85hBX2yD/iDxqN0f+Mi
         9YNPmoMLvTJSCz1N0SNOpIuOEFE5mvux7tUcQS58mo41yL3hHbEL8QAvu8jJa8ifpid+
         nGpEiXTtdoMnMpFmIAvVcGyhHl/kCuXctx9ZWkzEaS9A+rnj1b2wWSSqPPKxSEgoqC16
         pxTutt6J0trXOkgk8Z5HhW+ttLcWArhm5ns31D6FjZwigBdoZh1ZN1s+PE4oSGmOpmMZ
         mNhJRXSAkB/5p0pEpKtAygtD7+axwArenjobnX3XOn0LlGrQ+Pode9bWJLNZv4Ho5EWs
         icVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=bpcuepE/sfIV6VxX60D/u4EXmRumruXZ3zEG1txNU3I=;
        b=khne0FzpVZ05X+XvqRWobfP5+g7yewqxBkxCzPNHgaGk4NvyEnbx8pkZtS0PJoqowq
         TQrAOeXlm9vbYGz1OVNja6SOBb2YF28+uN/1KR1NGqtMSA9QJB1yD54xii7iVQeT/6Bl
         /HZhx0DddsHbL0x9qhiiyQ53xLTcUCF+gkx8VsCATvFv2U3UmfS7UWj8jDx8f8T/EnMw
         kXb5nNXkSPTyHzvlci+o98fAAQTX1+TzpEQLPGv1uh2byySugIUgQrSBPQvrll7b6VOE
         OwcdM6Mmam2HixIeEPB+EisGE9mVYEfXabEJusMNPHyE3YGrmXhnkOayM1ls9PxMt7dj
         DNpg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=30i86vTV;
       spf=pass (google.com: domain of allison.henderson@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=allison.henderson@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id h18si24338615pgj.47.2019.04.07.22.48.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Apr 2019 22:48:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of allison.henderson@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=30i86vTV;
       spf=pass (google.com: domain of allison.henderson@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=allison.henderson@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x385j7K2029199;
	Mon, 8 Apr 2019 05:48:12 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=bpcuepE/sfIV6VxX60D/u4EXmRumruXZ3zEG1txNU3I=;
 b=30i86vTVEq41DvWWanxQ8FW/uYKKDx66FJGDxxoW4aFDRe5we8JZ0rzygzPZj4D9cL62
 E57dMgVRrUPBeDyFP4IuRfVfHNBjZUIwkolwS5MPsqmXFCyq8AVGxhI+7wfAar4C4IfG
 CZU4SYSsCP21w0VFeaAA9Ftvs4/8ZiKkrX1JCXNSlysx2Qlayy0UNgW2W2iF73nG7qF7
 /3TeI35xkV92TbFIpeecDjX15m/PCgYIl/3vB48R4hYDfgyn5E0jBk7/NwmX/UPVb+hB
 o0/yIW+0UCkZsOmzA9YYYpuTfLtILVy6bDgpgKdS5P7FAC5EJDbR5XjHFNxoBQz08U3J sA== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by aserp2130.oracle.com with ESMTP id 2rphme4704-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 08 Apr 2019 05:48:12 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x385lu2B065606;
	Mon, 8 Apr 2019 05:48:12 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3020.oracle.com with ESMTP id 2rpytauxne-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 08 Apr 2019 05:48:12 +0000
Received: from abhmp0016.oracle.com (abhmp0016.oracle.com [141.146.116.22])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x385mADI028198;
	Mon, 8 Apr 2019 05:48:10 GMT
Received: from [192.168.1.226] (/70.176.225.12)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Sun, 07 Apr 2019 22:48:10 -0700
Subject: Re: [PATCH 2/4] xfs: unlock inode when xfs_ioctl_setattr_get_trans
 can't get transaction
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: david@fromorbit.com, linux-xfs@vger.kernel.org, linux-mm@kvack.org,
        linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-btrfs@vger.kernel.org
References: <155466882175.633834.15261194784129614735.stgit@magnolia>
 <155466883603.633834.5683596746694707981.stgit@magnolia>
From: Allison Henderson <allison.henderson@oracle.com>
Message-ID: <0342fa7f-23f3-2acf-f40f-c485e66d4762@oracle.com>
Date: Sun, 7 Apr 2019 22:48:08 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <155466883603.633834.5683596746694707981.stgit@magnolia>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9220 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904080053
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9220 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904080053
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000231, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Looks ok:
Reviewed-by: Allison Henderson <allison.henderson@oracle.com>

On 4/7/19 1:27 PM, Darrick J. Wong wrote:
> From: Darrick J. Wong <darrick.wong@oracle.com>
> 
> We passed an inode into xfs_ioctl_setattr_get_trans with join_flags
> indicating which locks are held on that inode.  If we can't allocate a
> transaction then we need to unlock the inode before we bail out.
> 
> Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> ---
>   fs/xfs/xfs_ioctl.c |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> 
> diff --git a/fs/xfs/xfs_ioctl.c b/fs/xfs/xfs_ioctl.c
> index 6ecdbb3af7de..91938c4f3c67 100644
> --- a/fs/xfs/xfs_ioctl.c
> +++ b/fs/xfs/xfs_ioctl.c
> @@ -1142,7 +1142,7 @@ xfs_ioctl_setattr_get_trans(
>   
>   	error = xfs_trans_alloc(mp, &M_RES(mp)->tr_ichange, 0, 0, 0, &tp);
>   	if (error)
> -		return ERR_PTR(error);
> +		goto out_unlock;
>   
>   	xfs_ilock(ip, XFS_ILOCK_EXCL);
>   	xfs_trans_ijoin(tp, ip, XFS_ILOCK_EXCL | join_flags);
> 

