Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FB80C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 15:35:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BE4DA20693
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 15:35:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="fOWlZGWE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BE4DA20693
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2876C8E0003; Wed, 13 Mar 2019 11:35:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 236068E0001; Wed, 13 Mar 2019 11:35:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0FEBF8E0003; Wed, 13 Mar 2019 11:35:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id D2E798E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 11:35:48 -0400 (EDT)
Received: by mail-vk1-f197.google.com with SMTP id x207so767683vke.11
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 08:35:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=5fkZ1R4sQEMo0zPoMAkzRXZhF754qG1NDK5UVkeCsEw=;
        b=mdxS+mpqA2BXlgfwjMBtOduMeiLwHklZQMJHM4+GxpI+IJ2Pbr6sXHQ/gG027nzZfI
         uQTpwSrW7gQMRL9FunGReoNmjzsznf2NM+x7EGgSSeaoMBFEHcVcn5rBGgbMYDljFIyY
         iO0udsj+iUo9pBELGvchKpOE/o0dZlhHDtys7o9hdJLzugjUe7npGfDSnpqc+sFRHzQt
         CYvwc9yD+kxdbQ7VcEEmz2cWEHAiuj10Pw+yhs3i2uIBTWQCvPU9G7srR2StqiyfcwAW
         aWaedEX7nYOu3achS4w20e0MDLYXw//ht7a2gWwTGzwD4uzpX+wJ6rdtTMVa42yxlkoD
         wuzQ==
X-Gm-Message-State: APjAAAXIDEfwLeryq6ivQo+98ZpbQRVMNvxcl5Q35BupyRnbtoY75eez
	P5V6EREV7oziqPejKLFaQIIHThjJz0Nzz7pRs54cxtjHANbrM/3/JqjamfddVQCHw4cU/HU05bI
	YYEn7nHLehb7ZA+Ls+GwlVAfwdtcnWga0BQj1fcZ5waag6DdT0XnYTGxSn9O6phCdrHC9K0gqG+
	PWPSoYtYe1LxFIhTU2WqmB7AgSjdR9bOxmlBjqkqap0/705bcyLib8bHLG/571jhX6IQRwpMhGU
	li84HO4jO3RA6aca6fhbIiI13X1L7bJPZvdZi2HxnaOUaeHNY27HaXVlTAhAgVwkcVOIP9Uwh+K
	7EVMi0NhbPZRu4BBRcv6LoyOp//mC6kq9T3KNVKpeaO/tZJRUvUgQ0gYKtgtdl/MhbqgSQNo7Sl
	W
X-Received: by 2002:a1f:2acb:: with SMTP id q194mr22607606vkq.92.1552491348469;
        Wed, 13 Mar 2019 08:35:48 -0700 (PDT)
X-Received: by 2002:a1f:2acb:: with SMTP id q194mr22607562vkq.92.1552491347455;
        Wed, 13 Mar 2019 08:35:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552491347; cv=none;
        d=google.com; s=arc-20160816;
        b=GvO1FLh127XyFL3wXSxd+kdoDxyFytsUttFlIUb+KU9fdiUB/7bnhohLlOZQ4/GVQf
         eUvWjMarrw3kg8xMAaQc7rfkQaZjiZrPCPtxJHfDTKZcLw+DjI1n9EMbsiEtC3GqYKEp
         cm7mByTekgoZp3qZY5qFYT0g7g/vq+Wsx6eZJGxcf8TLh1+NMasJfqq4p4LIAKMq9kT4
         NfXsTNm1TEiXUPx3sgp6WBuL57PvB/n685CT5nXReXtKZa7a7R2///stG7detFjiiLnY
         FaKCLILsiA8FMK+pV9l6p6uVxUfo5Lbi6NBiSZOh6I7shQISZ/VRVwN4Nr5CeD4aofCr
         vM4g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=5fkZ1R4sQEMo0zPoMAkzRXZhF754qG1NDK5UVkeCsEw=;
        b=CtnDFjTJkhKDd83jruSAUkzyIUvQaa8pxSvne/xG7b6940pJCeHDiN4rXNbFYSPBrN
         ceMc310h0gm5dYdFo5iL6hAOembd9tZW3//WrXspyCEbnl6b2B2uOzQJvWLDLbsNdxIH
         w7ozPnt9sjF2NtKXrC7IH92bI2mywhKFsC5hyrn25NP+Zwo9n9s4TecUDC4fj0tf88pJ
         Scs9x+HF+HQ8DMOACQ6qO7ZqwQFhe4on+cuzqNQ6wbFOV34zlthilQUWKiaj2txISu7u
         UO1v4ug99qlNrG9qwbh1q7sdVEecvPgyoBm8A9to4UZliUru1+TqVDw+pfEHEdFZILYW
         GH+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=fOWlZGWE;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g129sor7310506vsg.89.2019.03.13.08.35.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 08:35:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=fOWlZGWE;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=5fkZ1R4sQEMo0zPoMAkzRXZhF754qG1NDK5UVkeCsEw=;
        b=fOWlZGWEVn0MCbN4pbgoP2zKmNPjl5jA0QapjarN8eTRKf1QL/YmUvEDHR3ddi8zwy
         v8z/Bo777HByP3RdljwTtmsASTcwt5WD/WhJ2GvsthQfGrJZUz91fNQPjKwJjhFAYG5U
         DIFR23GoaBYbVRf4aCoccz6Ld4KrTT7rjPcZY=
