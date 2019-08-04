Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A0A6BC19759
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 23:28:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 549A720880
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 23:28:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Q8jHS5Ly"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 549A720880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA3BC6B0278; Sun,  4 Aug 2019 19:28:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D53A86B0279; Sun,  4 Aug 2019 19:28:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1C2C6B027C; Sun,  4 Aug 2019 19:28:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id A0E9C6B0278
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 19:28:43 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id v126so35818263vkv.20
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 16:28:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:cc:subject:to:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=Xv/Xmfe6YA+uiUXCTMOrvz+2cmMCgKpadUjchsyGSqE=;
        b=aBfTwpfHbeh2QYBdplliTzXSCu5nqnNoiqI0RS94joEZZ3KZLH3GFOZBoThWXSXDIJ
         eB8wWIV7dpko+b/aC2Y60Rw5XgorOmrRnsfJUUaV736WG+OYIQfSI7896yJOSyqffQvi
         TTP9vE+2e8qyLdUd+yjoUb8edkLnMR6ovz/HpzqzMHqhtnO5eCLRIuulrtUwE1tgUwzh
         iDbG0RywZ7gFmgASzDW4ZtdD36dAsvasc4WYR9c5gD0H/8BN+Xc3H5mmNwnZ8tcqy7w4
         GNrEFEvegljMMqooU/+fa6qDGT+WtRa9A9CD84eIkgkTRyrqNCGnTI4U9BCUe/dz84PS
         lLiA==
X-Gm-Message-State: APjAAAVFMmDqXoO3+ljUJYZlKUVaGhU5k/kx8xKf2snsKDyswE0wiaT9
	mly5YLaHeziPFl9mnFB7u2ih2DN+Je++LzWg+evDvpMOEG6DcaVNE9ffgM/aYQlVfrN2iLLeKqu
	Bsjq39LfOVecnDQ38pYWvM7VPVCeLkhVnByP7yB/ngPZ5ExpmdjZ5DoKNJjH9k8zpLg==
X-Received: by 2002:ab0:2556:: with SMTP id l22mr79747397uan.46.1564961323360;
        Sun, 04 Aug 2019 16:28:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFmmIRvcDZY6FNdo0qkg2ShlTryWY8KPgOim6IWpDlBAOtG0Gbzr3rO8oDvutTIx+RNWSo
