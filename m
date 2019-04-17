Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B171AC282DD
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 13:41:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D84E204EC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 13:41:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D84E204EC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 16BF66B0005; Wed, 17 Apr 2019 09:41:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0F3736B0006; Wed, 17 Apr 2019 09:41:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F24AE6B0007; Wed, 17 Apr 2019 09:41:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A06BE6B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 09:41:55 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n25so2857366edd.5
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 06:41:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=jzICcgedi+s9LIZxaX5EHYwDuMiVUohGNkzjSLI0MOw=;
        b=qwwj+ex8JVVbxxhGyz4lzILHFMp1ivmWVC3bgWWd7yZkEVXPHzTg5w65U6lI/OHOnS
         3zrvY6/AlxVYi7qeZcxuFrc/L9ssZHIm0cDBsOVP0uPPUf1IsmPZ+hNXHytuYGxXIyyO
         GEzyav+vhpJy7xrbTgIngrlE+WvWJ8JqOAA6Mt+QM7UQDyIhMTYRaQV86Xf8CXW+EEzU
         p/4ss0aKwjfC3c0gH218cJclIkbxFkgQiT5y+Yz6wEtGFMWErgFOaLhe9uazKR9fCYJf
         WRWkZVfrVAy9lmQpMpVubkmym0lCVfpk9bGePWvKLm1fr3i7byJkLOCo5jqZkz315Yk8
         KHfA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAV6K+Xko68+sldwD53peOZtdblfM7FCsBu5nMdP+2CCe1+yr5mC
	v1gZdspGyZWe0BhuYD2UnEsDfCTWuJOVAHqZ7ugC8DYsak/mwMXyzZ7OMmYxkP53OJoXV0N98Nv
	4cz4ne6fBqZ1o6ynyRqFu/2m7b8t4ZahJV6+/OW/MR2a9tZicYjHjatVWTnbI5G0=
X-Received: by 2002:a50:8908:: with SMTP id e8mr17128605ede.205.1555508515210;
        Wed, 17 Apr 2019 06:41:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwzE1V/gCwgH/FvEwOygNj3Up/Ox/ThxfF/LJ1KIW39DlHD5mHL8z22WdpEGQ3oOOdgy3BP
X-Received: by 2002:a50:8908:: with SMTP id e8mr17128559ede.205.1555508514393;
        Wed, 17 Apr 2019 06:41:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555508514; cv=none;
        d=google.com; s=arc-20160816;
        b=033bYTFjdFZ59Hzl0PgjbZ+uPPypihp/WFnLZuYDJnY9RhBjQgnELQWA/FRmlJJ6Ju
         w/7BUYDItu87z+Aanf4qOdPuxX2ZO6qVXKAsWoWs1QnvHQ2Nw4QAhRSrVc2qM7/UpA5R
         bGl5HT8ltPJ+0AQdLpLLat6iZL2wJTjrGP+zgWu685vOY+bI18l2PNKrMHiebEH1qQzL
         OEo5UMl9eWQ7nOfz13oGWO4xNkNwKq084zwN48MbxMtMmao0brqUetK5OzpekdFWdywj
         6ffalwUXBezB88fIVdEkIQFt/t59sC6P/e2MOJN9knNKFySKIAgEfn0ut3ycluJj+Cqd
         Rrng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=jzICcgedi+s9LIZxaX5EHYwDuMiVUohGNkzjSLI0MOw=;
        b=LaJnrGUHJdh0Df+iDYD/6WELGmAAmD2vxyNwQhz4cGNWzQ+5XUDZGVNekbuU3kpsjE
         xOpSK+UjK26qJ2KlbYegYzKYBUN9w3aBzVQ2A5FihfJSCUZnJacOd7fNSyj7xfDxOdzN
         RbY4/0tjU7K9rnwAv26laYEDVgPbKiVABnudMjowc7xWpA6Ka2VhG9CbsZvo7TgOIObw
         2Bvg4l27XJw1l3rGkGCKIezxQb04ePdy41yTH+rnJTS+fgWuFcqEp4kjUwvsAnfkNQF9
         pjbhEiZghVNDs5FUyqepz77CFU1aEbngeUobqyxQexzDTlwcsz4EAZ+20dntiDFb/OkO
         yF2w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gu5si2876913ejb.282.2019.04.17.06.41.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 06:41:54 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 8A131B175;
	Wed, 17 Apr 2019 13:41:53 +0000 (UTC)
Date: Wed, 17 Apr 2019 15:41:52 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Michal =?iso-8859-1?Q?Koutn=FD?= <mkoutny@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Mateusz Guzik <mguzik@redhat.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Geert Uytterhoeven <geert+renesas@glider.be>,
	Arun KS <arunks@codeaurora.org>,
	Bartosz Golaszewski <brgl@bgdev.pl>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: get_cmdline use arg_lock instead of mmap_sem
Message-ID: <20190417134152.GM5878@dhcp22.suse.cz>
References: <20190417120347.15397-1-mkoutny@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190417120347.15397-1-mkoutny@suse.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 17-04-19 14:03:47, Michal Koutny wrote:
> The commit a3b609ef9f8b ("proc read mm's {arg,env}_{start,end} with mmap
> semaphore taken.") added synchronization of reading argument/environment
> boundaries under mmap_sem. Later commit 88aa7cc688d4 ("mm: introduce
> arg_lock to protect arg_start|end and env_start|end in mm_struct")
> avoided the coarse use of mmap_sem in similar situations.
> 
> get_cmdline can also use arg_lock instead of mmap_sem when it reads the
> boundaries.

Don't we need to use the lock in prctl_set_mm as well then?

> Signed-off-by: Michal Koutný <mkoutny@suse.com>
> ---
>  mm/util.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/util.c b/mm/util.c
> index d559bde497a9..568575cceefc 100644
> --- a/mm/util.c
> +++ b/mm/util.c
> @@ -758,12 +758,12 @@ int get_cmdline(struct task_struct *task, char *buffer, int buflen)
>  	if (!mm->arg_end)
>  		goto out_mm;	/* Shh! No looking before we're done */
>  
> -	down_read(&mm->mmap_sem);
> +	spin_lock(&mm->arg_lock);
>  	arg_start = mm->arg_start;
>  	arg_end = mm->arg_end;
>  	env_start = mm->env_start;
>  	env_end = mm->env_end;
> -	up_read(&mm->mmap_sem);
> +	spin_unlock(&mm->arg_lock);
>  
>  	len = arg_end - arg_start;
>  
> -- 
> 2.16.4

-- 
Michal Hocko
SUSE Labs

