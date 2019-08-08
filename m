Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.4 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1368C0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 22:59:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6047C2173C
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 22:59:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="qK96gYx0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6047C2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF0066B0003; Thu,  8 Aug 2019 18:59:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA09C6B0006; Thu,  8 Aug 2019 18:59:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C1B8E6B0007; Thu,  8 Aug 2019 18:59:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 88D5A6B0003
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 18:59:18 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id y7so9446657pgq.3
        for <linux-mm@kvack.org>; Thu, 08 Aug 2019 15:59:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:references:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=M49TAEp0rF+Rj/ENVh2GXbZ42kgeSpTrxkT20El97xE=;
        b=clu4kI/rrxu4AK8aLKmmsEU9Y62wtlDtBwMk4c263oYJnyYEjslf54LqIHTOEDsXsx
         5BuJH6EN9y4vRbUOSctdH+bzax2DLPVdVQ48Lmnk3BjYfZErh5cgeiXmPe3AcXwODmjW
         tZ2195Fxm4zHzvIMzIdeO0linBJyah2iagCXnRfbR7uEw7eMYc+IumVxZiqd4W+R2zrp
         1ckgEVz6PA/S7L/WSwwaum0hSjmBKyBm+mluORzmRcfSAEyVtN351tjmlg9RzPE0RCqh
         oNnQ3rxpASHAADGwYoNz7R6SWod9v0wCrbLyqGYIPf1u7Dqa0+WO8MFMFZ4VqCBEmQt6
         d0Ow==
X-Gm-Message-State: APjAAAVewb/d+WtVlqEqUpYrOeDY/HileIJ7hvCpJJDdGe5Kq2IX/SRj
	jY33wvRYAONEqmhIzGv8kxfS8eWxN4QgSedHIqdyU4ZK40ZK0XdcVS0CEbBPsbxEWuQRHbC2yO4
	T5YWA57WscYRc9x1vm4Tr2Ns/E3gdYGUwzRLcF9hESW7fA8E+jkkKxaVzaaU+6c9ZeA==
X-Received: by 2002:a63:a35e:: with SMTP id v30mr14264332pgn.129.1565305158120;
        Thu, 08 Aug 2019 15:59:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJ7Q84C6somPVqE4/aQM3s5DO3gdZwpDS1OOkut4dtWz4GAXxx0AZAjNKwccZj6HruWaYW
X-Received: by 2002:a63:a35e:: with SMTP id v30mr14264283pgn.129.1565305156978;
        Thu, 08 Aug 2019 15:59:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565305156; cv=none;
        d=google.com; s=arc-20160816;
        b=fMsjoq9aGls7SyYVdukE3vg0I90xKIqBfPEtK7DMVqwVeFTjsFLxwL1/1L9UEdJF4h
         xJ1qhwny4Vp1bFr8YuslM0lhXUIHweyGn5AHjTVi1ks1kwUvoywh51LVBwIL8c0ct4OY
         SsghCUbf/p8Y8PZVkBszUrSyIJV1B68aQawWsNpGc6aYJsivjWUccHECT1FUEA4KeMAB
         A27iJbVLbaP2OB08OEASo1UCcwQKC7JPQEJuOrvAN7Xm9iYVzGoj+Id9kBWK7vKU25NU
         g0FQesvAmI5xP6i5wuJzy07fsV6kd0UfQMxlI4xTN8J1x1s2pNAV3dZT8IOVJlICxFa+
         uKsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:references:cc
         :to:from:subject;
        bh=M49TAEp0rF+Rj/ENVh2GXbZ42kgeSpTrxkT20El97xE=;
        b=ppCDalZrxaR9i1ThxtU+SkHeUUj/tjUfbPbqoJCjnWdlvx5Rnd5yb3xKrfdF6PDju+
         i9pFnlS9UKmxN5HUn4bbSg/91zeyohePLdgsv7H8nXbIXA7CW19rS3i5u16R6WEOLVfD
         wF0c4vPt99Tt7YSJ8L7Yp1GN3h1PLENSooglTgR1NW2ykwOoqd63F+c9sPTTIuuvBhny
         ihU+K4A0IaXrALHYk5z/nHQZymT6kPL8MSHg+GNr9+eaDmSQYPFGeM3NtGUVgwSzF+2u
         8tc4HgB2WqlRHo/8qYVUwjVREWVnBoQbMPqHjbzWbtpnc4KqPlFvqy55/PYM7GNRikzw
         fI8g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=qK96gYx0;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id f9si56186772pgc.510.2019.08.08.15.59.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Aug 2019 15:59:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=qK96gYx0;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d4ca94e0002>; Thu, 08 Aug 2019 15:59:26 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Thu, 08 Aug 2019 15:59:16 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Thu, 08 Aug 2019 15:59:16 -0700
Received: from [10.110.48.28] (172.20.13.39) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Thu, 8 Aug
 2019 22:59:15 +0000
Subject: Re: [PATCH 1/3] mm/mlock.c: convert put_page() to put_user_page*()
From: John Hubbard <jhubbard@nvidia.com>
To: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>
CC: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig
	<hch@infradead.org>, Ira Weiny <ira.weiny@intel.com>, Jan Kara
	<jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse
	<jglisse@redhat.com>, LKML <linux-kernel@vger.kernel.org>,
	<linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>, Dan Williams
	<dan.j.williams@intel.com>, Daniel Black <daniel@linux.ibm.com>, Matthew
 Wilcox <willy@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>
References: <20190805222019.28592-1-jhubbard@nvidia.com>
 <20190805222019.28592-2-jhubbard@nvidia.com>
 <20190807110147.GT11812@dhcp22.suse.cz>
 <01b5ed91-a8f7-6b36-a068-31870c05aad6@nvidia.com>
 <20190808062155.GF11812@dhcp22.suse.cz>
 <875dca95-b037-d0c7-38bc-4b4c4deea2c7@suse.cz>
 <306128f9-8cc6-761b-9b05-578edf6cce56@nvidia.com>
