Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92112C04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 17:14:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5635E21726
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 17:14:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="X2EOagEp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5635E21726
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EBEF26B0281; Tue, 28 May 2019 13:14:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E96716B0282; Tue, 28 May 2019 13:14:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D858D6B0283; Tue, 28 May 2019 13:14:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 720396B0281
	for <linux-mm@kvack.org>; Tue, 28 May 2019 13:14:21 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id d8so1431849lfa.21
        for <linux-mm@kvack.org>; Tue, 28 May 2019 10:14:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to;
        bh=WjL1kPJpFZ+/6P/J2gFeO1EXLoFczY/0XpAxesm/SAI=;
        b=R0S1udzYb++8srVnRa5dvYllFJrGGROhCPDJQNtMSvVWnvVxAJ/IdUnyBoG24cok+y
         GfssoVeQ6S0jju6psrRW4dx07rRW+0nCjPg2c/eqJTseFFN4WQO4Lri2kWrvA+ZJhFnY
         X0MWhH2TGsFCC0+fASNt2PY5dP/MNDRmP57Vx4P6Ja/1+hg+3E93zeAEERtqgOU+DG6W
         e8WAiN8zuovI8i6sCu87GEVFiBK4fGaq5N4qEPZ2YATNW/1n+qMH7wvZ3ZmUihJ5zbNz
         0sEKaCK0lKALbfOaLKgdJ1bzeAjAKhIip4Nc6SKkw1qpsu0XOfBP/KdF1wOyIZk079iJ
         4dhA==
X-Gm-Message-State: APjAAAVyF3tHkRPYmDBd3/JW7LDbXMFMmz+8yArmw6uwGay78NttTbJF
	TCCdQbZjr3UNdS7g2qCgMB3YeIz1PW+QqGk/AdK+BA+ku31KDsA/nH/D0zi4j7YNCuhtzbv2lxp
	Z1pJ5jKbyEaO60X0m26NxId9YVgEOBZsDbmEKcKIgp1bRP+hDMKWC8id/dqGEtOE/AA==
X-Received: by 2002:a2e:5852:: with SMTP id x18mr30747592ljd.81.1559063660888;
        Tue, 28 May 2019 10:14:20 -0700 (PDT)
X-Received: by 2002:a2e:5852:: with SMTP id x18mr30747562ljd.81.1559063660217;
        Tue, 28 May 2019 10:14:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559063660; cv=none;
        d=google.com; s=arc-20160816;
        b=hCk4ussNzbiOGfgFyVZKHqIwckDQvpWAldjXklA9/JP4Ka4p10UNGYgBc3CU3K7CDS
         4EYh2rMfJ56j8PhylINmVZAuCQHsYgcA/VHohsXnAAr9jLNMCs5XOpJNM0/O+owm0QfV
         0HfaSXz1ykNj8fkqWmA9Xhq7uP527ktO0mo3dcwpPk4CKVAVfhD9Y4us03FJHrrfjXHp
         eOQ28UyMFbiTFmLn7gOnzPLp7OWJa71ZAlLYUGDA7LBSkJuvQQOWMHpIwVU3DceUKqC2
         4MFGHAdxz9hNBTShCnr3wWOuibw6De4tAAbhWOfyZenBkkpWeBzp4Rqz+xP23LH+jEJl
         H/JA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=WjL1kPJpFZ+/6P/J2gFeO1EXLoFczY/0XpAxesm/SAI=;
        b=ojXX9LpO8BelS4anDev7rreK0UQ0hVJ6I9dIiCh8IeQ5CwqCtbKiyXCz+52A7CX/cU
         /KPIgLHZpC/zM2js3FDEuQxEw2n+tjGug4c3UAka6k+vVdud9dbuNScPrtBV+hE5xEeb
         OhWOPAAPavCt7yX5gu71xWWALzxS6xMtRJyBUgLXBF1foBz7xNJpdSdGqFBxdPZkE72Z
         /4i+gng++9QMQZxTjA7r3/0AeK322WwkG2MrQ924sXn1yqlfjny3Q/7oowiQYdleBfQO
         U2gUO4ZBLhifYpotBgLXkKaD69s4m6E7rgf+h3WJxCynX3I71UlX01tLXICyDp9oI2PP
         k2LQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=X2EOagEp;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l17sor3853453lfc.16.2019.05.28.10.14.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 10:14:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=X2EOagEp;
       spf=pass (google.com: domain of vdavydov.dev@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=vdavydov.dev@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to;
        bh=WjL1kPJpFZ+/6P/J2gFeO1EXLoFczY/0XpAxesm/SAI=;
        b=X2EOagEpclu4ci+J5hELZN56hZWa/YKEEJMK9pne6v5cmFWQgQ58z6hcuN4SKQZLrs
         2LYlVt5tiD/iE7WqzRZ8jHNm0MmyqhWQEq2iiBv+DbERpI0KtlpIuMTL9yxGXn0AATbh
         8S0dlssbwt0wAe9eMcKuq2YGU1jgdpZYeMbvwqLprQpHN3qxVNgQDU8vri2A537s8p//
         4WiaEtaZRVBk3HrrAySnKiZf7QfTCHiQPbl3Qy0m6tUmkxDUBAoSxoVUsBGbuUEW8WH2
         XoXsVF5Uid2iHAY8wQtjZ5v4ARPAKJRygdV96eXj2QnQS68LlFvJivE/aqEn0j6N9eNR
         yrbA==
X-Google-Smtp-Source: APXvYqzDZrteCE2LfMAWo8TQW16K+fLRlpq3FoRftMOd27u43NAPU34bi0T2PD4lughRbHjwkIeHpA==
X-Received: by 2002:ac2:510b:: with SMTP id q11mr4381015lfb.11.1559063659938;
        Tue, 28 May 2019 10:14:19 -0700 (PDT)
Received: from esperanza ([176.120.239.149])
        by smtp.gmail.com with ESMTPSA id d68sm3014105lfg.23.2019.05.28.10.14.19
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 May 2019 10:14:19 -0700 (PDT)
Date: Tue, 28 May 2019 20:14:16 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
To: Roman Gushchin <guro@fb.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>, Rik van Riel <riel@surriel.com>,
	Shakeel Butt <shakeelb@google.com>,
	Christoph Lameter <cl@linux.com>, cgroups@vger.kernel.org,
	Waiman Long <longman@redhat.com>
Subject: Re: [PATCH v5 1/7] mm: postpone kmem_cache memcg pointer
 initialization to memcg_link_cache()
Message-ID: <20190528171416.ujwr5rhbo7g4wfd5@esperanza>
References: <20190521200735.2603003-1-guro@fb.com>
 <20190521200735.2603003-2-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521200735.2603003-2-guro@fb.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 01:07:29PM -0700, Roman Gushchin wrote:
> Initialize kmem_cache->memcg_params.memcg pointer in
> memcg_link_cache() rather than in init_memcg_params().
> 
> Once kmem_cache will hold a reference to the memory cgroup,
> it will simplify the refcounting.
> 
> For non-root kmem_caches memcg_link_cache() is always called
> before the kmem_cache becomes visible to a user, so it's safe.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Reviewed-by: Shakeel Butt <shakeelb@google.com>

This one is a no-brainer.

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

Provided it's necessary for the rest of the series.

