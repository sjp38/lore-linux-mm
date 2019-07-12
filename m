Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5FE2C742D2
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 17:50:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BDE0204FD
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 17:50:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="PKj2zHQb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BDE0204FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 06D308E0162; Fri, 12 Jul 2019 13:50:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01B618E0003; Fri, 12 Jul 2019 13:50:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DFF298E0162; Fri, 12 Jul 2019 13:50:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id B74918E0003
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 13:50:57 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id b85so4239886vke.22
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 10:50:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=ttLP7k6LnQunc74kkiwUZeNR1lEb3Y0sGTeUpabWr0I=;
        b=Z2wicE+uZJZsoFAKnxJRTG8HG1OvAMEV9uks5rca4aJLhCsFTD+TWDQTzXk6mXiOFd
         LmchivhVW6xEkZHYZNprEVBIxCv/nIKL+1hO81Tzy226Ax9o+0IrpjbOSSnwl7ClDR/I
         8guxNImtyYpr20fShtr0aALM2ikpYW56S7USQ6hKiqZw43INAtWxc+bWZ7gwYU/4f4KT
         tthk/P4ri/qOUmWp9hRZvZ35WIVQAYge0MYh7I/kKOiqYf+aEe158xDtsKU8ByJMa4pl
         zxe9xjNBK0aVyF+XYqNM4SOBDCc6yPg/z+Ym/QNw+S8o2yO/C2VKpvkuiXT2iLCVFTKk
         l9gw==
X-Gm-Message-State: APjAAAVsRSqpbkrQnhUAAu213DNxIXlWTIKsbU+nSIyHTmAT8Mnqbwve
	iGgoOg/r1vBcqwDJcR9qQsOBzJgZIslxzJFf6e/gSII40J361tZA152JLFjJLt//O+lCQwaWGu/
	DgYDMoYT6fXo1dKZJIb1c4q54Qkf1kC5mesOaPz5VmNhK+GR/wwW6pJyo7wfdFUF+dw==
X-Received: by 2002:ab0:614d:: with SMTP id w13mr9083252uan.66.1562953857289;
        Fri, 12 Jul 2019 10:50:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxXVQp6IUSoKg6AeFq3kHa8oMK78AFzyevlKxQtLgm6bn8N35M4tsBiZ4dFwkfP/m4cSyqT
X-Received: by 2002:ab0:614d:: with SMTP id w13mr9083225uan.66.1562953856773;
        Fri, 12 Jul 2019 10:50:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562953856; cv=none;
        d=google.com; s=arc-20160816;
        b=caJjg78VsLcsOvpCZJ2sW8b//uKfmnbBaIyGfLJ3oqiWS34T0lUEMvaccw6Izzy6bT
         CcLnfE+IUvK2lIHgi/o9V49rSquqyx7WKR5kslg7u6ucTq7arAuVw5gJ9QrcDAbblApH
         AiPuKd5ZgcJ5JdIijIXu4mEnqXi8JVXrH48H9EVSCceNmoVCPtJt8Z9Z+2EAZ17Kff7e
         RpkOE4ZSDYP6tC6tu1qD+9MjMkKN8rZQLjd+zzDdAdHmzOMAUpTvyvdvNSnW2yVNHQY/
         H7Y8fNUyBHi5XZ6w17qKxdvJK/y+/xAY4YQ6x0IhmGCS26zyOuoVnMfnJqlQGlxRekug
         U//w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=ttLP7k6LnQunc74kkiwUZeNR1lEb3Y0sGTeUpabWr0I=;
        b=p5y3Wkmp7l05IWucbx9PIa2Hmaj2XeZAuE3I8hHSbbHVJlMuKTwLt0V7nO335R+RJU
         I2CKRI2UUx3dKxP9dmUxUFSKG6wPg4mF9zWZSNJBMB8byB9gFdO48e0OQxzV5SAG9pHe
         L0q6sJ6osh7N6hctcYeawmWs0Ps0JWL/GLhov6jbzI1VnPDG2oHI17bp8u/x6m+EK0SV
         CVmsOdPd7YLfJ+ku3rR/LgmR3CeUVY4qLzjro16iVRGdrvDv0v4jnWmlJl+atlVtzO1a
         /k2x8GZQEUFq/VsW9WD7qhrYWOp4bh+rncixxAwdPLrqezbkZ9wL8yQeq/d8S/Gmd7Tn
         U/jw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=PKj2zHQb;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id m9si2666320uaq.69.2019.07.12.10.50.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 10:50:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=PKj2zHQb;
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6CHiQUo182558;
	Fri, 12 Jul 2019 17:50:54 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=ttLP7k6LnQunc74kkiwUZeNR1lEb3Y0sGTeUpabWr0I=;
 b=PKj2zHQbTQcG3FiOlWudYS4C1QKpDC4EWtBtcI+eiGu8hNFd01ee4AV0dhdHrkQlFo+0
 I7HJh8gyiH8MyjA0K+zA9NySz17GMEcjDYX3D6Q0HSfxXFUxlqACLBpmTiIau0tdBUK6
 Bl9PNEUXrGQPoNDPmOvbceMvWnn8kn8jCoP4mG8UWm67b9dJNAU3NLE8opploNKXL+4r
 WegsU2vPTBCcGW2ee5eeJ4csDG9Y2MryuvrBWGz84L5D8KZ3eoSxxPk2+Uq62ZMHMlTa
 O1xZZxGk9qJK72kNfnMHgXUrj9iYzNnmty75QDfoMTOxFfmeF1kuPWdmcBhYnVEdMYGV eA== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by aserp2120.oracle.com with ESMTP id 2tjkkq6xjq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 12 Jul 2019 17:50:54 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6CHlsHr123708;
	Fri, 12 Jul 2019 17:50:54 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3020.oracle.com with ESMTP id 2tpefd7h4v-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 12 Jul 2019 17:50:54 +0000
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x6CHorrW009828;
	Fri, 12 Jul 2019 17:50:53 GMT
