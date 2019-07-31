Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9FE49C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 13:48:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 61FB8206A2
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 13:48:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 61FB8206A2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=surriel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F1F998E0003; Wed, 31 Jul 2019 09:48:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA8578E0001; Wed, 31 Jul 2019 09:48:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D97B48E0003; Wed, 31 Jul 2019 09:48:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id B83748E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 09:48:17 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id x10so61453657qti.11
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 06:48:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:sender;
        bh=a2UVqfb3vKkwAoFb8LMnoJhfpNx/nbwzZdgyGR+A5vg=;
        b=esAtG69pfzHhNXHiPzkIuCl8WIloSbupQSatPZyKR627DlHCqRgYCusWJ3OseHAPCv
         6dNog1rsBD1yngmagUAEWS23MXRyIGmM1XU6DlR2roXvZv5p6H1lZagpdje6DcVctoAV
         0lxVxw9ATwwRMDH6SDXIxrNSiG477H+VloLpX0RZgQeV2FM7Iff/h84NS5DeVIOV9epB
         etzxJ/5Xo+ZzJSQYNWwXMZcsr+035Dwuvd3Lqwa9K8dA50KoBNUCiF5t1y4jMSht81or
         ZZ/MjIfxgPe3E+9TWEt3TaKnwtqQBYryDmWU9RwTsu8AiL3K2ICsDgTwnaSA28HGmGbi
         ox7g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
X-Gm-Message-State: APjAAAWCCI44KKeIlQ+dKhHOK2qbBB5kVcrtAcra2eeEdrN8GRtPWZx/
	ZUVQjIRAEOJS7MezMq4iJXgnLCZe5uv6Bpm8AIQJPa20lNr8m7s2H+XxSKo3WQXruRhRRaXAD+Y
	rSoEMQMKk++cdiYMePEF/sQMkTirv0kbWEGGMAkcFvXRooFo+jObTq04JJFco7qKErg==
X-Received: by 2002:a37:4f4f:: with SMTP id d76mr72191412qkb.304.1564580897509;
        Wed, 31 Jul 2019 06:48:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyXwEnCCWy5Pc6lAp6YSXwLXTqxTiKSTbkvIHmzMnkJuyS2gh14kH0QhBoJF4bplXGzrm1k
X-Received: by 2002:a37:4f4f:: with SMTP id d76mr72191363qkb.304.1564580896724;
        Wed, 31 Jul 2019 06:48:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564580896; cv=none;
        d=google.com; s=arc-20160816;
        b=ELj/rowWQrqQpjVPVgw7OslP4x3JvLNtqKWPYPk91isTSClLxjKkm3lsvB2C5a01xx
         buCSqVgO6DSQwB+lkGg8wFYu1HLnvtvdp8BZS7D9St4RawwFTlfTMsmyLIX6kLEI3Qe5
         e+cE1OSY9+QJqbnBZMz9Z2LKXx747+CiL/LvTQk5C3z8H1FHp0R353YCefwNGRRJXzgT
         XjGf0j8DRb84IgqKTVIxwRYab5syuDlgxpQeKC+wbHHOhDQSJMmGPMTZj/yZDuxJ79Tk
         7kxE/HprStE0/CIA+xwznT69vTK2+W0bo0b6G8W+z1kvgk4pOZlRNqHMXXNQZEvwyuD8
         7T8A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:mime-version:user-agent:references:in-reply-to:date:cc:to
         :from:subject:message-id;
        bh=a2UVqfb3vKkwAoFb8LMnoJhfpNx/nbwzZdgyGR+A5vg=;
        b=FWhiUMIMx3RH32BIjjWOkddfhQhn0Jxy/bsfzbVZ9AP3Zt8w4erdMqEsHTogkn1mkq
         UmvTTmk1EZSj5Pi1XVEUGzUmwEHtoft5xOxyCuPKEiECzD8gAtS7Il+pc4hDU/zmAXi9
         hL1Klo6IrPg6BQyi3al6a+xxDppjw8TpgiE4din2dtqRnh44KNOrxbc23MJlOToiBSRG
         9NGxl0Kmi/SWD65hN46yt7wpa9qyF0kNOW4TA0Vh6Ouqz8o6ZBaRwy+KFc5ExD/C7DbP
         4QcSlLfGkFc7yUc7qeY2T9EMIvtsfU1qmWR4BW5Gkv64MJELXw6thrCEGrQnY4818XTJ
         mCcw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id r131si22247775qke.339.2019.07.31.06.48.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 06:48:14 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) client-ip=96.67.55.147;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from imladris.surriel.com ([96.67.55.152])
	by shelob.surriel.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.92)
	(envelope-from <riel@shelob.surriel.com>)
	id 1hsoxZ-0000KL-F1; Wed, 31 Jul 2019 09:48:05 -0400
