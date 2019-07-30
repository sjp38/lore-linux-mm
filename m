Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5FA6C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 19:57:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6320420659
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 19:57:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="OnYhNHNS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6320420659
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC5608E0005; Tue, 30 Jul 2019 15:57:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E76578E0001; Tue, 30 Jul 2019 15:57:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D16AE8E0005; Tue, 30 Jul 2019 15:57:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id AED808E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 15:57:34 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id k31so59525413qte.13
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 12:57:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :openpgp:autocrypt:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=q3a4x4yMF21FwXKdkk1r+Un/1eIYu8QFSlUw4Wtql1s=;
        b=k/bm756wOS1xeuW1t9Havs5j22J7mABuzKxt/pXY9s/yUnd9Kq2j05a6t4sWkDRkN5
         QDZgMNs7SWMLaMFS/sWD/4x9Q3bRaiscgAv3+ouG4d/rz69Txvj2iJFqNZ6Ih2R1YBT9
         +g9kdU/hQgp2HT+pZgV1zJ/RWdYfrkrhu+SQcZjgUPcoc3OY2gOC+G8pEzf6SgPD1WxK
         mR9e0pfiLvOuS6WPrCnUe0ZArrZw6dwroJs3n7gLCORW2sb0L2W4Bj6KtB4+j3ZcnXTD
         5Zij4FIGD0RPjTHpQe0slDFCJ5aEpFWiGTxN4a5XY1RAy9DLJnqldOyacBA3bv9U800E
         5SOA==
X-Gm-Message-State: APjAAAXRHRwxO++9U54oTvTH2xHc/LsPae9/8SfFVHrAObkGuLlfVUnx
	lm6nMNESINxdTghgxOLCf8PCCNQ3TPn4DAWYYC1BF7nw4u6l8NeO0AcLaHG5los8viJM56GhO6N
	t/T7kvJ7ieGay1bHhQADGcC6arhCrHyyCl2WqxbnPxC1sImdRj70YoCIHhKtYTzeMXA==
X-Received: by 2002:a37:9a97:: with SMTP id c145mr80009119qke.309.1564516654376;
        Tue, 30 Jul 2019 12:57:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw1tW9wBRC2Cu4rUQrN9luzZCAUcUznvJs5IsqdK1vl+zfTIMdUFT6q1JvklQ/lD1kZgcWu
