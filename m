Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 20C56C742B9
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 12:18:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9C7C208E4
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 12:18:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="CnC3slv8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9C7C208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A3F718E0143; Fri, 12 Jul 2019 08:18:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9EECC8E00DB; Fri, 12 Jul 2019 08:18:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B5CF8E0143; Fri, 12 Jul 2019 08:18:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6BA6A8E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 08:18:56 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id c5so10340264iom.18
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 05:18:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=tHy9732h8J88hlJcyQvuajeYi/Ef6ybEFYf/oRMEAZk=;
        b=qNCM1tWSql3QCweeQK/XEQq6zAYtWFs6NEtoPPzQUauYApFM1+2my90xVFmD0SQ72y
         3zAfevtJ8AeqCAz1NF+FxUsjwgdnLztBph+UxJxthkx7NRg6R5JGrTnY9TDhhOEdTv6d
         KntzeB2u4P8etwIOIe6qO8sjmY0YN2khWs+RIO08OF5Q9dd6UIg1MHatsVZZJB9IlucV
         hOIuacfompjIbFtOyZXDzp0DX6iXG34OYByWffBz4z+QwSdkdld/YL0R6CUgfxWYAEeN
         PCB/TANBH/2WxuAW8Wmcii/GYNm8aaIlcRSCJY8S3TNHQGe0sQPGzQCN+knoh7AkMtid
         cSfw==
X-Gm-Message-State: APjAAAWLURlqxwmIc1IE5EiYEYnwqBYgf+NiLH2J7z/yk6ET/1tMwBzj
	PYqUxX4r5kjLLed0uHR+wx2+V3EulXHwRfjm3ktMegQF6kovFO3MI79OgnEEWOIx0gYRV/Rquwj
	TERfG8J/5Ycp8ls5HUNCjrtz27zwq8libnJj+u7e8F5nUbdnTOUS4T+SavzXA2n0HXQ==
X-Received: by 2002:a5d:9b1a:: with SMTP id y26mr10387095ion.238.1562933936156;
        Fri, 12 Jul 2019 05:18:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy2vBdlfRdA8tBXfx1tKAvflLyZpCFFBpG8HxjN52qUoE0ugZ8BZQR4/Qn67J9dSiCTwnFu
