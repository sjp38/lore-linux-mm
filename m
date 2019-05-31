Return-Path: <SRS0=007R=T7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A4D2C04AB6
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 16:59:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 421EB26CA0
	for <linux-mm@archiver.kernel.org>; Fri, 31 May 2019 16:59:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="vaNEY3xb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 421EB26CA0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C81D06B0010; Fri, 31 May 2019 12:59:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C59E46B026F; Fri, 31 May 2019 12:59:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B6EF86B0272; Fri, 31 May 2019 12:59:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 98B7A6B0010
	for <linux-mm@kvack.org>; Fri, 31 May 2019 12:59:20 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id k10so9285061ywb.18
        for <linux-mm@kvack.org>; Fri, 31 May 2019 09:59:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=G82jjtVPtIBiymxHtt3594fMUhRhOyCXS9qt0zROSRs=;
        b=V+T6gFnDXFuOKFI3mA5TrfYKkQJD9QxBJ+bZMlCFSLE+jwVdhHHMLI23U/2sW/Rjur
         Gl57rA1vadWKqCTt6hpXBrDNnS5feG67ajyViMPEwwea024xeBrRH9tRXRlor+XXORbU
         5mx37dWxgo/KM6Nh1FS/S9sdoiOizbjgmwXL6K79OzkmrQ1Nr4oRPkCJ5tIodt3pSVGH
         /Hc6DYrD6X9Zhcw+U00BoxPAL4qY7pO8wTPoIytdCyBl5qbIiQZcLvpS0ilbuk2U5l6c
         gqCJ/sSd71PMrUx5n/i49/xooYoUpOZU+cSBdQCIcedaaa+yLNpCjLpyfvSekGXlKOJ6
         bwTg==
X-Gm-Message-State: APjAAAUEuKUaHum1VxDaqAasUWpD0XiTrU9e4A24+GncETUNOEs3fPQe
	bb5et1YgnFnkL8FrGQVWMG1p3OXy8zFbdmxi7dJL8YSsRwuaNTce5VWJmLvTVmVSkPPb6LLVdsU
	f3Gz+BJGCnf0Sr2Q9hpwEs4IVtT8NV/u6SKGAaIN1KW7jaoJDBBU1ssbek/PPPgqtPA==
X-Received: by 2002:a0d:d342:: with SMTP id v63mr5842050ywd.369.1559321960294;
        Fri, 31 May 2019 09:59:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyFTj0jWcKok8HSIrt3ED+/pOxlj3gBHNOY9i3yM6uUUcvrde5YMTf2tfDDLwaHcdQK4EyK
X-Received: by 2002:a0d:d342:: with SMTP id v63mr5842029ywd.369.1559321959581;
        Fri, 31 May 2019 09:59:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559321959; cv=none;
        d=google.com; s=arc-20160816;
        b=L8BuKDdz4VSDY2Q32dWDZ9C2iX+IDKCRkrFdZxhgHdjBcBti44EWIPy4eHvxCyIQA7
         fiCoudnImlAdjwweEWa8Hj1s8DND6Rk/SjcwCtIA2neDWdVMYrC0cuW1Q8y2KP2wI5Y8
         YN882LCWE7iY3/m9mOz2zrLRSzqGeOP/BDGsFx7qv8TZpvXfAtU7Rn80Bk++xMESDChj
         Adm6T03mre3gtSuSrOcYu3c/Hq9rWli+vWYReqzitsaut3IwBLxWHgkFzCsDDYESZDzT
         6wegmDTEdkw8nEWjlvIfLdksE68PGkXR6UHXk40jMqbeIMxoMcBx4VPXoa5BoDPje3Di
         75vQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=G82jjtVPtIBiymxHtt3594fMUhRhOyCXS9qt0zROSRs=;
        b=CdOSzNIrZbRcG16ZbcJnoWMa2tMj/rrMAzAEZNynTSl60vBoRxWKjQyISjh/6ZjfA7
         Dx2+xEV/QaOwJSItNygz+mHrbfoiOcFgfw4Hkz+ZdkaZiAnfJvX7g3eqMCIglv8nUfYL
         qNPvmIgzP8gXMhntCxFQMTr4cf7NgY4h24PlsVVuZs3Qge1WNxBmDA0/1TshTFAVi8+s
         wr1jgmW420yetjBE3vYEsn1FbNdb4uz/v/CPnwBJLAFRbrXP7ILLGe4/6Mq+bazl5s6C
         h3jq3r0BjYEUBmCBp2NoOVIt8zqy1cJwOua0jxS0TcgW//vbR9iaioXhvhMOpackKMI2
         9WUw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=vaNEY3xb;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 204si2010592ywu.374.2019.05.31.09.59.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 May 2019 09:59:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=vaNEY3xb;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4VGmkRa037317;
	Fri, 31 May 2019 16:59:05 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=G82jjtVPtIBiymxHtt3594fMUhRhOyCXS9qt0zROSRs=;
 b=vaNEY3xbHbsmFj4uuy58MnSzoYNnmBWMZ1uHLJz4TFgQS3PDxWUY7uo0/yb+5cHLLCQI
 GPx/XnsFEsPnQn9U1wJYM1XDXZtZkBSA5i9qKO+NWK5gGJBFA5LeeSsgb1/2jPXiKqU0
 Ifu/u2p8g04sYFmK5eV0CPPxOFSlT7KCzWSvdKifcZ/8RR8VLBpEs73OSYPVr4kfC81D
 EveRMMmF5HRn9+TFQXc35gdIgha+aTQqi2X0T3LXHfMzmagOchgedP58kzYQlVlkeBk/
 tsbLdCCdJQ0krqpBY9ZVH3eytgUQRnKCKvtp05KQHOSWorDRSYve3FvE//mlmiRGkTEc Ig== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2130.oracle.com with ESMTP id 2spw4tyn5e-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 31 May 2019 16:59:05 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4VGvdh1084819;
	Fri, 31 May 2019 16:59:05 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3030.oracle.com with ESMTP id 2ss1fprjt9-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 31 May 2019 16:59:05 +0000
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x4VGx2Fc009144;
	Fri, 31 May 2019 16:59:02 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 31 May 2019 09:59:01 -0700
Subject: Re: [PATCH -mm] mm, swap: Fix bad swap file entry warning
To: "Huang, Ying" <ying.huang@intel.com>,
        Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        Andrea Parri <andrea.parri@amarulasolutions.com>,
        "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>,
        Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>,
        Hugh Dickins <hughd@google.com>
References: <20190531024102.21723-1-ying.huang@intel.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <2d8e1195-e0f1-4fa8-b0bd-b9ea69032b51@oracle.com>
Date: Fri, 31 May 2019 09:59:00 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190531024102.21723-1-ying.huang@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9273 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905310104
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9273 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905310104
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/30/19 7:41 PM, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> Mike reported the following warning messages
> 
>   get_swap_device: Bad swap file entry 1400000000000001
> 
> This is produced by
> 
> - total_swapcache_pages()
>   - get_swap_device()
> 
> Where get_swap_device() is used to check whether the swap device is
> valid and prevent it from being swapoff if so.  But get_swap_device()
> may produce warning message as above for some invalid swap devices.
> This is fixed via calling swp_swap_info() before get_swap_device() to
> filter out the swap devices that may cause warning messages.
> 
> Fixes: 6a946753dbe6 ("mm/swap_state.c: simplify total_swapcache_pages() with get_swap_device()")
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>

Thank you, this eliminates the messages for me:

Tested-by: Mike Kravetz <mike.kravetz@oracle.com>

-- 
Mike Kravetz