X-Received: by 2002:ab0:2556:: with SMTP id l22mr79747376uan.46.1564961322452;
        Sun, 04 Aug 2019 16:28:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564961322; cv=none;
        d=google.com; s=arc-20160816;
        b=Xtd2nUhEc0Cih3vaOwHpSLwAh45EI6eCjZhECaw9ux/LddzjrVr8+KjStDZSebIEyJ
         IjM2qN06zclGgjS6G2mWuUwA4mqQaPLuevazIjPJ7V6AWlT+cQiV6aF64TV1aJNfFc3n
         gGm8D6/bGopUUwZr9NPSeGxljwZdKSc/8gasx6f6Rb5wlrWmEruwy2q6pbPIFfbsUwaZ
         eZxrDuma461gyuGpgDKwbB8sLEeAYdyRLIF4bWjWr59H2i40Lz6pMHjVgl/kEb0pTCBI
         4uzVYRsInMhYKRRivAEHJGoBdUIj7plIqhsv8fe2tnXgyyXkbVldjjYJ3UpuNnsotGxv
         KBqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:to:subject
         :cc:dkim-signature;
        bh=Xv/Xmfe6YA+uiUXCTMOrvz+2cmMCgKpadUjchsyGSqE=;
        b=hWiPY8emQjbkTlvethIXLRCQmDsmaXNuBwLduvCdCGKwwpABNxE6x/D0KzB3gqfpBw
         atm673wTCvIHzttDi9JQSjsAVdIw7+Ts01ql/Oq5aD3jipucWWZXUF9QfuaXZbjGtwZm
         us0YTXWImzeTEVxgRy1A0ml/VIqDJMQdVp7IjHj0Ud6saEoRzl+86wfMZoFAJm1UMRms
         VOlrDpvIRktr+HBsOEP39EUBeaeDFduIiIr9f03ZEz7/9C8EXARszGc122SMGarMJzMU
         lhNZzfXphouZeyG+r3WFl/oqh82dXuUrji7rsYG6T3WxNrJwo098eyBOLScSQ4WJcZqH
         mOSg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Q8jHS5Ly;
       spf=pass (google.com: domain of calum.mackay@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=calum.mackay@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id t22si17284135vsl.11.2019.08.04.16.28.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Aug 2019 16:28:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of calum.mackay@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Q8jHS5Ly;
       spf=pass (google.com: domain of calum.mackay@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=calum.mackay@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x74NNpc9062157;
	Sun, 4 Aug 2019 23:28:16 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=cc : subject : to :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=Xv/Xmfe6YA+uiUXCTMOrvz+2cmMCgKpadUjchsyGSqE=;
 b=Q8jHS5LyGioVRXkw2sEGxpCJ0g6RThcXNJNhQ+zIt1yN9QAbG9oidwXBknqGefI/Gzo9
 By4AgfVTCnBhziiCIa41vp2Km7uJGUaiXbbnEbFOGJu/tindREq8cqQoMC9pE39KJmFC
 pbJGax0NRp2J6BU7Wqa2MYOikJcTOlvo6BuaJMMnG/rkz+mFpRP2aBj29SOQtqfHNiyp
 Oiqh3Pja48Hg208XzAKVGnWgaY0bM8E6Jd5XgoYoeEDXsXo8GsiLTw4ZRpe3pTL5xLes
 aQ1Owfq77tOFIMZ2lazrtAcx+SAXXLqcnJIeXpem2RoPun+jIzPsLiAZSgR10i43pZcT 6Q== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2120.oracle.com with ESMTP id 2u527pc4c4-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 04 Aug 2019 23:28:16 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x74NRrau079768;
	Sun, 4 Aug 2019 23:28:16 GMT
Received: from pps.reinject (localhost [127.0.0.1])
	by aserp3030.oracle.com with ESMTP id 2u50abah84-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL);
	Sun, 04 Aug 2019 23:28:16 +0000
Received: from aserp3030.oracle.com (aserp3030.oracle.com [127.0.0.1])
	by pps.reinject (8.16.0.27/8.16.0.27) with SMTP id x74NSFYX079993;
	Sun, 4 Aug 2019 23:28:15 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3030.oracle.com with ESMTP id 2u50abah81-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Sun, 04 Aug 2019 23:28:15 +0000
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x74NSAcc031730;
	Sun, 4 Aug 2019 23:28:10 GMT
Received: from mbp2018.cdmnet.org (/82.27.120.181)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Sun, 04 Aug 2019 16:28:10 -0700
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
        xen-devel@lists.xenproject.org,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Subject: Re: [PATCH 31/34] nfs: convert put_page() to put_user_page*()
To: John Hubbard <jhubbard@nvidia.com>, john.hubbard@gmail.com,
        Andrew Morton <akpm@linux-foundation.org>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
 <20190802022005.5117-32-jhubbard@nvidia.com>
 <1738cb1e-15d8-0bbe-5362-341664f6efc8@oracle.com>
 <db136399-ed87-56ea-bd6e-e5d29b145eda@nvidia.com>
From: Calum Mackay <calum.mackay@oracle.com>
Organization: Oracle
Message-ID: <03a81556-98a7-7edb-5989-b799ec99a072@oracle.com>
Date: Mon, 5 Aug 2019 00:28:01 +0100
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.14; rv:70.0)
 Gecko/20100101 Thunderbird/70.0a1
MIME-Version: 1.0
In-Reply-To: <db136399-ed87-56ea-bd6e-e5d29b145eda@nvidia.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9339 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908040274
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03/08/2019 2:41 am, John Hubbard wrote:
> On 8/2/19 6:27 PM, Calum Mackay wrote:
>> On 02/08/2019 3:20 am, john.hubbard@gmail.com wrote:
> ...
>> Since it's static, and only called twice, might it be better to change its two callers [nfs_direct_{read,write}_schedule_iovec()] to call put_user_pages() directly, and remove nfs_direct_release_pages() entirely?
>>
>> thanks,
>> calum.
>>
>>
>>>      void nfs_init_cinfo_from_dreq(struct nfs_commit_info *cinfo,
>>>
>   
> Hi Calum,
> 
> Absolutely! Is it OK to add your reviewed-by, with the following incremental
> patch made to this one?

Thanks John; looks good.

Reviewed-by: Calum Mackay <calum.mackay@oracle.com>

> 
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index b00b89dda3c5..c0c1b9f2c069 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -276,11 +276,6 @@ ssize_t nfs_direct_IO(struct kiocb *iocb, struct iov_iter *iter)
>          return nfs_file_direct_write(iocb, iter);
>   }
>   
> -static void nfs_direct_release_pages(struct page **pages, unsigned int npages)
> -{
> -       put_user_pages(pages, npages);
> -}
> -
>   void nfs_init_cinfo_from_dreq(struct nfs_commit_info *cinfo,
>                                struct nfs_direct_req *dreq)
>   {
> @@ -510,7 +505,7 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
>                          pos += req_len;
>                          dreq->bytes_left -= req_len;
>                  }
> -               nfs_direct_release_pages(pagevec, npages);
> +               put_user_pages(pagevec, npages);
>                  kvfree(pagevec);
>                  if (result < 0)
>                          break;
> @@ -933,7 +928,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
>                          pos += req_len;
>                          dreq->bytes_left -= req_len;
>                  }
> -               nfs_direct_release_pages(pagevec, npages);
> +               put_user_pages(pagevec, npages);
>                  kvfree(pagevec);
>                  if (result < 0)
>                          break;
> 
> 
> 
> thanks,
> 

