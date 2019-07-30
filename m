Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 198B4C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 14:12:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B009E2089E
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 14:12:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="EkbGpGGu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B009E2089E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 451F58E0005; Tue, 30 Jul 2019 10:12:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 402638E0001; Tue, 30 Jul 2019 10:12:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F0048E0005; Tue, 30 Jul 2019 10:12:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0DCA38E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 10:12:36 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id x10so58406419qti.11
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 07:12:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=XHjAJSStjFV66kiAbYW6uQF1Gtv9TpuNcUiFdII3gO8=;
        b=BUMWFdHNDhdmkNTmG+j2+FyExD5wz3SLBj/5gZtE6ILWpyQnmT74mzBw26lJkdlMVD
         VoYxe6k2sIY8DNjZXsrrXI6jKahnTmdFg8Q+wAewugjSJN5/9pEP9W7Sb7eUI46XQ5hO
         pdLxUS9dyXsvo++9TuKaAGlkmy0dfOH1DqmdxOxaS2A0NE4TLYh+AnH5A5tSHBD+WVuI
         OfptfMrp7gNdHDRVmkBC1DE1GBKLEqdHUeB4+VQdUA4M9gSigQ4SfbY61/VS+cXVYwgC
         YahwhA5i6XaKGKD8L4qJXLzwGDk98/RrIMSUp2YOJd0Pglpkp+rBolgnTKaL40v0GEKr
         CdVA==
X-Gm-Message-State: APjAAAX2tU2Gss6AiIAseY5Y/0vRhlHHd7rclt6lKwcTIwJ54t7Mz6BU
	UYcW434qCgi6XLgBsw+gM5rc5HJU7iYD88X5wlgjUAuA9x5t3jOJgsamijlXXNrethX2tTFlD/T
	V/oxgk+7ubh1gpKAxQMogcWz8pDIBl2/PwjzJkHh/spZQo7G58NLN5nPxhSoa6qB3Yg==
X-Received: by 2002:a05:620a:1270:: with SMTP id b16mr75816346qkl.333.1564495955823;
        Tue, 30 Jul 2019 07:12:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwh3RO5odsGpUeRh0DGjCFrjV9ZC3Qj9A4WbKsO91jl8JmTBuGYYZKlGh284ZQuHDgU4nEz
