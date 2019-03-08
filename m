Return-Path: <SRS0=92PK=RL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43AE5C43381
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 09:13:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 00C0A20811
	for <linux-mm@archiver.kernel.org>; Fri,  8 Mar 2019 09:13:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 00C0A20811
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 742DD8E0004; Fri,  8 Mar 2019 04:13:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F12D8E0002; Fri,  8 Mar 2019 04:13:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E3A58E0004; Fri,  8 Mar 2019 04:13:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 319828E0002
	for <linux-mm@kvack.org>; Fri,  8 Mar 2019 04:13:38 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id o56so18047435qto.9
        for <linux-mm@kvack.org>; Fri, 08 Mar 2019 01:13:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=yFjUKzcA7+sJCO3vCiE5yZFLGPxO+iSC0e4dQ3XsPoE=;
        b=RCBvkcyLw7vn6ZF2fAwTVCFxoXOwh3J6VEuQaFGRcapnnYs+AlMVJehQX07FvPfsjE
         2SCQoIrsqJ2ae5MAWu6QUtHPKNR+egTWf2ipG1irqayPK5hareobvSl6rXH0xHFlSiN6
         +bsaBZr4lYYUXP394sbvk5iRaCLORhKEvYRTAxQ3S7lPqgoYInaOy7Xcik9BKJxERJW3
         +f4eV0sgXrEBrwHz6aeknt68mCYN/f4hv9nwlh+HfP+EmfWq02Alm5APIjzy7BwLXZaS
         LDfG/JhO5nFPGnZJbumDP1dLQ5x4L+WTumeeISbyAXs+2wQg9pEK6K/Iff1eRaGyaDKn
         BgaQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXD9TSSnQniNOFJmXI8HbdxiY6hlVNQye9cAVd/pjinWKMEDZFv
	31/Cwa+7te0VHdgY8UywnTPvRzx16rhg+P+jyCwrB9kBoqx8K768AiQ0FPtjxzWMk0Q8xOkScOn
	Y6X6vL+by34VUCqcuYMC4Nt68g4HgK14b1c05IziNEUxXLlbiC8+5JBcOqgYdLv2RLA==
X-Received: by 2002:a37:7ac6:: with SMTP id v189mr600417qkc.205.1552036417971;
        Fri, 08 Mar 2019 01:13:37 -0800 (PST)
X-Google-Smtp-Source: APXvYqxDO92UJDd44ehQI+iec71rDAaU3KjaaAMR9OJWCx6lRgGmMFrPxl2RQVgRJIWIZPbhUpfI
X-Received: by 2002:a37:7ac6:: with SMTP id v189mr600386qkc.205.1552036417199;
        Fri, 08 Mar 2019 01:13:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1552036417; cv=none;
        d=google.com; s=arc-20160816;
        b=ZCagFZiutDqqhouvsMjPWmE9iV/VYdtmweYj3R3jNKvekTq3KCBDlxhP9EEeDIKtNP
         JYRwchDvNKpKdzcXfVqJeK4KkKlmwZoKRefVK5EBB67ETDGH9z8FZztl87ZaG4Uutt75
         zgaYYlcXPA1EBjXue7lmWDdZ9n3FLIbzVoWas7OoiSKbvDGhpNSV7d1VL3nWKhrHSpkj
         8ib1uydlXEXuhqy6bvRTUlAnLQr6tb22tvHRwnbMalG5spCC8g58PFxSjgtMJj3Liwrd
         sGYTjC6VZ/PsHXNzwd4zwq/C2nRxo849S5tKAQItgN5vwM9t1qsUxdH5Gf/gIYEH9OzJ
         COwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=yFjUKzcA7+sJCO3vCiE5yZFLGPxO+iSC0e4dQ3XsPoE=;
        b=MRdVUBuPcZDyZV45kcDq9ku46M/r80NCfVdyayMxukFQBfZ/ZrJJyH27uzSykTMCc6
         L3rQDS65nDMuNxwCPgyEilAZgHTPy0X/P+9fKvtcCtxv3Kmfq8JXGPkcHdIBCv8sAEbg
         F+EyhwJvyQvNIRgfZ5vHpvAMxQQwS6GeyHjYGDKutAXqBLQO1l0b05ydr39HpaooFRyY
         pHWajUh4N5DZkYr7um1/ouqCDQbI/zEWj/Bu/zGY2B1f4NKoo1Hmez3/p0gbYQ7JPiul
         P0FzD06e9ZXVdXvMVps8xx2l8uubLueHJStSqXjwA4GaQnEEOdQLDesquIpKeuwPOVEL
         G8Wg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l11si1740125qkg.209.2019.03.08.01.13.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Mar 2019 01:13:37 -0800 (PST)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 37C38307E042;
	Fri,  8 Mar 2019 09:13:36 +0000 (UTC)