X-Received: by 2002:a37:9a97:: with SMTP id c145mr80009100qke.309.1564516653505;
        Tue, 30 Jul 2019 12:57:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564516653; cv=none;
        d=google.com; s=arc-20160816;
        b=J62CYTgKxnYyYlyA+/K+Hdqk5p4/MxlMYEHDu91xUtqUli7LxCxE+3v8ymD9LKYG/d
         DBl581wQRyFGbI6XNQhIar4+Hew24QAgihL/3bL/wUXDvNuLGy07MR2eJ3HO3dQ/SQC7
         wKjAMnFIsrvPFcdQ1Re/raInMsA+1Py20lzDE9Bfd6uwj2BxO1lDrofdAPZzXrY/QRVx
         oQ200EL3UOl2zHqv7f+LsoyRttSwInbn3lwvRrwa3eCj1lnn4QzKITgW8THXUEAPrsa1
         MsPaMm/XmmQQVOqXoGWcDMbbxnr9NHI28zlOVOCVmbaIngH6+JPrQ1iaIyd7QenGp6CW
         hS7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject:dkim-signature;
        bh=q3a4x4yMF21FwXKdkk1r+Un/1eIYu8QFSlUw4Wtql1s=;
        b=HDdEG83loSXj4uZi/ak4sqQzlj0GvjIN6AMnnCeiHo211BmuLnrj75IKrxIYdMVC2k
         hw4NB5RC87eW/tfOMFn5hlLuRXu4tnezXS//QbcUJB4GlFeoweIY2MhTk02GtxfOjjLi
         Ys+6d0F5FOtaAR8GmVInbVXi44gUX+XP/81j3euvDmzT7lIa9eZD04niGt//eejgIfew
         PWKs6wLJf/Ux4lBm1hYTSlYZ0nH+vgkAw0kgoo0J5yHqlOtYxwVA/SWrB+eWYLEgVVQB
         kfN+jrLWwXSLfh7UptMrK8y4jMs695yxB74cFtKyq1x5rjr4KZNK/AU28qlTzsqid/3f
         GQzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=OnYhNHNS;
       spf=pass (google.com: domain of boris.ostrovsky@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=boris.ostrovsky@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id v14si40979921qta.45.2019.07.30.12.57.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 12:57:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of boris.ostrovsky@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=OnYhNHNS;
       spf=pass (google.com: domain of boris.ostrovsky@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=boris.ostrovsky@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6UJsjZG001485;
	Tue, 30 Jul 2019 19:57:09 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=q3a4x4yMF21FwXKdkk1r+Un/1eIYu8QFSlUw4Wtql1s=;
 b=OnYhNHNSJ9oLP1qdIHkrZIb1JnF281ruQ82ogzXsDe9MCmS5r0bIAjxBwT4UfC2WSxT+
 B+ltjgJIkXX255mtn5e9GuQa+aVyoVpz0Wg9R8lfuK2fKKOzNAMe2m4z/69g4wxSRlj+
 DqQv8haLHwAtAS3OATHASm5dZZm7efbYTMgNRDauOkwIfinc5PPZOr3Yg/IAA90T9uUJ
 /yRlM8wluS1iOnPwz/EizEFT8SkZ2Emx0OeYwPBtkb7xagpIPDJAiD2bQ9RFpcCGOvxq
 Ra0YSdTD0+XsUiKylwl2A2MVU0C9BChtLkAMDNYzJoaorfz0z+tsavzZOg+NgXOkRmt2 rw== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2u0e1trvkx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 30 Jul 2019 19:57:08 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6UJqk15040897;
	Tue, 30 Jul 2019 19:57:08 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3020.oracle.com with ESMTP id 2u2jp4awp0-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 30 Jul 2019 19:57:07 +0000
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x6UJv3cw001033;
	Tue, 30 Jul 2019 19:57:03 GMT
Received: from bostrovs-us.us.oracle.com (/10.152.32.65)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 30 Jul 2019 12:57:02 -0700
Subject: Re: [PATCH] xen/gntdev.c: Replace vm_map_pages() with
 vm_map_pages_zero()
To: Souptick Joarder <jrdr.linux@gmail.com>, jgross@suse.com,
        sstabellini@kernel.org, marmarek@invisiblethingslab.com
Cc: willy@infradead.org, akpm@linux-foundation.org, linux@armlinux.org.uk,
        linux-mm@kvack.org, xen-devel@lists.xenproject.org,
        linux-kernel@vger.kernel.org, stable@vger.kernel.org,
        gregkh@linuxfoundation.org
References: <1564511696-4044-1-git-send-email-jrdr.linux@gmail.com>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Openpgp: preference=signencrypt
Autocrypt: addr=boris.ostrovsky@oracle.com; prefer-encrypt=mutual; keydata=
 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
 Jg6OxFYd01z+a+oL
Message-ID: <a99b3c56-589d-e3b7-5337-0ea94ee83c34@oracle.com>
Date: Tue, 30 Jul 2019 15:56:51 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <1564511696-4044-1-git-send-email-jrdr.linux@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9334 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1907300202
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9334 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1907300202
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/30/19 2:34 PM, Souptick Joarder wrote:
> 'commit df9bde015a72 ("xen/gntdev.c: convert to use vm_map_pages()")'
> breaks gntdev driver. If vma->vm_pgoff > 0, vm_map_pages()
> will:
>  - use map->pages starting at vma->vm_pgoff instead of 0
>  - verify map->count against vma_pages()+vma->vm_pgoff instead of just
>    vma_pages().
>
> In practice, this breaks using a single gntdev FD for mapping multiple
> grants.
>
> relevant strace output:
> [pid   857] ioctl(7, IOCTL_GNTDEV_MAP_GRANT_REF, 0x7ffd3407b6d0) = 0
> [pid   857] mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED, 7, 0) =
> 0x777f1211b000
> [pid   857] ioctl(7, IOCTL_GNTDEV_SET_UNMAP_NOTIFY, 0x7ffd3407b710) = 0
> [pid   857] ioctl(7, IOCTL_GNTDEV_MAP_GRANT_REF, 0x7ffd3407b6d0) = 0
> [pid   857] mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_SHARED, 7,
> 0x1000) = -1 ENXIO (No such device or address)
>
> details here:
> https://github.com/QubesOS/qubes-issues/issues/5199
>
> The reason is -> ( copying Marek's word from discussion)
>
> vma->vm_pgoff is used as index passed to gntdev_find_map_index. It's
> basically using this parameter for "which grant reference to map".
> map struct returned by gntdev_find_map_index() describes just the pages
> to be mapped. Specifically map->pages[0] should be mapped at
> vma->vm_start, not vma->vm_start+vma->vm_pgoff*PAGE_SIZE.
>
> When trying to map grant with index (aka vma->vm_pgoff) > 1,
> __vm_map_pages() will refuse to map it because it will expect map->count
> to be at least vma_pages(vma)+vma->vm_pgoff, while it is exactly
> vma_pages(vma).
>
> Converting vm_map_pages() to use vm_map_pages_zero() will fix the
> problem.
>
> Marek has tested and confirmed the same.

Cc: stable@vger.kernel.org # v5.2+
Fixes: df9bde015a72 ("xen/gntdev.c: convert to use vm_map_pages()")

> Reported-by: Marek Marczykowski-Górecki <marmarek@invisiblethingslab.com>
> Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
> Tested-by: Marek Marczykowski-Górecki <marmarek@invisiblethingslab.com>


Reviewed-by: Boris Ostrovsky <boris.ostrovsky@oracle.com>


> ---
>  drivers/xen/gntdev.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/xen/gntdev.c b/drivers/xen/gntdev.c
> index 4c339c7..a446a72 100644
> --- a/drivers/xen/gntdev.c
> +++ b/drivers/xen/gntdev.c
> @@ -1143,7 +1143,7 @@ static int gntdev_mmap(struct file *flip, struct vm_area_struct *vma)
>  		goto out_put_map;
>  
>  	if (!use_ptemod) {
> -		err = vm_map_pages(vma, map->pages, map->count);
> +		err = vm_map_pages_zero(vma, map->pages, map->count);
>  		if (err)
>  			goto out_put_map;
>  	} else {

