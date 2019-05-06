Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBF19C04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 17:20:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DB6A2053B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 17:20:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="FSlD/GUQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DB6A2053B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 37A5E6B000A; Mon,  6 May 2019 13:20:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 32A1F6B000C; Mon,  6 May 2019 13:20:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1F2086B026A; Mon,  6 May 2019 13:20:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id DAB456B000A
	for <linux-mm@kvack.org>; Mon,  6 May 2019 13:20:01 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id n4so8402485pgm.19
        for <linux-mm@kvack.org>; Mon, 06 May 2019 10:20:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=lm/pUQLSmHfHBwQh1FqE2NU2hu5mjgOk5sT30/V+Yq4=;
        b=Khi1UNqmSpvbFjQGSvV3XPl/C4lWn+OCAbJg7sHtDzCr8gZxu7XCDNvL9ZF1jSlG3p
         bPcqcHVTyBSG2rKCQknNtib0Vy5nJ+G5YzoksDAb6VvRpl+V8Nj+zTBXyRINGTp54OTs
         nxlsCZfIUW98EFhy5rLoKsTJtmejEEBxdvI0nT83bVnWGLwtnVttYXuVoS4oHTSZuhKQ
         eXDzOJf7vtgYA2lpYkT3LLq2mN2iPENUC069bW8rg1oQNNMzII/J4ti2Y9RFKWVj+gzE
         CQi2RHfhmt3wb9jzRmSb21vOmyc1QE+vIcV4HHY4iEx8luvl0/zEJisAf7j5oRr0FcPp
         s7Cg==
X-Gm-Message-State: APjAAAXm5L4ad5O62Nv9p12e2js0i3V8SxYFP3PnVtm9VppvHgS9Bmf7
	n8mfUyXBgwolz8L6LODhWrzKOmS8NtwqltB0kyEuZXisQ0pf7F+JQzNs2Sv69Tf4/UcOOGkKH6o
	EciITQ9DQV1KR1OoJf1i0hAiZ4Civuo8olEMxvR/H5vncURaC6W/C6fhbSwRzqryEcg==
X-Received: by 2002:a63:6604:: with SMTP id a4mr33929318pgc.104.1557163201245;
        Mon, 06 May 2019 10:20:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBBLPVRFSgKMjb+cCZUOuUItG2qQIv0x9JTtdYjFFUekM36AZyPEYr45bt8G7OZNjSxxa3
X-Received: by 2002:a63:6604:: with SMTP id a4mr33929220pgc.104.1557163200270;
        Mon, 06 May 2019 10:20:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557163200; cv=none;
        d=google.com; s=arc-20160816;
        b=ciatt6LyqYDr3jtT5GjiZASy4ezSYhjJ6ZEBEMsaZPLpVFeSca/XQKivCJwmHeKzj8
         WhhIsWKh/xtPmjvWrFQFEGDbxxrXzyDRi7hLlI8PwX+1qwwkY3ct7Fb8Uo4/ZLDxH1sO
         osAdlRKeWzGbEiIbjjkHtG7YFDoJIv+K2oHg4KIz96N0SrxfLwhljWAjH+l8D2FvZk8p
         rit+fcOUhYxqT10bNW4+j4nyM15rnGxJglGtTtK34SDU4OhTNCt36nLjQw+zSkosCoCy
         gPGIWytC3Kj+JhZatrpiFMqAOVM6ihQqJ9qhjpBMEYg7K/ig85lt7BpGEn6M9he1/o/y
         nHeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=lm/pUQLSmHfHBwQh1FqE2NU2hu5mjgOk5sT30/V+Yq4=;
        b=jRGZt5OkBUHUf7IjvKnz5++Z6dVG7DB0qkl0R3b14APFLX5e4Qvf9UNCcU49bnD3+w
         wRJdluQmqnhRmODp8NohKmyBUrLRz+tULA+vc9YJbuA1G2ReXOZKlyo7F8DAW4Bv0O3J
         h4uYRPcjzDKbfay8obuOCPH/cDS6Fm32uav82uGqpM8xWxtxbGsJnF649PqrPDP0T49K
         39X9Skhud5u81DxTIPQ6CNXEwebuzZfYY6I2HJ7KTZw25Wi3LXqY4bFEzkkBjbO5O3GC
         QY/8pvBQRsk8RebcrXpssqP+oc1NB8Ac7mYmP3fELnu1efkhtVS3EINowtQy8AtIFkk9
         l1/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="FSlD/GUQ";
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id m73si16345580pga.271.2019.05.06.10.19.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 10:20:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) client-ip=141.146.126.79;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b="FSlD/GUQ";
       spf=pass (google.com: domain of mike.kravetz@oracle.com designates 141.146.126.79 as permitted sender) smtp.mailfrom=mike.kravetz@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x46HIoKc023713;
	Mon, 6 May 2019 17:19:52 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=lm/pUQLSmHfHBwQh1FqE2NU2hu5mjgOk5sT30/V+Yq4=;
 b=FSlD/GUQwmeWCi/moIjGfBBk7pXux9pCWz2oUKjG4fHWmXQNVXfjkhICzZauPcnvj8F8
 zdupdKCRhok29PFx3GszVS/7F2xnLBMd3S5W5WZxaF40WJvC/7jGP3LQKDZ+X6fCSc7V
 74T0VUKC00iyKE6Q0X+BBQyOxu3RRZy/3sEzlqeljKS1mkuViXuyPX7LqZm5ULdjXpj1
 cteiCAmxvc+RIn15xrIQHYZ6XWfEI/D4lJs0NdzurUVd+tcx/6yH2nlWJ8ijTi7zR27I
 PpqMos/sj4SZww1SLJKOcvdOmpoPi3d8j2gIKhD5UG2vIDTyw4FT7H5DGPmoPA/KwH1E eQ== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by aserp2130.oracle.com with ESMTP id 2s94b5r1s2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 06 May 2019 17:19:52 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x46HJpiH179798;
	Mon, 6 May 2019 17:19:51 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3030.oracle.com with ESMTP id 2sagytfn3j-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Mon, 06 May 2019 17:19:51 +0000
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x46HJkkf010497;
	Mon, 6 May 2019 17:19:46 GMT
