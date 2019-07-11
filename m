Return-Path: <SRS0=bABq=VI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BFF1C742A1
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 20:42:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2EE90208E4
	for <linux-mm@archiver.kernel.org>; Thu, 11 Jul 2019 20:42:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="rFWTCChF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2EE90208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB40D8E00F9; Thu, 11 Jul 2019 16:42:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3D078E00DB; Thu, 11 Jul 2019 16:42:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DD618E00F9; Thu, 11 Jul 2019 16:42:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6C3178E00DB
	for <linux-mm@kvack.org>; Thu, 11 Jul 2019 16:42:34 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id c5so8008442iom.18
        for <linux-mm@kvack.org>; Thu, 11 Jul 2019 13:42:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=tSjzKrUHQ1knMz+gwb7wzYG6sENMAxSGm0UkDSdi7as=;
        b=lltfrvpcLRW11UuzPWZUC6uRdoWXqDxOUDjfMSS0b99/HJBLyZdQQGZwSgsN5flsT/
         t19zUqpsiDt4P8A9vhQv2jIWe/3mPdP3otHVnCISVUg2Zc7KVXd7E87E9ltYgsLiStgc
         i+RsyYOeVF7kZd7q/MZhLYWt4JvJ/0FL0YfEYJWf1boHmp5IvVVir/Dp4vBhdIIgPnAq
         RieRGfGB/2786zyFQK60CQPHV7DH34P54FKlMSlgbTIXwiOtY8+rMt4NUAL0KaOpt9nZ
         FVCO5Qb/zR2PBPBDF87qTqAUJvslgtbpcdqJG10FMiDiPa5++22zzbnbUoofUEhhAybP
         QYPQ==
X-Gm-Message-State: APjAAAV6M2JtJKDad8jOalE2f/MVTLL4ntVG1uDECEgWOGlYyhQYMOR1
	IYDwDxDy3t8QzCx0aKQpTcRz+NT5HWO+ikw1vpLsnpwPqLLfXXCKFf926LitxebneDTSvKr409v
	JmpeJZfotanB6B9CVedqyhTMuBJTPjz3RuzDQMKIw7c8P1/BMxP8UsnA4nE+EOorFmw==
X-Received: by 2002:a5d:940b:: with SMTP id v11mr6740074ion.69.1562877754221;
        Thu, 11 Jul 2019 13:42:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzKNvfP13MxavUBPEd3JHjI/TL6eJ8s5NRVVQTmiLQmTYbJ33dUIB3srX6PVwN/OcOodSvl
