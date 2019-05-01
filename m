Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD901C43219
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 15:21:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6BAFF21670
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 15:21:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="BsP6AnL/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6BAFF21670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF2CF6B0006; Wed,  1 May 2019 11:21:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA2AB6B0008; Wed,  1 May 2019 11:21:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A92976B000A; Wed,  1 May 2019 11:21:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 741936B0006
	for <linux-mm@kvack.org>; Wed,  1 May 2019 11:21:41 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id z7so11086748pgc.1
        for <linux-mm@kvack.org>; Wed, 01 May 2019 08:21:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=i/eVb1RrPCrDgsQYwTIls1vT7PGrIbuHhUptmv1sc2U=;
        b=G/LWOcc1m7XMMI7ZBIoxfI+b25uhbMlQksZHvy46rZo7AOe5mxJTUsQ1mWM8JD1K2k
         QW9xWiWoPaYMIphbfNWJcJg9ppTyNZTJQ8LZVLVl/1vwEPvGM4Z4aL3hzlEjherSdJVW
         hwh2mRTemu8J68646VKNNdO8l89/glv+x9OZmFCjtloYDa0c1gKgyPCzf8veZDGWP8+i
         owwRBXwIh9sQZPjTKdSFG9rVyuONRhOZbpkHb1C+I8uxLH4nOkACff3rwQOrA28lbvPx
         1KCRr9e+fdBouMqY7USiABX7K1UPj7hcSJ3G+M8ELt4lSJ+dXLy5/2vybL3OvR11HN8s
         1eHw==
X-Gm-Message-State: APjAAAUYOkxjs3Crg5q/tOqdzlfJsNGaCtgjiDYB35UyL4k3j25PvO76
	HH6haQIPm6wKcRze1umXCK5NcE7ipc0MrZGgDTJvAV2DYiH4wWlpd02PBcnujnIP0wCVcUyVpOt
	V1b31/nh+ArkIl1oNZZUioPeTeRelyw9CIPDhKr+m2AZTwoRMBeHBovsqW035DA+THQ==
X-Received: by 2002:aa7:800e:: with SMTP id j14mr77731328pfi.157.1556724101117;
        Wed, 01 May 2019 08:21:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyojObBf52HMWfgILyCPeEg/BT33ycVBndSzdUtwHYJyVzlPTte5fZLP+J2Z0P4ruFbEh9z
