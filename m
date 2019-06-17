Return-Path: <SRS0=4FFe=UQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 460DFC31E5B
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 20:09:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E830C2085A
	for <linux-mm@archiver.kernel.org>; Mon, 17 Jun 2019 20:09:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qf2k/45s"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E830C2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 898526B0005; Mon, 17 Jun 2019 16:09:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 847EA8E0004; Mon, 17 Jun 2019 16:09:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75D028E0001; Mon, 17 Jun 2019 16:09:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 54FC96B0005
	for <linux-mm@kvack.org>; Mon, 17 Jun 2019 16:09:14 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id g56so10317703qte.4
        for <linux-mm@kvack.org>; Mon, 17 Jun 2019 13:09:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Al3ctU5Ww8ocaVDWU/5q96TvOispLUizRV1CFtDfOaI=;
        b=S83LmPsBlebLlohZv9codZfK0pV4prIj8anY2wbaKN4dJo36xf2Yssv2WXnzWCGhLY
         A7vsfk6QkS8HknjTxSvigLeEWPqTjO9NZUC6e8aR2BysujY0gnr8LRlG8B3IwbE3hCjQ
         mqkepyhtBLMW8y8km/z0lN98gaaWs0gsFQMq0ZAQWS86Im4bvv1xXtXSXYQ7t7kCV1Ms
         r3AhPDmD/eo7LDpW7YpKlrOoHfCcz2t1r9C53uk9PgxplPzru6Cu3WRxCIbV4lIrlwrg
         XhHdiI8p5oY4ap2NC0I0At60laT/ghxWkouE7Vl+Btu+A2j0n+Ay2VRocQ4uvINZXNQp
         Te5Q==
X-Gm-Message-State: APjAAAUB10znSz0NmKEpNlaAxlA+u5py9xkszz3IXaOV+D/Rwuxr5TcH
	sZ2ydWpKB5IRRyFdbgXSjXxtOTYegO5Oq3vv/bd20suQOcg1R1XgezCxhDiGef4h9hLZKpDhwp6
	EqLPjOyOlAJQ/lx4aAAfzIoO06D2O3E0SRDQqcZ7xe7N4oYIAHbvViqfM+9QQFkDsEw==
X-Received: by 2002:ae9:f016:: with SMTP id l22mr52303095qkg.51.1560802154090;
        Mon, 17 Jun 2019 13:09:14 -0700 (PDT)
