Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92CC0C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 12:06:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E1F620989
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 12:06:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E1F620989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CDBC46B028F; Mon, 13 May 2019 08:06:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C8C3F6B0290; Mon, 13 May 2019 08:06:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B544C6B0291; Mon, 13 May 2019 08:06:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id 63E406B028F
	for <linux-mm@kvack.org>; Mon, 13 May 2019 08:06:34 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id x130so5863467wmg.1
        for <linux-mm@kvack.org>; Mon, 13 May 2019 05:06:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=biNvHQKs15xbQFoeFpqb5Q0+JlVOB2+nGH0+sYLUzJo=;
        b=EBnlHZBHEMkD7uyfCdY6sgxxmjnKdiSbrZHp5Vg5o648Vy9b0bG0Lu+4F3KQJSu2+L
         6l0Ywh4nv+hnlZv8UtgoaV1dX6B40lmS2d4TE0G8AD1TswkjpvDahr5KC1F/KG/lmCrv
         /wvkebGXsOQqo1/XyEsO+c5YniRNdWiYVBypQ4XhzBdx2tBFKIHqF/tYEE2dcSfzhtab
         mvhudwdS27HXbFQWd1eGz+rZ2hPfX29tFkad83ihOEu4jZg5wT+tQPlzioBQtS+61L7t
         GR3z8XmJsKdhgnp203FcyD4eAcaGTc215HQWINKrFv1Uw9IwyN/pUXL76aPmlek4CcTH
         decA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUOSqi1An8T/ogiS98DypqZhf4fqrAL1oC/Onrn3/8M4jws0Yln
	qPIXIyV422Z8vOqUOzeQsGhm7XOJO47FTXf4Pc0wexQiREBDCyyMtZetw6NtUykgXLb73Gf4n80
	m9W9NMTktKhf4M1lEAd+wol9YviaLueE+M3rbLWm6iWV+8VDwQ9rsnk8u0NIQhQXRPg==
X-Received: by 2002:adf:dd51:: with SMTP id u17mr14099929wrm.150.1557749194003;
        Mon, 13 May 2019 05:06:34 -0700 (PDT)
X-Received: by 2002:adf:dd51:: with SMTP id u17mr14099881wrm.150.1557749193337;
        Mon, 13 May 2019 05:06:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557749193; cv=none;
        d=google.com; s=arc-20160816;
        b=EPOmNscHMZ8C0lTNt9pMpgM/m8+cZG+MfGWbN952I+GfVUB6/+XfWyiXVoiVm6Yc3v
         tLxUV7oaVnxeLzccYhcFruuHYT7DEhaVfQ/U9k1rGKlJzZJr71VI11gIJeFCUnZpjYMg
         xsN+SR/nVK22wTAmJR2p/LAHOASIhPlSx3YfpNpUeJkDSsQeryqo93gMNTYnjQE0HxDr
         XoNsnxDQ6kLqPZKawign/qZTxeUevxhWehONXCjbaY7thmEyHJdAS5TAOXOHMeIvbj46
         teicPhdK05wLdb9uglK3A6B+1rMhWWf8IEQc3Bg7LGLFxXKpGIHDIAN0CuVDHOBbLcQb
         hffg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=biNvHQKs15xbQFoeFpqb5Q0+JlVOB2+nGH0+sYLUzJo=;
        b=bOKqWxC1wN1FJbTlKiD6DRjtNJrICYnHbw+ic298Ul+uDedLyqcCiggTsbvmYICjGm
         Tl+tD/b+QjrhKQBfNbokR+1YiuoajyHw7iqMwZQsw0qv/r62E+Em7Xzeyyz5uu1yiXRj
         PZZkjIJqkX48wYu+A7ma+mHrSUt40IZaw3Iin1w/Afrw//rZlJU63dZ/zXkZ4ViaC8xs
         x6TMZ5bQa31lyq1sFtLcGXXsnwMFJbBGqKO2Q2Hx8Uh4XFpSOp4OmvvFtENHJsG2YVax
         EYEpWrFus8UkT6tewMw+1s2KRn0PrHGsM1jBaFgegbGezeSRtP/HkV+fESJVpsz9QzVD
         MnFw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p6sor129657wrt.23.2019.05.13.05.06.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 13 May 2019 05:06:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqzR54BPsEiJ8auTB6b64uU/gwBWlUPQ8ai+VlYRzE6qMlhJjD4AcuX7KIg5zrVoiA8EDFzDrQ==
X-Received: by 2002:adf:d089:: with SMTP id y9mr5913422wrh.239.1557749192996;
        Mon, 13 May 2019 05:06:32 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id o4sm12500619wmc.38.2019.05.13.05.06.31
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 13 May 2019 05:06:31 -0700 (PDT)
Date: Mon, 13 May 2019 14:06:31 +0200
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: Timofey Titovets <nefelim4ag@gmail.com>
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Aaron Tomlin <atomlin@redhat.com>, linux-mm@kvack.org
Subject: Re: [PATCH RFC 0/4] mm/ksm: add option to automerge VMAs
Message-ID: <20190513120631.cm2mc5grkofvloyk@butterfly.localdomain>
References: <20190510072125.18059-1-oleksandr@redhat.com>
 <36a71f93-5a32-b154-b01d-2a420bca2679@virtuozzo.com>
 <20190513113314.lddxv4kv5ajjldae@butterfly.localdomain>
 <CAGqmi744Vef7iF0tuBO3uBtXbNCKYxBV_c-T_Eg3LKPY0rKcWA@mail.gmail.com>
 <20190513120117.aeiij4v2ncu43yxt@butterfly.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190513120117.aeiij4v2ncu43yxt@butterfly.localdomain>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 13, 2019 at 02:01:17PM +0200, Oleksandr Natalenko wrote:
> On Mon, May 13, 2019 at 02:48:29PM +0300, Timofey Titovets wrote:
> > > Also, just for the sake of another piece of stats here:
> > >
> > > $ echo "$(cat /sys/kernel/mm/ksm/pages_sharing) * 4 / 1024" | bc
> > > 526
> > 
> > IIRC, for calculate saving you must use (pages_shared - pages_sharing)
> 
> Based on Documentation/ABI/testing/sysfs-kernel-mm-ksm:
> 
> 	pages_shared: how many shared pages are being used.
> 
> 	pages_sharing: how many more sites are sharing them i.e. how
> 	much saved.
> 
> and unless I'm missing something, this must be already accounted:
> 
> [~]$ echo "$(cat /sys/kernel/mm/ksm/pages_shared) * 4 / 1024" | bc
> 69
> 
> [~]$ echo "$(cat /sys/kernel/mm/ksm/pages_sharing) * 4 / 1024" | bc
> 563

Yup. To expand on this,

 246 /* The number of nodes in the stable tree */
 247 static unsigned long ksm_pages_shared;
 248 
 249 /* The number of page slots additionally sharing those nodes */
 250 static unsigned long ksm_pages_sharing;

2037     if (rmap_item->hlist.next)
2038         ksm_pages_sharing++;
2039     else
2040         ksm_pages_shared++;

IOW, first item is accounter in "shared", the rest will go to "sharing".

-- 
  Best regards,
    Oleksandr Natalenko (post-factum)
    Senior Software Maintenance Engineer