X-Nvconfidentiality: public
Message-ID: <d1ecb0d4-ea6a-637d-7029-687b950b783f@nvidia.com>
Date: Thu, 8 Aug 2019 15:59:15 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <306128f9-8cc6-761b-9b05-578edf6cce56@nvidia.com>
X-Originating-IP: [172.20.13.39]
X-ClientProxiedBy: HQMAIL107.nvidia.com (172.20.187.13) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1565305166; bh=M49TAEp0rF+Rj/ENVh2GXbZ42kgeSpTrxkT20El97xE=;
	h=X-PGP-Universal:Subject:From:To:CC:References:X-Nvconfidentiality:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=qK96gYx06tpkH2q4CcpF6OFBCFRxcA8XFBMTGsGorSI049/l40m06bHRMJx1tJDS8
	 DAxdC1uODwBgaSWpMv4if5Iqt5i6qp+oDs/yhJULQwcTTRKfkWpB4SnYndw1nTt5km
	 1xsWvHi7FBF0yo5mOFnYaowlOnPQGpSB0fYDx8KBQ1ve/x25U7+7434V1pzCwlvZIk
	 g3hlON18SJuJ2D/c0ndQmqy+GqYV484LBuFviFDcSWUg4RE4xEoQGHJIHzlfkY/R0f
	 OLytPdbTTAL5LajiZx2D0leH8axGGC7GmnAFDCpEVhyRNyBbECyjZ/GMFaZn0/VRiJ
	 mrtUWi75zSo4g==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 8/8/19 12:20 PM, John Hubbard wrote:
> On 8/8/19 4:09 AM, Vlastimil Babka wrote:
>> On 8/8/19 8:21 AM, Michal Hocko wrote:
>>> On Wed 07-08-19 16:32:08, John Hubbard wrote:
>>>> On 8/7/19 4:01 AM, Michal Hocko wrote:
>>>>> On Mon 05-08-19 15:20:17, john.hubbard@gmail.com wrote:
>>>>>> From: John Hubbard <jhubbard@nvidia.com>
>>>> Actually, I think follow_page_mask() gets all the pages, right? And the
>>>> get_page() in __munlock_pagevec_fill() is there to allow a pagevec_release() 
>>>> later.
>>>
>>> Maybe I am misreading the code (looking at Linus tree) but munlock_vma_pages_range
>>> calls follow_page for the start address and then if not THP tries to
>>> fill up the pagevec with few more pages (up to end), do the shortcut
>>> via manual pte walk as an optimization and use generic get_page there.
>>
> 
> Yes, I see it finally, thanks. :)  
> 
>> That's true. However, I'm not sure munlocking is where the
>> put_user_page() machinery is intended to be used anyway? These are
>> short-term pins for struct page manipulation, not e.g. dirtying of page
>> contents. Reading commit fc1d8e7cca2d I don't think this case falls
>> within the reasoning there. Perhaps not all GUP users should be
>> converted to the planned separate GUP tracking, and instead we should
>> have a GUP/follow_page_mask() variant that keeps using get_page/put_page?
>>  
> 
> Interesting. So far, the approach has been to get all the gup callers to
> release via put_user_page(), but if we add in Jan's and Ira's vaddr_pin_pages()
> wrapper, then maybe we could leave some sites unconverted.
> 
> However, in order to do so, we would have to change things so that we have
> one set of APIs (gup) that do *not* increment a pin count, and another set
> (vaddr_pin_pages) that do. 
> 
> Is that where we want to go...?
> 

Oh, and meanwhile, I'm leaning toward a cheap fix: just use gup_fast() instead
of get_page(), and also fix the releasing code. So this incremental patch, on
top of the existing one, should do it:

diff --git a/mm/mlock.c b/mm/mlock.c
index b980e6270e8a..2ea272c6fee3 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -318,18 +318,14 @@ static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
                /*
                 * We won't be munlocking this page in the next phase
                 * but we still need to release the follow_page_mask()
-                * pin. We cannot do it under lru_lock however. If it's
-                * the last pin, __page_cache_release() would deadlock.
+                * pin.
                 */
-               pagevec_add(&pvec_putback, pvec->pages[i]);
+               put_user_page(pages[i]);
                pvec->pages[i] = NULL;
        }
        __mod_zone_page_state(zone, NR_MLOCK, delta_munlocked);
        spin_unlock_irq(&zone->zone_pgdat->lru_lock);
 
-       /* Now we can release pins of pages that we are not munlocking */
-       pagevec_release(&pvec_putback);
-
        /* Phase 2: page munlock */
        for (i = 0; i < nr; i++) {
                struct page *page = pvec->pages[i];
@@ -394,6 +390,8 @@ static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
        start += PAGE_SIZE;
        while (start < end) {
                struct page *page = NULL;
+               int ret;
+
                pte++;
                if (pte_present(*pte))
                        page = vm_normal_page(vma, start, *pte);
@@ -411,7 +409,13 @@ static unsigned long __munlock_pagevec_fill(struct pagevec *pvec,
                if (PageTransCompound(page))
                        break;
 
-               get_page(page);
+               /*
+                * Use get_user_pages_fast(), instead of get_page() so that the
+                * releasing code can unconditionally call put_user_page().
+                */
+               ret = get_user_pages_fast(start, 1, 0, &page);
+               if (ret != 1)
+                       break;
                /*
                 * Increase the address that will be returned *before* the
                 * eventual break due to pvec becoming full by adding the page


thanks,
-- 
John Hubbard
NVIDIA

