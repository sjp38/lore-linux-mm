Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 19E69C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 07:52:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDB30214D8
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 07:52:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDB30214D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7B2228E0003; Tue, 12 Mar 2019 03:52:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7617A8E0002; Tue, 12 Mar 2019 03:52:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 629838E0003; Tue, 12 Mar 2019 03:52:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3BDCD8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 03:52:09 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id x12so1523405qtk.2
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 00:52:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=tuMFvOlBO7UZPvcLns7+MXnrq5AaaEB3ZM3FeQS8H6k=;
        b=rqNi9QnhqGNcZSZpI9Ibxzn/zUSxyxkh/n4+i+/SKQKKV5tsfyxp4bV7Cy4zbqY3nY
         O1ivVg/FJY19IU6ao3GS1BakMCezpLHp5mCYBwGDI8cTV5cnQU+5HX9ymSpz8dKqH+Up
         r7dUuny/DhhQVFmVSQ/J7UAX8qzN2f1IZVYSMhjzaevMz2kvq8DhPaSJD5UyshAc42Bx
         Xug8E29xcNiqnFOaYf59ggjO9IuGNE/Fk0QrsAyb7fjtqTr99BBs/Li+i5oswf4wX4Zc
         nbT6fxKQiCTsfMssCNlfrqaCN53LQ/pJdDDFZTme41m61PeEGey0DKfiEU+nQCnqekU/
         54LQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUdyv29yY0Ob/0I0B0B5za36rgWWECN4L/QkrE88hXliHPb4FOq
	HhPC5xU19YSLO+lESFx4aPpUg8UkfWPSFI00km4I1FAORZvURGJ4oEyCi02+yIdCJiEtVHPoiPB
	0SMsn3u7xtvJlRCn4kRuCeclrWcdUGuUgYETdRiaonvmuJUCHOiYVrfZy4g14SmBzCA==
X-Received: by 2002:a05:620a:12a5:: with SMTP id x5mr27827780qki.291.1552377129007;
        Tue, 12 Mar 2019 00:52:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxtUkEDnNHmms0N5t9sOwtgYzJ+3oy79P4Vbhg/8rr2XAcFY12Vk6Boi3Ep0SO8zrSIVvc9
X-Received: by 2002:a05:620a:12a5:: with SMTP id x5mr27827752qki.291.1552377128320;
        Tue, 12 Mar 2019 00:52:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552377128; cv=none;
        d=google.com; s=arc-20160816;
        b=mIddchr7UJazufjrYphhlUhwE1N0fPP0Jfz60XF9yWCQ9emK9ONxXcK4TGynwQysEU
         CZAYAh2CFaq/CSq4gf7SQL7JpSj8viEEeby/ynPrkJRmg63HSmKaLI3abeDBkhtdenMz
         fEUtaasvlC0MIRa4LHKj4J2QGG2Pcq47m9kwgexlBA3QrZ/VN00qUn8kJ8qT8YIHaXtW
         vPw3dDelAinN0Rg85LtnlK2bUbjzUwQcEv3ytkRVwGmJk9FA11Ml8vzFSyocw/xxFtRh
         Lri8qSOMEINrE/20WpYY+SFV0mG79silGA2uNyvHOBSu7r3wswbxLMIvMU9hDm4TPt+Y
         BUBg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=tuMFvOlBO7UZPvcLns7+MXnrq5AaaEB3ZM3FeQS8H6k=;
        b=xpfYNwVLIQF5v+cA0y9H1Qp+0+sbIN9aT35bDd9YWJw+lq6EEo4hFCbqv7Rbs4+oJh
         3vhCb3DWHhgv1/h+OSVak8Ig9c+2I4H2+UKBxj6+i2jh7qWYILWb/zNdi3Z+KBw4+e4U
         qlQWXuZEhAYril3GZF3SpgNRYCyiJRZB7R6XNrvCvGwprjIqfRaoPZ3F1kxNMKkGsdTb
         xjvU6WKm6SDnOruVudnAvNzoinW+MtXQVtnEztirUiV/8DnZAdOCpldYtjkXJMuKAdVN
         2oEpZW0rQOzHkBlXnEqm702aF7Ku+NN7tslLtrU2CaDcvazuk3bx5pBVQjCQiahTCeNc
         Xm1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m4si390066qvg.167.2019.03.12.00.52.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 00:52:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4FA493082200;
	Tue, 12 Mar 2019 07:52:07 +0000 (UTC)
