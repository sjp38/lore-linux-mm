Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CC98C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:52:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 36C4D21B25
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 18:52:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="ncBVT9ty"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 36C4D21B25
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B8F9E8E012F; Mon, 11 Feb 2019 13:52:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B15778E012D; Mon, 11 Feb 2019 13:52:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B8338E012F; Mon, 11 Feb 2019 13:52:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 555608E012D
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:52:14 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id f3so9008367pgq.13
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 10:52:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=onajfLzjwMOVtd+is/9izGJShjdIldm5SizvaLUaHmo=;
        b=AlTxo3kDmIq0wA8gZuz6mtVaTjYxvPLMiIHdam49vdf1LlXSRni1UN1OObW1JAGvTs
         3PDCqXQSzVf1DyXgHwbiy3CaPxR6Zylv+VqNEy7cSchrfwWZHNgUpCmqVJrlGgx7/2TB
         81qBdaNnHAkUjYEEGY2Fn0kbzjOiWnkrXUtgeWKVsdKsZ0+Zc519zu2DkjWw/8h4OcZ1
         bLq6JYSiSuldj/b1UQTsnhoGqQL/qFBeWEWoBY+9ICQA0fhEHKr3qrqhYiRgd+nmovJj
         FsXMrc99tg0qnqdwsYDJQn1zXm+LR1oRnSZGmYz2DP8XxZoEyLHNb0ht2UvS5rPC+1Px
         1FYg==
X-Gm-Message-State: AHQUAuZ8yFvSUSd4SsQeYYBxCM7EueJwUd0rHt5gkD/yP1gT/DF3GfLd
	SCwckk3Urzwg8krKhjHEwMPG/Sofotfy2lhfTfJsc7TPRsqj5ETBzG8LywlVm+cPE/HUN3q01z5
	ESBXOUvWZ/jSFi5vWl7SIbhckA2RLvwItYjRAsfaIfcVkI1nJsC8u+mciUHEItScgpEUHhH/CYr
	C2gM5nNsEz026CsCHSOjNwGGZLpjpHTKlc15YP1Orjyxf7NFPGdQ+5ZH58XrI4V6kw2K3I0v+TY
	59shV2cc90/U2tNp42s4LiMzkcY2KjCjtjxhgMTd/kTDC3v8yJpt7X7l0MDm8LuSpqSCjgRMBY3
	C41XbdwWSK/ZskXtj5TZeTfRDY7gEcMWRtwSmOBvoJ0d4QP9UfuFd+hqqQnU9TQrWRIzulLZbEh
	X
X-Received: by 2002:aa7:854d:: with SMTP id y13mr8415875pfn.175.1549911134018;
        Mon, 11 Feb 2019 10:52:14 -0800 (PST)
