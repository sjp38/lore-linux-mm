Return-Path: <SRS0=bSwl=PY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DEC81C43387
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 17:48:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7E49B20657
	for <linux-mm@archiver.kernel.org>; Wed, 16 Jan 2019 17:48:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="W0lskNPy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7E49B20657
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DD5628E0004; Wed, 16 Jan 2019 12:48:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D84748E0002; Wed, 16 Jan 2019 12:48:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C742F8E0004; Wed, 16 Jan 2019 12:48:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5410A8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 12:48:58 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id 18-v6so1697780ljn.8
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 09:48:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=W+afB5wbNUEIen7GSS/LHpIEPOpjXFQl9X924ccGuhY=;
        b=E7BQraOMDGQh0Ql+0U30KdhmfurOZ1EjUu8HmqtY4pzBo6uk9nAjfyVJWM1t9paueT
         0EbLRo5/MAVD9jM/CU9GXdo1o/uAc6QtLwSmQrzGEWDxOoU4RcI4YqN0K694uGLJPfsW
         8FjiTyb/trhoC0BVENvy7ZfUKZ9nEp8WBcfSLauWtUb+RbGX5T1bmTiS/Pd4Z3Iw7DmZ
         Tv5TMf+puPn+YCRA3pq49vdprjagv3XieMpHmUA7GH8m+Y4GNSJkKr2i/8WKshkuhNoX
         CwsAYPZZrw5ySB+NToi6ckEXHMIQnr/bsDSf+Bhewh0G4u48gVeSsxFsvyeHfr58bYcT
         ZR0g==
X-Gm-Message-State: AJcUuke7DBabXRpf2tnqGtRmIWX6w/rr7EedhBW9w42N/8uXo70GmBpC
	FewHajr1IShoefvRptdtzH7aC/b9ydw5d5h9dAG4sr5VPfgHA/d0y5ClOV/2usFNYhZI9uOEnYG
	S+HH4mLURB6NV6Q/ui1xdKJbPgTCEYRQ0YYDTCwdOw5ktFIFdIGKdg4fOSC7RlMCTrW6KW4DXFH
	XlqQck5ZXEKRLb9wBTUQHN4+d0KI8qRrC1rRda3O0DYhdSE9laWU6j8PdA3ipUEBiuMVGigmKTn
	nTEr4evlOsLzpRfjIO2RtFPCZBToQHqQ8glaQh8J30/tn3z8OPXaeIwZpVx8UjZnIZ2Um/YKcj8
	pY/XjOm8JM+FhCTShLV2Rs9e1Jnfy9gkzTJqULf1B4U9xuepNNBHMZuq5atj+1QVwMASO8L7BqY
	L
X-Received: by 2002:a19:d58e:: with SMTP id m136mr8305354lfg.70.1547660937258;
        Wed, 16 Jan 2019 09:48:57 -0800 (PST)
X-Received: by 2002:a19:d58e:: with SMTP id m136mr8305288lfg.70.1547660936163;
        Wed, 16 Jan 2019 09:48:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547660936; cv=none;
        d=google.com; s=arc-20160816;
        b=lglM5VHMCaxyZ1lfmTwu2RzX+AFTWzNQcNPY2lZ6TVbD5y3W5PSrHkcS634vTHJKwr
         FjXiYkh3RzkknwbehPGNt5otl/DAg0FWU374taTEFQ3mGptI6mkYaonVq5YRULntjbuB
         BtulKJFB0gqZc4eDEGTVrSiKi73GpG4bg9VKO3ASPcGV5JrnKR/s4Sgd41mph/D9KTX0
         jOAo0vWSIDE/BzkimqcKfOTFXCCl4MLMBdsnrPRVPdUFheD30KsjZex+OEkUDLurNMfQ
         KRtRmc8nyXoKuqECzYQyrEbTPD4/ETbjLnWEgOcvRjTDE9kvotg3q+nwTl9oulQCuVHX
         dfwg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=W+afB5wbNUEIen7GSS/LHpIEPOpjXFQl9X924ccGuhY=;
        b=axquCXPml2XIX6fggOhxXxELauppuKZYQqqwltoxu2HweA8Ry7ugwTAjyD/ek0Q2bw
         leywmoHg/CTr+kXCrpUl+noLEWuvE8eOGdWuV7bpS6yNhnw9ENbNg2N7TO6icLLpwupm
         Qlt9wBVwDY5hZOkkpTrZ0gd7SiQ1b4oAU2qCLWZf0+9m3ZMnc2LJWSv03Bi2P6dNL6EK
         jcvxdVVNJjK3W0/INnt7TjOb5RSWfjL9e8IIaM7SgU75HmYmKdfhnXfS+1Fh9VfH1rCu
         EFUNo6vRI+Qx+j298I0Ntsa/zpM63/GjlZ7faM7mY/x7Fj4ix9CA7Kif+fmoEZH3gqfW
         Sd8g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=W0lskNPy;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k14-v6sor5268841lji.4.2019.01.16.09.48.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 16 Jan 2019 09:48:56 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b=W0lskNPy;
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=W+afB5wbNUEIen7GSS/LHpIEPOpjXFQl9X924ccGuhY=;
        b=W0lskNPyJGVkwBeCqn7hxuizmoco3Z9p/QtYyRASYKeE5U8WBWejOPMFzYf4XqcQKc
         CP9fTDmdGtWxjB6zod0u9NLNp3tceCfoA1fw/tnTdrduhvigUBxQsJOFBwlUqkIkldn1
         55/K5Ik7gtG5I9h5xV1/dC1/binLkK6pUsqtQ=
