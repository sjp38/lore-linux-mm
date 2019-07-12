Return-Path: <SRS0=GtRI=VJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 101C3C742D2
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 16:38:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B3CC92080A
	for <linux-mm@archiver.kernel.org>; Fri, 12 Jul 2019 16:38:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="udzUsKOC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B3CC92080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 50E9D8E015D; Fri, 12 Jul 2019 12:38:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4BF2D8E0003; Fri, 12 Jul 2019 12:38:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 386C78E015D; Fri, 12 Jul 2019 12:38:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 179368E0003
	for <linux-mm@kvack.org>; Fri, 12 Jul 2019 12:38:13 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id s9so11220519iob.11
        for <linux-mm@kvack.org>; Fri, 12 Jul 2019 09:38:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :organization:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=nyEsN/LT+qLQeAhJSw73nRDEiezb1wkuHqJmYoNu09Q=;
        b=rp2gHyI0Rs2k8JFL9xE5GN2sy6bmrzNFA47sjUygGxCNCcOwR00WVnaR/yZfveX5nR
         qHv6AWklJDccbekwP8vQw1qCVlDMjRM3h3lt04PwbGPzIhaq39ASr+YTsgskMB4Jd/EY
         ecO9MPd/hrPWyGJdy/wWsKR09/Dr400bEGsO5YlSj8lH4/J9djVK5Pos+gMpQN1ypXhL
         IKyxuQiS1BqqViuCk7jE11mMwPZmGIQF8DmKzHD+oMsJeEzNOcg8evE/eEAzKHYnxjSr
         5pmoNXgUomPSCiqPF9CVKkBcbw25g7BBEkSmyTFZq4+Cpx+SNg24crDHUC34eTq9vFcP
         5oJg==
X-Gm-Message-State: APjAAAUcsBCN4IkkzHclh8qPDvacDMoClowSvmGs19i/2ivxoGtHMwKc
	vqvZudzL3SFI11ozDD5ZcKRj4FtuVMD40NqnZz0T0a2Lhq4zcPQdyMLXZ1afJ++4Je+2s4DpBbz
	m1Ig09w1s+ED+rd1qhY7DcjhbVSMFB/5rqtegqyacTEPDXRcFTsqpo9k1fNQzxNYTcg==
X-Received: by 2002:a5e:8c11:: with SMTP id n17mr11499618ioj.64.1562949492848;
        Fri, 12 Jul 2019 09:38:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyAZGlzrGlwwTAgogL8Z/SFl72v1TVK2U/FWaTA9gW2B94UR+rQmkk8m/CzY6mUV/O0XBWd