Message-ID: <c91e6104acaef118ae09e4b4b0c70232c4583293.camel@surriel.com>
Subject: Re: [PATCH v3] sched/core: Don't use dying mm as active_mm of
 kthreads
From: Rik van Riel <riel@surriel.com>
To: Waiman Long <longman@redhat.com>, Peter Zijlstra <peterz@infradead.org>,
  Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton
	 <akpm@linux-foundation.org>, Phil Auld <pauld@redhat.com>, Michal Hocko
	 <mhocko@kernel.org>
Date: Wed, 31 Jul 2019 09:48:04 -0400
In-Reply-To: <b5a462b8-8ef6-6d2c-89aa-b5009c194000@redhat.com>
References: <20190729210728.21634-1-longman@redhat.com>
	 <ec9effc07a94b28ecf364de40dee183bcfb146fc.camel@surriel.com>
	 <3e2ff4c9-c51f-8512-5051-5841131f4acb@redhat.com>
	 <8021be4426fdafdce83517194112f43009fb9f6d.camel@surriel.com>
	 <b5a462b8-8ef6-6d2c-89aa-b5009c194000@redhat.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-xAvz8PAt4EpYAA5Kq7uu"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-xAvz8PAt4EpYAA5Kq7uu
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2019-07-30 at 17:01 -0400, Waiman Long wrote:
> On 7/29/19 8:26 PM, Rik van Riel wrote:
> > On Mon, 2019-07-29 at 17:42 -0400, Waiman Long wrote:
> >=20
> > > What I have found is that a long running process on a mostly idle
> > > system
> > > with many CPUs is likely to cycle through a lot of the CPUs
> > > during
> > > its
> > > lifetime and leave behind its mm in the active_mm of those
> > > CPUs.  My
> > > 2-socket test system have 96 logical CPUs. After running the test
> > > program for a minute or so, it leaves behind its mm in about half
> > > of
> > > the
> > > CPUs with a mm_count of 45 after exit. So the dying mm will stay
> > > until
> > > all those 45 CPUs get new user tasks to run.
> > OK. On what kernel are you seeing this?
> >=20
> > On current upstream, the code in native_flush_tlb_others()
> > will send a TLB flush to every CPU in mm_cpumask() if page
> > table pages have been freed.
> >=20
> > That should cause the lazy TLB CPUs to switch to init_mm
> > when the exit->zap_page_range path gets to the point where
> > it frees page tables.
> >=20
> I was using the latest upstream 5.3-rc2 kernel. It may be the case
> that
> the mm has been switched, but the mm_count field of the active_mm of
> the
> kthread is not being decremented until a user task runs on a CPU.

Is that something we could fix from the TLB flushing
code?

When switching to init_mm, drop the refcount on the
lazy mm?

That way that overhead is not added to the context
switching code.

--=20
All Rights Reversed.

--=-xAvz8PAt4EpYAA5Kq7uu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAl1BnBUACgkQznnekoTE
3oP8LggAs4XburHZ+HTI3IJjkgfu6S82BUog14l4Iqg4Pk4/KMkf5dPrftjy8atc
BcB98mXDlfQCjyPd3gj8JZVlxmpwcendnEKgh1ErkLh5cDDTUnhil7dSQjCVLCBi
KRxakwewtyuK1MwCtcDM0fd1GhNJS/VWfGzDh5BxSLFbQSNlhGZyxR92xMMe9ra0
xIaIzzSdYJ9B9Uno9ZlaJdZwenrS/zEpE4iet6MSFaf/yy0gU0Bk07/x2IYNwsOB
0diPL3V6VWTPG7k0fjfiaBoDjSdBaogMAPWEO+0fG2g4KQMsxyPg1Kgfrayw2NW7
RSzLXBmZNFvkqJZMnErK1bmn937QQg==
=14CR
-----END PGP SIGNATURE-----

--=-xAvz8PAt4EpYAA5Kq7uu--

