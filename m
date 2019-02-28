Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C6A7C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 19:55:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C592F218AE
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 19:55:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="Snme+H0X"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C592F218AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 47AAE8E0004; Thu, 28 Feb 2019 14:55:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 429F38E0001; Thu, 28 Feb 2019 14:55:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2CB738E0004; Thu, 28 Feb 2019 14:55:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id F330A8E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 14:55:48 -0500 (EST)
Received: by mail-yw1-f72.google.com with SMTP id h2so18551679ywm.11
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 11:55:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :openpgp:autocrypt:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=BQykvYhRUAwJYzwviW9IjdI42oTTZwsnFOiROkKx/D0=;
        b=p01e1ysr/a3CnNEXt6pTZQL/TMKOQuoFwDgAyHsTtIGyoTVDPv/1D6EVQnYPND3ZdW
         vFM2g28oeO6o994gvHQjy1CeABVS7/Wg3mKjywjQli6P6fEwrxCLwje92vg6UHTO5Lvu
         SLh1Rk1QKczIVhpFWVO0ta/ZlsvEfZrSOhjmxIZnAov0NjZEwI0S9VaafJRoOqlAlhPC
         nyJT+DGYYpBJg8bRxIuPc1p2TSvYDcBUWBMlwA1RQIe38AkF1v/sYFB3Hvd11PDZw+H+
         mKZz31fcI6Z3hcP7JYyuEMV8K4JA1+VUEIfkavcolCyBLXdNF/U4nTVLttqkCF0mAxvX
         gndw==
X-Gm-Message-State: APjAAAVXlEkaPGqc4X7htGUXIsHnbiIxKGL0h6jNBJnjTaXRm0+H1HB6
	810C2qaem5Jzhw00du/pvP9KAUs9WgMJiwcaH5GzmYmsdyDnTEIUQbvmDl5MbT7v3wsNJyHDAtW
	LiUY1Hii78TR0yAU7nOUr/wDQE2ZhSymG0w/hctzfDLW/j1zyzIhdhTGrBtEY8skXnA==
X-Received: by 2002:a81:9850:: with SMTP id p77mr594411ywg.243.1551383748724;
        Thu, 28 Feb 2019 11:55:48 -0800 (PST)
