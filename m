Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14D07C32750
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 06:10:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C96E4206A3
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 06:10:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C96E4206A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5BF746B0008; Fri,  2 Aug 2019 02:10:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 56FB76B000A; Fri,  2 Aug 2019 02:10:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 45E8F6B000C; Fri,  2 Aug 2019 02:10:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id EBB2E6B0008
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 02:10:11 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l26so46310878eda.2
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 23:10:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language;
        bh=JV032OoO+DGS3E+8nVOOUSUZxQCqLxozSmSGzztEJiQ=;
        b=OqKMLBC7t4z43zIWKSrvqpMtIUQLLZGnr0SwTMyUG4417b19YH8fmn4w7Nwn+BFdfO
         te5DLrG5Ab5ogZwPRtIvosOXaxOqhd524qqz33Ku2jLvzb1sYP72i/QynzyY05E+769+
         iUFEcaSgNWFzFdjU/O/CxUVJobv/6Ew4nbq7PQSpp7aQNcvZz5IArZ0nxlzpCTFd9SOx
         67dOxSHO93++Ve3qG4b36JSYs3O++dwEqfpDJhLBINb0xlQqJy0kGYEwjw2a1p2xVi5N
         OYLG3uwtZO2A8VdDlutWEfCSsT2oqUosIDIw0BHWYgjeIaa1twW6MtTtRdkdGj1rI9FQ
         Z48w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Gm-Message-State: APjAAAV9TsG2Lg0ctl15QN/4nqUclPA7Rl9k0Ynu0Pqynm60wGmhTHvb
	yAyoniImgrNbDW1v4HGr2K4Dqaj+/mJdN8IR9XqEVP1vMr+cCJAjphBejv+C2ZRdJXSATg5mm43
	APSOZBr79aIe+XuzrqJOsVAA/9A3bqDBAiXC9EvhE5kBQuEoP43U8BrYKl+q+dRthLQ==
X-Received: by 2002:a17:906:8409:: with SMTP id n9mr10170151ejx.128.1564726211506;
        Thu, 01 Aug 2019 23:10:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzMSJDTjAU7RR1cXZqC0ySo9CbwYoHgT2MnHiQjS71uxSvd8qpHkY8LOPscJhZ4FtaTHlL2
X-Received: by 2002:a17:906:8409:: with SMTP id n9mr10170097ejx.128.1564726210528;
        Thu, 01 Aug 2019 23:10:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564726210; cv=none;
        d=google.com; s=arc-20160816;
        b=S8NrBBtOzKW/ExRWVZRX4PXXieeI6gAvC8qVmGE2ICw8+cuMsiH35lTgMGSdsqFNJM
         VkkXtnAa75SCpzf37FufdsXWTySXQLrKiLzZwCSKJJm9/gQzBRqSu/t33IuDgE6QbQLm
         ephck4z9cyZRtSIjdQewKKMfZ62Jz68F9VLO/pcAiNkjL3jrWmkNz5C0+xUumyIQseKh
         UY4yJ5BFqlZmi7lA09MzZX6xIVJghbFOtubhIViyat+yaIHDhxrvHFdLsJ1erXKfZPXm
         GavOaeRGfBHrOnSmxQ8fdPmLvu8LDS4evK/q40f0ZRs0NsRcrXoXPMTJmva1xMxstfl0
         5/Ww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:in-reply-to:mime-version:user-agent:date
         :message-id:from:references:cc:to:subject;
        bh=JV032OoO+DGS3E+8nVOOUSUZxQCqLxozSmSGzztEJiQ=;
        b=mihMg579XG8lzNRglQOArDNZcGOlOTmlxeiWe2E0pydR3/CELa2q++m1LGu85kSupY
         o7YMa2pLmbK7Z1VPkpdg/zczCY/XAeVU9ixd3noNf93vLy8xKpVTspn8Kwzn9EB2FKED
         FrdvIzw0rzsbUoSkTedsTS8+3Xl3iKdkTsu7kQFoMNdXjdxPg1TdDLVHlOvtCGzc0vWc
         yRkW/YoUxK2fGX1ARJGIQKFWBOCARUm2yprK17joy+JQn9ZQReKAhmwcJwGg4D8Icj1m
         RSqleODsA11ZY5+CAI/aC09TTnKNMAeX/dPInFSubfhl/FrlwTtnASqYBzmG/mvhn/Qc
         EuLw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l28si24922846edb.261.2019.08.01.23.10.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 23:10:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jgross@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=jgross@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 95267B634;
	Fri,  2 Aug 2019 06:10:09 +0000 (UTC)
