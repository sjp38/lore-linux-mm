Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59D4BC43219
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 19:08:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76002206A3
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 19:08:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=vmware.com header.i=@vmware.com header.b="crdakZE8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76002206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 96F5D6B000A; Thu, 25 Apr 2019 15:08:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 91E556B000C; Thu, 25 Apr 2019 15:08:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 810746B000D; Thu, 25 Apr 2019 15:08:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 618116B000A
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 15:08:25 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id f20so734242qtf.3
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 12:08:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:thread-topic
         :thread-index:date:message-id:references:in-reply-to:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=cGN+2eGnFRjQKKRet0DhCtdHwhr+g4OStM4ZwhGCD9I=;
        b=m5KwIo+y4f0JCEewIkqfnV75bfUeuMw3yQtaEJ457+WhRMuc+3OuydJpbhZl9yk8q1
         Apq9Z/V1BtIYRUJEKoZluA8HimAeQjl37wT7w/DbGdybPs3Al0rugyLLAe/IT2tcchR1
         wOUmvHLj/WBkyG0Nco90yMUFDMGEmvf2CrPVsryg5pOS7zyVkkJBPuLXKQGcXgoaxrNA
         QJnsH2HRPtKDS1rQwM92svFyxEMvG1at6YBaBcOawRRR8FwQIUNUJU1CHi+zRXiKK6x8
         hn1p7iiDVsxAjKB7lzVeVV0YIDMIxOVviIkg4v7C4N2giIX/PjVldX3BrBdZPK6LFlJ9
         z8bg==
X-Gm-Message-State: APjAAAXLDskFz/Mra461CLh4Y6sc5GHncAJe7xJXNLMtZPv7/Jv7VLS7
	jaJcjZV02DZtMlk25CyDw3T1Fsl+3Gr115tmZycYNh2UKetGz5LLW7zZgGLcjstWSpvYNbCIvqL
	8PqoyqJbn+5nWAMyrD6nOuylqxN9ian4sKjFy29DxOsENmG0+pLjCqcQDdpDIpRNghw==
X-Received: by 2002:ac8:260d:: with SMTP id u13mr32725845qtu.32.1556219305060;
        Thu, 25 Apr 2019 12:08:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxxnBspMhFSKsWBa7vvjgVDyx/KHajfMlsb56oj0BTqBLgyPunRqweJFcIxcEsu2YV2bEaz
X-Received: by 2002:ac8:260d:: with SMTP id u13mr32725756qtu.32.1556219304095;
        Thu, 25 Apr 2019 12:08:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556219304; cv=none;
        d=google.com; s=arc-20160816;
        b=xY+vo/jUvX9xlpePO4TT2BxWr5tZEy6j5bR1fHiI2mmzKiCHZ2rkC5yAOBX3knRv45
         GXWwTtWXHOsIoPSYv8oBBRqmVZFKFEXk14So6yd5v7QUk5WZ8+3jSTCuokx9HR8UKodp
         ydaO3IHlkCh14J0Stlf07zeTxXiGRsQnwQymNdyxeAOfWfIpC2fZZOmhWXsoZ3rbzRJd
         +sSTDtzhhDMggLcpodRh7xw2xUag7n+qilEb1pjmJXLPsuAjJ+V3orZGBmTUY+ji0Cra
         oNoyAhHmZRkeJ5F8ZQ9MLjK8hrwDy5A6K0qWi6GjbFb2W1Xnu8pbNncvXlGJ/VpqF6R2
         Rh+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature;
        bh=cGN+2eGnFRjQKKRet0DhCtdHwhr+g4OStM4ZwhGCD9I=;
        b=fhxwB/SSFF8Mn4KyPBwc6wyi1Uq+QT4FokL8rdga9vtZpoHdCHg3LXXZyQdzSCkdxZ
         mi+22IHETzWLNaa8GTokRVUDhtKfYOvY8SIQNbVVTyXrxL0sFJUtTeWTaXnryaua0t0F
         MpPIsHBXo8/ZLpEQmo8qnWmOLWlJ41Ki11l2JmR2lQNJdZinGy0MlhpTWGmLZzi4itmf
         kzrX0RRRwxy8cy5p27dVXeqMej8ihsFYHF30xEoYUjUP8jGvGvnlopaOT5eHxX6ib6FG
         rV0+05PmUCaKYDhoArGS//b6gw7okHLTOA4i6uauIBb+07cvEM4qRvtgd6QjGRv+KnvJ
         OT3w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=crdakZE8;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.74.40 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from NAM01-BN3-obe.outbound.protection.outlook.com (mail-eopbgr740040.outbound.protection.outlook.com. [40.107.74.40])
        by mx.google.com with ESMTPS id p53si1252164qtk.343.2019.04.25.12.08.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 12:08:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of namit@vmware.com designates 40.107.74.40 as permitted sender) client-ip=40.107.74.40;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@vmware.com header.s=selector1 header.b=crdakZE8;
       spf=pass (google.com: domain of namit@vmware.com designates 40.107.74.40 as permitted sender) smtp.mailfrom=namit@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=vmware.com;
 s=selector1;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=cGN+2eGnFRjQKKRet0DhCtdHwhr+g4OStM4ZwhGCD9I=;
 b=crdakZE8t1c58kfX53aUFY+7aG1ypFDGu7WYjfYvFVrIAbcyYtu021d2Zh82nuC0Tor5SLUDimkQKTYvkAUe40a7XXtToxDblsEa2IcoN/i4eZSR1rUwBB/rCS459xM8FJ85Z0TbtG1+pBxalDLr9An6BgNJR7IYTVbtEyp79wU=
