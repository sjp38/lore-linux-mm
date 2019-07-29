Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5F5EC433FF
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 19:01:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77F57206DD
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 19:01:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="um4NIe51"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77F57206DD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05EAC8E0005; Mon, 29 Jul 2019 15:01:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 035F98E0002; Mon, 29 Jul 2019 15:01:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E95B98E0005; Mon, 29 Jul 2019 15:01:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id CBD6C8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 15:01:00 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id h3so68543320iob.20
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 12:01:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=lAL03gieRWMt2NiHS28qTkY4C5xTTlo85PjStvM0KRU=;
        b=Fw0T5VofRieCRxPxeAyjyD63wbAqu5Kvp+SGU2xxlornc4PrYKkl6NKKI50on5Rqf0
         wNPcO4iltFmpgPJWi8377K8HmhlHxzx3Mx0j1YTzOt7NN3Ud/aXjKOCZNciCTw/Cqwug
         eOlftStz8Vk1o4JltT3jPRhZ83kQeADU64jWzjDSgaBLw/kCNOJNA5liv5B3A2UbysmZ
         ZtWbPZpdDwVJfveZGtNrxJehBMtqCmYCiiyvlLHHiYFxrbV88WLRIC6GL7lz8yKZNp34
         0naTS+Qi1G3iVLedsI0k2CNAlvoU3dYUmO4VX3aa5oY+/r4gM4uH5xgi8NYIN/wcCSsN
         GVTg==
X-Gm-Message-State: APjAAAVYwE/aQz+PnAwsW3RHDBvGm7TmFO8u7S5ILUABnn+W4UrqFchu
	T00zAo5762KLzL/BbeWv6wfKS4DSufO1OIR4dn6WPInNkADEUtsBnVlN7Ks0jY1lFSVj6u5TG55
	Vco2AhEq9UV3xS7QNCjS2lCq+RYY2KcTAGf0NnOqrVjuns0XGTmJy7wPXjQoei2TEew==
X-Received: by 2002:a05:6638:3d2:: with SMTP id r18mr115664254jaq.13.1564426860582;
        Mon, 29 Jul 2019 12:01:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzDT2jbRlWpF77Ooi5IFXqu6GKj6C7goXe8OJC3LAcyp+ReW64Sc9rwZZzfBwCreem1Thz/
X-Received: by 2002:a05:6638:3d2:: with SMTP id r18mr115664183jaq.13.1564426859928;
        Mon, 29 Jul 2019 12:00:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564426859; cv=none;
        d=google.com; s=arc-20160816;
        b=xg0kxPSnGtVTFu1wEGuQFnI/3b7A5mkLwvY6f7soOSlLQoiGzSFr7hwPZERIp9hVo8
         pKBAhZP426j7mioVtiil3I0ZuBQmSmX6ta8JsrpB6yDtR4fNY4LfPNkkx2e/V7bEZvRC
         KawzA52T459PswMo4AZ1iR0ohrGNEEQpWnmXuCdFZNBKg/rPODTNYobu7RLFuDk0ItLQ
         YsKLMXrJgKha+XforfhclTolvzLf7EjC88L56/70OGm2zlxiLmz7Kd2CVjp4YoAhDfek
         C7TH7IZ2cctfiDlGwtsdWoja43IwgZPW5NyJLtNNvZwTKjX6tqFEZRGLdGwu1r3my8HI
         S/HA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=lAL03gieRWMt2NiHS28qTkY4C5xTTlo85PjStvM0KRU=;
        b=07DNPz+WfJM3Hx53N1FPjgfsZN730SLHlOr+Ua/D1qziqkGnkWWRKz+Uklf/vN4LdN
         5KOe/ymyhxf1rTD9mLqJqhtKxZ9GkDmjbi8B/OjMwaEUvMzGO9hPGA5HlSDVbIb5OjoE
         NozEqd1tRpIzMQg1z9VbJMB9kRSgVHnPV4tbjWiguqHbQ5KWfxpMK7R2GiXptuQ4KxA2
         vMFI6VE2/cZc6VxCl7KMXkvbroWBWcrGH3sYSJWDYMBK3qh5aDo0KlnDz9zu7zL0j3cV
         EhaWH2UgbwFPwoNW7XG80P1aZPIMbACDfO+o9pwnMZ5cVxVW2O1PgxgGPO+hMsrVFlFQ
         Bt9g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=um4NIe51;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id w12si79242833iod.69.2019.07.29.12.00.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Jul 2019 12:00:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=um4NIe51;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6TIsOTM113863;
	Mon, 29 Jul 2019 19:00:51 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=lAL03gieRWMt2NiHS28qTkY4C5xTTlo85PjStvM0KRU=;
 b=um4NIe510L2v/cjoKmnDynIkYzl4e4EI30gykJDTPQhknFlZALvoG4XLQPCL4b/D0CxI
 drQ07qYB2nYfJH5gpFo7wgUpV+XmerDqBFuWn4UyWH2y9tJVcXAtt1GS23TbVgASDhmk
 dbUfcWnFQ4rMXZemxksjR5Wg+T5dbrjJMiS6tDYvMMuHh3q7s7mIw0XxvM7s8/fxxY0I
 LQvLMQ8erYsC7xLgKHxPYxIJXIuAqKkrmMDQEIZe24STGUnisW7qgjHQJhXsjcz1xfqF
 dWPpBe/V1numGlAQs2vltGjGsCMWnPr5lTqYYhg38FVNicJ8P+sdKI0OnQL/Cg59cI30 Gg== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2120.oracle.com with ESMTP id 2u0f8qsdye-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 29 Jul 2019 19:00:51 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6TIw4m4041359;
	Mon, 29 Jul 2019 19:00:50 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3020.oracle.com with ESMTP id 2u0ee4d4eb-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 29 Jul 2019 19:00:50 +0000
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x6TJ0g7R012209;
	Mon, 29 Jul 2019 19:00:43 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 29 Jul 2019 12:00:42 -0700
