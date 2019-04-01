Return-Path: <SRS0=sWz3=SD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B5226C43381
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 08:18:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6184A2084B
	for <linux-mm@archiver.kernel.org>; Mon,  1 Apr 2019 08:18:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6184A2084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0E8FE6B0006; Mon,  1 Apr 2019 04:18:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0987C6B0008; Mon,  1 Apr 2019 04:18:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E79E16B000A; Mon,  1 Apr 2019 04:18:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id C63386B0006
	for <linux-mm@kvack.org>; Mon,  1 Apr 2019 04:18:03 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id d8so7840249qkk.17
        for <linux-mm@kvack.org>; Mon, 01 Apr 2019 01:18:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=IoXH/rpEYuMV6xX+QAj8bnG6/X0/+K0uAx2M8Uj1UPA=;
        b=VJrinyyyVDTBhVuL9diIiyq+ypVNxnr2jlaRexanjzNlcKD8f10bjDeJTsoTWb0esA
         4iXgNr6RHkzrzucYDR9IAX/DST30NKxZtAUeaaUi8Cb2pLSlyCwaufKCJhS/kZUz3NeN
         DUy+c+1jybH+Eo6wIIFjBYe1X0CTlMwNkM0pavNFrxd0OU0w62DArL8G0b/g5b5sPwxw
         1L+gIHpThhYFLW2HMZUFIjInZLm2AeEWLf8cv8GqZHL/ldVSu+2FQzkoMl1QN8MOjax4
         dqSsB+4ftIg1R9LqfyaZfH5hZzqcFGEaqWg3Mj8XKBFg2v8JwTaR24UUfaGBzFSPyPf8
         9xIg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWKBnGxebb9+N3h7giP4xaAnusAHuVuL2kyYIjrEQiEDntCZ865
	MxWtcc1oH/dwscKD/vvNTtvh+YoANiy7vAECkx6rC4VHg4C636jsmXdVsgbf2zHC/gKj5RtyTFT
	lZ7gQ2ix4VjBtyJgZMxvzl1ycOqe2BvObdWTgBwiaeUsSuZX5R7gZue+9DF+cVBL8Vg==
X-Received: by 2002:a05:620a:1429:: with SMTP id k9mr48669025qkj.238.1554106683552;
        Mon, 01 Apr 2019 01:18:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwC9uDpj4EAgXUmiVeC3lkZm2hfh6wFb4CU7tnicFRp9ABDMLBblpljpWKOWOz8vMyWWjiW
X-Received: by 2002:a05:620a:1429:: with SMTP id k9mr48668986qkj.238.1554106682653;
        Mon, 01 Apr 2019 01:18:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554106682; cv=none;
        d=google.com; s=arc-20160816;
        b=J+brX8/5ncWXpFWPL2JdIfMce/Iz75FsOzJva2nD/T8VnWySi+SYsEIyOZO4TOhgP1
         mAyRY3rRjmABM9Zqmp4o0fS7Sq1dmY+BwyeZeRgdI/43M5gSwFuDOyFRNvN4Czuc0ESa
         +PIuWZ9mATMylDTTFaT+9yr4cS8d/1ZW33eqq+1brh/v3ZtLNTh+o6K0WIKRJHb3hml1
         cjBu2y2MrP9EfSVYtO6eUZGxiT6nLSFRHjPGSg6Na0JzFl4PFF8HUfBBQXhsujWTQsi2
         cgOy7TSVjfSfojXjA2v1J/HdoJZmamdvqkkaBrBPw8BhqYn1tjcfDc6CSfnQcydef/AJ
         2z8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=IoXH/rpEYuMV6xX+QAj8bnG6/X0/+K0uAx2M8Uj1UPA=;
        b=jtby9ays92M1oxXMuOz8f1gcydfHDMTzM9ES2ygg9yGIQWf3nDW9DC/sAoxjm0CWmA
         BkhEdJFMiV9kU+a/gme4p2v3qIRp9NvN5ghiMlP0fbOWNru5Ceq7JCkc530gO7jSiumQ
         JduQqB48KlhN0NbFBkqHFYcjo3voFcfXs4lsfknTzpbSq44TJlMh7TY2p9GUvFJKFgew
         09kd7TAJcGRbq7fZXKhCJLj2QOOBENbSdlLpTbZS30/8gpbNfe/n6kM54/ntedqk5h3i
         F++MHxbq6COeRZGDjsXg2yOTSPgCttBuIxsphfFgOTA9D472eosntPCB6mgPBo5Q+exm
         cHuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b23si367267qtq.44.2019.04.01.01.18.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Apr 2019 01:18:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B97613084034;
	Mon,  1 Apr 2019 08:18:01 +0000 (UTC)
Received: from [10.36.117.63] (ovpn-117-63.ams2.redhat.com [10.36.117.63])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 03DC11A918;
	Mon,  1 Apr 2019 08:17:51 +0000 (UTC)
Subject: Re: On guest free page hinting and OOM
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org, pbonzini@redhat.com,
 lcapitulino@redhat.com, pagupta@redhat.com, wei.w.wang@intel.com,
 yang.zhang.wz@gmail.com, riel@surriel.com, dodgen@google.com,
 konrad.wilk@oracle.com, dhildenb@redhat.com, aarcange@redhat.com,
 alexander.duyck@gmail.com
