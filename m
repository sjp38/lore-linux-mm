Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63C44C742BD
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 14:07:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B273206B8
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 14:07:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="L5+C7PJ+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B273206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B24CD8E0152; Fri, 12 Jul 2019 10:07:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AD5768E00DB; Fri, 12 Jul 2019 10:07:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C3E38E0152; Fri, 12 Jul 2019 10:07:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7E5388E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 10:07:26 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id h3so10735862iob.20
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 07:07:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=F9vHBH7bxmfd3Exz2+DCAGo6VowZreYVT2luGWbO36Y=;
        b=Hc/yuBQOyxdw4ysLNXQmuV/ty98xisqCake+NVInFMsjtrE1hdfnasvcqbfdH4IKXF
         8OK/C2Ig6OjxCRub0oQqGwM1BVEcWCmV4TFtLo4W76h/0eTRUOUJn8Z1shFuMb4n2XFB
         CxDUDYlkx7ap9ra4g7VCkDEJBb3bEi+0eAJcZvl9KSCQUc/C9SREbM/qnPWTofy0BL/D
         Lxqa8QJMpRXrob7YuOZ3KRoNxxXjSz00/I5E9dYgRCXOqvkUKZImsTPc+/BmH5fdO1sT
         CgEySamSmvv2aUDvKX1dzeFIXSs6QR3SHyd2HgLoLlCnfInZwzHpH0ITHYNw2mFY5wPJ
         U3CQ==
X-Gm-Message-State: APjAAAUnZddEpJIB12S2S3W6kEuckBmg5I987W4qZgUC4Gc9o+eJVnKC
	YexE/mEpgz/HbE10yTRft1pDBjcmaD5Ly6Trc1aoOvbDXUuYwgJ1k4b1BbuyquXi5T6mdTEeRO8
	WoZEZif385M6XkYpx7XaipCbDVFSH4KxjxkD+zVxiwmUTHTbCGGTwAZ2huRXJ2ZAixA==
X-Received: by 2002:a6b:bbc1:: with SMTP id l184mr11446018iof.232.1562940446278;
        Fri, 12 Jul 2019 07:07:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzTJj8OEas2yNY/PTzb44T05o6FIuZCavdRb9Dym9hxamcHQxSqZ7HZW0AsaNWaRbkOr4h7
X-Received: by 2002:a6b:bbc1:: with SMTP id l184mr11445933iof.232.1562940445311;
        Fri, 12 Jul 2019 07:07:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562940445; cv=none;
        d=google.com; s=arc-20160816;
        b=BUl+oczM8eEKxwOuo8d3oR5GGr9TwprPjm3wG/LET2LztGfSLvuaQw34kcy7VbSI9Z
         DCqWjQ1HrIToZS9wI5Vf8vtFjBmS1HhHF3pDkreMyR+dnwze/Nk4Ug2eTwHGNLNZJsas
         SEpbpXQrkjRLoHgbZPJObAEGAKuaFrIrXi6ygdrt6avafCUAgpOdFUjm0SCwx/jQPsoK
         n7+vTpbfQsyt0PlJcPF1ppxFHm2aDC5etJBt/IJdZR6BM58o9AQdCvPkMglpK3671IoS
         wWalLVAOGdTakyBZSG3/H8Ytut7KrlZFB/ob4jgfdayvgbKO8xypJeZUbFhpTi4WOGZ5
         1MrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=F9vHBH7bxmfd3Exz2+DCAGo6VowZreYVT2luGWbO36Y=;
        b=oOT8Ap/Ec5OCrkm2rnj8hwMj/iGFBKQ71r5+cNQAQT/tG5XPIPdIZuBeEO+PwAARYP
         jee2O2jyZdutlbFO4UgxMJGVBUax34Il+dPFqpZmsQPayf/YJ7DAL0HNbADVFckY0UzN
         Dyn3Mm+gbuDuqIfB6kFBd0bRZBHhT1YYUecsaRQaJ/L/TUyrvkR3HXy4P+QPecD1qJT4
         XNlPTROcLB9r6Qrd6Dete1h+n8gK6sEDv2V0SwccfCkRXCxAhZQuOMaPvrE3tgigwzp6
         384cNtvsFXI5xaHYsA5y7sH8WrrQDjm3PP4PE8pWtk2SnTM7DNJsMrSi5s/r7699MAcn
         c7+A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=L5+C7PJ+;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id f8si13374878iok.62.2019.07.12.07.07.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 07:07:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=L5+C7PJ+;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6CE40ia193220;
	Fri, 12 Jul 2019 14:07:13 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=F9vHBH7bxmfd3Exz2+DCAGo6VowZreYVT2luGWbO36Y=;
 b=L5+C7PJ+i6ErZ4mGphNpwQlPmp+REhtMGAXURHDX5SzsguYSI72Cqr3ux4zQv9qGTnaE
 RSBPNqCIlsGokpDHQp6+PhOOTbe0ykqvNSXDx3SKiTPRWvlLhvKYJbi4TLUYp+oHq9hF
 aSH7VG8rW77iuM2l+rqt/bJdhYK/nKGBYADD8HAbYuCzFxqT+zRtl/GgdgD9PBmtYJRZ
 m6GnZ+Gi2W+xJWZLJlATm6bN0GcH6+MRzlGj98/20EfmQ1X7YWLIDRkUBoF76itBoCbz
 Fu8yQQj4pNOM5OuX77+tY4s+1pb9yXTE/gQE+WXjNTfwCJCqXaiMlxsLMGmbDkdIx6gQ gA== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by aserp2120.oracle.com with ESMTP id 2tjkkq5tfm-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 12 Jul 2019 14:07:12 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6CE3O8b129756;
	Fri, 12 Jul 2019 14:07:12 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3030.oracle.com with ESMTP id 2tn1j25tg4-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 12 Jul 2019 14:07:11 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x6CE78ZA022867;
	Fri, 12 Jul 2019 14:07:09 GMT