Subject: =?UTF-8?Q?Re=3a_=5bMM_Bug=3f=5d_mmap=28=29_triggers_SIGBUS_while_do?=
 =?UTF-8?B?aW5nIHRoZeKAiyDigItudW1hX21vdmVfcGFnZXMoKSBmb3Igb2ZmbGluZWQgaHVn?=
 =?UTF-8?Q?epage_in_background?=
To: Li Wang <liwang@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Linux-MM <linux-mm@kvack.org>, LTP List <ltp@lists.linux.it>,
        xishi.qiuxishi@alibaba-inc.com, mhocko@kernel.org,
        Cyril Hrubis <chrubis@suse.cz>
References: <CAEemH2dMW6oh6Bbm=yqUADF+mDhuQgFTTGYftB+xAhqqdYV3Ng@mail.gmail.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <47999e20-ccbe-deda-c960-473db5b56ea0@oracle.com>
Date: Mon, 29 Jul 2019 12:00:41 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CAEemH2dMW6oh6Bbm=yqUADF+mDhuQgFTTGYftB+xAhqqdYV3Ng@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9333 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1907290207
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9333 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1907290207
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/28/19 10:17 PM, Li Wang wrote:
> Hi Naoya and Linux-MMers,
> 
> The LTP/move_page12 V2 triggers SIGBUS in the kernel-v5.2.3 testing.
> https://github.com/wangli5665/ltp/blob/master/testcases/kernel/syscalls/move_pages/move_pages12.c
> 
> It seems like the retry mmap() triggers SIGBUS while doing thenuma_move_pages() in background. That is very similar to the kernelbug which was mentioned by commit 6bc9b56433b76e40d(mm: fix race onsoft-offlining ): A race condition between soft offline andhugetlb_fault which causes unexpected process SIGBUS killing.
> 
> I'm not sure if that below patch is making sene to memory-failures.c, but after building a new kernel-5.2.3 with this change, the problem can NOT be reproduced. 
> 
> Any comments?

Something seems strange.  I can not reproduce with unmodified 5.2.3

[root@f23d move_pages]# uname -r
5.2.3
[root@f23d move_pages]# PATH=$PATH:$PWD ./move_pages12
tst_test.c:1096: INFO: Timeout per run is 0h 05m 00s
move_pages12.c:201: INFO: Free RAM 6725424 kB
move_pages12.c:219: INFO: Increasing 2048kB hugepages pool on node 0 to 4
move_pages12.c:229: INFO: Increasing 2048kB hugepages pool on node 1 to 4
move_pages12.c:145: INFO: Allocating and freeing 4 hugepages on node 0
move_pages12.c:145: INFO: Allocating and freeing 4 hugepages on node 1
move_pages12.c:135: PASS: Bug not reproduced

Summary:
passed   1
failed   0
skipped  0
warnings 0

Also, the soft_offline_huge_page() code should not come into play with
this specific test.
-- 
Mike Kravetz