X-Received: by 2002:ae9:f016:: with SMTP id l22mr52303009qkg.51.1560802153128;
        Mon, 17 Jun 2019 13:09:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560802153; cv=none;
        d=google.com; s=arc-20160816;
        b=jlgiY6wCtcobsTOqhdSpO8wBXzrkR7AgptjZMK2IobwW6pvpINRtwYg7Ixe1fDQpJf
         +CaF6gqy/igvxdcJfCnDIZ4d4zVfRhxNz6hSZQ/fWtQqcQEHNde6/uVNC+U86ao9kgZA
         jhuJ36+Amm1y5ypqo71DLht5UCAOw62fX0+q2br1Jh6anAAZDIH33Q0jmfQxc+rw2gw9
         yMDkfTwRMmzg+d0+xhQYHAL1Qhojrjji0hqZa5oExEK4XPuZ13naQKns7H5QB9mamGcC
         BMclNBbb8xVA0Xt/zSGtSUT8G2XF+wa7n2pDwhKf+GrmBfcWl+hJkJxmvxFA65ldJjod
         PW0g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Al3ctU5Ww8ocaVDWU/5q96TvOispLUizRV1CFtDfOaI=;
        b=YUWlZLOlan2FYHFoO1ZhXAT2y6gsgyKQGG0Wys+u3cdjvtqfojFIey6zk7zNS8COFE
         uVs9b5twR7QNDC88bLKkq8PYXCzu31L3Fs1VV33vasTmTMKqT8feKAuzStJYVA+gRD32
         nGq6EKNgSvwvfDSi8W2Nh9kVhP4pNno8kzwMOen1QHnoAi4pBvIrXpstq01xCMkEI+rA
         hIcvrBELxm5Xq35sK4Gu2t8BEKCjq5g32gIh/6aSUdGaqe4tHjjoKZCD9tuNwbOlymgL
         rsapi/A0D0jw3C2VnFXcATyEZm/CtmJn4fjrSRPYv62gnqZTgFho32PX0Ea5Gc1s1v0Y
         CJVA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="qf2k/45s";
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n54sor1352942qvc.31.2019.06.17.13.09.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 17 Jun 2019 13:09:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="qf2k/45s";
       spf=pass (google.com: domain of mikhail.v.gavrilov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=mikhail.v.gavrilov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Al3ctU5Ww8ocaVDWU/5q96TvOispLUizRV1CFtDfOaI=;
        b=qf2k/45sE6OZ+Gh5+DRtXE3WIuJUZT2CIDmri09NlrXYO4Btj+toXNyiwRb328WTSY
         ddqXPu9rEVhtAPxNvE0K9CDxvTTzKJ0BWWz+j79PNc/TSbO8aw+FFoHXVc4o2PKt8xNE
         +8jsRM9cZr6cLlby+GvBWV52Ce9fzKzF9u5dyTb3FEfd/G/6GPisk3ItT0GKNsFAcRDv
         Gh0rYMhi8yC4VqJZqJDfvJ4y48ZkB4H1RhwI7V5LywTJZQ9BlboK1qHYtO6lb+CyKD+8
         6fQspClujju8RzhFtk3VEotj1QcxYEPM9LEK3PBmY3sBJLGUu0IjerGPEGXV8M4h1plt
         s7yw==
X-Google-Smtp-Source: APXvYqw0XOx8hWQvkZc6V+ztD3J86tZW+NikUxFcZSuurS8j1Clx/hKHsSn2WYyavAruZHjK33NHIYroa03/SQ/r7LY=
X-Received: by 2002:a0c:b66f:: with SMTP id q47mr23211411qvf.102.1560802152622;
 Mon, 17 Jun 2019 13:09:12 -0700 (PDT)
MIME-Version: 1.0
References: <CABXGCsN9mYmBD-4GaaeW_NrDu+FDXLzr_6x+XNxfmFV6QkYCDg@mail.gmail.com>
 <CABXGCsNq4xTFeeLeUXBj7vXBz55aVu31W9q74r+pGM83DrPjfA@mail.gmail.com>
 <20190529180931.GI18589@dhcp22.suse.cz> <CABXGCsPrk=WJzms_H+-KuwSRqWReRTCSs-GLMDsjUG_-neYP0w@mail.gmail.com>
 <CABXGCsMjDn0VT0DmP6qeuiytce9cNBx8PywpqejiFNVhwd0UGg@mail.gmail.com> <ee245af2-a0ae-5c13-6f1f-2418f43d1812@suse.cz>
In-Reply-To: <ee245af2-a0ae-5c13-6f1f-2418f43d1812@suse.cz>
From: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
Date: Tue, 18 Jun 2019 01:09:01 +0500
Message-ID: <CABXGCsOfQjGLEN0nAt-iPo2Ay61fDY75Deq1Xn1Ymm_UsR3n_g@mail.gmail.com>
Subject: Re: kernel BUG at mm/swap_state.c:170!
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, 
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 17 Jun 2019 at 17:17, Vlastimil Babka <vbabka@suse.cz> wrote:
>
> That's commit "tcp: fix retrans timestamp on passive Fast Open" which is
> almost certainly not the culprit.

Yes, I seen also content of this commit.
And it looks like madness.
But I can proving that my bisect are properly created.
Here I saved all dmesg output from all bisecting steps:
https://mega.nz/#F!00wFHACA!nmaLgkkbrlt46DteERjl7Q
And only one of them ended without crash message "kernel BUG at
mm/swap_state.c:170!"
This is step5 with commit 3d21b6525cae.

I tried to cause kernel panic several times when kenel compiled from
commit 3d21b6525cae would be launched and all my attempts was be
unsuccessful.

So I can say that commit 3d21b6525cae is enough stable for me and I
now sitting on it.

> You told bisect that 5.2-rc1 is good, but it probably isn't.
> What you probably need to do is:
> git bisect good v5.1
> git bisect bad v5.2-rc2
>
> The presence of the other ext4 bug complicates the bisect, however.
> According to tytso in the thread you linked, it should be fixed by
> commit 0a944e8a6c66, while the bug was introduced by commit
> 345c0dbf3a30. So in each step of bisect, before building the kernel, you
> should cherry-pick the fix if the bug is there:
>
> git merge-base --is-ancestor 345c0dbf3a30 HEAD && git cherry-pick 0a944e8a6c66

Oh, thanks for advise. But I am used another solution.
(I applied the patch every time when bisect move to new step)

> Also in case you see a completely different problem in some bisect step, try
> 'git bisect skip' instead of guessing if it's good or bad.
> Hopefully that will lead to a better result.

If you take a look all my dmesg logs you can sure that all bad steps
ended with crash "kernel BUG at mm/swap_state.c:170!".

And yes, I look again at commit cd736d8b67fb still don't understand
how it can broke my system.

--
Best Regards,
Mike Gavrilov.

