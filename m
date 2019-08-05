Return-Path: <SRS0=3S0K=WB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61AF8C433FF
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 04:39:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B903217F4
	for <linux-mm@archiver.kernel.org>; Mon,  5 Aug 2019 04:39:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B903217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B80CC6B0006; Mon,  5 Aug 2019 00:39:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B310C6B0007; Mon,  5 Aug 2019 00:39:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A20676B0008; Mon,  5 Aug 2019 00:39:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 811056B0006
	for <linux-mm@kvack.org>; Mon,  5 Aug 2019 00:39:42 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id e39so74421219qte.8
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 21:39:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=zkUvsqXsQjRmrqof1WilbHLdWUGaLQOvS61PBAUJr7E=;
        b=I1Fr78hKxKYWDdcegriLLEy5N+GNE6jKyiYZNue9OY1Hm0yQgtYtg2xRfqb7Wn7uPi
         zK72F5Pc7jgUdPlp4eRLgGlJ6Js3bT344S15mlDOUd+35qEZO+JOZqVdGHTlZ6H4LsGT
         zvAkGjoUGuyXMY8SMNBzAbsEp3nmYkkISY0ZF0xFGIkuMHdvhiVLWaQN2FQWN/g053H4
         zREkWtBk2du1DZO1czb9o55JvFRm/uWxFE8lROXFRwtpzzqSBRe36468yfrEdLinulFt
         JYUZ17jWePA8Rxm+gQhFB0OcktwSEu+BOmgI2aYzzRH0rKwi/N9WDTIEwR+M07JTlx4x
         6aqQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVae/MfpYVYeglgdbCcGnN7M+sqKr7FCj1453YMBMdZiJcgno0d
	hjOngW39bEPAk13oeJG+ciCQafY6SjYreQBDTBENCCCE7VCKU1UyAQ0v3nNp5pUzxdLjNbiJChe
	kvQ03C8HvjKYkFfqlPRthf6/bSJfHUJFiAtcgQZboZ2t9Uzy8LAAEAQQQyDDX+Us29A==
X-Received: by 2002:a0c:9932:: with SMTP id h47mr107109396qvd.147.1564979982293;
        Sun, 04 Aug 2019 21:39:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz0I5sqShE1sWoQ7fijT0aSx/trEscTp5FaqJcwh7Jq4jJr7X9o6XfxSfXLAB8WevRt8ZNG
X-Received: by 2002:a0c:9932:: with SMTP id h47mr107109381qvd.147.1564979981733;
        Sun, 04 Aug 2019 21:39:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564979981; cv=none;
        d=google.com; s=arc-20160816;
        b=dwbU+k29LLy3RLeC1WN1/tH7hU14rJlAbAaG88Gsx8VbbzEJ23meihVORlogCesNUq
         +y/dmztZcDMIvJU+XOnuKPLzsUBfDV5Gtguxq6lSQyCC0p1+10vR9Jd3dKnCH18UBLgB
         kUTP/pKlkDYryp81QqO9cJZyk/Lhoui3Dalzp9Kfy7MBAid0vEyUuSRpR8Pa/VdKU5Rv
         JZPandAWhgGkLbGLNlW7CTtPYDx910zzmT0qK9nAo/kpsYLTsbR/rQqQ/e9yFyuHtZKG
         vz2qPp4G4YgqCPNROP0XDxEC4jW5Pz5uXEvBsYEr2393Kj30PJb6FA5Xha2VqsLmKodz
         9LDQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=zkUvsqXsQjRmrqof1WilbHLdWUGaLQOvS61PBAUJr7E=;
        b=dEMgAGJpO/2EbbfSlbWoBbWh0jzF3E5kgR8naFhmjB/47Mx9pvCgwCos6b2GBY3rvq
         rfCXOLaiFOYW59UggLigQu0lbX5QTOlvSC/IsW778633sGnq1dHT0u1THPOtzEYKDEqA
         JuMJsfMmC8RF/VPgwWniOHkdh6bjQo1mYA6laOOnhXO6r8QjQjwzvrO2aMEfUQVEY+Z0
         jhh31c1nFgcIazj7azr+jMCl8//qbvEj1yR1lbAcyJuacCahJ75HkXiiv4da5Dxd0zVd
         fIEwmT+HleDYHEI2a2pWPnkfEQDypa8WLsrN2oR68knSWjuC9SWEJ92upVGpZJd096Jk
         N9lg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v23si47946246qvf.71.2019.08.04.21.39.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Aug 2019 21:39:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D37428110A;
	Mon,  5 Aug 2019 04:39:40 +0000 (UTC)
