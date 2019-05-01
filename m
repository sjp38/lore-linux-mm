Return-Path: <SRS0=L4L0=TB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8B5AC43219
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 14:49:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 68AFB208C3
	for <linux-mm@archiver.kernel.org>; Wed,  1 May 2019 14:49:52 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 68AFB208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 15D8E6B0003; Wed,  1 May 2019 10:49:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10E4A6B0005; Wed,  1 May 2019 10:49:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ECAAC6B0006; Wed,  1 May 2019 10:49:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id C57F06B0003
	for <linux-mm@kvack.org>; Wed,  1 May 2019 10:49:51 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id d39so12205362qtc.15
        for <linux-mm@kvack.org>; Wed, 01 May 2019 07:49:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=hX5aR2jjqrI2dhs9uTT8wfEMkfeebtgi9I6H1ZsXtJs=;
        b=ppkyX42Y6rZtJd10ZqW2wfWkZjE8cixoSsvj0GSuTHw8TijiRh/zKHR2qsgqjH+YBE
         XU5P4O9uSvZeM07foogHZWLKsocnz0c/0qVvr2+3a6UjCkU4cbjgm4R1QgVLZDz3qAlh
         xmsGFiaFgt3NMHfc+aGCBlQ115unpt337mxCVm4dmmV7DQKGs96uQUPr5IMvk0PMu4KF
         Dz9n4FajKKOVGbJyCNUex4qz17x6lk7Bu+gYz1dCgNX1773YZlYbZUW8SwQDLWeOCZ2z
         xs2psVhfk3FjKuXcaHqneV4mCsE0o7k/8HVq7e3C6Sk/0i5YX19CXXEnOPHhgtKtPCZW
         iGlg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXyCbMmghYOIj7oDMnwfGX0s8HmD/Ha3zEsdTpveoec5S5XeeVh
	c20iFSyEBg3uDQBENDtCZvWULWBRnF/NF3nFWkkDduXp/Gc9dE2KpfpXt87UjAhINp7H6NLPqvn
	4g98hbZ1k246EXcqpsXokTVeDqtW4L8PWIalpvPfGCo2xL9UI8qFUbZmzWzASXg/RIA==
X-Received: by 2002:ac8:2df3:: with SMTP id q48mr25667252qta.354.1556722191532;
        Wed, 01 May 2019 07:49:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyOFAUZCbkjW6vwpnqtDRcz2n5Blbjng6bGKNzSmyGhnwozx5Cfw0VuNjjvNslwf0OYAnY5
X-Received: by 2002:ac8:2df3:: with SMTP id q48mr25667210qta.354.1556722190852;
        Wed, 01 May 2019 07:49:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556722190; cv=none;
        d=google.com; s=arc-20160816;
        b=gTtLdfruD71XxjenNMia96Jo9hJKadyJRkmu0D424bErfAXhZEJSxIQ2JaumQViTe9
         4TUnUKhK5mGInPhcghAXOI7F4wpNVa9R2/pdKyhNiQlwUabsf+517CRcx6pF+lX4zpSC
         mIU3ZfGp1bTT2q/QtGiW16FFIWugBHBW+kaXlN3TDSNrybHO/scpVf62Nmpn/N9KI3LB
         eg8+Yv9ySSc9By7zeCt5u6IJIhVg/Lli2+uN9KP0kPoc6Frf9VkGkKnoZZNGmeiS7Ck9
         A/fsTnrlOhgR0CnQLoRv39fkPXyELxU8+L8txGGD/rer3lt2JppFI5ho5Mr36IMB44kH
         vRrQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=hX5aR2jjqrI2dhs9uTT8wfEMkfeebtgi9I6H1ZsXtJs=;
        b=L4wdtNeSzv5IyYl+xag1wjMp8somWFMu3jj2Ot/YOAtfuDOEqGfHwltyvd/Wd0/Pou
         N4Lwt0fNHEyj/vx4z5a0N7FL0uOzhpgo1r052cA7qn/8+OfbuatEMUI936kbzQhfkEj5
         7iQo5TrUpclfbZqn/Xian04iFunWYuqAmGCEe3mQofNEEfZNrJw5zqhgE/OGnp1DMBXi
         hR+1ffaL5MdA2EZdgc6n3qplljKlg/8utNH/klbcVD13r+I5GKWS/9XvkXYkZ3rNF07N
         oPPx8IScrOKb2NB3PJVjUsjL5JP15ah95XcyYk4Z9GQU86VBzcx+G7Ncu6FWiaNbX2P9
         WoCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id t2si3922425qkd.225.2019.05.01.07.49.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 May 2019 07:49:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6AA7EC024915;
	Wed,  1 May 2019 14:49:49 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-85.bos.redhat.com [10.18.17.85])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E30A710021B4;
	Wed,  1 May 2019 14:49:44 +0000 (UTC)
Subject: Re: [RFC PATCH v9 03/13] mm: Add support for eXclusive Page Frame
 Ownership (XPFO)
To: Khalid Aziz <khalid.aziz@oracle.com>, Ingo Molnar <mingo@kernel.org>
Cc: juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de,
 keescook@google.com, konrad.wilk@oracle.com,
 Juerg Haefliger <juerg.haefliger@canonical.com>,
 deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com,
 dwmw@amazon.co.uk, andrew.cooper3@citrix.com, jcm@redhat.com,
 boris.ostrovsky@oracle.com, iommu@lists.linux-foundation.org,
 x86@kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 linux-security-module@vger.kernel.org, Khalid Aziz <khalid@gonehiking.org>,
 Linus Torvalds <torvalds@linux-foundation.org>,
 Andrew Morton <akpm@linux-foundation.org>,
 Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>,
 Peter Zijlstra <a.p.zijlstra@chello.nl>, Dave Hansen <dave@sr71.net>,
 Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>,
 Arjan van de Ven <arjan@infradead.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>
References: <cover.1554248001.git.khalid.aziz@oracle.com>
 <f1ac3700970365fb979533294774af0b0dd84b3b.1554248002.git.khalid.aziz@oracle.com>
 <20190417161042.GA43453@gmail.com>
 <e16c1d73-d361-d9c7-5b8e-c495318c2509@oracle.com>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <35c4635e-8214-7dde-b4ec-4cb266b2ea10@redhat.com>
Date: Wed, 1 May 2019 10:49:44 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <e16c1d73-d361-d9c7-5b8e-c495318c2509@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Wed, 01 May 2019 14:49:50 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 11:34:04AM -0600, Khalid Aziz wrote:
> diff --git a/Documentation/admin-guide/kernel-parameters.txt
b/Documentation/admin-guide/kernel-parameters.txt

> index 858b6c0b9a15..9b36da94760e 100644
> --- a/Documentation/admin-guide/kernel-parameters.txt
> +++ b/Documentation/admin-guide/kernel-parameters.txt
> @@ -2997,6 +2997,12 @@
>
>      nox2apic    [X86-64,APIC] Do not enable x2APIC mode.
>
> +    noxpfo        [XPFO] Disable eXclusive Page Frame Ownership (XPFO)
> +            when CONFIG_XPFO is on. Physical pages mapped into
> +            user applications will also be mapped in the
> +            kernel's address space as if CONFIG_XPFO was not
> +            enabled.
> +
>      cpu0_hotplug    [X86] Turn on CPU0 hotplug feature when
>              CONFIG_BO OTPARAM_HOTPLUG_CPU0 is off.
>              Some features depend on CPU0. Known dependencies are:

Given the big performance impact that XPFO can have. It should be off by
default when configured. Instead, the xpfo option should be used to
enable it.

Cheers,
Longman

