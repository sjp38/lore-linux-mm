Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B73DEC742BD
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 13:45:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4257D20863
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 13:45:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="I3qle/iC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4257D20863
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF54F8E014B; Fri, 12 Jul 2019 09:45:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA6008E00DB; Fri, 12 Jul 2019 09:45:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C46408E014B; Fri, 12 Jul 2019 09:45:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id A43B18E00DB
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 09:45:45 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id c5so10596986iom.18
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 06:45:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=dGzIhFt0u54O4Kbeh8RbIfe/e2jNby1b+/yE0CanLKw=;
        b=HwewLd0aPp+FtKqsKb4XHP5kGUvl+Ucz2NNTF87+GX7LaxCAAGPa20r/YkOVAesHQu
         /cm3g3eNcy2XnHUEp19gIZvhauaa0nGbCDyN30liQ/7tgeU0yAF8FpRVSjDSoPYczWzJ
         DsuIw2z3bCO5WGKZQ3CX8fpwkM9FIWS+ApxnBZKTEi6V40l04a601Cw6F9whNVqtq2iV
         dMSfG4PUSWc2J8tow8vIjmk16jN+0S1YiHYgUbDF2NUNtbwMSpZPh18GgmnDw+UbpgX3
         2/gyv7APY2UF7kTHdgzIGp+e01EuQXHNYwMD2xGYlGInWcuBYaWEE8jK0XU4Q76Oo6aQ
         lN0g==
X-Gm-Message-State: APjAAAWY92rZIX1HfN7ojYrcpeA/wWfMt2G/v+YdmiB0gx7mhVi2PzZc
	6mg1Sf4YV7+6FdNdzx/nLo4cyJFzBUg/Brj2tAaAPwKUX2fNCf+bkRHeqdu0/SWNOwoFkM+RcXO
	HKqaGnj4g/C6eLx+9MKBnxJfuViCN57BLIVH+wRvrqQdEgD83xdd02x9VFlrg7gpbzA==
X-Received: by 2002:a02:c9d8:: with SMTP id c24mr11945512jap.38.1562939145400;
        Fri, 12 Jul 2019 06:45:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzwD66siL5NJ15RwJCKHJllHp49k+AXs09qHi9Bbu5dYLAJpWmwitprj7L/pEVMyw1V+4xB
X-Received: by 2002:a02:c9d8:: with SMTP id c24mr11945376jap.38.1562939143647;
        Fri, 12 Jul 2019 06:45:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562939143; cv=none;
        d=google.com; s=arc-20160816;
        b=oQfs8CfJo260Dn3t6GhJpefvWFcy8nZP+v/SBlYtZr7CT038dSYnfZgD3KnSclZ5n4
         ZWC2821ND+2h8mrPrPodmUsnMejPM8GzLw9wQ/QMHa6LLrUE5al7Ks+kFbFChGtxB6uO
         xvoHf06I6aegEZZF1n5Yy2ZGH6itwLgbOv3Nwd671PL8c1DeAobcvwDAet5yyFSRz0W1
         E9FAVsKGNjiKnb3EP0sOvdtBDIykEnlNQD3FrLe/FYHWFzIamb12S1HiRvLDkeIYTJYd
         5ZKnnPXhi0gzQIayUikS+yH9agR86p+68xJDldhggNLlqkxSuPvA+57e7i+1aAdWW8ve
         PFUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=dGzIhFt0u54O4Kbeh8RbIfe/e2jNby1b+/yE0CanLKw=;
        b=IHG3vsmlnvmNSzbxmYiVhL+aQfNSOrb8rzH4N/adIB0BP1/ks/eYXXFwUvCm/CRtA9
         XUiPIgiOeuR45WJNs+SLi5sSrP9PCRPRWW9tvrmxMEWcm0oEKaoFbZMuTX5TB8CZmQ/l
         AtnZvCxMP0rWFJTA9XWwpJL5nN5b/LvNVfnRUO6zsnplxxE8XIF+GkeB3GGKEj23DO8A
         cUgpxNR9UimeHUPQu9XPvBuPe+/tIccdgegT2ZnCbgl618kE/sB/di7EM9N2lxy4ehMY
         ZswHfmHZOmI1iy4q41zdNPYSpYkoPS0ABu3Hk6tnyxJ3k+gmdLk6xHUNF+lIFnv9Xisd
         b9gg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="I3qle/iC";
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id w3si12605991iot.79.2019.07.12.06.45.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 06:45:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="I3qle/iC";
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6CDiTbQ090742;
	Fri, 12 Jul 2019 13:45:25 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=dGzIhFt0u54O4Kbeh8RbIfe/e2jNby1b+/yE0CanLKw=;
 b=I3qle/iCNC7VAuoB0DAxu5j9PNjrSqNjf+rVWmK41YEKSGoN9OiSbkyAlre45qgeLtFv
 4sFAcj+k4BiPbPPjoSj6sSzja1imo4cED1Jqsw0nmu6QBA2dzTYgXG2X7jgZ0cafheoO
 EdVvD/RFeBBxmc+NVol1fI8F8zsihyoowAaasRFe4SRSr2vJSOqA9u9VNLL1AQhvwW8G
 hm7wITkGEQ8u6fMAIB8kHLrZjZLx9p3ngRzt14Z9sFLzJOmWmoreQe93CFfwMVT/FYtF
 rgBjFQcc/yzt+XhKz5ajWXfaH6vKZFK3JY+4m6C+YPeY2H4Djfjypiv+wrJp1Rb5CF6t qQ== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2120.oracle.com with ESMTP id 2tjm9r5pmv-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 12 Jul 2019 13:45:25 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6CDgnqQ001226;
	Fri, 12 Jul 2019 13:45:25 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3030.oracle.com with ESMTP id 2tmwgysfk3-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 12 Jul 2019 13:45:24 +0000
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x6CDjMYA006659;
	Fri, 12 Jul 2019 13:45:22 GMT