Received: from [10.72.12.115] (ovpn-12-115.pek2.redhat.com [10.72.12.115])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 34BC819C59;
	Mon,  5 Aug 2019 04:39:35 +0000 (UTC)
Subject: Re: [PATCH V2 7/9] vhost: do not use RCU to synchronize MMU notifier
 with worker
To: "Michael S. Tsirkin" <mst@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
References: <7555c949-ae6f-f105-6e1d-df21ddae9e4e@redhat.com>
 <20190731193057.GG3946@ziepe.ca>
 <a3bde826-6329-68e4-2826-8a9de4c5bd1e@redhat.com>
 <20190801141512.GB23899@ziepe.ca>
 <42ead87b-1749-4c73-cbe4-29dbeb945041@redhat.com>
 <20190802124613.GA11245@ziepe.ca>
 <20190802100414-mutt-send-email-mst@kernel.org>
 <20190802172418.GB11245@ziepe.ca>
 <20190803172944-mutt-send-email-mst@kernel.org>
 <20190804001400.GA25543@ziepe.ca>
 <20190804040034-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <8e0812e4-f618-8a9c-38ce-d45f6c897c52@redhat.com>
Date: Mon, 5 Aug 2019 12:39:34 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190804040034-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Mon, 05 Aug 2019 04:39:40 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/8/4 下午4:07, Michael S. Tsirkin wrote:
> On Sat, Aug 03, 2019 at 09:14:00PM -0300, Jason Gunthorpe wrote:
>> On Sat, Aug 03, 2019 at 05:36:13PM -0400, Michael S. Tsirkin wrote:
>>> On Fri, Aug 02, 2019 at 02:24:18PM -0300, Jason Gunthorpe wrote:
>>>> On Fri, Aug 02, 2019 at 10:27:21AM -0400, Michael S. Tsirkin wrote:
>>>>> On Fri, Aug 02, 2019 at 09:46:13AM -0300, Jason Gunthorpe wrote:
>>>>>> On Fri, Aug 02, 2019 at 05:40:07PM +0800, Jason Wang wrote:
>>>>>>>> This must be a proper barrier, like a spinlock, mutex, or
>>>>>>>> synchronize_rcu.
>>>>>>>
>>>>>>> I start with synchronize_rcu() but both you and Michael raise some
>>>>>>> concern.
>>>>>> I've also idly wondered if calling synchronize_rcu() under the various
>>>>>> mm locks is a deadlock situation.
>>>>>>
>>>>>>> Then I try spinlock and mutex:
>>>>>>>
>>>>>>> 1) spinlock: add lots of overhead on datapath, this leads 0 performance
>>>>>>> improvement.
>>>>>> I think the topic here is correctness not performance improvement
>>>>> The topic is whether we should revert
>>>>> commit 7f466032dc9 ("vhost: access vq metadata through kernel virtual address")
>>>>>
>>>>> or keep it in. The only reason to keep it is performance.
>>>> Yikes, I'm not sure you can ever win against copy_from_user using
>>>> mmu_notifiers?
>>> Ever since copy_from_user started playing with flags (for SMAP) and
>>> added speculation barriers there's a chance we can win by accessing
>>> memory through the kernel address.
>> You think copy_to_user will be more expensive than the minimum two
>> atomics required to synchronize with another thread?
> I frankly don't know. With SMAP you flip flags twice, and with spectre
> you flush the pipeline. Is that cheaper or more expensive than an atomic
> operation? Testing is the only way to tell.


Let me test, I only did test on a non SMAP machine. Switching to 
spinlock kills all performance improvement.

Thanks


>
>>>> Also, why can't this just permanently GUP the pages? In fact, where
>>>> does it put_page them anyhow? Worrying that 7f466 adds a get_user page
>>>> but does not add a put_page??
>> You didn't answer this.. Why not just use GUP?
>>
>> Jason
> Sorry I misunderstood the question. Permanent GUP breaks lots of
> functionality we need such as THP and numa balancing.
>
> release_pages is used instead of put_page.
>
>
>
>

