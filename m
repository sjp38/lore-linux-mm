Return-Path: <SRS0=ErOr=VZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8F7FC433FF
	for <linux-mm@archiver.kernel.org>; Sun, 28 Jul 2019 20:01:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4933F206A2
	for <linux-mm@archiver.kernel.org>; Sun, 28 Jul 2019 20:01:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="nTGxTS/J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4933F206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AAA428E0003; Sun, 28 Jul 2019 16:01:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A5A5C8E0002; Sun, 28 Jul 2019 16:01:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9220E8E0003; Sun, 28 Jul 2019 16:01:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 466128E0002
	for <linux-mm@kvack.org>; Sun, 28 Jul 2019 16:01:10 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id f3so37041532edx.10
        for <linux-mm@kvack.org>; Sun, 28 Jul 2019 13:01:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Ejm20Y4Kz3qQAGjgn7grvGG6B+WvKV1+ZQma7+eIPL8=;
        b=k5i1UdLvEBOzjy+kqZWIUtNbq1bhUR6yp0gNuObUCHDpjpNLVv4qnxItS6a6Uzv8sk
         hI1v5xyIbzpichLspykv9te6EbdxeYQfWAqigTi6W3anDEZQ468Db7QS/KoUpqQxdbYR
         wjVjgFkAYjQf4tgqFqpGb1rbSIuycxShyfUTuqKteTubrqzu6X3ezZpIPfR1Gf6PZSuH
         HToLa7KMOhf6J2ceK+7VqTMdUaz852iaLZeBy1HI/Rbya8UD9+VFDl/BgWYRl+Pq8uNR
         du0SkJXHVAIgTGepqX7aed5ZDtR3GibBNTwX2HAMkYKPf4sASaCsH+rjk8KFjuEK9Afk
         8bwQ==
X-Gm-Message-State: APjAAAXzbe44QJETR+A+UM9uFnqE+dUJSGAQ1tBURWYuG/9JSHGgyzFW
	m1GJtp3O/lp7cJVbMUSnhbK3mY9OTnqVd4Cbz2VRCdMQ1eNGKg8oyp4o0UQW3qkeRrbRYL9LD+0
	DC51Filv4y28gJb1i3zkfsV8w9NbXxTPJrHJ4cAZ+IdmUJuGSX6plA9iLJj4cJzDCdQ==
X-Received: by 2002:a50:97ad:: with SMTP id e42mr94313607edb.243.1564344069521;
        Sun, 28 Jul 2019 13:01:09 -0700 (PDT)
