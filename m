Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CFF5C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:58:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CD83920B1F
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 11:58:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CD83920B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4A08E6B0006; Tue,  6 Aug 2019 07:58:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4507C6B0008; Tue,  6 Aug 2019 07:58:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 319A16B000A; Tue,  6 Aug 2019 07:58:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D9D836B0006
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 07:58:26 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id n3so53706861edr.8
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 04:58:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=1eHBI4smRB1TfNdo1TOqzaG0cVcwD1VCiSmymOE0Bmk=;
        b=FIUscWhXRrYvJ4TwDY5UnzRs9oZc/ctbIYRMDAZJgGJNEq155mcXtEoRM5PjSPgEmq
         EzKLDGFi1qQrSea3ar2EmCJqYnwirYHZASwgljDRNxO4bbRFfHOnqUYKdWkZv1r2XzX9
         3MH5CvIWpVEFegCJmxNbO2vCjKSjSOr829d76pIpZFUPZQY4zw/1p2TU33MQ0GHpSUst
         jsU2tWUOefeEYARF8/DhbrD/dfNLK1tXrOKqZtTv36w0YjFoH0j9FlkyVuIwia5Wk6YV
         nRXVir2ReruenKFvslBcVSufBQ/9aNuL5xw8i4kw2pxVMC97CEsGJE5evZoYLbK4acuw
         qBjg==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVZk92AOmYh7rD/8TjpdsXuIncJ24HARmrt8N2J7FqtJNQ3kawF
	TNHjBGBHJSp69bid03kNoyLKwZ6diKnQY2p17gZh7flpdFrm2RtoUkp8SR0bSeW9CZfP4TJEEbF
	6WBuuWmSDj5y1tYiO/FwMNgwpTYti2Q3fcFvzDl3qhng08HFkd3mhFKotGpeJo/M=
X-Received: by 2002:a17:906:6c85:: with SMTP id s5mr2769451ejr.199.1565092706480;
        Tue, 06 Aug 2019 04:58:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBgD1XsOZxLOfk4yd+wpKUOg01b37HvK0o7XPNf4Z5xeyOFccwZGqRD1bSBkDWeG9fR8JQ
X-Received: by 2002:a17:906:6c85:: with SMTP id s5mr2769420ejr.199.1565092705915;
        Tue, 06 Aug 2019 04:58:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565092705; cv=none;
        d=google.com; s=arc-20160816;
        b=zx+mYrn1dVtkSjZAuWpX+gTeb43/fDr0dXJCQ8nZwOcLJ3UW6IHlIG6AISEmRY/Zbr
         9GhYSGyJVGocRvg0RQKvs/XGAivzrWmz1/U/CRUKp/WHP4ptX5FQT5u6ttnQGskeUC8m
         BisPTsIFVsnGCrD12G+F4kiFdm3mB6T6PvCODD2Q2alwEv9jVj180lsl7GpoPmS1H6V9
         V1jO6KUX1FQ3alUIZhqz0dLycWaphsSAoumiTvno8OkP+TjtCzB8DFLwQd2EU9UQqsXm
         MlJuNL176ovWIGUBN6Dc1QHOx3TZCyzfwh4h+NNqBawwm6a9dQRbbxHEIpcdcSuJiFpv
         zV4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=1eHBI4smRB1TfNdo1TOqzaG0cVcwD1VCiSmymOE0Bmk=;
        b=jdp3Uudu2kQxle627u23CwQDFn3cyeoI5hMwWCZbJ63X+4nxQFqP6Ch2Kd6q4xeMNk
         Eu4t/Q4GOQiGkF2NmqBV9CFjjB/80C+HKypm66oKFe1RIIO6o2i2NrzJy2UZQxr3x+ry
         ETqNsLRBwUoATtJLtUqI8GmHNOokGd1ledPc/HanmN1fN961tYRUvLyS94ZW5Okwj+oW
         iGwKt8pUKtnqTZ+lE6l4fnG3wmbNYRa88b20hrsHp0fqIS1PrtZaGpOKA2hN4kcwirZc
         EyUju0dGWGM2MtElcEIYRfgYU2mvGk1khWVqlz8GkaIC9bCW3h3xMYhpr5v0VxdY758v
         aEoA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b43si30487885edd.433.2019.08.06.04.58.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 04:58:25 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0098EAD88;
	Tue,  6 Aug 2019 11:58:24 +0000 (UTC)
Date: Tue, 6 Aug 2019 13:58:23 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Mel Gorman <mgorman@techsingularity.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux MM <linux-mm@kvack.org>,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	Christoph Lameter <cl@linux.com>,
	Yafang Shao <shaoyafang@didiglobal.com>
Subject: Re: [PATCH v2] mm/vmscan: shrink slab in node reclaim
Message-ID: <20190806115823.GZ11812@dhcp22.suse.cz>
References: <20190806073525.GC11812@dhcp22.suse.cz>
 <20190806074137.GE11812@dhcp22.suse.cz>
 <CALOAHbBNV9BNmGhnV-HXOdx9QfArLHqBHsBe0cm-gxsGVSoenw@mail.gmail.com>
 <20190806090516.GM11812@dhcp22.suse.cz>
 <CALOAHbDO5qmqKt8YmCkTPhh+m34RA+ahgYVgiLx1RSOJ-gM4Dw@mail.gmail.com>
 <20190806092531.GN11812@dhcp22.suse.cz>
 <20190806095028.GG2739@techsingularity.net>
 <CALOAHbAwSevM9rpReKzJUhwoZrz_FdbBzSgRtkUfWe9BMGxWJA@mail.gmail.com>
 <20190806102845.GP11812@dhcp22.suse.cz>
 <CALOAHbCJg4DqdgKpr8LWqc636ig=phCZWUduEmwYFUtw5gq=tw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbCJg4DqdgKpr8LWqc636ig=phCZWUduEmwYFUtw5gq=tw@mail.gmail.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 06-08-19 18:59:52, Yafang Shao wrote:
> On Tue, Aug 6, 2019 at 6:28 PM Michal Hocko <mhocko@kernel.org> wrote:
[...]
> > Really, I wouldn't be opposing normally but node_reclaim is an odd ball
> > rarely used and changing its behavior based on some trivial testing
> > doesn't sound very convincing to me.
> >
> 
> Well.  I'm not insist if Andrew prefer your change.

Btw. feel free to use the diff I've send for the real patch with the
changelog. Thanks!
-- 
Michal Hocko
SUSE Labs

