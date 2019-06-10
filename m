Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C69F2C282DD
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 13:09:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 561A420679
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 13:09:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="BhIIjcgO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 561A420679
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 999476B0266; Mon, 10 Jun 2019 09:09:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 949DC6B0269; Mon, 10 Jun 2019 09:09:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 838196B026A; Mon, 10 Jun 2019 09:09:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 61C4E6B0266
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 09:09:18 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id g30so8989120qtm.17
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 06:09:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=4F5p4XvqxWD0TPhx038sRdW6UkfS+pQjYQgLxUjnBMI=;
        b=FxZ86xKAQhBDgn3NfVDdUolF1LhIQiCv8diJQEpamjBkjAIGWRDrXxKxl1qVl7ae0a
         xKXZ9NMy4T54fHVTNCfqyDBkhGD5TtuEN+q1do1lwTx7Z0rGlfGV9c7AhvuYzVnJijf9
         aR274IBl3QmNMgdVJa7kkuWBLV4JfcR7R+ME2fl+DVhCYm0y/Ksx6lfiiIYkGZvS2nDT
         QZwwqM3QS3q83IEYyAXspEcbAMvKig1gUFkT5uwZBnC3i7iJwit1isLYqqzVI4q4egBY
         J+qEFl30ZIQFeOt/lQ0NWmE98+sKDpvos4JyGn8Sse9zBYdVKJYKMo4cs+WbV6cSmNyK
         HAmA==
X-Gm-Message-State: APjAAAVZvJUQz+Z+d+PlrLlGRB+oPMXm9uc1ACYuZw2dn3Mj76Oldfnn
	jip0NUobjZWM91nf1uQVizJSZQLRO2VsBGpXPy47X5xiAd1lyi1oGaEYb+k/YED6ukz28KXMGBH
	xX0iIRFNQBcLy1TFqVHs/dYQPbnewVe2jp3ZIyaZTnfBxLAjXHjrwo4KgSAi/+V80Cg==
X-Received: by 2002:a05:620a:13d9:: with SMTP id g25mr11684719qkl.138.1560172158139;
        Mon, 10 Jun 2019 06:09:18 -0700 (PDT)
X-Received: by 2002:a05:620a:13d9:: with SMTP id g25mr11684620qkl.138.1560172157081;
        Mon, 10 Jun 2019 06:09:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560172157; cv=none;
        d=google.com; s=arc-20160816;
        b=G/8VV+CffmOpwdbbDZ23xXGU9HPjgl/ThWPlAvTSJvxh7UqUdIdzOp4/4fygm/ABeB
         auJ1UQ7Ez3nQYrOWUMeOS8VpLZM2xORsW9mAgKDVnm3oqYvK2YM3eE00bDZEym0HXVrU
         ZosaEcEty4CmvJGYKoeLndM6F3VzsWRwKzGlnyPjiNwoYjKM9st+Y6r7FQfWy+KN1gHK
         WQCkuV4iuAfjzo43dqocF7qgmGndMYxQr9Uzn4F2D6UJYR8LEvN/AOsg/jQtgL7diz5i
         8LY7TatrCoz8zbPEjPfC7Q8YsWSblu9SCa/agFW/JR13a9yvThJYZHjrzOBevW8UIcVp
         +F5g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=4F5p4XvqxWD0TPhx038sRdW6UkfS+pQjYQgLxUjnBMI=;
        b=PQY8+ZvFRkch0U/jIcS5XsHLqZnQVtCN23shxYdJlsR+ug+RINVSu5gKTdqhNDN7SA
         SVnu5cvgknIk5JcLiWbTiGLvlyTn8ZQbeRYsRhIS6DXVRhSSAK0BUrcLiBxPsTzp0dkS
         ffpab9Nkdp90AYUAkPb5VCkDi0+s1ogNJRs4XKN9eLhBMgc1+mls4zJM/3MQEjD1QB87
         nd2UrY4HOCOIVsDudzB85Bu328X776MdzB6dbFst8qxGEoeOpZtIJw6AV6Q4Ozfwa+Mq
         k8QtU1mYpHewoZQQmoQCOqoHOMLGH/tU5kYYzc43a/2l003od1S51lu4OcueTQkT+xzh
         jSmg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=BhIIjcgO;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j34sor12967836qte.42.2019.06.10.06.09.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Jun 2019 06:09:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=BhIIjcgO;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=4F5p4XvqxWD0TPhx038sRdW6UkfS+pQjYQgLxUjnBMI=;
        b=BhIIjcgOeQFdpsXOGxWnmGvjoyeGrIjjevpQNRl/I2/FM8ihdN5hXQobSh95XYjgPy
         BcVai4r/g1HxBTsXAlAV0qer0KY857kzqTHnHg2h6eEGGmmeCl7I6rNfu1lMP1j2s+65
         HMCq4j4xGVfZGz9FHAfQJXTacr+yVjc2YESaxykFfinvyANrOti3zkztW1T11pGgbt+m
         ogx8XVpNVzdJsodX6ozViM6hnDCL71wrSt/am17+Hfd0sGLK4ljxB0UQChBHCVSbWxea
         5/soEI9XcHDofveKfkWMk8uTfUv0yVeOC28YGBJDNyrnMAdm6q1bApQkogtXbzNnCf+V
         garw==
X-Google-Smtp-Source: APXvYqyfdzwD7zPoXm7GvJhg1KqfurFKZJX3W/vApYwm27bMvAhRfi5kk7rnbLbo+akkzc5tVyXK/g==
X-Received: by 2002:ac8:1af4:: with SMTP id h49mr51085239qtk.183.1560172156644;
        Mon, 10 Jun 2019 06:09:16 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id v30sm1245889qtk.45.2019.06.10.06.09.16
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 10 Jun 2019 06:09:16 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1haK31-0006cK-Gt; Mon, 10 Jun 2019 10:09:15 -0300
Date: Mon, 10 Jun 2019 10:09:15 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ralph Campbell <rcampbell@nvidia.com>
Cc: Jerome Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>,
	Felix.Kuehling@amd.com, linux-rdma@vger.kernel.org,
	linux-mm@kvack.org, Andrea Arcangeli <aarcange@redhat.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org
Subject: Re: [PATCH v2 hmm 02/11] mm/hmm: Use hmm_mirror not mm as an
 argument for hmm_range_register
Message-ID: <20190610130915.GA18468@ziepe.ca>
References: <20190606184438.31646-1-jgg@ziepe.ca>
 <20190606184438.31646-3-jgg@ziepe.ca>
 <4a391bd4-287c-5f13-3bca-c6a46ff8d08c@nvidia.com>
 <e460ddf5-9ed3-7f3b-98ce-526c12fdb8b1@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <e460ddf5-9ed3-7f3b-98ce-526c12fdb8b1@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 07, 2019 at 03:39:06PM -0700, Ralph Campbell wrote:
> > > +    range->hmm = hmm;
> > > +    kref_get(&hmm->kref);
> > >       /* Initialize range to track CPU page table updates. */
> > >       mutex_lock(&hmm->lock);
> > > 
> 
> I forgot to add that I think you can delete the duplicate
>     "range->hmm = hmm;"
> here between the mutex_lock/unlock.

Done, thanks

Jason

