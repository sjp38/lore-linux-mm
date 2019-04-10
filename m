Return-Path: <SRS0=DRoR=SM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3848C282CE
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 07:54:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AEE2A20674
	for <linux-mm@archiver.kernel.org>; Wed, 10 Apr 2019 07:54:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AEE2A20674
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40C426B026D; Wed, 10 Apr 2019 03:54:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 397016B026E; Wed, 10 Apr 2019 03:54:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 260446B026F; Wed, 10 Apr 2019 03:54:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id F3DD26B026D
	for <linux-mm@kvack.org>; Wed, 10 Apr 2019 03:54:05 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id b188so1240624qkg.15
        for <linux-mm@kvack.org>; Wed, 10 Apr 2019 00:54:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=L744jdFsHrSPvq4+8Q/UN3c+NA4ULvvZJVno1mznp1A=;
        b=crntbzMzRBJmKVXGVbIrdbTTG+NpjbrbZV3DRWrAOk69781QPIzVjncbjO1Br+8tLT
         UD73Pqz0NMV9vkjM8lN9apwdstrIxRJdQvR31maR/jSQi1A8t6FrnWtjcBcwJQpqnwC5
         03DhcHgE1TXZLl9F+xxnu6W8QXz0CAq4QvqoTyBM+Sr1ggJpTK+jzeEHFvkCiYhns/xA
         7a8GJ86MoSTNDSfyu8hWz72nHLYO/YWB88a5UgZ6nCCs9MlYhkLFWN5HZPBHFAA51nFl
         sVVI7dqQdUyUVIEYGcO+iv4d+/HxHbOakthW1VDlfV2xqgrAgjKZg0gT0Cizw4HGSroN
         gqbA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWsMQrJRlaIhyEpc+WYSngpLlWmiB1jTEOxygArpZp/NFUAcrWt
	RmDeR80jRBsp/RPT5SozMnvyYXiwqd+x/oSQKSK4Es4kjw94+mPMuLKGMcbrzP3D4VMpfWLWdu4
	x5XdV73WT98ox+bRT+Fs52LzbWPfHH0ik7aW3RO2SlqYo8v2H/iLN4wry2cKT+I0Itg==
X-Received: by 2002:a37:a81:: with SMTP id 123mr31914953qkk.290.1554882845719;
        Wed, 10 Apr 2019 00:54:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyPXRrl4pYdQCK57muWV734wvthGOvFyS1+4qXdiclzE3FWRn/K2UIk52X2jIBtgpx88+9s
X-Received: by 2002:a37:a81:: with SMTP id 123mr31914925qkk.290.1554882845028;
        Wed, 10 Apr 2019 00:54:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554882845; cv=none;
        d=google.com; s=arc-20160816;
        b=cyhlPtm0BsfXiXkGD9V5xczKzFABC/rzHUUyxL9dyKCRS6Y9r2/WU25NlfFjYtWTGU
         LKrg9Cd4V77RHOcs1vsN7p4hc/81XoX4yF3Ad5Zuq7rWYqkTZpUANpOtPxMcqy9xrQFy
         e3MwHMVAgVx2hJb0rgCikek8ta+bRMUCep3anODXCck8sIrqtgjM7R2aFbFedT8HK1Hw
         yQpQBcpC33tKIwesiPZMc+PmCNmb28KRVu/MmqimiIb5DdfTXJejoDb6tjhiabIBFNC4
         914IY+lUYTbnFsC6otpwLV6zTo9zvGiUsDOJ+2GmXMZ4aiWyg5mNZo6OGU+jgdrn0z/N
         PTmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=L744jdFsHrSPvq4+8Q/UN3c+NA4ULvvZJVno1mznp1A=;
        b=05K6uqYTGEQM/wmONZ1+UDwjiZCLZcjmot4bBPfYKZOeP29OGmpVJdqYslotSqRZ44
         iPnxo0ZwRkf/XeiVH1PrECQ3lhj05EtIpMW1T2BwE9XRCxLg7cPOVQ4uywoJGtdy3pko
         zV+GTwEkwSZJlM5nrno0lhPlvGv1CcCSWIF5az8tiJTO/rJmA8km9/ML4nWj/c2PaZ3Q
         PgXfq6PzBBW5Y4JZqQlt0YQ6gCLCqxQNpBbxBpixoLTJQQ27Ufg54tPs4H2lBbFffd6D
         IYWPGPz4vmeh+ihxdf+tq5yJVst7V9L6BqsSXAFWYUuYPNEke5fkC+qLVhdVBgPHGoqk
         Ss/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c58si3088360qta.208.2019.04.10.00.54.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Apr 2019 00:54:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7CCA6C002965;
	Wed, 10 Apr 2019 07:54:03 +0000 (UTC)
