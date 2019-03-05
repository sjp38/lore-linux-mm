Return-Path: <SRS0=tSF5=RI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EB8A2C43381
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 15:04:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AAD0F20684
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 15:04:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="iiEkLBgA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AAD0F20684
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C9AE8E0003; Tue,  5 Mar 2019 10:04:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 376878E0001; Tue,  5 Mar 2019 10:04:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2665D8E0003; Tue,  5 Mar 2019 10:04:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id F2DE98E0001
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 10:04:26 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id j18so2612927itl.6
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 07:04:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=whALaH2FYSiHZMtoyrQE2aHUWCB9+DSN3UR8q9XLFW0=;
        b=jYHYjEaKW7R/R8IwfN+/D5VUg4h4qUsgb6XQiAEOX3Wb4ARgPpK7/5X00hFYIpyMWA
         /S3cXsq7N3VllGotiyMs0bnHrz1SsrithgfIZGLgN3MG3GixZFHz7XfnyE6V9OMnTUQT
         gDShgdF3hZ6I/5bBUUFd57l3t93nooKhmYhevdIYY3HD7LaLl6MKyMXZULLbzx5V0iMH
         pz1Dkh9tkQNZiiztXv5EtRlyY4lY1lcVBJSFCQC0wbeAnWkoqWfv0ll+dq88UrNHwlo5
         w0dX4/jzz2gSm0o9OtnbPr7Y4sYrlcz5U5AwH1kdfQdAWPYmPzI4NPu626zzMVk0pDvs
         OoiQ==
X-Gm-Message-State: APjAAAVj6x0Y3Iax07aFaUFFzIiPFqEQJbcwBp9/NaYT4sGWXfpkgfhT
	ng3EpB9C26s1h/GZ1AO0R5nQ9H8DCk+i7eAIokHR934gCAn0P9u17MfJLFC29wgcAAWroJoJ8AQ
	wtsprNM77EUpNat2WP8opF5RvTuqwoJvyvFfwDoIwUN0s6hw6ER4SwO/815Fh062aTw==
X-Received: by 2002:a6b:760d:: with SMTP id g13mr238751iom.273.1551798266745;
        Tue, 05 Mar 2019 07:04:26 -0800 (PST)