Received: from [10.72.12.27] (ovpn-12-27.pek2.redhat.com [10.72.12.27])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 48D2F5D9D4;
	Fri,  8 Mar 2019 09:13:27 +0000 (UTC)
Subject: Re: [RFC PATCH V2 5/5] vhost: access vq metadata through kernel
 virtual address
To: Andrea Arcangeli <aarcange@redhat.com>, Jerome Glisse <jglisse@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org,
 Jan Kara <jack@suse.cz>
References: <1551856692-3384-1-git-send-email-jasowang@redhat.com>
 <1551856692-3384-6-git-send-email-jasowang@redhat.com>
 <20190306092837-mutt-send-email-mst@kernel.org>
 <15105894-4ec1-1ed0-1976-7b68ed9eeeda@redhat.com>
 <20190307101708-mutt-send-email-mst@kernel.org>
 <20190307190910.GE3835@redhat.com> <20190307193838.GQ23850@redhat.com>
 <20190307201722.GG3835@redhat.com> <20190307212717.GS23850@redhat.com>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <671c4a98-4699-836e-79fc-0ce650c7f701@redhat.com>
Date: Fri, 8 Mar 2019 17:13:26 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190307212717.GS23850@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Fri, 08 Mar 2019 09:13:36 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/3/8 上午5:27, Andrea Arcangeli wrote:
> Hello Jerome,
>
> On Thu, Mar 07, 2019 at 03:17:22PM -0500, Jerome Glisse wrote:
>> So for the above the easiest thing is to call set_page_dirty() from
>> the mmu notifier callback. It is always safe to use the non locking
>> variant from such callback. Well it is safe only if the page was
>> map with write permission prior to the callback so here i assume
>> nothing stupid is going on and that you only vmap page with write
>> if they have a CPU pte with write and if not then you force a write
>> page fault.
> So if the GUP doesn't set FOLL_WRITE, set_page_dirty simply shouldn't
> be called in such case. It only ever makes sense if the pte is
> writable.
>
> On a side note, the reason the write bit on the pte enabled avoids the
> need of the _lock suffix is because of the stable page writeback
> guarantees?
>
>> Basicly from mmu notifier callback you have the same right as zap
>> pte has.
> Good point.
>
> Related to this I already was wondering why the set_page_dirty is not
> done in the invalidate. Reading the patch it looks like the dirty is
> marked dirty when the ring wraps around, not in the invalidate, Jeson
> can tell if I misread something there.


Actually not wrapping around,  the pages for used ring was marked as 
dirty after a round of virtqueue processing when we're sure vhost wrote 
something there.

Thanks


>
> For transient data passing through the ring, nobody should care if
> it's lost. It's not user-journaled anyway so it could hit the disk in
> any order. The only reason to flush it to do disk is if there's memory
> pressure (to pageout like a swapout) and in such case it's enough to
> mark it dirty only in the mmu notifier invalidate like you pointed out
> (and only if GUP was called with FOLL_WRITE).
>
>> O_DIRECT can suffer from the same issue but the race window for that
>> is small enough that it is unlikely it ever happened. But for device
> Ok that clarifies things.
>
>> driver that GUP page for hours/days/weeks/months ... obviously the
>> race window is big enough here. It affects many fs (ext4, xfs, ...)
>> in different ways. I think ext4 is the most obvious because of the
>> kernel log trace it leaves behind.
>>
>> Bottom line is for set_page_dirty to be safe you need the following:
>>      lock_page()
>>      page_mkwrite()
>>      set_pte_with_write()
>>      unlock_page()
> I also wondered why ext4 writepage doesn't recreate the bh if they got
> dropped by the VM and page->private is 0. I mean, page->index and
> page->mapping are still there, that's enough info for writepage itself
> to take a slow path and calls page_mkwrite to find where to write the
> page on disk.
>
>> Now when loosing the write permission on the pte you will first get
>> a mmu notifier callback so anyone that abide by mmu notifier is fine
>> as long as they only write to the page if they found a pte with
>> write as it means the above sequence did happen and page is write-
>> able until the mmu notifier callback happens.
>>
>> When you lookup a page into the page cache you still need to call
>> page_mkwrite() before installing a write-able pte.
>>
>> Here for this vmap thing all you need is that the original user
>> pte had the write flag. If you only allow write in the vmap when
>> the original pte had write and you abide by mmu notifier then it
>> is ok to call set_page_dirty from the mmu notifier (but not after).
>>
>> Hence why my suggestion is a special vunmap that call set_page_dirty
>> on the page from the mmu notifier.
> Agreed, that will solve all issues in vhost context with regard to
> set_page_dirty, including the case the memory is backed by VM_SHARED ext4.
>
> Thanks!
> Andrea