Received: from BYAPR05MB4776.namprd05.prod.outlook.com (52.135.233.146) by
 BYAPR05MB4662.namprd05.prod.outlook.com (52.135.233.76) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1835.9; Thu, 25 Apr 2019 19:08:17 +0000
Received: from BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::e862:1b1b:7665:8094]) by BYAPR05MB4776.namprd05.prod.outlook.com
 ([fe80::e862:1b1b:7665:8094%3]) with mapi id 15.20.1835.010; Thu, 25 Apr 2019
 19:08:17 +0000
From: Nadav Amit <namit@vmware.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
CC: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Arnd Bergmann
	<arnd@arndb.de>, Julien Freche <jfreche@vmware.com>, Pv-drivers
	<Pv-drivers@vmware.com>, Jason Wang <jasowang@redhat.com>, LKML
	<linux-kernel@vger.kernel.org>, "virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>, "linux-mm@kvack.org"
	<linux-mm@kvack.org>
Subject: Re: [PATCH v3 1/4] mm/balloon_compaction: list interfaces
Thread-Topic: [PATCH v3 1/4] mm/balloon_compaction: list interfaces
Thread-Index: AQHU+mwdinHS3UiOtEKcnmatxdvta6ZLVFgAgAHrSAA=
Date: Thu, 25 Apr 2019 19:08:17 +0000
Message-ID: <77127A20-8B02-4C1F-A746-6378A160D12B@vmware.com>
References: <20190423234531.29371-1-namit@vmware.com>
 <20190423234531.29371-2-namit@vmware.com>
 <20190424092829-mutt-send-email-mst@kernel.org>
In-Reply-To: <20190424092829-mutt-send-email-mst@kernel.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=namit@vmware.com; 
x-originating-ip: [66.170.99.2]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 77370d01-82c2-4c89-81c8-08d6c9b16023
x-microsoft-antispam:
 BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR05MB4662;
x-ms-traffictypediagnostic: BYAPR05MB4662:
x-ld-processed: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0,ExtAddr
x-microsoft-antispam-prvs:
 <BYAPR05MB46626B388BEF9A0A7B0C1976D03D0@BYAPR05MB4662.namprd05.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 0018A2705B