X-Google-Smtp-Source: APXvYqwcYMu+3Od/Mp3dbAjr/HAxLHleDeU49WF9eNzwx94gb3f0Z29i9AKNubAWSfk4R2uQEdtJ
X-Received: by 2002:a6b:760d:: with SMTP id g13mr238620iom.273.1551798264579;
        Tue, 05 Mar 2019 07:04:24 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551798264; cv=none;
        d=google.com; s=arc-20160816;
        b=zOGnFqmTAEs42F+6QjPpZx/TXPeZnwakLBTcs6XgQnA2ktPaRzytHuS+zDr28A6Sg7
         G+ZI3S2qIl5jE+oJ21QzLCs+7QTm/f5meKpediSYm1wByCBJVVi2akDR080Hvwg58GgO
         qUw5QfxAPsWstGvL6F/A/EGHiWPFaP7aZWmEZ23kWPVZcduXdS6gSzWYp9vgPE0SapPi
         LssqaknQyCEw0D1OttzauYkYSg44wKnh+vWCTWRa/WD7hvMbcsNxcmKSzthGRI4zgOgW
         rz+fSJ4ky3wPaLXbuHtD82aiX7NlAQ9LnNLSbEqiLY7kuncB6h5w7jOLZwop8OV1pi5X
         4lZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=whALaH2FYSiHZMtoyrQE2aHUWCB9+DSN3UR8q9XLFW0=;
        b=FVw6QIIBWpf1exnp7bt4RVY9MJ3w5G/NwN6b9B/DnfSV/7tHZ9KIDk8pfJQhyItdwo
         htmCCHCAHF+JLrLO6NhP4lDdVg+wT/uowwsRecTCyufKx+Gx083TxXroNRb4umudBs26
         c9eArxpEswht4svrxKnBXibGyS/6E403BFa/m1zqprz6Ma92GUD1hxueJ2IjW3CDrAXT
         2iDkJAYmXGiazUZb2IX1WeLvEl+nT6kprJiH1DeJxcPpbT9sWpHyGd6yatHd1CKDl5eI
         U/q0QJdXwFgklDuH0/tqjtYtmcNntdr/wOYM+FiQw7oRFxeevqWYWPtEelylXVLCIT7I
         8D7g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=iiEkLBgA;
       spf=pass (google.com: domain of yuval.shaia@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=yuval.shaia@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id c82si4635724iof.67.2019.03.05.07.04.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Mar 2019 07:04:24 -0800 (PST)
Received-SPF: pass (google.com: domain of yuval.shaia@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=iiEkLBgA;
       spf=pass (google.com: domain of yuval.shaia@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=yuval.shaia@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x25EwucM068210;
	Tue, 5 Mar 2019 15:04:19 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 content-transfer-encoding : in-reply-to; s=corp-2018-07-02;
 bh=whALaH2FYSiHZMtoyrQE2aHUWCB9+DSN3UR8q9XLFW0=;
 b=iiEkLBgAwmBmdeGX1HiIRD7U9YiwRSNZEiBwb7+XyGeEH5Fui14m2Vg34bw4SIMvKQNk
 egDQuj/sr+1IocTidAvaFNviwwHXKvbvwgr4O8NNByK+t4+pmV4fP4T7Wnvbc+OSGyai
 UxaWlp1HoyMtb3ybmpjmygB2fJxQCUn0gAmkVWXs/IYyZKEg3asRjPbaOzQIrEgwGb3X
 +M+lMUZfc5H0gZNzOemrZxxXeD8CToF7XRNCVXHI4+Honp8CI/E07/rIgR3mX3nWm1SH
 ZbzrqK3/sRXiGQH/pRDCjqWZVOK3LNwSYFim8BKnzxrwTVKRG2WKSKnJyUXBWR2NlaR5 jA== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2130.oracle.com with ESMTP id 2qyh8u5wvv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 05 Mar 2019 15:04:18 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x25F4CMs002625
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 5 Mar 2019 15:04:13 GMT
Received: from abhmp0007.oracle.com (abhmp0007.oracle.com [141.146.116.13])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x25F4CcT010829;
	Tue, 5 Mar 2019 15:04:12 GMT
Received: from lap1 (/77.138.186.148)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 05 Mar 2019 07:04:11 -0800
Date: Tue, 5 Mar 2019 17:04:06 +0200
From: Yuval Shaia <yuval.shaia@oracle.com>
To: Ira Weiny <ira.weiny@intel.com>
Cc: john.hubbard@gmail.com, linux-mm@kvack.org,
        Andrew Morton <akpm@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>,
        John Hubbard <jhubbard@nvidia.com>, Leon Romanovsky <leon@kernel.org>,
        Jason Gunthorpe <jgg@ziepe.ca>, Doug Ledford <dledford@redhat.com>,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH v3] RDMA/umem: minor bug fix in error handling path
Message-ID: <20190305150406.GA12098@lap1>
References: <20190304194645.10422-1-jhubbard@nvidia.com>
 <20190304194645.10422-2-jhubbard@nvidia.com>
 <20190304115814.GE30058@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
In-Reply-To: <20190304115814.GE30058@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9185 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903050100
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 04, 2019 at 03:58:15AM -0800, Ira Weiny wrote:
> On Mon, Mar 04, 2019 at 11:46:45AM -0800, john.hubbard@gmail.com wrote:
> > From: John Hubbard <jhubbard@nvidia.com>
> >=20
> > 1. Bug fix: fix an off by one error in the code that
> > cleans up if it fails to dma-map a page, after having
> > done a get_user_pages_remote() on a range of pages.
> >=20
> > 2. Refinement: for that same cleanup code, release_pages()
> > is better than put_page() in a loop.
> >=20
> > Cc: Leon Romanovsky <leon@kernel.org>
> > Cc: Ira Weiny <ira.weiny@intel.com>
> > Cc: Jason Gunthorpe <jgg@ziepe.ca>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Doug Ledford <dledford@redhat.com>
> > Cc: linux-rdma@vger.kernel.org
> > Cc: linux-mm@kvack.org
> > Signed-off-by: John Hubbard <jhubbard@nvidia.com>
>=20
> I meant...
>=20
> Reviewed-by: Ira Weiny <ira.weiny@intel.com>
>=20
> <sigh>  just a bit too quick on the keyboard before lunch...  ;-)
>=20
> Ira

I have this mapping in vimrc so i just have to do shift+!

map ! o=0DReviewed-by: Yuval Shaia <yuval.shaia@oracle.com>=0D=1B

>=20
>=20
> > ---
> >  drivers/infiniband/core/umem_odp.c | 9 ++++++---
> >  1 file changed, 6 insertions(+), 3 deletions(-)
> >=20
> > diff --git a/drivers/infiniband/core/umem_odp.c b/drivers/infiniband/co=
re/umem_odp.c
> > index acb882f279cb..d45735b02e07 100644
> > --- a/drivers/infiniband/core/umem_odp.c
> > +++ b/drivers/infiniband/core/umem_odp.c
> > @@ -40,6 +40,7 @@
> >  #include <linux/vmalloc.h>
> >  #include <linux/hugetlb.h>
> >  #include <linux/interval_tree_generic.h>
> > +#include <linux/pagemap.h>
> > =20
> >  #include <rdma/ib_verbs.h>
> >  #include <rdma/ib_umem.h>
> > @@ -684,9 +685,11 @@ int ib_umem_odp_map_dma_pages(struct ib_umem_odp *=
umem_odp, u64 user_virt,
> >  		mutex_unlock(&umem_odp->umem_mutex);
> > =20
> >  		if (ret < 0) {
> > -			/* Release left over pages when handling errors. */
> > -			for (++j; j < npages; ++j)
> > -				put_page(local_page_list[j]);
> > +			/*
> > +			 * Release pages, starting at the the first page
> > +			 * that experienced an error.
> > +			 */
> > +			release_pages(&local_page_list[j], npages - j);
> >  			break;
> >  		}
> >  	}
> > --=20
> > 2.21.0
> >=20

