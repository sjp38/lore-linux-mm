Return-Path: <SRS0=AiS9=SS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	HTML_MESSAGE,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8328C282DA
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 14:55:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51C3020873
	for <linux-mm@archiver.kernel.org>; Tue, 16 Apr 2019 14:55:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51C3020873
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=inria.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D34AD6B02AF; Tue, 16 Apr 2019 10:55:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE24C6B02B0; Tue, 16 Apr 2019 10:55:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BAC346B02B1; Tue, 16 Apr 2019 10:55:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6A26C6B02AF
	for <linux-mm@kvack.org>; Tue, 16 Apr 2019 10:55:23 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id e6so19317259wrs.1
        for <linux-mm@kvack.org>; Tue, 16 Apr 2019 07:55:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language;
        bh=qm4Vojrg8FZVrLar+RG6E7oBWC3PYekGCUK4aKWGGP4=;
        b=pI7vziT5H4YDxYdFHUwmcF+39TfXH5mLoilSlkMATUtdVv14Z9++qCXTWuJVLI6y0L
         zGveE7DSj7BO5c5aeEGTz3ELlGa1P0Q4S66SPMaBWuzyzvaGtPSIAFMCbkRjttdCZyiV
         9mVFUjh2rI7sHEfJJ+Obz6v/KIv6yBy4H1Fs1AdRBo7ZST2CQYoIyH8hmwP0+v9lWGGb
         nXqjT8ClwDEFFIoLk7EytLZifKa8UDofJLwsIMgP1s7Fbv1Q+mBRaHx/Ph/fNnXmtqWw
         ONwck1UhFbzK1NUh0Z0wVQUk2yeKlGGZs6qwEThSE4XpkgXJ1oBtaAZSyJQW0Flz9UdI
         Xyeg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.83 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
X-Gm-Message-State: APjAAAV6Cj4Sm0cbA/TIlK9gUPiZuZUfICYBveSQHyZPcukQKh+v7rA3
	G4b6QPxmnnq1IXfNJs1CSJGdtZg6D9u6nmFU2IeYhLzHvqjuaBnKaazTNEfIWRasRjS7pSnMRry
	8AbI51+lDet4p2c4Vx/4csxmKKABubX+25kdf3vxsvu23i7PHhSzOEEL1STZs80ZznQ==
X-Received: by 2002:a05:6000:14a:: with SMTP id r10mr32186269wrx.107.1555426523018;
        Tue, 16 Apr 2019 07:55:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwlwmAHKltMuVQPAPGF6tYBy37+KqpHFTmrScC6tnGFvh8c8lJ67VG8/gj4EQcIdYZwi60n
X-Received: by 2002:a05:6000:14a:: with SMTP id r10mr32186211wrx.107.1555426522156;
        Tue, 16 Apr 2019 07:55:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555426522; cv=none;
        d=google.com; s=arc-20160816;
        b=tDm3LS1Q9OR7GMGvmYPpaRy7A87Q/+v6rABFLC2gpKRx9PrxpGxcTobUT4EPefK15d
         s5NJFi6ftaMfogXl533EiTBUCg4hdrdpLspekdpzt3VFMLXp+asCPA7o1BRw4VL/wZwo
         KBKMRgMqC/5FAoUq9KPr8YbI54wYrZGnjrCHF0MtBjchd7JoDaLXFKgQu5Ee4z319eKs
         gJz1hrczBy5Aj+PHYrOolBCcw1QdkeCRJ/sPIBkVAOHarbuwpqaT4NCukSU5z6ICVzc7
         FM++cyuCIePUlEPCrhR7nL0F3bAiAd1MSmaUw+GMTa12vv2wAwLbQ0bEEW/aZIKAIQ6F
         lHaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:in-reply-to:mime-version:user-agent:date
         :message-id:autocrypt:openpgp:from:references:cc:to:subject;
        bh=qm4Vojrg8FZVrLar+RG6E7oBWC3PYekGCUK4aKWGGP4=;
        b=JbMAsp6kQOOlpBQOEWyZH2EM19qL3tG67Oz87HhN8EhsD0Lq6NzSwCbwra8jMq/jVA
         n4bFuB6fdjGujYTbNdjoD2jJMLWusMMN0j3K7g0JymKDvK438HdQ+FEXGwSiaB9zlXuI
         fJUvjnBL+TWLnxV5G2DvPlKFV14LFQzTnJPPMBR3BEepOC3Z6fAz9/x1YwwHTBCXF/4g
         ny3VxJgdvJxcL7h+uDvkeBLB6n4UBloowcGmt6MGBusin/IixLCvSViWWjHI6Zz5vVsF
         CmQowf8UjuZk1bo05+ni35puHtMQQ5KRpAcB7e8obmGmiJV5Suk/RsUJitjRf33lJXI1
         q59A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.83 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
