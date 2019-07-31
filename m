Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B858EC32750
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 00:44:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48F1020665
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 00:44:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="pQJ+lKld"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48F1020665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB6548E0003; Tue, 30 Jul 2019 20:44:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A669B8E0001; Tue, 30 Jul 2019 20:44:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 92F4D8E0003; Tue, 30 Jul 2019 20:44:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7254E8E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 20:44:43 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id w17so73443003iom.2
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 17:44:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=k6ekATruC6j87E/vcYZ9wuBsE4DGKdcSaK/xyWq6FlE=;
        b=TubD250L9b8WkJw12JJhWdmBgpy3Gm4Z8V+Mff8y5qs59qcc2xhse/WKjS4XBsicxm
         +yfN4IcEvqk0MlJEm4qBb6AtAR1YCtmtOSEnJvwa7aropswleaRcHOyaHikmeLKw50hz
         oK3Nqsly6428AI9ssGhHqCmb4D/Uv8921Zu7FaEJ9VwDMOiDfF64a+g7y894A71qW+FO
         0Cy0G44xNJGtt4JsFjG8KKWYhRgVjWevv+1pvWtLHszKSesoMFX2R31Cb+G7kG3UPPXb
         wSNfrTjDMrwuXdOiJfewvHZ1kg34aFnHDZLpjvW86Lnzd4t2qaIaFQcT/TFJ2WYRVJQu
         RoTg==
X-Gm-Message-State: APjAAAVy0F7ielSQAhxYemVuAXY9xo0Shlsy2c1aht359e6uLlFM0Ppr
	jkevHqozG7H9rFgwAvcBWBF17/TSJWE1E8eAjs7oDG0X64vOTyk0F46pGrcdMIicbLfp42+UdMo
	USyKf/IBIuCRYY5jsfRNuSWw8BZva+Rg+xYvtriYL3o37iJER9IBIi/PLgm3vkeEN1w==
X-Received: by 2002:a02:c549:: with SMTP id g9mr4654295jaj.14.1564533883155;
        Tue, 30 Jul 2019 17:44:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/IiIu2cctjswceFLVfh2E3t/+my18Z+7DVBb2lUP7+rqsErhpS20zh6TWgJE6b5OKsFgC
X-Received: by 2002:a02:c549:: with SMTP id g9mr4654239jaj.14.1564533882348;
        Tue, 30 Jul 2019 17:44:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564533882; cv=none;
        d=google.com; s=arc-20160816;
        b=NeYMjJiyTeB+catWcnLJ1sRcrpmi4yaFFa3RyYiKP8eOWV0hWluTvNRA6TPD5Rr5Y5
         rjwx5ce3BQKhukoPy4nUYnDA4kx+J66iN9j+MZ/76w9j6iSQhOtAuqjsTyWZK/KkmCB5
         7Dvh6nS33JRfoA7WwonRz0tPvH0lrY/sj3GBuER2tYeuKZzh8CjC3kWkxTzdMiF7W54I
         TmSFWwRlZIQMaglNQmWlYuD29RGv7LFabYrq1xIN2vS6rBelSA9PG88xO7gC5XBrcLal
         K1zSOgVNjAnpljDubEm/qPqgMbVUajOOeshrgxx5sdQeVRXuShZMm0aeWO3Tqe3Ou9SN
         4CZQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=k6ekATruC6j87E/vcYZ9wuBsE4DGKdcSaK/xyWq6FlE=;
        b=yzRv4TrIS+9pxm+F0E+HT9Fl8YjrVOEyvZNFV4NjraeXPB5CldMNkPHyfuOXMHmRuW
         k9RO0DbwEHGnrh5813Y/SHw4w4cz0f2JELusqvEe9jlHUpwimRhSU02d29kFKjgoPWiP
         JnD9g7mVa05SIuTctKS1lp8AgdA5F92rm6u0J8eUt5dvGqFN1yLg+0fpjKHbHYpQmQKL
         nsqdI4lVe2u+9Vb+TqG8HQeIdQa46ta0ElZ7JZkQdwNelMMRtGfhdV7N+XsfAeygPY0l
         6CK+5uA72CE7plTXRJc0j5ZOYt8vEOXfOOnOTIQ7j9cBRTubHKnweKLeIq+00zFaVYdV
         6HEg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=pQJ+lKld;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id e8si95330533jaj.110.2019.07.30.17.44.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 17:44:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=pQJ+lKld;
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6V0iVaN108615;
	Wed, 31 Jul 2019 00:44:31 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=k6ekATruC6j87E/vcYZ9wuBsE4DGKdcSaK/xyWq6FlE=;
 b=pQJ+lKldoKlG2Ffa3L3CgrQXTumrWsyML3443xlQeqdOsuy5EjXKWXsHzGfuU2C3baZt
 tzKmj/2mzu1LqvhJ+CahWFznmTkyQi1WJnyIQvlfdIp+VsFZaIvBUkIT7Bc1c5Qwg2Lw
 R9R8mC4kwAQOU5iMO6zJI/51zhq2bFEQgqkFpduLxxU8xcGVzw49mtqj5GLZRPVOaPfB
 eAx55LwLYI9GbsZYhFHDTCqgwgIHlSB6HGA2+UTagKwXXhhI0CdZD8izayQqW9QyY/mi
 tWF6Y+40P+HDqBt/H+A7s+RwMYdN5EGX31AJclz4vWr40nUsoX56R1tyWqBr1VEGdhlx sg== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by aserp2120.oracle.com with ESMTP id 2u0ejphpmp-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 31 Jul 2019 00:44:31 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6V0gaPY095554;
	Wed, 31 Jul 2019 00:44:30 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3020.oracle.com with ESMTP id 2u2jp4hj1u-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 31 Jul 2019 00:44:30 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x6V0iNAI000800;
	Wed, 31 Jul 2019 00:44:23 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 30 Jul 2019 17:44:23 -0700
