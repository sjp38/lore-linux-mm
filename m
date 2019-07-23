Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E56BBC76190
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 13:34:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A6A6422543
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 13:34:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A6A6422543
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4346F6B000E; Tue, 23 Jul 2019 09:34:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 40CD78E0003; Tue, 23 Jul 2019 09:34:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 322FC8E0002; Tue, 23 Jul 2019 09:34:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 12B956B000E
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 09:34:40 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id x11so34098373qto.23
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 06:34:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=AX2ygKaDqPTUn3szeSrgnCIunMmrqbAlyLo6JyAkA4Y=;
        b=cCY2vvgGdLDIdIIXBi9Wc9dj1jnaa0wekQjTHlDjBeqWxpa+hPc9Awvx4v+9zfCoyN
         qLLD1eTaLhdIzK1UQmEvx5koJxSoFaHgh11t3VX9amfgctTkAsRYc6gBc8lspwUUlrzw
         lXU2icENbrGIU58lxV7XL77lZ+k5lCX3fKzGx0PumnvwFGEW8TRU4Q1EQlaBk689SUZV
         qxask4WVUXo2ah4JJwvo5ZY4Uagxh0sYk2bsdJcreDhQNyZ2N8DEtWNZaqevzVV1KpBe
         orRh0fo1uZtnPpZl8uNSN13qychJf7MVNPgxHEX3M7syvil+Yz/NgCSCpyjc2VJ78lKy
         CLag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUPDlynmtd6rk51/AISuusga30jqi7pZeyOeUNC3ukg52L8YKBC
	rANAPKxdKBW89fxZuU/obmOsQLj8ryNCbLpAK5Tb+lRbKa4cY/TcxIpknZrjcEyQ7/F99Lc9ryP
	qA6cYiTmQW8dkiy3gTBoNPiW3zOS+ki6fMh1SHFvzXoc0qbstFwcEUFNWeeDhwoD1og==
X-Received: by 2002:aed:2dc7:: with SMTP id i65mr35017590qtd.365.1563888879846;
        Tue, 23 Jul 2019 06:34:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxqv+X3areSbrTAfFD9pc9XIV78O8sss9XTkvdnsxVHY58uT9w74E2CuUfYiBzDPSh2SAZv
X-Received: by 2002:aed:2dc7:: with SMTP id i65mr35017548qtd.365.1563888879101;
        Tue, 23 Jul 2019 06:34:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563888879; cv=none;
        d=google.com; s=arc-20160816;
        b=EI8LYg5fTDAz+eKBJEqUXoSItF45kw8QAmoJeRQQVI9vKwQEu2RdQZMxPZFHZZ06Py
         +eHw2WRCPveJLLPPTTH+pX8C7NgM0SIGZEbArSiDahPL0Ht2+N5vgSoOoZ1UlKK8MmJP
         HozNSf5noi30Oyd7hQcG+rmXoTC0dZFpJCXTF3gqlsAlwNPGigMRgGNjh2uwxL4sKFQ5
         k19zBo+bTaaLwL9tBUGgTWbofYZ5LmOA7oMUS6csKRL/DtD1AMlH6RVnO2rQpLE6ca++
         SS8jIasCy/XlS2/p7kvH9ZrxLunyDz6fE4g0Gw532PFRT7KV90EmaWxLoVLomrLEkzDh
         yk3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=AX2ygKaDqPTUn3szeSrgnCIunMmrqbAlyLo6JyAkA4Y=;
        b=kMxYwFyRWtIPkTpkErA6t+FFCmvW+EZt2s/XnIfszVpRkO/guD5/pNxx6PPTILUqVz
         vmt7ur/zAjhxr8Vmlc4gc6MLY08L+drSFa5FBTzfwZezKwavYTFu0czf4suv5RINsY0g
         zachPZyG+8KvhZ6I+aciuR8DCrYAY0bM7CcboES9PirvfBSozM8rJtBeuGTB96gIoXOJ
         fDDTPzMTHfvGDesHYTpSp7HeziZNzrXG0JHYhUkrohqEjYQPgRh031QSlOMwzOd3es0A
         Alch2m8VVof9IyhP1OonzWhG53AQ14im9aO1YD2LKvWEWBVD8lS3gUThlGWGfpRq9FCl
         +aZg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i2si25099860qkg.67.2019.07.23.06.34.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 06:34:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jasowang@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jasowang@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E9D3785365;
	Tue, 23 Jul 2019 13:34:37 +0000 (UTC)
