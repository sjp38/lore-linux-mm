Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9C79CC7618F
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 14:38:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6DD8A2147A
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 14:38:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DD8A2147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD7148E000B; Wed, 24 Jul 2019 10:38:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D86868E0002; Wed, 24 Jul 2019 10:38:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4F378E000B; Wed, 24 Jul 2019 10:38:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9D98E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 10:38:03 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id b1so22479399wru.4
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 07:38:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=SseZUKX9lTYVRvgaMfxR1/1c8ORn6U6I0UVzuYsjNEE=;
        b=bmCbXCTacI/o8Ze9aoz7DIteSfs+ti+p2IIGGTMJsS3a0A3QXGWMRDFxCP82+rzUeA
         NQikS8x8NnzYrlKPo2FhEQe16oP84GM8qE3KGypw7UQtiIhWYM7sy+LiqDv/R7wW5BVh
         sRCxKVQhYjYd0rxyEbpVcG5SxsBHF5yqzv+ntCe3CRsjEQxve9Y+bT2Ch6j1zzaNpPaH
         M/xG71/e5i/S8AcXbaQy/u+jQHOqT333MOsuo5L0LQ3z3hD+Z1B/tjrEZh8HlMEPAnvp
         6iOBxjgGhq/AnOv3GIExmz9qS0GC9oDgHJylODu9eqr+w/gaZmpSX9ms3DO6fS90eg+c
         TuJA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAWwBndN56YBRN5SVEbXhmORsglQxT5D0UnvPFGrmTtr+tIxrZFB
	5P3EGT8zd+HKMdz9B110TMWQdv9qrRRGjmpjhfzh31LxdqOqH6sHN7ORAg+EHX+vLL8Ty+Cgy6z
	DorEG7j4XycGulA+lxBFeqksNQNIwg40tutYZOq9CxBMpnEEUp6J+S0rUHZhAwKK9qQ==
X-Received: by 2002:a1c:7c08:: with SMTP id x8mr75010399wmc.19.1563979083001;
        Wed, 24 Jul 2019 07:38:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw5pso/Hfztd1HljSoL3TYCGDxQunl6EUwQhZ0eM8XG8eey6lw2dpgoCp+t7NIK39L+Qk0Z