X-Received: by 2002:a05:620a:1270:: with SMTP id b16mr75816278qkl.333.1564495955172;
        Tue, 30 Jul 2019 07:12:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564495955; cv=none;
        d=google.com; s=arc-20160816;
        b=DP8WACf+Y0dILzu0gWtOxa2lJK46I+DR/xvhyLL/gQFpagtdVj+vJct4KL5FRlQ94y
         FGGS3X8vxP/6y8Wik+Rjb+/d+AcCJG5asRjhNkFMg7sv1Ndu3D7VnNywbtUdRhew7Gio
         OPK6zw14tgFSJIkOiwwXvz221HKG7Lh8NRh/RKs/0CKeK5nKFCeeM9LI/He65mssEbaF
         OZiPlgrr0iLFZqJLFVV80SUcZyLcGqC/rDEi85GelTY9rl41vmwS/rGb3cEWsM3bWhDX
         o2uRJAGLOwIYTLJfFldU2nGKPLays0VVLaqELP9R+Q+34C3JsEM1OFO6cE3RnHQ5xFIq
         G2Iw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=XHjAJSStjFV66kiAbYW6uQF1Gtv9TpuNcUiFdII3gO8=;
        b=AWMPSJlLKoDkNIFWftjLWLBuaEPAwWrQCtBFNazetSfgfmD24SeoMQCoB96gwznMlw
         iwmqmDpF7smL3WunWIG09Xk01rpaoxdfaYf4e+VH5ugFxFLLqWM8KNSjm9UsxpDuGKS+
         XBLxj7s0UYEGAaHK2oG9THbsnUtEo8Y4dn3diyJxokBk25iw0YPvDvZFpRLjqrneeTqT
         U2pPV/tzjwWD1Vs/faoWargL+fcp9s4GHAdmW3sjQcWsaW2mrPMkCidhdhvvQP1WUgr/
         erekmbozRgyvRbeosGf9kx6pFuhVn4TsKylrUhwukOExNY4oFuAdswrTw40Efme6CYbI
         N7nQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=EkbGpGGu;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id c40si39494931qta.60.2019.07.30.07.12.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 07:12:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=EkbGpGGu;
       spf=pass (google.com: domain of william.kucharski@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=william.kucharski@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6UDxQsu074495;
	Tue, 30 Jul 2019 14:12:03 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=XHjAJSStjFV66kiAbYW6uQF1Gtv9TpuNcUiFdII3gO8=;
 b=EkbGpGGuV8PO4LLUs9K2i+8ZCGMZNS5fbhFxL9owl9e3c38ydZTJUnMw0i4bjFG2xOJO
 vVqut1xfZWCoiJKo8gu2x6k9tk/z01l668eFm+KoNfXHXpHON3zWTKuzj/t5KVHVqpku
 xMZxZpVCpe+2pKmknn/M+Ia5yJMWGXmP1FN8WyvRYML+3/028MTcGVFK+5X/MG03JKO8
 k4Nr7Eb/0JQapuWuo8ThZ8kF2c4U9WYJpiv3YouuTFIB2JYjr36rzLhZ3wRQYEsgxZQH
 pmgRrWTq9Rt8nd5h6hmoC70yuutZUzl/54wnd+W71mVm/kuZnbqhG8tUMlix/sWSz3eb fg== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by userp2130.oracle.com with ESMTP id 2u0e1tpxgb-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 30 Jul 2019 14:12:03 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6UDwAZj029607;
	Tue, 30 Jul 2019 14:12:03 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userp3020.oracle.com with ESMTP id 2u2exa4efe-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 30 Jul 2019 14:12:02 +0000
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x6UEBrEn029376;
	Tue, 30 Jul 2019 14:11:53 GMT
Received: from localhost.localdomain (/73.243.10.6)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 30 Jul 2019 07:11:53 -0700
Subject: Re: [PATCH v2 2/2] mm,thp: Add experimental config option
 RO_EXEC_FILEMAP_HUGE_FAULT_THP
To: Song Liu <songliubraving@fb.com>
Cc: "ceph-devel@vger.kernel.org" <ceph-devel@vger.kernel.org>,
        "linux-afs@lists.infradead.org" <linux-afs@lists.infradead.org>,
        "linux-btrfs@vger.kernel.org" <linux-btrfs@vger.kernel.org>,
        lkml <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
        Networking <netdev@vger.kernel.org>, Chris Mason <clm@fb.com>,
        "David S. Miller" <davem@davemloft.net>,
        David Sterba <dsterba@suse.com>, Josef Bacik <josef@toxicpanda.com>,
        Dave Hansen
 <dave.hansen@linux.intel.com>,
        Bob Kasten <robert.a.kasten@intel.com>,
        Mike Kravetz <mike.kravetz@oracle.com>,
        Chad Mynhier <chad.mynhier@oracle.com>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
        Johannes Weiner <jweiner@fb.com>, Matthew Wilcox <willy@infradead.org>,
        Dave Airlie <airlied@redhat.com>, Vlastimil Babka <vbabka@suse.cz>,
        Keith Busch <keith.busch@intel.com>,
        Ralph Campbell <rcampbell@nvidia.com>,
        Steve Capper <steve.capper@arm.com>,
        Dave Chinner <dchinner@redhat.com>,
        Sean Christopherson <sean.j.christopherson@intel.com>,
        Hugh Dickins <hughd@google.com>, Ilya Dryomov <idryomov@gmail.com>,
        Alexander Duyck <alexander.h.duyck@linux.intel.com>,
        Thomas Gleixner <tglx@linutronix.de>,
        =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>,
        Amir Goldstein <amir73il@gmail.com>, Jason Gunthorpe <jgg@ziepe.ca>,
        Michal Hocko <mhocko@suse.com>, Jann Horn <jannh@google.com>,
        David Howells <dhowells@redhat.com>,
        John Hubbard <jhubbard@nvidia.com>,
        Souptick Joarder <jrdr.linux@gmail.com>,
        "john.hubbard@gmail.com" <john.hubbard@gmail.com>,
        Jan Kara <jack@suse.cz>, Andrey Konovalov <andreyknvl@google.com>,
        Arun KS <arunks@codeaurora.org>,
        "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
        Jeff Layton <jlayton@kernel.org>, Yangtao Li <tiny.windzz@gmail.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Robin Murphy <robin.murphy@arm.com>,
        Mike Rapoport <rppt@linux.ibm.com>,
        David Rientjes <rientjes@google.com>,
        Andrey Ryabinin <aryabinin@virtuozzo.com>,
        Yafang Shao
 <laoar.shao@gmail.com>,
        Huang Shijie <sjhuang@iluvatar.ai>,
        Yang Shi <yang.shi@linux.alibaba.com>,
        Miklos Szeredi <mszeredi@redhat.com>,
        Pavel Tatashin <pasha.tatashin@oracle.com>,
        Kirill Tkhai <ktkhai@virtuozzo.com>, Sage Weil <sage@redhat.com>,
        Ira Weiny <ira.weiny@intel.com>,
        Dan Williams <dan.j.williams@intel.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Gao Xiang <hsiangkao@aol.com>,
        Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
        Ross Zwisler <zwisler@google.com>
References: <20190729210933.18674-1-william.kucharski@oracle.com>
 <20190729210933.18674-3-william.kucharski@oracle.com>
 <E6E92F42-3FA0-473C-B6F2-E23826C766F5@fb.com>
From: William Kucharski <william.kucharski@oracle.com>
Message-ID: <ffbdd056-e80c-41f4-37c4-c8b758fb59e7@oracle.com>
Date: Tue, 30 Jul 2019 08:11:48 -0600
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <E6E92F42-3FA0-473C-B6F2-E23826C766F5@fb.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9334 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1907300146
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9334 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1907300146
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 7/29/19 4:51 PM, Song Liu wrote:

>
>> +#define	HPAGE_PMD_OFFSET	(HPAGE_PMD_SIZE - 1)
>            ^ space vs. tab difference here.

Thanks, good catch!

> 
>> +#define HPAGE_PMD_MASK		(~(HPAGE_PMD_OFFSET))
>> +
>> +#define HPAGE_PUD_SHIFT		PUD_SHIFT
>> +#define HPAGE_PUD_SIZE		((1UL) << HPAGE_PUD_SHIFT)
>> +#define	HPAGE_PUD_OFFSET	(HPAGE_PUD_SIZE - 1)

Saw this one, too.

> Should HPAGE_PMD_OFFSET and HPAGE_PUD_OFFSET include bits for
> PAGE_OFFSET? I guess we can just keep huge_mm.h as-is and use
> ~HPAGE_PMD_MASK.

That's what I had intended; would you rather see those macros
omit the unneeded for the larger page size bits?

>> - * - FGP_PMD: If FGP_CREAT is specified, attempt to allocate a PMD-sized page.
>> + * - FGP_PMD: If FGP_CREAT is specified, attempt to allocate a PMD-sized page

No - this came in as part of patch 1/2 and I missed dropping the period 
at the end of the line that caused this to be a diff, so I will put it
back. :-)

> We have been using name "xas" for "struct xa_state *". Let's keep using it?

Thanks, done.

>> +	if (unlikely(!(PageCompound(new_page)))) {
> 
>     What condition triggers this case
I wanted a check to make sure that __page_cacke_alloc() returned a large 
page. I don't recall if the mechanism guarantees that when you ask for
a large page, you get one, so I wanted to handle that case.

If you prefer, I could make this a VM_BUG_ON_PAGE() instead, but I
wanted it to fallback gracefully if it can't get a properly sized
page.

>> +#ifndef	COMPOUND_PAGES_HEAD_ONLY
> 
> Where do we define COMPOUND_PAGES_HEAD_ONLY?

At present, we do not.

I used this so I could include the code that would be needed once
Matthew's "store only head pages in page cache" changes go back in,
which looks like it may not be until 5.4-rc1. Matthew recommended I
include this so we didn't lose track of the code change that would be
needed then. I'll be talking to him today about this and the issues
you raised regarding patch 1/2.

Thanks for going through this!!

     -- Bill

