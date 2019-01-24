Return-Path: <SRS0=9gyo=QA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7AC61C282C0
	for <linux-mm@archiver.kernel.org>; Thu, 24 Jan 2019 00:21:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3182821872
	for <linux-mm@archiver.kernel.org>; Thu, 24 Jan 2019 00:21:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="PH9V0/KK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3182821872
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A9CAA8E0065; Wed, 23 Jan 2019 19:21:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A4C4F8E0047; Wed, 23 Jan 2019 19:21:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 93D4C8E0065; Wed, 23 Jan 2019 19:21:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f72.google.com (mail-lf1-f72.google.com [209.85.167.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2419A8E0047
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 19:21:01 -0500 (EST)
Received: by mail-lf1-f72.google.com with SMTP id l16so301914lfc.8
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 16:21:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=8I8uV3WmaHvuIIbILWs8wayzXWD2yoy7pULfBcUtKtA=;
        b=QIvOzgnj3I+ZKd4rYooRziWkTrj27SHmAyh0QlCsLA3Z1ijIN5vnVqB7umvcRTJ+/j
         693//poMa2Tjo4QQcEYPiQj6boGnxhG6VcwCvPLIwcZQi8rpXvMy01Dj3lpwR6oE5yiA
         ccm4/OmsnCQTn9rYawL5mmPgAOgb2DcRw4TdaWDGK6/ldu2P+1WIouC8QzQGoUxKM7wz
         PhPFPpO34PTEFPmh486MZ3bVd9Feuojb4QDLM21VW5CB+dRCbeSnnxQ6tqqgKVOtgUu6
         hmf8rYGO1CbyzGeTUkzzbFlBj5InccpLMWd8cf2m7d+bbdzitWmvtnNUneEuDz7An+zL
         dK6g==
X-Gm-Message-State: AJcUukfHtRjpOVq/JGRnMiJAPWu1ewF3lZmoaayj9FV6+AgNFG8Iq9iB
	yzygiXUJ5xGOv0Rnq2PhYWAz4mz9PAf34baGsxsZbuXKANYcwrLZGJ69HFKvXuLegs22+4ZubJA
	8DFT68nH0ZCHtoVKkNHAg30+uxa0sInf1JHsCTWQLr3/OtyJR0TOXs8qfsaCcL3WVZqvE2cXJs1
	uZVZqUi/lqWQe5eztMJOozTUI1O1CV/X0vPKvwUpw4ZITTG4wNnDGXeoSXFJVSzZqLtQY+k9HS3
	tYW9p1GpxvHpwmixn9iVHM/OksZmJWvw1j79vWfxKRDmhNu2DFoQ7JUIx2WlChrguwqd3ijSVW9
	UduPsDZdObE3VYgVuad6kSOXweE1K2fKZ5vw64GzziGauVtL6uHHvD9W4v99SgavPgX/skRIZPw
	A
X-Received: by 2002:a2e:9603:: with SMTP id v3-v6mr3609576ljh.15.1548289260119;
        Wed, 23 Jan 2019 16:21:00 -0800 (PST)
X-Received: by 2002:a2e:9603:: with SMTP id v3-v6mr3609540ljh.15.1548289259021;
        Wed, 23 Jan 2019 16:20:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548289259; cv=none;
        d=google.com; s=arc-20160816;
        b=qscFInR3tqD1wFN7NALmMrUhr+0mI0v8u9/XL0Gk8XtqjkxkXxwMcVmYqvVr8f1QAv
         RxQtUkKF+mpf3DX+WWCG5KmfQen31brXfEJtLiRY00B0QFb0NvEgDUt5D8P4toVUSJDi
         SGItheBovV1PyUGU3lzvzbSyM0ceinwBeAcs5kgjkjoA7Cr6Gp1gYumfr1dv1J7ZSI+Q
         PzyTJ6zGW6VYL2ugpHEfWUcq3zZ/P5S1AvfEPZjlWcIXDFLpt9Fk9LdAYR9jlB3M5/te
         +w9CTrWjd/oJlxwWzW3pJknBL5oqbJBEHoNj/j+330mEywR/WOkyvcqGh1sNepruJiA4
         pt3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=8I8uV3WmaHvuIIbILWs8wayzXWD2yoy7pULfBcUtKtA=;
        b=o+nkX3WdTwefsl4y2YaQfS9hFFEi8F4wUsgJhCxL5ZqZEZzbIYK6KiNn3BnpqgYScP
         kWzFS5oY5iMNll50JAkUiDoaXEskILHU6bsen6SRmxpOfYRl/xZWMam47ZRTYcpU0GVW
         C08UbXy3pRrJxN8agoRdbDXKc0B2ZM58C0j4qZIC09AlFZDfZCpP+aB0GvhqhNLg5H7M
         OSI2qCpCn82cRml0trysM1kbkdzxIx1df6o0PqUD80C5VBfCGn+x8HHI0vMx0nuzp23a
         8gw5bJXbe4qGlJJPjm2WBm10PoSp7LP9Lf77ng8VViPw+TIUbEAD0N7lGzXyq+ws0pb0
         KKWg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b="PH9V0/KK";
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m10-v6sor3283651lje.8.2019.01.23.16.20.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 Jan 2019 16:20:59 -0800 (PST)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b="PH9V0/KK";
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=8I8uV3WmaHvuIIbILWs8wayzXWD2yoy7pULfBcUtKtA=;
        b=PH9V0/KK92bXTEP81nt/LjQ6SSJLxS2F5++KT1VQvagruTtDYwwS38WCMe6QCTl1S9
         M/9QB21XB+xpradFhe9+OrMMThoKxz5UPxF1nlYho5qbehIWzvZfhcn0/eS81yXC++tg
         bTuEa1IIpQqjLr/qqfcnvuWomWwQUP+zq6EPA=
X-Google-Smtp-Source: ALg8bN4R15JVJNQ824TtDFzgOouqsUEV8+cAZ1lTVsVoYwFxz+z+yVdLM7wgfBoQLEUT/BKwc+2v2Q==
X-Received: by 2002:a2e:8045:: with SMTP id p5-v6mr3505700ljg.87.1548289257361;
        Wed, 23 Jan 2019 16:20:57 -0800 (PST)
Received: from mail-lf1-f47.google.com (mail-lf1-f47.google.com. [209.85.167.47])
        by smtp.gmail.com with ESMTPSA id u79-v6sm816187lje.36.2019.01.23.16.20.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 16:20:55 -0800 (PST)
Received: by mail-lf1-f47.google.com with SMTP id f5so2955099lfc.13
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 16:20:54 -0800 (PST)
X-Received: by 2002:a19:980f:: with SMTP id a15mr3398536lfe.103.1548289254203;
 Wed, 23 Jan 2019 16:20:54 -0800 (PST)
MIME-Version: 1.0
References: <20190110004424.GH27534@dastard> <CAHk-=wg1jSQ-gq-M3+HeTBbDs1VCjyiwF4gqnnBhHeWizyrigg@mail.gmail.com>
 <20190110070355.GJ27534@dastard> <CAHk-=wigwXV_G-V1VxLs6BAvVkvW5=Oj+xrNHxE_7yxEVwoe3w@mail.gmail.com>
 <20190110122442.GA21216@nautica> <CAHk-=wip2CPrdOwgF0z4n2tsdW7uu+Egtcx9Mxxe3gPfPW_JmQ@mail.gmail.com>
 <5c3e7de6.1c69fb81.4aebb.3fec@mx.google.com> <CAHk-=wgF9p9xNzZei_-ejGLy1bJf4VS1C5E9_V0kCTEpCkpCTQ@mail.gmail.com>
 <9E337EA6-7CDA-457B-96C6-E91F83742587@amacapital.net> <CAHk-=wjqkbjL2_BwUYxJxJhdadiw6Zx-Yu_mK3E6P7kG3wSGcQ@mail.gmail.com>
 <20190116054613.GA11670@nautica> <CAHk-=wjVjecbGRcxZUSwoSgAq9ZbMxbA=MOiqDrPgx7_P3xGhg@mail.gmail.com>
 <nycvar.YFH.7.76.1901161710470.6626@cbobk.fhfr.pm> <CAHk-=wgsnWvSsMfoEYzOq6fpahkHWxF3aSJBbVqywLa34OXnLg@mail.gmail.com>
 <nycvar.YFH.7.76.1901162120000.6626@cbobk.fhfr.pm> <CAHk-=wg+C65FJHB=Jx1OvuJP4kvpWdw+5G=XOXB6X_KB2XuofA@mail.gmail.com>
 <CAHk-=wgy+1YT-Rhj5qWb_aCuBADhcq42GDKHB74sqrnOVPKzPg@mail.gmail.com> <nycvar.YFH.7.76.1901240009560.6626@cbobk.fhfr.pm>
In-Reply-To: <nycvar.YFH.7.76.1901240009560.6626@cbobk.fhfr.pm>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 24 Jan 2019 13:20:37 +1300
X-Gmail-Original-Message-ID: <CAHk-=whVyE2TL4NpEgsSnx=w0Pf-vNBidJY9HEeOVLO-m=Mx+g@mail.gmail.com>
Message-ID:
 <CAHk-=whVyE2TL4NpEgsSnx=w0Pf-vNBidJY9HEeOVLO-m=Mx+g@mail.gmail.com>
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
Message-ID: <20190124002037.U24p3ddNExpBu_O5YypXDqUjrt4SDzOCDY0Sybf5ykU@z>

On Thu, Jan 24, 2019 at 12:12 PM Jiri Kosina <jikos@kernel.org> wrote:
>
> >
> > I think the "test vm_file" thing may be unnecessary, because a
> > non-anonymous mapping should always have a file pointer and an inode.
> > But I could  imagine some odd case (vdso mapping, anyone?) that
> > doesn't have a vm_file, but also isn't anonymous.
>
> Hmm, good point.
>
> So dropping the 'vma->vm_file' test and checking whether given vma is
> special mapping should hopefully provide the desired semantics, shouldn't
> it?

Maybe. But on the whole I think it would  be simpler and more
straightforward to just instead add a vm_file test for the
inode_permission() case. That way you at least know that you aren't
following a NULL pointer.

If the file then turns out to be some special thing, it doesn't really
_matter_, I think. It won't have anything in the page cache etc, but
the code should "work".

             Linus

