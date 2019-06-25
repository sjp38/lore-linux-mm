Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2B84C48BD6
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 18:13:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E32B2080C
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 18:13:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E32B2080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A51F6B0005; Tue, 25 Jun 2019 14:13:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2571C8E0003; Tue, 25 Jun 2019 14:13:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 11D358E0002; Tue, 25 Jun 2019 14:13:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id E58136B0005
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 14:13:07 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id v58so21987239qta.2
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 11:13:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=87nHfvMQIK3vzGnrthGYRPSxqqg/R2ZWrgXo/9nW9SQ=;
        b=YeLLqf9FpTAgYa3rMUtwS50nWmgRsnirJj/WifweHdI6n/7kK1Ofu2PNOCxGNpkaxi
         gYU8TTiXT79kqz60Rg0F+5wUsIGgeUvOgjS7Crlb59Tl6RCDjqsogQzjEVI2i7ThNHso
         BZNDV5Sd38Giy88V9KWKn1zrzWl/pDeKLQ5rZJDznpsqzJE/nQq0wtHU5Jc0GJIDo4HL
         8QvNG9HT9TejborzXT9+ghQcPe4g/0DZ6xbznGIyNP/o3Vi8YVIkFyhS65+iDH5NeBLw
         FYTZs3xCxRBK2YCTFaWV+55biB6wAddR8J/NnskZY/m033Ih8GIQDkPak95CqJkoN4yk
         WdQw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU4wdir//soS3JrVuMDNcG0AOw/Egumuv61EgQ0n6Soyz2jPJg/
	dsHpeIqvG2ckoszRGbNGOo5WT4pfxXGxec6RP8yePciLNBTnlOpHkQIG7uhXrTpvED6GD5gu14y
	C/8DUQtYBuAOwydUfRVSOdXqq3iAn4pHyuY0neOGF+Z8q4srXG8VjnjMc/cWiSqaCuA==
X-Received: by 2002:ac8:38c5:: with SMTP id g5mr138360721qtc.299.1561486387709;
        Tue, 25 Jun 2019 11:13:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwgpv5W3l9pxoXW4Vq9i4KbcN8qFEk3gRESoPtrM1bQ8Pp9SyeD9QIRo7Po+gVsM4ojRSrN
X-Received: by 2002:ac8:38c5:: with SMTP id g5mr138360669qtc.299.1561486387102;
        Tue, 25 Jun 2019 11:13:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561486387; cv=none;
        d=google.com; s=arc-20160816;
        b=ORTdIpwwQKxqe/14G30+Nlq1OQQfgTqk1MshFG15LVfliIE+6bXM0mMXcHBH3iUSqa
         7+W5Sx9Jo5XWkwALHjDJMniDjQx4B7bNITOFGSt+a8Z56b2r4t9f2dC7lSHkkZSHCOrk
         Mj64863R5SAJBFGVOXSU4kZjuqs5y9wBY70KKMWybERxa198zGbyvFCjUg4Bsd/WqDTA
         ksnkNbQm9vyUvBlGnb48nnYAXPBe+fI1pfOq9fMllByPkZ+NykzaH5JUR5Ftf3P4z5TM
         CLdIp97BjYoQw9aciNEnc0bL4Oy4HViT4FmOkxXTP+xZenVPOwFRYCYcVhZIqkjJ0Iym
         yGsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=87nHfvMQIK3vzGnrthGYRPSxqqg/R2ZWrgXo/9nW9SQ=;
        b=USakbueZPD5MMhiak31g+wD134e+feT2lKWhsSpF1ivgmjEJX5DX4JzyiVvPCVqcML
         qHmOosV3dW7jS1MTZfIQYm/W+vSX9JRcSMR6fOmVHuufx+CVlqDKJp95jLs+czUS57/g
         bgiEsJuQ7hZ2rv9btxn2SPiq2K1YG0Q3qCYBMdpuAcoatPA9PUTJDswbWI0NbRD2Wn2O
         Zd/l8ek67SXSajDavUE6RjOtrqDvmF76F3MjqJR6f/zM9HYRzidmrY1ohIMDLw5+k9jN
         3ItYdwtJyfhXBM9Mv/xPlmoyA/HWQA7cCXh/i932O9RRuiHyg+fFFsVWvb6bEn753zku
         2pIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id v54si11192455qvc.169.2019.06.25.11.13.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 11:13:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6049630F1BAE;
	Tue, 25 Jun 2019 18:12:58 +0000 (UTC)
