Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 074E3C7618B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 11:57:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACBC722BF5
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 11:57:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACBC722BF5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2EC1B8E006D; Thu, 25 Jul 2019 07:57:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C27D8E0059; Thu, 25 Jul 2019 07:57:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 18A2C8E006D; Thu, 25 Jul 2019 07:57:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id E96898E0059
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 07:57:47 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id h198so42219621qke.1
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 04:57:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding
         :content-language;
        bh=N8ezWZkCh70U7UZMtTosop62NOOxul/P9Lqf9C7BbjI=;
        b=Zi5Cl1iULijT6ngDabL3k9MyrC281zDV09TERVj+krBUq9RzZz6DuhkLzNdTIckuzt
         EqtCo0gb5nyqSFpCkd/dtAIy+eKcgsh8pOOSoZUSfET5xyYzs/0+4+Ib2ZdJ7p/mqFej
         LRRsZTRytf1Wq6ICWfvyY/K41VMT5kOAXUk8nctnWXpGNKIFqearowsAM1TRodsdEzXy
         fYGcZpAAjJ7i0AIhzKR1hiCA7/wxR8H5Sp4FmAkMR7659/8kGrVmHG8klKavzJfN9qNr
         wM3Uf47q5LVs9D9gzXjGaYhsPYP1lrynMW/fJ1jvzfGLCS8nojEWmFkhYgfkQxmJewHo
         4mkw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXkCBQP/WDYhDakIoFGLSqlPd72+L12NlUdnyIRm01GsALmytmN
	nD07gS8lFvOTVubGPJyq6rGPYajSTINxrAbw+1IgpKQmROMUnU43vCezNqV/quwM62cBP99kx8F
	yy98Idi/kmBqFnmfzwjpAz9A1KONlhoHZ5ATH1rvFkicSYTamJtLX+f00+GUJ33xiBA==
X-Received: by 2002:aed:24f4:: with SMTP id u49mr59788491qtc.8.1564055867726;
        Thu, 25 Jul 2019 04:57:47 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz7hs/9vy+3PLwDrD38L4PU93decemlCONtRxapLzzWOY52ON07gJiVnbLh7IrRczl1fuzd
X-Received: by 2002:aed:24f4:: with SMTP id u49mr59788465qtc.8.1564055867172;
        Thu, 25 Jul 2019 04:57:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564055867; cv=none;
        d=google.com; s=arc-20160816;
        b=ik2S1/Vk75dIgRpacKHkCY0F5HbULmQvmXTYykxnLlbwXAn/vB7nldEGaY3eNej7tJ
         lGTb3NtcFKso3xDXscKQu5n8PFYUZ/ehJUnG+eAMtqxhPE/c3oIrs008Mp/0F0vcMDq2
         dJFHPA4SRPOFGiZaNZeF1SEKLM4WL9MfoYTAvjatQ/lIIc6VLA79emFXuOpEPIYKhTaN
         tA2sP0R2cC4mYXcaWGURaU11IThKzI+VZCpRBmmxR1ItYrS0m76lnYNWXVV1eqiv9Vo/
         GGTzaATSEjX9oVHSzgvRyezm+YfeS2GGCfJlljYpBXCrBQy2QejDwQWOCroTrBVpQITh
         /C3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=N8ezWZkCh70U7UZMtTosop62NOOxul/P9Lqf9C7BbjI=;
        b=CqtmQt2pZ+nwxs40UxXJZSOa5Ervqfody7I4gg4QJ/oVNm3xfhYVVHfWmB/oGX4ver
         kWbd0cNJpEK/koCluDK9Yxqx/0ERdCtGJA7WELZi8TK6ffjmZtQf+nXOHFW5fm8HfXQM
         Q+ZUzc/FNJh3j7hHUjK3qinHZ7b7mjMhD6FyfsG34nG0DLytJmk0JcJ6653F76LfydDo
         2NsRRoWoCrht/7uLk9YDPXb2qf7lYjOevQfkgWt3KbRhGx7F2TFill5pbrZJ9Z7cNC/J
         5tp5xT5VLUpXlPNG+0ofrqCaCWwn78YnGmJi9QMuEB2/+Ww7y+kIFny/qKsDNkFDxf0C
         Giww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m28si30756467qtm.326.2019.07.25.04.57.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 04:57:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 534E6300CA4D;
	Thu, 25 Jul 2019 11:57:46 +0000 (UTC)
