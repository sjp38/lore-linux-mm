Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F185C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 21:26:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2FDA120873
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 21:26:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="grovnzlG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2FDA120873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC33E6B0006; Mon, 13 May 2019 17:26:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A73326B0008; Mon, 13 May 2019 17:26:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 961E66B000A; Mon, 13 May 2019 17:26:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7A1776B0006
	for <linux-mm@kvack.org>; Mon, 13 May 2019 17:26:04 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id e126so10860277ioa.8
        for <linux-mm@kvack.org>; Mon, 13 May 2019 14:26:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:subject:from
         :in-reply-to:date:cc:content-transfer-encoding:message-id:references
         :to;
        bh=565YBW81DzfaRDIS43k2HzjR+yOfbcWDWWoM7zcskn0=;
        b=bCcJum55W8apJ9ccKenGv2btomj2INzVhe8EHO+Ult6SdQNi4iSV+PQzinzskg7Bd6
         EJ0rNVl4BdTgCtVVDvw/hZmABmptWqmMx+V/q5m5j5KM5zSmcH7ye3jTsVtfuNoOJCSn
         czG/vfw4MLeOk7KbuQ52RahXwl7UfSlok/PjCf+oLYjLjwUctLOIApgqESqPwO6DnEfH
         4RZ3phDMdrBFnobsQ4cnOTYKJJwtIs5kDUxTa/M9TOpfrKG7wyqZ8G94r/VtTgpCf2WQ
         rBVuwFBchgeXPbYS4MwtQ4Wkv2VEIpOsOa+N/qt+P4aVh8qvT4pAZqJ3WGixHCcfy8HE
         39Lg==
X-Gm-Message-State: APjAAAWDfcCSlZTfesYqYp48HlIEEEPuC6j5VYgHQBAS00n/NEoOhoif
	sibgJETqLSQ61d01IB6K/stZftTm6Yia92Ka22a3Q7vjKtArMhQyZq7N9wA25pwi7yocBg/74Zs
	31N5sE5goFsHrI1t7LWkZBuGOLvgynhgsqAQbnJNzLz7APvNC8+l+bd1eztNICDPwOA==
X-Received: by 2002:a24:354c:: with SMTP id k73mr992572ita.175.1557782763801;
        Mon, 13 May 2019 14:26:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzLqbdDvhSwQFtGzewdyRgnUpTSwd8LlJgVrA1Bu/cj+Gfi4OkG8kf57HKv8iBkNAgZCXd5