Received: from localhost (/10.159.245.178)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 12 Jul 2019 10:50:53 -0700
Date: Fri, 12 Jul 2019 10:50:52 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org,
        linux-xfs@vger.kernel.org, Amir Goldstein <amir73il@gmail.com>,
        Boaz Harrosh <boaz@plexistor.com>, stable@vger.kernel.org
Subject: Re: [PATCH 2/3] fs: Export generic_fadvise()
Message-ID: <20190712175052.GZ1404256@magnolia>
References: <20190711140012.1671-1-jack@suse.cz>
 <20190711140012.1671-3-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190711140012.1671-3-jack@suse.cz>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9316 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1907120180
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9316 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907120180
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 11, 2019 at 04:00:11PM +0200, Jan Kara wrote:
> Filesystems will need to call this function from their fadvise handlers.
> 
> CC: stable@vger.kernel.org # Needed by "xfs: Fix stale data exposure when
> 					readahead races with hole punch"
> Signed-off-by: Jan Kara <jack@suse.cz>

Looks ok,
Reviewed-by: Darrick J. Wong <darrick.wong@oracle.com>

--D

> ---
>  include/linux/fs.h | 2 ++
>  mm/fadvise.c       | 4 ++--
>  2 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index f7fdfe93e25d..2666862ff00d 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -3536,6 +3536,8 @@ extern void inode_nohighmem(struct inode *inode);
>  /* mm/fadvise.c */
>  extern int vfs_fadvise(struct file *file, loff_t offset, loff_t len,
>  		       int advice);
> +extern int generic_fadvise(struct file *file, loff_t offset, loff_t len,
> +			   int advice);
>  
>  #if defined(CONFIG_IO_URING)
>  extern struct sock *io_uring_get_socket(struct file *file);
> diff --git a/mm/fadvise.c b/mm/fadvise.c
> index 467bcd032037..4f17c83db575 100644
> --- a/mm/fadvise.c
> +++ b/mm/fadvise.c
> @@ -27,8 +27,7 @@
>   * deactivate the pages and clear PG_Referenced.
>   */
>  
> -static int generic_fadvise(struct file *file, loff_t offset, loff_t len,
> -			   int advice)
> +int generic_fadvise(struct file *file, loff_t offset, loff_t len, int advice)
>  {
>  	struct inode *inode;
>  	struct address_space *mapping;
> @@ -178,6 +177,7 @@ static int generic_fadvise(struct file *file, loff_t offset, loff_t len,
>  	}
>  	return 0;
>  }
> +EXPORT_SYMBOL(generic_fadvise);
>  
>  int vfs_fadvise(struct file *file, loff_t offset, loff_t len, int advice)
>  {
> -- 
> 2.16.4
> 

