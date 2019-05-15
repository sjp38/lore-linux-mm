Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77548C04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 15:16:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2AA9720862
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 15:16:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=kroah.com header.i=@kroah.com header.b="gHkvdyLX";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="gtRcPgCq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2AA9720862
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=kroah.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BA54C6B000A; Wed, 15 May 2019 11:16:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B566E6B000D; Wed, 15 May 2019 11:16:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D0216B000E; Wed, 15 May 2019 11:16:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 79CB86B000A
	for <linux-mm@kvack.org>; Wed, 15 May 2019 11:16:03 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id x23so2548135qka.19
        for <linux-mm@kvack.org>; Wed, 15 May 2019 08:16:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:date:from:to:cc
         :subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=vwxG4zfHU1KFopIJRohTDTKqQxnzS9PnCdczIsuquQE=;
        b=K/u48m71Pbxi85wCv3LXkJv4aytbL66Y+k7TT+2WNpkJGuvSamwY+hNVGEt2NA48iJ
         /5VrgHKCArjDYtbrDaq6Lz6MzhK5kqj7l9cr+gH4KsqUy3HIWXjVAZl9iN1gdKWXcCXm
         imZv0o5s2Hwz2VQrbFla00PrZKBSXsDW0AZ5+GUtY9H+/0FX/yZsjZxJcnDvZ0p9zmyc
         kue0ZLFd7smj9OEOJM9NvRhc+obtkF6RmpgP30DqOfM1WJf2oDTf6PE/m5kobCxZagkz
         S8ATEk84IpRu1A6wD8IWuHEQCdfU+n4UUqk2PpR1jkkNHFkN9aOVtsojn3gXc2iwrRdd
         umpw==
X-Gm-Message-State: APjAAAU82cFBQY3KJIypf4UhKDILP5pWKV/3EjwPZROaYSkHMAgbEuXO
	l1ozTdtWTYSJeOAA09rTPYhv/8RaafVgpHr05CLqXFqaahemaay88VLZUSunIa+NGEVO6Xl7bKP
	tt9oY0CgT0cBGip1VDleZ5eC22zhAoiVQqXzRqvOoL+vaLTGcZrvyq6SFHc2VkbP0SQ==
X-Received: by 2002:a0c:9523:: with SMTP id l32mr35645441qvl.75.1557933363208;
        Wed, 15 May 2019 08:16:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzZ0dmySDMmtaPGMZUeeh6v+MoswzXNmgsCtPGRgoRCySdnVd3w85Dzjslw/y7CRlklb36i
X-Received: by 2002:a0c:9523:: with SMTP id l32mr35645380qvl.75.1557933362548;
        Wed, 15 May 2019 08:16:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557933362; cv=none;
        d=google.com; s=arc-20160816;
        b=zEyKGEmrY1A147nvbea2lno7YEUzsrMpQVdVyaXldl1WgnKCOYYSHr+qGcIXKzmaj2
         HU7doNLCJc+Nh3WJ+yNcPBS9SeS64yrdHrUzR5aR4GnO+hVxcXxUd5yDwSfzDP44WFR4
         eqtmlngQ4Z7ynNkpkimpzg2KcXQ+en0re57zxPbujha3gXmzQs+/hC9tXcacpuXWMUXn
         m9tZr189RBwuFt5KynCn/qQLoHqve3Vg29PZFwZDEEL/nvB6ggzDEhlXVsdpW0e2fP6y
         bteeWiT0GqT39WOcdQdZho+qLUTTSSwuZj806nJQTxDec9Hn9WIgCKH2wJk4h/v/Nxu0
         bCAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature:dkim-signature;
        bh=vwxG4zfHU1KFopIJRohTDTKqQxnzS9PnCdczIsuquQE=;
        b=QePS/pZYRV9HokBRpwiuQG9XiS/8X6vnQ+FoaiLDYBYm0BxazjOuNer+zqcXxDh3uZ
         ZETqp3uX4XpQd/7PDVotDol2FRF44RXer2mYFQFknMczh6pdfeAmg0zLbC0vsgrwa8I6
         MJbn9fezsDEqhTV61YXeoa1CvRK/5N1yJGtLhsKI95jv4rrZA1xnNxuk2RNjpusoJksH
         5H42Pyy9F7HJHI5I4+GwSDYrWAuJz3Wq2vaMjKAQGhxdbzq2NSykJtCaVMrCboUpi71G
         NFXRSX+/HlBaYowfjdiXI89wjdmHIt+OUEmzAh5E/zzWzru7y+nI7To3U+3GMfSqbPZg
         EA7w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kroah.com header.s=fm3 header.b=gHkvdyLX;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=gtRcPgCq;
       spf=pass (google.com: domain of greg@kroah.com designates 66.111.4.221 as permitted sender) smtp.mailfrom=greg@kroah.com
Received: from new1-smtp.messagingengine.com (new1-smtp.messagingengine.com. [66.111.4.221])
        by mx.google.com with ESMTPS id g70si1058400qke.265.2019.05.15.08.16.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 08:16:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of greg@kroah.com designates 66.111.4.221 as permitted sender) client-ip=66.111.4.221;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kroah.com header.s=fm3 header.b=gHkvdyLX;
       dkim=pass header.i=@messagingengine.com header.s=fm2 header.b=gtRcPgCq;
       spf=pass (google.com: domain of greg@kroah.com designates 66.111.4.221 as permitted sender) smtp.mailfrom=greg@kroah.com
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailnew.nyi.internal (Postfix) with ESMTP id 09669B881;
	Wed, 15 May 2019 11:16:02 -0400 (EDT)
