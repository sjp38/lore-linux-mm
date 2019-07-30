Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24B7EC433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 14:07:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9939820651
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 14:07:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="a2laasGI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9939820651
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 084288E0003; Tue, 30 Jul 2019 10:07:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 036058E0001; Tue, 30 Jul 2019 10:07:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E17008E0003; Tue, 30 Jul 2019 10:07:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id BCED78E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 10:07:43 -0400 (EDT)
Received: by mail-vs1-f70.google.com with SMTP id v9so16937450vsq.7
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 07:07:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :openpgp:autocrypt:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=Ce5xL37tcuEyMK1++l5PbIdXt1oAvxgj/4b7X50ueGQ=;
        b=FxpDdV8gldpRXbC4b0IgGvGNJxGASHPG5/aJkDuucdrm9ilYaczBJ6alxG/TElIWLp
         Cm7I6zsy1nnHF6wybVbMJKC+yT1dlovg0XGNPIWKt/2PWlCrtgbFgGhr/gcvpejat1oR
         viNp6LhAET6lN4K+OVvRAOquXYDP67skA7oLg3PkH2z8Ua24Dij1XStqi5R7gA21UH+d
         dNaha32OB0yYjEDAQrv/m+rolyO97QjFT2sM7RZi8PbVglOaKpdKNlNubkrOLIQeHjuO
         vUS9BiY3ATIz/sVMJX3PutbfDI+6ucJc0l8Y477txBJ512b/eMUvhRoVp6Y+zHPC+A0i
         WRvw==
X-Gm-Message-State: APjAAAUpPYzg8LWhsflx5+O5rAbGRwmSViM6YCPwIMnQ3uvP4+pc42ET
	FFBLynSJSOBBmSpolcFIPyokBhlt2gXtxGbC0rLFZmTMaA2Ctq5KM9cR4U9spl+laQTcR8yzVez
	mEA7VU6iPQK1cAoG9dIuGu2OUvsbLsSEdNsgH4vGlMNeM+D7mFvMmRDwLZkN1URLueA==
X-Received: by 2002:a1f:20f:: with SMTP id 15mr43908366vkc.15.1564495663383;
        Tue, 30 Jul 2019 07:07:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqybz0XIhqPHyXFpkuQ7CMNkQJR7g6C54IQxH/xvrVF27Mgx0A9tw76DAwKatJ/4poXNhtR+