X-Received: by 2002:aa7:854d:: with SMTP id y13mr8415815pfn.175.1549911133343;
        Mon, 11 Feb 2019 10:52:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549911133; cv=none;
        d=google.com; s=arc-20160816;
        b=KvPlB3m49rpoGQ1YIdTeNrqS0UhIH+ifh0llam6p7MVK/BlPPG3Jswck+Sn2UZBbVo
         8b8+pZK7t6WQvA/1i7sVUleDO3xV1hgIkqJbsyrGxIQlzNsbCaxx+YBcRYSuz9OEYCI2
         6D7OeuCFYalQ/Uyx/gsDguqGem39BfopG0mpWpjDuvP3LYJftpqJRl14gPoCOKFnQm18
         E7S3elhFalQ/I/Q0ZrOfBXpelE2r9of547NzEJczZgyzxriDOCizC6/WweA9jMaF8gn9
         3zX+G5gIHotBwFKjajNQlW0HEWWG8JWhLbOer6bGiiH1xN2mhDy4JzA4V2ag5GU1fQLP
         dAHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=onajfLzjwMOVtd+is/9izGJShjdIldm5SizvaLUaHmo=;
        b=vR4Bw3GVZmWaddEDFZPw/42bBWLMWtgSJa4q9Xui8R4BOYZSuNSEp3Pu6ZKsqzV+Ru
         95kppbEPW0WqJ/QxnTFOGPkz4WigwqyHDD6luS8PlkOV/ra8BzYMJI/vOKRolfzSvQ/n
         SJ99Ys0cgvedraOZikt+bRbUE5VpsUM4GQL4KIawneVKxfzp1jy/kDRrZUpOxDS7MjN7
         G8ozMHDwONesEy6eMexzjFpxZMAtwlpOM4MX8TxP0L+SzwWxIaq7TOzTOD+MOuqaIe7Z
         uXW9hw+Cg5drd2bTRVD5+RN+LvuFlh16XwfU1xL8Baf39/7cgNkJk8Sf04g7DQwBvJSF
         X/AQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ncBVT9ty;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id d82sor16017301pfm.4.2019.02.11.10.52.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 10:52:13 -0800 (PST)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.41 as permitted sender) client-ip=209.85.220.41;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=ncBVT9ty;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.41 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=onajfLzjwMOVtd+is/9izGJShjdIldm5SizvaLUaHmo=;
        b=ncBVT9tyNIxZ8aiOn7dnre8Goggom0TvQuIANUcxYHYcAfeeDAW/pJ1tXT7OKgQueF
         MwVqVQuXrOqAtT08VYAKSwE++I0VmP13ZxXyhW0aHCvpPht7QPP8DsjyNB1q9UiS9QQl
         9nis0PU6XVMI930sTgtUCXc+fAmTp6gsgaaqqrv2IrcDnHYa8QQ6hciHJK6+lgRilZhN
         KdqVMLYVj7G0Grzr3UxJ2Dq0ijc+Xx3ACM1wwRK1oFZm7gwjlXdLXp02XnnVh4GoMf0t
         Uhm7OacraCe04mXWaJ3y/+i8oWGZKM8zgc/nBhN60h1PI8Pp5idnG3RIVGXQVzve/sCh
         iKDA==
X-Google-Smtp-Source: AHgI3IZQFoZrbycn++mXjdTEjZaF9ayC32KEiKRH0Wc/WBMk/e+oR/Sql4ixUe/6CE8nd6+lelEMoUAztsut/G+K/Ak=
X-Received: by 2002:a62:6047:: with SMTP id u68mr37586266pfb.239.1549911132174;
 Mon, 11 Feb 2019 10:52:12 -0800 (PST)
MIME-Version: 1.0
References: <b1d210ae-3fc9-c77a-4010-40fb74a61727@lca.pw> <CAAeHK+yzHbLbFe7mtruEG-br9V-LZRC-n6dkq5+mmvLux0gSbg@mail.gmail.com>
 <89b343eb-16ff-1020-2efc-55ca58fafae7@lca.pw> <CAAeHK+zxxk8K3WjGYutmPZr_mX=u7KUcCUYXHi+OgRYMfcvLTg@mail.gmail.com>
 <d8cdc634-0f7d-446e-805a-c5d54e84323a@lca.pw> <59db8d6b-4224-2ec9-09de-909c4338b67a@lca.pw>
 <CAAeHK+wsULxYXnGJnQXx9HjZMiU-5jb5ZKC+TuGQihc9L386Xg@mail.gmail.com> <20190211121554.GB165128@arrakis.emea.arm.com>
In-Reply-To: <20190211121554.GB165128@arrakis.emea.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 11 Feb 2019 19:52:01 +0100
Message-ID: <CAAeHK+x5J_eYm+3qupptBK5gWLqkz8OM=UCgRdrKb=u0s4yxxg@mail.gmail.com>
Subject: Re: CONFIG_KASAN_SW_TAGS=y not play well with kmemleak
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Qian Cai <cai@lca.pw>, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, 
	kasan-dev <kasan-dev@googlegroups.com>, 
	Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000001, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 1:16 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Fri, Feb 08, 2019 at 06:15:02PM +0100, Andrey Konovalov wrote:
> > On Fri, Feb 8, 2019 at 5:16 AM Qian Cai <cai@lca.pw> wrote:
> > > Kmemleak is totally busted with CONFIG_KASAN_SW_TAGS=y because most of tracking
> > > object pointers passed to create_object() have the upper bits set by KASAN.
> >
> > Yeah, the issue is that kmemleak performs a bunch of pointer
> > comparisons that break when pointers are tagged.
>
> Does it mean that the kmemleak API receives pointer aliases (i.e. same
> object tagged with different values or tagged/untagged)?

Please disregard that comment. This is a bug in KASAN, will send a fix soon.

