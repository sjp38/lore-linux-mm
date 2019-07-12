Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92E75C742A8
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 07:50:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3846A208E4
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 07:50:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="pbWIwWl1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3846A208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B56B68E0122; Fri, 12 Jul 2019 03:50:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B07F08E00DB; Fri, 12 Jul 2019 03:50:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CE998E0122; Fri, 12 Jul 2019 03:50:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7DDAB8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 03:50:19 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id s9so9698454iob.11
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 00:50:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=KWdd569p7H98s99VGkNt8W1kteSRKpwe7r4VXaES3dU=;
        b=rBxkV3O6wuHIVLNED2MZBEZAcQBv2s8XMKjeUTx+VCkpk+KDycmI1LtWxduwaXnpwE
         V9i3lMYn5gOd3q+5KD+bFZTDXynp3CedsPYg/bivx3ihOIYfHMZmxXcsxHIHSLMTWUs1
         IrqMmu2aWS5nD4s9rEMUhm9+Ra8lNDRPR1ak+mTbZzaeyIa8rHAtn8/mVxMXb03+z+PE
         0jjgv+/pw0cBM2wdLKT2gdZbt99oWTZWFxSwypDsuH7rdb7K9ljFZhNQqBmsD/9JxTde
         SwLJ15r2dzhoS0gVJ+6XbsIKsY7h+HgvqUzFcWQVi3h3LkLs6QTHACoR/7RRJK+ZAZD3
         ExEA==
X-Gm-Message-State: APjAAAXatF2MH2nFVlKZF+SZwbs6hFgiQFDCTkH7RPdeC2LY/OTYyI50
	HyTXVVM+HVamkfA5pThMhZgSXL0m5s2kmbNYFmCPfcHLnEX/+8lxyPIQygb91TdES2sHtByVp5u
	Zu1jjZhoqsNV38yDeoh9MrqYmM9Ii8LYsUjyWreYcXfiF1k01dHHgRhUr8lXHZW4hPg==
X-Received: by 2002:a02:b90e:: with SMTP id v14mr9800977jan.122.1562917819300;
        Fri, 12 Jul 2019 00:50:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWxJDduDRZPQUa2lufleuPiLhMJyu/3zMB1sqrYmKxvU565JCiIarWROl+Tus0Cnl26K/P
