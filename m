Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E887C742BD
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 13:48:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E4BE120863
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 13:48:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="GzivNqdL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E4BE120863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D561D8E014C; Fri, 12 Jul 2019 09:48:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D076A8E00DB; Fri, 12 Jul 2019 09:48:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BA7408E014C; Fri, 12 Jul 2019 09:48:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9BE4F8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 09:48:09 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id k21so10703245ioj.3
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 06:48:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=2TNZ9h7pACCt3IUFNoHpTzTBPzs/ZEZEH8ovFfWNlCs=;
        b=dURjzmeumZZypOQ8+p3m+DriaEFhxKnBufu8suASnnnYqYnaPj+b/0H51hCS6OUjtW
         2Pun9xz844nD6hOC4fGLMT3WRvmQLSZPdLsbl+Y759ufqcnid74DLwfAo1t8EvzPFNjm
         gJ+ICuwDpJk636rcnMItFYg89gmV2UXmhTjVcu9MY/aWftuaXm17CgxtyMxHc4HUDmnn
         blyL1ZflHVgE3WW4EoCJywJU0ly2A/he9ZyGGjn3VU0QEEl4sxTyKg9WtW5L1gAfuZtT
         Lzh3OyawZGuOCPTmKzMmGCZIpMGKYzXl/0m2irDAOS3aBv1qjgeo8AIKDJR44+DjEFWf
         0fsA==
X-Gm-Message-State: APjAAAW+/k3joXjzDFPnGqufHloSudVKPR6n0Pf2lqRHSJqUvsICsWVq
	vv8U0LIxyO/lITufcnX5ohGLtf3k3WLdAfm5nNBnI3s6rzTb2SPlrC4qUVgVzmOIFb73lzDWKMB
	cyDpvY6jDQmq14tEfepkKaadQ0SSIM1vSXnsO4mvzfEcvEbjLblgxS3m+GQ7SoQl2MQ==
X-Received: by 2002:a6b:f816:: with SMTP id o22mr11116685ioh.166.1562939289424;
        Fri, 12 Jul 2019 06:48:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3V56D0N654A/PbCLarpfBa58SLyt0Gzr9/oFjWYDvGj8ueBYRl8u9Pc+ITWOuypi0HVOT
X-Received: by 2002:a6b:f816:: with SMTP id o22mr11116638ioh.166.1562939288839;
        Fri, 12 Jul 2019 06:48:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562939288; cv=none;
        d=google.com; s=arc-20160816;
        b=AChL/MWDuvVI/lt2NEu8K17qqBTmXV5Fi4FSiLgpv64nXDiY8IfpB7R+rN3I1nAQrH
         QH0ZM064rsvJxUIP4H4L4TIWfrlj+K5ILdHg1J0ztjN/OuOMuVuX4lSFlDZVWK9T72tU
         ohR8G8i6TnLQ5UfYit+Q8vcLcKMu9LIG3dQREKDpUq6tV2sGoR002tBbP3ims+AHtPRX
         DXQWE6Ua0JqNFaqyjfVxZiJ4LcBG0BnePDhCz4AGSVc1xhhf9wDUTiS6P7vQY2YG6r+o
         +MLaanOw0QHL7eIUvkeHMEGng7S8nJKwg23wwh2of4iw2DWDQ9/yYh11YuxzDBYKKm7F
         oe6Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=2TNZ9h7pACCt3IUFNoHpTzTBPzs/ZEZEH8ovFfWNlCs=;
        b=UGhA5+8Zzp0FQe/Z8AFFOFcDjDVoJKzMb8JHkxvd2Rh7WpXapyhnREzQVPZ0pPWNyB
         WSdIJ8Id+I9n9ErIrPq0UTNXnFnFXMw8p/Q05WCBGBPMcFqRSfhoRVp1wyoI2rUKoS4J
         Tq0wUVY7CuBOzPmtorbADD4zuGv5RUCNvCiiY/M6k0wiedBOxZ8zU4fHZSyyTMzo+uxO
         von1WJCSJW+//Ctdx+EyJqqTh5WScSQYugGe4yKdILEmtb7rKcl4XLFQ4rbCuHAdMYWZ
         iK6Z0W5zmdmtRghT9t4EfSo+hZwwtFEkd/NMc7SzlfhHa2fUds6aqSorUZJfEEhBxB9d
         gqPA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=GzivNqdL;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id t130si13915443jaa.66.2019.07.12.06.48.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 06:48:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=GzivNqdL;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6CDibWT175649;
	Fri, 12 Jul 2019 13:47:52 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=2TNZ9h7pACCt3IUFNoHpTzTBPzs/ZEZEH8ovFfWNlCs=;
 b=GzivNqdLQWmLHwFSLtjBb5hgZ/6skpeLOc/wyZdgE7AQoBQBV9MoaP8HCyn0Wi7hbumt
 JxH7WeiTo51RSzWzU44B3FLonPUKH5xqpqIgC3wlJWl4XaHeWPGOTGtIjnYFlni6afKf
 myQRwBz8e/4VStXUb0QFP0APmdAMZuVnNoW5LjzXQD4TRRL4ZzwgdV7uCgxx8bii1rp0
 92yUiuBi3HqHraJcXxhPoXwK9Cq7ry0+yksAJSa6GrD2vE6xfGbrPYlLMIlEvnnCyrBH
 A5XhGaFnpC0uPUql8SL+zUGGqo6SEEhI1vUaL2dKvqd7iWj9wy+otuieM78IwgJklx1p cw== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by aserp2120.oracle.com with ESMTP id 2tjkkq5pv4-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 12 Jul 2019 13:47:52 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6CDlS8M011118;
	Fri, 12 Jul 2019 13:47:51 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3030.oracle.com with ESMTP id 2tmwgysgmr-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 12 Jul 2019 13:47:51 +0000
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x6CDloOS026847;
	Fri, 12 Jul 2019 13:47:50 GMT
