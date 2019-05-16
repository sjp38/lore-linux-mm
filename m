Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DBF00C04E84
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 07:31:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9DD5C2087B
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 07:31:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="eJk9HEnZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9DD5C2087B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 288416B0007; Thu, 16 May 2019 03:31:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2126A6B0008; Thu, 16 May 2019 03:31:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0D9A96B000A; Thu, 16 May 2019 03:31:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id DC1A66B0007
	for <linux-mm@kvack.org>; Thu, 16 May 2019 03:31:02 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id d193so1985671ybh.13
        for <linux-mm@kvack.org>; Thu, 16 May 2019 00:31:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=GVt+8/S9xZlwwkWG1PlPMVhqKME8gM7ABoyAssUfp34=;
        b=TDlC5k3tmJl9h/tVnL9pcJsMxR/OpKPlpIdc6asSjSBfTmyEduX0iK5Lt1fB2oLugj
         t3iGjszqrJ4wqmZ0viu7+wo6/K6VLPDFQ3q/QfTKctnk9SvDMOtehdLqCW+miTxrK0+E
         Sm7bcb0BNLTCjJ4Enike0LoegDiT2z6W+EgwJ6X0k0PvTOckT6gwprI2ibcWOJKKhQ0o
         pNT1yeF1zNazBA7wxlvmQb7rRII2cbvzbKQ1IntzVDmccev6SD62vSsTGgyvqtnLGtMy
         3g8ciJqUs+f2mZB4wH2eT0RToAjROUJDLB3HrQvqYd/jyrqQjlWZN3T80wi09jLHOd+d
         x/nw==
X-Gm-Message-State: APjAAAWsK/SqZlPOuEGKAWW629v/AJ4lf9yiZ+iI4mSPncbhbWECdzt+
	qYk+oUlExTVxc2llOi8JW164zun2kAyDRwM+dcfb/GlWlJwcg8woDz6XgoGlLDWsbxN63DsN8T1
	cP5XbpIGDiLDLbuc5v18q1Hpa6jHmbssj17UoMw2WcAAqiTbZQjCT+Ct6mQrMOWmvvg==
X-Received: by 2002:a0d:d0c6:: with SMTP id s189mr22297177ywd.399.1557991862491;
        Thu, 16 May 2019 00:31:02 -0700 (PDT)