X-Received: by 2002:aa7:800e:: with SMTP id j14mr77731253pfi.157.1556724100118;
        Wed, 01 May 2019 08:21:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556724100; cv=none;
        d=google.com; s=arc-20160816;
        b=I13Ns4ZfNB1lUBizuyvaKvIb5uFN4WXmldAnQmgIxijUJ0AWAKOtMJxTUfZjgOvQ9Z
         GFdSMJfX9OHFtC5BYDLzmd1fECRbuJaLAKd9MOprAclRDFjVVkGALJy6WewAL8+RcV6N
         pDAeA8gkNOFGV/99HhZgNZNfo/AQDnfmAxB0g4oB5Lev/lRK4+F8JjqB9ZarVbKQKSmo
         IDo3mAIuWrZvn6lEZjLribd45SLGvCCvLFcaUkvGfvV4V+NmwiE77wX0FjCLwxF5dKzG
         B/uQ0ygNptj1Ryi8TfXPLEl53JWynGLB1ATXKiBoN0oxZ1n4ISlU0QwrZpWFlX8+l+st
         iMrg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=i/eVb1RrPCrDgsQYwTIls1vT7PGrIbuHhUptmv1sc2U=;
        b=GIBeZfyQ53h3d6sRxVlNnepXQexAYkcVI1+S0V8kOVfd43/uU+qZvMqWDGS+ngdzIm
         u7njKPe8J0hBvzWGK7tps813gD/Mb9CUZSK26jAURm+XP47OAPy5Uqh0ITh8/QGvojUm
         Qt5xCZBoOsU8u2MpIbyyW6Ac7HMGiQgEVVgQMo7eYxxdz2aElm/pfUFJcm2WDlAU5ZZT
         HvRFWpO9IeQS7uu6DdSj+AYzlkadyTnGzhXh1MJ9j+oqUHZN515pWclNtv8PbtX6bIJc
         P9fSi/03SciJa38YTuUT5pWpykVbAt0Jwy/SS3YvALZCvs6dH4UkPJZpEbnIVqYryO/j
         Kh0g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="BsP6AnL/";
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id 30si29087931plc.8.2019.05.01.08.21.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 08:21:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="BsP6AnL/";
       spf=pass (google.com: domain of khalid.aziz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=khalid.aziz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x41ExFjM181642;
	Wed, 1 May 2019 15:21:05 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=i/eVb1RrPCrDgsQYwTIls1vT7PGrIbuHhUptmv1sc2U=;
 b=BsP6AnL/ORY8ld331R4h0ac65YxS73XkP57Vczvh6L/OUPqAHMOzeF1ujrkUCRrgatxc
 jebYYcNYN8gNQ1pZZRlBgRtNrMTisjdd42nTg+Ycd9UXFg6tu7mpm/FPlvNziKb4GHgk
 Ev/rAHicr5ObHUMRbubGeDPRgTwGg3FWy0K33/iF0u2XsYkT68SDeK3uZU5y4oVZ33kj
 +ktkW9kzO8wVZMrVdA8Y+QMoCoV8U1+8O4GynSn3BODBw+OLs3zxFhsPGV8DCVHOV/rL
 f8jPd2DGbY/dStdvsDL4ViC8D5ksbEkNxvDpzU9xr8j+5etNJkZgs8hgSt7qW6slgjfr KA== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2120.oracle.com with ESMTP id 2s6xhyk8g7-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 01 May 2019 15:21:04 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x41FIh2M030628;
	Wed, 1 May 2019 15:19:04 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserp3030.oracle.com with ESMTP id 2s6xhgjet8-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 01 May 2019 15:19:03 +0000
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x41FIjxB018467;
	Wed, 1 May 2019 15:18:46 GMT
Received: from [192.168.1.16] (/24.9.64.241)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 01 May 2019 08:18:45 -0700
Subject: Re: [RFC PATCH v9 03/13] mm: Add support for eXclusive Page Frame
 Ownership (XPFO)
To: Waiman Long <longman@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, keescook@google.com,
        konrad.wilk@oracle.com,
        Juerg Haefliger <juerg.haefliger@canonical.com>,
        deepa.srinivasan@oracle.com, chris.hyser@oracle.com,
        tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com,
        jcm@redhat.com, boris.ostrovsky@oracle.com,
        iommu@lists.linux-foundation.org, x86@kernel.org,
        linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        linux-security-module@vger.kernel.org,
        Khalid Aziz <khalid@gonehiking.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Thomas Gleixner <tglx@linutronix.de>,
        Andy Lutomirski <luto@kernel.org>,
        Peter Zijlstra <a.p.zijlstra@chello.nl>, Dave Hansen <dave@sr71.net>,
        Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
        Arjan van de Ven <arjan@infradead.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
 <f1ac3700970365fb979533294774af0b0dd84b3b.1554248002.git.khalid.aziz@oracle.com>
 <20190417161042.GA43453@gmail.com>
 <e16c1d73-d361-d9c7-5b8e-c495318c2509@oracle.com>
 <35c4635e-8214-7dde-b4ec-4cb266b2ea10@redhat.com>
From: Khalid Aziz <khalid.aziz@oracle.com>
Organization: Oracle Corp
Message-ID: <4a47cf86-a05d-3de5-0320-eda06101cc75@oracle.com>
Date: Wed, 1 May 2019 09:18:41 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <35c4635e-8214-7dde-b4ec-4cb266b2ea10@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9243 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905010096
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9243 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905010096
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/1/19 8:49 AM, Waiman Long wrote:
> On Wed, Apr 03, 2019 at 11:34:04AM -0600, Khalid Aziz wrote:
>> diff --git a/Documentation/admin-guide/kernel-parameters.txt
> b/Documentation/admin-guide/kernel-parameters.txt
>=20
>> index 858b6c0b9a15..9b36da94760e 100644
>> --- a/Documentation/admin-guide/kernel-parameters.txt
>> +++ b/Documentation/admin-guide/kernel-parameters.txt
>> @@ -2997,6 +2997,12 @@
>>
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 nox2apic=C2=A0=C2=A0=C2=A0 [X86-64,APIC=
] Do not enable x2APIC mode.
>>
>> +=C2=A0=C2=A0=C2=A0 noxpfo=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 [=
XPFO] Disable eXclusive Page Frame Ownership (XPFO)
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 wh=
en CONFIG_XPFO is on. Physical pages mapped into
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 us=
er applications will also be mapped in the
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ke=
rnel's address space as if CONFIG_XPFO was not
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 en=
abled.
>> +
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 cpu0_hotplug=C2=A0=C2=A0=C2=A0 [X86] Tu=
rn on CPU0 hotplug feature when
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 CONFIG_BO OTPARAM_HOTPLUG_CPU0 is off.
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 Some features depend on CPU0. Known dependencies are:
>=20
> Given the big performance impact that XPFO can have. It should be off b=
y
> default when configured. Instead, the xpfo option should be used to
> enable it.

Agreed. I plan to disable it by default in the next version of the
patch. This is likely to end up being a feature for extreme security
conscious folks only, unless I or someone else comes up with further
significant performance boost.

Thanks,
Khalid

