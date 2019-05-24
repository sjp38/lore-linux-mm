Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,UNPARSEABLE_RELAY,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1260C282E1
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 21:43:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 652F8217D7
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 21:43:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="m+Zhhh6b"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 652F8217D7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E80D96B0008; Fri, 24 May 2019 17:43:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E0AB26B000A; Fri, 24 May 2019 17:43:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CAA266B000C; Fri, 24 May 2019 17:43:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id A3B786B0008
	for <linux-mm@kvack.org>; Fri, 24 May 2019 17:43:18 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id p13so9744891ywm.20
        for <linux-mm@kvack.org>; Fri, 24 May 2019 14:43:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=5ZYOEzS+65K8bB/ZHCHtVMV0q6W5qUrvuM4ooNhr7KA=;
        b=OX2dpB8Bo8f987T9p/5RX5BhGNJfKvzpa2wo5cVZ5M98rlRPQQpEgpRikRaBz9Gt0w
         TZ8GYHdhAhqnuMLpGLnoiMQ30cDC9gwwUWwirTCNecGoxM9O50fQ3RIycse5fEhfjZCu
         9D69zdxWSc0GKGoLIuWitII8e9h/bWRndTUVymbwvSb5SQu17cR+34sSf2uuUOwBpI9u
         kTOw+qnpVXeDI2Y9TOZEPdU1q0SKrl0jhfS0RY5NUEdVDWd707jfhnV1+EjcAyU0P+B9
         9lwExIHeV/2ONKMdsg3QG2wRxpSyKfCI4CF1rZHqV/VlM2eZeN2IXiGO+H4BowfVYAtC
         MKuA==
X-Gm-Message-State: APjAAAUYR0btyA5fn6HrELVTpwNftS53woRZFDwG7CYM9iWDF+rhZvKt
	th8lIzuEq+GkDN+N0l/Mjctp55UVyjnruXrPDrqRdJB/0YYB1CXdttYhUy89lGcX/hLuSa9uOyk
	G4BR0A3/1V8QRS9H8JtHvGosp0ZbC05jeFds8t2IGqaWK0JWaRTQU4hhb9drbQACRUA==
X-Received: by 2002:a81:2183:: with SMTP id h125mr18687130ywh.289.1558734198320;
        Fri, 24 May 2019 14:43:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwZEvB2WNi8QfvKVeF7jaqS3+mU7v3eijwxsVX60lVaZck6MYSSKhKhl4H6w7CkwUb5t4rO
