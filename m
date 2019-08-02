Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C1AE6C19759
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 00:19:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F0872080C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 00:19:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="rWLGD0Oa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F0872080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E650D6B0003; Thu,  1 Aug 2019 20:19:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E15206B0005; Thu,  1 Aug 2019 20:19:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CDC086B0006; Thu,  1 Aug 2019 20:19:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id A86E26B0003
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 20:19:55 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id r27so81176351iob.14
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 17:19:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:references
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=rhayChBIMMzjZ70I+yc6wMOnu1t5fS2GeqE4wEB9Te4=;
        b=ndTX4RqJM8GHESJS8PL0EMx4ztHkoRMO8NB3O+KPJZole4ciaYw88LkD600v7jcVOL
         AXZLbaBvi8g0ngokWzZwi2l9Mv5GzgO5vHk8FzZteTPIZJJ4gOaG1IqxjvQNeZg+HNsG
         hkh278ZPmvloshDxOxiSOkteM6bjeje7ZVQdY1Iuu/IJ2W05P7cYEcm33bYpTemeJXsl
         ial+lmL0uG28Njol24A5jGI2ypgsaXUFxaDt441EY9GuMF3y42eamstDsJHB2/WCOGBB
         fte7rkbrt8ezSZpyjatBkxQT47HboxgluBcR5S/Lmh09ymzqRlqs6zZRhunlzQIwly8k
         O4Mw==
X-Gm-Message-State: APjAAAU5GX7isqnx5he25UGCOIuHJBdTLhqZSecgH55DAlgoeGAVYAtl
	F+iC4q+0fsPl6BxDUv2+G+PljpEJvbQiyMTBwCwx2f2qFeRPxH2pmRfhbKizBw24hCWASOVFLmQ
	ZhaQQBkcFCAdj9p3ey3i7zOluH7MqLac8hbEeiANmxaC1kCP/ANbo7s3S1ijEmYZu2w==
X-Received: by 2002:a6b:ed01:: with SMTP id n1mr8670643iog.255.1564705195417;
        Thu, 01 Aug 2019 17:19:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfs4CdHmYeMEK7b+sTH7g+4kAip8ARQgBjvW03ODAyKE8ekhdHfg3z9MrBrXkGqjrtlSTn
X-Received: by 2002:a6b:ed01:: with SMTP id n1mr8670573iog.255.1564705194479;
        Thu, 01 Aug 2019 17:19:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564705194; cv=none;
        d=google.com; s=arc-20160816;
        b=kiW9+sacbfx/iSFaNyHpMXQihhhnIGbmy6H9HN0WpnHDs6r6062+CMmzeOx5dY+5tp
         Ga++tg3/0GZVku90PyxzeGrICf/bWlCNjxQLbo837lJPUpCu+I2u6jDYs/WTQ2IjELpd
         4IzVmXbWw79uHWfPGD7kW5FluVk7JlIwyUz4CNiEkb0rSsEBom0t+4bf9RQvNBlbJUoS
         3rqP8L2GLHgZN1Yg3vUP7QC1E71O/xGp3fdzOU4xGv1dIDaxoej64zsfOrJVwrb45rev
         xllGMBK1wub+oqqVG5e58XQmfvu8dXu96q/Yz+2rwDxH3CWiHWlUXYq8ufby/wsw45JB
         iJdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject
         :dkim-signature;
        bh=rhayChBIMMzjZ70I+yc6wMOnu1t5fS2GeqE4wEB9Te4=;
        b=gR7TnkKMJJX+BnKB/67oM5ryGR6rM09PCb1X+gkONRQeBzNvyY11u5iHwIsZTqgMKT
         zg5mc8JdZ/FGhfyYQKMC+QfZ/PhROwS/UbUn4GAJ3qU6EaGJN/gDd+1byOlTMeJ2AhZD
         PGHAyeJOD1aePGaDh8eDQ/sApCRmwKlekmxEfc2e/vnbiGPAkMs1dY3Ayqpxk3rtmYjj
         66gjQICn34o+xMeMoE3HLVk3fmSyylyA6h+tWMOHGIcLvPNtPKkAizQEFGiZPL0xCx0N
         qgPvPjTCOKMOZGdA82Y7U1KqiB6kAoo5a4638lCVPaGJZhwwv3gwYw2FLsqOOHAljXzk
         /hrQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=rWLGD0Oa;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id d20si100555700jaq.50.2019.08.01.17.19.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 17:19:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=rWLGD0Oa;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x720EqpT019585;
	Fri, 2 Aug 2019 00:19:45 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : references : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=rhayChBIMMzjZ70I+yc6wMOnu1t5fS2GeqE4wEB9Te4=;
 b=rWLGD0OaoOoaAslcOWB2HzRfswas+mJggdZOkHEauekipNN2JRNWnX+/txtXLvDnhSP7
 xLiJVzQi3max1BjPpDmtIiOn0nen11OV1Xpn7rGY3JTLR5/U9WNZpoxTqg1d3XtsblN8
 BFeq8utObBQERQwTNXYEi0M/W4U91kA94uwW2SbTMyMQWir+kTEIOPSyHkjZ9V83ixbD
 dqRYPNsh0CplPqrEhtHgbtuOC2VYZA8srcGoJp8ixoliEPzzxxWOobIsQb7U6Jlp16GH
 CKpWcMsvtfF937cfjuooB/pF6mM9L7YE8UkxXQ+Ka9auLH5xGDT1uC0K5Cule5x9/vss aw== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
	by userp2130.oracle.com with ESMTP id 2u0e1u71bm-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 02 Aug 2019 00:19:45 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
	by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x720Hm5f132175;
	Fri, 2 Aug 2019 00:19:44 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3030.oracle.com with ESMTP id 2u349eg2ac-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 02 Aug 2019 00:19:44 +0000
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x720JhFe006332;
	Fri, 2 Aug 2019 00:19:43 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 01 Aug 2019 17:19:42 -0700
