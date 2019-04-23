Return-Path: <SRS0=sydr=SZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98391C10F03
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 22:19:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30DF8217D9
	for <linux-mm@archiver.kernel.org>; Tue, 23 Apr 2019 22:19:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=chromium.org header.i=@chromium.org header.b="JHvP3Qc4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30DF8217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=chromium.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D32F66B0005; Tue, 23 Apr 2019 18:19:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CE21D6B0008; Tue, 23 Apr 2019 18:19:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BAA526B000A; Tue, 23 Apr 2019 18:19:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f71.google.com (mail-ua1-f71.google.com [209.85.222.71])
	by kanga.kvack.org (Postfix) with ESMTP id 900406B0005
	for <linux-mm@kvack.org>; Tue, 23 Apr 2019 18:19:32 -0400 (EDT)
Received: by mail-ua1-f71.google.com with SMTP id v5so2068276ual.6
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 15:19:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=5wd3juuCyGv6I7aWGEczXK2I2MkaE+Yk5Y+BNpedQc0=;
        b=ob//+HuChpMUKwPYyp7OZcbQ+VzN4+5bUU8MGM618Dyf4ZKt8JYWr+4Xw0q6nnwv00
         fG/z1aZZsegrXeLbKWgMZoIKeGDsqh37r6Fdpz3kEKj4AbTcVH7CwrcD0WHQ5ZNo01Po
         8aaCKjk35yBgg1K58EbClsyExVia2NoGXcxEHPhvdk2i1sjBECsKpAGeR/0TVRZuldBB
         Nb3BdYRXR1izN2SPuHXuN7dMeXT1ZO4GG+0Tvu69A+6T2mb0haKynumF4Xji7a0KCPWa
         ebSO2/ebu/u8+88la9yl2QOydi3l8rl6bYDr2i/P0TS7naJV7fOKOGo2KoAhROxjiY4z
         UmQw==
X-Gm-Message-State: APjAAAWyygnQnSlrAhkXK44dQsWspyQds2SG9gPVy2GUwLMaigOqt7im
	T2hDTrgpfSAJSkUXojfyTvDs+QVeY7cI2ZFaDzxk83srbMOcXa2vnkzsTmVbS1lMvOk3inFhv/+
	ixjrwqA8x4wtArwSkP21jSUDSGqbPAcNLKiKpamQ3hWHDXpUZ7mp0ZWjmWXuB0HhKPQ==
X-Received: by 2002:ab0:348a:: with SMTP id c10mr14468769uar.79.1556057972193;
        Tue, 23 Apr 2019 15:19:32 -0700 (PDT)
