Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8245FC5B57D
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 23:06:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1CF7E219BE
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 23:06:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="JUb1nx9Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1CF7E219BE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B04116B0003; Tue,  2 Jul 2019 19:06:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB3E88E0003; Tue,  2 Jul 2019 19:06:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C9B48E0001; Tue,  2 Jul 2019 19:06:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6276D6B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 19:06:33 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 91so220485pla.7
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 16:06:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=8y/CkT0i0Qs7+/sL/dgJQk245UhHoHWZs2hJ097JT0A=;
        b=mWcycdoNW8QhIWVDkFV9IF+GmBN1ZGwOOOcaiYvY2JYZ4mMFDQKyzNzuKqeVjCIcnN
         9JOVmBhUCGxl/QrvwgstGtZLw7MKyEJVbBRAmJjTNvlxNOXZZPWvy4cjGmXQuz7yWoga
         vRgzEl1m3yz1+Rzu/LeynceSqspbUEOaSuVqfvyu4G/B6t6o2SzFngJ08Ndn3Vh1pxve
         YKFFOBkc02/X7Tmcuy1WSNh9woOgriUmqkv8Uee7pV7YgJKlagC76ZNqLP05H6zAq6IS
         JD4IUNYMeuchhY87Y+/RIwK+70fDGxW28Yiu3CuRF3GsB6Lv9LnZ6z27dlcpiptiBlTc
         /y9Q==
X-Gm-Message-State: APjAAAW/WqYPwLIF0ZxLzlrj07iF1dWM4ME2jyX9ODCUdHSxu/kCpz4e
	ob8AbKqMh/qYeoiP3JhfNAx8VgBi3SyEQBb0I5IiEWcszHo/xW1xlz3SFyDTk/DObNj3+kq5QtK
	Vx17KMs5omN3DRbxODCqpSksT+yygRN2AzQIqvqpx+8PvhvHVxKPlQzbF08CuhvOlHQ==
X-Received: by 2002:a17:90a:35e5:: with SMTP id r92mr8548138pjb.34.1562108792934;
        Tue, 02 Jul 2019 16:06:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyFmDEQMlfj9DFDbrOhzND6ZL9kjWD2AgtJu5/ZrI+CDouZwkcHJT6plhNQK7eQbHidIu+s
X-Received: by 2002:a17:90a:35e5:: with SMTP id r92mr8548080pjb.34.1562108792297;
        Tue, 02 Jul 2019 16:06:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562108792; cv=none;
        d=google.com; s=arc-20160816;
        b=EF6EUq9di5eoqmyqicNkCUsQdYq3jBKkGPtnKDThAEgLvfYmTvlf4CPskaOmyUvk4N
         1fdqoAeJacNqOLdq5UIJqUft3jYnzTuHBbqsd41dcOUrm9AQdsm6D2wPfPNtMY6a+JSG
         Epn6Z1FOkq+dXjPrjYtGBF4pBrpaXSctP9yNP+n2D84ILhq3A5jw4VFZTimVp+1UTqXq
         FrGqFpB0Dj+Af47eYgzAvzm2OX/Num7PW7PoN1vC9mu6scGAMgJGl/xf+u+V6vKMBxwD
         KA0Uu+BJhAnhcmg8ppUXHmOHswTZHeG1EdDySVcAmYh0k7r19WwEC+tQKxfGvX8XyqrI
         7LRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=8y/CkT0i0Qs7+/sL/dgJQk245UhHoHWZs2hJ097JT0A=;
        b=bPGMTny3YGHue/YEhnIGansg7dIwDoQj6/6hpY2tgvG28Zw+hhkQMeIeZQ4I05NAQm
         VTKfBYl2pTDLEw5QsF6aW94qSolVwHM8BzdG5kfoNDHFosNLUujUibtdRXxMvpPM6e94
         6zkyfXxt52BSyJ12BVfy1IjOcgqIBywlBnnxnV59gJ4ttes2tZJMr1oTza8EGb8tyvMh
         jNPICkCekIqBDVzkT63xsn2+Dt7PTvTgeU17FRTR9AiryVq25+/oay0W4PGVXEiXySJ9
         Oruqc96R9wGID+CRohT5fdNPccwbZPECsyRRrBNbBMHPblLM5CLVlLFOPBmtk52DpVQV
         cRwA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=JUb1nx9Q;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id i133si184926pgc.109.2019.07.02.16.06.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 16:06:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=JUb1nx9Q;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 59F8E2199C;
	Tue,  2 Jul 2019 23:06:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562108791;
	bh=JfXv0pCKQrn0sl4VrjHSpgULbbIU9t/cCfO93UN+XVI=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=JUb1nx9QXGiAL3ORC8afccxW5WUezpyIh8W9m2X8t+BMOcduaCPnCe14iwDLeFsDg
	 q8sbXWgPfCidgfAHEr4dQbDjWJQ2Mp0AJm1EExPGNvZDbjd8RcrqIcLXrnIGHihGuH
	 509avyOOeAQvk2WYzgSx8myhqZVMx/gFaMXoxT0w=
Date: Tue, 2 Jul 2019 16:06:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, Catalin Marinas <catalin.marinas@arm.com>, Will
 Deacon <will.deacon@arm.com>, Dave Hansen <dave.hansen@linux.intel.com>,
 Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>,
 Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
 "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko
 <mhocko@kernel.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Michael
 Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org,
 linux-arm-kernel@lists.infradead.org, x86@kernel.org
Subject: Re: [PATCH V2] mm/ioremap: Probe platform for p4d huge map support
Message-Id: <20190702160630.25de5558e9fe2d7d845f3472@linux-foundation.org>
In-Reply-To: <1561699231-20991-1-git-send-email-anshuman.khandual@arm.com>
References: <1561699231-20991-1-git-send-email-anshuman.khandual@arm.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 28 Jun 2019 10:50:31 +0530 Anshuman Khandual <anshuman.khandual@arm.com> wrote:

> Finishing up what the commit c2febafc67734a ("mm: convert generic code to
> 5-level paging") started out while levelling up P4D huge mapping support
> at par with PUD and PMD. A new arch call back arch_ioremap_p4d_supported()
> is being added which just maintains status quo (P4D huge map not supported)
> on x86, arm64 and powerpc.

Does this have any runtime effects?  If so, what are they and why?  If
not, what's the actual point?

