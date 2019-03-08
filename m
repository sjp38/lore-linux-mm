Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D1EDC10F09
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 21:27:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 891D820652
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 21:27:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="aa43xZK6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 891D820652
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F05478E0003; Fri,  8 Mar 2019 16:27:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EB59B8E0002; Fri,  8 Mar 2019 16:27:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA3748E0003; Fri,  8 Mar 2019 16:27:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9887F8E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 16:27:09 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id e4so23537330pfh.14
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 13:27:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=3tvUY7zeJ4w84IzUd3MSVKGooVlpXF75LlcBQTZLcB4=;
        b=i3eUQgmNoVanRpjWA4ka03/MPssCFpyLb4NL07a6xUzu3oLTs7jQvnyU3Y/e91ItI2
         WALGQkYCgb1sc2Ocfvv27zT6vk+quHMyeO/sl8xNzkbqsD+Xj362Ewp+A7RrAmMV/l4d
         PCb7+QZtAT96yGPx87Eo5Q7qQvY64dot+z0ngJz1Xk0Y9/LHpzmuYHIXDPQWhxjY0ojh
         +18Z/CetAQATsZ70wlryowc0/u/Matpm+5Dp1zVQG+oGvyQH+JIArcFdGNJE6CbrfXMO
         LZgJU7GAmcJAlEJfHZV7KSYm+RaLQAOtY+BIA1LM1acSmI3+up17TSf+N6HI5pBYOM6o
         NH/A==
X-Gm-Message-State: APjAAAVv7XaV7WxUsyYf955CP15pkkk3b/OPUBope32xZXFOKG1T/Am8
	TgjAuJ0MmRpQNgDq3a2DrroIXYFTLyzm03xutZGd6BBCp71iZNDTHDhY4pFhb8+xw3piVp4f05b
	GPUjVl1A8xeexm3I1nKEOjF/zw1W1sSjt9kk0ZVLK9pNhYUsvfTREOQ/zmCDT6JTVLw==
X-Received: by 2002:a17:902:ba84:: with SMTP id k4mr21254904pls.103.1552080428973;
        Fri, 08 Mar 2019 13:27:08 -0800 (PST)
X-Google-Smtp-Source: APXvYqydo/MUwKYg+dCLZbFvUO1mRxnlvRB6+66d7LWDgufESwYFL8mEmM3k+Rw+KqtlgXvlIQjJ
X-Received: by 2002:a17:902:ba84:: with SMTP id k4mr21254818pls.103.1552080427939;
        Fri, 08 Mar 2019 13:27:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552080427; cv=none;
        d=google.com; s=arc-20160816;
        b=CX+I41a1NblFqj83kZTlA4f+wfvsDr/yHhDI/TL5SmMOe2s2EtwI5w/VEfJhCMCllP
         e6jb+zsy2hZZBa4MJZ2USuy5uNrq9aaZBhzu0yyMPPzO8pKNdCY9itNKKLThronFM8hd
         TGsIdYeRiShAdhS2z1QQ0FBzflJSn4XWuL6x9w2GjWtZ7cTHvfnseLD4tORJMO7/MN/y
         UguaUXChgpM41xVyXdfcWEzr7Vw9OPIBmvv4tV2qOQRG2Hbz5kIOIHaxOxIdA3zUJRIL
         BuHE7DUTVUAmpA8YTdRGpU6JGHSlM+pk/a0nJsri2+KeR1Q8+6xDRyVborEIO1n1U/iz
         uSEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=3tvUY7zeJ4w84IzUd3MSVKGooVlpXF75LlcBQTZLcB4=;
        b=a6sJ7+rJYlbolc6ADBi8/nOXbbSHpPulc8GLLvmWIpK7H4DQfeJcWHKrfWpAORNlzN
         DVtWIgbNI9JwgAOkjSs2JR1S//eCmgRbdpLJhW1WYXwpVcsIApPbxoBt05vH2tnsigGy
         K96LTUO60AkGKCs9yM9hAq7jQeNuZxIjOaz2l6rO5pxk9jexbL9rkjinz7bkOC2QHH1o
         75DRUMGt4KttMphOLaxLXWFpR9wFWbdRTvijPuomODJ6vBc5ZNgKd+Kr0fAxnRJv9sC6
         +mXBYW+5DlAwwAaz7HdKQ1mY02F2xFHF9vDqBqOrqmqD5GhDgHAaFhfGBvIYzsyHbWRg
         2RkQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=aa43xZK6;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate14.nvidia.com (hqemgate14.nvidia.com. [216.228.121.143])
        by mx.google.com with ESMTPS id p10si7649018pls.296.2019.03.08.13.27.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 13:27:07 -0800 (PST)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) client-ip=216.228.121.143;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=aa43xZK6;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.143 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate14.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c82de2c0000>; Fri, 08 Mar 2019 13:27:08 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 08 Mar 2019 13:27:07 -0800
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 08 Mar 2019 13:27:07 -0800
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Fri, 8 Mar
 2019 21:27:06 +0000
