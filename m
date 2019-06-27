Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_IN_DEF_DKIM_WL autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC66EC48BD7
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 13:09:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 918222084B
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 13:09:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="EMPAztye"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 918222084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 308CA8E000A; Thu, 27 Jun 2019 09:09:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B8DD8E0002; Thu, 27 Jun 2019 09:09:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A80D8E000A; Thu, 27 Jun 2019 09:09:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id EC7F58E0002
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 09:09:20 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id b85so656963vke.22
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 06:09:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=+GEy0GowFU+uQq8TtB0z8xaih9ptN5Q3IEiqpuelFDs=;
        b=rtYv9Uo2rsLp+UK+rQ1DwJbfCn3ML6zXKYxBdjBc573RcHOGc/3CBktOS7dqtpziN3
         3LI5My/PMCmJZQXXcIkr4JLw8cy9IMNAsepm61zrfGAg95Z74GwfLmZEzi2yoUkCYXmR
         ZgQF8yVrDyUOLX1Y0KcTu59+35I2yiukNmWIg9vyr8kFGQPkNbZF/mnuinsYwlPyzHwq
         5KHRip5k34nWqeMW5QyHylM7ViiT4pmQliRZbBXHDfwduc9mNGxiCc0bxnREXq8xU9X3
         pDtnKI9N63T/gtCWw5Vbdwh5syKUiAugaz31qNQdgtbB6/P4mcLya6sR7gquJSWA8loO
         C7eA==
X-Gm-Message-State: APjAAAV+j9tGD/qxr1/G7MA0EMtFJImOPb/VI0XKrvTHckWkYDM3T2gZ
	S9bpOzeABA0a1eLCBsRea0w/5gZDgY1pAVV8KQ9aCMKjchF3j5cppqH5WkRJUvM/dNNmSnj/P6i
	IJaHzrksErBDi1bjjYc2sKOtfq5A56pG+JJedbxXogEutMP3kOxm8uRWyXwm4wJfUXA==
X-Received: by 2002:a1f:9390:: with SMTP id v138mr1337059vkd.48.1561640960648;
        Thu, 27 Jun 2019 06:09:20 -0700 (PDT)
