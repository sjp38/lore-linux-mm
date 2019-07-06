Return-Path: <SRS0=LAVX=VD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40479C468AB
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 02:40:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E27342184C
	for <linux-mm@archiver.kernel.org>; Sat,  6 Jul 2019 02:40:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="YUs/UgR/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E27342184C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6BC536B0003; Fri,  5 Jul 2019 22:40:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 64E228E0003; Fri,  5 Jul 2019 22:40:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 50C7F8E0001; Fri,  5 Jul 2019 22:40:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id E39996B0003
	for <linux-mm@kvack.org>; Fri,  5 Jul 2019 22:40:00 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id r16so2500191lja.9
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 19:40:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=fd4Y87tY8rXvKyCsNSuOPm1j51lFjgKYC9nK5pdmnzI=;
        b=DFlhQN9046wv502gA692dr7r1YTdrXIm7xro0FNkRIPXqMawKUCC8TLxBlbBjzN7QN
         7uXM4kmZIl7q4x5mt/LT2K+Hqx+6P7ASCxHSSzYJERrn3jWXwsm/h0gu8YD3Cp60M5fD
         n6Hb5AaLZZMoRLixUwRkN0EIrYB9L8M1MoiDA+9cFrU65WxKkaWIoC5aKzHgWQ/HtsPF
         MkJ5YgVBYB1qsxg0r5/cNCGrLulObeyOEC0pGN2SUwFyDLTn6XFP8AlHUyhx8pjlMcS/
         Jt2qilgvyleDN/v5Fe2dp+JOsnGJXkb3c14B6FEaPv4qmrEAUvmwIwNGEKwUGOx7fV65
         G0kQ==
X-Gm-Message-State: APjAAAUUtZ+p6gFp/AYJiPLikFsnOQ3lIuRhBxwyYjAHsogV0pNhm7/E
	L2bdskbGc9UqQYAh5XDVqmS0Dh4aNP6oqwfmB9ww5O1CaF86RofWEcIhAuu68SXo+/ooizeB1uH
	cwAZ2bj+EfuMOs+B+Q5qo4kgVoxGdid8lHjuGgRa7MDzqm40fvBrGdDAqKd6hWTj1Ug==
X-Received: by 2002:a19:be03:: with SMTP id o3mr3316207lff.88.1562380800132;
        Fri, 05 Jul 2019 19:40:00 -0700 (PDT)
X-Received: by 2002:a19:be03:: with SMTP id o3mr3316182lff.88.1562380799283;
        Fri, 05 Jul 2019 19:39:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562380799; cv=none;
        d=google.com; s=arc-20160816;
        b=TLXnPsJsbZXSn769ycmhOVbxgXmmoOBQgdoHzTVZb8DyF/PVY5GfOTtm3aIr2+fil1
         +s/q02tQLDyPm8yPOCaNAyEAvCFs6CmjBDb9rw2sJxb0uwfaYTferRBk7Znf4iO6VJwr
         PM8KZG416ZzxDfgQ1FZwmQsRv7+1uAWlL9k5avJAqoLw2hRX4l2ICNQanHVYyxpM0kQA
         YjbaMqmbJTIkrTQkbcWaWoCPOWZjlyBRDehAUWbp3IzAYFzv33v4YiEjiKcAfwMfjYJy
         69rapingojEt8fJjmm9IC3flpFSN+wzBtl3ObBJSRVc9jRk/xRfsE6xhQGEFuAaEhE6y
         U+Uw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=fd4Y87tY8rXvKyCsNSuOPm1j51lFjgKYC9nK5pdmnzI=;
        b=eIkVUU9TiHluDM/oxyxQMMNbDbi0/b/6t0FDqVYGglnQFOd+MOQJzEvq2IVt4rQ0/c
         Vbhh5cqNoaGjINzVPdF9qSng5TJ+7OCzeWHeKv2TKrIrfdxKpPnWUp39Z6SHu2dI8dJn
         SFnYpXlspjahELHTSLH7c7K6DIB8WWtzDxQXfJ8cOzD6FCa6YSuKShyKJ40AnTu5kR9q
         ysKgGlcX/zEVZlVDsFIKQqX058yaoZC4iw93mk3sgPSMD6h+Z2dxlfTsmkojfsP2SUPl
         EMKWld2Gj1ronks5FdCpJAk/qwwfGzNXg+RXCsKQ4Fmaw7qEewAzHArYYaFzTJrevX7p
         ERwg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b="YUs/UgR/";
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id w5sor2819796lfe.19.2019.07.05.19.39.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Jul 2019 19:39:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@linux-foundation.org header.s=google header.b="YUs/UgR/";
       spf=pass (google.com: domain of torvalds@linuxfoundation.org designates 209.85.220.41 as permitted sender) smtp.mailfrom=torvalds@linuxfoundation.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=fd4Y87tY8rXvKyCsNSuOPm1j51lFjgKYC9nK5pdmnzI=;
        b=YUs/UgR/8Hp7wwsb7zpTWwyIpunZ8Ebmdz6mmomdXNFvrtT0rRerwLe2HTG10s2mHE
         lmdb6ncApNQ00nd78WB80+xcJxIJpf6hoJTJX8vUIjCCV8E+4N5q+5IkIJ6NvUbWosRq
         Wdf/Rw9vCEZYTXwhGdCGNqUuAlzpv1DIpsCBo=