X-Received: by 2002:ab0:348a:: with SMTP id c10mr14468733uar.79.1556057971504;
        Tue, 23 Apr 2019 15:19:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556057971; cv=none;
        d=google.com; s=arc-20160816;
        b=bIkUEBzQNWD7FQpqDO/VUJmKVURBnbdKey5seikLXpB87luqZ8babW25sDOqzgBH5r
         nJqEoLJDbgbHqEa5jxZmVYN0CtGOfDQcy6+CZnvwuTR1vBsuk7Kv8kCmBZbgHJ5On98M
         xS9b4JIcXca6X1SP1D8ZTOhZm8KV9q0l//+BWVUOp2Fhm4SYpl9zi6XGI5f1tYHNKKgs
         ztplgsR/SkWwfeKkwbnRRwdCX8samwVGi4S/im3UfyI9w2iJEB/CZIbhkwKdZnT94Gov
         1F/5Y7UnKhu1Qh2bSFYVITkuCGeczPmr2nVu3fdUvyS3YZsayZJMMTyXqOMcFRtnJLJD
         rr7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=5wd3juuCyGv6I7aWGEczXK2I2MkaE+Yk5Y+BNpedQc0=;
        b=OTnOIsj9GF3iqABsc9gqIdx3KGHTGH3d/Nf4LtMitIf2SZYEKO4rRM7WDYhJf1oPmJ
         CLXLiQHghcXnQrdcnnm3wQLmmTMt8MQfiNlRfTzkPyQut2/8PsEp58WzHmLxiTihIAC2
         +xNm/OoyHbrqjp+TTVo0DTfXoW5ct8UXBEhRJwPaOg58F4IAqk9l3/HCZY+PcHB+8sUf
         82fD4QPgGsbUcz8gZXblTJVava4gqw5jAiwZucSNA1yiRbDRJ1JJUniBQhPinvYsAYun
         kv/h780OHT2E7mkCD4yjYu4A9doyqgGTfKGdzrRcbPssVaP26YWG290MEROUULyhHnfj
         LUbg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=JHvP3Qc4;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l11sor8334854uak.15.2019.04.23.15.19.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Apr 2019 15:19:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@chromium.org header.s=google header.b=JHvP3Qc4;
       spf=pass (google.com: domain of keescook@chromium.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=keescook@chromium.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=chromium.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=chromium.org; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=5wd3juuCyGv6I7aWGEczXK2I2MkaE+Yk5Y+BNpedQc0=;
        b=JHvP3Qc4kkkwAoF/0QYHWGplc3qsgSmh5NdB5v8VmADIDIKfxm29Zl03JyD4XVG9cK
         yzYYTUn+efgCCTi0FS+KzNAIgDktxEMhu5YO/Tot5RTlhcmQOOsrOxBqmB7so3nbTEBw
         AtVJmduRKOPMSxBxaCpYNVHVhvuORHcV1NhOQ=
X-Google-Smtp-Source: APXvYqxaDhMPHuv+bKYbdHMZyVOK02E1Jk4sg0Gv5gY4TbdUnyTfCzt1JFkGa0Wbnv2aqfHCxopbiw==
X-Received: by 2002:a9f:2d99:: with SMTP id v25mr13939110uaj.25.1556057970722;
        Tue, 23 Apr 2019 15:19:30 -0700 (PDT)
Received: from mail-vs1-f46.google.com (mail-vs1-f46.google.com. [209.85.217.46])
        by smtp.gmail.com with ESMTPSA id v22sm4469337vkv.35.2019.04.23.15.19.27
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Apr 2019 15:19:27 -0700 (PDT)
Received: by mail-vs1-f46.google.com with SMTP id f15so9228547vsk.9
        for <linux-mm@kvack.org>; Tue, 23 Apr 2019 15:19:27 -0700 (PDT)
X-Received: by 2002:a67:f849:: with SMTP id b9mr14894109vsp.188.1556057966875;
 Tue, 23 Apr 2019 15:19:26 -0700 (PDT)
MIME-Version: 1.0
References: <20190319030722.12441-1-peterx@redhat.com> <20190319030722.12441-2-peterx@redhat.com>
 <20190319110236.b6169d6b469a587a852c7e09@linux-foundation.org>
In-Reply-To: <20190319110236.b6169d6b469a587a852c7e09@linux-foundation.org>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 23 Apr 2019 15:19:15 -0700
X-Gmail-Original-Message-ID: <CAGXu5jJbgmq1QS-+FO7Oe9KLrAmT+ivUjSochmHBgbvHkuj+VQ@mail.gmail.com>
Message-ID: <CAGXu5jJbgmq1QS-+FO7Oe9KLrAmT+ivUjSochmHBgbvHkuj+VQ@mail.gmail.com>
Subject: Re: [PATCH v2 1/1] userfaultfd/sysctl: add vm.unprivileged_userfaultfd
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Xu <peterx@redhat.com>, LKML <linux-kernel@vger.kernel.org>, 
	Paolo Bonzini <pbonzini@redhat.com>, Hugh Dickins <hughd@google.com>, 
	Luis Chamberlain <mcgrof@kernel.org>, Maxime Coquelin <maxime.coquelin@redhat.com>, 
	Maya Gokhale <gokhale2@llnl.gov>, Jerome Glisse <jglisse@redhat.com>, 
	Pavel Emelyanov <xemul@virtuozzo.com>, Johannes Weiner <hannes@cmpxchg.org>, 
	Martin Cracauer <cracauer@cons.org>, Denis Plotnikov <dplotnikov@virtuozzo.com>, 
	Linux-MM <linux-mm@kvack.org>, Marty McFadden <mcfadden8@llnl.gov>, 
	Mike Kravetz <mike.kravetz@oracle.com>, Andrea Arcangeli <aarcange@redhat.com>, 
	Mike Rapoport <rppt@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, 
	Mel Gorman <mgorman@suse.de>, "Kirill A . Shutemov" <kirill@shutemov.name>, 
	Linux API <linux-api@vger.kernel.org>, 
	"linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, 
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 11:02 AM Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> On Tue, 19 Mar 2019 11:07:22 +0800 Peter Xu <peterx@redhat.com> wrote:
>
> > Add a global sysctl knob "vm.unprivileged_userfaultfd" to control
> > whether userfaultfd is allowed by unprivileged users.  When this is
> > set to zero, only privileged users (root user, or users with the
> > CAP_SYS_PTRACE capability) will be able to use the userfaultfd
> > syscalls.
>
> Please send along a full description of why you believe Linux needs
> this feature, for me to add to the changelog.  What is the benefit to
> our users?  How will it be used?
>
> etcetera.  As it was presented I'm seeing no justification for adding
> the patch!

Was there a v3 of this patch? I'd still really like to have this knob added. :)

Thanks!

-- 
Kees Cook

