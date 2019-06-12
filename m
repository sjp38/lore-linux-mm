Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1CC05C31E46
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 18:04:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEFA92080A
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 18:04:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Z/GOFRJX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEFA92080A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 729046B000D; Wed, 12 Jun 2019 14:04:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6DACE6B000E; Wed, 12 Jun 2019 14:04:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5A2476B0010; Wed, 12 Jun 2019 14:04:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id E3F8C6B000D
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 14:04:18 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id 77so956187ljf.0
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 11:04:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=HA7VYYB6HYTnwOsfSZ6IJMiRwVIheU8PeAUQ4SUxsDE=;
        b=r/lIn/XmQIiEdakspgsXzNICLKP+dP76z0Uj8XyXy6PGEl6cE0r5Jtt6J471+/qIjM
         p1C6o12xXEdH/gTU2P1kpG4om/OReglRQ5SPFWEtSoHgG2/rsNEHWlSWWE95PV6ek/AA
         bCPzC2G42eXokFetsyl2i5junH4SUH3pLj9ukohfJeg2di/AallhyTvxSB5oTYRtLo+z
         iFLRurLpAAMLL688DvF2bVKye7/V8hMfXZl66SuMk5ruVUTqgHc5iNoJkc9P1SXq2+sn
         ao0Np1b91qJxfw6mP5iMKVgt6tZSGNfRf5aimTmQniLwqhLivyFqo0luvbFn+6ODeswG
         LEHA==
X-Gm-Message-State: APjAAAWoGxNVUM3eLuthJ0DLLjDEkceyVAdE/QQHzeCvE61mrTZCfDhS
	lBYIZtMS5wNPaTXvQuzZ0qn4N1T5NGDV+hziByZ0gSmeTjsLv5xEUhLTgAtxulSU+kOB9rwnL5l
	Dl82zrN5f0nxC+Wh0Q6j0vMGfCJYi0ziezZkcF/zeaSfYAGNG/aQgOFMo2ddtVADLnQ==
X-Received: by 2002:a2e:9857:: with SMTP id e23mr10824548ljj.217.1560362658408;
        Wed, 12 Jun 2019 11:04:18 -0700 (PDT)