X-Google-Smtp-Source: APXvYqytIM2gw0wDPGPDxWjlbrd2n2gY+ovG9XSKsQgJW9TNFjEl6eEJ5JJy5ABmLWS57gN3Z1oM
X-Received: by 2002:a81:9850:: with SMTP id p77mr594387ywg.243.1551383748104;
        Thu, 28 Feb 2019 11:55:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551383748; cv=none;
        d=google.com; s=arc-20160816;
        b=OG5d4S5TgVbt8/q4XTRt0EHBJFeIkpN6Qw9vl4N+nmo73mkhTPIPeEkGw97lC1R0PB
         QoIbRfwsw1QZqxTBwFOFCyqdAJc35ciKf/fTwYMNfa1/aLDrS1ueO3SCV9vFh3ZoHz+S
         0SB4s9PomRRfykpTA4KuNxd5V863BhYj9TE6G2YKHVuJukjD3sR2H2/UXO2CaKKy6TCA
         oACsC25leeOn7XJ+o6dygbxBbDBIv/1SEVAJYRuUecpGqo+Z0US8xn6fJ96HFl2kzez9
         KgWtR2IqkSTqZ+tEOYVxbzXYqmZjccf6m6OUb4klk6SJIGDCGPZ9i5fvooZM/CYlNiRP
         rJMA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:autocrypt:openpgp:from:references:cc:to
         :subject:dkim-signature;
        bh=BQykvYhRUAwJYzwviW9IjdI42oTTZwsnFOiROkKx/D0=;
        b=k/MYNN8IC5tARssmlmBozAScz/JIi1Gdbf3UXWEmOUek9EoU2sU9CrTEPk1pFFIc8H
         lSutvHDvOB38xW1/cqJGv6q5Cxp8NI5Pg6t0mh9DQ+R0p5MwNsFXGBir7BrJ+6CLNKHW
         RStc9wW16D2nVcNyWaVcon6OImgFPRnodHoW2mBtSpdUM9IPOl+e/YfJrH8yDF6VyeZG
         7um1zgBxzyky14AgDtIwtbsCie9uFDvNZvhQpVf+pX0hb9zeVJ4l/3GouyrlGiR0hacH
         m3fchgV4D1KSgp6EwiPrQ6GtaQnB8hb63sjav7XdK5oAy/I2TuyHMme6JDt0qkeghXVi
         s63g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Snme+H0X;
       spf=pass (google.com: domain of boris.ostrovsky@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=boris.ostrovsky@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id v201si8975197ybe.478.2019.02.28.11.55.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Feb 2019 11:55:48 -0800 (PST)
Received-SPF: pass (google.com: domain of boris.ostrovsky@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=Snme+H0X;
       spf=pass (google.com: domain of boris.ostrovsky@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=boris.ostrovsky@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1SJmXGF013072;
	Thu, 28 Feb 2019 19:55:08 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=BQykvYhRUAwJYzwviW9IjdI42oTTZwsnFOiROkKx/D0=;
 b=Snme+H0X+SBu1KPluj8zNnINQGb+XaKD9viIjTqZQxOrYyMLEnzuhjKYLFauL65IivtF
 F30wQcS7Q3eg/SG3d9eaQGRYLjefS/FLs6zAMZSYuq1gfDJ0p0K9shc05Re0C/eCgBUZ
 iQFq6+jEBBx3pDO8j5AfaLfcl2gMRgOuxR1Y139ud7kuGppvlWzbQy7cEsPSDO5O5agW
 9Bwut4EGqQseLqtIbeN+93EzAQURC5DaAbgs9JdLPzbNMbVUoNG6apb5BRpnOI7J2uad
 VMGhKYh1Yi8wxIFrYv1k1+aSGpsLtIKtFNlKMBIhExu1Jn/ApFzVqEEYjg9h3dCj83xZ Gw== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2120.oracle.com with ESMTP id 2qtxts36wt-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Feb 2019 19:55:08 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id x1SJt8ve000374
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 28 Feb 2019 19:55:08 GMT
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1SJt4HZ008548;
	Thu, 28 Feb 2019 19:55:04 GMT
Received: from dhcp-burlington7-2nd-B-east-10-152-55-162.usdhcp.oraclecorp.com (/10.152.32.65)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 28 Feb 2019 11:55:04 -0800
Subject: Re: [PATCH v2 0/8] mm/kdump: allow to exclude pages that are
 logically offline
To: Andrew Morton <akpm@linux-foundation.org>, Dave Young <dyoung@redhat.com>
Cc: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
        devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org,
        linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org,
        kexec-ml <kexec@lists.infradead.org>, pv-drivers@vmware.com,
        Alexander Duyck <alexander.h.duyck@linux.intel.com>,
        Alexey Dobriyan <adobriyan@gmail.com>, Arnd Bergmann <arnd@arndb.de>,
        Baoquan He <bhe@redhat.com>, Borislav Petkov <bp@alien8.de>,
        Christian Hansen <chansen3@cisco.com>,
        David Rientjes <rientjes@google.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Haiyang Zhang <haiyangz@microsoft.com>,
        Jonathan Corbet <corbet@lwn.net>, Juergen Gross <jgross@suse.com>,
        Julien Freche <jfreche@vmware.com>, Kairui Song <kasong@redhat.com>,
        Kazuhito Hagio <k-hagio@ab.jp.nec.com>,
        "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
        Konstantin Khlebnikov <koct9i@gmail.com>,
        "K. Y. Srinivasan" <kys@microsoft.com>,
        Len Brown <len.brown@intel.com>, Lianbo Jiang <lijiang@redhat.com>,
        Matthew Wilcox <willy@infradead.org>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Michal Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>,
        Miles Chen <miles.chen@mediatek.com>, Nadav Amit <namit@vmware.com>,
        Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
        Omar Sandoval <osandov@fb.com>, Pankaj gupta <pagupta@redhat.com>,
        Pavel Machek <pavel@ucw.cz>,
        Pavel Tatashin <pasha.tatashin@oracle.com>,
        "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>,
        "Rafael J. Wysocki" <rjw@rjwysocki.net>,
        Stefano Stabellini <sstabellini@kernel.org>,
        Stephen Hemminger <sthemmin@microsoft.com>,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        Vitaly Kuznetsov <vkuznets@redhat.com>,
        Vlastimil Babka <vbabka@suse.cz>,
        Xavier Deguillard <xdeguillard@vmware.com>
References: <20181122100627.5189-1-david@redhat.com>
 <20190227053214.GA12302@dhcp-128-65.nay.redhat.com>
 <20190228114535.150dfaebbe4d00ae48716bf0@linux-foundation.org>
From: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Openpgp: preference=signencrypt
Autocrypt: addr=boris.ostrovsky@oracle.com; prefer-encrypt=mutual; keydata=
 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
 Jg6OxFYd01z+a+oL
Message-ID: <2d46475b-4f7e-7a71-b74e-abeaf31fca15@oracle.com>
Date: Thu, 28 Feb 2019 14:54:47 -0500
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190228114535.150dfaebbe4d00ae48716bf0@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9181 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902280133
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2/28/19 2:45 PM, Andrew Morton wrote:
> On Wed, 27 Feb 2019 13:32:14 +0800 Dave Young <dyoung@redhat.com> wrote:
>
>> This series have been in -next for some days, could we get this in
>> mainline? 
> It's been in -next for two months?
>
>> Andrew, do you have plan about them, maybe next release?
> They're all reviewed except for "xen/balloon: mark inflated pages
> PG_offline". 
> (https://ozlabs.org/~akpm/mmotm/broken-out/xen-balloon-mark-inflated-pages-pg_offline.patch).
> Yes, I plan on sending these to Linus during the merge window for 5.1
>


This was reviewed:

https://lore.kernel.org/lkml/3d5250b7-870e-e702-a6e4-937d2362fea4@suse.com/



-boris