X-Received: by 2002:a1f:9390:: with SMTP id v138mr1337030vkd.48.1561640959900;
        Thu, 27 Jun 2019 06:09:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561640959; cv=none;
        d=google.com; s=arc-20160816;
        b=DTYdd2SUK/H62JAy/gQDy7IoAIZNERGTZb5plhvnXF/QnF74QCGa2/AIV+aDFDM76Q
         0Zuzl53j9NvxXEDmKvsBhvwMKkxI5XilxaMaaNXcHlNj58POdAjRvIzQJVzAlO4cS97h
         1LUIh2LvB01cNWP8B5Z11euDWCs1bvdp3rtxFUDYks06ovJ4WKyQmwV5eZRSYN0/tSNO
         g0a2njEI+D1UR2V2SKuwMjmnaosUPz6CealgPSi/0wj/qrnMgZxRbXLcHaemY1oMFdJ5
         nkEVDgCeFWs6/O93ZHYev51/PeHoq/NKOAaaObRg4uh/0HQUB8NAUQr1ypX31ztBLTLu
         j3uQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=+GEy0GowFU+uQq8TtB0z8xaih9ptN5Q3IEiqpuelFDs=;
        b=mzfirYg54kvCp4HGdsp73VGSGmQmJek5u8vpUi+PpeR5XGCVnVPY9uiUJqR+puDWZ4
         wT1HU7HrTLN9U3yYsMp8JBtedtFFDonqk9pz4Q6108tKJOYZTCX75+SHm9+hy5dOYl64
         DQADp0XaT/0Vi6OR/d4Q8N25IGRHKO6AWrN3EcLHu7f71cQnviYnH3mZkjQ9KTR/3sLV
         xTdWN3o98SvQm/I60nw9tWj5QIAg2ZLugxQm4bzQA+FIXmrJJHz9HHvJQVyYp3011Qit
         yVfnPAWff51qe3+eHvsq6YPhzZWVlOzpiQiFNcSjK/WNWgGvI80ueFpXIIpw/MlpIG5O
         4RYw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=EMPAztye;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m12sor1069506uao.68.2019.06.27.06.09.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 27 Jun 2019 06:09:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=EMPAztye;
       spf=pass (google.com: domain of glider@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=glider@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=+GEy0GowFU+uQq8TtB0z8xaih9ptN5Q3IEiqpuelFDs=;
        b=EMPAztyeJD8w4tcBaVeombkZujMeYNTsJ7eaSZC9f/YoNsl84xyhDO4M73FyMmjA/x
         t5N4V/SYNJGu8aRCWbdfkZuL0gmN6Wgsx5IiESN3D5cmEWh1+qccSYhaDxN/fjQrz5Jj
         Cmx2Loy9qjuSXQ4c1Xk6qnfHtYBKzCGdneCzQmv777wUvbWV+GjeS64FIN8TGVu5kjI3
         cB8Y4DCxGroHXSrRmB1f6VKjKprKpC5G6gqTdPHTtnquOGPC1Bg5sg8J02NNcNrwL5Ku
         Y7AExdNBks6Anahq3UGPKqAJm/MXezvkzfSwn+pSQixXTQgFZClv7wnEHCzFUPX1MZUn
         6o4w==
X-Google-Smtp-Source: APXvYqyybVeF02FV7oyRIEy9deXhVNP2OXv1ccgGnq0QB34Ix3HStMP+1vnMzbMN3do7c59wTe80K7fkjXUNi2zvrCQ=
X-Received: by 2002:ab0:3d2:: with SMTP id 76mr2215849uau.12.1561640958978;
 Thu, 27 Jun 2019 06:09:18 -0700 (PDT)
MIME-Version: 1.0
References: <20190626121943.131390-1-glider@google.com> <20190626121943.131390-2-glider@google.com>
 <20190626144943.GY17798@dhcp22.suse.cz> <CAG_fn=Xf5yEuz7JyOt-gmNx1uSM6mmM57_jFxCi+9VPZ4PSwJQ@mail.gmail.com>
 <20190626154237.GZ17798@dhcp22.suse.cz>
In-Reply-To: <20190626154237.GZ17798@dhcp22.suse.cz>
From: Alexander Potapenko <glider@google.com>
Date: Thu, 27 Jun 2019 15:09:06 +0200
Message-ID: <CAG_fn=V4SZwu50LCZq+2Fa-zAZmQ+X-80vxzN-MGJZdjpFpjhw@mail.gmail.com>
Subject: Re: [PATCH v8 1/2] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, 
	Kees Cook <keescook@chromium.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, 
	James Morris <jmorris@namei.org>, "Serge E. Hallyn" <serge@hallyn.com>, 
	Nick Desaulniers <ndesaulniers@google.com>, Kostya Serebryany <kcc@google.com>, 
	Dmitry Vyukov <dvyukov@google.com>, Sandeep Patil <sspatil@android.com>, 
	Laura Abbott <labbott@redhat.com>, Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>, 
	Mark Rutland <mark.rutland@arm.com>, Marco Elver <elver@google.com>, Qian Cai <cai@lca.pw>, 
	Linux Memory Management List <linux-mm@kvack.org>, 
	linux-security-module <linux-security-module@vger.kernel.org>, 
	Kernel Hardening <kernel-hardening@lists.openwall.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 5:42 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Wed 26-06-19 17:00:43, Alexander Potapenko wrote:
> > On Wed, Jun 26, 2019 at 4:49 PM Michal Hocko <mhocko@kernel.org> wrote:
> [...]
> > > > @@ -1142,6 +1200,8 @@ static __always_inline bool free_pages_prepar=
e(struct page *page,
> > > >       }
> > > >       arch_free_page(page, order);
> > > >       kernel_poison_pages(page, 1 << order, 0);
> > > > +     if (want_init_on_free())
> > > > +             kernel_init_free_pages(page, 1 << order);
> > >
> > > same here. If you don't want to make this exclusive then you have to
> > > zero before poisoning otherwise you are going to blow up on the poiso=
n
> > > check, right?
> > Note that we disable initialization if page poisoning is on.
>
> Ohh, right. Missed that in the init code.
>
> > As I mentioned on another thread we can eventually merge this code
> > with page poisoning, but right now it's better to make the user decide
> > which of the features they want instead of letting them guess how the
> > combination of the two is going to work.
>
> Strictly speaking zeroying is a subset of poisoning. If somebody asks
> for both the poisoning surely satisfies any data leak guarantees
> zeroying would give. So I am not sure we have to really make them
> exclusive wrt. to the configuraion. I will leave that to you but it
> would be better if the code didn't break subtly once the early init
> restriction is removed for one way or another. So either always make
> sure that zeroying is done _before_ poisoning or that you do not zero
> when poisoning. The later sounds the best wrt. the code quality from my
> POV.
I somewhat liked the idea of always having zero-initialized page/heap
memory if init_on_{alloc,free} is on.
But in production mode we won't have page or slab poisoning anyway,
and for debugging this doesn't really matter much.
I've sent v9 with poisoning support added.
> --
> Michal Hocko
> SUSE Labs



--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Paul Manicle, Halimah DeLaine Prado
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