x-forefront-antispam-report:
 SFV:NSPM;SFS:(10009020)(346002)(366004)(396003)(376002)(39860400002)(136003)(189003)(199004)(4326008)(305945005)(68736007)(316002)(14444005)(26005)(446003)(102836004)(186003)(66066001)(14454004)(5660300002)(33656002)(6506007)(478600001)(25786009)(53546011)(97736004)(36756003)(99286004)(6246003)(76176011)(66946007)(76116006)(73956011)(64756008)(66446008)(11346002)(82746002)(81156014)(86362001)(3846002)(6512007)(71200400001)(83716004)(66556008)(66476007)(71190400001)(53936002)(6436002)(7736002)(256004)(81166006)(6916009)(229853002)(8936002)(6486002)(486006)(8676002)(6116002)(54906003)(2616005)(476003)(2906002);DIR:OUT;SFP:1101;SCL:1;SRVR:BYAPR05MB4662;H:BYAPR05MB4776.namprd05.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: vmware.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info:
 DzjKMmLSinPfv+4M/fs6qfqOT0w5c75ymM0cGb8xCZzI+WEW+tJy335Ie6a1p129rXHF3MP9Z7WIyVihCUH/VucE/OQotZRQfMFFpExUywwYIjomsEy/YLFt37rKCLJUzzSRy6ottqUUPfz8NAx20FO5NL93b8ntdfyXAsFf6A2bi6mb1gAThSYN/CSAl0gxZlKcHlI2vKV62bQmZHlqXIi3DhghdsGqGEOSZS6Dj+hXceihZHKZOXyKmbuNgn2l+7FnPRypLjbRUajPfy9kkNtdT0ByglHCRkIsfeXV1XnBpGGbQJowbwfQKhMPrsJ8hIhAL+WDYsGussKGD6UvmluTcuCScTpuD/7jIzwbxDlol+C3s0bKdihoyWpD72RfFenw8VfvYt/Drmsjsa0HkT7k7dvnxJ2j4rwMzSHfofM=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <6DCBC4D19BB59F4481A64E7CC85E0804@namprd05.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: vmware.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 77370d01-82c2-4c89-81c8-08d6c9b16023
