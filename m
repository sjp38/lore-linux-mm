Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AEBCFC76195
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 08:19:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E63D21E70
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 08:19:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E63D21E70
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 169996B0003; Mon, 22 Jul 2019 04:19:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F4D36B0006; Mon, 22 Jul 2019 04:19:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFE348E0001; Mon, 22 Jul 2019 04:19:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id B79066B0003
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 04:19:49 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id j10so15832946wre.18
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 01:19:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=lYQ5JigCLf0Ev1hb1xRUUSaQSsRHlyi5XCg/GYiCLdE=;
        b=HHi0AMGxZYz9pRr+4eiDTzVd1CaC8xc11EmNsGEOqbOtvq/+DUZFs1K9UH4/2vMlcY
         ci7F/e6ZL47dql84iyJOGuNCrtqoAJwe0gjQQv04ed5Z+nKwQiphjaIDzyxx3cZkcAyK
         25PBRhiY3IWv0Tj7deSiALDMCqSDm+DQoZ4KVmhMPC7mqOYG+km5K+shY2+oaLl5yrze
         DwUbZafuVgJfyguJ+5FBd3BxY3DG/XZB1j7QQskarSlU+btBmGx9/f0jT2Z7j2QUWuyd
         RLH7xfzK7HgDhFkcSKPtgDatAuiL0+8+3VlWr+rlRaWoJ4CkeUiR0P6SLqOs3Xo4nOEO
         t+3g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAU/hy9lFmxGDSHe+67la9uCg7zGSW5djQaOj10+lI0VhIIXBGfg
	LF3mdm8o59JtvZ0TilVPQXPzzEQW7m72wyr2ZHI8+5pFRjmVGBAZj2idBwtEOq+epecXFjhwuFl
	H2HOdhpJoHJY9aSu/UoAvDYd4k8xMyndnx9F1w1BivCqWp8RtAD2YCxplGKwRRFA7ag==
X-Received: by 2002:a1c:a686:: with SMTP id p128mr65853642wme.130.1563783589266;
        Mon, 22 Jul 2019 01:19:49 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwfZJUAvgvuOZn7iEoHOtqL4ftZ6V4aS/HqZBfsCSdC4DbJuntepV4EvU3UthX7ChQbjZJj
X-Received: by 2002:a1c:a686:: with SMTP id p128mr65853592wme.130.1563783588626;
        Mon, 22 Jul 2019 01:19:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563783588; cv=none;
        d=google.com; s=arc-20160816;
        b=Vgw5crfl6jgeF41axYHmDtvGeM8mHUKpN4GUkPGnyhUdJbDH1ec4kX7zTZBw0v0GhJ
         Qciv7sS1KcHr+lD6cvhoYG7BfN1j/Ey7jkSx/zlhc1taetw9SUIZdqfyXhdJq4P2Xx6J
         hhLHyPlPxNZBiR4crCZzE2xHyhFHYpkexG8m4KFaxjcNQOhELa22Z48SCxZe5rI1G7ax
         oW8n3QoG0rbcNVQeu5qb3mWRQnPBI0zYZxKX/m0ST25RneBusMqkb8JcMu9zMSZSxvc6
         PYeT/PeQDCO5iyQ2yfapibRRV6X5wEwHfhWPaum7ML3OgJMLWSXZIY9yJ6XKdu8PY4Q0
         k81Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=lYQ5JigCLf0Ev1hb1xRUUSaQSsRHlyi5XCg/GYiCLdE=;
        b=WI8/6uoCPszrJPoDc/oxWDbXd2RsgzlBRHHFteX3OCgwmkIn+ut7uWuvVC+IohyRw3
         o06GMY/KuqJDX+Z27qYGzqcSjUmwWUtfs/IWbC5nbVdqUZ5Mui7jNiI+wWFb1T4fTr94
         Djp841jK7t07v2AghP0D3HN7VzEL2I/U7ITEPi1ZaBSweWQIPE3RTh8i3Z9XZzamxVyZ
         yp575NhUY0bqByk6bX8QI/lU6iXyfiCo+lKkOyKJ5P0mtsc3Q0JZFchE9ge4W9rNRKcy
         ve9VA6xuVBQmKjO4UY82mgAK4cgyMCTqQOsdqNAac50xE0tdB3N1mt74Y54zaWCKYA9t
         bDqw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a0a:51c0:0:12e:550::1])
        by mx.google.com with ESMTPS id r6si38532237wrn.294.2019.07.22.01.19.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 22 Jul 2019 01:19:48 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) client-ip=2a0a:51c0:0:12e:550::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef1cb8.dip0.t-ipconnect.de ([217.239.28.184] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hpTXi-0001Ce-9t; Mon, 22 Jul 2019 10:19:34 +0200
Date: Mon, 22 Jul 2019 10:19:32 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Joerg Roedel <jroedel@suse.de>
cc: Joerg Roedel <joro@8bytes.org>, Dave Hansen <dave.hansen@linux.intel.com>, 
    Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, 
    Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
    Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, 
    linux-mm@kvack.org
Subject: Re: [PATCH 3/3] mm/vmalloc: Sync unmappings in vunmap_page_range()
In-Reply-To: <20190722081115.GH19068@suse.de>
Message-ID: <alpine.DEB.2.21.1907221018460.1782@nanos.tec.linutronix.de>
References: <20190719184652.11391-1-joro@8bytes.org> <20190719184652.11391-4-joro@8bytes.org> <20190722081115.GH19068@suse.de>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 22 Jul 2019, Joerg Roedel wrote:

> Srewed up the subject :(, it needs to be

Un-Srewed it :)
   ^^^^^^

