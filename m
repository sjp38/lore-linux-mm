Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D3D1C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 09:37:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0EC9E20675
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 09:36:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="NS75H5d4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0EC9E20675
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 960088E0003; Wed,  6 Mar 2019 04:36:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E9058E0002; Wed,  6 Mar 2019 04:36:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B21A8E0003; Wed,  6 Mar 2019 04:36:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 501A18E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 04:36:59 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id w200so4902791itc.8
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 01:36:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=ySK+dnbEwNc/jKCcXQYwRKr281ZVSbI5VAD5JADKSXY=;
        b=oZzFxhwIuCzxLxZ4gTOlo5rppkjkyVHPy3/GJ7iLp/vMSgrR0TCdvl48n9ISCVAjQr
         3kfErAOinV4VjopydxE3/LGxEc/yKJazzYsTtSoLt+RAdD030QmyfOq3eXIHDK3/iqxd
         Tb4izZHN5a9AxgDA0Bez/DZL+Pu60AISngpMCX/XV759PJBSnJH7BoObqJcLc8jz3Ovi
         gstDBfAAqEgcd5ipYmTmhtJLQJUuBBGfCPdr7hg1PFgGeaZ/FAIbmu7OOV8C5h5MiZjc
         zF752IQQptehv0+/Nd0ovpP2Nt4ChgMb533hWHD00jRucf0IHw0FPdfV51lliyf3L2CJ
         27WQ==
X-Gm-Message-State: APjAAAV63eGr7IGLJosxVxO/NAfn1ymsfGlsCNhGyxDaqXeStRBbNaY6
	NIEQxfUdDB20pWkF35N01m+2ad+g8Hqh71l4nhpZ3wOiV0x0wkX9WTlV3EbVof2xdLVnjAgmTYF
	f82vuic50j2+ASW+i9EAGrKxTMx4ghqSJx98ocREUYiZ68idcojfLssIwMihzsjq1vg==
X-Received: by 2002:a6b:6b02:: with SMTP id g2mr2781136ioc.178.1551865019051;
        Wed, 06 Mar 2019 01:36:59 -0800 (PST)
X-Google-Smtp-Source: APXvYqwXwHD+bqkNbUSvQRdr3HPfJPPEBYRPMHzEIwNt/tvQEElwKr56NXim8euFxIg9EiL67+UI
X-Received: by 2002:a6b:6b02:: with SMTP id g2mr2781002ioc.178.1551865014463;
        Wed, 06 Mar 2019 01:36:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551865014; cv=none;
        d=google.com; s=arc-20160816;
        b=zblW/rTB9ghnVRWF9ttPkLmTmFlCOza0ooxIjYHNXttQ+/GpZrgIMVLr3VsB58cdsn
         nHn8hTg9oibzaEgVf5VHPs3MgE1BXVedtPlSFALGxzhmrIokSgihEXjzNOFt+VJx/oNW
         yGVdFUktx+pTFYeoesRFL7cBpykDsbcQDRhtfTeZRDT9/lDo2ySEmMEEdl7QKtE0WPQ6
         qCP8t3R8QbQFCrMUKZKOtbXXz2PlqGZnU9H8nFD9XMDKDvl1LHP6wj/PDJiLf3chG2Sr
         PSBHLjXDHNR86Edh0ZFMV/Ke6KKrsLsj05JWUqA7oWtx44pNx2heEIiVLY65w6qwWJMY
         m/0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=ySK+dnbEwNc/jKCcXQYwRKr281ZVSbI5VAD5JADKSXY=;
        b=S75lLqzCvZwQFZzvVnq+3di/GMEOmouZoBCYBG7pzMOfxJWgGO9h416lgL44zVKcVg
         tTDb2kIsXGbFz3CTRirYb9ZmOn4pZg101p/88L7JKBPTKF6nFvjzkyJ63p6Ru0zowV2N
         oIMZ+WkuSKXwt+Tq6kReEDCdymTrFFdY17/rlri7ZWwhGjKBCgs4mOx9w0YXecpTg0J2
         nSWDD85Xtn0MFsUzAHNvjNcgi3ttdZ/ynne+s9B+y0+/hLOmo99/czhO86AZ4mRYYSQD
         9cSRVtm7c/lua9SBKionYoucf96tC0Dv5pKJFbHqKYf0zLtB0DKis6QZw6kZFO6seun4
         rAkw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=NS75H5d4;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id h69si454802jad.12.2019.03.06.01.36.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 01:36:54 -0800 (PST)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=NS75H5d4;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x269XhiX164633;
	Wed, 6 Mar 2019 09:36:38 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=ySK+dnbEwNc/jKCcXQYwRKr281ZVSbI5VAD5JADKSXY=;
 b=NS75H5d4BIExubi8/gXjQ+2jAR9Hi4BPuZF3X6XKt/me6YlINo6XvDNNsBCC0vMEQyVo
 Pc3woLLg39I4or4aXAD39z0GMcS/BIt7hWfEyZXCrXqn85VsccruAlMigBRgynYXiTsV
 geQv/bjWg4mcE5q+DECQCOU78M3nW7FTprWJIOAHgT0XPCza+7bArIBNW8zUJIIEgn/Q
 JHtGrZ9G49gxvnq+su5xOIGf/Y8l7RtaAc0pGE9xgogrCTo028oMGWrncVdbBMOreUZe
 horeE9axn7c5GHwmel/i+f/S/LU7elvuZ8hB+zHgZHkg8jAR1L+T2Tv8eZYHxeEumG1l xQ== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by aserp2130.oracle.com with ESMTP id 2qyfbeawsy-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 06 Mar 2019 09:36:38 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x269acXb019478
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 6 Mar 2019 09:36:38 GMT
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x269abKR024174;
	Wed, 6 Mar 2019 09:36:37 GMT
