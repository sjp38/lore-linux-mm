Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 190C3C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 07:17:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB2B2214AE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 07:17:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB2B2214AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CDDD8E0003; Tue, 12 Mar 2019 03:17:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 754288E0002; Tue, 12 Mar 2019 03:17:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 61D328E0003; Tue, 12 Mar 2019 03:17:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 33C938E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 03:17:14 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id j22so1394328qtq.21
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 00:17:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=/chgghI73eyS2vcRFwrCOvFFr4AfrBIwF6cwjrNCzO4=;
        b=RE9wfhxtHvRd1MinM/FxGsjJ0n35ufqig4JL/T6E6n+S9pTXSJeXShGhnLu+P9V4B+
         b/7dijuN4jl1NEhSh4/SW6+CNtcDq+jHXiGsc1ITiisZ0oY4CmKrzQuxDanR3vjemGzQ
         o2HHpaU2/yGxBCBPXloJl01KuSjjt4rf8o3aPzHQChqrdbPdfWw3d+lqmcAulv3jQzMB
         X3rg2KJQM+K9lTsUMr3lILltUSPc1cplbtflJvchacvvw2b1vn819r2P6A3s7xiLEBWn
         WSwh183KMi23j6oa6q7+hI49VVTNfUVPWNRXcJGVzbiNS9D2x9ibDyZrV1g3MVjMBynL
         DWhg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU33jdMU+VtIR/ZLc5H9i5ivw7CJdZ27g8qSsJaPghMewvuZkAw
	9V7VCsAe68a/dvBGImGeUoiJMSDX+ywqmpxEL/B1FD3DhKroSgJavz8ZNEbGWYCtdtQ1nqLpLyT
	5wgE/PjGQFYPjOqk+OAJe3Vkk0nZY+GJ3j3pHKN3IfxwA+bq2aW3YJT+aBN6N41jMrw==
X-Received: by 2002:a05:620a:30a:: with SMTP id s10mr4214670qkm.54.1552375033994;
        Tue, 12 Mar 2019 00:17:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzl8DfNtUo4eOSuS1j5c+A7ATwitEgiVlpGg3h+IxoBAnUPpOkrflms2Y/BLdu0GmNVBxTx
X-Received: by 2002:a05:620a:30a:: with SMTP id s10mr4214633qkm.54.1552375033233;
        Tue, 12 Mar 2019 00:17:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552375033; cv=none;
        d=google.com; s=arc-20160816;
        b=cyyai0m+Dr97HV0C2mbL17DIEfIRiA68ay2szaRFMyBi0YIPF+RAbKYWGasQNlESSv
         HNfwUI6xd2O4StkNDsqkCHsWzIyt1MiaVZy0XDyHp5Bs/mwt4ZG+ik9/FRhZJOiKB2jt
         i/XHyRBIkgw+taXGz8s0Q33XEAjf9KHmf3iS4/eM56JrFBkoJ1iMWg7uk5e2bGV1gmhE
         rN8RcHP3kkHHVwnQ6THCp8ICvjSLvzA2mcJz35UwwOBWPSzbZdqVIbCfJEvz9tLWKIQ5
         qRMLJJ6GMKK8Llp20gXojmKBJ3wAsuTalAPpr5LHwmN4waBKNuebmGrkDE8b+a1/Zf+S
         VyVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=/chgghI73eyS2vcRFwrCOvFFr4AfrBIwF6cwjrNCzO4=;
        b=ukXjoJQNmEBCmwfEipRDt5d3LJygHq5u1tBn0D2jM5nVl/She0DyvSxynis5JYclkr
         K8M+1ljmUi1bQgKKuBcY52baH7K5z/4yUTwev5qKKZM9EwHqjtKjuEqD0mQrbvniD0TI
         omlkUSS2nxPiqyoxZVhfL//YmI+zC99B9s9y/vRgLf1C00W15KW3BB9OlGzXxSkyWlfN
         TnZbsdRJlEhZ5CzRFNA4eci9GSUZjPuBncrCzmFTupC7iFC97O7O5WQ7e9ZartF8RTSP
         8YHxvlj6FSQiPAeMBY194W4IGX4UQNzayLslGQJnNq+9/bQkGeTbUPtkMHgQqA1yW3rW
         m+aA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 6si884541qtp.312.2019.03.12.00.17.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 00:17:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1B71B307D84D;
	Tue, 12 Mar 2019 07:17:12 +0000 (UTC)
