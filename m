Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 04BE6C4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 23:08:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 873F82177E
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 23:08:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="U8ZKu7pF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 873F82177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B6CF16B000C; Thu,  4 Apr 2019 19:08:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B1C0E6B000D; Thu,  4 Apr 2019 19:08:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A0E2F6B000E; Thu,  4 Apr 2019 19:08:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8037C6B000C
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 19:08:47 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id b1so3758230qtk.11
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 16:08:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=mxyilDLNlg1/sM6txmvcxJBT1IrVO6TCewAy95yLK5Y=;
        b=dnFid6RNnV0oQ5UEqHtwD14T1cwQl4QvBYPeIH+xDiKt8f8VUsQrYo5d/0FqMGfF7u
         FpPp1bBosjpiOEFUAYelpAxghIt5n0Mcd9cBtmecUWIA/CfMp5/yaBvo+V3y2FA/sFDA
         pzW9LyIajJh8jhvQ4tf77d15zH3ZX2NwhbfBkpbJNbbw/bkHm3ihMj5bDTCKOjGp7ugz
         mzJRoATLjesFaMQo6Zoffi73T9KFFhg+ei5X5m1bn8UDTr7RbrL7fAAgIH5HfcAUma3K
         jWVc1IkAXG+ZabIemMAX3Ng6iJ86AQJM1q8TqwlMqAMcP821fZ+CJnQSxSaXiJ1BTW+D
         1wmg==
X-Gm-Message-State: APjAAAUYxHtBY2qWL0Ar7Z5hC/HyBGt16ml4DusCWoy4xb/QYJMcqD1V
	53qwilGynvIVacYWobrXNnAZJsYIsQykSbYHm+8JlqmyebmUBJ/+CJXlYe6EX7svZImFeUJbKoN
	0djhLILDG+yFL0WAXUUB59WKQ8c3av9P9n2WWmttpQR0uqyR9FJdmLGeJDd/rvQXg9w==
X-Received: by 2002:a37:a887:: with SMTP id r129mr7594501qke.40.1554419327245;
        Thu, 04 Apr 2019 16:08:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwnwiZ6GWyG6wNbX6EQBkjMQbuRnJwpwdxgoe6DG0JZJWDwIz4gvKUITUPljJ4SegrWZjuG
X-Received: by 2002:a37:a887:: with SMTP id r129mr7594459qke.40.1554419326549;
        Thu, 04 Apr 2019 16:08:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554419326; cv=none;
        d=google.com; s=arc-20160816;
        b=SN3f56MBP+F4IA25kqpNKeNz3NiqE9jDfEfcacZcligHXsCoQxi0nH2aKoq7JTTcBH
         auhEozCHaFdOZJSWY00tE2mcSs7SldNfyc4D6x35ST3eVWimYijmohAclu4shg0z7nQT
         xMM8GYIXojByfuqEG9BhzqX9LqjByhS56UzIAePANlGholcq0l0KMr2WapXjIWNKqJ8F
         5WoRhzPk18BteDRqfhidXAJTrjLIhxOS/uyhld/yMo38oEjlH48pPndffOKzSVdP59vF
         2juSBfJcJaI3/IaN6oUpxJ4y3YcreV0SmgVyrBo3iYr3kDfCOA3xGrLDIIOjZqGW5it8
         YOZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=mxyilDLNlg1/sM6txmvcxJBT1IrVO6TCewAy95yLK5Y=;
        b=Qd+hAJrWWTcw2a8eO8IScQ9GKLsfvkH+sLoIRRz9D+9VeyTNHyqqdr+iXzxVEYFszk
         1Hzmdbe8y6sz47gTe49ugjccGLd2kYO52Apm74vkIdOhX/8gJOC6fTWUy6ukap3MBxDq
         MLZVVR3wfybwsES2df16j1vSKReJQICZt6F7b4BztYnSXwP2PVlFAkVxnZjVZVJalqOZ
         F3W5aiYpBNZ7965NPL5uvCEu/ZGNVG73fo1FY1xmoepm+Rf1ALPdOQWKtsbxtca1w1gK
         OpQarb+UsTc0Zib6hWZv7oe6C3rDH+WtlFCdKyB/PZ2+FZ/3I3gnVqG/f77ORyQ5ttdv
         2bkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=U8ZKu7pF;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id o6si4249777qta.316.2019.04.04.16.08.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 16:08:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=U8ZKu7pF;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x34N4cRi034096;
	Thu, 4 Apr 2019 23:08:38 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=mxyilDLNlg1/sM6txmvcxJBT1IrVO6TCewAy95yLK5Y=;
 b=U8ZKu7pFYsZjWl1frcDpjT6VshGSrKDKziTow/fzjF/V+2WNzLBpKcma65ZyWOl3+Ra3
 GlNjTBxnnDpZ6B6FFPKq97mcVR7KE1fxn1hiQSWVhL0ii9whEC1nGNXLWSOmziYBBdD9
 f01rhL/6ZkIrcLVnjOPdi37iGHhpsy/sA5VjtVceShg+1oP9U31hkKtwr1rCycyDq5gR
 FcMHa52F2v9IoOX/XlaZpgUmckINPHO5aP0eaQ4dqW9V5PQA4CAtYtyAUWR6QTTm83ur
 GSLeVuJxG1xL4hN27jhb4QEAph3kCzLxPklkkMg5EPj8R3OlLQn6hV94yNxuxnKl8+KD gQ== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2rhyvtj0m8-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 04 Apr 2019 23:08:38 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x34N7R1S120620;
	Thu, 4 Apr 2019 23:08:38 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3020.oracle.com with ESMTP id 2rm9mjw8wn-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 04 Apr 2019 23:08:37 +0000
Received: from abhmp0015.oracle.com (abhmp0015.oracle.com [141.146.116.21])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x34N8Zp6025922;
	Thu, 4 Apr 2019 23:08:35 GMT
Received: from [192.168.1.222] (/50.38.38.67)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 04 Apr 2019 16:08:34 -0700
Subject: Re: [PATCH] mm:rmap: use the pra.mapcount to do the check
To: Huang Shijie <sjhuang@iluvatar.ai>, akpm@linux-foundation.org
Cc: kirill.shutemov@linux.intel.com, linux-mm@kvack.org
References: <20190404054828.2731-1-sjhuang@iluvatar.ai>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <de5865e2-a9e4-f0f9-f740-f1301679258a@oracle.com>
Date: Thu, 4 Apr 2019 16:08:33 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190404054828.2731-1-sjhuang@iluvatar.ai>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9217 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904040147
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9217 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904040147
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 4/3/19 10:48 PM, Huang Shijie wrote:
> We have the pra.mapcount already, and there is no need to call
> the page_mapped() which may do some complicated computing
> for compound page.
> 
> Signed-off-by: Huang Shijie <sjhuang@iluvatar.ai>

This looks good to me.  I had to convince myself that there were no
issues if we were operating on a sub-page of a compound-page.  However,
Kirill is the expert here and would know of any subtle issues I may have
overlooked.

-- 
Mike Kravetz

> ---
>  mm/rmap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 76c8dfd3ae1c..6c5843dddb5a 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -850,7 +850,7 @@ int page_referenced(struct page *page,
>  	};
>  
>  	*vm_flags = 0;
> -	if (!page_mapped(page))
> +	if (!pra.mapcount)
>  		return 0;
>  
>  	if (!page_rmapping(page))
> 

