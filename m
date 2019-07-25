Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14C4FC7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 07:08:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B31C420840
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 07:08:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="muZVds6s"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B31C420840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4FE268E0042; Thu, 25 Jul 2019 03:08:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 486CC8E0031; Thu, 25 Jul 2019 03:08:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 34F1F8E0042; Thu, 25 Jul 2019 03:08:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 100228E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 03:08:20 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id r27so53881448iob.14
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 00:08:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=gv2SPbpkF9xScJE1PHpWHpgE3ifu6hFMD2cmVIyD7TY=;
        b=b5ycV/DmrJPN/7ZmCedU8ijE0OAjFfu3e59D5JvifqfBFGjmXaflXa243DFks4kgO8
         ZYE33ZQeGDPApV5pN6tlvO9+3myMC9fvrvLvcuH9ig1OySwm/t/0/h07Xr0mbNU65LKy
         3SLZS9ccF9DiOcQcwc3O4CWABuT7VNtBcP/WBVb8fmDZPWJDXwL9k9HnqGPTXQDwFnKb
         zLuDhPLnjVuKFl/Qu2Xf+6MCaYaupRgP5ojJpujB3W2cej8VMMcWCGmdio/at+L4q3qk
         quaErTe10twmnmucfBNbJ5do4PjdaCLJbByeXR9ntu6zD1m1DA7ykCZKr/EBdDJtQsFp
         nwLw==
X-Gm-Message-State: APjAAAWQR7mXaKmAcHk2VB0gptSyCvbHSPQDOZtJWK4R87p9EEIyCnal
	lDZM7RwUTCIa3n/nZA4iMIXuXBy95eMBBmFUZwD6OY9kqgCVAlUChsZZk17VjWama8+Z7tiK3+m
	eItJq9a7dJkpbsVZMNHo3pBIp+Jkx/kRe5bApZPryJtClOWfj+4VoiBjP44/MsLyNtw==
X-Received: by 2002:a5e:9304:: with SMTP id k4mr83155685iom.206.1564038499810;
        Thu, 25 Jul 2019 00:08:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzT0O4+a2pPMxlaXN27/kora32yZpwI4rv1pc3jcFwIF6hI5ZJz6+rB0I9xC6OyV/Eid5Ie