X-Google-Smtp-Source: APXvYqz9IVVALCCpl3721pm2fUK002AUSN0zM7sVVWKhB/07oRmPqvwrbMsyb+TIiuXOVqca13dLjQ==
X-Received: by 2002:a67:7684:: with SMTP id r126mr4643413vsc.219.1552491346372;
        Wed, 13 Mar 2019 08:35:46 -0700 (PDT)
Received: from mail-vs1-f47.google.com (mail-vs1-f47.google.com. [209.85.217.47])
        by smtp.gmail.com with ESMTPSA id m14sm745502vke.4.2019.03.13.08.35.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Mar 2019 08:35:45 -0700 (PDT)
Received: by mail-vs1-f47.google.com with SMTP id z18so1273657vso.7
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 08:35:45 -0700 (PDT)
X-Received: by 2002:a67:fa94:: with SMTP id f20mr7091272vsq.172.1552491344698;
 Wed, 13 Mar 2019 08:35:44 -0700 (PDT)
MIME-Version: 1.0
References: <00000000000016f7d40583d79bd9@google.com> <CAGXu5jKjWwYk5N3mOH1A8fXX_0BT3r1At_3MzN9M+Ckg5irKXg@mail.gmail.com>
 <20190313143503.GD9108@quack2.suse.cz>
In-Reply-To: <20190313143503.GD9108@quack2.suse.cz>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 13 Mar 2019 08:35:33 -0700
X-Gmail-Original-Message-ID: <CAGXu5j+_Ao_CU8DG9nrTbx5ioDkJUFw0cGcLBMWnvNLe_eFJ4A@mail.gmail.com>
Message-ID: <CAGXu5j+_Ao_CU8DG9nrTbx5ioDkJUFw0cGcLBMWnvNLe_eFJ4A@mail.gmail.com>
Subject: Re: WARNING: bad usercopy in fanotify_read
To: Jan Kara <jack@suse.cz>
Cc: syzbot <syzbot+2c49971e251e36216d1f@syzkaller.appspotmail.com>, 
	Amir Goldstein <amir73il@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, cai@lca.pw, 
	Chris von Recklinghausen <crecklin@redhat.com>, LKML <linux-kernel@vger.kernel.org>, 
	Linux-MM <linux-mm@kvack.org>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 7:35 AM Jan Kara <jack@suse.cz> wrote:
> On Tue 12-03-19 23:26:22, Kees Cook wrote:
> > On Mon, Mar 11, 2019 at 1:42 PM syzbot
> > <syzbot+2c49971e251e36216d1f@syzkaller.appspotmail.com> wrote:
> > > C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=17ee410b200000
> > > [...]
> > > ------------[ cut here ]------------
> > > Bad or missing usercopy whitelist? Kernel memory exposure attempt detected
> > > from SLAB object 'fanotify_event' (offset 40, size 8)!
> > > [...]
> > >   copy_to_user include/linux/uaccess.h:151 [inline]
> > >   copy_fid_to_user fs/notify/fanotify/fanotify_user.c:236 [inline]
> > >   copy_event_to_user fs/notify/fanotify/fanotify_user.c:294 [inline]
> >
> > Looks like this is the fh/ext_fh union in struct fanotify_fid, field
> > "fid" in struct fanotify_event. Given that "fid" is itself in a union
> > against a struct path, I think instead of a whitelist using
> > KMEM_CACHE_USERCOPY(), this should just use a bounce buffer to avoid
> > leaving a whitelist open for path or ext_fh exposure.
>
> Do you mean to protect it from a situation when some other code (i.e. not
> copy_fid_to_user()) would be tricked into copying ext_fh containing slab
> pointer to userspace?

Yes. That's the design around the usercopy hardening. The
"whitelisting" is either via code (with a bounce buffer, so only the
specific "expected" code path can copy it), with a
kmem_create_usercopy() range marking (generally best for areas that
are not unions or when bounce buffers would be too big/slow), or with
implicit whitelisting (via a constant copy size that cannot change at
run-time, like: copy_to_user(dst, src, 6)).

In this case, since there are multiple unions in place and
FANOTIFY_INLINE_FH_LEN is small, it seemed best to go with a bounce
buffer.

-- 
Kees Cook

