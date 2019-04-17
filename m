Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44A4DC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 14:55:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 105A0217FA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 14:55:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 105A0217FA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99B8D6B0005; Wed, 17 Apr 2019 10:55:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 948236B0006; Wed, 17 Apr 2019 10:55:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8379D6B0007; Wed, 17 Apr 2019 10:55:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4B2E36B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 10:55:51 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id g1so12944535edm.16
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 07:55:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=I65fb2sNH1MOdVrP9ynMTyurS4TBSoyLtDkUCQrHD3A=;
        b=B9gGOmoquGLEXPqA+3kNlxoXScySOAmXfA8mTCfm2Q7UJ04wr0n1PgtMzL6rTM8HHM
         ljF/OSwHuhpRh7asJHx7YASgTSDiGb8gG4aI0sl0b0isnGroIy3cF/OGv0qoLaj9voGr
         CTA3VfP4zqQOlf3idBvgHpvrc8bBqhDtU7Fp4oStGWqV7jhS7NYkU4cb1UCUX0yQNg+G
         Zkp9sFEJL8B+EoycE5hScosM8eCgtDtr9IOAHWsflzwmoG2uV9gfYzrBpglqGcaAtrLe
         YFFkcd1ZYTocwoxAxifMHio/E3Xlzmbg/1/vkymFy6nRZrb48iw/iLLQidvoASuEJ72L
         LA/w==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVPNEvPqLXaytz6CtnvvP/xJSVlkUhTSYynsQNRzAeysjTmwdUZ
	oAW967HbCcSobBHyfkvarduL34sHYfZdiIHcpv2nwnpMPfS3oMPMXZD6PFJwEuVHIj0mw0R+652
	XU689k+phg315xYgk1e8qpMVJQTggy5j0wve97sIFdfQCe3JH7dYT5WQ8mYvn5wc=
X-Received: by 2002:a50:ad58:: with SMTP id z24mr17415169edc.75.1555512950819;
        Wed, 17 Apr 2019 07:55:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwENY+xhuu3lGciqmV6ry22ryXVBxI7qEier76YZtbPTMKXNHMPyUYJohaUtDO+CRISUqEo
X-Received: by 2002:a50:ad58:: with SMTP id z24mr17415132edc.75.1555512950062;
        Wed, 17 Apr 2019 07:55:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555512950; cv=none;
        d=google.com; s=arc-20160816;
        b=uHlmeZo3zbpjF0mowjpa0mTE9PS1ZAwVkuAPVU5TpXE2efQVWjTLpCljn/9ifHapDm
         brLeM6PevsFG/X/9vmwDEjuk7BAfShyKsFZmciAcpICcAhsM9jCjkKMhdaRziN4ZklsJ
         ad5ku64alE351KqZ3avmzBGBzzaa86qc+ZAS7+BBgK9INuQETYy7IzzyiC0KfLL9YCDD
         dvk2jTTq/b06/+OjHL41iVxh5AViuG5bJeP5VOBpfiAHYMniisnFsHcIiWXbbMq+ep9K
         PUJzGJL/P0/7H0Qj4S+upl8bsiZY+oRH6dYfsI5SijusvWiQP9eua2d8YcUDqY+9kONG
         FPgQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=I65fb2sNH1MOdVrP9ynMTyurS4TBSoyLtDkUCQrHD3A=;
        b=bdVffNDqNFWeoXOHPoCebmkWvCLQMXPYIDAU1rPZGLbyw3hLsbEmU4aU96iG3zLA3H
         omi3+e5kmt4zsrP6Kw7RhWsrxCMzA6e3VWnHZJVbDiu6Bh7nbiaVkVe5zAYpg+BGgpGU
         mYlLdU2ABzV7RylHe2T5yPsjoyQAKmzym+OLCEvxukdHQUVJGDXNSE8TMYEUXDWynAWv
         KZCqlHpSmakh2iJto06Dty7ZWrmpM61UnO5DFZ0MLCU23eivx/u/BKkcZyBP+oZk17dj
         NnfHzP7febIyNwkMNdZKgQxjpQdlG+jQ4LYIglDPDyYpKlQyo8PH6KLIjSoT1NeHE8R2
         /QsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e15si3891995edl.324.2019.04.17.07.55.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 07:55:50 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 78B5FAE0F;
	Wed, 17 Apr 2019 14:55:49 +0000 (UTC)
Date: Wed, 17 Apr 2019 16:55:48 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Michal =?iso-8859-1?Q?Koutn=FD?= <mkoutny@suse.com>
Cc: Bartosz Golaszewski <brgl@bgdev.pl>, Arun KS <arunks@codeaurora.org>,
	Geert Uytterhoeven <geert+renesas@glider.be>, linux-mm@kvack.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mateusz Guzik <mguzik@redhat.com>, Vlastimil Babka <vbabka@suse.cz>,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: get_cmdline use arg_lock instead of mmap_sem
Message-ID: <20190417145548.GN5878@dhcp22.suse.cz>
References: <20190417120347.15397-1-mkoutny@suse.com>
 <20190417134152.GM5878@dhcp22.suse.cz>
 <20190417144142.GF8962@blackbody.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190417144142.GF8962@blackbody.suse.cz>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 17-04-19 16:41:42, Michal Koutny wrote:
> On Wed, Apr 17, 2019 at 03:41:52PM +0200, Michal Hocko <mhocko@kernel.org> wrote:
> > Don't we need to use the lock in prctl_set_mm as well then?
> 
> Correct. The patch alone just moves the race from
> get_cmdline/prctl_set_mm_map to get_cmdline/prctl_set_mm.
> 
> arg_lock could be used in prctl_set_mm but the better idea (IMO) is
> complete removal of that code in favor of prctl_set_mm_map [1].

Ohh, I have missed that patch. As long as both are merged together then
no objections from me and you can add

Acked-by: Michal Hocko <mhocko@suse.com>

> Michal
> 
> [1] https://lore.kernel.org/lkml/20180405182651.GM15783@uranus.lan/

-- 
Michal Hocko
SUSE Labs

