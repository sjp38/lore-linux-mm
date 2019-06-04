Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1861AC282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 13:39:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B33B724B0A
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 13:39:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B33B724B0A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.vnet.ibm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 13FD86B0269; Tue,  4 Jun 2019 09:39:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F1AF6B026B; Tue,  4 Jun 2019 09:39:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F22E06B026C; Tue,  4 Jun 2019 09:39:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id BE1726B0269
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 09:39:39 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 14so12417771pgo.14
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 06:39:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :subject:from:in-reply-to:date:cc:content-transfer-encoding
         :references:to:message-id;
        bh=y3gYFTyfftk/Ecmlo+AW97S+gHW1XBHjcEWP5Sqb1FM=;
        b=MJHYgsyaz4KFWoh1XlcVSHvTN7ALMVKsk0WgSASG8VM9zOiI9yptb5zE3cqdNQKBMb
         a0sY3uhE4R2ZgJQFToCskrMm049rGJVVFJPbRT+Y8kHaVfBorRLtz6NBf56+6ofklOt0
         Vhb3jIjtYwK166y2Og6l97eE0tAp1NL8rbOMrfZRhdI5mFjGwkH5DA+57abLUDVcy7xk
         3Edtcv52z+PJNbpCzoGSFzygN/xzT5TcbKnBOWBXJe0KWa5AlEulzZp/O8fLmbap9x8U
         68KFLZmHmHe9wVli15vundnWFQaUnI7PrC579dksoqdkRrFl0cx1iuu5z6CQxKggf5Vr
         zNPw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of sachinp@linux.vnet.ibm.com) smtp.mailfrom=sachinp@linux.vnet.ibm.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
X-Gm-Message-State: APjAAAWsl6ltr9oFRUio0JAZ4eNb9hWSeXx/ekWm5Isrrb2uTyryacFh
	NuMGholxIPfI7UmrLWgRah0EhhcRFDlW0m6DJNLu9cFs/OIHRfFqlnkL13tQfYcb/s61M/anHqS
	CTp14sOgftY2gtwSJVxoFjRoq8V03/LqGqrYXOiVsEJRy17BmOwk9Pl9HBD4F4As=
X-Received: by 2002:a17:902:aa0a:: with SMTP id be10mr35829977plb.293.1559655579456;
        Tue, 04 Jun 2019 06:39:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz+6yZr1rh8Tk6VihjrDe4d9JTCZ3HDJAxONZgJ1F58mTusVGGLGiyIPkFnyIhnezfj+yzz
X-Received: by 2002:a17:902:aa0a:: with SMTP id be10mr35829929plb.293.1559655578699;
        Tue, 04 Jun 2019 06:39:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559655578; cv=none;
        d=google.com; s=arc-20160816;
        b=jMh3ZOInbbhhtsmDTqtqSNXOqAEps7kQJSwwIOUvzAv27uOsCSuIiYNb5IN7fhLOG8
         kUhhfTn5uIaU+b0jxI7z2KCBEmYO2Q90uALRQWn+/FkMrigdqVE7+l6QxbYL2BsmUH7W
         0JeFZAIZ5+0tq0XnLod9enfLBjyzJvzU90X1hn3TOeBqGGvLRe5mEJe/xMB5D61qNbuO
         oec2Gq7N+9zkg669YGCXxDUql8QVO9+pJlbFu6AwqoaMwW6rt4G6ck6vsMJbVlivz30p
         oDMXOkWKdzRN58UGIfLcqoiFp/J+3LP20g7Cat7lNdqcfadWrToDKAXGCcEjumOjY1ll
         uzrg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:to:references:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version;
        bh=y3gYFTyfftk/Ecmlo+AW97S+gHW1XBHjcEWP5Sqb1FM=;
        b=yfjOGdzLxFjNBGCuUH/CHj2P6NjU+4HqLVELkrZ0rIctbvBT+aHVA6NZ4JS+v0SfQk
         isgaOkfutJLE8+u0AknsG3k57DMPqG0ehrHkMgK3DrYFWOEmEyVmQQiXA1FlSJ2pLWsg
         sQiPCl5cXi1N9QXbzLYQ/VHy2/8P4rJf3ouyKtpqWhJYKLyVKWMT2QMTa1yGMhrh7Lzm
         M8hq0KaVPaXvHcO6/JO+Kf/aCfN/0CCasqi6vh06lGlw+V7zB72Ri0Yp50K/HKmQc868
         IbaP07eOUm2ELD80kYPn9MVGav35hC2dcfS1bueDT/ISSEqSUfYPJdZ6IMudR55X7HK4
         ImbA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of sachinp@linux.vnet.ibm.com) smtp.mailfrom=sachinp@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c8si24252096pfn.208.2019.06.04.06.39.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 06:39:38 -0700 (PDT)
