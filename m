Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9941C282D9
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 10:30:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C4D6218D3
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 10:30:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="RJwgaBs8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C4D6218D3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3678D8E0002; Thu, 31 Jan 2019 05:30:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 316148E0001; Thu, 31 Jan 2019 05:30:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 206D68E0002; Thu, 31 Jan 2019 05:30:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id CE1E18E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 05:30:30 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id i124so1861313pgc.2
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 02:30:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=jjdfEJaEYqyHvE39Q3E9pHyf6stwD6p51MDgkNf625E=;
        b=Kb4DUnYxwbWTLbOH9TWK0flRJuobAUidjQ78SzTDsvjp9kGtsNmUGeeOEY+gy6oxY/
         0hmrEI0SOeoIqg122Tx+lcviLGQyGmDM4iR1w0JvpY39yibCfB5NPi6w+0kZ5RgF8xhc
         ID3cAhhTEZ8ps7xyOYYkAMxxWTdoCrY2B6mkKgq3Xs6FKWN8s2ch/ssbW6P1uuQzUR/s
         Y/7OclvGhgXD56bf8ArbmkTw5dbe7hPB4ELaxqHT1NwtVi41mCODRgcpai9ZEAyGlw9D
         nncf2ljHCFbUG0a/V/E3EiMs78bgulA/fEsmmT8nuQA7x8JjXBZA985RGgG41+jsZSxA
         KuTg==
X-Gm-Message-State: AJcUukd2huEzEqBvUEB3ixTHxSuUAjNooqc2aozTtsMOM4fiI03csoZ2
	EjX9HxXhOeMoMOxG9CR75wTkRsTDmKuKUnHquykweG3AmmrXh4Nq8v7+Syy2VDjdwwfJgE7N3ka
	eKHgpKpxI8ZDLlt9zfxatc+ZUVLnAvIxGcdFloilF0LMVrRDc9APPi49z+qquUZQUPQ==
X-Received: by 2002:a62:5b83:: with SMTP id p125mr34479529pfb.116.1548930630418;
        Thu, 31 Jan 2019 02:30:30 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7zztv3FXxi5ZStWLJ262eLJA0b+CM1pkWAX5IMf4oZXfVMAKiPOB5Zh4RMKFGtPeRFA0/d