Received: from [10.72.12.17] (ovpn-12-17.pek2.redhat.com [10.72.12.17])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 074E9600C5;
	Tue, 12 Mar 2019 07:17:01 +0000 (UTC)
Subject: Re: [RFC PATCH V2 0/5] vhost: accelerate metadata access through
 vmap()
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: David Miller <davem@davemloft.net>, hch@infradead.org,
 kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, peterx@redhat.com,
 linux-mm@kvack.org, aarcange@redhat.com,
 linux-arm-kernel@lists.infradead.org, linux-parisc@vger.kernel.org
References: <20190308141220.GA21082@infradead.org>
 <56374231-7ba7-0227-8d6d-4d968d71b4d6@redhat.com>
 <20190311095405-mutt-send-email-mst@kernel.org>
 <20190311.111413.1140896328197448401.davem@davemloft.net>
 <6b6dcc4a-2f08-ba67-0423-35787f3b966c@redhat.com>
 <20190311235140-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <76c353ed-d6de-99a9-76f9-f258074c1462@redhat.com>
Date: Tue, 12 Mar 2019 15:17:00 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.5.1
MIME-Version: 1.0
In-Reply-To: <20190311235140-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Tue, 12 Mar 2019 07:17:12 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/3/12 上午11:52, Michael S. Tsirkin wrote:
> On Tue, Mar 12, 2019 at 10:59:09AM +0800, Jason Wang wrote:
>> On 2019/3/12 上午2:14, David Miller wrote:
>>> From: "Michael S. Tsirkin" <mst@redhat.com>
>>> Date: Mon, 11 Mar 2019 09:59:28 -0400
>>>
>>>> On Mon, Mar 11, 2019 at 03:13:17PM +0800, Jason Wang wrote:
>>>>> On 2019/3/8 下午10:12, Christoph Hellwig wrote:
>>>>>> On Wed, Mar 06, 2019 at 02:18:07AM -0500, Jason Wang wrote:
>>>>>>> This series tries to access virtqueue metadata through kernel virtual
>>>>>>> address instead of copy_user() friends since they had too much
>>>>>>> overheads like checks, spec barriers or even hardware feature
>>>>>>> toggling. This is done through setup kernel address through vmap() and
>>>>>>> resigter MMU notifier for invalidation.
>>>>>>>
>>>>>>> Test shows about 24% improvement on TX PPS. TCP_STREAM doesn't see
>>>>>>> obvious improvement.
>>>>>> How is this going to work for CPUs with virtually tagged caches?
>>>>> Anything different that you worry?
>>>> If caches have virtual tags then kernel and userspace view of memory
>>>> might not be automatically in sync if they access memory
>>>> through different virtual addresses. You need to do things like
>>>> flush_cache_page, probably multiple times.
>>> "flush_dcache_page()"
>>
>> I get this. Then I think the current set_bit_to_user() is suspicious, we
>> probably miss a flush_dcache_page() there:
>>
>>
>> static int set_bit_to_user(int nr, void __user *addr)
>> {
>>          unsigned long log = (unsigned long)addr;
>>          struct page *page;
>>          void *base;
>>          int bit = nr + (log % PAGE_SIZE) * 8;
>>          int r;
>>
>>          r = get_user_pages_fast(log, 1, 1, &page);
>>          if (r < 0)
>>                  return r;
>>          BUG_ON(r != 1);
>>          base = kmap_atomic(page);
>>          set_bit(bit, base);
>>          kunmap_atomic(base);
>>          set_page_dirty_lock(page);
>>          put_page(page);
>>          return 0;
>> }
>>
>> Thanks
> I think you are right. The correct fix though is to re-implement
> it using asm and handling pagefault, not gup.


I agree but it needs to introduce new helpers in asm  for all archs 
which is not trivial. At least for -stable, we need the flush?


> Three atomic ops per bit is way to expensive.


Yes.

Thanks