X-Google-Smtp-Source: APXvYqzZTK8Psa2KdTQPqHaaD2/S7MGx9r6L8xF7TlKRG+F64wIdMgAS76xUNVV3YtmYY6+OFlBisQ==
X-Received: by 2002:ac2:514b:: with SMTP id q11mr3389546lfd.33.1562380797515;
        Fri, 05 Jul 2019 19:39:57 -0700 (PDT)
Received: from mail-lf1-f45.google.com (mail-lf1-f45.google.com. [209.85.167.45])
        by smtp.gmail.com with ESMTPSA id u13sm1653402lfu.37.2019.07.05.19.39.55
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Jul 2019 19:39:56 -0700 (PDT)
Received: by mail-lf1-f45.google.com with SMTP id q26so7408614lfc.3
        for <linux-mm@kvack.org>; Fri, 05 Jul 2019 19:39:55 -0700 (PDT)
X-Received: by 2002:ac2:4565:: with SMTP id k5mr3364080lfm.170.1562380795305;
 Fri, 05 Jul 2019 19:39:55 -0700 (PDT)
MIME-Version: 1.0
References: <CABXGCsN9mYmBD-4GaaeW_NrDu+FDXLzr_6x+XNxfmFV6QkYCDg@mail.gmail.com>
 <CABXGCsNq4xTFeeLeUXBj7vXBz55aVu31W9q74r+pGM83DrPjfA@mail.gmail.com>
 <20190529180931.GI18589@dhcp22.suse.cz> <CABXGCsPrk=WJzms_H+-KuwSRqWReRTCSs-GLMDsjUG_-neYP0w@mail.gmail.com>
 <CABXGCsMjDn0VT0DmP6qeuiytce9cNBx8PywpqejiFNVhwd0UGg@mail.gmail.com>
 <ee245af2-a0ae-5c13-6f1f-2418f43d1812@suse.cz> <CABXGCsOpj_E7jL9OpMX4wZbMktiF=9WOyeTv1R-W59gFMGC7mw@mail.gmail.com>
 <CABXGCsOizgLhJYUDos+ZVPZ5iV3gDeAcSpgvg-weVchgOsTjcA@mail.gmail.com> <20190705230312.GB6485@quack2.suse.cz>
In-Reply-To: <20190705230312.GB6485@quack2.suse.cz>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 5 Jul 2019 19:39:39 -0700
X-Gmail-Original-Message-ID: <CAHk-=wjV7HdJ-Dgv6OYJ5c9iY_pOWqryNy1BU3MdZrjsUJdVkQ@mail.gmail.com>
Message-ID: <CAHk-=wjV7HdJ-Dgv6OYJ5c9iY_pOWqryNy1BU3MdZrjsUJdVkQ@mail.gmail.com>
Subject: Re: kernel BUG at mm/swap_state.c:170!
To: Jan Kara <jack@suse.cz>
Cc: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, 
	Michal Hocko <mhocko@kernel.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Matthew Wilcox <willy@infradead.org>, Qian Cai <cai@lca.pw>, 
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, songliubraving@fb.com, 
	william.kucharski@oracle.com, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jul 5, 2019 at 4:03 PM Jan Kara <jack@suse.cz> wrote:
>
> Yeah, I guess revert of 5fd4ca2d84b2 at this point is probably the best we
> can do. Let's CC Linus, Andrew, and Greg (Linus is travelling AFAIK so I'm
> not sure whether Greg won't do release for him).

I'm back home now, although possibly jetlagged.

The revert looks trivial (a conflict due to find_get_entries_tag()
having been removed in the meantime), and I guess that's the right
thing to do right now.

Matthew, comments?

               Linus