Received: from [10.72.12.26] (ovpn-12-26.pek2.redhat.com [10.72.12.26])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 4DB5A1001B29;
	Tue, 23 Jul 2019 13:34:24 +0000 (UTC)
Subject: Re: WARNING in __mmdrop
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: syzbot <syzbot+e58112d71f77113ddb7b@syzkaller.appspotmail.com>,
 aarcange@redhat.com, akpm@linux-foundation.org, christian@brauner.io,
 davem@davemloft.net, ebiederm@xmission.com, elena.reshetova@intel.com,
 guro@fb.com, hch@infradead.org, james.bottomley@hansenpartnership.com,
 jglisse@redhat.com, keescook@chromium.org, ldv@altlinux.org,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, linux-parisc@vger.kernel.org, luto@amacapital.net,
 mhocko@suse.com, mingo@kernel.org, namit@vmware.com, peterz@infradead.org,
 syzkaller-bugs@googlegroups.com, viro@zeniv.linux.org.uk, wad@chromium.org
References: <0000000000008dd6bb058e006938@google.com>
 <000000000000964b0d058e1a0483@google.com>
 <20190721044615-mutt-send-email-mst@kernel.org>
 <75c43998-3a1c-676f-99ff-3d04663c3fcc@redhat.com>
 <20190722035657-mutt-send-email-mst@kernel.org>
 <cfcd330d-5f4a-835a-69f7-c342d5d0d52d@redhat.com>
 <20190723010156-mutt-send-email-mst@kernel.org>
 <124be1a2-1c53-8e65-0f06-ee2294710822@redhat.com>
 <20190723032800-mutt-send-email-mst@kernel.org>
 <e2e01a05-63d8-4388-2bcd-b2be3c865486@redhat.com>
 <20190723062221-mutt-send-email-mst@kernel.org>
From: Jason Wang <jasowang@redhat.com>
Message-ID: <9baa4214-67fd-7ad2-cbad-aadf90bbfc20@redhat.com>
Date: Tue, 23 Jul 2019 21:34:29 +0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190723062221-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Tue, 23 Jul 2019 13:34:38 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 2019/7/23 下午6:27, Michael S. Tsirkin wrote:
>> Yes, since there could be multiple co-current invalidation requests. We need
>> count them to make sure we don't pin wrong pages.
>>
>>
>>> I also wonder about ordering. kvm has this:
>>>          /*
>>>            * Used to check for invalidations in progress, of the pfn that is
>>>            * returned by pfn_to_pfn_prot below.
>>>            */
>>>           mmu_seq = kvm->mmu_notifier_seq;
>>>           /*
>>>            * Ensure the read of mmu_notifier_seq isn't reordered with PTE reads in
>>>            * gfn_to_pfn_prot() (which calls get_user_pages()), so that we don't
>>>            * risk the page we get a reference to getting unmapped before we have a
>>>            * chance to grab the mmu_lock without mmu_notifier_retry() noticing.
>>>            *
>>>            * This smp_rmb() pairs with the effective smp_wmb() of the combination
>>>            * of the pte_unmap_unlock() after the PTE is zapped, and the
>>>            * spin_lock() in kvm_mmu_notifier_invalidate_<page|range_end>() before
>>>            * mmu_notifier_seq is incremented.
>>>            */
>>>           smp_rmb();
>>>
>>> does this apply to us? Can't we use a seqlock instead so we do
>>> not need to worry?
>> I'm not familiar with kvm MMU internals, but we do everything under of
>> mmu_lock.
>>
>> Thanks
> I don't think this helps at all.
>
> There's no lock between checking the invalidate counter and
> get user pages fast within vhost_map_prefetch. So it's possible
> that get user pages fast reads PTEs speculatively before
> invalidate is read.
>
> -- 


In vhost_map_prefetch() we do:

         spin_lock(&vq->mmu_lock);

         ...

         err = -EFAULT;
         if (vq->invalidate_count)
                 goto err;

         ...

         npinned = __get_user_pages_fast(uaddr->uaddr, npages,
                                         uaddr->write, pages);

         ...

         spin_unlock(&vq->mmu_lock);

Is this not sufficient?

Thanks

