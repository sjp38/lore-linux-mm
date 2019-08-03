Return-Path: <SRS0=U/7Q=V7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 651D5C0650F
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 01:30:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E97252087E
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 01:30:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="2UsMaGPW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E97252087E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C90B6B0003; Fri,  2 Aug 2019 21:30:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A0736B0005; Fri,  2 Aug 2019 21:30:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 38E1D6B0006; Fri,  2 Aug 2019 21:30:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 174B46B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 21:30:35 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id v1so16325521qkf.21
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 18:30:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:cc:subject:to:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=PzG5W+xMCPCqX5V/WwOxL0iZTAvQCXHlqgOKkoOg1MQ=;
        b=AiUKmZ+dTKc4omeYP9dgAADqJ8Uym7az/JEgFkSZNPXeIKxcjQ28afzVHSmECdg5Gb
         gICYt80r7VQVI6wu47Hn0AzuIG3wkG80zflJ0izqYOhoWv+BNbAffkDCvkN/zjKw3l2A
         mrA5oKb5Bk55iL7clqZ7ATgoruw+YK6A7lboT6h6J78LDDnmM3aciT2X5b1Gsxz7ohMG
         1KnwhZ3ZOGux7qBKykc/93vZB+fH3wHUu7NQw+pLO5UZS2v/A2Coz691J+er6WkPW07H
         DRET5x0a8v3wsC+bagpoASpeypRGH9C8/oYyLSdL+rJtlR4uGFIlAU7NxxKxfMA/qsVE
         LAQg==
X-Gm-Message-State: APjAAAWtMUyHqKN3tPru58wxLDg+sCKm5qHaar8YlbfuAlXE0t2k6STd
	4HtEfKlPmWni0rZLk86syG38N3OTESgdfLk7F1rzZ9Ag9yNUJjg9TVzv1x+QHjqB38TVuF3va/l
	y/MagRICgFKkf9WUGWYIiSr8I4qI5uCgYe3teR4V2sq7KMZhBbgE4AAZdxMrSdw+Vig==
X-Received: by 2002:a37:a152:: with SMTP id k79mr90114081qke.411.1564795834706;
        Fri, 02 Aug 2019 18:30:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwuQJeFMjGnK3GyNold+yT8sshgVMQpmIQ1Cm8JrugDc2zxawA+4Pqn+fD1rZ6hX4gSECRQ