Received-SPF: neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of sachinp@linux.vnet.ibm.com) client-ip=148.163.156.1;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 148.163.156.1 is neither permitted nor denied by best guess record for domain of sachinp@linux.vnet.ibm.com) smtp.mailfrom=sachinp@linux.vnet.ibm.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=ibm.com
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x54DYPdM122474
	for <linux-mm@kvack.org>; Tue, 4 Jun 2019 09:39:37 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2swq74evyn-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Jun 2019 09:39:36 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sachinp@linux.vnet.ibm.com>;
	Tue, 4 Jun 2019 14:39:33 +0100
Received: from b06cxnps4075.portsmouth.uk.ibm.com (9.149.109.197)
	by e06smtp01.uk.ibm.com (192.168.101.131) with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted;
	(version=TLSv1/SSLv3 cipher=AES256-GCM-SHA384 bits=256/256)
	Tue, 4 Jun 2019 14:39:29 +0100
Received: from d06av26.portsmouth.uk.ibm.com (d06av26.portsmouth.uk.ibm.com [9.149.105.62])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id x54DdS7J50987256
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 4 Jun 2019 13:39:28 GMT
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id AF048AE04D;
	Tue,  4 Jun 2019 13:39:28 +0000 (GMT)
Received: from d06av26.portsmouth.uk.ibm.com (unknown [127.0.0.1])
	by IMSVA (Postfix) with ESMTP id 69768AE056;
	Tue,  4 Jun 2019 13:39:27 +0000 (GMT)
Received: from [9.102.21.242] (unknown [9.102.21.242])
	by d06av26.portsmouth.uk.ibm.com (Postfix) with ESMTP;
	Tue,  4 Jun 2019 13:39:27 +0000 (GMT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 12.4 \(3445.104.11\))
Subject: Re: [POWERPC][next-20190603] Boot failure : Kernel BUG at
 mm/vmalloc.c:470
From: Sachin Sant <sachinp@linux.vnet.ibm.com>
In-Reply-To: <20190604202918.17a1e466@canb.auug.org.au>
Date: Tue, 4 Jun 2019 19:09:26 +0530
Cc: linuxppc-dev@lists.ozlabs.org, linux-next@vger.kernel.org,
        linux-mm@kvack.org, "Uladzislau Rezki (Sony)" <urezki@gmail.com>,
        linux-kernel@vger.kernel.org
Content-Transfer-Encoding: quoted-printable
References: <9F9C0085-F8A4-4B66-802B-382119E34DF5@linux.vnet.ibm.com>
 <20190604202918.17a1e466@canb.auug.org.au>
To: Stephen Rothwell <sfr@canb.auug.org.au>
X-Mailer: Apple Mail (2.3445.104.11)
X-TM-AS-GCONF: 00
x-cbid: 19060413-4275-0000-0000-0000033C9377
X-IBM-AV-DETECTION: SAVI=unused REMOTE=unused XFE=unused
x-cbparentid: 19060413-4276-0000-0000-0000384CA27D
Message-Id: <88ADCAAE-4F1A-49FE-A454-BBAB12A88C70@linux.vnet.ibm.com>
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-04_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=outbound_notspam policy=outbound score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=854 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906040092
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On 04-Jun-2019, at 3:59 PM, Stephen Rothwell <sfr@canb.auug.org.au> =
wrote:
>=20
> Hi Sachin,
>=20
> On Tue, 4 Jun 2019 14:45:43 +0530 Sachin Sant =
<sachinp@linux.vnet.ibm.com> wrote:
>>=20
>> While booting linux-next [next-20190603] on a POWER9 LPAR following
>> BUG is encountered and the boot fails.
>>=20
>> If I revert the following 2 patches I no longer see this BUG message
>>=20
>> 07031d37b2f9 ( mm/vmalloc.c: switch to WARN_ON() and move it under =
unlink_va() )
>> 728e0fbf263e ( mm/vmalloc.c: get rid of one single unlink_va() when =
merge )
>=20
> This latter patch has been fixed in today's linux-next =E2=80=A6

Thanks Stephen.=20
With today=E2=80=99s next (20190604) I no longer see this issue.

Thanks
-Sachin=

