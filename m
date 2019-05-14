Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 360C2C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 07:07:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C82EF208C3
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 07:07:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="fj8Pr4HG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C82EF208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 146936B0003; Tue, 14 May 2019 03:07:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F87E6B0005; Tue, 14 May 2019 03:07:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED94D6B0007; Tue, 14 May 2019 03:07:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9F20D6B0003
	for <linux-mm@kvack.org>; Tue, 14 May 2019 03:07:37 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id c8so9507353wrb.21
        for <linux-mm@kvack.org>; Tue, 14 May 2019 00:07:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=bnleR30QPIQpq+EFwBkF6XZjkSnpThngrZ0Pg3kgcGM=;
        b=Dc+i30hzPeuqZwfJQ6xj72Ccl52V5Y8q6pJFmSsErY6z6/zOmeFaZEHO55yE/BBkQH
         c+RoUKDfp6XFVULrvRrQGbdCllbuRiRclGucn/bKUEnPJ+ZJA7Sd/WooM+wk++n4fRg2
         8+prO2imgoILcvxPeacfvAXcsqX4FiFn2o8pVs2nP54CuUhYvXbfNyK3Kj/LqtUf6zOD
         SQjBpRIjMwUCeR/AKU5kJ7Ayk/ddqouCjDtCWknQQt1HuqP6OMyowAWzuvqLYis+54Ps
         yMmcZM2Z5xL70y8bJEGWNGzcmExvg0eWeN4vCLQkEhco6b7ha+mh5OPuztA1y7QydcXT
         p75w==
X-Gm-Message-State: APjAAAXFMh5r/JAEw5B43t7pqPUwUsyWXroi8EFvFLoxC2tB+e3KN1Ka
	Uk9teTP1kU2zNF4xrwu0xvKh9tc+TxDw6vfkh+Dskr8MPvtb/k58H/SS2Z4vOq1orTt71h3QzXR
	vpIWUN9zAohnQyozFbonsm9MW6x7O5stTFIATiZ+PO663EuIhdqlxhNg9yTiJM3pEsw==
X-Received: by 2002:adf:b243:: with SMTP id y3mr19647963wra.21.1557817657110;
        Tue, 14 May 2019 00:07:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy6hMDBx+4fSaknyEb1jzE+NtbuaBauPrC6G3s32/9m+ESTIhLysw66Ps8VnRzCzz3sAS9C
