Return-Path: <SRS0=mZRB=PG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7BF51C43387
	for <linux-mm@archiver.kernel.org>; Sat, 29 Dec 2018 21:33:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3041720815
	for <linux-mm@archiver.kernel.org>; Sat, 29 Dec 2018 21:33:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="UlE4B7+F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3041720815
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C570D8E0069; Sat, 29 Dec 2018 16:33:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C06998E005B; Sat, 29 Dec 2018 16:33:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B1C988E0069; Sat, 29 Dec 2018 16:33:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8213D8E005B
	for <linux-mm@kvack.org>; Sat, 29 Dec 2018 16:33:05 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id k69so7356132ywa.12
        for <linux-mm@kvack.org>; Sat, 29 Dec 2018 13:33:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=IYFvICSJkCQtftzZlZjdaG+P5ndvp4JYx4OmGQFlpEk=;
        b=eTpOqOfD55lvtsYoHx2jLM672Mr3ZcscOb+UoS9N6V0WhHb/6nemIpovTheR85WJ37
         TmXGcI1Z1zSdY/eEQSbXMiEuKpm+Mr7c7vlRhw1ZUwaAI58yG1BU6tcGeu0jCXNa9vby
         Zi6e143JiOABJSRS7VsNfFAoHj35lmyWJiB6GIUYCqsCT509yZMxkfoRxQQghChm/R+4
         ipEQef4H3z/9+w7rEtATnsUYWVm5lnyX3iEgYEskcyhb7a2//KXlwW7IGeVd6emckfYh
         tmPaQ1mTkaAG14NIPguIZ+M0ZuPQeP/FS3c3qyQFWwxEjNhA2dH5XTUAMmkKp3+jCxwy
         R7Pw==
X-Gm-Message-State: AJcUukeiz7F18m2z0Jxp6m1Z4lFSoV2y1oCdSqcNTfWfYpTj7/3VoJvM
	OTqmtNSYgdBSIsGibmbQXyD66s1LrBmMvFnykiRABGgQwnmIsoy1JPsbkEhKffKJegSf7/MBw/6
	SI5S038R2feuY+t4hEhWutvb7UfWYARLZ91lOhvdlptu8VBWVlEaG80fgleKp8Wv06DkRCgOBMl
	xgPDn/UqvyWNVTrkvZW5zRxf0O0hrf0BCq6FqQYKlx2waimJzgZ6J+JoSn+L2fvN/f3SuGYGbV5
	RWoNYdTIuBR8l5a9z/Dgtjjq6QrPVQ1jycyBxuCCe49WQ6OQYLj6+EVBMG0IEwqpptkKm6yzV5f
	iquz83QIIdDPlk02WtyozceZGhR6Bwd1XfWfQd9gOpNr+9WoCwt6jTRWrUoIgQqAWXfHptV8ZPh
	O
X-Received: by 2002:a5b:352:: with SMTP id q18mr5131219ybp.371.1546119185184;
        Sat, 29 Dec 2018 13:33:05 -0800 (PST)
X-Received: by 2002:a5b:352:: with SMTP id q18mr5131207ybp.371.1546119184689;
        Sat, 29 Dec 2018 13:33:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1546119184; cv=none;
        d=google.com; s=arc-20160816;
        b=dcUc+z6xUZH/iXOtHiRP6PWF+CMlFWJ3Td7UKk0pRSLCcil/JTmd0Du4hwsEY1MaAl
         UPIHOjbpCCh5djLU9OIxlnbG+LEtgdwzZYATprvqbSVniJdrKKvgdAl/2YIpI42gVeiV
         35myAg4416ErdvgrkjzxAgO4IlD8/v0fLjvABU49jysFno6urakxfIbf/cnLY6+s3+fN
         GeN3OZxS09N+kjD3s+fS0th+4tJ4euEmkTKl9mMUdYRxP+wWULXC9ZlOK/z/jA9BGmhu
         1Km1v+DOfVYEyEpPu0ea6rr+OG3R7589r+LYHpKeFCff4hketc0F0u+jijn0A9XJ++D7
         e9dQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=IYFvICSJkCQtftzZlZjdaG+P5ndvp4JYx4OmGQFlpEk=;
        b=O0OoDsvtHequvCWJHOAgjHk7vI6N6rLVAviJA4gwus0FZaF42V2yqiO6jAIuffq8yt
         o/ccMqG8wqNvb8mNQnWakHUrvuNMMyeFBv9jjWInBgcaCjpB6B+yhrMZa73BiWEZPQw0
         097GNZbMm7WZ5n1o58CJi9UN/TgPFVtS5J/C39zT9qK59M+JfGZUShcU4RqHsei69kIE
         1vrK8XmgA5d89ZsXDU1bIXfz6NQDInYHCdWYQXyk6P6ZuYEIA3tmUo+QVSq/XZKXRlXm
         rR3eRKkCG0zOVR5l5Q+f7baDlaFLHNSv/zx0p1mLN00Xegh0AS6mhV3BbwK8HiwMffUA
         tiDA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=UlE4B7+F;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o192sor6172633ywo.136.2018.12.29.13.33.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 29 Dec 2018 13:33:04 -0800 (PST)