X-Received: by 2002:a62:5b83:: with SMTP id p125mr34479479pfb.116.1548930629660;
        Thu, 31 Jan 2019 02:30:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548930629; cv=none;
        d=google.com; s=arc-20160816;
        b=qvpb4E4u1ISrT77XrSkcsHsu0e1VTzOc2OBpD5svNdROHvjNH1QqrOzskRu4+Wb7rA
         FUAiG4Dg/fIbMXCPx8ABHQXdgjGwoVWEWc05pfhzfPrbQKWxp6isHYP7xWM/WR9SnyaF
         xlDuinm8hoeauZbudnIRXqiQPDu082owfs44qYglC6iKJbpS8mRa45ZHm2KrB67BmTOA
         DOQFdJd88Q85U1JpRjDk4UMCh8Ikp6CqXn9PAF+MhS1Dy3y/lusJMZLFONtYMC1+lpK4
         7Y+J+D2ZD5XT242kTkxmY0DWt8P5hh4bYTWiPFSTG16Vm8VImV3f4o02RLcamdS/tb0q
         ghdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=jjdfEJaEYqyHvE39Q3E9pHyf6stwD6p51MDgkNf625E=;
        b=dIkW4D2XMD9psZeig4xRYxK2UruBvY/52yN5HSI7qTMmJrDRz6gIJix6LHpLCWK0am
         ds7wURZhb+tYuI8w9ix5hlhJS/UgoM9jTdeog3OhMN3MZUS3V/9jqxpokN5mtE7yKtE7
         RWy/Kf/MutMOMEjm6qsfzjjz1betoKIMG+kqYeEhEC/2jZQImZTV6f4qopWj++n5XhRW
         hV+64MWBka/tG6CGL/i5zly93iO7jlo9277ri9r0C011jWLRw4Ze9ZHaJuvq3KHJJ3oc
         0ZGlZs2K2bxnmYsB+KITbBB0KKETDN8L81d0H2VFq27sB1aXPp2Kib/N5dpo4Hvru++L
         EWuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=RJwgaBs8;
       spf=pass (google.com: domain of jikos@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p5si4210506pfb.188.2019.01.31.02.30.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 02:30:29 -0800 (PST)
Received-SPF: pass (google.com: domain of jikos@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=RJwgaBs8;
       spf=pass (google.com: domain of jikos@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jikos@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from pobox.suse.cz (prg-ext-pat.suse.com [213.151.95.130])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 01DA0218AC;
	Thu, 31 Jan 2019 10:30:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1548930629;
	bh=Y2q2CGTr8DC8b5sUaWln1mdflBI54lRZC+oK9+sq4fg=;
	h=Date:From:To:cc:Subject:In-Reply-To:References:From;
	b=RJwgaBs8AwKSAgm+Pqtpv5rDpOa/DdLevBF/0L1uyrwGGr3bMPou4mxv/Katajwu9
	 tw9/N/B0Jm9pmTP2tL7DqioyGhCkyQPaJ2Hcph7WIzpSCxIkHZ/kGNWUs4q3Ve/3j4
	 9b4MsooLv8MXcQ3kEoyWvgANTMXXXOdarH1dJqqU=
Date: Thu, 31 Jan 2019 11:30:24 +0100 (CET)
From: Jiri Kosina <jikos@kernel.org>
To: Michal Hocko <mhocko@kernel.org>
cc: Vlastimil Babka <vbabka@suse.cz>, 
    Andrew Morton <akpm@linux-foundation.org>, 
    Linus Torvalds <torvalds@linux-foundation.org>, 
    linux-kernel@vger.kernel.org, linux-mm@kvack.org, 
    linux-api@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, 
    Greg KH <gregkh@linuxfoundation.org>, Jann Horn <jannh@google.com>, 
    Dominique Martinet <asmadeus@codewreck.org>, 
    Andy Lutomirski <luto@amacapital.net>, Dave Chinner <david@fromorbit.com>, 
    Kevin Easton <kevin@guarana.org>, Matthew Wilcox <willy@infradead.org>, 
    Cyril Hrubis <chrubis@suse.cz>, Tejun Heo <tj@kernel.org>, 
    "Kirill A . Shutemov" <kirill@shutemov.name>, 
    Daniel Gruss <daniel@gruss.cc>, linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 2/3] mm/filemap: initiate readahead even if IOCB_NOWAIT
 is set for the I/O
In-Reply-To: <20190131102348.GT18811@dhcp22.suse.cz>
Message-ID: <nycvar.YFH.7.76.1901311129420.3281@cbobk.fhfr.pm>
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm> <20190130124420.1834-1-vbabka@suse.cz> <20190130124420.1834-3-vbabka@suse.cz> <20190131095644.GR18811@dhcp22.suse.cz> <nycvar.YFH.7.76.1901311114260.6626@cbobk.fhfr.pm>
 <20190131102348.GT18811@dhcp22.suse.cz>
User-Agent: Alpine 2.21 (LSU 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 31 Jan 2019, Michal Hocko wrote:

> > > > diff --git a/mm/filemap.c b/mm/filemap.c
> > > > index 9f5e323e883e..7bcdd36e629d 100644
> > > > --- a/mm/filemap.c
> > > > +++ b/mm/filemap.c
> > > > @@ -2075,8 +2075,6 @@ static ssize_t generic_file_buffered_read(struct kiocb *iocb,
> > > >  
> > > >  		page = find_get_page(mapping, index);
> > > >  		if (!page) {
> > > > -			if (iocb->ki_flags & IOCB_NOWAIT)
> > > > -				goto would_block;
> > > >  			page_cache_sync_readahead(mapping,
> > > >  					ra, filp,
> > > >  					index, last_index - index);
> > > 
> > > Maybe a stupid question but I am not really familiar with this path but
> > > what exactly does prevent a sync read down page_cache_sync_readahead
> > > path?
> > 
> > page_cache_sync_readahead() only submits the read ahead request(s), it 
> > doesn't wait for it to finish.
> 
> OK, I guess my question was not precise. What does prevent taking fs
> locks down the path?

Well, RWF_NOWAIT doesn't mean the kernel can't reschedule while executing 
preadv2(), right? It just means it will not wait for the arrival of the 
whole data blob into pagecache in case it's not there.

-- 
Jiri Kosina
SUSE Labs

