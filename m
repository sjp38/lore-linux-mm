Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CF97AC04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 22:49:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77A3A20862
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 22:49:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77A3A20862
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=davemloft.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF1756B0003; Mon, 20 May 2019 18:49:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA1286B0005; Mon, 20 May 2019 18:49:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C6ACB6B0006; Mon, 20 May 2019 18:49:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 796166B0003
	for <linux-mm@kvack.org>; Mon, 20 May 2019 18:49:04 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h2so27451587edi.13
        for <linux-mm@kvack.org>; Mon, 20 May 2019 15:49:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date
         :message-id:to:cc:subject:from:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=JdsKHMYCwyG79Y0zBeXDibY4PN9XKitXH09TAsiFZ+o=;
        b=hA8R27Nas7A6p0ApgPmFFbh/IZ/tOhMM6EpJf+K/qF7AmgFXWMKsc4wannHRW6ioRC
         a+qlZXGDbwmcokbf8tPzh1cu2OU+UTwxnICSl3gcxmwDQtrC49I2+kuGcChSheDGAedC
         vT0okW70J59obVXOwYlwlHmSJYfCkSpEWB5MApO6D+Pl+gIGsaBPsWcXfKg0JOVPb3cN
         o8nFKvCUquzZ3I+FpNlxyM0WHq1qW3Jp+av4axs2OO+GtLlBe5WUtur8pPfUK1MWnccN
         GslBHLiwjivJmGMMPuAOGH/iqh8wvprOj4kS5PqWzYNj8q7WBXET569Eo5LAAmN8uAyL
         /LYA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
X-Gm-Message-State: APjAAAVOC1ho6CHBhjPfgOUfov0rLEnYpttTLYPA1jyva54WWVV9f30y
	4yz3oL83wNg18eC1nuMGgvvOlGUpXHiwal7gW57coDWfL6MbJRPSoR4Bi9F4I+YsxDWQf7Q8NWv
	hhkVsYhc6P8KzLtQxTAGfvAmOgMbVK1OthJ+veTc04Ta+MS+g34Zjzq9fngnU4o0=
X-Received: by 2002:a17:906:6603:: with SMTP id b3mr61026163ejp.128.1558392544061;
        Mon, 20 May 2019 15:49:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy9cMUK/p+8BUwTvdM1P7qWch7i+g+tb9W9gd519nvGf1z0oEyDoaSerXuMb4N4ec5YwQ3g
X-Received: by 2002:a17:906:6603:: with SMTP id b3mr61026123ejp.128.1558392543329;
        Mon, 20 May 2019 15:49:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558392543; cv=none;
        d=google.com; s=arc-20160816;
        b=IxcR8xJTHP9qYx20faPxXaLmjelbqu+wXVdQ6GxB+LMd4NXnb4Pv/qnb5y7EuQMGse
         7u7ziZld8FRAMDI5V0VH+K9OL0NB46M7dBPalLRmrw7+iHD/FiAOg3tBY+reiHQtUf8x
         sj8RxbKYA22KrrQ1xBecJT4mMt1O9CKvkqEZEYq27GYz7FiywXV8qCy0CWalcXcwn0mU
         SEzR/uuIHrHbZ/hOFJweL9cymVlKUwuD/dZfXeP2ttjOsiyL9Xh1Bvb7xUwGDUvCKA5I
         xmoDlktvQ6UloWaVpRbJ/5AiZSTBqyAClRcpYIYIFf1DWohCUGczShgdl3IIByFU50rR
         R0BA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:from
         :subject:cc:to:message-id:date;
        bh=JdsKHMYCwyG79Y0zBeXDibY4PN9XKitXH09TAsiFZ+o=;
        b=rletxobbH4fMAl0DhRtklFtZcN0oWn8+1130Ko7iRC4cTKVk334Wy/k+4ZfQghO8Zh
         w0Ndd7Q+awsCMOuaC2GfLwsaw6JJqLHlql5EgrO0VN/u/bIgAU/t8fXfDXHcVP2ORXFC
         aifbIf/wB/AfWvrQNrui73v+An1kY188ps+4rhXNXgGBeaW7IZRMvrEHL0Z60I4zAnWa
         Rk421c5s9GChsRxKp+jAK5sK2xtwL65L0xxtL3KWLZ+D3HdNQawokJIRP9ZuBJ2UzrBk
         dj2U0OTQYQ3k1UNQZEvciZLrg8EmhjS04jrdcJ80gE/nxxrbcuCzM13Nzqrff51nNohJ
         7TbA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from shards.monkeyblade.net (shards.monkeyblade.net. [2620:137:e000::1:9])
        by mx.google.com with ESMTPS id w17si7212616edl.369.2019.05.20.15.49.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 15:49:03 -0700 (PDT)
Received-SPF: neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) client-ip=2620:137:e000::1:9;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 2620:137:e000::1:9 is neither permitted nor denied by best guess record for domain of davem@davemloft.net) smtp.mailfrom=davem@davemloft.net
Received: from localhost (unknown [IPv6:2601:601:9f80:35cd::3d8])
	(using TLSv1 with cipher AES256-SHA (256/256 bits))
	(Client did not present a certificate)
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 2E3EF12DAD571;
	Mon, 20 May 2019 15:48:58 -0700 (PDT)
Date: Mon, 20 May 2019 15:48:55 -0700 (PDT)
Message-Id: <20190520.154855.2207738976381931092.davem@davemloft.net>
To: rick.p.edgecombe@intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, peterz@infradead.org,
 mroos@linux.ee, netdev@vger.kernel.org, sparclinux@vger.kernel.org,
 bp@alien8.de, luto@kernel.org, mingo@redhat.com, namit@vmware.com,
 dave.hansen@intel.com
Subject: Re: [PATCH v2] vmalloc: Fix issues with flush flag
From: David Miller <davem@davemloft.net>
In-Reply-To: <c6020a01e81d08342e1a2b3ae7e03d55858480ba.camel@intel.com>
References: <20190520200703.15997-1-rick.p.edgecombe@intel.com>
	<90f8a4e1-aa71-0c10-1a91-495ba0cb329b@linux.ee>
	<c6020a01e81d08342e1a2b3ae7e03d55858480ba.camel@intel.com>
X-Mailer: Mew version 6.8 on Emacs 26.1
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.5.12 (shards.monkeyblade.net [149.20.54.216]); Mon, 20 May 2019 15:48:58 -0700 (PDT)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Edgecombe, Rick P" <rick.p.edgecombe@intel.com>
Date: Mon, 20 May 2019 22:17:49 +0000

> Thanks for testing. So I guess that suggests it's the TLB flush causing
> the problem on sparc and not any lazy purge deadlock. I had sent Meelis
> another test patch that just flushed the entire 0 to ULONG_MAX range to
> try to always the get the "flush all" logic and apprently it didn't
> boot mostly either. It also showed that it's not getting stuck anywhere
> in the vm_remove_alias() function. Something just hangs later.

I wonder if an address is making it to the TLB flush routines which is
not page aligned.  Or a TLB flush is being done before the callsites
are patched properly for the given cpu type.