X-Received: by 2002:a02:b90e:: with SMTP id v14mr9800939jan.122.1562917818801;
        Fri, 12 Jul 2019 00:50:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562917818; cv=none;
        d=google.com; s=arc-20160816;
        b=Eyk1KeD1a6l3aZqCo5W0Idk2Ac70CyypjRc/P0TM1oGLS9jFZxOCnrZkY23cpHz+7T
         uAEZ8wAu4iWOf4fBkJB4QPpeZOiUuKtc6lG7whiij3qa40YWoYvXNR5EiNqIUoZJN/Bx
         4qtbXw1Xy+UQbtMFth4nK1Vo1/MKPrvz4iqZ7bplgjqsfvml8lMF51thappgBidHfAi6
         C7PlKltzuhkFC3nznbgUYRlka7Fahz7sOf61BN65zFmgnHUhiOm4dhjZmW9CamjXSe5e
         akfz2v0GD+4S2ANwRoZlRGizRDHjrcSwDDBwEn4n1wR1+ixJ3eONJZAMIQSv3dIMo9gs
         b9sA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=KWdd569p7H98s99VGkNt8W1kteSRKpwe7r4VXaES3dU=;
        b=pwIvc9CHkZoUEo10Oh/02L2NEKuj1M/XaHqjg2NmWazOxbhQdkqc7UXX1895JnUKu0
         Qachelh0OPo5WuxLTJouYskeF28ZAjI1uJ1kgspgGqRUeAo2q/kphw+2+SRHQviQfvXB
         jWFApsnvGqLrnz0Z65hctyeFwzBKJshAV8zsbiodvS/g6lOJ4+dzCzyqnruMJIQCcDjh
         lJJANBmfW5J9kMDmhq5d7PlTkljWcEqWy7gWFrUaI0T/XutatToNOtWe2sBWMPa/9bKr
         gliAM/G/fAUBDczksDnWPVwaNvRxPD5MPidimZyh6Yxr1N4NuUHP9uwDnSoGokSz41Ld
         8hvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=pbWIwWl1;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id p5si12805591jam.23.2019.07.12.00.50.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 00:50:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=pbWIwWl1;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6C7nQXn084246;
	Fri, 12 Jul 2019 07:50:08 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=KWdd569p7H98s99VGkNt8W1kteSRKpwe7r4VXaES3dU=;
 b=pbWIwWl1aHu4f+DB6qI+IjeZS3EVzt/ZaLXRb3VkoTvcnyJiSPBjy53GBCqbYAQFWPrE
 ZFldPCuG6PvGbLCXMa7oii7YLCkchEd7W/WtM4uCDu/LDnBGo8SbyWaCaEv4bd+ixN28
 NoLoni2nztIJoXRUZjJlxHi9A3PE+t/uYnhj58XGG/pCqULq9IvI5fYO5axaS1TUaK3t
 /t7VN0yb/w54ud5iNtAVIxAct9/mQj9n3ls6BHu4ywz5o1PeXXtnT23PURm/RzK0pcRD
 yVU4QvmJFLW18ULNLf85ObPX8TtKJypDiK5sDVfaiQisxxxhvtz4uP1JZY/Fb1by7STf EQ== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2120.oracle.com with ESMTP id 2tjkkq424s-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 12 Jul 2019 07:50:08 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6C7lu8S028521;
	Fri, 12 Jul 2019 07:50:08 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3030.oracle.com with ESMTP id 2tmwgyms2d-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 12 Jul 2019 07:50:08 +0000
Received: from abhmp0007.oracle.com (abhmp0007.oracle.com [141.146.116.13])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x6C7o5XQ002589;
	Fri, 12 Jul 2019 07:50:05 GMT
Received: from [10.166.106.34] (/10.166.106.34)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 12 Jul 2019 00:50:04 -0700
Subject: Re: [RFC v2 02/26] mm/asi: Abort isolation on interrupt, exception
 and context switch
To: Andy Lutomirski <luto@amacapital.net>
Cc: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, konrad.wilk@oracle.com,
        jan.setjeeilers@oracle.com, liran.alon@oracle.com, jwadams@google.com,
        graf@amazon.de, rppt@linux.vnet.ibm.com
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
 <1562855138-19507-3-git-send-email-alexandre.chartre@oracle.com>
 <B8AF6DF6-8D39-40F6-8624-6F67EDA4E390@amacapital.net>
From: Alexandre Chartre <alexandre.chartre@oracle.com>
Organization: Oracle Corporation
Message-ID: <42a38126-8ae9-2f9e-6c9e-19998eedb85d@oracle.com>
Date: Fri, 12 Jul 2019 09:50:00 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <B8AF6DF6-8D39-40F6-8624-6F67EDA4E390@amacapital.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9315 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1907120081
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9315 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907120081
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/12/19 2:05 AM, Andy Lutomirski wrote:
> 
>> On Jul 11, 2019, at 8:25 AM, Alexandre Chartre <alexandre.chartre@oracle.com> wrote:
>>
>> Address space isolation should be aborted if there is an interrupt,
>> an exception or a context switch. Interrupt/exception handlers and
>> context switch code need to run with the full kernel address space.
>> Address space isolation is aborted by restoring the original CR3
>> value used before entering address space isolation.
>>
> 
> NAK to the entry changes. That code you’re changing is already known
> to be a bit buggy, and it’s spaghetti. PeterZ and I are gradually
> working on fixing some bugs and C-ifying it. ASI can go on top.
> 

Agree this is spaghetti and I will be happy to move ASI on top. I will keep
an eye for your changes, and I will change the ASI code accordingly.

Thanks,

alex.