X-Google-Smtp-Source: ALg8bN7Y4VsRzsLJfZ062jBW8Bbi6yXG2AteCfXfChlm02Ru7agIeaCb9wRiZxEtQLKmUqJjaOMnjw==
X-Received: by 2002:a2e:2909:: with SMTP id u9-v6mr7474865lje.28.1547660934922;
        Wed, 16 Jan 2019 09:48:54 -0800 (PST)
Received: from mail-lf1-f51.google.com (mail-lf1-f51.google.com. [209.85.167.51])
        by smtp.gmail.com with ESMTPSA id d24-v6sm1126543ljg.2.2019.01.16.09.48.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 09:48:52 -0800 (PST)
Received: by mail-lf1-f51.google.com with SMTP id n18so5590665lfh.6
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 09:48:51 -0800 (PST)
X-Received: by 2002:a19:6e0b:: with SMTP id j11mr8122372lfc.124.1547660931486;
 Wed, 16 Jan 2019 09:48:51 -0800 (PST)
MIME-Version: 1.0
References: <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica> <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <5c3e7de6.1c69fb81.4aebb.3fec@mx.google.com> <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com>
 <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net> <CAHk-=wjqkbjL2_BwUYxJxJhdadiw6Zx-Yu_mK3E6P7kG3wSGcQ@mail.gmail.com>
 <20190116054613.GA11670@nautica> <CAHk-=wjVjecbGRcxZUSwoSgAq9ZbMxbA=MOiqDrPgx7_P3xGhg@mail.gmail.com>
 <nycvar.YFH.7.76.1901161710470.6626@cbobk.fhfr.pm>
In-Reply-To: <nycvar.YFH.7.76.1901161710470.6626@cbobk.fhfr.pm>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 17 Jan 2019 05:48:33 +1200
X-Gmail-Original-Message-ID: <CAHk-=wgsnWvSsMfoEYzOq6fpahkHWxF3aSJBbVqywLa34OXnLg@mail.gmail.com>
Message-ID:
 <CAHk-=wgsnWvSsMfoEYzOq6fpahkHWxF3aSJBbVqywLa34OXnLg@mail.gmail.com>
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
To: Jiri Kosina <jikos@kernel.org>
Cc: Dominique Martinet <asmadeus@codewreck.org>, Andy Lutomirski <luto@amacapital.net>, 
	Josh Snyder <joshs@netflix.com>, Dave Chinner <david@fromorbit.com>, 
	Matthew Wilcox <willy@infradead.org>, Jann Horn <jannh@google.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, 
	Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>, Linux-MM <linux-mm@kvack.org>, 
	kernel list <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190116174833.80MR4H8lotwQUg-rzlRRArluOD3tNZ5qZH5xgZRSi3E@z>

On Thu, Jan 17, 2019 at 4:12 AM Jiri Kosina <jikos@kernel.org> wrote:
>
> So that seems to deal with mincore() in a reasonable way indeed.
>
> It doesn't unfortunately really solve the preadv2(RWF_NOWAIT), nor does it
> provide any good answer what to do about it, does it?

As I suggested earlier in the thread, the fix for RWF_NOWAIT might be
to just move the test down to after readahead.

We could/should be smarter than this,but it *might* be as simple as just

diff --git a/mm/filemap.c b/mm/filemap.c
index 9f5e323e883e..7bcdd36e629d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2075,8 +2075,6 @@ static ssize_t generic_file_buffered_read(

                page = find_get_page(mapping, index);
                if (!page) {
-                       if (iocb->ki_flags & IOCB_NOWAIT)
-                               goto would_block;
                        page_cache_sync_readahead(mapping,
                                        ra, filp,
                                        index, last_index - index);

which starts readahead even if IOCB_NOWAIT is set and will then test
IOCB_NOWAIT _later_ and not actually wait for it.

            Linus

