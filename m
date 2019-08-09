Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC134C31E40
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 21:00:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7B6D62086D
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 21:00:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="pcYp9yfI";
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="UefUInbU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7B6D62086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EA4A06B0008; Fri,  9 Aug 2019 17:00:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E2F0F6B000A; Fri,  9 Aug 2019 17:00:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CF6C46B000C; Fri,  9 Aug 2019 17:00:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id AFA6B6B0008
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 17:00:29 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id e39so89718480qte.8
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 14:00:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=9sLztaDMB8aeSX3WL8ufO6Qlj+pu4SLKowKGxHUAYS8=;
        b=aE28uFz5nINKDYDJuQEAUXAifH/cOfv7ueQ6vr0TcMtZvSeNvZpQ8lfLQAYM6IoqLL
         vZRAl35vH7jxl2G4i3TBgEJgNKsrRwjG5wVAZfe0ouEk8yP2JOl9YO5vv93vCpQt8ZQA
         zS7UFhETFM6HprRa8clEbieNB+gGppL17jFeqO0sWWbWZo5RN/azW5UA6AiC9R1js29d
         AtjaHFuF92poUSqJjbJG3nSYYLbxTcWRQlvuHcW4Or2pVjHmN5REnOcLq5qrvKRH/lYv
         SUjwB0BcnRk6E5sdUdFCOBIJD2WxBs51FzfBI5gPOYi6v2RnVKAFdVom1d7zi1J8DDqI
         FbXg==
X-Gm-Message-State: APjAAAVtwHgi2KD0OmSv3ARLSGpgnn9W8Z8CMq7JCL9y18JONQHK0mNu
	iOAfg3YMxbSKnNLAAaNVZ1/bWMrWMZjd+durBzuY1OydK3LCW06KpO2TJYs/eH+9e0cFynKrWSi
	TK9dCxiNfoBk/W4IBVi1nlWVbfIWHc+XRfcPQd6UTsuPGkduQG2y0qDE3UeLGpnbnKQ==
X-Received: by 2002:ad4:562b:: with SMTP id cb11mr8877481qvb.167.1565384429429;
        Fri, 09 Aug 2019 14:00:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyeiT7KYzkTxBKEjG8oucAr9CdcSqs2rdfk1r0+JbOcOgeX10x2252dONWLkPsBxvt3DZVk
X-Received: by 2002:ad4:562b:: with SMTP id cb11mr8877430qvb.167.1565384428925;
        Fri, 09 Aug 2019 14:00:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565384428; cv=none;
        d=google.com; s=arc-20160816;
        b=ZY3WqUL6890d0r2wU9R1hJn7Yvehnmitfs7YSxFYD8KeRvr7NBZcoLpEZy6+RVPe9D
         6bVaLI3fj7ut3Q0zxQ6gtarDZObEhNrN3P5IEo+s+Est3ktMarUO7u/BfHkfrJ3NUSom
         tRBFGoZFShDQV+0k8VqxBG04oNCuF/X86c5HTxTpLVa2rp5CkWXylAIasFDGFP15QLVO
         Gov8NfR3gcWkf5kMY+9DexsHzJRnP9g+tdsPz6wtdDyGyRwN0HsLGMEHavy5OqfGvE+D
         SozR8EXdTihCeOrqiYFXxrd1QjpHN1hoZX2HHEwD4/+yXBZRj6JLj/PWp0aj4LDrzcaf
         bopg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature:dkim-signature;
        bh=9sLztaDMB8aeSX3WL8ufO6Qlj+pu4SLKowKGxHUAYS8=;
        b=CzIbfKyn28ueADpl6SGOKBWD27cN08JrtQYeiCo3m7NTRLec1C4pcvFhFZBmGRAt32
         vyaPtQSijESdoUROxxyAkMGzdLVYT/o1X+Ych7uqyHEvccUJb4E4inHr2Frb8Z4jwM88
         6a3OZ862huzJew7qx1pxugSTNLR4Gbnug8r5rzqBNBPuYd33AjLwGhH2WutlNEPqiC4U
         3HFs8YL0yuQcA7ewTdOTM9CJug+LnaOxkHL58y+uprT1VrNfVPrqIDaCYFAcevdlmtAn
         o+yUILuebPuX90BANEQB22a9VJVJHyRYiObamO3lNeTDAGaaQ/H8bgREPo28m7hoop9Z
         mPiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2019-08-05 header.b=pcYp9yfI;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=UefUInbU;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id j6si2857159qkl.303.2019.08.09.14.00.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 14:00:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2019-08-05 header.b=pcYp9yfI;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=UefUInbU;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x79KxT2t044817;
	Fri, 9 Aug 2019 21:00:24 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2019-08-05;
 bh=9sLztaDMB8aeSX3WL8ufO6Qlj+pu4SLKowKGxHUAYS8=;
 b=pcYp9yfI3GuKYjG0G1hZnUZ4mlVzJhMn8SDnFIAzHBL80YDKrjzKOIYK5jCrJnoZCC7T
 RRO8mCE2iaWu46snuI9l0EoYMXANzjdEMQ57i1CRXiO6XGPmABWxu2DmDbWlcq7LKuyz
 yNF6hBnc83a66hJimNA6UgiMfpJe0JRVQWDKBFil0LYD8mLzdiOg2n96TIJwiX282nbH
 c9Pjrfahh0u7DRAhZHcOitDBo33YQph1lvHMNnfypeliX/9mlv6NZyaXOU7uSuk/Yyl5
 5vi7kruxTckNH64kZyDfpogI8yEcQJ7JtVKRpFpngUgaLve2gShL6D1Z25RDCpAIQ70n Cw== 
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=9sLztaDMB8aeSX3WL8ufO6Qlj+pu4SLKowKGxHUAYS8=;
 b=UefUInbUUZVRUhWHdFjDeVmYihsfyeb61d47cAMjPnlxeMdTTxQ76xdZCw2SPU++rVKt
 bG0sK1hFkwkSCJS/zxMt/pdcl0734OhVrIAp8qyhNAOUQkwXW/GeHY8WNyXFIgRV/pV7
 86uwKsYH94fY2QX0WVToNPbbsBB1VL+XOdq9/mjdldNniAKHzPrIzYiec+dKe36ZfSW7
 15CKaLG/oZyet44aTb2NcVFdZ7b934CoDlRI8j4hKxohV9Hh6dP84fv3f65XPbtYhZq7
 PCFCjFg8zoSvpYzoXE4PerYHA7HB53JMytkkEs8emfM8PAk1NNjTa1dy7pcK1wejnL69 hw== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2130.oracle.com with ESMTP id 2u8hpsa0jb-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 09 Aug 2019 21:00:24 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x79KvYJo172016;
	Fri, 9 Aug 2019 21:00:24 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3030.oracle.com with ESMTP id 2u8pj9jvyc-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 09 Aug 2019 21:00:24 +0000
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x79L0NTc027268;
	Fri, 9 Aug 2019 21:00:23 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 09 Aug 2019 14:00:23 -0700
