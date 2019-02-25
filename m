Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8833BC10F00
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 21:14:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 434052146F
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 21:14:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 434052146F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E279A8E0005; Mon, 25 Feb 2019 16:14:26 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD86B8E0004; Mon, 25 Feb 2019 16:14:26 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA01A8E0005; Mon, 25 Feb 2019 16:14:26 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9AB4C8E0004
	for <linux-mm@kvack.org>; Mon, 25 Feb 2019 16:14:26 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id m37so10376480qte.10
        for <linux-mm@kvack.org>; Mon, 25 Feb 2019 13:14:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=CqNDToLpCJDIRJoWRt/hrt5tJUNrn2ICUnR3vjEsZA0=;
        b=rKRPkXwXkvNDRaD9/zRymIl93y/IUkDkvdV4yXtDWJWLaTY2b4JNHUWgaguLRPHJje
         sPt+hT/2Dv8dGT55c40q7qgdYXf+9zwBi2gXU/K0gLd+hzpkTRBbY+J3EbCqrGs2UN0+
         wtIBfklSd2nCTGkOBSM3GknKXq0WRjVXEsg9WBGb6Lr1xjSMj0fmmSmTK3RSb5jvmMtt
         XyB2CurYP1DaMDHJ1ymNvFwHNjAunkDoqoUFPyZfqolcF8lO4AItrHNIfJq99Uq5s1or
         c/sWDlKF9NWiQ1XcuwZ0ZFNzKal91ufJ6egcMswer953JrnOBRq3jk5nsc2EHvusr4+l
         Lm7g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubnINWdO5Dh30GkkYlryzEAkjKh9/BMSf+oiNYh9FxHBL8h25BD
	N4mQjDiz52xfaC8nVvKQ4qjNS5X6C4XkIunC6VXfyb+c6uIpCZcxDEp4+Cu0yZgs/8y2K4qcW18
	+/W1thzjUhTZBeDnwMMUOQXJgA0dNdlbT7Su7t/pBzjE+nv/sFl2XwA6o18Xk7EGmQQ==
X-Received: by 2002:ac8:393a:: with SMTP id s55mr15579857qtb.70.1551129266343;
        Mon, 25 Feb 2019 13:14:26 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbubkTyoJl/x3ONhEBw34xPwh9lfpFdwnR5e8/8KMhCVselMgpByr7/MrjZf1JBON8D56F9
X-Received: by 2002:ac8:393a:: with SMTP id s55mr15579796qtb.70.1551129265312;
        Mon, 25 Feb 2019 13:14:25 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551129265; cv=none;
        d=google.com; s=arc-20160816;
        b=0MH5pp4XS0e60sfblnw8aj/4n+qWFhY8V1mqbkpiOL7mKxQI+CK74Fpz+nbmmY+01K
         wEZEO7m8+kzUIoouKxvmnNPuNjsdRllbKpYMp0XWseSPL+Yp2/Vx8+4e9tbmIEK441X9
         ktvWWuXNCmp+Sxfb7uD308K8HOhrpZnNSt/YYQX45r2bsw7gktzq6rED8lTlGon0RM8F
         BrbJZy59kEtqzwxKWsLmF2RyoqrB6MDF9B0+rUyBeyp89QhK5EpEMH8mNKBEGKhMl4vB
         xBSUwRMdAKldYXriZ4sMW0qtUl/H33y+U13k2f/lAJBaysOm4+an5v5UA9/EDE6wsdcl
         GnYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=CqNDToLpCJDIRJoWRt/hrt5tJUNrn2ICUnR3vjEsZA0=;
        b=h8z22EJDZTXQNIvqXog4cSxTTdGC9JQEeh7h6oq8vGaQzdP/Hn+okmy8gefH61X4N5
         gtiLDUiK1DlMwaxYezDSDVHgBnudooDvfgiaWq4I4/g/MQzI6hkSZ/NI6FDt6OxFjqRU
         CxWRS7kClxgbYHPZYyzOQkg9N9Z3l0iXabwjphC7U3YaW1H0GY8FTg1T+myWitgTlgYr
         cOQIheqP8IHyFH3GcDAR6wX4DQTMzFrBkNsr35l/lGz/1uS3r8ohHV28QueqlrDADkrv
         IOTFVgWWeFr1X+MIedD9w4HjdrrW0iUuILvlCHkuIKC3LcHEEepJFi5Y/EjtqBYp5osj
         UQ+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h29si1032377qvc.103.2019.02.25.13.14.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Feb 2019 13:14:25 -0800 (PST)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 675C5316499B;
	Mon, 25 Feb 2019 21:14:24 +0000 (UTC)