X-Received: by 2002:a24:354c:: with SMTP id k73mr992529ita.175.1557782763132;
        Mon, 13 May 2019 14:26:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557782763; cv=none;
        d=google.com; s=arc-20160816;
        b=Yq0rmPAKqrbVvfhDLrrNCy+dIl2pPQMbH5eGin+8lgDMsnyRC1eBxTkgcQVpo0cCSV
         IRpjpiZ9U0XT2I4/9Qr13/3o4y5LOWV8ltF1PVpqaoRtp2lXbM+11OW3IaIoLXfiqsIY
         ewiO4d+gUvrd6/gR1cVEqOIE/Jd7tVsnIZBmuVyMGuIBAsn4CnXJ+1PwWiUPXf/xu63p
         OtenEz91b8ziznDItO7EFRthKPbg8XJ2ywIaf3CrEmHzaxzEXgnTH7ljhBk/59IcHh6F
         I99t1U4cWYboQLiP1z9XHzHWkEWuMU7lmBKAhLfxGc/8tV0Qz7J+AEi2qBmKT6a6HEld
         /K5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=to:references:message-id:content-transfer-encoding:cc:date
         :in-reply-to:from:subject:mime-version:dkim-signature;
        bh=565YBW81DzfaRDIS43k2HzjR+yOfbcWDWWoM7zcskn0=;
        b=c39s3Dir/9oBSUnrA2yBoe9WPUcDEkBqPHOHEJzMyOe119RXgYHyg7YiZFp8eQ9rjl
         PrCwHWTqRLY1A/jzyuLVOk38yP0ZnfaJiTvnDkGPQ8qzIp6LnhQ0g8P4NFmQhwnPyHIg
         RsUzvnkeMtoVFgeA9ygxxUkGCj1VkVSs3MdhdXd5cqRG93wC+EAoavV3jarfBKFkge7X
         zoq7idqbX6x7plxs7FTfAn/0H2y2szzkOHJhq+5GnX2KAByDDYzYEtuClW6ne3osuWCb
         Sw5RqqKfRUu6ugnwLILSRSWv4qzMfzp5fUuZqpegtSc9IID/GOXdWv2ZdSIcR+xIIkme
         TUCg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=grovnzlG;
       spf=pass (google.com: domain of liran.alon@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=liran.alon@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id b2si368974iti.141.2019.05.13.14.26.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 May 2019 14:26:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of liran.alon@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=grovnzlG;
       spf=pass (google.com: domain of liran.alon@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=liran.alon@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DLOIfI163779;
	Mon, 13 May 2019 21:25:54 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=565YBW81DzfaRDIS43k2HzjR+yOfbcWDWWoM7zcskn0=;
 b=grovnzlGNhoWxg5qTfZqqCe1IbYlscPPaFCoCsuR8tt3ASzDgZxK2+mT55ONjtQpCEzY
 kfB5uJIm7OzXwBf4+8TE3xSbFPPVcOCDVWNVFli9RyNtmRNYhiKlGCNLURZHUOscPclr
 IYNal+CRZA/SCX4yPG2Zpsri3AT60IdEClhmHHTYUgtZ3dAmQr+9vx9HV06zYb8AszYn
 9FRvfVgMvL0QV+oO4S7ODYaqwUl2XjF2+9Wo5jDYi7dTaDvu181uHwWAfiIBxuoIDcUx
 2VvBeh+jiKiBWjHJ9ibL/22dVxSBMC832kGL/8a4Y5k8XxNOcY+NvuyxL2Iy8p7Lf8mn RQ== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2120.oracle.com with ESMTP id 2sdq1q9ry6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 21:25:54 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4DLPIdA126929;
	Mon, 13 May 2019 21:25:53 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3020.oracle.com with ESMTP id 2se0tvsthj-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 13 May 2019 21:25:53 +0000
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4DLPpxg006777;
	Mon, 13 May 2019 21:25:52 GMT
Received: from [192.168.14.112] (/79.180.238.224)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 13 May 2019 14:25:51 -0700
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.1 \(3445.4.7\))
Subject: Re: [RFC KVM 24/27] kvm/isolation: KVM page fault handler
From: Liran Alon <liran.alon@oracle.com>
In-Reply-To: <20190513151500.GY2589@hirez.programming.kicks-ass.net>
Date: Tue, 14 May 2019 00:25:44 +0300
Cc: Alexandre Chartre <alexandre.chartre@oracle.com>, pbonzini@redhat.com,
        rkrcmar@redhat.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de,
        hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, konrad.wilk@oracle.com,
        jan.setjeeilers@oracle.com, jwadams@google.com
Content-Transfer-Encoding: quoted-printable
Message-Id: <13F2FA4F-116F-40C6-9472-A1DE689FE061@oracle.com>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <1557758315-12667-25-git-send-email-alexandre.chartre@oracle.com>
 <20190513151500.GY2589@hirez.programming.kicks-ass.net>
To: Peter Zijlstra <peterz@infradead.org>
X-Mailer: Apple Mail (2.3445.4.7)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905130142
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9256 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905130142
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On 13 May 2019, at 18:15, Peter Zijlstra <peterz@infradead.org> wrote:
>=20
> On Mon, May 13, 2019 at 04:38:32PM +0200, Alexandre Chartre wrote:
>> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
>> index 46df4c6..317e105 100644
>> --- a/arch/x86/mm/fault.c
>> +++ b/arch/x86/mm/fault.c
>> @@ -33,6 +33,10 @@
>> #define CREATE_TRACE_POINTS
>> #include <asm/trace/exceptions.h>
>>=20
>> +bool (*kvm_page_fault_handler)(struct pt_regs *regs, unsigned long =
error_code,
>> +			       unsigned long address);
>> +EXPORT_SYMBOL(kvm_page_fault_handler);
>=20
> NAK NAK NAK NAK
>=20
> This is one of the biggest anti-patterns around.

I agree.
I think that mm should expose a mm_set_kvm_page_fault_handler() or =
something (give it a better name).
Similar to how arch/x86/kernel/irq.c have =
kvm_set_posted_intr_wakeup_handler().

-Liran