Received: from [10.166.106.34] (/10.166.106.34)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 12 Jul 2019 06:43:35 -0700
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
To: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Dave Hansen
 <dave.hansen@intel.com>,
        pbonzini@redhat.com, rkrcmar@redhat.com, mingo@redhat.com,
        bp@alien8.de, hpa@zytor.com, dave.hansen@linux.intel.com,
        luto@kernel.org, kvm@vger.kernel.org, x86@kernel.org,
        linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        konrad.wilk@oracle.com, jan.setjeeilers@oracle.com,
        liran.alon@oracle.com, jwadams@google.com, graf@amazon.de,
        rppt@linux.vnet.ibm.com, Paul Turner <pjt@google.com>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
 <5cab2a0e-1034-8748-fcbe-a17cf4fa2cd4@intel.com>
 <alpine.DEB.2.21.1907120911160.11639@nanos.tec.linutronix.de>
 <61d5851e-a8bf-e25c-e673-b71c8b83042c@oracle.com>
 <20190712125059.GP3419@hirez.programming.kicks-ass.net>
From: Alexandre Chartre <alexandre.chartre@oracle.com>
Organization: Oracle Corporation
Message-ID: <a03db3a5-b033-a469-cc6c-c8c86fb25710@oracle.com>
Date: Fri, 12 Jul 2019 15:43:31 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <20190712125059.GP3419@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9315 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1907120148
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


On 7/12/19 2:50 PM, Peter Zijlstra wrote:
> On Fri, Jul 12, 2019 at 01:56:44PM +0200, Alexandre Chartre wrote:
> 
>> I think that's precisely what makes ASI and PTI different and independent.
>> PTI is just about switching between userland and kernel page-tables, while
>> ASI is about switching page-table inside the kernel. You can have ASI without
>> having PTI. You can also use ASI for kernel threads so for code that won't
>> be triggered from userland and so which won't involve PTI.
> 
> PTI is not mapping         kernel space to avoid             speculation crap (meltdown).
> ASI is not mapping part of kernel space to avoid (different) speculation crap (MDS).
> 
> See how very similar they are?
>
> 
> Furthermore, to recover SMT for userspace (under MDS) we not only need
> core-scheduling but core-scheduling per address space. And ASI was
> specifically designed to help mitigate the trainwreck just described.
> 
> By explicitly exposing (hopefully harmless) part of the kernel to MDS,
> we reduce the part that needs core-scheduling and thus reduce the rate
> the SMT siblngs need to sync up/schedule.
> 
> But looking at it that way, it makes no sense to retain 3 address
> spaces, namely:
> 
>    user / kernel exposed / kernel private.
> 
> Specifically, it makes no sense to expose part of the kernel through MDS
> but not through Meltdow. Therefore we can merge the user and kernel
> exposed address spaces.

The goal of ASI is to provide a reduced address space which exclude sensitive
data. A user process (for example a database daemon, a web server, or a vmm
like qemu) will likely have sensitive data mapped in its user address space.
Such data shouldn't be mapped with ASI because it can potentially leak to the
sibling hyperthread. For example, if an hyperthread is running a VM then the
VM could potentially access user sensitive data if they are mapped on the
sibling hyperthread with ASI.

The current approach is assuming that anything in the user address space
can be sensitive, and so the user address space shouldn't be mapped in ASI.

It looks like what you are suggesting could be an optimization when creating
an ASI for a process which has no sensitive data (this could be an option to
specify when creating an ASI, for example).

alex.

> 
> And then we've fully replaced PTI.
> 
> So no, they're not orthogonal.
> 

