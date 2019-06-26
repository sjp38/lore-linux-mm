Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3203BC48BD9
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 15:42:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0452F2177B
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 15:42:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0452F2177B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 87C148E0017; Wed, 26 Jun 2019 11:42:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 82C458E0002; Wed, 26 Jun 2019 11:42:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 71B1C8E0017; Wed, 26 Jun 2019 11:42:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1C3658E0002
	for <linux-mm@kvack.org>; Wed, 26 Jun 2019 11:42:41 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id b12so3771238eds.14
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 08:42:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=cwWEfocoodqO9cyrH8VhNzGnokLyp2Y95xLEsBu/ftM=;
        b=svmQNDcknuhF+UoToQGWHU5a7HWkxMqalCeWnv5MlkCa69cf5zX1Abxg9imZjh5fZQ
         RwzYyQrSVFUmyu4+WlAPxs9BSVQnBByb1yIkWuZrLHcMIBWv/qOCgU+FwwvFSbgkkHD6
         2o9iOyLl+IiVqtI1RqUU4iMkOV0+N+D8azBMKrXX3o31KQHyCFt/VCnSWHbhUx6+GWBm
         UvwbQWRu/wRV/Cai70jvNpgI9A/K3aFUp3y10fjwObcWzdl0IMmHGASUk86DIiLvVr8s
         aQp+s2RkhU/FfQbI3bw5/MdW7dxVAEpQOz12jy1h+rQmir0Zdf3inJAOxNWlzKPruODM
         nupw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVVXcY9YVX/5rt0Sgv6PPnLmGg29snr1xd7fXf+H0dfilsZDE/C
	uzEJYKtmuNt2Rk0tzuN0c9wsz3mCYgzUA/uEChFayt6+BY3lcg9GgGIEgKx2UgOql0VGE+Xly8c
	8Zp9tMpllomIjs8G0/dhJULxK8djBUPGN8cs9664puVUqW1L4Dm4x9xNOKgErYu0=
X-Received: by 2002:a50:be01:: with SMTP id a1mr6275976edi.287.1561563760675;
        Wed, 26 Jun 2019 08:42:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzfo2Y1QHnVCcc/UNnsMmYbSIkeoo23epU/5MsGoASH3o1ZHCkH2KasGL+w2xm58YJe3OtK
X-Received: by 2002:a50:be01:: with SMTP id a1mr6275897edi.287.1561563759970;
        Wed, 26 Jun 2019 08:42:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561563759; cv=none;
        d=google.com; s=arc-20160816;
        b=mnA9kMXEzOJiqNcaJFoFcSLnhmkDFgSltaYrI62CH1DuQzmLR9ILTbvljcRoDV+bII
         vRxZdPZkZnWE1G8cxGIpq6/vmt8sBwj3opVaxBpucWU4yI2RhWCawPrWkSdXC2dmSlyx
         lrtOkbevZGDelFe01Yif8mX+RsjnJo7LgX9vKQiubGu1bU5Zc/rW5nBQwbM60oA/Fy4m
         OSxP/DOqz3I7qnPvG5nBD5ekHHdB6eYsGvqofIgSf0nPTyIDbgSiT8jAP4pGx4ler1Wx
         f+bLFZlMEEq5ZxBxuC0hWx1uw+I0tVjelhRp+pgf6UkYpW9xqJoliEh4jtjBEriH/P2k
         v7xA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=cwWEfocoodqO9cyrH8VhNzGnokLyp2Y95xLEsBu/ftM=;
        b=V1oxcGegHV7c4BKOrbuxOOnS/NLRRyYmHn1Dca1eYJhwW+Og3rLNJG8QN8j1e3qGQT
         UCjMUZ8JoGgS3GRdKmtAvst1VWPNY60xWSVg6fby5a7sitCq2UJa7VAUR6cGumN+nUOK
         R3yMci4ShDChLWpCSNQ+Cj0fOVDNRBmHe/rVufJbwEcnzzWslDzOe1Mfrr/0UJJGmFEA
         7QpeCK/haXxB+yBr+KaFY2sFd3pFzGce9ngcqGlZFt20ZFLwEo2jXaBb/qcodaPIlYo6
         KX23h7BuARJJNOLjmcPIicIm6rj1B3eEwzeovRCuhzTONwC/H8/4bcBaNyR5Scm2n5oY
         9x2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k25si2769731ejp.223.2019.06.26.08.42.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 08:42:39 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id DB564ABD9;
	Wed, 26 Jun 2019 15:42:38 +0000 (UTC)
Date: Wed, 26 Jun 2019 17:42:37 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Christoph Lameter <cl@linux.com>, Kees Cook <keescook@chromium.org>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	James Morris <jmorris@namei.org>,
	"Serge E. Hallyn" <serge@hallyn.com>,
	Nick Desaulniers <ndesaulniers@google.com>,
	Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Sandeep Patil <sspatil@android.com>,
	Laura Abbott <labbott@redhat.com>,
	Randy Dunlap <rdunlap@infradead.org>, Jann Horn <jannh@google.com>,
	Mark Rutland <mark.rutland@arm.com>, Marco Elver <elver@google.com>,
	Qian Cai <cai@lca.pw>,
	Linux Memory Management List <linux-mm@kvack.org>,
	linux-security-module <linux-security-module@vger.kernel.org>,
	Kernel Hardening <kernel-hardening@lists.openwall.com>
Subject: Re: [PATCH v8 1/2] mm: security: introduce init_on_alloc=1 and
 init_on_free=1 boot options
Message-ID: <20190626154237.GZ17798@dhcp22.suse.cz>
References: <20190626121943.131390-1-glider@google.com>
 <20190626121943.131390-2-glider@google.com>
 <20190626144943.GY17798@dhcp22.suse.cz>
 <CAG_fn=Xf5yEuz7JyOt-gmNx1uSM6mmM57_jFxCi+9VPZ4PSwJQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG_fn=Xf5yEuz7JyOt-gmNx1uSM6mmM57_jFxCi+9VPZ4PSwJQ@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 26-06-19 17:00:43, Alexander Potapenko wrote:
> On Wed, Jun 26, 2019 at 4:49 PM Michal Hocko <mhocko@kernel.org> wrote:
[...]
> > > @@ -1142,6 +1200,8 @@ static __always_inline bool free_pages_prepare(struct page *page,
> > >       }
> > >       arch_free_page(page, order);
> > >       kernel_poison_pages(page, 1 << order, 0);
> > > +     if (want_init_on_free())
> > > +             kernel_init_free_pages(page, 1 << order);
> >
> > same here. If you don't want to make this exclusive then you have to
> > zero before poisoning otherwise you are going to blow up on the poison
> > check, right?
> Note that we disable initialization if page poisoning is on.

Ohh, right. Missed that in the init code.

> As I mentioned on another thread we can eventually merge this code
> with page poisoning, but right now it's better to make the user decide
> which of the features they want instead of letting them guess how the
> combination of the two is going to work.

Strictly speaking zeroying is a subset of poisoning. If somebody asks
for both the poisoning surely satisfies any data leak guarantees
zeroying would give. So I am not sure we have to really make them
exclusive wrt. to the configuraion. I will leave that to you but it
would be better if the code didn't break subtly once the early init
restriction is removed for one way or another. So either always make
sure that zeroying is done _before_ poisoning or that you do not zero
when poisoning. The later sounds the best wrt. the code quality from my
POV.

-- 
Michal Hocko
SUSE Labs

