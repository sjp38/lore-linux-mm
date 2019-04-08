Return-Path: <SRS0=5KBY=SK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C457EC10F13
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 11:37:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 735AE2070D
	for <linux-mm@archiver.kernel.org>; Mon,  8 Apr 2019 11:37:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="ZFSwn4+i"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 735AE2070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0D8BF6B0005; Mon,  8 Apr 2019 07:37:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0883E6B0006; Mon,  8 Apr 2019 07:37:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E91616B0008; Mon,  8 Apr 2019 07:37:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id C45786B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2019 07:37:06 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id k13so12296977qtc.23
        for <linux-mm@kvack.org>; Mon, 08 Apr 2019 04:37:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=qq3D3diVxA3pGGNFraFuDmpOfxDU2goQ7+Y69KnRSt4=;
        b=O8Mbj35hyAwv+ZKVsPjBh0TaY07yy+1em5G18qzD2ZumgHHFBgnKZ0cptcFfQcFR4e
         gSRwo+yAkZpEs1JJNnT50UJp+v/H8RLtz9ZxsAiDwXium58pds6Nmg9vgjf9WH72CagR
         5uVC9oK225kDQivQPp2bEkHZuh3ps+4F2S4rfub05XQ9ue0lfT6kv9tYFMYC+/i6kil+
         hyyYl4b6c+c6pbQzC5OMqk84HxiZawyFdjit7veKAUcnn/yJXRbcdeWIUUpnJTT4XZ2n
         w8gnEq3V30AZqsSqtgh9jTbh/0ezRhkEnQrzxfQRrCaqA7BeogJ3fivSb9tAJdx/H81i
         wTpA==
X-Gm-Message-State: APjAAAWF2suxfbx42UtF0meBzj/LGrweiVlRbtgqNt68AzgGBeIXtm46
	c0rwC4YFIFuUJeXZXS9PLAIrWv5AVqQzTSjafT6Yh0mXsO+g7G3RwZpqGgAF4vTlArCzTc/kQPe
	dq7jTsGit3tC86fMxtCHd0DcduAXKI3eF3IDRv3UFhQZQ6/91jnkoCI9B33npmUKtLg==
X-Received: by 2002:a0c:d162:: with SMTP id c31mr5155099qvh.157.1554723426528;
        Mon, 08 Apr 2019 04:37:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzOikjKJm3gKydRS/1evn9h+fCtchCetnQG6YNqWhTIy5SnSzLFedpcxO8q35vSTjHD/iOP