Received: from mailfrontend2 ([10.202.2.163])
  by compute6.internal (MEProxy); Wed, 15 May 2019 11:16:02 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kroah.com; h=
	date:from:to:cc:subject:message-id:references:mime-version
	:content-type:in-reply-to; s=fm3; bh=vwxG4zfHU1KFopIJRohTDTKqQxn
	zS9PnCdczIsuquQE=; b=gHkvdyLXIDp0vGK+W7yRjq/rjgDBR7tzxR9R7z0JJ1t
	ETMPawT6EO98yeb7fpVVWt78adtbwr/Q37R6ICQ7ZwRkAQ8vUCi0d75RMV5sb3eO
	0xSr5dWVddZu+LzMa6uIh58y3U7HetT2sfUzDyjUzv27XnzaERYulO/VlhQQXWNd
	QuJ76pupaP85prOYolxkTr2nSaBiE97VCOL8LJl7wOggdplGlOHDeqSTYi/l5aU9
	kJtY3WWhxfjjFWVSm4/hnfcVNvvlvUJXggpjlWD4as3sUr0doQ0LcsnMbF1t2KvF
	wa1kF5teSJTxaOrkcMaK2wFnufZCFGLivbQIb5ch4DA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:content-type:date:from:in-reply-to
	:message-id:mime-version:references:subject:to:x-me-proxy
	:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; bh=vwxG4z
	fHU1KFopIJRohTDTKqQxnzS9PnCdczIsuquQE=; b=gtRcPgCq3KlYjNgN5VkUbh
	vPRqtf232eMydJaBzRhgEFMZPVJPaepK61PHnjsTO+aI6xO3+7vnL/QBNCYW0npR
	mdjON24eCAjS6h/CQZbl5kSg45zXOyaWlWtJoFkhcT0qKt7ACvNcdSx8DeVfrI3V
	Fu0gV/rF7R27mDeD5OJIQgbAn+yPoLzLGeiwa+uXa/geqqpcbNl1YzklJid0l0vX
	9a34M5XrENZALRRrYViU+9A/9NK9oBeRjVzf9HCuAli4jeKE1usn5PEv6h1JSmSh
	1PYMfmNLU+/Q08L4tp1ioiGimAOCbgcjleRwUgiZZbUu3NyXTOxvsAwpWkmtpHLQ
	==
X-ME-Sender: <xms:Ly3cXIqtEcRx9UKvtT31bHQPGHtqif2FimXrV5sg9rf5MZDW0qE-TA>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeduuddrleekgdekvdcutefuodetggdotefrodftvf
    curfhrohhfihhlvgemucfhrghsthforghilhdpqfgfvfdpuffrtefokffrpgfnqfghnecu
    uegrihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenuc
    fjughrpeffhffvuffkfhggtggujggfsehttdertddtredvnecuhfhrohhmpefirhgvghcu
    mffjuceoghhrvghgsehkrhhorghhrdgtohhmqeenucfkphepkeefrdekiedrkeelrddutd
    ejnecurfgrrhgrmhepmhgrihhlfhhrohhmpehgrhgvgheskhhrohgrhhdrtghomhenucev
    lhhushhtvghrufhiiigvpedt
X-ME-Proxy: <xmx:MC3cXDmYW1qVvqbi6kuOuyKLMhJdj57T6xm-YL-Bzw-5gC_7Eyls_w>
    <xmx:MC3cXIvjo27jTfAB63rKqho2w26r_LTW_30RhoeNi8vMnmwkQPw7ZQ>
    <xmx:MC3cXDDKfweBa9OM_nuhIdbZJYf_IXPTRxGZvsw3KAjiMz0KJMEQWQ>
    <xmx:MS3cXKbqACB4COtIQLCVlB1vCPAk72yRC4uF8X0KOiQ7lOfuM8BeuA>
Received: from localhost (83-86-89-107.cable.dynamic.v4.ziggo.nl [83.86.89.107])
	by mail.messagingengine.com (Postfix) with ESMTPA id 71077103CB;
	Wed, 15 May 2019 11:15:59 -0400 (EDT)
Date: Wed, 15 May 2019 17:15:57 +0200
From: Greg KH <greg@kroah.com>
To: Michal Hocko <mhocko@kernel.org>
Cc: Oleksandr Natalenko <oleksandr@redhat.com>,
	linux-kernel@vger.kernel.org, Kirill Tkhai <ktkhai@virtuozzo.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	Grzegorz Halat <ghalat@redhat.com>, linux-mm@kvack.org,
	linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>,
	Suren Baghdasaryan <surenb@google.com>,
	Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH RFC v2 0/4] mm/ksm: add option to automerge VMAs
Message-ID: <20190515151557.GA23969@kroah.com>
References: <20190514131654.25463-1-oleksandr@redhat.com>
 <20190514144105.GF4683@dhcp22.suse.cz>
 <20190514145122.GG4683@dhcp22.suse.cz>
 <20190515062523.5ndf7obzfgugilfs@butterfly.localdomain>
 <20190515065311.GB16651@dhcp22.suse.cz>
 <20190515145151.GG16651@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190515145151.GG16651@dhcp22.suse.cz>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 15, 2019 at 04:51:51PM +0200, Michal Hocko wrote:
> [Cc Suren and Minchan - the email thread starts here 20190514131654.25463-1-oleksandr@redhat.com]
> 
> On Wed 15-05-19 08:53:11, Michal Hocko wrote:
> [...]
> > I will try to comment on the interface itself later. But I have to say
> > that I am not impressed. Abusing sysfs for per process features is quite
> > gross to be honest.
> 
> I have already commented on this in other email. I consider sysfs an
> unsuitable interface for per-process API.

Wait, what?  A new sysfs file/directory per process?  That's crazy, no
one must have benchmarked it :)

And I agree, sysfs is not for that, please don't abuse it.  Proc is for
process apis.

thanks,

greg k-h