X-Received: by 2002:a81:2183:: with SMTP id h125mr18687115ywh.289.1558734197554;
        Fri, 24 May 2019 14:43:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558734197; cv=none;
        d=google.com; s=arc-20160816;
        b=KdaiaD/lv/AKu3AuFQIiMzB+EoYb8LenNrRK6KLskFGHB+5SXj7p5ud9UYv6E2tHv1
         2gket0JqrD4lLU561N2x6vIwb1pci2A67z3M9Wlg/wEwvSNbWVZxGu2H5vlVFgG5lJlf
         FKl9RRBh+7SDKP4OR+6u6F3VOJsJAaufIUnCOmvQcNuSAOlmywowJIfmcnvUz35JIHcL
         wgDRv5SYca5ntCm4ZUdbErNXm9c1EjIgQRTXX47lFxnVXhh46eMh3rxQSy/q5DOfUb2a
         QWw7aVrhtzZyb+UeXqk0/brxFNwL3fdJYX6xbTj6U9nkjxUEqDiGHBuGbfMuTNssvPqz
         MR4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=5ZYOEzS+65K8bB/ZHCHtVMV0q6W5qUrvuM4ooNhr7KA=;
        b=kHFYB5HyYCjH36Ubt85Sq2WhF+K85mxiZ22gY+0NgzusCS/yJSwzwiVn5n1GNrJSXV
         T6+RHOULnzConU0nbgAWDfiUEmLlUcvWv3vRwbkppqWe14K25V5aksaltT1wix5wOBq5
         f3SgTxymA7BC7Our6WRTEoBekbIkZlTF5WiLZHd3AqSLOGaod2/SsAAa8qgHj9kgDr/8
         dy23ZkMutdpMbjW0dzv57iEcaIxfdGtzB/PnOrnEfRDCiFFtVOzykCjC4NTi87FtopJm
         ww1qLiKwzmZaWQbxRlsr6Rwkr+7G62O/NwoAnPfq5xOQbO55wNLweyvraWXlLslPmluc
         K/rA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=m+Zhhh6b;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id y12si1093244ybg.5.2019.05.24.14.43.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 May 2019 14:43:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=m+Zhhh6b;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4OLdSlE141964;
	Fri, 24 May 2019 21:43:11 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=date : from : to : cc
 : subject : message-id : references : mime-version : content-type :
 content-transfer-encoding : in-reply-to; s=corp-2018-07-02;
 bh=5ZYOEzS+65K8bB/ZHCHtVMV0q6W5qUrvuM4ooNhr7KA=;
 b=m+Zhhh6bDXlaH1hAoV9gd9ihKiKeb6nlkBYBgRMj+BZ38id0RqowMWRjt6wKtIptu7jM
 V5LvrzcunUIC2M9aHa7Lhz8vwdFsYhJIr+IEpJHXTQJrBNVw2PDwFWns+SUkHrXUhp1z
 ws62Zjw3BrtWx0HiRj+WN/Me+RoLyUUyWZTMKXNVcGUKDmoShFrg1wkG9Yu120lCzOQ6
 zTD5DrSu0fgXVIydHgRcbqeEGca7YgMFmKAsHdS7rqgodWOlU5hztSQOYxxx9gFc2mai
 iEAb3F37E4XWVYZPO3j41WDxYJ3rzu8pBjLswBwpyde6jwpFDyRLsnqmdP/igSiq6gUy 8g== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2120.oracle.com with ESMTP id 2smsk5kgm1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 24 May 2019 21:43:11 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4OLhBln162017;
	Fri, 24 May 2019 21:43:11 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3030.oracle.com with ESMTP id 2smshg3ec9-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 24 May 2019 21:43:10 +0000
Received: from abhmp0022.oracle.com (abhmp0022.oracle.com [141.146.116.28])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4OLh4p9016253;
	Fri, 24 May 2019 21:43:04 GMT
Received: from ca-dmjordan1.us.oracle.com (/10.211.9.48)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 24 May 2019 21:43:04 +0000
Date: Fri, 24 May 2019 17:43:04 -0400
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: "Potyra, Stefan" <Stefan.Potyra@elektrobit.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "Jordan, Tobias" <Tobias.Jordan@elektrobit.com>,
        akpm@linux-foundation.org, vbabka@suse.cz, mhocko@suse.com,
        kirill.shutemov@linux.intel.com, linux-api@vger.kernel.org
Subject: Re: [PATCH] mm: mlockall error for flag MCL_ONFAULT
Message-ID: <20190524214304.enntpu4tvzpyxzfe@ca-dmjordan1.us.oracle.com>
References: <20190522112329.GA25483@er01809n.ebgroup.elektrobit.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190522112329.GA25483@er01809n.ebgroup.elektrobit.com>
User-Agent: NeoMutt/20180323-268-5a959c
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9267 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905240141
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9267 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905240141
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

[ Adding linux-api and some of the people who were involved in the
MCL_ONFAULT/mlock2/etc discussions.  Author of the Fixes patch appears to
have moved on. ]

On Wed, May 22, 2019 at 11:23:37AM +0000, Potyra, Stefan wrote:
> If mlockall() is called with only MCL_ONFAULT as flag,
> it removes any previously applied lockings and does
> nothing else.

The change looks reasonable.  Hard to imagine any application relies on it, and
they really shouldn't be if they are.  Debian codesearch turned up only a few
cases where stress-ng was doing this for unknown reasons[1] and this change
isn't gonna break those.  In this case I think changing the syscall's behavior
is justified.  

> This behavior is counter-intuitive and doesn't match the
> Linux man page.

I'd quote it for the changelog:

  For mlockall():

  EINVAL Unknown  flags were specified or MCL_ONFAULT was specified with‐
         out either MCL_FUTURE or MCL_CURRENT.

With that you can add

Reviewed-by: Daniel Jordan <daniel.m.jordan@oracle.com>

[1] https://sources.debian.org/src/stress-ng/0.09.50-1/stress-mlock.c/?hl=203#L203