Subject: Re: [RFC PATCH] hugetlbfs: Add hugetlb_cgroup reservation limits
To: Mina Almasry <almasrymina@google.com>
Cc: =?UTF-8?Q?Michal_Koutn=c3=bd?= <mkoutny@suse.com>,
        shuah <shuah@kernel.org>, David Rientjes <rientjes@google.com>,
        Shakeel Butt <shakeelb@google.com>, Greg Thelen <gthelen@google.com>,
        akpm@linux-foundation.org, khalid.aziz@oracle.com,
        open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
        linux-kselftest@vger.kernel.org, cgroups@vger.kernel.org
References: <20190808194002.226688-1-almasrymina@google.com>
 <20190809112738.GB13061@blackbody.suse.cz>
 <CAHS8izNM3jYFWHY5UJ7cmJ402f-RKXzQ=JFHpD7EkvpAdC2_SA@mail.gmail.com>
 <fc420531-f0fe-8df5-57fe-71a686bf2a71@oracle.com>
 <CAHS8izN9BFASse_pjLEhQzWwofjRv+JQ5Z=ZiR6Wywn2USLELA@mail.gmail.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <af6a8c43-e286-5360-61f3-6d306d8f1951@oracle.com>
Date: Fri, 9 Aug 2019 14:00:21 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CAHS8izN9BFASse_pjLEhQzWwofjRv+JQ5Z=ZiR6Wywn2USLELA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9344 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=509
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908090205
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9344 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=533 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908090205
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/9/19 1:57 PM, Mina Almasry wrote:
> On Fri, Aug 9, 2019 at 1:39 PM Mike Kravetz <mike.kravetz@oracle.com> wrote:
>>
>> On 8/9/19 11:05 AM, Mina Almasry wrote:
>>> On Fri, Aug 9, 2019 at 4:27 AM Michal Koutný <mkoutny@suse.com> wrote:
>>>>> Alternatives considered:
>>>>> [...]
>>>> (I did not try that but) have you considered:
>>>> 3) MAP_POPULATE while you're making the reservation,
>>>
>>> I have tried this, and the behaviour is not great. Basically if
>>> userspace mmaps more memory than its cgroup limit allows with
>>> MAP_POPULATE, the kernel will reserve the total amount requested by
>>> the userspace, it will fault in up to the cgroup limit, and then it
>>> will SIGBUS the task when it tries to access the rest of its
>>> 'reserved' memory.
>>>
>>> So for example:
>>> - if /proc/sys/vm/nr_hugepages == 10, and
>>> - your cgroup limit is 5 pages, and
>>> - you mmap(MAP_POPULATE) 7 pages.
>>>
>>> Then the kernel will reserve 7 pages, and will fault in 5 of those 7
>>> pages, and will SIGBUS you when you try to access the remaining 2
>>> pages. So the problem persists. Folks would still like to know they
>>> are crossing the limits on mmap time.
>>
>> If you got the failure at mmap time in the MAP_POPULATE case would this
>> be useful?
>>
>> Just thinking that would be a relatively simple change.
> 
> Not quite, unfortunately. A subset of the folks that want to use
> hugetlb memory, don't want to use MAP_POPULATE (IIRC, something about
> mmaping a huge amount of hugetlb memory at their jobs' startup, and
> doing that with MAP_POPULATE adds so much to their startup time that
> it is prohibitively expensive - but that's just what I vaguely recall
> offhand. I can get you the details if you're interested).

Yes, MAP_POPULATE can get expensive as you will need to zero all those
huge pages.

-- 
Mike Kravetz