Received: from [192.168.0.110] (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 06 Mar 2019 01:36:37 -0800
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.2\))
Subject: Re: [PATCH v3] page cache: Store only head pages in i_pages
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <CAPhsuW5a8=QJe2acWXQGWic1a=CJigwPR6BxSu2O2vg4W1mhzA@mail.gmail.com>
Date: Wed, 6 Mar 2019 02:36:35 -0700
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Linux-MM <linux-mm@kvack.org>,
        linux-fsdevel@vger.kernel.org,
        open list <linux-kernel@vger.kernel.org>,
        Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>,
        Song Liu <liu.song.a23@gmail.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <863F9255-E992-402F-827D-DA5F4661B9AB@oracle.com>
References: <20190215222525.17802-1-willy@infradead.org>
 <CAPhsuW7Hu6jBn-ti7S2cJhO1YQYg_RDZUgkqtgFO8zpBMV_9LA@mail.gmail.com>
 <CAPhsuW5a8=QJe2acWXQGWic1a=CJigwPR6BxSu2O2vg4W1mhzA@mail.gmail.com>
To: Matthew Wilcox <willy@infradead.org>
X-Mailer: Apple Mail (2.3445.104.2)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9186 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1903060066
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Other than the bug Song found in memfd_tag_pins(), I'd like to suggest =
two quick
but pedantic changes to mm/filemap.c:

Though not modified in this patch, in line 284, the parenthesis should =
be moved
to after the period:

 * modified.) The function expects only THP head pages to be present in =
the

> +		 * Move to the next page in the vector if this is a =
small page
> +		 * or the index is of the last page in this compound =
page).

A few lines later, there is an extraneous parenthesis, and the comment =
could be a bit
clearer.

Might I suggest:

                 * Move to the next page in the vector if this is a =
PAGESIZE
                 * page or if the index is of the last PAGESIZE page =
within
                 * this compound page.

You can say "base" instead of "PAGESIZE," but "small" seems open to =
interpretation.

I haven't run across any problems and have been hammering the code for =
over five days
without issue; all my testing was with transparent_hugepage/enabled set =
to
"always."

Tested-by: William Kucharski <william.kucharski@oracle.com>
Reviewed-by: William Kucharski <william.kucharski@oracle.com>=