Received: from mail2-relais-roc.national.inria.fr (mail2-relais-roc.national.inria.fr. [192.134.164.83])
        by mx.google.com with ESMTPS id n12si36402423wrv.161.2019.04.16.07.55.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 07:55:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.83 as permitted sender) client-ip=192.134.164.83;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.83 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
X-IronPort-AV: E=Sophos;i="5.60,358,1549926000"; 
   d="scan'208,217";a="378902670"
Received: from unknown (HELO [193.50.110.213]) ([193.50.110.213])
  by mail2-relais-roc.national.inria.fr with ESMTP/TLS/AES128-SHA; 16 Apr 2019 16:55:21 +0200
Subject: Re: [PATCHv2 2/2] hmat: Register attributes for memory hot add
To: Keith Busch <keith.busch@intel.com>, linux-kernel@vger.kernel.org,
 linux-acpi@vger.kernel.org, linux-mm@kvack.org
Cc: Rafael Wysocki <rafael@kernel.org>, Dave Hansen <dave.hansen@intel.com>,
 Dan Williams <dan.j.williams@intel.com>
References: <20190415151654.15913-1-keith.busch@intel.com>
 <20190415151654.15913-3-keith.busch@intel.com>
From: Brice Goglin <Brice.Goglin@inria.fr>
Openpgp: preference=signencrypt
Autocrypt: addr=Brice.Goglin@inria.fr; prefer-encrypt=mutual; keydata=
 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
Message-ID: <9f130b73-e5ae-0529-69a1-28bd2ca29581@inria.fr>
Date: Tue, 16 Apr 2019 16:55:21 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190415151654.15913-3-keith.busch@intel.com>
Content-Type: multipart/alternative;
 boundary="------------C9633A7F7C1AFD5F502D2BC0"
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------C9633A7F7C1AFD5F502D2BC0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit

Hello Keith

Several issues:

* We always get a memory_side_cache, even if nothing was found in ACPI.
  You should at least ignore the cache if size==0?

* Your code seems to only work with a single level of cache, since
  there's a single cache_attrs entry in each target structure.

* I was getting a section mismatch warning and a crash on PMEM node
  hotplug until I applied the patch below.

WARNING: vmlinux.o(.text+0x47d3f7): Section mismatch in reference from the function hmat_callback() to the function .init.text:hmat_register_target()
The function hmat_callback() references
the function __init hmat_register_target().
This is often because hmat_callback lacks a __init 
annotation or the annotation of hmat_register_target is wrong.

Thanks

Brice



acpi/hmat: hmat_register_target() isn't __init only

It's called during PMEM node hotplug with kmem dax driver.
 
Signed-off-by: Brice Goglin <Brice.Goglin@inria.fr>

--- a/drivers/acpi/hmat/hmat.c
+++ b/drivers/acpi/hmat/hmat.c
@@ -598,7 +598,7 @@ static void hmat_register_target_perf(struct memory_target *target)
        node_set_perf_attrs(mem_nid, &target->hmem_attrs, 0);
 }
 
-static __init void hmat_register_target(struct memory_target *target)
+static void hmat_register_target(struct memory_target *target)
 {
        if (!node_online(pxm_to_node(target->memory_pxm)))
                return;


--------------C9633A7F7C1AFD5F502D2BC0
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 8bit

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <pre>Hello Keith

Several issues:

* We always get a memory_side_cache, even if nothing was found in ACPI.
  You should at least ignore the cache if size==0?

* Your code seems to only work with a single level of cache, since
  there's a single cache_attrs entry in each target structure.

* I was getting a section mismatch warning and a crash on PMEM node
  hotplug until I applied the patch below.

WARNING: vmlinux.o(.text+0x47d3f7): Section mismatch in reference from the function hmat_callback() to the function .init.text:hmat_register_target()
The function hmat_callback() references
the function __init hmat_register_target().
This is often because hmat_callback lacks a __init 
annotation or the annotation of hmat_register_target is wrong.

Thanks

Brice



acpi/hmat: hmat_register_target() isn't __init only

It's called during PMEM node hotplug with kmem dax driver.
 
Signed-off-by: Brice Goglin <a class="moz-txt-link-rfc2396E" href="mailto:Brice.Goglin@inria.fr">&lt;Brice.Goglin@inria.fr&gt;</a>

--- a/drivers/acpi/hmat/hmat.c
+++ b/drivers/acpi/hmat/hmat.c
@@ -598,7 +598,7 @@ static void hmat_register_target_perf(struct memory_target *target)
        node_set_perf_attrs(mem_nid, &amp;target-&gt;hmem_attrs, 0);
 }
 
-static __init void hmat_register_target(struct memory_target *target)
+static void hmat_register_target(struct memory_target *target)
 {
        if (!node_online(pxm_to_node(target-&gt;memory_pxm)))
                return;

</pre>
  </body>
</html>

--------------C9633A7F7C1AFD5F502D2BC0--

