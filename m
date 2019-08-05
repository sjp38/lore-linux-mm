Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 384FEC19759
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 00:27:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE8082086D
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 00:27:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="UxnSsely"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE8082086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C8556B026C; Sun,  4 Aug 2019 20:27:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 278B56B026E; Sun,  4 Aug 2019 20:27:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 168166B026F; Sun,  4 Aug 2019 20:27:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f71.google.com (mail-ua1-f71.google.com [209.85.222.71])
	by kanga.kvack.org (Postfix) with ESMTP id E1D626B026C
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 20:27:44 -0400 (EDT)
Received: by mail-ua1-f71.google.com with SMTP id s1so7931360uao.2
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 17:27:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:cc:subject:to:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=csR1CFI12mg4Wfl/I1DmedWmi55eZjSHDbam/aE57Lg=;
        b=fFroOef51GSQk7REnuGgOjExd2suRTnU0qKt9fIERP4/bHBgXJoLP/Y2JEsdv9+S7n
         GQz2IuPHkcpwTpYjjSe9JEu5V0R912+GgiRQ1mgAr8TjS7laoh/3wAL5+SDFi8NXYohP
         DYP/BXci9FbpMtfTjwCxrYBMveCH5cxxIBOvZjioXPRW3Xf7pxIEcgRnY+WqCYCUiJLY
         SYw67L4vujZdKtbEjpyJRpxKjN/BmefPS+ACERwQhb4YMy3My4llS/yW8uuYMr1Z5BZg
         r0OZGkAK+yNvSVa3Wcrb72YOcuK/Yg4f7R18mc2tHJ/jrYgBbBuQqi4kJ18UEc2PNKJF
         0HFQ==
X-Gm-Message-State: APjAAAXKummXvcJCUiu5crjI5Qb7BrVa+wARUIBggn84sUcPTUEUjq8w
	XOlLXy+pisgh+zqwmcIWI216vSCgt+RPLkObvJAA0XwMds1VQrE1Zu1Vs63lMTPFAC7txucHX+d
	HA9PAlXoQZtWKZvXWMNa38Qm8N4jS8ec+YXn9y1P/af863PFZi6rhK/2uJPCQSVcILA==
X-Received: by 2002:a9f:230c:: with SMTP id 12mr22512981uae.85.1564964864581;
        Sun, 04 Aug 2019 17:27:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzBOuR6+57a0HqQgrR+eSFnamx2k7hrwutmSSwo/YfvUdUjQeYuCYmkR1rg/aBrDKCoiVHk