Received-SPF: pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=UlE4B7+F;
       spf=pass (google.com: domain of shakeelb@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=shakeelb@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=IYFvICSJkCQtftzZlZjdaG+P5ndvp4JYx4OmGQFlpEk=;
        b=UlE4B7+FiIiMBKb3LEHrxeyseaMIlTqJrh/POxLF2jVXJLe80F0OZep8hAz8GMy9m+
         BAmArypN4990a8PK/Plt4jlecmt5oTcIU6wX3G0GFK4bEtgdG1l3/zBURqY+LEGtvYr2
         HvXY1s2eqBM44LdZW85DiTOfMveSvrXUwkW5qJko19AaG+0lcPBPKoccgpgJTkJdk0mj
         BpKzLkrBWMiR4fnCkXfzd88D0TQWNjtHmrTxxU8ClS5OMBZ6sxNeduzoL+r6zc/PislS
         JYoUjVhtP66I9pt15Fasip3PvIvqd3WE+lgpMQGjf8tAAXuEEvTow9W8dOirN43KZAKk
         ijZQ==
X-Google-Smtp-Source: AFSGD/UpJWc5KqV55JRDLH8Ip/Q/CegVG7mhQ75txjoDgXsGHPFBGvKlqCmlh9dH/QJ9C62pyi9ux0/zsKlj/DJ0fMM=
X-Received: by 2002:a81:29d5:: with SMTP id p204mr32577434ywp.285.1546119184209;
 Sat, 29 Dec 2018 13:33:04 -0800 (PST)
MIME-Version: 1.0
References: <20181229013147.211079-1-shakeelb@google.com> <20181229130352.8a1075da5b7583d5e0e4aa9a@linux-foundation.org>
 <20181229212619.GB73871@dennisz-mbp>
In-Reply-To: <20181229212619.GB73871@dennisz-mbp>
From: Shakeel Butt <shakeelb@google.com>
Date: Sat, 29 Dec 2018 13:32:53 -0800
Message-ID:
 <CALvZod6SPOUA-kx8g6s+HXXGQ3gJ5FPc=hjpWs7ZBpJi472xbQ@mail.gmail.com>
Subject: Re: [PATCH] percpu: plumb gfp flag to pcpu_get_pages
To: Dennis Zhou <dennis@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, 
	Christoph Lameter <cl@linux.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181229213253._x3gQEszBAWdLMupD1p9D4OPFpd_5K4XAWLZJE78HJk@z>

Hi Dennis,

On Sat, Dec 29, 2018 at 1:26 PM Dennis Zhou <dennis@kernel.org> wrote:
>
> Hi Andrew,
>
> On Sat, Dec 29, 2018 at 01:03:52PM -0800, Andrew Morton wrote:
> > On Fri, 28 Dec 2018 17:31:47 -0800 Shakeel Butt <shakeelb@google.com> wrote:
> >
> > > __alloc_percpu_gfp() can be called from atomic context, so, make
> > > pcpu_get_pages use the gfp provided to the higher layer.
> >
> > Does this fix any user-visible issues?
>
> Sorry for not getting to this earlier. I'm currently traveling. I
> respoeded on the patch itself. Do you mind unqueuing? I explain in more
> detail on the patch, but __alloc_percpu_gfp() will never call
> pcpu_get_pages() when called as not GFP_KERNEL.
>

Thanks for the explanation. Andrew, please ignore/drop this patch.

thanks,
Shakeel