X-Received: by 2002:a5e:9304:: with SMTP id k4mr83155635iom.206.1564038499028;
        Thu, 25 Jul 2019 00:08:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564038499; cv=none;
        d=google.com; s=arc-20160816;
        b=vTuIAo9nVV1YdfIrBsg4aFFYWaD2v97lfDW3MlLRvVYvG+h624V0NX4Sh44oH2VQtX
         zqhq/UBb1mSy9qtQMvhlFGXXcuLChoAq/dsUiRNND7cAdZ5U16It3eB0Nn8jIfxCnKdm
         p9BdYFBhxbphWm5wwhSRuFwXoZBEiCa59OBdU26FaqYtIvW/yp+6Cep+LWn2d8ids+gc
         3SwVs6VrvjIwF91s0QnIkguigul29+1IuqUGXulAZucmXigqqf/h3tQdtTCwhoXb/ka1
         +uUzWlD65PA/LUGIdkgmtqWhZtjr7t0Fcfs/490t423JWiC7NSDUNU/Y6kUCi/llttJ0
         HWfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=gv2SPbpkF9xScJE1PHpWHpgE3ifu6hFMD2cmVIyD7TY=;
        b=uElAbQn8enVKpDc5ZyV6qKAj1eou1zaE3UJQYBAHXqEjR1INtKISMlWAj1a22AVhMP
         AJ0UYZjO01U4DhNkKO4RjRMUmkiB9tjTb8ooxkB2aS4WbZdFf2PYvyJ85VakaSZ89txs
         V8BfHfV2z61n1Rp44CuKtk56WZmxYRb4wQFCFvOMO/VvJbSzX7Wc55KCrrqcgFRoBhXT
         m61FlAdNFM0OfAq/h1jrgYMJMy0MejyUcvBCML63qVAKVKTWQi8WYMabnrVGHbuGW6iy
         CFYO4CYZMdzkTQl1J2I73/xAuaM9UDr4YIJmsISnce/JPSu56NsICaAmevrXhnQuekzV
         O1PA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=muZVds6s;
       spf=pass (google.com: domain of bob.liu@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=bob.liu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id e124si62993309jab.5.2019.07.25.00.08.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 00:08:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of bob.liu@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=muZVds6s;
       spf=pass (google.com: domain of bob.liu@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=bob.liu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6P0dlXf171093;
	Thu, 25 Jul 2019 00:41:25 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=gv2SPbpkF9xScJE1PHpWHpgE3ifu6hFMD2cmVIyD7TY=;
 b=muZVds6swMHMAuFbMxKchNkOUd8CqTrPV0KBCMC49yrWg/LxnLuU6ow/RmgyiMUnnjmy
 MAiRa6Zm+jzf7B99ZPeMXmyGgQxIYQlCeWqFQqyGoNTjbspAoTiqbjfg4/VmNuRd7Vm5
 HrFVwz2k57PMYa/HPZcBBc0f5omPk+LrAWZPjNDUaWWol7Y67+yRcy8wbGU1Wbct1RLH
 zVzTyoIxGQlKet79OucxPmXfLkDZ0FkQP1v/RZBYzmhhy8PDfe/AB0YbSVtLklYjMvP9
 lz6P71WYbBjNCITeo6xlPXLd7l7LVGerjJLbDawimLUiySB/y4c3YF5VO7XLIrxNTkjP MA== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2tx61c0gjv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 25 Jul 2019 00:41:25 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6P0beDT189084;
	Thu, 25 Jul 2019 00:41:24 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3020.oracle.com with ESMTP id 2tx60yhed4-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 25 Jul 2019 00:41:24 +0000
Received: from abhmp0022.oracle.com (abhmp0022.oracle.com [141.146.116.28])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x6P0fGBA002510;
	Thu, 25 Jul 2019 00:41:16 GMT
Received: from [192.168.1.14] (/180.165.87.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 24 Jul 2019 17:41:15 -0700
Subject: Re: [PATCH 00/12] block/bio, fs: convert put_page() to
 put_user_page*()
To: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S . Miller" <davem@davemloft.net>,
        Dominique Martinet <asmadeus@codewreck.org>,
        Eric Van Hensbergen <ericvh@gmail.com>, Jason Gunthorpe <jgg@ziepe.ca>,
        Jason Wang <jasowang@redhat.com>, Jens Axboe <axboe@kernel.dk>,
        Latchesar Ionkov <lucho@ionkov.net>,
        "Michael S . Tsirkin" <mst@redhat.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Christoph Hellwig <hch@lst.de>, Matthew Wilcox <willy@infradead.org>,
        linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>,
        ceph-devel@vger.kernel.org, kvm@vger.kernel.org,
        linux-block@vger.kernel.org, linux-cifs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        samba-technical@lists.samba.org, v9fs-developer@lists.sourceforge.net,
        virtualization@lists.linux-foundation.org,
        John Hubbard <jhubbard@nvidia.com>
References: <20190724042518.14363-1-jhubbard@nvidia.com>
From: Bob Liu <bob.liu@oracle.com>
Message-ID: <8621066c-e242-c449-eb04-4f2ce6867140@oracle.com>
Date: Thu, 25 Jul 2019 08:41:04 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190724042518.14363-1-jhubbard@nvidia.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9328 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1907250003
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9328 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1907250003
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/24/19 12:25 PM, john.hubbard@gmail.com wrote:
> From: John Hubbard <jhubbard@nvidia.com>
> 
> Hi,
> 
> This is mostly Jerome's work, converting the block/bio and related areas
> to call put_user_page*() instead of put_page(). Because I've changed
> Jerome's patches, in some cases significantly, I'd like to get his
> feedback before we actually leave him listed as the author (he might
> want to disown some or all of these).
> 

Could you add some background to the commit log for people don't have the context..
Why this converting? What's the main differences?

Regards, -Bob

> I added a new patch, in order to make this work with Christoph Hellwig's
> recent overhaul to bio_release_pages(): "block: bio_release_pages: use
> flags arg instead of bool".
> 
> I've started the series with a patch that I've posted in another
> series ("mm/gup: add make_dirty arg to put_user_pages_dirty_lock()"[1]),
> because I'm not sure which of these will go in first, and this allows each
> to stand alone.
> 
> Testing: not much beyond build and boot testing has been done yet. And
> I'm not set up to even exercise all of it (especially the IB parts) at
> run time.
> 
> Anyway, changes here are:
> 
> * Store, in the iov_iter, a "came from gup (get_user_pages)" parameter.
>   Then, use the new iov_iter_get_pages_use_gup() to retrieve it when
>   it is time to release the pages. That allows choosing between put_page()
>   and put_user_page*().
> 
> * Pass in one more piece of information to bio_release_pages: a "from_gup"
>   parameter. Similar use as above.
> 
> * Change the block layer, and several file systems, to use
>   put_user_page*().
> 
> [1] https://urldefense.proofpoint.com/v2/url?u=https-3A__lore.kernel.org_r_20190724012606.25844-2D2-2Djhubbard-40nvidia.com&d=DwIDaQ&c=RoP1YumCXCgaWHvlZYR8PZh8Bv7qIrMUB65eapI_JnE&r=1ktT0U2YS_I8Zz2o-MS1YcCAzWZ6hFGtyTgvVMGM7gI&m=FpFhv2rjbKCAYGmO6Hy8WJAottr1Qz_mDKDLObQ40FU&s=q-_mX3daEr22WbdZMElc_ZbD8L9oGLD7U0xLeyJ661Y&e= 
>     And please note the correction email that I posted as a follow-up,
>     if you're looking closely at that patch. :) The fixed version is
>     included here.
> 
> John Hubbard (3):
>   mm/gup: add make_dirty arg to put_user_pages_dirty_lock()
>   block: bio_release_pages: use flags arg instead of bool
>   fs/ceph: fix a build warning: returning a value from void function
> 
> Jérôme Glisse (9):
>   iov_iter: add helper to test if an iter would use GUP v2
>   block: bio_release_pages: convert put_page() to put_user_page*()
>   block_dev: convert put_page() to put_user_page*()
>   fs/nfs: convert put_page() to put_user_page*()
>   vhost-scsi: convert put_page() to put_user_page*()
>   fs/cifs: convert put_page() to put_user_page*()
>   fs/fuse: convert put_page() to put_user_page*()
>   fs/ceph: convert put_page() to put_user_page*()
>   9p/net: convert put_page() to put_user_page*()
> 
>  block/bio.c                                |  81 ++++++++++++---
>  drivers/infiniband/core/umem.c             |   5 +-
>  drivers/infiniband/hw/hfi1/user_pages.c    |   5 +-
>  drivers/infiniband/hw/qib/qib_user_pages.c |   5 +-
>  drivers/infiniband/hw/usnic/usnic_uiom.c   |   5 +-
>  drivers/infiniband/sw/siw/siw_mem.c        |   8 +-
>  drivers/vhost/scsi.c                       |  13 ++-
>  fs/block_dev.c                             |  22 +++-
>  fs/ceph/debugfs.c                          |   2 +-
>  fs/ceph/file.c                             |  62 ++++++++---
>  fs/cifs/cifsglob.h                         |   3 +
>  fs/cifs/file.c                             |  22 +++-
>  fs/cifs/misc.c                             |  19 +++-
>  fs/direct-io.c                             |   2 +-
>  fs/fuse/dev.c                              |  22 +++-
>  fs/fuse/file.c                             |  53 +++++++---
>  fs/nfs/direct.c                            |  10 +-
>  include/linux/bio.h                        |  22 +++-
>  include/linux/mm.h                         |   5 +-
>  include/linux/uio.h                        |  11 ++
>  mm/gup.c                                   | 115 +++++++++------------
>  net/9p/trans_common.c                      |  14 ++-
>  net/9p/trans_common.h                      |   3 +-
>  net/9p/trans_virtio.c                      |  18 +++-
>  24 files changed, 357 insertions(+), 170 deletions(-)
> 