X-Received: by 2002:a5d:9b1a:: with SMTP id y26mr10386986ion.238.1562933935005;
        Fri, 12 Jul 2019 05:18:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562933935; cv=none;
        d=google.com; s=arc-20160816;
        b=FmAGpp9B7rnAmH31CAJ+78zxDysA0vJYcbmSAFZINlTym9DukGHs2btM6V7CD9UMcC
         fEQhfh1Oqfgi03Riy337eqIIbYWWrCM+zX/SQBhDXpHUEm9Q6hF2rG15eDbgjcBPH3LB
         oXQsYTMSAzotF/eQ7mHY4PfiYJWuCQG+iCRu2kR95jtcNm+prVxWW/LiHK6OyvqHgSat
         A9apyI0B4XK/u9mtlOcbN0omUzwLfdf9p2hmQvk8xvWN4h49nEWWD079iAmMVZYkoiTy
         hkp54KEGhOFLGWUHfoDho6+qZT3xZZSnfBes34YmWw3G57qPcht2pE22FiZT8DcmOq3m
         hD2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=tHy9732h8J88hlJcyQvuajeYi/Ef6ybEFYf/oRMEAZk=;
        b=kBzotWHzdG+K43bH7KK6/F3ouDNwpSDvxj1J219RKgVmRutx8o6BavhAIp1edkYRf6
         cr3272sAh6/3VgLKPOb03fOMx29RyHtt2Z+XOoJueXlflR8e0Su3eR6VY3u/hk0T8AV/
         H5l6ULjjWl+tWjz5rsygvWKi34lPd+Y3Y0zs7Zbobdy9n960oNc91GC048oIwicdKdDC
         06BAytqqaymH4BbSx8tZP+Im7zFJv6vHeqfri7eTdxaQUtcgVWag8OtRdrVX3WrGsCfA
         GZjN5dGhng+dpA9UZ5G1NOYjMTgBflXxdQwAvfk/oq6+Mz6C/i0mQy3eGGmYme5ac2V3
         ybgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=CnC3slv8;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id m7si6386847ioh.17.2019.07.12.05.18.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 05:18:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=CnC3slv8;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6CC90Xl012611;
	Fri, 12 Jul 2019 12:18:37 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=tHy9732h8J88hlJcyQvuajeYi/Ef6ybEFYf/oRMEAZk=;
 b=CnC3slv8NBqzLVrf761MKmmJDfer7dKnuBEhQa/FXBbm2ow7JK23L0vk/WZwnvkokWMY
 y7IFxlUnVNzQKNe4p+wmxcSzG5SegxPMg9NcgXCCP3pDFFXZkzx3fc+qToYydvHE9SCN
 D2VNz+65cWxxvv46Qv72qUR6O+mtixOx4/eZrTpPz4BIfrqs2KsN0OY93rF2Onbwdv3R
 mFf1I53WjD3Zzr+o0h6RVM/7Mqhm2JZm/L6cXriU/ge5HTHpasP5ibAgh91+08zMQYZJ
 7Nb7JwQ5zG6C15DKK651VACg8j9DiArepwlkSyS76+xjwbCQ0ylHhsNxBlGDkFgi7q45 qA== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2120.oracle.com with ESMTP id 2tjm9r59gw-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 12 Jul 2019 12:18:36 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6CC88Cl186642;
	Fri, 12 Jul 2019 12:18:36 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3030.oracle.com with ESMTP id 2tmwgyr9wd-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 12 Jul 2019 12:18:35 +0000
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x6CCIXEh014480;
	Fri, 12 Jul 2019 12:18:33 GMT
Received: from [10.166.106.34] (/10.166.106.34)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 12 Jul 2019 12:17:24 +0000
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
From: Alexandre Chartre <alexandre.chartre@oracle.com>
Organization: Oracle Corporation
Message-ID: <1f97f1d9-d209-f2ab-406d-fac765006f91@oracle.com>
Date: Fri, 12 Jul 2019 14:17:20 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190712114458.GU3402@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9315 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1907120133
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9315 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907120133
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/12/19 1:44 PM, Peter Zijlstra wrote:
> On Thu, Jul 11, 2019 at 04:25:12PM +0200, Alexandre Chartre wrote:
>> Kernel Address Space Isolation aims to use address spaces to isolate some
>> parts of the kernel (for example KVM) to prevent leaking sensitive data
>> between hyper-threads under speculative execution attacks. You can refer
>> to the first version of this RFC for more context:
>>
>>     https://lkml.org/lkml/2019/5/13/515
> 
> No, no, no!
> 
> That is the crux of this entire series; you're not punting on explaining
> exactly why we want to go dig through 26 patches of gunk.
> 
> You get to exactly explain what (your definition of) sensitive data is,
> and which speculative scenarios and how this approach mitigates them.
> 
> And included in that is a high level overview of the whole thing.
> 

Ok, I will rework the explanation. Sorry about that.

> On the one hand you've made this implementation for KVM, while on the
> other hand you're saying it is generic but then fail to describe any
> !KVM user.
> 
> AFAIK all speculative fails this is relevant to are now public, so
> excruciating horrible details are fine and required.

Ok.

> AFAIK2 this is all because of MDS but it also helps with v1.

Yes, mostly MDS and also L1TF.

> AFAIK3 this wants/needs to be combined with core-scheduling to be
> useful, but not a single mention of that is anywhere.

No. This is actually an alternative to core-scheduling. Eventually, ASI
will kick all sibling hyperthreads when exiting isolation and it needs to
run with the full kernel page-table (note that's currently not in these
patches).

So ASI can be seen as an optimization to disabling hyperthreading: instead
of just disabling hyperthreading you run with ASI, and when ASI can't preserve
isolation you will basically run with a single thread.

I will add all that to the explanation.

Thanks,

alex.