Received: from [10.166.106.34] (/10.166.106.34)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 12 Jul 2019 06:46:30 -0700
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
To: Peter Zijlstra <peterz@infradead.org>
Cc: pbonzini@redhat.com, rkrcmar@redhat.com, tglx@linutronix.de,
        mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, kvm@vger.kernel.org,
        x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        konrad.wilk@oracle.com, jan.setjeeilers@oracle.com,
        liran.alon@oracle.com, jwadams@google.com, graf@amazon.de,
        rppt@linux.vnet.ibm.com, Paul Turner <pjt@google.com>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
 <20190712114458.GU3402@hirez.programming.kicks-ass.net>
 <1f97f1d9-d209-f2ab-406d-fac765006f91@oracle.com>
 <20190712123653.GO3419@hirez.programming.kicks-ass.net>
 <b1b7f85f-dac3-80a3-c05c-160f58716ce8@oracle.com>
 <20190712130720.GQ3419@hirez.programming.kicks-ass.net>
From: Alexandre Chartre <alexandre.chartre@oracle.com>
Organization: Oracle Corporation
Message-ID: <8b84ac05-f639-b708-0f7f-810935b323e8@oracle.com>
Date: Fri, 12 Jul 2019 15:46:19 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190712130720.GQ3419@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9315 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1907120149
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9315 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907120148
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/12/19 3:07 PM, Peter Zijlstra wrote:
> On Fri, Jul 12, 2019 at 02:47:23PM +0200, Alexandre Chartre wrote:
>> On 7/12/19 2:36 PM, Peter Zijlstra wrote:
>>> On Fri, Jul 12, 2019 at 02:17:20PM +0200, Alexandre Chartre wrote:
>>>> On 7/12/19 1:44 PM, Peter Zijlstra wrote:
>>>
>>>>> AFAIK3 this wants/needs to be combined with core-scheduling to be
>>>>> useful, but not a single mention of that is anywhere.
>>>>
>>>> No. This is actually an alternative to core-scheduling. Eventually, ASI
>>>> will kick all sibling hyperthreads when exiting isolation and it needs to
>>>> run with the full kernel page-table (note that's currently not in these
>>>> patches).
>>>>
>>>> So ASI can be seen as an optimization to disabling hyperthreading: instead
>>>> of just disabling hyperthreading you run with ASI, and when ASI can't preserve
>>>> isolation you will basically run with a single thread.
>>>
>>> You can't do that without much of the scheduler changes present in the
>>> core-scheduling patches.
>>>
>>
>> We hope we can do that without the whole core-scheduling mechanism. The idea
>> is to send an IPI to all sibling hyperthreads. This IPI will interrupt these
>> sibling hyperthreads and have them wait for a condition that will allow them
>> to resume execution (for example when re-entering isolation). We are
>> investigating this in parallel to ASI.
> 
> You cannot wait from IPI context, so you have to go somewhere else to
> wait.
> 
> Also, consider what happens when the task that entered isolation decides
> to schedule out / gets migrated.
> 
> I think you'll quickly find yourself back at core-scheduling.
> 

I haven't looked at details about what has been done so far. Hopefully, we
can do something not too complex, or reuse a (small) part of co-scheduling.

Thanks for pointing this out.

alex.

