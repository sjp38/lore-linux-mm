Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C882C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 07:53:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB2D52173C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 07:53:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB2D52173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 876E48E0003; Tue, 12 Mar 2019 03:53:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 823DE8E0002; Tue, 12 Mar 2019 03:53:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EA7F8E0003; Tue, 12 Mar 2019 03:53:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6FD8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 03:53:50 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id b188so1471853qkg.15
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 00:53:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:cc:references:message-id:date:user-agent:mime-version
         :in-reply-to:content-transfer-encoding:content-language;
        bh=Z0aXoxS8rVXL7J6k2kLfOYzZULtUi8/02ywxziW0aKs=;
        b=akbjdtALfQ8nMZ7hWEjmCxBesLskj1zzxx9PlKa0+cvMOo0h5V6DXty6TS4nzgs7vt
         hS+UbJWYQzV+3/ti//lxa8X8B90Ae7LYuEED59zWKY7+K3JKBtfS1s4mp7jh8OufozGx
         j0GLYkbo3Yo16vyeiC5xF0rE6l0IgIEg8lUHrUq1JIB5XmrfeBzxCNRQmgsACnEftpUW
         x2oWcgX9B8N0ZXgsll4/OCKHV9K78R3uCGH7vcCErKtCju4SZM5thhJpI3HyccIQTYtb
         huWquH8naPqB4vBSOxxIzHDrW0KTHJtC2MJrbxJDCuvE5VvN8Y9XlZ8zeHQeEywX2uQD
         x/Ng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXHnWNj2GQG4tyKjMaTFD7I15RFJS5LF/EeAnYmC6k0fKUd0Ykg
	xpsPmfeK++wB2aQlvxoKs8J1q3Z4Tugly7+PuljKJUQ3be2Ts5UbwKFhtRs2kpizdbL8LRgnofY
	Yc7kK4HRe06+zD1mon1NIK7mKmdlUENTUFsyOO0PXSqCe3A90tqVtldlzv7FVOLBesA==
X-Received: by 2002:aed:3f82:: with SMTP id s2mr29607156qth.284.1552377230106;
        Tue, 12 Mar 2019 00:53:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxQneuG3opF9li1yiNm+FzUNx59NcY6M/QZNMlzwm4Pb09TknRtxe2H/sLk2MBNnFt413rs
X-Received: by 2002:aed:3f82:: with SMTP id s2mr29607124qth.284.1552377229423;
        Tue, 12 Mar 2019 00:53:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552377229; cv=none;
        d=google.com; s=arc-20160816;
        b=Eyljvg4hYkZpjvtrSZdGksaC5Xp0SAIsysSuvIokthJWTQ9tKI+VoEtDtnUnhKRCSr
         ECUmJHj9WyrEb1ayHUaPFrjT6nUGZBzHZLwreq53Weug2fzDzMGCFggKjwGdsYzzJ5UG
         mE0WQGUDePZhsVp6nkAX7E5YKnqHDQynddvtEts4r0ngwH7pcWMHton9uRdLzlLZhGKq
         NmouZ1mQ1gTTVWkv+eaKRZml2AGl30U2qmYJD5dw/grXdK7bjrtpF9XK0p/gKEataNGE
         M0YBg4g8veKQdyTxAdJokOY/tfjISHJFrKRX034/UG7APkYbSBYCBBn3oVFdZrhDc7Mj
         OUyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:references:cc:to:from:subject;
        bh=Z0aXoxS8rVXL7J6k2kLfOYzZULtUi8/02ywxziW0aKs=;
        b=kYtAXTO8G/w/Dd6pE9andyuKsfGs+kslpAGBPoUi8g8mvD5aK0Xi3HqN0GDBIgtzYG
         WS/rv9X+F7ii+t0L7xHsdmkqwC8YvXC0jM//J7XDrlMHKWON6KcNLjkCReDXvICqGbJU
         1kuzZBCvaNfuU0UunK99ARI2u3Me/WuiuVTK9q0mPEj68QOKPTUz3OczKeM+3JNSw/kr
         pPDa6w4hCrN5KxhL26xIh3zlNU3fxRIL/xuJP9hLszgb9uYQyM2xX6LBmn2WWSuhFFVu
         qFGpry8urg8rh8rfH6qTwUIFfk+70j+OM9qZzM6yB/t1hmch32J9yOzJGgdRgUGJdk3X
         pQLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k31si334910qvh.70.2019.03.12.00.53.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 00:53:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 904B987621;
	Tue, 12 Mar 2019 07:53:48 +0000 (UTC)