X-Received: by 2002:a2e:9857:: with SMTP id e23mr10824505ljj.217.1560362657666;
        Wed, 12 Jun 2019 11:04:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560362657; cv=none;
        d=google.com; s=arc-20160816;
        b=LYdhfOVROlpvox+n9fXV7fnBGt1B+BZqiMG0yDlaVQBLYntTq4/oofrCQCLkA2gbME
         Jhk/Dc/biXd+c2NziMnUCr3G1iat3qlHfanaED9kmFvRBJObs1YTOVlNHh2XDW9dBfoy
         1L8xRHNI+vz6YVTxNRrSAoNbcP7aAQWNpbcQRKKIku4D6JmN5KOqT2Z8F+2cQpB+9zgO
         QnhByW71PYKfwLnHOuIJuv2k4bxtL7BPko8Xt8RRdu7YwXIJJOvPgyOPwJqJv9SLtULs
         kMPyfFNbsw5iCDIxJmGr32bmoJUqSEvfIaxz0qTwhYyh/qbyHxIWJte2ZYRAWO0Jj59i
         xbaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=HA7VYYB6HYTnwOsfSZ6IJMiRwVIheU8PeAUQ4SUxsDE=;
        b=rETOG5VH3jbyVsMPdDTdrX73vHv85XXR2YEds7J/4qZowmeLgx59tBf3oPSQLXP+k8
         CgnvjRGHrAhYQQIvm0zkVipA/AJ7pA167kva7D21GqyPGy2O5CLXhsHEPlxTY592pchK
         IhS8YwAfqHag1YIjXZZVaJfkkYjhWcL8/CU7AnVkvxMKhi6WyqhDrfX+r8hhJwkTa6Jr
         Nakgfiq87s2I9z2y5araNRluZzilQxY+P98+aefr5LrBtYrqMy/Cr2zWS8nxd8f3hbtH
         K6+tZIgj8lBffYPG6fuiKdPxZkHj+ixJirkVqVUgn6/fZVJ9mVpNGRo191h5aJdWIzy5
         l1iA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="Z/GOFRJX";
       spf=pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=gorcunov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v9sor310213ljh.19.2019.06.12.11.04.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 11:04:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b="Z/GOFRJX";
       spf=pass (google.com: domain of gorcunov@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=gorcunov@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=HA7VYYB6HYTnwOsfSZ6IJMiRwVIheU8PeAUQ4SUxsDE=;
        b=Z/GOFRJXw0yo2NclXm9o0hxO/gUmaXJp5lNg1hcuR0tF6112X2HthCJzh8CXxy/QSX
         Casq6IhYPWFHSOoYCLPqB5YZn+lGzUwQDR1WTAPmX/8rdQITptlPHe92KHb2/yaoL1Qt
         OGcdLSSG0ZNjV51rjf3jHYjCGK90xs/bev2fp5W1lR0cxH4M1DMEqcSVFwkMuNOQm5xw
         6YU/glgO1ALD0evMQ/dDqytfrdWiSyB7glDGSG68T2gHvfxZHd4tJisB95h9lQor2gZu
         cbJMtpKGYitBwg44ruAKeGOHc2XkjHf/HsoByLHJvjodM4T3nwRt15ULmQgxdTiwyLJ3
         C2PQ==
X-Google-Smtp-Source: APXvYqzotGrbJI9s/KdrG87kqY2e2cD44RcIacKKFE4JrKA3iuS7uYtR1JSgUbX5wF56fdmAE1QXjA==
X-Received: by 2002:a2e:890a:: with SMTP id d10mr1641465lji.145.1560362657186;
        Wed, 12 Jun 2019 11:04:17 -0700 (PDT)
Received: from uranus.localdomain ([5.18.102.224])
        by smtp.gmail.com with ESMTPSA id w205sm96813lff.92.2019.06.12.11.04.15
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 12 Jun 2019 11:04:16 -0700 (PDT)
Received: by uranus.localdomain (Postfix, from userid 1000)
	id 90A854605BC; Wed, 12 Jun 2019 21:04:15 +0300 (MSK)
Date: Wed, 12 Jun 2019 21:04:15 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
To: Matthew Wilcox <willy@infradead.org>
Cc: Michal =?iso-8859-1?Q?Koutn=FD?= <mkoutny@suse.com>, linux-mm@kvack.org,
	Laurent Dufour <ldufour@linux.ibm.com>,
	linux-kernel@vger.kernel.org, Kirill Tkhai <ktkhai@virtuozzo.com>
Subject: Re: [RFC PATCH] binfmt_elf: Protect mm_struct access with mmap_sem
Message-ID: <20190612180415.GE23535@uranus.lan>
References: <20190612142811.24894-1-mkoutny@suse.com>
 <20190612170034.GE32656@bombadil.infradead.org>
 <20190612172914.GC9638@blackbody.suse.cz>
 <20190612175159.GF32656@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190612175159.GF32656@bombadil.infradead.org>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 12, 2019 at 10:51:59AM -0700, Matthew Wilcox wrote:
> On Wed, Jun 12, 2019 at 07:29:15PM +0200, Michal Koutný wrote:
> > On Wed, Jun 12, 2019 at 10:00:34AM -0700, Matthew Wilcox <willy@infradead.org> wrote:
> > > On Wed, Jun 12, 2019 at 04:28:11PM +0200, Michal Koutný wrote:
> > > > -	/* N.B. passed_fileno might not be initialized? */
> > > > +
> > > 
> > > Why did you delete this comment?
> > The variable got removed in
> >     d20894a23708 ("Remove a.out interpreter support in ELF loader")
> > so it is not relevant anymore.
> 
> Better put that in the changelog for v2 then.  or even make it a
> separate patch.

Just updated changelog should be fine, I guess. A separate commit
just to remove an obsolete comment is too much.

