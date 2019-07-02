Return-Path: <SRS0=T9E7=U7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BC55C5B57D
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 21:33:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1236F218D1
	for <linux-mm@archiver.kernel.org>; Tue,  2 Jul 2019 21:33:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="RBa6CBZo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1236F218D1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A11B36B0003; Tue,  2 Jul 2019 17:33:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C2238E0003; Tue,  2 Jul 2019 17:33:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B26B8E0001; Tue,  2 Jul 2019 17:33:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 54D296B0003
	for <linux-mm@kvack.org>; Tue,  2 Jul 2019 17:33:43 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d187so197515pga.7
        for <linux-mm@kvack.org>; Tue, 02 Jul 2019 14:33:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=gmn4/gRjuuSlk+8UerSlSJop90toIZ+cMx1MNCYSm7o=;
        b=FWcIg6mafdDQdHufMSadKfPaghJZgkVJVhn305Xxqos8iiVSjZoquq+aXL9HhccuX/
         EksrMPe7nvRA/p5r41RVRUmjv96e5Ih4SbqSogrdOrcO1MmTY0QkSVN9cgtMrq4l1NWT
         a9ezzG9naNqMA1qEiSNuE1DzUtweJLaZbfWZymS4nM+pSol6OTCq/tqclKC44qvsS7/W
         rGWLRGbrc52M+8Jw7QEaD1z/zBSFoBZ6tF8Mm3b3n9TQ/SDuJyys+bVOPP4IowHKkxcG
         00z63QajCO4y4/f78lZ++4i1PiwYe519s6k3BXB2W0Wz2Abmn3vfd4XOLFsHxJIPfIXQ
         R36w==
X-Gm-Message-State: APjAAAXAPWqKpD5n25zG4aZeR/8qXbJJdk2/uuuwPQh1k49aRrSYBPY2
	iN8GpYryXsw5IIG5vmk5S+upOCJbk+HXv32PQaOix5/bMnftlVPeXsuvJJ1yQb8s7BB91DiiOba
	1DHkzEZQcf1k+R1nf8pcT7imqO9hpUhkJzf7oaDAAvmFYe7IxCk38zHRrppJDA/ltfQ==
X-Received: by 2002:a17:90a:228b:: with SMTP id s11mr7799811pjc.23.1562103222903;
        Tue, 02 Jul 2019 14:33:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw01Cth5rKuZJgr/UV88RA+t7VGPG7mQAVT06rVbqjNbbett6jTD3MUotLgEm6C2Ic5vXaq
X-Received: by 2002:a17:90a:228b:: with SMTP id s11mr7799745pjc.23.1562103222025;
        Tue, 02 Jul 2019 14:33:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562103222; cv=none;
        d=google.com; s=arc-20160816;
        b=PUk4P2nryg2z3xbgSYDvdKN77TD0k+v7HRbmdjnAgUYod2/5XY+boN8sPZmi8M9oSw
         7nvqEKHWfQw+feD0L2koJZI2/wqLdIboIA7TkpJsKk6MYcRJeqaKW4wqEn2p9HlABLqE
         nSDZHmF90pZl/fDN88pJuXgUh2w8tB/BLnxZAOXx/tJKmXsetqvAopAx15cO/ITGxdwD
         Fs3vXMQSGBAV0Bey4lXz1PbEZl4qBIokXKmF/z/wg9taZb5uLH2yIEuVlwtrfNvx1HFK
         9o9OY2BTyunA22VZZ4rjVa0Ml6LAOkWKylL5NrD3R3oS9HCijKh4Gcd7brp/e7K00jkH
         k/Kg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=gmn4/gRjuuSlk+8UerSlSJop90toIZ+cMx1MNCYSm7o=;
        b=rK94Y+p4MZmnkzhErwDxjvRPpBSquBEIXJF0p1j77PjxsjELY0221ftyps1Zqlq7Gu
         yqlzxTrUqPXA4D5N30gEd1rNxqhhfCoyO+zsTmP4i1OLXc3Ol7Wp7sIVkMMQVriZImvt
         0mVEJ3shxetqJinnbadYinVGvlDdpERKO28x9jbqARQsNUQmx+s4YAs3Z9jxlgo2x8/a
         wXSsVq5f3M1lougwuhoDNQSXDmzf3ck1/XW+8H/6myG/Y9vST0X6Uxx8v84PQKtUrkRI
         KBCtQOLt9gYzDRW7KUkJ6Ao4+bl9x5rwCy/KsthYlExeXZbE0eKx4EJeik4rRU5dY73Z
         b9nw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=RBa6CBZo;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id j100si3053145pje.52.2019.07.02.14.33.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jul 2019 14:33:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=RBa6CBZo;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id ED1AE218CA;
	Tue,  2 Jul 2019 21:33:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562103221;
	bh=7BKwrn5ZR0EvyKBoBdw71Sjqy+1SUbMyW6AzU7/ufH4=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=RBa6CBZoD/h1b3spSkXt/s5mk4/LF71sNM0q6jPS2dnne68logM7RJmnQeYqnoPlk
	 We4S37hoCXN1vJ/SylpXLdidWn8wQovBsN3zWD/thJwRlA5V0kPWzkSRUxdgTRtCMR
	 lCSW1e94ZmkPHXhQYrDUGU4rHNsLYjp0UCC4jn8o=
Date: Tue, 2 Jul 2019 14:33:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Waiman Long <longman@redhat.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>,
 David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>,
 Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>,
 Luis Chamberlain <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>,
 Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
 Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org,
 linux-doc@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Roman Gushchin
 <guro@fb.com>, Shakeel Butt <shakeelb@google.com>, Andrea Arcangeli
 <aarcange@redhat.com>
Subject: Re: [PATCH] mm, slab: Extend slab/shrink to shrink all the memcg
 caches
Message-Id: <20190702143340.715f771192721f60de1699d7@linux-foundation.org>
In-Reply-To: <78879b79-1b8f-cdfd-d4fa-610afe5e5d48@redhat.com>
References: <20190702183730.14461-1-longman@redhat.com>
	<20190702130318.39d187dc27dbdd9267788165@linux-foundation.org>
	<78879b79-1b8f-cdfd-d4fa-610afe5e5d48@redhat.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.32; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2 Jul 2019 16:44:24 -0400 Waiman Long <longman@redhat.com> wrote:

> On 7/2/19 4:03 PM, Andrew Morton wrote:
> > On Tue,  2 Jul 2019 14:37:30 -0400 Waiman Long <longman@redhat.com> wro=
te:
> >
> >> Currently, a value of '1" is written to /sys/kernel/slab/<slab>/shrink
> >> file to shrink the slab by flushing all the per-cpu slabs and free
> >> slabs in partial lists. This applies only to the root caches, though.
> >>
> >> Extends this capability by shrinking all the child memcg caches and
> >> the root cache when a value of '2' is written to the shrink sysfs file.
> > Why?
> >
> > Please fully describe the value of the proposed feature to or users.=20
> > Always.
>=20
> Sure. Essentially, the sysfs shrink interface is not complete. It allows
> the root cache to be shrunk, but not any of the memcg caches.=A0

But that doesn't describe anything of value.  Who wants to use this,
and why?  How will it be used?  What are the use-cases?