X-Received: by 2002:a0d:d0c6:: with SMTP id s189mr22297144ywd.399.1557991861524;
        Thu, 16 May 2019 00:31:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557991861; cv=none;
        d=google.com; s=arc-20160816;
        b=Pr3SQixSXIY5KaD9JaWKLDapjAqjO6ejRPAlq9Kf2be8kEshQkr8KW+UmPTIpWADoT
         WSaFl0UVD9KqnSn1sJQbdlLT9HeLYCth9IhPJDOwNEw/Rpw62BK45+cfydK6HaxhHGK8
         7SsYqtMEMG2p5p/O08bgtCJ8I92a4zbmUIffoQ6odDLlYih8IKmYWj4JjZRK/hB35kEO
         Oc8fv++hN3DgwzufUESe2GdLGroQaWAgi5eUuQ2qTJ5/kLF+LGxJHKP+wIbKYYrmdWtw
         hcqeMQoqVrL2BBOpeDmVaLx5LaRYZxUBmywRQFW1eYG5/ahQR0go4pYYzBwBvvD+8Qru
         qS7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=GVt+8/S9xZlwwkWG1PlPMVhqKME8gM7ABoyAssUfp34=;
        b=GfNqAwQk9Kw3+cO86MXkH6J6S5xuJP9DMZb7LwwParQDCWnOj7AhyBmT4yRI1n7nqd
         zCgRjFqTurcb4+T7Aiz0/xJp9fE3Q/FTWOJBABpQ172k+3tLYgcmJUUw0LX/kwPszZA5
         kIpK1s03PvVlNq/hfug84H6krcKibVqBZCbIwJiEKn/em4YORoOsX09trhzyFaDGymV0
         8pZwVTMLlbaH5HaM40npANdrWZCw4x66jtlWt8o2XI5mW0/n3n/OTqGCHIjmdWFxuKIk
         ApSvF5E/6u56Tt9r80yrAh4X7+SgnaU9K0+kYhvF9txIhcQREdKCk3A/74tnNFN8gdzX
         YNSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eJk9HEnZ;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j2sor2326534ybp.149.2019.05.16.00.31.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 00:31:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=eJk9HEnZ;
       spf=pass (google.com: domain of urezki@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=urezki@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=GVt+8/S9xZlwwkWG1PlPMVhqKME8gM7ABoyAssUfp34=;
        b=eJk9HEnZpy5U2y9EOA7OmV1mUJO7aXYGKOLcDadFsBWNQc3uC60k3YTQ1Uh006P22q
         bifZARk7Fh+rzkH9ZrqlL8cB9coRlD+p9X4cAFVCoJW4TSMWFXCU9HlUiUtWyLgXA5g0
         sMfgmVrGwO1UY8tRU1fQDwUo9b+G8PGgMT7tcVeCyc/qNb/3KfqBagoV5sSvAsK5+6zf
         B94OBTVPtZ/UmOHM/+iWfYdeQlt2UasXOkcV5dSG0v4v6xzSDXkM3mSl/vn2wiaQu6rZ
         J9ZTi5excR5pK2J2z2bvodQHWhrvt5yHXhRW3He2ahkcwP4/WUCNnfW7YmqPVS+NVM1K
         8BeA==
X-Google-Smtp-Source: APXvYqxmH29D0NGJed5QeuA1TJKhB++qYRpIKOeRtLdwclUShZBcDQER2VpLN7ON/03jITGEU8SZMviooA4+7ZRu5QU=
X-Received: by 2002:a25:9089:: with SMTP id t9mr23802417ybl.369.1557991860971;
 Thu, 16 May 2019 00:31:00 -0700 (PDT)
MIME-Version: 1.0
References: <20190406183508.25273-1-urezki@gmail.com> <20190406183508.25273-2-urezki@gmail.com>
 <20190514141942.23271725e5d1b8477a44f102@linux-foundation.org> <20190515152415.lcbnqvcjppype7i5@pc636>
In-Reply-To: <20190515152415.lcbnqvcjppype7i5@pc636>
From: Uladzislau Rezki <urezki@gmail.com>
Date: Thu, 16 May 2019 09:30:49 +0200
Message-ID: <CA+KHdyURm1xb1u4=aV97KQYFi0R_3=SJPBCezWqEB8hT=J8pCw@mail.gmail.com>
Subject: Re: [PATCH v4 1/3] mm/vmap: keep track of free blocks for vmap allocation
To: Andrew Morton <akpm@linux-foundation.org>, "Tobin C. Harding" <tobin@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@suse.com>, Matthew Wilcox <willy@infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Thomas Garnier <thgarnie@google.com>, 
	Oleksiy Avramchenko <oleksiy.avramchenko@sonymobile.com>, Steven Rostedt <rostedt@goodmis.org>, 
	Joel Fernandes <joelaf@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, 
	Tejun Heo <tj@kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

+Tobin C. Harding <tobin@kernel.org>

On Wed, May 15, 2019 at 5:24 PM Uladzislau Rezki <urezki@gmail.com> wrote:
>
> Hello, Andrew.
>
> > An earlier version of this patch was accused of crashing the kernel:
> >
> > https://lists.01.org/pipermail/lkp/2019-April/010004.html
> >
> > does the v4 series address this?
> I tried before to narrow down that crash but i did not succeed, so
> i have never seen that before on my test environment as well as
> during running lkp-tests including trinity test case:
>
> test-url: http://codemonkey.org.uk/projects/trinity/
>
> But after analysis of the Call-trace and slob_alloc():
>
> <snip>
> [    0.395722] Call Trace:
> [    0.395722]  slob_alloc+0x1c9/0x240
> [    0.395722]  kmem_cache_alloc+0x70/0x80
> [    0.395722]  acpi_ps_alloc_op+0xc0/0xca
> [    0.395722]  acpi_ps_get_next_arg+0x3fa/0x6ed
> <snip>
>
> <snip>
>     /* Attempt to alloc */
>     prev = sp->lru.prev;
>     b = slob_page_alloc(sp, size, align);
>     if (!b)
>         continue;
>
>     /* Improve fragment distribution and reduce our average
>      * search time by starting our next search here. (see
>      * Knuth vol 1, sec 2.5, pg 449) */
>     if (prev != slob_list->prev &&
>             slob_list->next != prev->next)
>         list_move_tail(slob_list, prev->next); <- Crash is here in __list_add_valid()
>     break;
> }
> <snip>
>
> i see that it tries to manipulate with "prev" node that may be removed
> from the list by slob_page_alloc() earlier if whole page is used. I think
> that crash has to be fixed by the below commit:
>
> https://www.spinics.net/lists/mm-commits/msg137923.html
>
> it was introduced into 5.1-rc3 kernel.
>
> Why ("mm/vmalloc.c: keep track of free blocks for vmap allocation")
> was accused is probably because it uses "kmem cache allocations with struct alignment"
> instead of kmalloc()/kzalloc(). Maybe because of bigger size requests
> it became easier to trigger the BUG. But that is theory.
>
> --
> Vlad Rezki



-- 
Uladzislau Rezki