Received: from [10.166.106.34] (/10.166.106.34)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 12 Jul 2019 07:06:38 -0700
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
To: Dave Hansen <dave.hansen@intel.com>, pbonzini@redhat.com,
        rkrcmar@redhat.com, tglx@linutronix.de, mingo@redhat.com, bp@alien8.de,
        hpa@zytor.com, dave.hansen@linux.intel.com, luto@kernel.org,
        peterz@infradead.org, kvm@vger.kernel.org, x86@kernel.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: konrad.wilk@oracle.com, jan.setjeeilers@oracle.com, liran.alon@oracle.com,
        jwadams@google.com, graf@amazon.de, rppt@linux.vnet.ibm.com
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
 <5cab2a0e-1034-8748-fcbe-a17cf4fa2cd4@intel.com>
 <2791712a-9f7b-18bc-e686-653181461428@oracle.com>
 <dbbf6b05-14b6-d184-76f2-8d4da80cec75@intel.com>
From: Alexandre Chartre <alexandre.chartre@oracle.com>
Organization: Oracle Corporation
Message-ID: <bfd62213-c7c0-4a90-b377-0de7d9557c4c@oracle.com>
Date: Fri, 12 Jul 2019 16:06:34 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <dbbf6b05-14b6-d184-76f2-8d4da80cec75@intel.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9315 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1907120152
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9315 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907120153
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/12/19 3:51 PM, Dave Hansen wrote:
> On 7/12/19 1:09 AM, Alexandre Chartre wrote:
>> On 7/12/19 12:38 AM, Dave Hansen wrote:
>>> I don't see the per-cpu areas in here.  But, the ASI macros in
>>> entry_64.S (and asi_start_abort()) use per-cpu data.
>>
>> We don't map all per-cpu areas, but only the per-cpu variables we need. ASI
>> code uses the per-cpu cpu_asi_session variable which is mapped when an ASI
>> is created (see patch 15/26):
> 
> No fair!  I had per-cpu variables just for PTI at some point and had to
> give them up! ;)
> 
>> +    /*
>> +     * Map the percpu ASI sessions. This is used by interrupt handlers
>> +     * to figure out if we have entered isolation and switch back to
>> +     * the kernel address space.
>> +     */
>> +    err = ASI_MAP_CPUVAR(asi, cpu_asi_session);
>> +    if (err)
>> +        return err;
>>
>>
>>> Also, this stuff seems to do naughty stuff (calling C code, touching
>>> per-cpu data) before the PTI CR3 writes have been done.  But, I don't
>>> see anything excluding PTI and this code from coexisting.
>>
>> My understanding is that PTI CR3 writes only happens when switching to/from
>> userland. While ASI enter/exit/abort happens while we are already in the
>> kernel,
>> so asi_start_abort() is not called when coming from userland and so not
>> interacting with PTI.
> 
> OK, that makes sense.  You only need to call C code when interrupted
> from something in the kernel (deeper than the entry code), and those
> were already running kernel C code anyway.
> 

Exactly.

> If this continues to live in the entry code, I think you have a good
> clue where to start commenting.

Yeah, lot of writing to do... :-)
  
> BTW, the PTI CR3 writes are not *strictly* about the interrupt coming
> from user vs. kernel.  It's tricky because there's a window both in the
> entry and exit code where you are in the kernel but have a userspace CR3
> value.  You end up needing a CR3 write when you have a userspace CR3
> value when the interrupt occurred, not only when you interrupt userspace
> itself.
> 

Right. ASI is simpler because it comes from the kernel and return to the
kernel. There's just a small window (on entry) where we have the ASI CR3
but we quickly switch to the full kernel CR3.

alex.

