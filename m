Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07E15C43218
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 20:41:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C33EE2082E
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 20:41:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C33EE2082E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mit.edu
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70C696B026B; Mon, 10 Jun 2019 16:41:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6BD526B026C; Mon, 10 Jun 2019 16:41:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5AB816B026D; Mon, 10 Jun 2019 16:41:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3313B6B026B
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 16:41:57 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id 129so3307575vkh.15
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 13:41:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=ZGkqaqJfwPd+fjM7twQRXkHZqhGbKhROgc44/T3iciA=;
        b=VAMh3Kle3GYyDVeID9aBFT7b26RoBp+4nf4vitOrI9EvGXj5dLOyrC6TBvwG14//Yy
         jtmlvAs5V7PRYdmwtEjFh7bvPgSp72U5q42ewBZyJ6vV+TPLxxJwoTzj0iMycxlTChev
         264QkH7SPlz/prFrMZmm4GvjPg2wWLObnJFvm2nlgb/5JBhkkdHTn2I0aQGu2C0IXYd4
         d+N8pzI1cAUejaNQtughvSy/Z8HxALghFs6YzGbu7DrCM3uphMLtroddj6wGDUFq91G9
         +qEglEUYwkIUbu5Cv8BWVLrL8XWjUrF0X8Lr9f3QtS7Tbdrbo/cYZVtI5G1z6knioHHU
         qvTA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
X-Gm-Message-State: APjAAAXI1rgSuoMuGYSPkhHfypZQMKkIoNNfangX4lzRv0fdZ3HM0ucC
	DMIG9rqbLD6BLAikl6PM8Cleh8YBO96IBVVGqOT7QrsmxanucOpJVusxoZahBftJ0uPGYyqsyHf
	Krh43CA5orJq+ocmzOokvLU/K/jeJ6c8NyFgnE6WW02scwzAyIlF4szE2aYEZOPUxbA==
X-Received: by 2002:a67:c503:: with SMTP id e3mr28492163vsk.230.1560199316952;
        Mon, 10 Jun 2019 13:41:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwXGkj1jebNFR0t8MnywdoQkQ9LwMoxysPTYEilPm0jy3sd3sTkzGffKAaCgwF487F6lC+c
X-Received: by 2002:a67:c503:: with SMTP id e3mr28492085vsk.230.1560199316265;
        Mon, 10 Jun 2019 13:41:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560199316; cv=none;
        d=google.com; s=arc-20160816;
        b=1KCcdeUlDk+DJOEX8lIHzxCoZ33oYTAKlp4TtL4H97ivYadH5NMDcBGbOafsu9sf/P
         I0hrZghz3bYrwyHJPfOOhhWhZzExSOIPpYS3TXc6qZHCnr9hTuHuZeaEIBr2mJQlctxV
         6sbMo32Z/Emq9wiDnVmpbkxO+QXoHYHcUUuzokqC+qq7x8GnpV3dV+HbRDtckjO37iA7
         Iky2Y6+llMADAj/6f4NPBrj1PifYdlmmOvvym1BsikdzoRc8t72ncZlgI3qxl1yMDW/l
         TJHy54fxOLzme/yfW1pdiZsePp9CmW+nfp3YpjWwcUbD/zYl0yoyN7JEx1SegzJpXIgg
         jgUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=ZGkqaqJfwPd+fjM7twQRXkHZqhGbKhROgc44/T3iciA=;
        b=i3eUojY9HNr1Fv5crta+KIiI49NqXCMbODrc5knMZqY4QrBTjvkUcuqdXY2IdQsZIL
         4blp2x4FkcXzA37la3FpwWdxTDCWKsQ3tn6GEqSjNfgwZKst/BGt7MVjRUhZuxLwnbn4
         zMvEwop9z5B8NSttJnUPEZrA/rDY6zlgsUFGYWdlELi9PdcvT6gVOLaoTZpMg8y6cnUL
         FHu/K+XG2Hdx9QcXdWID1ju/9IS6G8h8JFzgknC/gfhl8fLXLSBIBqn6c52f/n9h8pjU
         8NtnXm7K2rHGIkMLrtjqZeWRQEadHJ2gQcfDe/S2qNoY0F4XzZ2Z4psdVxYswIZB/4UB
         5sKg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