Received: from [10.36.116.61] (ovpn-116-61.ams2.redhat.com [10.36.116.61])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 983995D9D1;
	Mon, 25 Feb 2019 21:14:22 +0000 (UTC)
Subject: Re: [PATCH v2] mm/memory-hotplug: Add sysfs hot-remove trigger
To: Michal Hocko <mhocko@kernel.org>, Robin Murphy <robin.murphy@arm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 gregkh@linuxfoundation.org, rafael@kernel.org, akpm@linux-foundation.org,
 osalvador@suse.de
References: <49ef5e6c12f5ede189419d4dcced5dc04957c34d.1549906631.git.robin.murphy@arm.com>
 <20190212083310.GM15609@dhcp22.suse.cz>
 <faca65d7-6d4b-7e4f-5b36-4fdf3710b0e3@arm.com>
 <20190212151146.GA15609@dhcp22.suse.cz>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <1ea6a40d-be86-6ccc-c728-fa8effbd5a8e@redhat.com>
Date: Mon, 25 Feb 2019 22:14:21 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190212151146.GA15609@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Mon, 25 Feb 2019 21:14:24 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 12.02.19 16:11, Michal Hocko wrote:
> On Tue 12-02-19 14:54:36, Robin Murphy wrote:
>> On 12/02/2019 08:33, Michal Hocko wrote:
>>> On Mon 11-02-19 17:50:46, Robin Murphy wrote:
>>>> ARCH_MEMORY_PROBE is a useful thing for testing and debugging hotplug,
>>>> but being able to exercise the (arguably trickier) hot-remove path would
>>>> be even more useful. Extend the feature to allow removal of offline
>>>> sections to be triggered manually to aid development.
>>>>
>>>> Since process dictates the new sysfs entry be documented, let's also
>>>> document the existing probe entry to match - better 13-and-a-half years
>>>> late than never, as they say...
>>>
>>> The probe sysfs is quite dubious already TBH. Apart from testing, is
>>> anybody using it for something real? Do we need to keep an API for
>>> something testing only? Why isn't a customer testing module enough for
>>> such a purpose?
>>
>> From the arm64 angle, beyond "conventional" servers where we can hopefully
>> assume ACPI, I can imagine there being embedded/HPC setups (not all as
>> esoteric as that distributed-memory dRedBox thing), as well as virtual
>> machines, that are DT-based with minimal runtime firmware. I'm none too keen
>> on the idea either, but if such systems want to support physical hotplug
>> then driving it from userspace might be the only reasonable approach. I'm
>> just loath to actually document it as anything other than a developer
>> feature so as not to give the impression that I consider it anything other
>> than a last resort for production use.
> 
> This doesn't sound convicing to add an user API.
> 
>> I do note that my x86 distro kernel
>> has ARCH_MEMORY_PROBE enabled despite it being "for testing".
> 
> Yeah, there have been mistakes done in the API land & hotplug in the
> past.
> 
>>> In other words, why do we have to add an API that has to be maintained
>>> for ever for a testing only purpose?
>>
>> There's already half the API being maintained, though, so adding the
>> corresponding other half alongside it doesn't seem like that great an
>> overhead, regardless of how it ends up getting used.
> 
> As already said above. The hotplug user API is not something to follow
> for the future development. So no, we are half broken let's continue is
> not a reasonable argument.
> 
>> Ultimately, though,
>> it's a patch I wrote because I needed it, and if everyone else is adamant
>> that it's not useful enough then fair enough - it's at least in the list
>> archives now so I can sleep happy that I've done my "contributing back" bit
>> as best I could :)
> 
> I am not saing this is not useful. It is. But I do not think we want to
> make it an official api without a strong usecase. And then we should
> think twice to make the api both useable and reasonable. A kernel module
> for playing sounds like more than sufficient.
> 

I'm late for the party, I consider this very useful for testing, but I
agree that this should not be an official API.

The memory API is already very messed up. We have the "removable"
attribute which does not mean that memory is removable. It means that
memory can be offlined and eventually "unplugged/removed" if the HW
supports it (e.g. a DIMM, otherwise it will never go).

You would be introducing "remove", which would sometimes not work when
"removable" indicates "true" (because your API only works if memory has
already been offlined). I would much rather want to see some of the mess
get cleaned up than new stuff getting added that might not be needed
besides for testing. Yes, not your fault, but an API that keeps getting
more confusing.

I am really starting to strongly dislike the "removable" attribute.

-- 

Thanks,

David / dhildenb

