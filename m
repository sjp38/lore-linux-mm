Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6EE01C04E87
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 19:27:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 481EE20851
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 19:27:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 481EE20851
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D9D9C6B0003; Mon, 20 May 2019 15:27:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D4F9E6B0005; Mon, 20 May 2019 15:27:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3DA56B000A; Mon, 20 May 2019 15:27:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9D63F6B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 15:27:37 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id b85so6991707vka.11
        for <linux-mm@kvack.org>; Mon, 20 May 2019 12:27:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Akr9EIj50sab0qWNmVtepYEwki9m6XvkJP1EdaBkhQk=;
        b=INJI71fasSDXbmJwAznK1BXrhdGYvB1En+IWhZeeWhHVuEu6xiF7l/eYH/G+GZjlwj
         bNefzkJnykPmBmZTLR9kzQ0KSn4roCyyw+gY3daWbbwoDCH45uQaTRVkdCR3W/HfeW9M
         929opZk/pflD4DbmoTdSWjxEDg7jWw4NDZTHAj55jsiujZkf3wFrb8DPRokxbRDa2Fre
         N1/SEWnpxGOgzs420/TnhFD9E5Y0BweupfQEXXPB4QiocKR2N2pztDD+iZGDJvePFeou
         DIReFXREO1D/MjD6tD9MmqkiOPdZb2/hnSHubRRyeJAeHPeULmf5rjKzG0m4Quhr6r3m
         1E4w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWJulsiMTBjkt7hU4FiBNiRYfc0zi+xgv4hZHHXmpdPcNL2zUHJ
	YtAGxj6bTlwURxnFa15TNK3NiQhMRaDoNwBdohQ8dByY660CSASbjbmRN4UW301zn69WwYfzImM
	IzvHRRwdsfe39DselOkrGTTov16GZp7mnnxyACpV4icrgOskYrhUdXxRK0vevucluWQ==
X-Received: by 2002:a67:6046:: with SMTP id u67mr15657475vsb.106.1558380457352;
        Mon, 20 May 2019 12:27:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyo+ho2KwINsA7qqfNq5d9FDoznU7XRJnbpu98ad/N1oNkYgvVwxIMz+y2Pohcr5AyBc3EG
X-Received: by 2002:a67:6046:: with SMTP id u67mr15657383vsb.106.1558380456613;
        Mon, 20 May 2019 12:27:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558380456; cv=none;
        d=google.com; s=arc-20160816;
        b=ssmXiVXErwrdQhVvxSMkVX5KS2fqhYgetItyGpOK2sApUfPbKhvJ5lgeSaWnYDdrtb
         yUR+DLrHxpgpt+Zkn9adSjvhLU3u8CMvTfgNOjUdPaco34L3VKEv4P1AyuMJlELJu85d
         yj0bJeDuneJ7afsdyERGXLMcc7tnFMNShzSLpwcv77lhgDjfQN7ZXg34t7CaG7Lo1mTf
         /8S7EZxjEneR211jDdXuj2+IJktuoy8O7x44VZ+E1LQPawpvnzPGJjPR7AdAStQIUqrP
         tsq07czgXMKPwTbNfmJMc5yg7cMKAR6MyIRt1ugiifKmxKrzz9gB0uwKpTr8907SdNPq
         Tv4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=Akr9EIj50sab0qWNmVtepYEwki9m6XvkJP1EdaBkhQk=;
        b=YvylNMsSDNJEJjb5fxw/VuC79+LzMTpDDeI1JWvH1GfAgzLucz00mae8QhP8wp6CU9
         AZMuiz48J9dDH29Mi//xqMgjlKUXjFcNQvE7XU7hELpWFzf3vIndbBYg4mQNeTmW5HT+
         qYMeY+j3UybtgK0EI2tQ16SLWEMZJfTpy/3peNIVHbrAATK/7bp7dL8U6p7wibKQAnqE
         j1PbPy2xsIBdA4tM1+DXgjq51t4peKYaYVUrd2+AaOplaQwqMgxrJhRQAySytJjQ4Bcp
         HrzZIPlQNUHmgfyixfD0ic9Xs5+BDEyiv3wV6XcGh5cPPhaWbtkMZYKGr0NEc8HJVGOb
         RAMw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x20si1220735vso.300.2019.05.20.12.27.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 12:27:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C022985365;
	Mon, 20 May 2019 19:27:25 +0000 (UTC)
Received: from redhat.com (ovpn-125-16.rdu2.redhat.com [10.10.125.16])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id D0781600C6;
	Mon, 20 May 2019 19:27:23 +0000 (UTC)
Date: Mon, 20 May 2019 15:27:21 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, dan.j.williams@intel.com,
	ldufour@linux.vnet.ibm.com
Subject: Re: [PATCH] mm/dev_pfn: Exclude MEMORY_DEVICE_PRIVATE while
 computing virtual address
Message-ID: <20190520192721.GA4049@redhat.com>
References: <1558089514-25067-1-git-send-email-anshuman.khandual@arm.com>
 <20190517145050.2b6b0afdaab5c3c69a4b153e@linux-foundation.org>
 <cb8cbd57-9220-aba9-7579-dbcf35f02672@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <cb8cbd57-9220-aba9-7579-dbcf35f02672@arm.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Mon, 20 May 2019 19:27:35 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 11:07:38AM +0530, Anshuman Khandual wrote:
> On 05/18/2019 03:20 AM, Andrew Morton wrote:
> > On Fri, 17 May 2019 16:08:34 +0530 Anshuman Khandual <anshuman.khandual@arm.com> wrote:
> > 
> >> The presence of struct page does not guarantee linear mapping for the pfn
> >> physical range. Device private memory which is non-coherent is excluded
> >> from linear mapping during devm_memremap_pages() though they will still
> >> have struct page coverage. Just check for device private memory before
> >> giving out virtual address for a given pfn.
> > 
> > I was going to give my standard "what are the user-visible runtime
> > effects of this change?", but...
> > 
> >> All these helper functions are all pfn_t related but could not figure out
> >> another way of determining a private pfn without looking into it's struct
> >> page. pfn_t_to_virt() is not getting used any where in mainline kernel.Is
> >> it used by out of tree drivers ? Should we then drop it completely ?
> > 
> > Yeah, let's kill it.
> > 
> > But first, let's fix it so that if someone brings it back, they bring
> > back a non-buggy version.
> 
> Makes sense.
> 
> > 
> > So...  what (would be) the user-visible runtime effects of this change?
> 
> I am not very well aware about the user interaction with the drivers which
> hotplug and manage ZONE_DEVICE memory in general. Hence will not be able to
> comment on it's user visible runtime impact. I just figured this out from
> code audit while testing ZONE_DEVICE on arm64 platform. But the fix makes
> the function bit more expensive as it now involve some additional memory
> references.

A device private pfn can never leak outside code that does not understand it
So this change is useless for any existing users and i would like to keep the
existing behavior ie never leak device private pfn.

Cheers,
Jérôme