X-Received: by 2002:a1f:20f:: with SMTP id 15mr43908318vkc.15.1564495662377;
        Tue, 30 Jul 2019 07:07:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564495662; cv=none;
        d=google.com; s=arc-20160816;
        b=v60CHljmwZOmQ7PdFIN3JCBU9PzFO2kofYJ8sChhteZBVnEixYNcXnPaYtRkDyem36
         w5Cswcy9ChJMdpoKKzLcNj+7ul+ObGVtmIegMGHTusM/PNOr5XbDOXo7hhwdhq9/3W36
         pl42l5wGnYWvTLgsmlLPxJWTY1tx4XGr5mavWpy6rMFYSJyGrX1BMFt8Pho+ZGfPAlP+
         Gwv7unsxY0QgCA79qTpMrhSArvRx11lEynRB7q34jU2sT0/jw6JNRoqryjae1CSDbmhZ
         5TAFu/7sitLGVGv000KxR+crjjnhGCI0N0lmcPeBQTFuV5E6K2iKKhGijgjuPv5FLWAo
         POzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject:dkim-signature;
        bh=Ce5xL37tcuEyMK1++l5PbIdXt1oAvxgj/4b7X50ueGQ=;
        b=LH5yhjsHKsW8r69Q2BPwcTJm6w9ThkrBpcou7y+i4tBQz75pJDIiuZ7ce7uzBtk8DE
         4GvTNMXmw/qPk8yswf1f0TUirPpNqtaGJIv8Ji/6UjYENldo+v55YhLmwrRuNd+t6D01
         o+ci+RvOKMCQS1JZ2bBQ0lpFMaD2/ilOZrthsdl21uMyBvabCXuv7AYFaKeWVZY+tXw+
         WqZbe8kRloJ8GmJmUVZ45TWFz098AcCIIBaxchDpO+4Qn0GMftYlB9jYKnLyymCcs+Q9
         GFIUoPNqYa374xLX8izlEP97Ofo+gwNDCioh58DoEYgRNwNRalWaBCje5w/DS2RllwE2
         62Dg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=a2laasGI;
       spf=pass (google.com: domain of boris.ostrovsky@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=boris.ostrovsky@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id m22si15688445vsj.373.2019.07.30.07.07.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 07:07:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of boris.ostrovsky@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=a2laasGI;
       spf=pass (google.com: domain of boris.ostrovsky@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=boris.ostrovsky@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6UDxCk7155283;
	Tue, 30 Jul 2019 14:06:01 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=Ce5xL37tcuEyMK1++l5PbIdXt1oAvxgj/4b7X50ueGQ=;
 b=a2laasGIQ9wUJlsQNTqZQq+U22np4QmwoE7caUUti16u4m/6ymp3Ka4V3CPa7qllTMw4
 bir31g27j/KpH2GPrcXH38RoIhTOk0HDrlgsBvU7TeWMcBTMoyASi/bBclgryavrMDyz
 Xuf95p8Nj0CZAMp4VjVVS+ISl1okDp0ch/Eav5kmrRaYBKADhpT2YbdqNpPb1YwH+miS
 ijm9ayYrezYiYdORudk3D2hw0BtDouPZzv8BaBlnQ4MsGPtGtczNJ/g+9DBP5YtNk/4g
 wwsqo2owbWkX2icI4BotFbeD0DkRvnD1skr1tLBiK/Em7EJ98VaIiEX1hUFdVKRyckyx Ow== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2120.oracle.com with ESMTP id 2u0ejpeq2j-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 30 Jul 2019 14:06:01 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6UDwCtO131102;
	Tue, 30 Jul 2019 14:06:01 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3030.oracle.com with ESMTP id 2u0xv876un-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 30 Jul 2019 14:06:01 +0000
Received: from abhmp0005.oracle.com (abhmp0005.oracle.com [141.146.116.11])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x6UE5sXI002501;
	Tue, 30 Jul 2019 14:05:54 GMT
Received: from bostrovs-us.us.oracle.com (/10.152.32.65)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 30 Jul 2019 07:05:54 -0700
Subject: Re: [Xen-devel] [PATCH v4 8/9] xen/gntdev.c: Convert to use
 vm_map_pages()
To: Souptick Joarder <jrdr.linux@gmail.com>,
        =?UTF-8?Q?Marek_Marczykowski-G=c3=b3recki?= <marmarek@invisiblethingslab.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@suse.com>,
        Juergen Gross <jgross@suse.com>,
        Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com,
        xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org,
        Linux-MM <linux-mm@kvack.org>
References: <20190215024830.GA26477@jordon-HP-15-Notebook-PC>
 <20190728180611.GA20589@mail-itl>
 <CAFqt6zaMDnpB-RuapQAyYAub1t7oSdHH_pTD=f5k-s327ZvqMA@mail.gmail.com>
 <CAFqt6zY+07JBxAVfMqb+X78mXwFOj2VBh0nbR2tGnQOP9RrNkQ@mail.gmail.com>
 <20190729133642.GQ1250@mail-itl>
 <CAFqt6zZN+6r6wYJY+f15JAjj8dY+o30w_+EWH9Vy2kUXCKSBog@mail.gmail.com>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Openpgp: preference=signencrypt
Autocrypt: addr=boris.ostrovsky@oracle.com; prefer-encrypt=mutual; keydata=
 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
 Jg6OxFYd01z+a+oL
Message-ID: <bf02becc-9db0-bb78-8efc-9e25cc115237@oracle.com>
Date: Tue, 30 Jul 2019 10:05:42 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CAFqt6zZN+6r6wYJY+f15JAjj8dY+o30w_+EWH9Vy2kUXCKSBog@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9334 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1907300146
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9334 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1907300146
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/30/19 2:03 AM, Souptick Joarder wrote:
> On Mon, Jul 29, 2019 at 7:06 PM Marek Marczykowski-Górecki
> <marmarek@invisiblethingslab.com> wrote:
>> On Mon, Jul 29, 2019 at 02:02:54PM +0530, Souptick Joarder wrote:
>>> On Mon, Jul 29, 2019 at 1:35 PM Souptick Joarder <jrdr.linux@gmail.com> wrote:
>>>> On Sun, Jul 28, 2019 at 11:36 PM Marek Marczykowski-Górecki
>>>> <marmarek@invisiblethingslab.com> wrote:
>>>>> On Fri, Feb 15, 2019 at 08:18:31AM +0530, Souptick Joarder wrote:
>>>>>> Convert to use vm_map_pages() to map range of kernel
>>>>>> memory to user vma.
>>>>>>
>>>>>> map->count is passed to vm_map_pages() and internal API
>>>>>> verify map->count against count ( count = vma_pages(vma))
>>>>>> for page array boundary overrun condition.
>>>>> This commit breaks gntdev driver. If vma->vm_pgoff > 0, vm_map_pages
>>>>> will:
>>>>>  - use map->pages starting at vma->vm_pgoff instead of 0
>>>> The actual code ignores vma->vm_pgoff > 0 scenario and mapped
>>>> the entire map->pages[i]. Why the entire map->pages[i] needs to be mapped
>>>> if vma->vm_pgoff > 0 (in original code) ?
>> vma->vm_pgoff is used as index passed to gntdev_find_map_index. It's
>> basically (ab)using this parameter for "which grant reference to map".
>>
>>>> are you referring to set vma->vm_pgoff = 0 irrespective of value passed
>>>> from user space ? If yes, using vm_map_pages_zero() is an alternate
>>>> option.
>> Yes, that should work.
> I prefer to use vm_map_pages_zero() to resolve both the issues. Alternatively
> the patch can be reverted as you suggested. Let me know you opinion and wait
> for feedback from others.
>
> Boris, would you like to give any feedback ?

vm_map_pages_zero() looks good to me. Marek, does it work for you?

-boris


