Return-Path: <SRS0=AeVH=PN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FA00C43612
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 23:09:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2D562222C3
	for <linux-mm@archiver.kernel.org>; Sat,  5 Jan 2019 23:09:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2D562222C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B01DE8E0131; Sat,  5 Jan 2019 18:09:06 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB1428E00F9; Sat,  5 Jan 2019 18:09:06 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A0808E0131; Sat,  5 Jan 2019 18:09:06 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3FD548E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 18:09:06 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id v4so35971483edm.18
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 15:09:06 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=M0uemqRb1WttK0iqit6BFBBoeosmq+tP9ZgmoEz4EH4=;
        b=PEf8ru2Pz0M5ymfYbPxqpzWEx74uOTp4eid2M5uO6SVFQkbEVpVbnUEB0rnSDRtkuV
         sbgY+e93OY1927q8zFD03aAt/6EeYAljFoxojeE3M1Xh5IHXLSubU6bGf0wJH576ysVT
         79MeVhH7/iYeuXQHDroT8EyWdGFAJAo62Ls+YzgOECShcKvWwRUN9cBm+OxzjR5CNzB5
         pK2PNYpzWkKmoPqJ4kdVFhpY0bOop7deo8hQXcpfan/7NMk4N2Je47bYZJJsoh7k48xQ
         bWNR+CAb+2d++R6bloLu2lsGigfQxbmdZUACkNG/cgfq+k/ZKqPV7gQYa71ag9hz/ZUL
         U0qg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AA+aEWapEdm2CETept2ZmKpoIieiaNj9OCb2nT9IC8nAj74UTSIHPMDS
	Hh99waPWB0nuT0zu5aHP5ZyGBld1AmwHR52GBBc1YJFLZi1iTJ/Y3F1GkdHPV9mZOSwgAqbi521
	JvwuAr3mIoDOqA18WQddvhbzH/D2vfNsFcoNhlJubB6nlp5NpKVKd/5cfPIEmtiQ=
X-Received: by 2002:a17:906:7805:: with SMTP id u5-v6mr42962462ejm.213.1546729745740;
        Sat, 05 Jan 2019 15:09:05 -0800 (PST)
X-Google-Smtp-Source: AFSGD/V9b5C3XRPCMOaGBu3fyxhB2QYXbj4HU4XXRHojzWvIQP9uWhJwMZWZVERzd3ktUxLXu1XD
X-Received: by 2002:a17:906:7805:: with SMTP id u5-v6mr42962445ejm.213.1546729744984;
        Sat, 05 Jan 2019 15:09:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546729744; cv=none;
        d=google.com; s=arc-20160816;
        b=yFBooOSsnSUBcXbGJVpz+T3syI7bFenVI30vOiqXhm837TLjApQ+ebvvn1lT+bQ5/e
         2tfpWQ9n+itupbjDHWw113/nyFIGsxmiYhs/U9IcQgzyqORmCTMr/+VfdW1bg3CXkl7z
         6iV5mViB+kRFcbLA/0i1R79KXbdomgD9BjF0DfqA5nJZkYuefMDq6nK/I0jVlIp2hwGc
         e2XUgan2L0g8P+QIv/kQxvQMSwfJOnX9KYhEKbG+4xSY+8WHfTo3FlaEWOJC5Blds4cj
         imtc1RdL1XXWjc44ObmygP6Ajw+bjHF7JRJI9rh2lrhKa4HwZ4dwQ+ngcP9WxltXprmt
         Rr4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=M0uemqRb1WttK0iqit6BFBBoeosmq+tP9ZgmoEz4EH4=;
        b=zA1tMQqOvvCX6k7hPZyjHtmmcUeYjctd7Bs4bPj9hS2eQD31vgT31XUKyePU6gZnr7
         wVOeC+Xmi+s2mi1N24ob3zfTczpj/5CtJNJRIA8avVTD4uj6lknssN/Qz+cOF8YGT/Tv
         wL0DOmp0mYZF0MG+x7TYRToRJ1CYDhi04B8FuIWbPeC/VivOpFEG6xC26C6cQNtiu7KQ
         mfejFYT4e0OupwiGe8NOhR29wiJ6CIqr7NfLX4bjlQyBYXdaFmnvoJfQFBfUR4ly1b0x
         R0kK0x4pNzZHpY9oFDS8hE6F/sSHMdmAN4FoMe5beu6FdzTmqDq/abiA5Mst4TnNAXWV
         RAJw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y4si2933971edr.395.2019.01.05.15.09.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 15:09:04 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning jikos@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay1.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2861DAD57;
	Sat,  5 Jan 2019 23:09:04 +0000 (UTC)
Date: Sun, 6 Jan 2019 00:09:02 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
To: Jann Horn <jannh@google.com>
cc: Linus Torvalds <torvalds@linux-foundation.org>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Greg KH <gregkh@linuxfoundation.org>, 
    Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, 
    Linux-MM <linux-mm@kvack.org>, kernel list <linux-kernel@vger.kernel.org>, 
    Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
In-Reply-To: <CAG48ez2jAp9xkPXQmVXm0PqNrFGscg9BufQRem2UD8FGX-YzPw@mail.gmail.com>
Message-ID: <nycvar.YFH.7.76.1901060001590.16954@cbobk.fhfr.pm>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm> <CAG48ez2jAp9xkPXQmVXm0PqNrFGscg9BufQRem2UD8FGX-YzPw@mail.gmail.com>
User-Agent: Alpine 2.21 (LSU 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190105230902.NafI8S1lhkaJTz_pPxBkIQSye19w0Dx7a7-g3oMNTic@z>

On Sat, 5 Jan 2019, Jann Horn wrote:

> > Provide vm.mincore_privileged sysctl, which makes it possible to mincore()
> > start returning -EPERM in case it's invoked by a process lacking
> > CAP_SYS_ADMIN.
> >
> > The default behavior stays "mincore() can be used by anybody" in order to
> > be conservative with respect to userspace behavior.
> >
> > [1] https://www.theregister.co.uk/2019/01/05/boffins_beat_page_cache/
> 
> Just checking: I guess /proc/$pid/pagemap (iow, the pagemap_read()
> handler) is less problematic because it only returns data about the
> state of page tables, and doesn't query the address_space? In other
> words, it permits monitoring evictions, but non-intrusively detecting
> that something has been loaded into memory by another process is
> harder?

So I was just about to immediately reply that we don't expose pagemap 
anymore due to rowhammer, but apparently that's not true any more 
(this behavioud was originally introduced by ab676b7d6fbf, but then 
changed via 1c90308e7a77 (and further adjusted for swap entries in 
ab6ecf247a, but I guess that's not all that interesting).

Hmm.

But unless it has been mapped with MAP_POPULATE (whcih is outside the 
attacker's control), there is no guarantee that the mappings would 
actually be there, right?

-- 
Jiri Kosina
SUSE Labs

