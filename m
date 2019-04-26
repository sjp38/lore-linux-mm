Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84CFBC43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 14:45:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 39D1E2077B
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 14:45:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="XNRLx+/7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 39D1E2077B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D75906B0008; Fri, 26 Apr 2019 10:45:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D266A6B000A; Fri, 26 Apr 2019 10:45:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C15696B000C; Fri, 26 Apr 2019 10:45:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 847416B0008
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 10:45:24 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id g1so2357743pfo.2
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 07:45:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=LE9A4smiUcCKHhSGSOEPiRFSN9l8MMhyxEeH0NKsxbs=;
        b=a9EF6Siu97Lb8Kb1vf2kx2s9Z99Je679ODRkSoP7X17qUmJ3DY4NiKZNhWE3w/T0kn
         cfo4+Y+Gutccw6621NM3vV8MMsNKjB2bXI4Uc1R1rtWzMERufB8Wcx7w7CIdCMjZ+RYS
         XyWPjlggvM2eZyxDw7a+GIVn4BpIvlwfoA55h83qUlNaYeSz6XzxcY/Q1CliaqYplrnk
         MUXHEb1woavYR4vnVVAVCebNv/pwvsv5PV5G6nGxQPFF6Inp/+tAIG8xSqckkh5rf7XD
         hzMZJZ2Xq8od8f+KHNRy0w3JjCUdu9iky+UgzIByodfAUNUyvl5Xztr1MwanPedwNDHy
         RwLg==
X-Gm-Message-State: APjAAAVhJFB2Gv79K8aAGvlMbh0J/lp64UXiTiFp+xSJQEat+w/6R4PA
	+9enoOUHEOwhU8RoXS2jzCYamvZUTXO3I6/6IW7lPgbHSuoQSp0c5MKH9sZR6McvV/8k2e8rytk
	gi5gUBv9Zm2j9I+3Hr+7jyV4mLsxqh9kqAnU0UxdXaWin24AF4oLyS+1o2s3Ai4C2QA==
X-Received: by 2002:a63:6941:: with SMTP id e62mr40027329pgc.99.1556289924132;
        Fri, 26 Apr 2019 07:45:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxnrpxUnuIoRyCuXU+UbQU+xPsrmKxXw4+GrSAT9+ipxXXC6ZbSs4VSrbIBFEvk08mkmvy0