Received: from outgoing.mit.edu (outgoing-auth-1.mit.edu. [18.9.28.11])
        by mx.google.com with ESMTPS id t16si2842305ual.126.2019.06.10.13.41.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 13:41:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) client-ip=18.9.28.11;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of tytso@mit.edu designates 18.9.28.11 as permitted sender) smtp.mailfrom=tytso@mit.edu
Received: from callcc.thunk.org (guestnat-104-133-0-109.corp.google.com [104.133.0.109] (may be forged))
	(authenticated bits=0)
        (User authenticated as tytso@ATHENA.MIT.EDU)
	by outgoing.mit.edu (8.14.7/8.12.4) with ESMTP id x5AKfsg3006278
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NOT);
	Mon, 10 Jun 2019 16:41:55 -0400
Received: by callcc.thunk.org (Postfix, from userid 15806)
	id 1ADDB420481; Mon, 10 Jun 2019 16:41:54 -0400 (EDT)
Date: Mon, 10 Jun 2019 16:41:54 -0400
From: "Theodore Ts'o" <tytso@mit.edu>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: linux-xfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-mm@kvack.org
Subject: Re: [PATCH 1/8] mm/fs: don't allow writes to immutable files
Message-ID: <20190610204154.GA5466@mit.edu>
References: <155552786671.20411.6442426840435740050.stgit@magnolia>
 <155552787330.20411.11893581890744963309.stgit@magnolia>
 <20190610015145.GB3266@mit.edu>
 <20190610044144.GA1872750@magnolia>
 <20190610131417.GD15963@mit.edu>
 <20190610160934.GH1871505@magnolia>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190610160934.GH1871505@magnolia>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 10, 2019 at 09:09:34AM -0700, Darrick J. Wong wrote:
> > I was planning on only taking 8/8 through the ext4 tree.  I also added
> > a patch which filtered writes, truncates, and page_mkwrites (but not
> > mmap) for immutable files at the ext4 level.
> 
> *Oh*.  I saw your reply attached to the 1/8 patch and thought that was
> the one you were taking.  I was sort of surprised, tbh. :)

Sorry, my bad.  I mis-replied to the wrong e-mail message  :-)

> > I *could* take this patch through the mm/fs tree, but I wasn't sure
> > what your plans were for the rest of the patch series, and it seemed
> > like it hadn't gotten much review/attention from other fs or mm folks
> > (well, I guess Brian Foster weighed in).
> 
> > What do you think?
> 
> Not sure.  The comments attached to the LWN story were sort of nasty,
> and now that a couple of people said "Oh, well, Debian documented the
> inconsistent behavior so just let it be" I haven't felt like
> resurrecting the series for 5.3.

Ah, I had missed the LWN article.   <Looks>

Yeah, it's the same set of issues that we had discussed when this
first came up.  We can go round and round on this one; It's true that
root can now cause random programs which have a file mmap'ed for
writing to seg fault, but root has a million ways of killing and
otherwise harming running application programs, and it's unlikely
files get marked for immutable all that often.  We just have to pick
one way of doing things, and let it be same across all the file
systems.

My understanding was that XFS had chosen to make the inode immutable
as soon as the flag is set (as opposed to forbidding new fd's to be
opened which were writeable), and I was OK moving ext4 to that common
interpretation of the immmutable bit, even though it would be a change
to ext4.

And then when I saw that Amir had included a patch that would cause
test failures unless that patch series was applied, it seemed that we
had all thought that the change was a done deal.  Perhaps we should
have had a more explicit discussion when the test was sent for review,
but I had assumed it was exclusively a copy_file_range set of tests,
so I didn't realize it was going to cause ext4 failures.

     	    	       	   	 - Ted