Received: from [10.36.116.44] (ovpn-116-44.ams2.redhat.com [10.36.116.44])
	by smtp.corp.redhat.com (Postfix) with ESMTP id AF0EB19936;
	Tue, 25 Jun 2019 18:12:44 +0000 (UTC)
Subject: Re: [PATCH v1 0/6] mm / virtio: Provide support for paravirtual waste
 page treatment
To: Alexander Duyck <alexander.duyck@gmail.com>,
 Dave Hansen <dave.hansen@intel.com>
Cc: Nitesh Narayan Lal <nitesh@redhat.com>, kvm list <kvm@vger.kernel.org>,
 "Michael S. Tsirkin" <mst@redhat.com>, LKML <linux-kernel@vger.kernel.org>,
 linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>,
 Yang Zhang <yang.zhang.wz@gmail.com>, pagupta@redhat.com,
 Rik van Riel <riel@surriel.com>,
 Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, lcapitulino@redhat.com,
 wei.w.wang@intel.com, Andrea Arcangeli <aarcange@redhat.com>,
 Paolo Bonzini <pbonzini@redhat.com>, dan.j.williams@intel.com,
 Alexander Duyck <alexander.h.duyck@linux.intel.com>
References: <20190619222922.1231.27432.stgit@localhost.localdomain>
 <ff133df4-6291-bece-3d8d-dc3f12f398cf@redhat.com>
 <8fea71ba-2464-ead8-3802-2241805283cc@intel.com>
 <CAKgT0UdAj4Kq8qHKkaiB3z08gCQh-jovNpos45VcGHa_v5aFGg@mail.gmail.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <19accd94-7f0b-b940-fee5-5f003f658f1c@redhat.com>
Date: Tue, 25 Jun 2019 20:12:43 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <CAKgT0UdAj4Kq8qHKkaiB3z08gCQh-jovNpos45VcGHa_v5aFGg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Tue, 25 Jun 2019 18:13:05 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 25.06.19 19:00, Alexander Duyck wrote:
> On Tue, Jun 25, 2019 at 7:10 AM Dave Hansen <dave.hansen@intel.com> wrote:
>>
>> On 6/25/19 12:42 AM, David Hildenbrand wrote:
>>> On 20.06.19 00:32, Alexander Duyck wrote:
>>> I still *detest* the terminology, sorry. Can't you come up with a
>>> simpler terminology that makes more sense in the context of operating
>>> systems and pages we want to hint to the hypervisor? (that is the only
>>> use case you are using it for so far)
>>
>> It's a wee bit too cute for my taste as well.  I could probably live
>> with it in the data structures, but having it show up out in places like
>> Kconfig and filenames goes too far.
>>
>> For instance, someone seeing memory_aeration.c will have no concept
>> what's in the file.  Could we call it something like memory_paravirt.c?
>>  Or even mm/paravirt.c.
> 
> Well I couldn't come up with a better explanation of what this was
> doing, also I wanted to avoid mentioning hinting specifically because
> there have already been a few series that have been committed upstream
> that reference this for slightly different purposes such as the one by
> Wei Wang that was doing free memory tracking for migration purposes,
> https://lkml.org/lkml/2018/7/10/211.

That one we referred to rather as "free page reporting".

> 
> Basically what we are doing is inflating the memory size we can report
> by inserting voids into the free memory areas. In my mind that matches
> up very well with what "aeration" is. It is similar to balloon in
> functionality, however instead of inflating the balloon we are
> inflating the free_list for higher order free areas by creating voids
> where the madvised pages were.
> 
>> Could you talk for a minute about why the straightforward naming like
>> "hinted/unhinted" wasn't used?  Is there something else we could ever
>> use this infrastructure for that is not related to paravirtualized free
>> page hinting?
> 
> I was hoping there might be something in the future that could use the
> infrastructure if it needed to go through and sort out used versus
> unused memory. The way things are designed right now for instance
> there is only really a define that is limiting the lowest order pages
> that are processed. So if we wanted to use this for another purpose we
> could replace the AERATOR_MIN_ORDER define with something that is
> specific to that use case.


I'd still vote to call this "hinting" in some form. Whenever a new use
case eventually pops up, we could generalize this approach. But well,
that's just my opinion :)


-- 

Thanks,

David / dhildenb