X-MS-Exchange-CrossTenant-originalarrivaltime: 25 Apr 2019 19:08:17.6759
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: b39138ca-3cee-4b4a-a4d6-cd83d9dd62f0
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR05MB4662
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Apr 24, 2019, at 6:49 AM, Michael S. Tsirkin <mst@redhat.com> wrote:
>=20
> On Tue, Apr 23, 2019 at 04:45:28PM -0700, Nadav Amit wrote:
>> Introduce interfaces for ballooning enqueueing and dequeueing of a list
>> of pages. These interfaces reduce the overhead of storing and restoring
>> IRQs by batching the operations. In addition they do not panic if the
>> list of pages is empty.
>>=20
>> Cc: "Michael S. Tsirkin" <mst@redhat.com>
>> Cc: Jason Wang <jasowang@redhat.com>
>> Cc: linux-mm@kvack.org
>> Cc: virtualization@lists.linux-foundation.org
>> Reviewed-by: Xavier Deguillard <xdeguillard@vmware.com>
>> Signed-off-by: Nadav Amit <namit@vmware.com>
>=20
>=20
> Looks good overall. Two minor comments below.
>=20
>=20
>> ---
>> include/linux/balloon_compaction.h |   4 +
>> mm/balloon_compaction.c            | 144 +++++++++++++++++++++--------
>> 2 files changed, 110 insertions(+), 38 deletions(-)
>>=20
>> diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_=
compaction.h
>> index f111c780ef1d..430b6047cef7 100644
>> --- a/include/linux/balloon_compaction.h
>> +++ b/include/linux/balloon_compaction.h
>> @@ -64,6 +64,10 @@ extern struct page *balloon_page_alloc(void);
>> extern void balloon_page_enqueue(struct balloon_dev_info *b_dev_info,
>> 				 struct page *page);
>> extern struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_=
info);
>> +extern size_t balloon_page_list_enqueue(struct balloon_dev_info *b_dev_=
info,
>> +				      struct list_head *pages);
>> +extern size_t balloon_page_list_dequeue(struct balloon_dev_info *b_dev_=
info,
>> +				     struct list_head *pages, size_t n_req_pages);
>>=20
>> static inline void balloon_devinfo_init(struct balloon_dev_info *balloon=
)
>> {
>> diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
>> index ef858d547e2d..a2995002edc2 100644
>> --- a/mm/balloon_compaction.c
>> +++ b/mm/balloon_compaction.c
>> @@ -10,6 +10,105 @@
>> #include <linux/export.h>
>> #include <linux/balloon_compaction.h>
>>=20
>> +static void balloon_page_enqueue_one(struct balloon_dev_info *b_dev_inf=
o,
>> +				     struct page *page)
>> +{
>> +	/*
>> +	 * Block others from accessing the 'page' when we get around to
>> +	 * establishing additional references. We should be the only one
>> +	 * holding a reference to the 'page' at this point. If we are not, the=
n
>> +	 * memory corruption is possible and we should stop execution.
>> +	 */
>> +	BUG_ON(!trylock_page(page));
>> +	list_del(&page->lru);
>> +	balloon_page_insert(b_dev_info, page);
>> +	unlock_page(page);
>> +	__count_vm_event(BALLOON_INFLATE);
>> +}
>> +
>> +/**
>> + * balloon_page_list_enqueue() - inserts a list of pages into the ballo=
on page
>> + *				 list.
>> + * @b_dev_info: balloon device descriptor where we will insert a new pa=
ge to
>> + * @pages: pages to enqueue - allocated using balloon_page_alloc.
>> + *
>> + * Driver must call it to properly enqueue a balloon pages before defin=
itively
>> + * removing it from the guest system.
>> + *
>> + * Return: number of pages that were enqueued.
>> + */
>> +size_t balloon_page_list_enqueue(struct balloon_dev_info *b_dev_info,
>> +				 struct list_head *pages)
>> +{
>> +	struct page *page, *tmp;
>> +	unsigned long flags;
>> +	size_t n_pages =3D 0;
>> +
>> +	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
>> +	list_for_each_entry_safe(page, tmp, pages, lru) {
>> +		balloon_page_enqueue_one(b_dev_info, page);
>> +		n_pages++;
>> +	}
>> +	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
>> +	return n_pages;
>> +}
>> +EXPORT_SYMBOL_GPL(balloon_page_list_enqueue);
>> +
>> +/**
>> + * balloon_page_list_dequeue() - removes pages from balloon's page list=
 and
>> + *				 returns a list of the pages.
>> + * @b_dev_info: balloon device decriptor where we will grab a page from=
.
>> + * @pages: pointer to the list of pages that would be returned to the c=
aller.
>> + * @n_req_pages: number of requested pages.
>> + *
>> + * Driver must call this function to properly de-allocate a previous en=
listed
>> + * balloon pages before definetively releasing it back to the guest sys=
tem.
>> + * This function tries to remove @n_req_pages from the ballooned pages =
and
>> + * return them to the caller in the @pages list.
>> + *
>> + * Note that this function may fail to dequeue some pages temporarily e=
mpty due
>> + * to compaction isolated pages.
>> + *
>> + * Return: number of pages that were added to the @pages list.
>> + */
>> +size_t balloon_page_list_dequeue(struct balloon_dev_info *b_dev_info,
>> +				 struct list_head *pages, size_t n_req_pages)
>> +{
>> +	struct page *page, *tmp;
>> +	unsigned long flags;
>> +	size_t n_pages =3D 0;
>> +
>> +	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
>> +	list_for_each_entry_safe(page, tmp, &b_dev_info->pages, lru) {
>> +		if (n_pages =3D=3D n_req_pages)
>> +			break;
>> +
>> +		/*
>> +		 * Block others from accessing the 'page' while we get around
>=20
> should be "get around to" - same as in other places
>=20
>=20
>> +		 * establishing additional references and preparing the 'page'
>> +		 * to be released by the balloon driver.
>> +		 */
>> +		if (!trylock_page(page))
>> +			continue;
>> +
>> +		if (IS_ENABLED(CONFIG_BALLOON_COMPACTION) &&
>> +		    PageIsolated(page)) {
>> +			/* raced with isolation */
>> +			unlock_page(page);
>> +			continue;
>> +		}
>> +		balloon_page_delete(page);
>> +		__count_vm_event(BALLOON_DEFLATE);
>> +		unlock_page(page);
>> +		list_add(&page->lru, pages);
>=20
> I'm not sure whether this list_add must be under the page lock,
> but enqueue does list_del under page lock, so I think it's
> a good idea to keep dequeue consistent, operating in the
> reverse order of enqueue.
>=20
>> +		++n_pages;
>> +	}
>> +	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
>> +
>> +	return n_pages;
>> +}
>> +EXPORT_SYMBOL_GPL(balloon_page_list_dequeue);
>> +
>> /*
>>  * balloon_page_alloc - allocates a new page for insertion into the ball=
oon
>>  *			  page list.
>> @@ -43,17 +142,9 @@ void balloon_page_enqueue(struct balloon_dev_info *b=
_dev_info,
>> {
>> 	unsigned long flags;
>>=20
>> -	/*
>> -	 * Block others from accessing the 'page' when we get around to
>> -	 * establishing additional references. We should be the only one
>> -	 * holding a reference to the 'page' at this point.
>> -	 */
>> -	BUG_ON(!trylock_page(page));
>> 	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
>> -	balloon_page_insert(b_dev_info, page);
>> -	__count_vm_event(BALLOON_INFLATE);
>> +	balloon_page_enqueue_one(b_dev_info, page);
>> 	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
>> -	unlock_page(page);
>> }
>> EXPORT_SYMBOL_GPL(balloon_page_enqueue);
>>=20
>> @@ -70,36 +161,13 @@ EXPORT_SYMBOL_GPL(balloon_page_enqueue);
>>  */
>> struct page *balloon_page_dequeue(struct balloon_dev_info *b_dev_info)
>> {
>> -	struct page *page, *tmp;
>> 	unsigned long flags;
>> -	bool dequeued_page;
>> +	LIST_HEAD(pages);
>> +	int n_pages;
>>=20
>> -	dequeued_page =3D false;
>> -	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
>> -	list_for_each_entry_safe(page, tmp, &b_dev_info->pages, lru) {
>> -		/*
>> -		 * Block others from accessing the 'page' while we get around
>> -		 * establishing additional references and preparing the 'page'
>> -		 * to be released by the balloon driver.
>> -		 */
>> -		if (trylock_page(page)) {
>> -#ifdef CONFIG_BALLOON_COMPACTION
>> -			if (PageIsolated(page)) {
>> -				/* raced with isolation */
>> -				unlock_page(page);
>> -				continue;
>> -			}
>> -#endif
>> -			balloon_page_delete(page);
>> -			__count_vm_event(BALLOON_DEFLATE);
>> -			unlock_page(page);
>> -			dequeued_page =3D true;
>> -			break;
>> -		}
>> -	}
>> -	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
>> +	n_pages =3D balloon_page_list_dequeue(b_dev_info, &pages, 1);
>>=20
>> -	if (!dequeued_page) {
>> +	if (n_pages !=3D 1) {
>> 		/*
>> 		 * If we are unable to dequeue a balloon page because the page
>> 		 * list is empty and there is no isolated pages, then something
>> @@ -112,9 +180,9 @@ struct page *balloon_page_dequeue(struct balloon_dev=
_info *b_dev_info)
>> 			     !b_dev_info->isolated_pages))
>> 			BUG();
>> 		spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
>> -		page =3D NULL;
>> +		return NULL;
>> 	}
>> -	return page;
>> +	return list_first_entry(&pages, struct page, lru);
>> }
>> EXPORT_SYMBOL_GPL(balloon_page_dequeue);
>>=20
>> --=20
>> 2.19.1
>=20
>=20
> With above addressed:
>=20
> Acked-by: Michael S. Tsirkin <mst@redhat.com>

Thank you, Michael.

I addressed your feedback and I will send another version shortly.