X-Received: by 2002:a50:97ad:: with SMTP id e42mr94313543edb.243.1564344068627;
        Sun, 28 Jul 2019 13:01:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564344068; cv=none;
        d=google.com; s=arc-20160816;
        b=R4gRacpYSgdrTdY6DjDBs7uoEfCQXJIO/gUyIfJPrAnI7q1qutqImtunFzmsmEFTuD
         0h5APuQmJA7qKhKSUfP6YWuk371AVkIR/D01IwzqnOfCf32EVAwHaQN09ezQvwxQfF1Q
         ffSbI+UZ6n1pl3PccXGdZz8FANGoQX16Y+ras2a3ia0fRgLisdJ1I6OsSa5CsG4rT4sz
         ny4XAvT74jOChStewBt3kpwM+bbhYHdbvZKzmJ8YjmgoRvIUm2F/I2fxTiVsS5jYM0kG
         LtRL+sGci7sCwWYYRdr6kyNAtPDkdhU+ofGaG+Z0tIuUEIEyvkQBhxmZI0HZnhKFMjLK
         R9PQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Ejm20Y4Kz3qQAGjgn7grvGG6B+WvKV1+ZQma7+eIPL8=;
        b=HH5Lb0kfFyFjGlcXHTm/QxsDQ5fFSolWPm6jGkNBsAGfoRpAhhKlA4eikwSBUBrS1T
         p3jjTsVlgoIxecWjP7nPMcbh4CPcjqXQZRTTZtyez8rtyct6wu3mNSXkx5xES6YpWGRD
         lBqnEOcM8L4ICvxvAbn1+/1Wv6FnW2x8fTYI6JtGy2OF+fg5qLfkiQ0b808sP/XUTimq
         zj9iaszxc2il7Yt+ToIi/tvVaZYgny26PsJKl/leHWC77p4yD+LDDaW840k+dl7Fn0NS
         wKBgoJi/1S8d2/yRWAyUIrgtxg5gR87oAiMXb1KNJS6HCDCiNDRDOiVbhjAp5imZl/cY
         DN1A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="nTGxTS/J";
       spf=pass (google.com: domain of matorola@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matorola@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n11sor16533327ejs.38.2019.07.28.13.01.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 28 Jul 2019 13:01:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of matorola@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="nTGxTS/J";
       spf=pass (google.com: domain of matorola@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=matorola@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Ejm20Y4Kz3qQAGjgn7grvGG6B+WvKV1+ZQma7+eIPL8=;
        b=nTGxTS/Jv3FkFSiVUwVt3eU3upA0PZep95o1yMzzmRbpzGHi72LM1Dn91gFiuJVklE
         QK3ewaEcpiveSbu8BDMIplVr3G1Py4DjJSCfYXLzcCXlXFghetCAW8m3JK5PE4x7vpvr
         BzMW23/7hYHfWzSqZ2uczEc8WLZsGPdJe+4oRKJyVZpxev5ObiocjYA3FYyM3XnBKmHU
         MHx+cRFpuye5JMZ8IQGhk7YAf58xXQZ8zU5zGGFAMiXb5r53/mNzfTEhWepzadFjKIS1
         OOspT6d9JMnoMmSmzIAY5tqXiDP/gVK2GaS86dHqlBbPmoe2VEsxj0/NWSjG3YHBwAAL
         3cHA==
X-Google-Smtp-Source: APXvYqx6e1jH1Ur0aG9EOYYD+HMwXocx7yP4Jc9Kg4wAHeNy/76HfFW+d9490J38ti3/OHDZj+IqVh4q5sOAPqy98MI=
X-Received: by 2002:a17:907:2177:: with SMTP id rl23mr82663915ejb.14.1564344068148;
 Sun, 28 Jul 2019 13:01:08 -0700 (PDT)
MIME-Version: 1.0
References: <CADxRZqx-jEnm4U8oe=tJf5apbvcMuw5OYZUN8h4G68sXFvDsmQ@mail.gmail.com>
 <20190724.131324.1545677795217357026.davem@davemloft.net> <CADxRZqw0oCpw=wKUrFTOJF1dUKrCU6k5MQXj3tVGachu4zPcgw@mail.gmail.com>
 <20190727.190929.2229738632787796180.davem@davemloft.net>
In-Reply-To: <20190727.190929.2229738632787796180.davem@davemloft.net>
From: Anatoly Pugachev <matorola@gmail.com>
Date: Sun, 28 Jul 2019 23:00:56 +0300
Message-ID: <CADxRZqwv_TUkGsbS5vHsdGXMadjf3MjYbW7WUPEenpa=iSo6PQ@mail.gmail.com>
Subject: Re: [PATCH 09/16] sparc64: use the generic get_user_pages_fast code
To: David Miller <davem@davemloft.net>
Cc: "Dmitry V. Levin" <ldv@altlinux.org>, Christoph Hellwig <hch@lst.de>, Khalid Aziz <khalid.aziz@oracle.com>, 
	torvalds@linux-foundation.org, akpm@linux-foundation.org, 
	Sparc kernel list <sparclinux@vger.kernel.org>, linux-mm@kvack.org, 
	Linux Kernel list <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jul 28, 2019 at 5:09 AM David Miller <davem@davemloft.net> wrote:
> From: Anatoly Pugachev <matorola@gmail.com>
> Date: Thu, 25 Jul 2019 21:33:24 +0300
> > there's vmlinuz-5.3.0-rc1 kernel and archive 5.3.0-rc1-modules.tar.gz
> > of /lib/modules/5.3.0-rc1/
> > this is from oracle sparclinux LDOM , compiled with 7.4.0 gcc
>
> Please, I really really need the unstripped kernel image with all the
> symbols.  This vmlinuz file is stripped already.  The System.map does
> not serve as a replacement.

David,

http://u164.east.ru/kernel2/

I'm sorry missed debug kernel first. Enabled CONFIG_DEBUG_INFO=y

