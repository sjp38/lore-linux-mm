Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A20C6C76195
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 04:31:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59411217F4
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 04:31:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="lrbv6UWo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59411217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E2C2E8E0001; Wed, 17 Jul 2019 00:31:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DDB9C6B0008; Wed, 17 Jul 2019 00:31:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA2C98E0001; Wed, 17 Jul 2019 00:31:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id AD5936B0005
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 00:31:41 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id p20so18119950yba.17
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 21:31:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=ukaqXZgt5ZM3Hss7HF/VcYbbn1bk3tRqOhq/W93Amps=;
        b=D4MPJnrAlYZM5gQz+jspScXc+k6lJ3e+eCHLquhcjDr2qoBFQpkK7+fKwM4k5yEASE
         go8VJRld9YzvLkxzFiUYgziOZ7D/Ix+mprTPafz9VYVkW9yTsG/Z1NjUAUpFlEseeSzH
         tikkYyl/xRRjeFsYRI3N+qMZo7+yykIBUQcxzf34ekUspItW2t+7VFclIuhrtbFVeNt0
         bBSoYuWFmnvVJMkYv07X8aFvNyyKWW9A2fvCIhqmdqq+Mic2b+GPG9m4pu+2q8iSqK2f
         JkoMf/9bSbJzB0Mtlx6Q0+5x9KaGcdTyzRG8YwfBYis5F/9qRWXtT956Hvi2CVGQUhJE
         Mpfg==
X-Gm-Message-State: APjAAAXgJxUGOjYwKdAZlyeLLcCB1Uz2Xhi+BBcBu2SJb43kS9mcjJPm
	JowK/5IwdRumpx3hUWQg2iSo+fSmG1RMKj3LMpx8du8sibj9J/4niJeTclEHIAUTfHwKepZ/69Q
	S7siBtN6dj/PB9QiKeHnydqea4Lhi2/RZLxVkBVNbNNkMB7b69vkGYxz89f1NO+2+RQ==
X-Received: by 2002:a81:6f84:: with SMTP id k126mr23221521ywc.496.1563337901405;
        Tue, 16 Jul 2019 21:31:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxBM1PDGyzTrlMl0bAJ/nOT9r7dknHIbVb1jE09eUtAxRh/0zqh31uIf7KPuDinneh/Kw9S
X-Received: by 2002:a81:6f84:: with SMTP id k126mr23221491ywc.496.1563337900774;
        Tue, 16 Jul 2019 21:31:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563337900; cv=none;
        d=google.com; s=arc-20160816;
        b=QceW35u17veV6y39VzGtSlabL0wjkBqR9pcAWNnxVbBCWnc0Wqds5XICYkx0m9ILlO
         4aFJBM5tTmjT9vw2AL2i1idZgaBYy44t3AduvhTuZ6n0bq3QXFNgqTWpYzdUhGsnO7eI
         yHi4xpiqXu1bVJtD2ZTnSyiXh+7XK2Bh/yucyMnOqyHbem3XPbbFlw3m6XPpXWU8qqGc
         vnsDM3dtw+IFJfkQwFJDDcI08FjXeCTAhUuafQ0yvUm3unAExGwkTkjo2HeoFQ1Nu7p0
         iUvn8YWmA/O98dkqXcgb10fgadzWzAgFLeYea85HVIeOuXjFK7cgBqbUg3BBzLupRcWS
         sulg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=ukaqXZgt5ZM3Hss7HF/VcYbbn1bk3tRqOhq/W93Amps=;
        b=XW/6ghvSiu5uDsG8dec/pgX25Ylv5IptUTr8PyKjdjaWVGTxCz9YPIkL+ZZVwITEMk
         bYmMqlJrL6+TF4UQgmvyV6ha2dbjf6enbuJxWusGALM72YEguhklzll563ajoUTsFtxq
         MbxsnVyuIGmO6+pHvoNFVy6A87JdqWARXxv5PqP+OtZ8kq8qUrZzUH6IzPNDCpx1/VrS
         JYINmMvbkWebB0BAIzu4WfaeHzwMUEPxLH9ZYSzp7n5E6SktTuo87J/L2bDBNGRZZ99f
         3OQoayJnNtk8QGogGiSCimtRw6heBXhOQr5ll+jok61cuzlQrkNKZFY+mGBfznc/m0Wh
         VMQg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=lrbv6UWo;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id d18si9139732ybq.450.2019.07.16.21.31.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Jul 2019 21:31:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=lrbv6UWo;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d2ea4b20000>; Tue, 16 Jul 2019 21:31:46 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Tue, 16 Jul 2019 21:31:39 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Tue, 16 Jul 2019 21:31:39 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Wed, 17 Jul
 2019 04:31:34 +0000