X-Received: by 2002:a5d:940b:: with SMTP id v11mr6740025ion.69.1562877753606;
        Thu, 11 Jul 2019 13:42:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562877753; cv=none;
        d=google.com; s=arc-20160816;
        b=YBxpn3rLo3jZWcOY6JqIqkuJoNO4D2dAj4X371yZCmN7D6SKYiH0Zb+nn/GheAiHm1
         81qilkcBqpM4561rItWw+8sDcUbPmDC0+cqDt+KB3xuY4PFWD/jNjaSDpaV8Bc+f5sE+
         S4dnsJHQ875o73uFgqzsyY51uaV1F+PwLqDRqIv3snOvlrx2IPbroO4OBW5WlZcvm0Kf
         IQm+pxsiB9NF/LAYj5Ya+L+4GappkcieYg1ht27BQCpIjNqAQskblnDDmKw6AkL+CbsP
         YtLbVV/rEUkE0NLFsJYmI+oVcZcGjyIch87o0ntivNa8uNIK8MvzPBDCG7sijn01EQbl
         Q/dw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=tSjzKrUHQ1knMz+gwb7wzYG6sENMAxSGm0UkDSdi7as=;
        b=R3f7UB+nD6uycf3FfIXj1dInaTGmRMtbx6Dhwbs3eFcVjKqYy7j02A0nXakPdEP7CH
         G39R5EqGSNrJWe8kxwW3DA8tm4KWb2ueBhS/WoSaaM6V1wQjeX274+/RrKsEJXbAcUcD
         Du6Zy2ypRfVcnu9iRoxglyRuRr4C8Ssgjn8282w9INwsebqDLmjgWqpuwURLYepltcn7
         GmfU6x08sd+Gu8pjM3sViroFjGLQcAScIlIjiUr5vFIxY8rhPTJZBl4sbZlQ7DfBwcKG
         nHZRqfEVTXQu5Z3cFLdLHrxNbB5Zl4cgJdDD50zbC4vrU7MB6PScCIzNnHFovQune57L
         tqhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=rFWTCChF;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id r62si10371764iod.101.2019.07.11.13.42.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jul 2019 13:42:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=rFWTCChF;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6BKcTBi021280;
	Thu, 11 Jul 2019 20:42:16 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=tSjzKrUHQ1knMz+gwb7wzYG6sENMAxSGm0UkDSdi7as=;
 b=rFWTCChF0oyIYzpmE5gque0fCM7T3jAST9DCJqUh+t3gKYfiFuveoO4uVhdNJh06LnTd
 DKd8tWqs4dflR8Ey8detui0SFtEDZzR/WM6dPbb6hO37tOHhCEi0732WX+HW0Fo60voZ
 Ezy1Hkp+Iuf5ZFtxRFZk4luBgxE+6viMmigJOwH+6Vmw1NBmmoyGKJ4K0b42CDgdVQTJ
 ymmQku8IXTD35TjXu/FxCCu5vs6kFW+NiIDzvIbzZhB9P8PxXHol/uCuvV5pYgYQy9f9
 aC1eSLXjTydoTYPA7XSnTPJ7LSiXNZzdy+b7f+W3XYYN8zAbC44UBjKC88OYPqYeF1AK bA== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2120.oracle.com with ESMTP id 2tjkkq28mt-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Jul 2019 20:42:15 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6BKbdeo158183;
	Thu, 11 Jul 2019 20:42:14 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3020.oracle.com with ESMTP id 2tnc8tpsaq-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 11 Jul 2019 20:42:14 +0000
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x6BKg4ou031753;
	Thu, 11 Jul 2019 20:42:10 GMT
Received: from [10.166.106.34] (/10.166.106.34)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 11 Jul 2019 13:42:04 -0700
Subject: Re: [RFC v2 02/26] mm/asi: Abort isolation on interrupt, exception
 and context switch
To: Mike Rapoport <rppt@linux.ibm.com>, Andi Kleen <andi@firstfloor.org>
Cc: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, peterz@infradead.org,
        kvm@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, konrad.wilk@oracle.com,
        jan.setjeeilers@oracle.com, liran.alon@oracle.com, jwadams@google.com,
        graf@amazon.de, rppt@linux.vnet.ibm.com
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
 <1562855138-19507-3-git-send-email-alexandre.chartre@oracle.com>
 <874l3sz5z4.fsf@firstfloor.org> <20190711201706.GB20140@rapoport-lnx>
From: Alexandre Chartre <alexandre.chartre@oracle.com>
Organization: Oracle Corporation
Message-ID: <09fee00d-37a6-0895-7964-0e8a2d5b17d6@oracle.com>
Date: Thu, 11 Jul 2019 22:41:59 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190711201706.GB20140@rapoport-lnx>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9315 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1907110228
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9315 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907110228
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/11/19 10:17 PM, Mike Rapoport wrote:
> On Thu, Jul 11, 2019 at 01:11:43PM -0700, Andi Kleen wrote:
>> Alexandre Chartre <alexandre.chartre@oracle.com> writes:
>>>   	jmp	paranoid_exit
>>> @@ -1182,6 +1196,16 @@ ENTRY(paranoid_entry)
>>>   	xorl	%ebx, %ebx
>>>   
>>>   1:
>>> +#ifdef CONFIG_ADDRESS_SPACE_ISOLATION
>>> +	/*
>>> +	 * If address space isolation is active then abort it and return
>>> +	 * the original kernel CR3 in %r14.
>>> +	 */
>>> +	ASI_START_ABORT_ELSE_JUMP 2f
>>> +	movq	%rdi, %r14
>>> +	ret
>>> +2:
>>> +#endif
>>
>> Unless I missed it you don't map the exception stacks into ASI, so it
>> has likely already triple faulted at this point.
> 
> The exception stacks are in the CPU entry area, aren't they?
>   

That's my understanding, stacks come from tss in the CPU entry area and
the CPU entry area is part for the core ASI mappings (see patch 15/26).

alex.