X-Received: by 2002:a0c:d162:: with SMTP id c31mr5155057qvh.157.1554723425735;
        Mon, 08 Apr 2019 04:37:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554723425; cv=none;
        d=google.com; s=arc-20160816;
        b=bUlUt47qhtJv9euTQUj9tWW+cO+z7l3oLPvUdmJxMFXWGvKRJY2SGMsl7ePjAsxj3D
         dZckD8PfsfuleeWOPElD6zNX5cWGNPBc0u7vi8qvf96X3VTOcJKzCTjZC2crRZ/1M8f6
         6VdBiECrPfHC4tRzTZdnhtpWxkpA7t9+QuuAJv03ZfG9xJan0CxnNqtYjjRCAO0puZt6
         m75N/HbKRcIPJudH9gYxsJq7ikqFyLSyy1QIAQS+NYaQuAWMUrhLXr3RKFZIyYstDjKs
         3nM6pAzN9DFImWMBNLm3cpfrCjMfVBZTQoh2af9ZmUDOVrOnxc6n2bOC4qOZT4LDf2iw
         QWZg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=qq3D3diVxA3pGGNFraFuDmpOfxDU2goQ7+Y69KnRSt4=;
        b=DRby/2OzoNX9uvtCFGYB0bIJsGT4vlqJDfTbFj/mLH4UZ4klqjJI8KOX5EGkjNLH5F
         rtH2WMuEVvBXjiYD9ZeSzeYMCBF8nO8VJCFW1BGQhiSC+nJyMWN7ZoEHV+VbbLAaNtWg
         DpOrGY3o3OV/gi0YjpNixTKzmg2ErrV3B5YUVRPrz/tDdBlRMKvXV0b8cUxwGoz+k9CV
         4dSN+LNFIYEZuAYuF3JZHFkjdh8bIG/EFH4mTx8T2aAlB2KN/Qb+lTyP+OFdhMsCUZfA
         hc6lBQWaLFMCjOtgJyidIsOxY0Ij08nGT2K5uaqwybxS25YqOgCnDQ1TbZW4oWXjSKgY
         kg1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=ZFSwn4+i;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 200si1552987qkd.55.2019.04.08.04.37.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Apr 2019 04:37:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=ZFSwn4+i;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x38BT5i5126300;
	Mon, 8 Apr 2019 11:36:55 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=qq3D3diVxA3pGGNFraFuDmpOfxDU2goQ7+Y69KnRSt4=;
 b=ZFSwn4+i6TN5tsKbcoMjrUm32uO7+yYh4aQXPnr+H7hFYRkQPd7INyvzdAhjo4r/WCT2
 LR/ymO2up/qRwrousBy3Bsu8FaH9Dar+SEVcCgY0DL3iDpi/0cfD1kwfW2EKSKtxZc0R
 dumJFlakROVgeOBf4gGX1muKnKQ539FdW1c6ROqt/Tt014SW8HEGBXEtYJ3RfZL91hN9
 t8rLXpLpHdPU3DPyxm6Ooymegvm14X/0AVZ/+w94HlNS9R0yIWZ69HT0NZSTCSkLeD4P
 gZiNEXGpYe7G9oAhXN6sSI6gHvhL2dqthWcAFq2MEoHBK59P2fgfWrvUJED11J3fa321 9w== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2120.oracle.com with ESMTP id 2rpmrpwkwq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 08 Apr 2019 11:36:54 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x38BZXDE191953;
	Mon, 8 Apr 2019 11:36:54 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3020.oracle.com with ESMTP id 2rpytayyug-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 08 Apr 2019 11:36:53 +0000
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x38BalGM016696;
	Mon, 8 Apr 2019 11:36:48 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 08 Apr 2019 04:36:47 -0700
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.8\))
Subject: Re: Read-only Mapping of Program Text using Large THP Pages
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20190220171905.GJ12668@bombadil.infradead.org>
Date: Mon, 8 Apr 2019 05:36:46 -0600
Cc: Keith Busch <keith.busch@intel.com>, Linux-MM <linux-mm@kvack.org>,
        linux-fsdevel@vger.kernel.org, linux-nvme@lists.infradead.org,
        linux-block@vger.kernel.org
Content-Transfer-Encoding: quoted-printable
Message-Id: <B53C9F2D-966C-4DFD-8151-0A7255ACA9AD@oracle.com>
References: <379F21DD-006F-4E33-9BD5-F81F9BA75C10@oracle.com>
 <20190220134454.GF12668@bombadil.infradead.org>
 <07B3B085-C844-4A13-96B1-3DB0F1AF26F5@oracle.com>
 <20190220144345.GG12668@bombadil.infradead.org>
 <20190220163921.GA4451@localhost.localdomain>
 <20190220171905.GJ12668@bombadil.infradead.org>
To: Matthew Wilcox <willy@infradead.org>
X-Mailer: Apple Mail (2.3445.104.8)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9220 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904080100
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9220 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904080100
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Feb 20, 2019, at 10:19 AM, Matthew Wilcox <willy@infradead.org> =
wrote:
>=20
> Yes, on reflection, NVMe is probably an example where we'd want to =
send
> three commands (one for the critical page, one for the part before and =
one
> for the part after); it has low per-command overhead so it should be =
fine.
>=20
> Thinking about William's example of a 1GB page, with a x4 link running
> at 8Gbps, a 1GB transfer would take approximately a quarter of a =
second.
> If we do end up wanting to support 1GB pages, I think we'll want that
> low-priority queue support ... and to qualify drives which actually =
have
> the ability to handle multiple commands in parallel.

I just got my denial for LSF/MM, so I was hopeful someone who will
be attending can talk to the filesystem folks in an effort to determine =
what
the best approach may be going forward for filling a PMD sized page to =
satisfy
a page fault.

The two obvious solutions are to either read the full content of the PMD
sized page before the fault can be satisfied, or as Matthew suggested
perhaps satisfy the fault temporarily with a single PAGESIZE page and =
use a
readahead to populate the other 511 pages. The next page fault would =
then
be satisfied by replacing the PAGESIZE page already mapped with a =
mapping for
the full PMD page.=20

The latter approach seems like it could be a performance win at the sake =
of some
complexity. However, with the advent of faster storage arrays and more =
SSD, let
alone NVMe, just reading the full contents of a PMD sized page may =
ultimately be
the cleanest way to go as slow physical media becomes less of a concern =
in the
future.

Thanks in advance to anyone who wants to take this issue up.=