Received: from [10.72.12.17] (ovpn-12-17.pek2.redhat.com [10.72.12.17])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 07EDA5DD74;
	Tue, 12 Mar 2019 07:51:55 +0000 (UTC)
Subject: Re: [RFC PATCH V2 0/5] vhost: accelerate metadata access through
 vmap()
To: James Bottomley <James.Bottomley@HansenPartnership.com>,
 David Miller <davem@davemloft.net>, mst@redhat.com
Cc: hch@infradead.org, kvm@vger.kernel.org,
 virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, peterx@redhat.com, linux-mm@kvack.org,
 aarcange@redhat.com, linux-arm-kernel@lists.infradead.org,
 linux-parisc@vger.kernel.org
References: <20190308141220.GA21082@infradead.org>
 <56374231-7ba7-0227-8d6d-4d968d71b4d6@redhat.com>
 <20190311095405-mutt-send-email-mst@kernel.org>
 <20190311.111413.1140896328197448401.davem@davemloft.net>
 <6b6dcc4a-2f08-ba67-0423-35787f3b966c@redhat.com>
 <1552367685.23859.22.camel@HansenPartnership.com>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <f9e52313-0a06-22b6-140c-ded75eecde20@redhat.com>
Date: Tue, 12 Mar 2019 15:51:53 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <1552367685.23859.22.camel@HansenPartnership.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.47]); Tue, 12 Mar 2019 07:52:07 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/3/12 下午1:14, James Bottomley wrote:
> On Tue, 2019-03-12 at 10:59 +0800, Jason Wang wrote:
>> On 2019/3/12 上午2:14, David Miller wrote:
>>> From: "Michael S. Tsirkin" <mst@redhat.com>
>>> Date: Mon, 11 Mar 2019 09:59:28 -0400
>>>
>>>> On Mon, Mar 11, 2019 at 03:13:17PM +0800, Jason Wang wrote:
>>>>> On 2019/3/8 下午10:12, Christoph Hellwig wrote:
>>>>>> On Wed, Mar 06, 2019 at 02:18:07AM -0500, Jason Wang wrote:
>>>>>>> This series tries to access virtqueue metadata through
>>>>>>> kernel virtual
>>>>>>> address instead of copy_user() friends since they had too
>>>>>>> much
>>>>>>> overheads like checks, spec barriers or even hardware
>>>>>>> feature
>>>>>>> toggling. This is done through setup kernel address through
>>>>>>> vmap() and
>>>>>>> resigter MMU notifier for invalidation.
>>>>>>>
>>>>>>> Test shows about 24% improvement on TX PPS. TCP_STREAM
>>>>>>> doesn't see
>>>>>>> obvious improvement.
>>>>>> How is this going to work for CPUs with virtually tagged
>>>>>> caches?
>>>>> Anything different that you worry?
>>>> If caches have virtual tags then kernel and userspace view of
>>>> memory
>>>> might not be automatically in sync if they access memory
>>>> through different virtual addresses. You need to do things like
>>>> flush_cache_page, probably multiple times.
>>> "flush_dcache_page()"
>>
>> I get this. Then I think the current set_bit_to_user() is suspicious,
>> we
>> probably miss a flush_dcache_page() there:
>>
>>
>> static int set_bit_to_user(int nr, void __user *addr)
>> {
>>           unsigned long log = (unsigned long)addr;
>>           struct page *page;
>>           void *base;
>>           int bit = nr + (log % PAGE_SIZE) * 8;
>>           int r;
>>
>>           r = get_user_pages_fast(log, 1, 1, &page);
>>           if (r < 0)
>>                   return r;
>>           BUG_ON(r != 1);
>>           base = kmap_atomic(page);
>>           set_bit(bit, base);
>>           kunmap_atomic(base);
> This sequence should be OK.  get_user_pages() contains a flush which
> clears the cache above the user virtual address, so on kmap, the page
> is coherent at the new alias.  On parisc at least, kunmap embodies a
> flush_dcache_page() which pushes any changes in the cache above the
> kernel virtual address back to main memory and makes it coherent again
> for the user alias to pick it up.


It would be good if kmap()/kunmap() can do this but looks like we can 
not assume this? For example, sparc's flush_dcache_page() doesn't do 
flush_dcache_page(). And bio_copy_data_iter() do flush_dcache_page() 
after kunmap_atomic().

Thanks


>
> James
>

