Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8D63C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 09:07:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 97547208CB
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 09:07:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 97547208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 489076B0003; Wed, 19 Jun 2019 05:07:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 43B4F8E0002; Wed, 19 Jun 2019 05:07:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 301828E0001; Wed, 19 Jun 2019 05:07:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0446B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 05:07:35 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id a18so15066784qtj.18
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:07:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=ktjMYymeAJyOKpas1BxeSxj+UueHLwYkYaavUnAGu9A=;
        b=HCnLknYJCi5ZJtspWLyUQivvoOoLL6pWO6or2xuXO8NMoZNp3UcvK8J0M8WkklRmcI
         lgspazTqyTsXAg/wCFBkX+3sk7laoyz6IJFs4V9nBBaYcu5Deeh+EvnJ1QPtk9cW2sVt
         ODzlbYqajq6hqOL4HPoECn/sD7zlaA4AtW9EMy+HS39wLI+9+/yXIwwn1T8wLh+NsLPh
         Tpj8l9+MHuLXCdbGJcl5ORnkiYfTfjoj4wdzHiYzAKZzlpOuyyaIzcpP/ptgYyF8Mzlb
         JyKrUiIt7n91aPl0rJ5WfSdPCtyDKIEdg3lURu1aCFFN7NdFR+G1qZWlqrWzOcrohqMd
         4aGQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAX4WAb+QKGyxCLsEGWpPYYB22b2RCBTAmnWqXDOU0stOaLWicar
	p8Svh/FzKzeU6TXC7dPGXKAHjJiKb//nve5QqfXyAY7mlodx13orIvvVSihXW8hkSfAodldt2wx
	jnyWKyjQBbCgxTBDQiH0USpo7aSVkyz7MnwAEqIZPPs3rw/l5FEXMxmKh46wpiQWJJA==
X-Received: by 2002:ac8:374b:: with SMTP id p11mr101394851qtb.316.1560935254844;
        Wed, 19 Jun 2019 02:07:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzn4STeN0WFQFFL1VeAgBE4MFXJIcVdeOlxna5jFm219tv1YdX3MHup9ErmwgsYspBwSRP8
X-Received: by 2002:ac8:374b:: with SMTP id p11mr101394802qtb.316.1560935254245;
        Wed, 19 Jun 2019 02:07:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560935254; cv=none;
        d=google.com; s=arc-20160816;
        b=I+U9zmi3CBFUJsnnUkiY7FIXKHqECms20xk2ktnSoHsakrPS2sdAQhYYhWFmklmrNu
         flAh+p9haM5xxKESWQiSo/+2KQw/5mnVoOLFP6OeJNdmEOu18ijx9+Rpm4WzjndBCJ5y
         QY1oHHvg+01TdYREAP7bJFO3i4xN80EOF1Zl7H2gw5AZUG6BV6YIxB0DMt5TMN9qeYZP
         /CWAuhfpLDnRmUD5VeArZ2IP+BwWXRHA4FA/X66S3PJ8tLO2D/m6Q2+SPycEDFpu2S/H
         L9g8W+Qh6Rz7XyG/ba+KCtiLiTC3c72vOAVTZk5+EElg3rwblQJEJPkGZ/8fm0pS/P2u
         tpoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=ktjMYymeAJyOKpas1BxeSxj+UueHLwYkYaavUnAGu9A=;
        b=cUMQgRF3ykWD6loH2saxiWHZxeypzQKq1GBGqQLa39gxT4ZMIJpVKSX8DV/sWFJWCd
         cnuvXIUJK3CfS6oIPI4xChtQqf5ULnZLd2aDKHE2GKEyK9t08RYRDOHf1JPCn/wt9d4I
         CfBDZ77cPoS3WYH4rXMFyCCtvbBhpM7RwkfgE1JHk1ljdEo/6uexR0Pj8da7vPGXGtWn
         FUyRRUL8P5oUQQPJcwY6ELSY3rLBI6JLnmIJr02G1zNa9w7RmSoqvz9LsVXFjl/w2pcD
         Vhsa7Ea6cMLksVWIk836fTnuDmZr8YRivjjTs5Kso7OM5vnYOHelbLzO0X2mxmDD+Kku
         RUew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k129si12239140qkc.35.2019.06.19.02.07.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 02:07:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 5220E223872;
	Wed, 19 Jun 2019 09:07:33 +0000 (UTC)