X-Received: by 2002:a9f:230c:: with SMTP id 12mr22512968uae.85.1564964863871;
        Sun, 04 Aug 2019 17:27:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564964863; cv=none;
        d=google.com; s=arc-20160816;
        b=iJJuGQiHgm7yZBKIiG/8bGtNGuS7P26sXsdZxuU9zo5u7NmEJ+qUyt9XZoJkMLTwEg
         HKNsnd450Yalt7gRPOuVgRBuDNYbhoj5nYAqiOFXYtqcvnJP1zRW2Mf16PhaVZuR+VEn
         +xtMyPXmLZJu7dgP/WXeWmFomegkRyuMC2OeXjXKtXdLbIoRslN2jETah8KtM3CFEezY
         WE/24ZE38fmRSPAbPdipzFjfwAuhOWZtM6R6RKHFcWtXF8BulMTqV7A4CnmWS74ezy/e
         kPLbq4BwKbqqE4fekLdO08ohsuTpHu65fBgGpHTaykwWYyAYso4UIzPSGZc3EMakGUMs
         n6qQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:to:subject
         :cc:dkim-signature;
        bh=csR1CFI12mg4Wfl/I1DmedWmi55eZjSHDbam/aE57Lg=;
        b=Tp1eVPOx0+SGCzl4PpBMu8yXwA6654hZOXozT5RVV1NXK5iMPMZw2+m4BCJSEyoBhN
         p7CAsbNA7QZrEZvv7FAZD8etMzX1fu5HsAVvkMVy/3F1dpBAKFQH2yFMTFb/FqrfNZ0/
         I+TlKuB8TU5IGkABxQSrwLEcWyybGgsY+dQKzY3v4U9YYFl5bM+OOmoLzNa0muI66/Ha
         +FS366bD0MEdRMHZaeukYJDWMVzPrFG8m8ebMLc0D5/C5rkRpubH5kRP6jvlO7YoSIFY
         RLaI2jM5O8kDn35vrMjmPI7VksQZdMizMgTCMvLNFFVwat0CCSHAo0i5WYNDR5VFdjyA
         NJ2g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=UxnSsely;
       spf=pass (google.com: domain of calum.mackay@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=calum.mackay@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id l16si17154945uao.70.2019.08.04.17.27.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Aug 2019 17:27:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of calum.mackay@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=UxnSsely;
       spf=pass (google.com: domain of calum.mackay@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=calum.mackay@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x750PN8L099080;
	Mon, 5 Aug 2019 00:27:22 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=cc : subject : to :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=csR1CFI12mg4Wfl/I1DmedWmi55eZjSHDbam/aE57Lg=;
 b=UxnSselyJSkDrlgtrJqirrqIgp3f8N92FZdRzvuEzRyV0BK1GmSaf9C8PKnong3YQqHb
 MCpznjeWe33FH9kWSVMHzf3ueNmMrgta/dHNshxU+ezcH/SlcYl3T1BbtssK9RamgmgB
 uxHaAwYQYSv2zhs8xcIQpAvtnAqvLsICBKD/Oi73oWTTrzZCg0llYMmo1CN1xJK1/n6p
 FN3jH23l0bDAY+8rbi5+pi71wYYr59UK7ki0dfZmNagJqJGpCz4Dhc49Z+1r5jDxqopk
 IUz6WPSid5pJVTZGy3yYzlDcCEYZUIldAG3FEELFmfGykxTqdKwI/FpOYaMM05PGsiiD Lg== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by aserp2120.oracle.com with ESMTP id 2u527pc6va-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 05 Aug 2019 00:27:22 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x750Mxa2125660;
	Mon, 5 Aug 2019 00:27:22 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by aserp3020.oracle.com with ESMTP id 2u5232s8j6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Mon, 05 Aug 2019 00:27:22 +0000
Received: from aserp3020.oracle.com (aserp3020.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x750RLrL130645;
	Mon, 5 Aug 2019 00:27:22 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3020.oracle.com with ESMTP id 2u5232s8hy-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 05 Aug 2019 00:27:21 +0000
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x750R78g009479;
	Mon, 5 Aug 2019 00:27:08 GMT
Received: from mbp2018.cdmnet.org (/82.27.120.181)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Sun, 04 Aug 2019 17:27:07 -0700
Cc: Christoph Hellwig <hch@infradead.org>,
        Dan Williams <dan.j.williams@intel.com>,
        Dave Chinner <david@fromorbit.com>,
        Dave Hansen <dave.hansen@linux.intel.com>,
        Ira Weiny <ira.weiny@intel.com>, Jan Kara <jack@suse.cz>,
        Jason Gunthorpe <jgg@ziepe.ca>,
        =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>, amd-gfx@lists.freedesktop.org,
        ceph-devel@vger.kernel.org, devel@driverdev.osuosl.org,
        devel@lists.orangefs.org, dri-devel@lists.freedesktop.org,
        intel-gfx@lists.freedesktop.org, kvm@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-block@vger.kernel.org,
        linux-crypto@vger.kernel.org, linux-fbdev@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-media@vger.kernel.org,
        linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-rdma@vger.kernel.org, linux-rpi-kernel@lists.infradead.org,
        linux-xfs@vger.kernel.org, netdev@vger.kernel.org,
        rds-devel@oss.oracle.com, sparclinux@vger.kernel.org, x86@kernel.org,
        xen-devel@lists.xenproject.org, John Hubbard <jhubbard@nvidia.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: Re: [PATCH v2 31/34] fs/nfs: convert put_page() to put_user_page*()
To: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>
References: <20190804224915.28669-1-jhubbard@nvidia.com>
 <20190804224915.28669-32-jhubbard@nvidia.com>
From: Calum Mackay <calum.mackay@oracle.com>
Organization: Oracle
Message-ID: <cf978e10-facc-ba5b-d7e4-d7fc2c3f7ebc@oracle.com>
Date: Mon, 5 Aug 2019 01:26:59 +0100
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:70.0)
 Gecko/20100101 Thunderbird/70.0a1
MIME-Version: 1.0
In-Reply-To: <20190804224915.28669-32-jhubbard@nvidia.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9339 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908050001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 04/08/2019 11:49 pm, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> For pages that were retained via get_user_pages*(), release those pages
> via the new put_user_page*() routines, instead of via put_page() or
> release_pages().
> 
> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
> ("mm: introduce put_user_page*(), placeholder versions").
> 
> Cc: Calum Mackay <calum.mackay@oracle.com>
> Cc: Trond Myklebust <trond.myklebust@hammerspace.com>
> Cc: Anna Schumaker <anna.schumaker@netapp.com>
> Cc: linux-nfs@vger.kernel.org
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> ---
>   fs/nfs/direct.c | 11 ++---------
>   1 file changed, 2 insertions(+), 9 deletions(-)

Reviewed-by: Calum Mackay <calum.mackay@oracle.com>


> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index 0cb442406168..c0c1b9f2c069 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -276,13 +276,6 @@ ssize_t nfs_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
>   	return nfs_file_direct_write(iocb, iter);
>   }
>   
> -static void nfs_direct_release_pages(struct page **pages, unsigned int npages)
> -{
> -	unsigned int i;
> -	for (i = 0; i < npages; i++)
> -		put_page(pages[i]);
> -}
> -
>   void nfs_init_cinfo_from_dreq(struct nfs_commit_info *cinfo,
>   			      struct nfs_direct_req *dreq)
>   {
> @@ -512,7 +505,7 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
>   			pos += req_len;
>   			dreq->bytes_left -= req_len;
>   		}
> -		nfs_direct_release_pages(pagevec, npages);
> +		put_user_pages(pagevec, npages);
>   		kvfree(pagevec);
>   		if (result < 0)
>   			break;
> @@ -935,7 +928,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
>   			pos += req_len;
>   			dreq->bytes_left -= req_len;
>   		}
> -		nfs_direct_release_pages(pagevec, npages);
> +		put_user_pages(pagevec, npages);
>   		kvfree(pagevec);
>   		if (result < 0)
>   			break;
> 

