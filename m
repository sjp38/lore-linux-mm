Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA7C7C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 23:09:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E80D216C4
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 23:09:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E80D216C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A7D7E6B0003; Wed,  8 May 2019 19:09:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2EF56B0005; Wed,  8 May 2019 19:09:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 944CB6B0007; Wed,  8 May 2019 19:09:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 46F386B0003
	for <linux-mm@kvack.org>; Wed,  8 May 2019 19:09:32 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f41so122727ede.1
        for <linux-mm@kvack.org>; Wed, 08 May 2019 16:09:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=79UeR8o+ymrE6lfaFv9K4P5R/+C7ki3AuBoGYxhNSX8=;
        b=K9qrVdXKlNUt2oNX31yD2dexbAe2iI/yzqvcJtA9pmMGbVJCw/5+yug7USNNwMt+jq
         j/EFtj9l9yeoE++Au+6MnVjOA4SXTpOO583jiTR2aaIDoPd5bVKLN8nVUS1x+xiG2WKF
         KZWCb4tSfpYWYjgfEWVpU1xkUzYtwRQDi8DRswJwdCHFSDuBhI7AluhmEhI6gqcmUZgv
         smDx8HWIp/FIdob8ORYySsiM/UA1T8X/Wtpuu4K8LtIFcNyH64bqjvd3cno76wAhBBn3
         y+7oI9Ndq6NqsvQjLVgu4lz2gdtWmNmKQZ7qyRbyt9+bWEQocjINxWiKjzqDcTqNUX0G
         uJfg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.com designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.com
X-Gm-Message-State: APjAAAUCcgRx2SIRHYHDcQt+VakRpXd+HCnms9IPJk+ysGx2f5igwkWy
	1ReQlKEBLkmb+uFpd9Xud+3Ga0RAApWKPJAmYDI9T6KxcUu2rnchiT/8SVzB0vaL5eUY+Jy9nfQ
	Mkqh0UdYv7Kdcavi27m9cVMNXJP9A2TYcOUDDPj96XaHGm0Vlq8u5h7edQR/jywT4Gg==
X-Received: by 2002:a50:9203:: with SMTP id i3mr391301eda.172.1557356971804;
        Wed, 08 May 2019 16:09:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzS/gSOnQPCPZZ/X8/VAO+bwqeGB5PM43jBkiJ13UDqxYzf60Rqv664dJLltSn4V16jwePC
X-Received: by 2002:a50:9203:: with SMTP id i3mr391238eda.172.1557356970789;
        Wed, 08 May 2019 16:09:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557356970; cv=none;
        d=google.com; s=arc-20160816;
        b=R9tEtjSlXgZ0wKp+GXhHOtTI8GObdC1NXqztIwsYpgWYXT0v26sHAaRRIOfaWUzhvy
         xmFFpQ4QSru859CbR1BJJl8BTJapMrO11YkTOMhjFSc0A7XiKSQpIeQEvcL/VCfnC/og
         KtBR0aQIohYYs0drAXEps20kuiEBJ2Zmy4nDnybxmD2mgO2m8AbOZhCaKEKdwpxa0Pu4
         Mq8BcpDfPf2k8NhjIuRWujApYOI3gtJsT4OE75ozVJLJSutR0dXsr7b+D5rqHpvCHZDG
         h9iNhdvDnjtdZjsTo02fBj9VlkfN4aEaqpkgVWJwmIJl3OlSM1cIDvrJBddv1jhELwF5
         4FwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=79UeR8o+ymrE6lfaFv9K4P5R/+C7ki3AuBoGYxhNSX8=;
        b=bCWMCR6ed8xnmME6+iYCsiDv9LUmifoj/ePn/6alzbvoqIcx9jEyarKqJwM2rsgqUW
         BslhSbMX/3eNNFyWY/DakwgC0IK+Fac1dD/t2yfBYqo1fFC/eutwFy+OcP4rzVSwfDF/
         AbmclrPydLa4nQszmjoH93/E78VD1OvnNsBbJXIuXrzPeoGOqBmBfu2AYzfaYeMP+IPh
         VDP6DNWEAUUYJKpTFDfcp6K5iWULYy+OZXvLyATTfxxZfhmXHzQaAvBL9c6WsaVl0aB9
         OlKkChj2IRKA0UWcHPdHc2Q1Ubs4yZNNEsITZYWjiT/Rbyo3WccmFtx1MeQBasHUTLI6
         QAnw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.com designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.com
Received: from smtp.nue.novell.com (smtp.nue.novell.com. [195.135.221.5])
        by mx.google.com with ESMTPS id g23si157394ejm.69.2019.05.08.16.09.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 16:09:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.com designates 195.135.221.5 as permitted sender) client-ip=195.135.221.5;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.com designates 195.135.221.5 as permitted sender) smtp.mailfrom=osalvador@suse.com
Received: from emea4-mta.ukb.novell.com ([10.120.13.87])
	by smtp.nue.novell.com with ESMTP (TLS encrypted); Thu, 09 May 2019 01:09:30 +0200
Received: from [192.168.1.138] (nwb-a10-snat.microfocus.com [10.120.13.201])
	by emea4-mta.ukb.novell.com with ESMTP (TLS encrypted); Thu, 09 May 2019 00:09:14 +0100
Message-ID: <1557356938.3028.35.camel@suse.com>
Subject: Re: [PATCH v2 5/8] mm/memory_hotplug: Drop MHP_MEMBLOCK_API
From: osalvador <osalvador@suse.com>
To: David Hildenbrand <david@redhat.com>, Dan Williams
	 <dan.j.williams@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List
 <linux-kernel@vger.kernel.org>, linux-ia64@vger.kernel.org, linuxppc-dev
 <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, 
 Linux-sh <linux-sh@vger.kernel.org>, Andrew Morton
 <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin
 <pasha.tatashin@soleen.com>, Wei Yang <richard.weiyang@gmail.com>, Joonsoo
 Kim <iamjoonsoo.kim@lge.com>, Qian Cai <cai@lca.pw>, Arun KS
 <arunks@codeaurora.org>, Mathieu Malaterre <malat@debian.org>
Date: Thu, 09 May 2019 01:08:58 +0200
In-Reply-To: <edd762a1-c012-fe05-a72e-2505cd98188a@redhat.com>
References: <20190507183804.5512-1-david@redhat.com>
	 <20190507183804.5512-6-david@redhat.com>
	 <CAPcyv4ge1pSOopfHof4USn=7Skc-UV4Xhd_s=h+M9VXSp_p1XQ@mail.gmail.com>
	 <d83fec16-ceff-2f6f-72e1-48996187d5ba@redhat.com>
	 <CAPcyv4iRQteuT9yESvbUyhp3KVVgTXDiGAo+TwPCM_4f0CzBgg@mail.gmail.com>
	 <edd762a1-c012-fe05-a72e-2505cd98188a@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-05-08 at 09:39 +0200, David Hildenbrand wrote:
> However I haven't really thought it through yet, smalles like that
> could
> as well just be handled by the caller of
> arch_add_memory()/arch_remove_memory() eventually, passing it via
> something like the altmap parameter.
> 
> Let's leave it in place for now, we can talk about that once we have
> new
> patches from Oscar.
Hi David,

I plan to send a new patchset once this is and Dan's are merged,
otherwise I will have a mayhem with the conflicts.

I also plan/want to review this patchset, but time is tight this week.