References: <20190329084058-mutt-send-email-mst@kernel.org>
 <f6332928-d6a4-7a75-245d-2c534cf6e710@redhat.com>
 <20190329104311-mutt-send-email-mst@kernel.org>
 <7a3baa90-5963-e6e2-c862-9cd9cc1b5f60@redhat.com>
 <f0ee075d-3e99-efd5-8c82-98d53b9f204f@redhat.com>
 <20190329125034-mutt-send-email-mst@kernel.org>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <fb23fd70-4f1b-26a8-5ecc-4c14014ef29d@redhat.com>
Date: Mon, 1 Apr 2019 10:17:51 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190329125034-mutt-send-email-mst@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.40]); Mon, 01 Apr 2019 08:18:01 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 29.03.19 17:51, Michael S. Tsirkin wrote:
> On Fri, Mar 29, 2019 at 04:45:58PM +0100, David Hildenbrand wrote:
>> On 29.03.19 16:37, David Hildenbrand wrote:
>>> On 29.03.19 16:08, Michael S. Tsirkin wrote:
>>>> On Fri, Mar 29, 2019 at 03:24:24PM +0100, David Hildenbrand wrote:
>>>>>
>>>>> We had a very simple idea in mind: As long as a hinting request is
>>>>> pending, don't actually trigger any OOM activity, but wait for it to be
>>>>> processed. Can be done using simple atomic variable.
>>>>>
>>>>> This is a scenario that will only pop up when already pretty low on
>>>>> memory. And the main difference to ballooning is that we *know* we will
>>>>> get more memory soon.
>>>>
>>>> No we don't.  If we keep polling we are quite possibly keeping the CPU
>>>> busy so delaying the hint request processing.  Again the issue it's a
>>>
>>> You can always yield. But that's a different topic.
>>>
>>>> tradeoff. One performance for the other. Very hard to know which path do
>>>> you hit in advance, and in the real world no one has the time to profile
>>>> and tune things. By comparison trading memory for performance is well
>>>> understood.
>>>>
>>>>
>>>>> "appended to guest memory", "global list of memory", malicious guests
>>>>> always using that memory like what about NUMA?
>>>>
>>>> This can be up to the guest. A good approach would be to take
>>>> a chunk out of each node and add to the hints buffer.
>>>
>>> This might lead to you not using the buffer efficiently. But also,
>>> different topic.
>>>
>>>>
>>>>> What about different page
>>>>> granularity?
>>>>
>>>> Seems like an orthogonal issue to me.
>>>
>>> It is similar, yes. But if you support multiple granularities (e.g.
>>> MAX_ORDER - 1, MAX_ORDER - 2 ...) you might have to implement some sort
>>> of buddy for the buffer. This is different than just a list for each node.
> 
> Right but we don't plan to do it yet.

MAX_ORDER - 2 on x86-64 seems to work just fine (no THP splits) and
early performance numbers indicate it might be the right thing to do. So
it could be very desirable once we do more performance tests.

> 
>> Oh, and before I forget, different zones might of course also be a problem.
> 
> I would just split the hint buffer evenly between zones.
> 

Thinking about your approach, there is one elementary thing to notice:

Giving the guest pages from the buffer while hinting requests are being
processed means that the guest can and will temporarily make use of more
memory than desired. Essentially up to the point where MADV_FREE is
finally called for the hinted pages. Even then the guest will logicall
make use of more memory than desired until core MM takes pages away.

So:
1) Unmodified guests will make use of more memory than desired.
2) Malicious guests will make use of more memory than desired.
3) Sane, modified guests will make use of more memory than desired.

Instead, we could make our life much easier by doing the following:

1) Introduce a parameter to cap the amount of memory concurrently hinted
similar like you suggested, just don't consider it a buffer value.
"-device virtio-balloon,hinting_size=1G". This gives us control over the
hinting proceess.

hinting_size=0 (default) disables hinting

The admin can tweak the number along with memory requirements of the
guest. We can make suggestions (e.g. calculate depending on #cores,#size
of memory, or simply "1GB")

2) In the guest, track the size of hints in progress, cap at the
hinting_size.

3) Document hinting behavior

"When hinting is enabled, memory up to hinting_size might temporarily be
removed from your guest in order to be hinted to the hypervisor. This is
only for a very short time, but might affect applications. Consider the
hinting_size when sizing your guest. If your application was tested with
XGB and a hinting size of 1G is used, please configure X+1GB for the
guest. Otherwise, performance degradation might be possible."

4) Do the loop/yield on OOM as discussed to improve performance when OOM
and avoid false OOM triggers just to be sure.


BTW, one alternatives I initially had in mind was to add pages from the
buffer from the OOM handler only and putting these pages back into the
buffer once freed. I thought this might help for certain memory offline
scenarios where pages stuck in the buffer might hinder offlining of
memory. And of course, improve performance as the buffer is only touched
when really needed. But it would only help for memory (e.g. DIMM) added
after boot, so it is also not 100% safe. Also, same issues as with your
given approach.

-- 

Thanks,

David / dhildenb