Subject: Re: [PATCH v3 1/1] mm: introduce put_user_page*(), placeholder
 versions
To: Jerome Glisse <jglisse@redhat.com>, <john.hubbard@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>, <linux-mm@kvack.org>, Al Viro
	<viro@zeniv.linux.org.uk>, Christian Benvenuti <benve@cisco.com>, Christoph
 Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, Dan Williams
	<dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dennis
 Dalessandro <dennis.dalessandro@intel.com>, Doug Ledford
	<dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>, Jan Kara
	<jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, Matthew Wilcox
	<willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, Mike Rapoport
	<rppt@linux.ibm.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Ralph
 Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>, LKML
	<linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>
References: <20190306235455.26348-1-jhubbard@nvidia.com>
 <20190306235455.26348-2-jhubbard@nvidia.com>
 <20190308175712.GD3661@redhat.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <2e7ca6e2-70aa-8285-5010-808bb9568e5f@nvidia.com>
Date: Fri, 8 Mar 2019 13:27:06 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.3
MIME-Version: 1.0
In-Reply-To: <20190308175712.GD3661@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL101.nvidia.com (172.20.187.10) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1552080428; bh=3tvUY7zeJ4w84IzUd3MSVKGooVlpXF75LlcBQTZLcB4=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=aa43xZK68IFXNgycq4yBvet4MIraEeY3y1GqNe4M8SYFF5Mi5c7A8gDJfWYiSkmKD
	 jGzeYYcLDYMMF7DIksAJXqoPxPuKM/6b856idCc5eNF/afPlyLPQR+zUfX9eHReeeR
	 qF5QXOed6drRl+XcJkFa3TbOa5Feh+Cwo0PEuRXrRzXROoCJM/7kg4w2zwlBZGNhTj
	 N0sa7vY3UJcqR3iwZ6QcAtE5LhceFDkYsAPTRWr3W5K0Ne5Kv8DpdJR6/XToXH9WC8
	 x0xSAPq6bpTx7v6CE5RNEK0vyS/eEUbpoKNyhGFKFz4nPV1VVPp7d6LDVkFB6KM94U
	 KzXgvGYMzvLNw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 3/8/19 9:57 AM, Jerome Glisse wrote:
[snip]=20
> Just a small comments below that would help my life :)
>=20
> Reviewed-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20

Thanks for the review!=20

>> ---
>>  include/linux/mm.h | 24 ++++++++++++++
>>  mm/swap.c          | 82 ++++++++++++++++++++++++++++++++++++++++++++++
>=20
> Why not putting those functions in gup.c instead of swap.c ?

Yes, gup.c is better for these. And it passes the various cross compiler an=
d
tinyconfig builds locally, so I think I'm not missing any cases. (The swap.=
c=20
location was an artifact of very early approaches, pre-dating the
put_user_pages() name.)=20

[snip]

>>  #define SECTION_IN_PAGE_FLAGS
>>  #endif
>> diff --git a/mm/swap.c b/mm/swap.c
>> index 4d7d37eb3c40..a6b4f693f46d 100644
>> --- a/mm/swap.c
>> +++ b/mm/swap.c
>> @@ -133,6 +133,88 @@ void put_pages_list(struct list_head *pages)
>>  }
>>  EXPORT_SYMBOL(put_pages_list);
>> =20
>> +typedef int (*set_dirty_func)(struct page *page);
>=20
> set_dirty_func_t would be better as it is the rule for typedef to append
> the _t also it make it easier for coccinelle patch.
>=20

Done. I'm posting a v4 in a moment, with both of the above, plus
Christopher's "real filesystems" wording change, and your reviewed-by
tag.


thanks,
--=20
John Hubbard
NVIDIA