X-Received: by 2002:a5e:8c11:: with SMTP id n17mr11499551ioj.64.1562949492062;
        Fri, 12 Jul 2019 09:38:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562949492; cv=none;
        d=google.com; s=arc-20160816;
        b=vwyGpSjczyrWrMtvdfnpxW9/bGvpjK3genSLosV/ciUGjuJwUZdU2jjd5itl9q8WkS
         M0RM1JOUFGOjxHv1gAZuwKbhzz5DajU98cDLWaFDbqcvk8fW4u2373C54TgpvOYvauHx
         REscjv8Q0xCj/rbQx6dQ74Qrij8DVeXUK1KtYK0beCTR6GkTHC9rHNglYXfWf0I53qGw
         Jh+UZkhPRPsrBsp40bR+0pLGCJHJIDm9AbtaqkInw3PJ+h4poNeuOutsablA3f59rYkL
         sLM3rxk2gg7bJERcBsc3nK4dgNyaU0hpK7RxbnNtxAHtFBUQrdaW3vA/AA+Qf6JYmVtM
         YOsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject:dkim-signature;
        bh=nyEsN/LT+qLQeAhJSw73nRDEiezb1wkuHqJmYoNu09Q=;
        b=BvVfUSY6ybeCWE7USkr+gLzR7z84jXJga2DZGTtkIbiWEwMCo593wFKMxI8VSpN9Nw
         owY5MmBaCO+Wi6HPwi5gzS30MNPkz2LdHIf0UPmTPn2HPG5hlZjb2W+l7/b9EA1jkKpH
         z3Vi0doO0MY/cPNOECSPJupftI3X9Qj/6PYfNBjPh/AEVZC0MIq6qPX51RA5HMsRy5QM
         CMATTxQpP1LfxVTHgahW5N9YXrmilm+w+aAi6NOiFUFfNPMR4p/TkFU0cLfDhkaGN0r6
         ScFuHIXJCIXozgcZx3V/m1PY80FrV9uj2HHAFCGKJE78sYpGw2z94e89BZNptKdOwZzt
         91VQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=udzUsKOC;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id h16si12939390iol.156.2019.07.12.09.38.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jul 2019 09:38:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=udzUsKOC;
       spf=pass (google.com: domain of alexandre.chartre@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=alexandre.chartre@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6CGYu5W044476;
	Fri, 12 Jul 2019 16:37:56 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=nyEsN/LT+qLQeAhJSw73nRDEiezb1wkuHqJmYoNu09Q=;
 b=udzUsKOCDBkPUmzOUDtUv3Rsrc9AjAPNDVOQAGhzxJz8cM/ac3qhx5la2ks5/yVkRxcN
 jeJuWWO1mCOVL7CdwMw1K5mrevYgdJ0U1KqrVJXYcGhsGKBybJTzoG1DmqR/AtKpiRUG
 /6cdcqaH7+uwyAS/A20qc+5Japv6c6FQGyZeWGHfpCZ0Cd11Z2ykMLdZrqwzh23px5JK
 zjP8561g4U1GdrrdSfcmHkKZXMW8rHVjPA3kl5NBx2d98FCqPiLcAhEa4FB571m6F2RM
 dyIFcDD4kndhbBovZteDlGSGO/H8G0eogKOqieLEXrwfqHR56AX8ZGkcAyv5JsZwO7iB hA== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2120.oracle.com with ESMTP id 2tjm9r6n6w-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 12 Jul 2019 16:37:56 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6CGHoBM082891;
	Fri, 12 Jul 2019 16:37:56 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3030.oracle.com with ESMTP id 2tn1j288h9-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 12 Jul 2019 16:37:55 +0000
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x6CGbqMp028681;
	Fri, 12 Jul 2019 16:37:52 GMT
Received: from [10.166.106.34] (/10.166.106.34)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 12 Jul 2019 09:37:51 -0700
Subject: Re: [RFC v2 00/27] Kernel Address Space Isolation
To: Thomas Gleixner <tglx@linutronix.de>,
        Peter Zijlstra <peterz@infradead.org>
Cc: Dave Hansen <dave.hansen@intel.com>, pbonzini@redhat.com,
        rkrcmar@redhat.com, mingo@redhat.com, bp@alien8.de, hpa@zytor.com,
        dave.hansen@linux.intel.com, luto@kernel.org, kvm@vger.kernel.org,
        x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
        konrad.wilk@oracle.com, jan.setjeeilers@oracle.com,
        liran.alon@oracle.com, jwadams@google.com, graf@amazon.de,
        rppt@linux.vnet.ibm.com, Paul Turner <pjt@google.com>
References: <1562855138-19507-1-git-send-email-alexandre.chartre@oracle.com>
 <5cab2a0e-1034-8748-fcbe-a17cf4fa2cd4@intel.com>
 <alpine.DEB.2.21.1907120911160.11639@nanos.tec.linutronix.de>
 <61d5851e-a8bf-e25c-e673-b71c8b83042c@oracle.com>
 <20190712125059.GP3419@hirez.programming.kicks-ass.net>
 <alpine.DEB.2.21.1907121459180.1788@nanos.tec.linutronix.de>
From: Alexandre Chartre <alexandre.chartre@oracle.com>
Organization: Oracle Corporation
Message-ID: <3ca70237-bf8e-57d9-bed5-bc2329d17177@oracle.com>
Date: Fri, 12 Jul 2019 18:37:47 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.0
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1907121459180.1788@nanos.tec.linutronix.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9316 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1907120170
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9316 signatures=668688
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1907120171
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/12/19 5:16 PM, Thomas Gleixner wrote:
> On Fri, 12 Jul 2019, Peter Zijlstra wrote:
>> On Fri, Jul 12, 2019 at 01:56:44PM +0200, Alexandre Chartre wrote:
>>
>>> I think that's precisely what makes ASI and PTI different and independent.
>>> PTI is just about switching between userland and kernel page-tables, while
>>> ASI is about switching page-table inside the kernel. You can have ASI without
>>> having PTI. You can also use ASI for kernel threads so for code that won't
>>> be triggered from userland and so which won't involve PTI.
>>
>> PTI is not mapping         kernel space to avoid             speculation crap (meltdown).
>> ASI is not mapping part of kernel space to avoid (different) speculation crap (MDS).
>>
>> See how very similar they are?
>>
>> Furthermore, to recover SMT for userspace (under MDS) we not only need
>> core-scheduling but core-scheduling per address space. And ASI was
>> specifically designed to help mitigate the trainwreck just described.
>>
>> By explicitly exposing (hopefully harmless) part of the kernel to MDS,
>> we reduce the part that needs core-scheduling and thus reduce the rate
>> the SMT siblngs need to sync up/schedule.
>>
>> But looking at it that way, it makes no sense to retain 3 address
>> spaces, namely:
>>
>>    user / kernel exposed / kernel private.
>>
>> Specifically, it makes no sense to expose part of the kernel through MDS
>> but not through Meltdow. Therefore we can merge the user and kernel
>> exposed address spaces.
>>
>> And then we've fully replaced PTI.
>>
>> So no, they're not orthogonal.
> 
> Right. If we decide to expose more parts of the kernel mappings then that's
> just adding more stuff to the existing user (PTI) map mechanics.
  

If we expose more parts of the kernel mapping by adding them to the existing
user (PTI) map, then we only control the mapping of kernel sensitive data but
we don't control user mapping (with ASI, we exclude all user mappings).

How would you control the mapping of userland sensitive data and exclude them
from the user map? Would you have the application explicitly identify sensitive
data (like Andy suggested with a /dev/xpfo device)?

Thanks,

alex.


> As a consequence the CR3 switching points become different or can be
> consolidated and that can be handled right at those switching points
> depending on static keys or alternatives as we do today with PTI and other
> mitigations.
> 
> All of that can do without that obscure "state machine" which is solely
> there to duct-tape the complete lack of design. The same applies to that
> mapping thing. Just mapping randomly selected parts by sticking them into
> an array is a non-maintainable approach. This needs proper separation of
> text and data sections, so violations of the mapping constraints can be
> statically analyzed. Depending solely on the page fault at run time for
> analysis is just bound to lead to hard to diagnose failures in the field.
> 
> TBH we all know already that this can be done and that this will solve some
> of the issues caused by the speculation mess, so just writing some hastily
> cobbled together POC code which explodes just by looking at it, does not
> lead to anything else than time waste on all ends.
> 
> This first needs a clear definition of protection scope. That scope clearly
> defines the required mappings and consequently the transition requirements
> which provide the necessary transition points for flipping CR3.
> 
> If we have agreed on that, then we can think about the implementation
> details.
> 
> Thanks,
> 
> 	tglx
> 