X-Received: by 2002:adf:b243:: with SMTP id y3mr19647897wra.21.1557817656081;
        Tue, 14 May 2019 00:07:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557817656; cv=none;
        d=google.com; s=arc-20160816;
        b=BVdoPoNdvVAcYpKTSyTjk0xZbLIwhVeavJXlwXVmaNLgeVPWBLWlLfePL6wo5AI3Vn
         hABdt88zNTLps8zzuX5yUyNApQIpI6QiLc9q/wz1onqgr1ueSp5gobkqZ/NMkqq7GTtv
         cU7OwJ0pfV1W/O3xM5YtoSjBToj0vKO+0PPQhJGq/Qdub0KOFlvfuQysQQK3IGh3FRhw
         7MVUeXwcoGoYUNakGxRf2eolb+9ESoOtW7AaHT/XLjiHNgA5E4K8YtD7EkNgAk5Pkafk
         CNrE4KNigxwMvTZT5cm042TqbUxKX3emHhw5Bc9JUrnC6BHvS4AyVJP85TgK0HJbMyeS
         UQ6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=bnleR30QPIQpq+EFwBkF6XZjkSnpThngrZ0Pg3kgcGM=;
        b=fAYF6+SRD88uR9r8W0he5ZV/1OQi1eGg+1THIElzTl530EMYSIoLenrfszg/YBpGR9
         VHU/qiVkUljqBnJEppd5b89Yy9nponHJJSeVk6InBnJ14C/sD+2oVWbAgx9pboVX7Eyu
         3U5ZvZ3rkZmgjsbR0ZqikW9vk82IcAF+iV+VsBswO9QBG7kqbf8BE3+ejqgkPXgi6g8C
         LMakgytiKYx9pjDKzN0ciC0X7VERhiqjRcUADLRnMXaA7Gp+408QGz9JTw/XtxoSZk92
         VPr5ma+fdYllmIxmey6qz8+oXMp9U33t/zAot5mnUcCsnmfy3TlvG5oHpETO6FjQCN64
         eUjw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=fj8Pr4HG;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id j33si11342054wre.178.2019.05.14.00.07.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 14 May 2019 00:07:36 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=fj8Pr4HG;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=In-Reply-To:Content-Type:MIME-Version:
	References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=bnleR30QPIQpq+EFwBkF6XZjkSnpThngrZ0Pg3kgcGM=; b=fj8Pr4HGZz0EffcR3mMIilbKU
	fw2M4dJTleSkNrTFwvh8Xs0jEjW3csUzM6UlbkmE+h4NJSbyN1qXkhAjKCTsO61cTx+t8imqrXN8S
	0rQ6trjzcgY+Ek1FpZg4xVOto/iAuNkyo2qkztLhyrNP7BQdtcOmzL0dqS9biIpCkVAZyFIF27KIq
	i59RJMm8ZVxQAWKjZk0Egm7j5WlaJRcSVPUVls0HDAmaHtOJzuXORnbslZy/3esomWW5W3XaQ5fMa
	kgMziZKLho0llyMphjzIedWd+CVfi8S5JmkjDx1A4voaVaOPz2muFlfyL9z/18kaC3Y9VpXA9rT9k
	KABV+JT4Q==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hQRX0-00063G-SZ; Tue, 14 May 2019 07:07:23 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 1000)
	id E3F802029F87A; Tue, 14 May 2019 09:07:19 +0200 (CEST)
Date: Tue, 14 May 2019 09:07:19 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Alexandre Chartre <alexandre.chartre@oracle.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim Krcmar <rkrcmar@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	kvm list <kvm@vger.kernel.org>, X86 ML <x86@kernel.org>,
	Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	jan.setjeeilers@oracle.com, Liran Alon <liran.alon@oracle.com>,
	Jonathan Adams <jwadams@google.com>
Subject: Re: [RFC KVM 06/27] KVM: x86: Exit KVM isolation on IRQ entry
Message-ID: <20190514070719.GD2589@hirez.programming.kicks-ass.net>
References: <1557758315-12667-1-git-send-email-alexandre.chartre@oracle.com>
 <1557758315-12667-7-git-send-email-alexandre.chartre@oracle.com>
 <CALCETrUzAjUFGd=xZRmCbyLfvDgC_WbPYyXB=OznwTkcV-PKNw@mail.gmail.com>
 <64c49aa6-e7f2-4400-9254-d280585b4067@oracle.com>
 <CALCETrUd2UO=+JOb_008mGbPdfW5YJgQyw5H7D_CxOgaWv=gxw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUd2UO=+JOb_008mGbPdfW5YJgQyw5H7D_CxOgaWv=gxw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 11:13:34AM -0700, Andy Lutomirski wrote:
> On Mon, May 13, 2019 at 9:28 AM Alexandre Chartre
> <alexandre.chartre@oracle.com> wrote:

> > Actually, I am not sure this is effectively useful because the IRQ
> > handler is probably faulting before it tries to exit isolation, so
> > the isolation exit will be done by the kvm page fault handler. I need
> > to check that.
> >
> 
> The whole idea of having #PF exit with a different CR3 than was loaded
> on entry seems questionable to me.  I'd be a lot more comfortable with
> the whole idea if a page fault due to accessing the wrong data was an
> OOPS and the code instead just did the right thing directly.

So I've ran into this idea before; it basically allows a lazy approach
to things.

I'm somewhat conflicted on things, on the one hand, changing CR3 from
#PF is a natural extention in that #PF already changes page-tables (for
userspace / vmalloc etc..), on the other hand, there's a thin line
between being lazy and being sloppy.

If we're going down this route; I think we need a very coherent design
and strong rules.