Subject: Re: [PATCH 1/3] mm: document zone device struct page reserved fields
To: Christoph Hellwig <hch@lst.de>
CC: Ralph Campbell <rcampbell@nvidia.com>, <linux-mm@kvack.org>,
	<linux-kernel@vger.kernel.org>, <willy@infradead.org>, Vlastimil Babka
	<vbabka@suse.cz>, Christoph Lameter <cl@linux.com>, Dave Hansen
	<dave.hansen@linux.intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
	<jglisse@redhat.com>, "Kirill A . Shutemov"
	<kirill.shutemov@linux.intel.com>, Lai Jiangshan <jiangshanlai@gmail.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>, Pekka Enberg
	<penberg@kernel.org>, Randy Dunlap <rdunlap@infradead.org>, Andrey Ryabinin
	<aryabinin@virtuozzo.com>, Jason Gunthorpe <jgg@mellanox.com>, Andrew Morton
	<akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
References: <20190717001446.12351-1-rcampbell@nvidia.com>
 <20190717001446.12351-2-rcampbell@nvidia.com>
 <26a47482-c736-22c4-c21b-eb5f82186363@nvidia.com>
 <20190717042233.GA4529@lst.de>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <ae3936eb-2c08-c4a4-f670-10f25c7e0ed8@nvidia.com>
Date: Tue, 16 Jul 2019 21:31:33 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.2
MIME-Version: 1.0
In-Reply-To: <20190717042233.GA4529@lst.de>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563337906; bh=ukaqXZgt5ZM3Hss7HF/VcYbbn1bk3tRqOhq/W93Amps=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=lrbv6UWohE3Xi/PabIIUYKG9FSQNWiFKQjPqnE/pkOIdjgkkZfYheIRH6zaQFKR56
	 /2aqF2iRMK863gnT6l80rJKAuB8nW49sP7+xIYllUgTDFfV2+hpRXUy2SJCM0etIQI
	 OhdIbvsEmSEtRv4Kjgamt8OBRrDuhAZB6jX6foiEn5LOGmVcLiqhTG4M7O7FfrnoVB
	 mdJE07HL20AKBlJWlWgNt+50sh4W3aOnuDu3oqVqAdcAxXwo/q92/muhCocih1rlHM
	 YVpm3mczCFAWJcVLQvE3i3xEjXLx31utC87WbdTJGwYzMYNRmg9o2PL2HDnrXGSpsk
	 loItmkeeipJaQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/16/19 9:22 PM, Christoph Hellwig wrote:
> On Tue, Jul 16, 2019 at 06:20:23PM -0700, John Hubbard wrote:
>>> -			unsigned long _zd_pad_1;	/* uses mapping */
>>> +			/*
>>> +			 * The following fields are used to hold the source
>>> +			 * page anonymous mapping information while it is
>>> +			 * migrated to device memory. See migrate_page().
>>> +			 */
>>> +			unsigned long _zd_pad_1;	/* aliases mapping */
>>> +			unsigned long _zd_pad_2;	/* aliases index */
>>> +			unsigned long _zd_pad_3;	/* aliases private */
>>
>> Actually, I do think this helps. It's hard to document these fields, and
>> the ZONE_DEVICE pages have a really complicated situation during migration
>> to a device. 
>>
>> Additionally, I'm not sure, but should we go even further, and do this on the 
>> other side of the alias:
> 
> The _zd_pad_* field obviously are NOT used anywhere in the source tree.
> So these comments are very misleading.  If we still keep
> using ->mapping, ->index and ->private we really should clean up the
> definition of struct page to make that obvious instead of trying to
> doctor around it using comments.
> 

OK, so just delete all the _zd_pad_* fields? Works for me. It's misleading to
calling something padding, if it's actually unavailable because it's used
in the other union, so deleting would be even better than commenting.

In that case, it would still be nice to have this new snippet, right?:

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index d6ea74e20306..c5ce5989d8a8 100644

--- a/include/linux/mm_types.h

+++ b/include/linux/mm_types.h

@@ -83,7 +83,12 @@

 struct page {

                         * by the page owner. 
                         */ 
                        struct list_head lru; 
-                       /* See page-flags.h for PAGE_MAPPING_FLAGS */ 
+                       /* 
+                        * See page-flags.h for PAGE_MAPPING_FLAGS. 
+                        * 
+                        * Also: the next three fields (mapping, index and 
+                        * private) are all used by ZONE_DEVICE pages. 
+                        */ 
                        struct address_space *mapping; 
                        pgoff_t index;          /* Our offset within mapping. */ 
                        /** 

thanks,
-- 
John Hubbard
NVIDIA