Subject: Re: [PATCH 20/34] xen: convert put_page() to put_user_page*()
To: John Hubbard <jhubbard@nvidia.com>, john.hubbard@gmail.com,
 Andrew Morton <akpm@linux-foundation.org>
Cc: devel@driverdev.osuosl.org, Dave Chinner <david@fromorbit.com>,
 Christoph Hellwig <hch@infradead.org>,
 Dan Williams <dan.j.williams@intel.com>, Ira Weiny <ira.weiny@intel.com>,
 x86@kernel.org, linux-mm@kvack.org, Dave Hansen
 <dave.hansen@linux.intel.com>, amd-gfx@lists.freedesktop.org,
 dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org,
 linux-arm-kernel@lists.infradead.org, linux-rpi-kernel@lists.infradead.org,
 devel@lists.orangefs.org, xen-devel@lists.xenproject.org,
 Boris Ostrovsky <boris.ostrovsky@oracle.com>, rds-devel@oss.oracle.com,
 =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>,
 Jan Kara <jack@suse.cz>, ceph-devel@vger.kernel.org, kvm@vger.kernel.org,
 linux-block@vger.kernel.org, linux-crypto@vger.kernel.org,
 linux-fbdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 LKML <linux-kernel@vger.kernel.org>, linux-media@vger.kernel.org,
 linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
 linux-xfs@vger.kernel.org, netdev@vger.kernel.org,
 sparclinux@vger.kernel.org, Jason Gunthorpe <jgg@ziepe.ca>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
 <20190802022005.5117-21-jhubbard@nvidia.com>
 <4471e9dc-a315-42c1-0c3c-55ba4eeeb106@suse.com>
 <d5140833-e9ee-beb5-ff0a-2d13a4fe819f@nvidia.com>
From: Juergen Gross <jgross@suse.com>
Message-ID: <d4931311-db01-e8c3-0f8c-d64685dc2143@suse.com>
Date: Fri, 2 Aug 2019 08:10:07 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <d5140833-e9ee-beb5-ff0a-2d13a4fe819f@nvidia.com>
Content-Type: multipart/mixed;
 boundary="------------8BBD3C4A32BE2A4FA02D8356"
Content-Language: de-DE
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------8BBD3C4A32BE2A4FA02D8356
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit

On 02.08.19 07:48, John Hubbard wrote:
> On 8/1/19 9:36 PM, Juergen Gross wrote:
>> On 02.08.19 04:19, john.hubbard@gmail.com wrote:
>>> From: John Hubbard <jhubbard@nvidia.com>
> ...
>>> diff --git a/drivers/xen/privcmd.c b/drivers/xen/privcmd.c
>>> index 2f5ce7230a43..29e461dbee2d 100644
>>> --- a/drivers/xen/privcmd.c
>>> +++ b/drivers/xen/privcmd.c
>>> @@ -611,15 +611,10 @@ static int lock_pages(
>>>   static void unlock_pages(struct page *pages[], unsigned int nr_pages)
>>>   {
>>> -    unsigned int i;
>>> -
>>>       if (!pages)
>>>           return;
>>> -    for (i = 0; i < nr_pages; i++) {
>>> -        if (pages[i])
>>> -            put_page(pages[i]);
>>> -    }
>>> +    put_user_pages(pages, nr_pages);
>>
>> You are not handling the case where pages[i] is NULL here. Or am I
>> missing a pending patch to put_user_pages() here?
>>
> 
> Hi Juergen,
> 
> You are correct--this no longer handles the cases where pages[i]
> is NULL. It's intentional, though possibly wrong. :)
> 
> I see that I should have added my standard blurb to this
> commit description. I missed this one, but some of the other patches
> have it. It makes the following, possibly incorrect claim:
> 
> "This changes the release code slightly, because each page slot in the
> page_list[] array is no longer checked for NULL. However, that check
> was wrong anyway, because the get_user_pages() pattern of usage here
> never allowed for NULL entries within a range of pinned pages."
> 
> The way I've seen these page arrays used with get_user_pages(),
> things are either done single page, or with a contiguous range. So
> unless I'm missing a case where someone is either
> 
> a) releasing individual pages within a range (and thus likely messing
> up their count of pages they have), or
> 
> b) allocating two gup ranges within the same pages[] array, with a
> gap between the allocations,
> 
> ...then it should be correct. If so, then I'll add the above blurb
> to this patch's commit description.
> 
> If that's not the case (both here, and in 3 or 4 other patches in this
> series, then as you said, I should add NULL checks to put_user_pages()
> and put_user_pages_dirty_lock().