X-Received: by 2002:a63:6941:: with SMTP id e62mr40027273pgc.99.1556289923278;
        Fri, 26 Apr 2019 07:45:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556289923; cv=none;
        d=google.com; s=arc-20160816;
        b=vd1C6EYqwbcV7JqYb5Zf+A31V50t2nAQ3qaw/2uXpH+/Fcz73WvVQeQ+xVmEZRd/MV
         /r4HY+DWGRcVB1WQ204QfGFRaDF4VnNEdFhlZn8MQGdwLY6f3cI4oBv6VB8KVueg3VP3
         Taj/Kx1PkSkFD15c9cZ3PpH7MOFKmUaJVoZo5vy/GGnv5js+oj9NKAhymXlnv4XfjI4N
         wqyrw3Pk5GTI0reOrDYNFpjchP6Ty11+JYvfUuu9p5y7s5cGP0JeThiVtc/kYcNy/nqi
         t3uQWYkzGXJ3Dc3R8ZRRetP9vQ5DTpYJy35irXpKU5osoutpt18R1liZVyLpXJsf9eHp
         wiIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=LE9A4smiUcCKHhSGSOEPiRFSN9l8MMhyxEeH0NKsxbs=;
        b=xVuhR1ggX4TxLAX+K9JJj7brOhi9LzHpagZUcrlVi69Rv2MZN7ZrrjaDlpEOuYXjle
         zTMwVtFcdBkl1oVV6bUIgwtEi2kWnW2NbOuWo2HwNDloNCMKDrzaBLSBYe/VnSaJ6HKX
         IWpsZSzMvvKZgHM1q3yz7qNSei42ftaFCcHr2lZ1ANmi3fIvZl38DjHRjsS8G/Yadkly
         g20yZ9xRM/QkOAI0MfuOD29hp2yGpUifaqurIjZynENPTLlDSyixfv0dmutw/aNJFstX
         fcKl6r2iANxfAiv7DSwWDKIpKRlBNPc4tP9VigPdqEnl/uZ6a9d9//XcjyPJOYHLkGDK
         wnEA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="XNRLx+/7";
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id bd9si25340644plb.208.2019.04.26.07.45.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 07:45:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="XNRLx+/7";
       spf=pass (google.com: domain of darrick.wong@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=darrick.wong@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3QEYTmS120579;
	Fri, 26 Apr 2019 14:45:10 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 in-reply-to; s=corp-2018-07-02;
 bh=LE9A4smiUcCKHhSGSOEPiRFSN9l8MMhyxEeH0NKsxbs=;
 b=XNRLx+/7PRD7ym+fUsYzMt4wfLPh6UCuLh8UnZvF78EJKnzruNlOdccbiJhgIe5kl7iY
 /9OEHv5GBUe4aq9tvnaP5wYY5IbDsy5yihOkZoZCkrAW7ZA1xqgEUUx+NajOUoPXuKJ9
 C2AMf75B4eucFzdtrJ7zycj0pu3kEKwUlztJlb3v84VlNwiqroxJ6fOvRI7FmTSAZIvF
 zMdqTAl0Z3VewQl2Ja7q9uniTaJIEhuHFZ+qwCCMXvMN8MyY/sD+80Vtope085wYE5sD
 nc+bGpF/Uv68G9ZIaDzryOOFJ2dpdAmebCxw9dP4Zl/qBP8mOQpadPQIboCcOl4IgIJM BA== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2130.oracle.com with ESMTP id 2ryrxder02-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 26 Apr 2019 14:45:10 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x3QEipin179053;
	Fri, 26 Apr 2019 14:45:09 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3020.oracle.com with ESMTP id 2s0dwg2app-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 26 Apr 2019 14:45:09 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x3QEj7FI016013;
	Fri, 26 Apr 2019 14:45:07 GMT
Received: from localhost (/67.169.218.210)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 26 Apr 2019 07:45:07 -0700
Date: Fri, 26 Apr 2019 07:45:07 -0700
From: "Darrick J. Wong" <darrick.wong@oracle.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Dave Chinner <david@fromorbit.com>, Jerome Glisse <jglisse@redhat.com>,
        lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org,
        linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [LSF/MM TOPIC] Direct block mapping through fs for device
Message-ID: <20190426144507.GB178347@magnolia>
References: <20190426013814.GB3350@redhat.com>
 <20190426062816.GG1454@dread.disaster.area>
 <20190426124553.GB12339@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190426124553.GB12339@infradead.org>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9238 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904260101
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9238 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904260101
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 26, 2019 at 05:45:53AM -0700, Christoph Hellwig wrote:
> On Fri, Apr 26, 2019 at 04:28:16PM +1000, Dave Chinner wrote:
> > i.e. go look at how xfs_pnfs.c works to hand out block mappings to
> > remote pNFS clients so they can directly access the underlying
> > storage. Basically, anyone wanting to map blocks needs a file layout
> > lease and then to manage the filesystem state over that range via
> > these methods in the struct export_operations:
> > 
> >         int (*get_uuid)(struct super_block *sb, u8 *buf, u32 *len, u64 *offset);
> >         int (*map_blocks)(struct inode *inode, loff_t offset,
> >                           u64 len, struct iomap *iomap,
> >                           bool write, u32 *device_generation);
> >         int (*commit_blocks)(struct inode *inode, struct iomap *iomaps,
> >                              int nr_iomaps, struct iattr *iattr);
> 
> Nipick:  get_uuid isn't needed for the least itself, it just works
> around the fact that the original pNFS/block protocol is braindead.
> The pNFS/SCSI prototocol already switches to a device UUID, and other
> users that work locally shouldn't need it either.

Hmmm, this lease interface still doesn't support COW, right?

(Right, xfs_pnfs.c bails out with -ENXIO for reflink files)

It occurs to me that maybe we don't want Goldwyn's IOMAP_DAX_COW
approach (hide the read address in the iomap->inline_data pointer); we
just want two physical source addresses.  Then the dax code can turn
that into a memory pointer and file lessees can do sector accesses or
whatever they need to do to write the range before calling
->commit_blocks.

Oh, right, both of you commented about a dual iomap approach on the v2
btrfs dax support series.

/me goes back to drinking coffee.

--D