Received: from [10.18.17.163] (dhcp-17-163.bos.redhat.com [10.18.17.163])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 5B99D5DABA;
	Thu, 25 Jul 2019 11:57:37 +0000 (UTC)
Subject: Re: [PATCH v2 QEMU] virtio-balloon: Provide a interface for "bubble
 hinting"
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>,
 Alexander Duyck <alexander.duyck@gmail.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, kvm@vger.kernel.org,
 david@redhat.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, akpm@linux-foundation.org, yang.zhang.wz@gmail.com,
 pagupta@redhat.com, riel@surriel.com, konrad.wilk@oracle.com,
 lcapitulino@redhat.com, wei.w.wang@intel.com, aarcange@redhat.com,
 pbonzini@redhat.com, dan.j.williams@intel.com
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
 <20190724171050.7888.62199.stgit@localhost.localdomain>
 <20190724150224-mutt-send-email-mst@kernel.org>
 <6218af96d7d55935f2cf607d47680edc9b90816e.camel@linux.intel.com>
From: Nitesh Narayan Lal <nitesh@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=nitesh@redhat.com; prefer-encrypt=mutual; keydata=
 mQINBFl4pQoBEADT/nXR2JOfsCjDgYmE2qonSGjkM1g8S6p9UWD+bf7YEAYYYzZsLtbilFTe
 z4nL4AV6VJmC7dBIlTi3Mj2eymD/2dkKP6UXlliWkq67feVg1KG+4UIp89lFW7v5Y8Muw3Fm
 uQbFvxyhN8n3tmhRe+ScWsndSBDxYOZgkbCSIfNPdZrHcnOLfA7xMJZeRCjqUpwhIjxQdFA7
 n0s0KZ2cHIsemtBM8b2WXSQG9CjqAJHVkDhrBWKThDRF7k80oiJdEQlTEiVhaEDURXq+2XmG
 jpCnvRQDb28EJSsQlNEAzwzHMeplddfB0vCg9fRk/kOBMDBtGsTvNT9OYUZD+7jaf0gvBvBB
 lbKmmMMX7uJB+ejY7bnw6ePNrVPErWyfHzR5WYrIFUtgoR3LigKnw5apzc7UIV9G8uiIcZEn
 C+QJCK43jgnkPcSmwVPztcrkbC84g1K5v2Dxh9amXKLBA1/i+CAY8JWMTepsFohIFMXNLj+B
 RJoOcR4HGYXZ6CAJa3Glu3mCmYqHTOKwezJTAvmsCLd3W7WxOGF8BbBjVaPjcZfavOvkin0u
 DaFvhAmrzN6lL0msY17JCZo046z8oAqkyvEflFbC0S1R/POzehKrzQ1RFRD3/YzzlhmIowkM
 BpTqNBeHEzQAlIhQuyu1ugmQtfsYYq6FPmWMRfFPes/4JUU/PQARAQABtCVOaXRlc2ggTmFy
 YXlhbiBMYWwgPG5pbGFsQHJlZGhhdC5jb20+iQI9BBMBCAAnBQJZeKUKAhsjBQkJZgGABQsJ
 CAcCBhUICQoLAgQWAgMBAh4BAheAAAoJEKOGQNwGMqM56lEP/A2KMs/pu0URcVk/kqVwcBhU
 SnvB8DP3lDWDnmVrAkFEOnPX7GTbactQ41wF/xwjwmEmTzLrMRZpkqz2y9mV0hWHjqoXbOCS
 6RwK3ri5e2ThIPoGxFLt6TrMHgCRwm8YuOSJ97o+uohCTN8pmQ86KMUrDNwMqRkeTRW9wWIQ
 EdDqW44VwelnyPwcmWHBNNb1Kd8j3xKlHtnS45vc6WuoKxYRBTQOwI/5uFpDZtZ1a5kq9Ak/
 MOPDDZpd84rqd+IvgMw5z4a5QlkvOTpScD21G3gjmtTEtyfahltyDK/5i8IaQC3YiXJCrqxE
 r7/4JMZeOYiKpE9iZMtS90t4wBgbVTqAGH1nE/ifZVAUcCtycD0f3egX9CHe45Ad4fsF3edQ
 ESa5tZAogiA4Hc/yQpnnf43a3aQ67XPOJXxS0Qptzu4vfF9h7kTKYWSrVesOU3QKYbjEAf95
 NewF9FhAlYqYrwIwnuAZ8TdXVDYt7Z3z506//sf6zoRwYIDA8RDqFGRuPMXUsoUnf/KKPrtR
 ceLcSUP/JCNiYbf1/QtW8S6Ca/4qJFXQHp0knqJPGmwuFHsarSdpvZQ9qpxD3FnuPyo64S2N
 Dfq8TAeifNp2pAmPY2PAHQ3nOmKgMG8Gn5QiORvMUGzSz8Lo31LW58NdBKbh6bci5+t/HE0H
 pnyVf5xhNC/FuQINBFl4pQoBEACr+MgxWHUP76oNNYjRiNDhaIVtnPRqxiZ9v4H5FPxJy9UD
 Bqr54rifr1E+K+yYNPt/Po43vVL2cAyfyI/LVLlhiY4yH6T1n+Di/hSkkviCaf13gczuvgz4
 KVYLwojU8+naJUsiCJw01MjO3pg9GQ+47HgsnRjCdNmmHiUQqksMIfd8k3reO9SUNlEmDDNB
 XuSzkHjE5y/R/6p8uXaVpiKPfHoULjNRWaFc3d2JGmxJpBdpYnajoz61m7XJlgwl/B5Ql/6B
 dHGaX3VHxOZsfRfugwYF9CkrPbyO5PK7yJ5vaiWre7aQ9bmCtXAomvF1q3/qRwZp77k6i9R3
 tWfXjZDOQokw0u6d6DYJ0Vkfcwheg2i/Mf/epQl7Pf846G3PgSnyVK6cRwerBl5a68w7xqVU
 4KgAh0DePjtDcbcXsKRT9D63cfyfrNE+ea4i0SVik6+N4nAj1HbzWHTk2KIxTsJXypibOKFX
 2VykltxutR1sUfZBYMkfU4PogE7NjVEU7KtuCOSAkYzIWrZNEQrxYkxHLJsWruhSYNRsqVBy
 KvY6JAsq/i5yhVd5JKKU8wIOgSwC9P6mXYRgwPyfg15GZpnw+Fpey4bCDkT5fMOaCcS+vSU1
 UaFmC4Ogzpe2BW2DOaPU5Ik99zUFNn6cRmOOXArrryjFlLT5oSOe4IposgWzdwARAQABiQIl
 BBgBCAAPBQJZeKUKAhsMBQkJZgGAAAoJEKOGQNwGMqM5ELoP/jj9d9gF1Al4+9bngUlYohYu
 0sxyZo9IZ7Yb7cHuJzOMqfgoP4tydP4QCuyd9Q2OHHL5AL4VFNb8SvqAxxYSPuDJTI3JZwI7
 d8JTPKwpulMSUaJE8ZH9n8A/+sdC3CAD4QafVBcCcbFe1jifHmQRdDrvHV9Es14QVAOTZhnJ
 vweENyHEIxkpLsyUUDuVypIo6y/Cws+EBCWt27BJi9GH/EOTB0wb+2ghCs/i3h8a+bi+bS7L
 FCCm/AxIqxRurh2UySn0P/2+2eZvneJ1/uTgfxnjeSlwQJ1BWzMAdAHQO1/lnbyZgEZEtUZJ
 x9d9ASekTtJjBMKJXAw7GbB2dAA/QmbA+Q+Xuamzm/1imigz6L6sOt2n/X/SSc33w8RJUyor
 SvAIoG/zU2Y76pKTgbpQqMDmkmNYFMLcAukpvC4ki3Sf086TdMgkjqtnpTkEElMSFJC8npXv
 3QnGGOIfFug/qs8z03DLPBz9VYS26jiiN7QIJVpeeEdN/LKnaz5LO+h5kNAyj44qdF2T2AiF
 HxnZnxO5JNP5uISQH3FjxxGxJkdJ8jKzZV7aT37sC+Rp0o3KNc+GXTR+GSVq87Xfuhx0LRST
 NK9ZhT0+qkiN7npFLtNtbzwqaqceq3XhafmCiw8xrtzCnlB/C4SiBr/93Ip4kihXJ0EuHSLn
 VujM7c/b4pps