X-Received: by 2002:a1c:7c08:: with SMTP id x8mr75010358wmc.19.1563979082034;
        Wed, 24 Jul 2019 07:38:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563979082; cv=none;
        d=google.com; s=arc-20160816;
        b=KNrfg++TCTxy18atG4Ek3rmgOHiuD6QrTnmymuFWSvn+yoCzuz5TDpdFVgIjgzrmN4
         BLZFD6zW9l/zzesFW/B33vpH9LBr6gLmilH6frvajITY0pcQcB02bLDbI0MVlDpzwkT5
         cOu4UzLCjLO7JvhpMEj4WwIArwygGJmwheqFKXNk+Culr53Qu9rW51N4j/n8Z+tJAcGn
         Ey3IZh7NaU/3jHV1a7q3EcLzxHIg8aKPMXSvn5LnseMv8OFMPS8fnBvGMLeibYtUa8vV
         Dkr+ZWZG1YMhEqoP73HdVdezQGXC9+MrkyJVtlEl8DX4okgOC8Ypet94BDDZNkbIqRw6
         tI6w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=SseZUKX9lTYVRvgaMfxR1/1c8ORn6U6I0UVzuYsjNEE=;
        b=iaKAFennJb/cPbwQFaOnQnpOhoDXgIlK6vJkSzy54pN/6FiBpfNkdKk1g6vZKDbV/h
         bG0xdXl3euq90ZUgVys1st+NHUIvmCPGrSxMOspLRYUWaA8PVLgjlHglPwumOfa42M1z
         lZ/FwN4inkZutuoGs//6NWA1ZJg4GbQ2n7aB7jcI7US3SdI/yRrU+Yc5ioTZjNxMgdXA
         /hRyMyANHeR4R/EsNJ5XRaR4hyvw59DTRlHMDLRVQeHOoRNioRHY2OH1YGvqic/GCD4f
         2ww5AhyW2UjOwFokeS3qtKzZUatV9GPSytBigrGlvtdzXkTzCnMMNYp6Fa9m3dQJq387
         mIKA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a0a:51c0:0:12e:550::1])
        by mx.google.com with ESMTPS id w13si36958376wmk.22.2019.07.24.07.38.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 24 Jul 2019 07:38:02 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) client-ip=2a0a:51c0:0:12e:550::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef1cb8.dip0.t-ipconnect.de ([217.239.28.184] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hqIOx-0002MW-0J; Wed, 24 Jul 2019 16:37:55 +0200
Date: Wed, 24 Jul 2019 16:37:53 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Steven Price <steven.price@arm.com>
cc: Mark Rutland <mark.rutland@arm.com>, 
    Dave Hansen <dave.hansen@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>, 
    Ard Biesheuvel <ard.biesheuvel@linaro.org>, 
    Peter Zijlstra <peterz@infradead.org>, 
    Catalin Marinas <catalin.marinas@arm.com>, x86@kernel.org, 
    linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
    =?ISO-8859-15?Q?J=E9r=F4me_Glisse?= <jglisse@redhat.com>, 
    Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
    Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, 
    James Morse <james.morse@arm.com>, 
    Andrew Morton <akpm@linux-foundation.org>, Will Deacon <will@kernel.org>, 
    linux-arm-kernel@lists.infradead.org, 
    "Liang, Kan" <kan.liang@linux.intel.com>
Subject: Re: [PATCH v9 00/21] Generic page walk and ptdump
In-Reply-To: <fd898367-b44e-9328-bdab-7a3de0db6bda@arm.com>
Message-ID: <alpine.DEB.2.21.1907241620140.1791@nanos.tec.linutronix.de>
References: <20190722154210.42799-1-steven.price@arm.com> <20190723101639.GD8085@lakrids.cambridge.arm.com> <e108b8a6-deca-e69c-b338-52a98b14be86@arm.com> <alpine.DEB.2.21.1907241541570.1791@nanos.tec.linutronix.de>
 <fd898367-b44e-9328-bdab-7a3de0db6bda@arm.com>
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

On Wed, 24 Jul 2019, Steven Price wrote:
> On 24/07/2019 14:57, Thomas Gleixner wrote:
> > From your 14/N changelog:
> > 
> >> This keeps the output shorter and will help with a future change
> > 
> > I don't care about shorter at all. It's debug information.
> 
> Sorry, the "shorter" part was because Dave Hansen originally said[1]:
> > I think I'd actually be OK with the holes just not showing up.  I
> > actually find it kinda hard to read sometimes with the holes in there.
> > I'd be curious what others think though.

I missed that otherwise I'd have disagreed right away.

> > I really do not understand why you think that WE no longer care about the
> > level (and the size) of the holes. I assume that WE is pluralis majestatis
> > and not meant to reflect the opinion of you and everyone else.
> 
> Again, I apologise - that was sloppy wording in the commit message. By
> "we" I meant the code not any particular person.

Nothing to apologize. Common mistake of trying to impersonate code. That
always reads wrong :)

> > I have no idea whether you ever had to do serious work with PT dump, but I
> > surely have at various occasions including the PTI mess and I definitely
> > found the size and the level information from holes very useful.
> 
> On arm64 we don't have those lines, but equally it's possible they might
> be useful in the future. So this might be something to add.
> 
> As I said in a previous email[3] I was dropping the lines from the
> output assuming nobody had any objections. Since you find these lines
> useful, I'll see about reworking the change to retain the lines.

That would be great and as I saw in the other mail, Mark wants to have them
as well :)

That reminds me, that I had a patch when dealing with L1TF which printed
the PFNs so I could verify that the mitigations do what they are supposed
to do, but that patch got obviously lost somewhere down the road.

Thanks,

	tglx