Subject: =?UTF-8?Q?Re=3a_=5bMM_Bug=3f=5d_mmap=28=29_triggers_SIGBUS_while_do?=
 =?UTF-8?B?aW5nIHRoZeKAiyDigItudW1hX21vdmVfcGFnZXMoKSBmb3Igb2ZmbGluZWQgaHVn?=
 =?UTF-8?Q?epage_in_background?=
From: Mike Kravetz <mike.kravetz@oracle.com>
To: Li Wang <liwang@redhat.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        Linux-MM
 <linux-mm@kvack.org>, LTP List <ltp@lists.linux.it>,
        xishi.qiuxishi@alibaba-inc.com, mhocko@kernel.org,
        Cyril Hrubis <chrubis@suse.cz>
References: <CAEemH2dMW6oh6Bbm=yqUADF+mDhuQgFTTGYftB+xAhqqdYV3Ng@mail.gmail.com>
 <47999e20-ccbe-deda-c960-473db5b56ea0@oracle.com>
 <CAEemH2d=vEfppCbCgVoGdHed2kuY3GWnZGhymYT1rnxjoWNdcQ@mail.gmail.com>
 <a65e748b-7297-8547-c18d-9fb07202d5a0@oracle.com>
Message-ID: <27a48931-aff6-d001-de78-4f7bef584c32@oracle.com>
Date: Thu, 1 Aug 2019 17:19:41 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <a65e748b-7297-8547-c18d-9fb07202d5a0@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9336 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908020000
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9336 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908020000
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/30/19 5:44 PM, Mike Kravetz wrote:
> A SIGBUS is the normal behavior for a hugetlb page fault failure due to
> lack of huge pages.  Ugly, but that is the design.  I do not believe this
> test should not be experiencing this due to reservations taken at mmap
> time.  However, the test is combining faults, soft offline and page
> migrations, so the there are lots of moving parts.
> 
> I'll continue to investigate.

There appears to be a race with hugetlb_fault and try_to_unmap_one of
the migration path.

Can you try this patch in your environment?  I am not sure if it will
be the final fix, but just wanted to see if it addresses issue for you.

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index ede7e7f5d1ab..f3156c5432e3 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3856,6 +3856,20 @@ static vm_fault_t hugetlb_no_page(struct mm_struct *mm,
 
 		page = alloc_huge_page(vma, haddr, 0);
 		if (IS_ERR(page)) {
+			/*
+			 * We could race with page migration (try_to_unmap_one)
+			 * which is modifying page table with lock.  However,
+			 * we are not holding lock here.  Before returning
+			 * error that will SIGBUS caller, get ptl and make
+			 * sure there really is no entry.
+			 */
+			ptl = huge_pte_lock(h, mm, ptep);
+			if (!huge_pte_none(huge_ptep_get(ptep))) {
+				ret = 0;
+				spin_unlock(ptl);
+				goto out;
+			}
+			spin_unlock(ptl);
 			ret = vmf_error(PTR_ERR(page));
 			goto out;
 		}