Organization: Red Hat Inc,
Message-ID: <bbfe0fbb-dd23-ed5c-01b3-493ae804942f@redhat.com>
Date: Thu, 25 Jul 2019 07:57:35 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <6218af96d7d55935f2cf607d47680edc9b90816e.camel@linux.intel.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Thu, 25 Jul 2019 11:57:46 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 7/24/19 4:18 PM, Alexander Duyck wrote:
> On Wed, 2019-07-24 at 15:02 -0400, Michael S. Tsirkin wrote:
>> On Wed, Jul 24, 2019 at 10:12:10AM -0700, Alexander Duyck wrote:
>>> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>>>
>>> Add support for what I am referring to as "bubble hinting". Basically the
>>> idea is to function very similar to how the balloon works in that we
>>> basically end up madvising the page as not being used. However we don't
>>> really need to bother with any deflate type logic since the page will be
>>> faulted back into the guest when it is read or written to.
>>>
>>> This is meant to be a simplification of the existing balloon interface
>>> to use for providing hints to what memory needs to be freed. I am assuming
>>> this is safe to do as the deflate logic does not actually appear to do very
>>> much other than tracking what subpages have been released and which ones
>>> haven't.
>>>
>>> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
>>> ---
>>>  hw/virtio/virtio-balloon.c                      |   40 +++++++++++++++++++++++
>>>  include/hw/virtio/virtio-balloon.h              |    2 +
>>>  include/standard-headers/linux/virtio_balloon.h |    1 +
>>>  3 files changed, 42 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/hw/virtio/virtio-balloon.c b/hw/virtio/virtio-balloon.c
>>> index 2112874055fb..70c0004c0f88 100644
>>> --- a/hw/virtio/virtio-balloon.c
>>> +++ b/hw/virtio/virtio-balloon.c
>>> @@ -328,6 +328,39 @@ static void balloon_stats_set_poll_interval(Object *obj, Visitor *v,
>>>      balloon_stats_change_timer(s, 0);
>>>  }
>>>  
>>> +static void virtio_bubble_handle_output(VirtIODevice *vdev, VirtQueue *vq)
>>> +{
>>> +    VirtQueueElement *elem;
>>> +
>>> +    while ((elem = virtqueue_pop(vq, sizeof(VirtQueueElement)))) {
>>> +    	unsigned int i;
>>> +
>>> +        for (i = 0; i < elem->in_num; i++) {
>>> +            void *addr = elem->in_sg[i].iov_base;
>>> +            size_t size = elem->in_sg[i].iov_len;
>>> +            ram_addr_t ram_offset;
>>> +            size_t rb_page_size;
>>> +            RAMBlock *rb;
>>> +
>>> +            if (qemu_balloon_is_inhibited())
>>> +                continue;
>>> +
>>> +            rb = qemu_ram_block_from_host(addr, false, &ram_offset);
>>> +            rb_page_size = qemu_ram_pagesize(rb);
>>> +
>>> +            /* For now we will simply ignore unaligned memory regions */
>>> +            if ((ram_offset | size) & (rb_page_size - 1))
>>> +                continue;
>>> +
>>> +            ram_block_discard_range(rb, ram_offset, size);
>> I suspect this needs to do like the migration type of
>> hinting and get disabled if page poisoning is in effect.
>> Right?
> Shouldn't something like that end up getting handled via
> qemu_balloon_is_inhibited, or did I miss something there? I assumed cases
> like that would end up setting qemu_balloon_is_inhibited to true, if that
> isn't the case then I could add some additional conditions. I would do it
> in about the same spot as the qemu_balloon_is_inhibited check.


Just wondering if you have tried running these patches in an environment with
directly assigned devices? Ideally, I would expect qemu_balloon_is_inhibited()
to take care of it.


>
>
-- 
Thanks
Nitesh