Received: from [10.36.117.229] (ovpn-117-229.ams2.redhat.com [10.36.117.229])
	by smtp.corp.redhat.com (Postfix) with ESMTP id D319C19C6A;
	Wed, 19 Jun 2019 09:07:31 +0000 (UTC)
Subject: Re: [PATCH v2] mm/sparse: set section nid for hot-add memory
To: Michal Hocko <mhocko@suse.com>
Cc: Oscar Salvador <osalvador@suse.de>,
 Wei Yang <richardw.yang@linux.intel.com>, linux-mm@kvack.org,
 akpm@linux-foundation.org, anshuman.khandual@arm.com
References: <20190618005537.18878-1-richardw.yang@linux.intel.com>
 <20190619062330.GB5717@dhcp22.suse.cz> <20190619075347.GA22552@linux>
 <a52a196a-9900-0710-a508-966e725eae03@redhat.com>
 <20190619090405.GJ2968@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <361b8e87-7c30-c492-cfa9-e068c5f55bf9@redhat.com>
Date: Wed, 19 Jun 2019 11:07:30 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190619090405.GJ2968@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Wed, 19 Jun 2019 09:07:33 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 19.06.19 11:04, Michal Hocko wrote:
> On Wed 19-06-19 10:51:47, David Hildenbrand wrote:
>> On 19.06.19 09:53, Oscar Salvador wrote:
>>> On Wed, Jun 19, 2019 at 08:23:30AM +0200, Michal Hocko wrote:
>>>> On Tue 18-06-19 08:55:37, Wei Yang wrote:
>>>>> In case of NODE_NOT_IN_PAGE_FLAGS is set, we store section's node id in
>>>>> section_to_node_table[]. While for hot-add memory, this is missed.
>>>>> Without this information, page_to_nid() may not give the right node id.
>>>>
>>>> Which would mean that NODE_NOT_IN_PAGE_FLAGS doesn't really work with
>>>> the hotpluged memory, right? Any idea why nobody has noticed this
>>>> so far? Is it because NODE_NOT_IN_PAGE_FLAGS is rare and essentially
>>>> unused with the hotplug? page_to_nid providing an incorrect result
>>>> sounds quite serious to me.
>>>
>>> The thing is that for NODE_NOT_IN_PAGE_FLAGS to be enabled we need to run out of
>>> space in page->flags to store zone, nid and section. 
>>> Currently, even with the largest values (with pagetable level 5), that is not
>>> possible on x86_64.
>>> It is possible though, that somewhere in the future, when the values get larger
>>> (e.g: we add more zones, NODE_SHIFT grows, or we need more space to store
>>> the section) we finally run out of room for the flags though.
>>>
>>> I am not sure about the other arches though, we probably should audit them
>>> and see which ones can fall in there.
>>>
>>
>> I'd love to see NODE_NOT_IN_PAGE_FLAGS go.
> 
> NODE_NOT_IN_PAGE_FLAGS is an implementation detail on where the
> information is stored.

Yes and no. Storing it per section clearly doesn't allow storing node
information on smaller granularity, like storing in page->flags does.

So no, it is not only an implementation detail.

I cannot say how much it is really needed now but
> I can see there will be a demand for it in a longer term because
> page->flags space is scarce and very interesting storage. So I do not
> see it go away I am afraid.
Depends on how performance-critical pfn_to_nid() is. I can't tell.

-- 

Thanks,

David / dhildenb