Received: from [10.72.12.186] (ovpn-12-186.pek2.redhat.com [10.72.12.186])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 2125419C72;
	Wed, 10 Apr 2019 07:53:53 +0000 (UTC)
Subject: Re: [PATCH net] vhost: flush dcache page when logging dirty pages
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: kvm@vger.kernel.org,
 "open list:VIRTIO GPU DRIVER" <virtualization@lists.linux-foundation.org>,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 Christoph Hellwig <hch@infradead.org>,
 James Bottomley <James.Bottomley@hansenpartnership.com>,
 Andrea Arcangeli <aarcange@redhat.com>, linux@armlinux.org.uk,
 linux-arm-kernel@lists.infradead.org,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>,
 Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>,
 linuxppc-dev@lists.ozlabs.org, Ralf Baechle <ralf@linux-mips.org>,
 Paul Burton <paul.burton@mips.com>, James Hogan <jhogan@kernel.org>,
 linux-mips@vger.kernel.org, Linux-MM <linux-mm@kvack.org>
References: <20190409041647.21269-1-jasowang@redhat.com>
 <20190409085607-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <b635592f-a2c5-5687-e634-6fcd4f5a1e36@redhat.com>
Date: Wed, 10 Apr 2019 15:53:52 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190409085607-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Wed, 10 Apr 2019 07:54:04 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/4/9 下午9:14, Michael S. Tsirkin wrote:
> On Tue, Apr 09, 2019 at 12:16:47PM +0800, Jason Wang wrote:
>> We set dirty bit through setting up kmaps and access them through
>> kernel virtual address, this may result alias in virtually tagged
>> caches that require a dcache flush afterwards.
>>
>> Cc: Christoph Hellwig <hch@infradead.org>
>> Cc: James Bottomley <James.Bottomley@HansenPartnership.com>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Fixes: 3a4d5c94e9593 ("vhost_net: a kernel-level virtio server")
> This is like saying "everyone with vhost needs this".
> In practice only might affect some architectures.


For the archs that does need dcache flushing, the function is just a nop.


> Which ones?


There're more than 10 archs that have ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE 
defined, just cc some maintainers of some more influenced ones.


> You want to Cc the relevant maintainers
> who understand this...
>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> I am not sure this is a good idea.
> The region in question is supposed to be accessed
> by userspace at the same time, through atomic operations.
>
> How do we know userspace didn't access it just before?


get_user_pages() will do both flush_annon_page() to make sure the 
userspace write is visible to kernel.


>
> Is that an issue at all given we use
> atomics for access? Documentation/core-api/cachetlb.rst does
> not mention atomics.
> Which architectures are affected?
> Assuming atomics actually do need a flush, then don't we need
> a flush in the other direction too? How are atomics
> supposed to work at all?


It's the issue of visibility, atomic operation is just one of the 
possible operations. If we can finally makes the write visible to each 
other, there will be no issue.

It looks to me we could still end up alias if userspace is accessing the 
dirty log between get_user_pages_fast() and flush_dcache_page(). But the 
flush_dcache_page() can guarantee what kernel wrote is visible to 
userspace finally though some bits cleared by userspace might still 
there. We may end up with more dirty pages noticed by userspace which 
should be harmless.


>
>
> I really think we need new APIs along the lines of
> set_bit_to_user.


Can we simply do:

get_user()

set bit

put_user()

instead?


>
>> ---
>>   drivers/vhost/vhost.c | 1 +
>>   1 file changed, 1 insertion(+)
>>
>> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
>> index 351af88231ad..34a1cedbc5ba 100644
>> --- a/drivers/vhost/vhost.c
>> +++ b/drivers/vhost/vhost.c
>> @@ -1711,6 +1711,7 @@ static int set_bit_to_user(int nr, void __user *addr)
>>   	base = kmap_atomic(page);
>>   	set_bit(bit, base);
>>   	kunmap_atomic(base);
>> +	flush_dcache_page(page);
>>   	set_page_dirty_lock(page);
>>   	put_page(page);
>>   	return 0;
> Ignoring the question of whether this actually helps, I doubt
> flush_dcache_page is appropriate here.  Pls take a look at
> Documentation/core-api/cachetlb.rst as well as the actual
> implementation.
>
> I think you meant flush_kernel_dcache_page, and IIUC it must happen
> before kunmap, not after (which you still have the va locked).


Looks like you're right.

Thanks


>
>> -- 
>> 2.19.1