In this case it is not correct, but can easily be handled. The NULL case
can occur only in an error case with the pages array filled partially or
not at all.

I'd prefer something like the attached patch here.


Juergen

--------------8BBD3C4A32BE2A4FA02D8356
Content-Type: text/x-patch;
 name="gup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="gup.patch"

diff --git a/drivers/xen/privcmd.c b/drivers/xen/privcmd.c
index 2f5ce7230a43..12bd3154126d 100644
--- a/drivers/xen/privcmd.c
+++ b/drivers/xen/privcmd.c
@@ -582,10 +582,11 @@ static long privcmd_ioctl_mmap_batch(
 
 static int lock_pages(
 	struct privcmd_dm_op_buf kbufs[], unsigned int num,
-	struct page *pages[], unsigned int nr_pages)
+	struct page *pages[], unsigned int *nr_pages)
 {
-	unsigned int i;
+	unsigned int i, free = *nr_pages;
 
+	*nr_pages = 0;
 	for (i = 0; i < num; i++) {
 		unsigned int requested;
 		int pinned;
@@ -593,35 +594,22 @@ static int lock_pages(
 		requested = DIV_ROUND_UP(
 			offset_in_page(kbufs[i].uptr) + kbufs[i].size,
 			PAGE_SIZE);
-		if (requested > nr_pages)
+		if (requested > free)
 			return -ENOSPC;
 
 		pinned = get_user_pages_fast(
 			(unsigned long) kbufs[i].uptr,
-			requested, FOLL_WRITE, pages);
+			requested, FOLL_WRITE, pages + *nr_pages);
 		if (pinned < 0)
 			return pinned;
 
-		nr_pages -= pinned;
-		pages += pinned;
+		free -= pinned;
+		*nr_pages += pinned;
 	}
 
 	return 0;
 }
 
-static void unlock_pages(struct page *pages[], unsigned int nr_pages)
-{
-	unsigned int i;
-
-	if (!pages)
-		return;
-
-	for (i = 0; i < nr_pages; i++) {
-		if (pages[i])
-			put_page(pages[i]);
-	}
-}
-
 static long privcmd_ioctl_dm_op(struct file *file, void __user *udata)
 {
 	struct privcmd_data *data = file->private_data;
@@ -681,11 +669,12 @@ static long privcmd_ioctl_dm_op(struct file *file, void __user *udata)
 
 	xbufs = kcalloc(kdata.num, sizeof(*xbufs), GFP_KERNEL);
 	if (!xbufs) {
+		nr_pages = 0;
 		rc = -ENOMEM;
 		goto out;
 	}
 
-	rc = lock_pages(kbufs, kdata.num, pages, nr_pages);
+	rc = lock_pages(kbufs, kdata.num, pages, &nr_pages);
 	if (rc)
 		goto out;
 
@@ -699,7 +688,8 @@ static long privcmd_ioctl_dm_op(struct file *file, void __user *udata)
 	xen_preemptible_hcall_end();
 
 out:
-	unlock_pages(pages, nr_pages);
+	if (pages)
+		put_user_pages(pages, nr_pages);
 	kfree(xbufs);
 	kfree(pages);
 	kfree(kbufs);

--------------8BBD3C4A32BE2A4FA02D8356--

