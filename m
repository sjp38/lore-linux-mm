Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0156C43218
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 00:20:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8467820820
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 00:20:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="d4F1P2X1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8467820820
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 113276B026D; Mon, 10 Jun 2019 20:20:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C55F6B026E; Mon, 10 Jun 2019 20:20:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EA71A6B026F; Mon, 10 Jun 2019 20:20:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id C6A7B6B026D
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 20:20:01 -0400 (EDT)
Received: by mail-it1-f197.google.com with SMTP id j83so960704ita.3
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 17:20:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=SN1DHavmoz1vQkJTLVb+wvWfnTmq3aQZzTCx5KVXGak=;
        b=mt9ilZR5FanQ9v5oJJOTur9/yoiWbIiONLuOJ7it+dwfEHu05eOnl3DG7j6QNFeB25
         kzfK5QnmTCgNixXKATK4cFgLTM5ipO8qX1zMdTnXdsF2Sa4h9YmZxgCbzjqgBGrMAiOL
         FH1uL9rLXGiqztYGH4qCDC4+xN3gxk+a4AHFYaQj/fXFso42VIYQaYFkLE7dZbvWvzTB
         9T4c14gzzDxooRzfM4HuQ1aCPEFqPpeOrvK2jLQe+dQokeTzRTtNuSxGviF48CX/9cgZ
         9bRWx+8QwRn9RStf6/mFwhCUQPxF1Ds8XP9S5WCUlPzxYia3BMXKif6Dit0FRN1jH3uB
         9dcg==
X-Gm-Message-State: APjAAAWUAwrOtDzhzGHZGiNiYzZuoF407tHInJWPCq++nzqYf9PO0w7q
	uyN0/4uQAWKPa//ZtmVNwxXi6AyFr1m3tOwuebxQWmwtIQx8++2Dl8hnJQ924bIlq3KtNZWudBV
	mB/P6rTd8MDHRx9J7snaLzQumOyIIFr5Cj22r6WF0ELQ/hF7W1UMnfpNM8ukiGGiZRg==
X-Received: by 2002:a24:94d0:: with SMTP id j199mr15766713ite.160.1560212401609;
        Mon, 10 Jun 2019 17:20:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyACpBTfm6UpMbmLnL7S7NRoH+M7EO7eVdiu0IJF9BOujBNyj4Gcy6Jbmfc3VSb3duqsCO4
X-Received: by 2002:a24:94d0:: with SMTP id j199mr15766692ite.160.1560212401080;
        Mon, 10 Jun 2019 17:20:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560212401; cv=none;
        d=google.com; s=arc-20160816;
        b=gAV6EgNauWLGtbKeg0PhoY/fRDxdIuWIJ5fRXF2+HS8Wpf1xRQ9TymdbIvS9DNxSl3
         qOD8J4HpNxx1dRee62sO0/Ed/rkhU0fH/5e601PcQintj/SYO0FHLqeNRoljt4n2tBL0
         HbhiiiX+dQEnhziQoRwsJ3+uYW5DDaMCSrYLAGkSGl1LX9dOa0b2LHq12SK+a8KGwFvh
         XgN+Jc/sPBUGNywwSludWXHG37mTBGejt61fUtZXVypdN/RTSK2ip+o2zOK7LcuqBqOg
         o1XtO45pAX8Gz2KZ9KFOtGBz65KiCx+5SzmKZSyOPDveY/YP0d8jzRE9BoH6dL4e8lbk
         D64g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=SN1DHavmoz1vQkJTLVb+wvWfnTmq3aQZzTCx5KVXGak=;
        b=IwITXibrEtfbSFI73zX2lozvti4gmZsXUMjCoYb1kOK5hfXp24yDUi3aG4E7qsvH5T
         Mk6B0OYWcug1BvcV98SGrFU+SMT80LhmJKJRjgZ5HfQHyKGH6e9IKM1zaEYdRLW9UTwO
         Yfu4f2Zz92yDEiiMrPYpoHGyE7sqOAcKUCkNb0QG6ZhQI2VlegNgTUkQfb1hhh9dTtDc
         kTLE/ceeeThkrqXUbqLSw4RGEf5t2I7lXMGHUFVMUgItLwKc1xUgk+b44v+/vQwfNQkF
         KlfvCP7IjyZV4DRxNZZ1mo1/mLHZ+seYWfkc97KiaIYFWHN32ghBWTV94B/yFjf8WNpa
         74RA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=d4F1P2X1;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id y3si6847966ion.162.2019.06.10.17.20.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 17:20:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=d4F1P2X1;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5B09Qak178531;
	Tue, 11 Jun 2019 00:19:51 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=SN1DHavmoz1vQkJTLVb+wvWfnTmq3aQZzTCx5KVXGak=;
 b=d4F1P2X1cdzomcjxDD8rWoT8K4BELOdxfIPlPmW8bMauny6na8dpFxQ0mDkhCrEYuRrw
 FkmZvsbz3d2Y7Hc/dzhaVpLL4sXE4fQmHKq+ZeCRr30/Y735i+AjuxdAolrKfmuR3yRP
 nxGd5Z91iaIMAHXSWJ9TRGmQOV08dS0KRFsn1SEWuuV54ukLz+GMBo5kd3DaMVtAWhSU
 ryutHlUL3j1oGSqoNkuqFA439H5ECkXF1QsFZaWb76MqivRXDamIHR/WuQ+oaoqDiOe0
 JJefijaTqIN7ZNWUsCrmQv1Kusjse86kPgk9l/uxSxqE3i3kJ2wKDyXBVW5d4FADRWTB kA== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2120.oracle.com with ESMTP id 2t05nqhtk4-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 00:19:51 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x5B0IEM0043654;
	Tue, 11 Jun 2019 00:19:50 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3020.oracle.com with ESMTP id 2t0p9r0a6x-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 11 Jun 2019 00:19:50 +0000
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x5B0JlsJ032551;
	Tue, 11 Jun 2019 00:19:47 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 10 Jun 2019 17:19:46 -0700
Subject: Re: [PATCH v2 1/2] mm: soft-offline: return -EBUSY if
 set_hwpoison_free_buddy_page() fails
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Michal Hocko <mhocko@kernel.org>, xishi.qiuxishi@alibaba-inc.com,
        "Chen, Jerry T" <jerry.t.chen@intel.com>,
        "Zhuo, Qiuxu"
 <qiuxu.zhuo@intel.com>, linux-kernel@vger.kernel.org
References: <1560154686-18497-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1560154686-18497-2-git-send-email-n-horiguchi@ah.jp.nec.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <8e8e6afc-cddb-9e79-c8ae-c2814b73cbe9@oracle.com>
Date: Mon, 10 Jun 2019 17:19:45 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <1560154686-18497-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9284 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1906110000
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9284 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1906110000
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 6/10/19 1:18 AM, Naoya Horiguchi wrote:
> The pass/fail of soft offline should be judged by checking whether the
> raw error page was finally contained or not (i.e. the result of
> set_hwpoison_free_buddy_page()), but current code do not work like that.
> So this patch is suggesting to fix it.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Fixes: 6bc9b56433b76 ("mm: fix race on soft-offlining")
> Cc: <stable@vger.kernel.org> # v4.19+

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>

To follow-up on Andrew's comment/question about user visible effects.  Without
this fix, there are cases where madvise(MADV_SOFT_OFFLINE) may not offline the
original page and will not return an error.  Are there any other visible
effects?

-- 
Mike Kravetz