Received: from [192.168.1.222] (/71.63.128.209)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Mon, 06 May 2019 10:19:46 -0700
Subject: Re: [PATCH v2] mm/hugetlb: Don't put_page in lock of hugetlb_lock
To: Zhiqiang Liu <liuzhiqiang26@huawei.com>, mhocko@suse.com,
        shenkai8@huawei.com, linfeilong@huawei.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, wangwang2@huawei.com,
        "Zhoukang (A)" <zhoukang7@huawei.com>,
        Mingfangsen <mingfangsen@huawei.com>, agl@us.ibm.com, nacc@us.ibm.com
References: <12a693da-19c8-dd2c-ea6a-0a5dc9d2db27@huawei.com>
 <b8ade452-2d6b-0372-32c2-703644032b47@huawei.com>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <9405fcd5-a5a7-db4a-d613-acf2872f6e62@oracle.com>
Date: Mon, 6 May 2019 10:19:44 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <b8ade452-2d6b-0372-32c2-703644032b47@huawei.com>
Content-Type: text/plain; charset=gbk
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9249 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905060147
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9249 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905060147
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/6/19 7:06 AM, Zhiqiang Liu wrote:
> From: Kai Shen <shenkai8@huawei.com>
> 
> spinlock recursion happened when do LTP test:
> #!/bin/bash
> ./runltp -p -f hugetlb &
> ./runltp -p -f hugetlb &
> ./runltp -p -f hugetlb &
> ./runltp -p -f hugetlb &
> ./runltp -p -f hugetlb &
> 
> The dtor returned by get_compound_page_dtor in __put_compound_page
> may be the function of free_huge_page which will lock the hugetlb_lock,
> so don't put_page in lock of hugetlb_lock.
> 
>  BUG: spinlock recursion on CPU#0, hugemmap05/1079
>   lock: hugetlb_lock+0x0/0x18, .magic: dead4ead, .owner: hugemmap05/1079, .owner_cpu: 0
>  Call trace:
>   dump_backtrace+0x0/0x198
>   show_stack+0x24/0x30
>   dump_stack+0xa4/0xcc
>   spin_dump+0x84/0xa8
>   do_raw_spin_lock+0xd0/0x108
>   _raw_spin_lock+0x20/0x30
>   free_huge_page+0x9c/0x260
>   __put_compound_page+0x44/0x50
>   __put_page+0x2c/0x60
>   alloc_surplus_huge_page.constprop.19+0xf0/0x140
>   hugetlb_acct_memory+0x104/0x378
>   hugetlb_reserve_pages+0xe0/0x250
>   hugetlbfs_file_mmap+0xc0/0x140
>   mmap_region+0x3e8/0x5b0
>   do_mmap+0x280/0x460
>   vm_mmap_pgoff+0xf4/0x128
>   ksys_mmap_pgoff+0xb4/0x258
>   __arm64_sys_mmap+0x34/0x48
>   el0_svc_common+0x78/0x130
>   el0_svc_handler+0x38/0x78
>   el0_svc+0x8/0xc
> 
> Fixes: 9980d744a0 ("mm, hugetlb: get rid of surplus page accounting tricks")
> Signed-off-by: Kai Shen <shenkai8@huawei.com>
> Signed-off-by: Feilong Lin <linfeilong@huawei.com>
> Reported-by: Wang Wang <wangwang2@huawei.com>
> Acked-by: Michal Hocko <mhocko@suse.com>

Good catch.  Sorry, for the late reply.

Reviewed-by: Mike Kravetz <mike.kravetz@oracle.com>
-- 
Mike Kravetz