X-Received: by 2002:a37:a152:: with SMTP id k79mr90114015qke.411.1564795833580;
        Fri, 02 Aug 2019 18:30:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564795833; cv=none;
        d=google.com; s=arc-20160816;
        b=WdWk9Z480K5Ah4h93xNwy+jvg2g8/9mNspvQEvntKi4hI/fnL2FYuKjoxhTp+YU4k3
         Zh580Ty0PWlfj2fzCErvLHssGrteW6WrABcETFtzuj1mpIbcHK3+I0fYVBJrbbLC9ZNy
         bsDup5NQnto1iO2OVwWichQj7qmdH3jLOdtpaVR84wO1QLSgVb/oIY3V5W3V6E8btZPl
         +qYspD25XSNh+ew7QMQoEKQ+V783taBWk1RXuzvrfW+dXCmng2ElSUhwNRwdd3AIvMOu
         hAxWS7dVBvOJHjY+dz/OuD97TyS5hr+fgZ493sqZahn2rJvwozN72Ta0ZXoPxHOJ8gU3
         +VaQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:to:subject
         :cc:dkim-signature;
        bh=PzG5W+xMCPCqX5V/WwOxL0iZTAvQCXHlqgOKkoOg1MQ=;
        b=tyy7L7fsxYITGwT/YX6Hkl1sDDaiNtDGLgenXcOQOt0RWydSNl2O/ooLDjOxzy9Icl
         g4LgUeM/ehqDcmzd6vxjHnCsUuYphp8qnD7ix94Rt4lasST0hAaFMYDVFZHuUuPo9LhD
         2owy90pM1t5AmcaEPMJLRjr9l9HtZRL/U4OCdq3K3+1td1COFBa/lUQbuUHWBjSUnoxm
         zgeeGGtX1KYzDvp/CjaVJIzNp+KXOqs4itzfUIBuQa28yF8bgIFSbiOMn8PBriUFCIhU
         vzCrePo383gzEPBahZdtMUe6uBTSOsinI5nMhn3J3TGTyMgqeTvvdnf1imbRXtRBQkBc
         6t7w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=2UsMaGPW;
       spf=pass (google.com: domain of calum.mackay@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=calum.mackay@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id z9si5491718qth.213.2019.08.02.18.30.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 18:30:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of calum.mackay@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=2UsMaGPW;
       spf=pass (google.com: domain of calum.mackay@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=calum.mackay@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x731TjiM041024;
	Sat, 3 Aug 2019 01:30:14 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=cc : subject : to :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=PzG5W+xMCPCqX5V/WwOxL0iZTAvQCXHlqgOKkoOg1MQ=;
 b=2UsMaGPWcwZDgPtPG4vvO4o2+XprVDs5YewZlGJ99NG/oeu5neHqgRolXDdQUDZF8YMI
 IxYI2JZfBcSTSH5fID80qQTk2RWiC2i2+JKhPWGaFknkpOXtRCnVCla7UCXQjDJ07TcC
 Y8zIof10PGpETzEquU4Ep6o2lM98f1fWi0d++c5eyIcbTbo8lM/F3e4I2lqnL2U/DsCA
 8mUjAebH6kYb0xf2V8EwArlSIvwpZUBAi4UxsNctBmeyR2rpJRijKuOrdEc0RMfPWfzX
 anPCkdDrm0pEBpPwYOnfJAsFmVDpXvcG9fkUEJAY/0LPZMTheZ3JVp0D915Q7k5fKIRC kQ== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2120.oracle.com with ESMTP id 2u0f8rn4cg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sat, 03 Aug 2019 01:30:13 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x731SCbQ177888;
	Sat, 3 Aug 2019 01:28:12 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by aserp3030.oracle.com with ESMTP id 2u50aa8apf-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Sat, 03 Aug 2019 01:28:12 +0000
Received: from aserp3030.oracle.com (aserp3030.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x731SC7W177834;
	Sat, 3 Aug 2019 01:28:12 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3030.oracle.com with ESMTP id 2u50aa8ap0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sat, 03 Aug 2019 01:28:12 +0000
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x731S6LT032689;
	Sat, 3 Aug 2019 01:28:06 GMT
Received: from mbp2018.cdmnet.org (/82.27.120.181)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 02 Aug 2019 18:28:05 -0700
Cc: calum.mackay@oracle.com, Christoph Hellwig <hch@infradead.org>,
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
Subject: Re: [PATCH 31/34] nfs: convert put_page() to put_user_page*()
To: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
 <20190802022005.5117-32-jhubbard@nvidia.com>
From: Calum Mackay <calum.mackay@oracle.com>
Organization: Oracle
Message-ID: <1738cb1e-15d8-0bbe-5362-341664f6efc8@oracle.com>
Date: Sat, 3 Aug 2019 02:27:55 +0100
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:70.0)
 Gecko/20100101 Thunderbird/70.0a1
MIME-Version: 1.0
In-Reply-To: <20190802022005.5117-32-jhubbard@nvidia.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9337 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908030013
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 02/08/2019 3:20 am, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> For pages that were retained via get_user_pages*(), release those pages
> via the new put_user_page*() routines, instead of via put_page() or
> release_pages().
> 
> This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
> ("mm: introduce put_user_page*(), placeholder versions").
> 
> Cc: Trond Myklebust <trond.myklebust@hammerspace.com>
> Cc: Anna Schumaker <anna.schumaker@netapp.com>
> Cc: linux-nfs@vger.kernel.org
> Signed-off-by: John Hubbard <jhubbard@nvidia.com>
> ---
>   fs/nfs/direct.c | 4 +---
>   1 file changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index 0cb442406168..b00b89dda3c5 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -278,9 +278,7 @@ ssize_t nfs_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
>   
>   static void nfs_direct_release_pages(struct page **pages, unsigned int npages)
>   {
> -	unsigned int i;
> -	for (i = 0; i < npages; i++)
> -		put_page(pages[i]);
> +	put_user_pages(pages, npages);
>   }

Since it's static, and only called twice, might it be better to change 
its two callers [nfs_direct_{read,write}_schedule_iovec()] to call 
put_user_pages() directly, and remove nfs_direct_release_pages() entirely?

thanks,
calum.


>   
>   void nfs_init_cinfo_from_dreq(struct nfs_commit_info *cinfo,
> 