Subject: =?UTF-8?Q?Re=3a_=5bMM_Bug=3f=5d_mmap=28=29_triggers_SIGBUS_while_do?=
 =?UTF-8?B?aW5nIHRoZeKAiyDigItudW1hX21vdmVfcGFnZXMoKSBmb3Igb2ZmbGluZWQgaHVn?=
 =?UTF-8?Q?epage_in_background?=
To: Li Wang <liwang@redhat.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        Linux-MM
 <linux-mm@kvack.org>, LTP List <ltp@lists.linux.it>,
        xishi.qiuxishi@alibaba-inc.com, mhocko@kernel.org,
        Cyril Hrubis <chrubis@suse.cz>
References: <CAEemH2dMW6oh6Bbm=yqUADF+mDhuQgFTTGYftB+xAhqqdYV3Ng@mail.gmail.com>
 <47999e20-ccbe-deda-c960-473db5b56ea0@oracle.com>
 <CAEemH2d=vEfppCbCgVoGdHed2kuY3GWnZGhymYT1rnxjoWNdcQ@mail.gmail.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <a65e748b-7297-8547-c18d-9fb07202d5a0@oracle.com>
Date: Tue, 30 Jul 2019 17:44:22 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CAEemH2d=vEfppCbCgVoGdHed2kuY3GWnZGhymYT1rnxjoWNdcQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9334 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1907310005
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9334 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1907310005
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/29/19 11:29 PM, Li Wang wrote:
> It's not 100% reproducible, I tried ten times only hit 4~6 times fail.
> 
> Did you try the test case with patch V3(in my branch)?
> https://github.com/wangli5665/ltp/commit/198fca89870c1b807a01b27bb1d2ec6e2af1c7b6
> 

My bad!  I was using an old version of the test without the soft offline
testing.

> # git clone https://github.com/wangli5665/ltp ltp.wangli --depth=1
> # cd ltp.wangli/; make autotools;
> # ./configure ; make -j24
> # cd testcases/kernel/syscalls/move_pages/
> # ./move_pages12 
> tst_test.c:1100: INFO: Timeout per run is 0h 05m 00s
> move_pages12.c:249: INFO: Free RAM 64386300 kB
> move_pages12.c:267: INFO: Increasing 2048kB hugepages pool on node 0 to 4
> move_pages12.c:277: INFO: Increasing 2048kB hugepages pool on node 1 to 4
> move_pages12.c:193: INFO: Allocating and freeing 4 hugepages on node 0
> move_pages12.c:193: INFO: Allocating and freeing 4 hugepages on node 1
> move_pages12.c:183: PASS: Bug not reproduced
> tst_test.c:1145: BROK: Test killed by SIGBUS!
> move_pages12.c:117: FAIL: move_pages failed: ESRCH

Yes, I can recreate.

When I see this failure, the SIGBUS is the result of a huge page allocation
failure.  The allocation was in response to a page fault.

Note that running the test will deplete memory of the system as huge pages
are marked 'poisoned' and can not be reused.  So, each run of the test will
take additional memory offline.

A SIGBUS is the normal behavior for a hugetlb page fault failure due to
lack of huge pages.  Ugly, but that is the design.  I do not believe this
test should not be experiencing this due to reservations taken at mmap
time.  However, the test is combining faults, soft offline and page
migrations, so the there are lots of moving parts.

I'll continue to investigate.

Naoya may have more context as he contributed to both the kernel code and
the testcase.
-- 
Mike Kravetz