Received: from [10.72.12.17] (ovpn-12-17.pek2.redhat.com [10.72.12.17])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 86C1260CA3;
	Tue, 12 Mar 2019 07:53:39 +0000 (UTC)
Subject: Re: [RFC PATCH V2 0/5] vhost: accelerate metadata access through
 vmap()
From: Jason Wang <jasowang@redhat.com>
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
 <f9e52313-0a06-22b6-140c-ded75eecde20@redhat.com>
Message-ID: <7f779c16-58d1-dd4f-54cf-a7538d4b6fe4@redhat.com>
Date: Tue, 12 Mar 2019 15:53:37 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <f9e52313-0a06-22b6-140c-ded75eecde20@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Tue, 12 Mar 2019 07:53:48 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/3/12 下午3:51, Jason Wang wrote:
>
> On 2019/3/12 下午1:14, James Bottomley wrote:
>> On Tue, 2019-03-12 at 10:59 +0800, Jason Wang wrote:
>>> On 2019/3/12 上午2:14, David Miller wrote:
>>>> From: "Michael S. Tsirkin" <mst@redhat.com>
>>>> Date: Mon, 11 Mar 2019 09:59:28 -0400
>>>>
>>>>> On Mon, Mar 11, 2019 at 03:13:17PM +0800, Jason Wang wrote:
>>>>>> On 2019/3/8 下午10:12, Christoph Hellwig wrote:
>>>>>>> On Wed, Mar 06, 2019 at 02:18:07AM -0500, Jason Wang wrote:
>>>>>>>> This series tries to access virtqueue metadata through
>>>>>>>> kernel virtual
>>>>>>>> address instead of copy_user() friends since they had too
>>>>>>>> much
>>>>>>>> overheads like checks, spec barriers or even hardware
>>>>>>>> feature
>>>>>>>> toggling. This is done through setup kernel address through
>>>>>>>> vmap() and
>>>>>>>> resigter MMU notifier for invalidation.
>>>>>>>>
>>>>>>>> Test shows about 24% improvement on TX PPS. TCP_STREAM
>>>>>>>> doesn't see
>>>>>>>> obvious improvement.
>>>>>>> How is this going to work for CPUs with virtually tagged
>>>>>>> caches?
>>>>>> Anything different that you worry?
>>>>> If caches have virtual tags then kernel and userspace view of
>>>>> memory
>>>>> might not be automatically in sync if they access memory
>>>>> through different virtual addresses. You need to do things like
>>>>> flush_cache_page, probably multiple times.
>>>> "flush_dcache_page()"
>>>
>>> I get this. Then I think the current set_bit_to_user() is suspicious,
>>> we
>>> probably miss a flush_dcache_page() there:
>>>
>>>
>>> static int set_bit_to_user(int nr, void __user *addr)
>>> {
>>>           unsigned long log = (unsigned long)addr;
>>>           struct page *page;
>>>           void *base;
>>>           int bit = nr + (log % PAGE_SIZE) * 8;
>>>           int r;
>>>
>>>           r = get_user_pages_fast(log, 1, 1, &page);
>>>           if (r < 0)
>>>                   return r;
>>>           BUG_ON(r != 1);
>>>           base = kmap_atomic(page);
>>>           set_bit(bit, base);
>>>           kunmap_atomic(base);
>> This sequence should be OK.  get_user_pages() contains a flush which
>> clears the cache above the user virtual address, so on kmap, the page
>> is coherent at the new alias.  On parisc at least, kunmap embodies a
>> flush_dcache_page() which pushes any changes in the cache above the
>> kernel virtual address back to main memory and makes it coherent again
>> for the user alias to pick it up.
>
>
> It would be good if kmap()/kunmap() can do this but looks like we can 
> not assume this? For example, sparc's flush_dcache_page() 


Sorry, I meant kunmap_atomic().

Thanks


> doesn't do flush_dcache_page(). And bio_copy_data_iter() do 
> flush_dcache_page() after kunmap_atomic().
>
> Thanks
>
>
>>
>> James
>>
>

