Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D550C28D1E
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 11:14:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D18E2207E0
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 11:14:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D18E2207E0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5BFD36B026D; Thu,  6 Jun 2019 07:14:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5706A6B026F; Thu,  6 Jun 2019 07:14:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 460796B0270; Thu,  6 Jun 2019 07:14:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id EC14A6B026D
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 07:14:53 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d13so3269140edo.5
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 04:14:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=h8qEDdQVvgqhdDq9RUrIclI/RYacBNDWD7gszRkBp0o=;
        b=Qp27rKgQxNnhdJ++aQxj3WYkgm+btfYKo7+ca0qpoORjNGP0BuEpbYhqTVL4GbdgHF
         Lh4EUsrPPD0Ugv0RAP5XraWetXkws7b6DxM7uNKylHoter079FJMX+bWV/fLc8Kv3N4V
         +aXByv17HTaVS1uRs6Smp7pQOXiMAi1TYW3DWQS13LtPWVYZWDE9j9F/Da1hy81l+YeL
         2r9msjia3Z65xdsrM6lsq6npWrSfWU6QKpK/SXm4NmjFVbAvM/yxz2FvSYJ2za2+nvD/
         1QQAnO6LzNlIBI1YPAQ4ki5e6ioDADvIPDYm1HebVXbdaH10rrdodP5zvDvz6xXzloxJ
         souQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWz8l1nu0sJS8b3gKk2N1GYiezX2oYZ6HdU5rncByBnRt9mkxcb
	bjQjKLYn87J5rPr11zIPRWulvDEQQhAHFkPh5O5uk5q4U0p5FwALi9fj6L/ygKn1CyDUlYjt17u
	J3P0ZnnPiGxtjhrLab3XJCL7Nf8qbSnXllXvn0XT/WpN62MAOoN8MtqgkUM93tkA=
X-Received: by 2002:a17:907:384:: with SMTP id ss4mr23198833ejb.166.1559819693495;
        Thu, 06 Jun 2019 04:14:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/A0hc5aHEZ/NZWE749iQf4Ay1NQX/gN+U7T/+pgU5wW84THui4Cugt8HVXn58mEoGcJXQ
X-Received: by 2002:a17:907:384:: with SMTP id ss4mr23198767ejb.166.1559819692699;
        Thu, 06 Jun 2019 04:14:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559819692; cv=none;
        d=google.com; s=arc-20160816;
        b=mZ9WpH6Iejh9Bc67GDQa8/s/NCz5xwOXpBe96CCFbNdw8ZtBgbIRLs1+hBASbSax0q
         37YDh9j9uJKdSKsrikO7vn+o8VGIRF7Qm7GO4wTrCHi1W3iTH5Z79PFF3tTznw2CyBTW
         Y7HvxWQ/CfF0QU9KVepEZ/A/zVHetRkFgzWZeDc63s239/atxWKRnd6j6UGUQ/+mxGGX
         DA2HUfN2986ur+O5QrAroSeC8YXxQZxW+z2tlAFbw46H79r9sKMpYGvYM1gNN3igu2yZ
         Geh4GnSYEDJDvxxFg83SX2/Ns7TCL65sbx8i53Tc81LUl/srK78wXIBsrPsKdsqTOgp9
         4h/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=h8qEDdQVvgqhdDq9RUrIclI/RYacBNDWD7gszRkBp0o=;
        b=hcPwJIZX3hrhwlOzVBHTH2jIcWkD5/BGTM//vGgBqAiD0OzhfcwosZrJFtpdxhD4ze
         +Jmez9+fWVLlhmtmnzsXXITt9T7SBfCbFfwJ3aV/eDJl2lu4TURH/tbuU42KeZPDusXz
         CDtaI8zQHs6aa2rIGYYTCVkvaJA5BvPyhDvDGA5ZFExoCqr1x7APYAUnjVodn6KCWpHU
         w29PwXklHtiYKgyjsdCcpHqc7IBzZE4iYiv0GM/d2iSoripGxehUtLobjyv1NKS3pGS1
         MMY9BWjD8NbTEWTE0ERoaqFZW6LiTqfQt1iHfhp9qlVDRtIAM+GLK5ItRvtlLxoEXwOy
         9u/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hh12si1260785ejb.189.2019.06.06.04.14.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 04:14:52 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 0F722AE78;
	Thu,  6 Jun 2019 11:14:52 +0000 (UTC)
Date: Thu, 6 Jun 2019 13:14:46 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com
Subject: Re: [PATCH] mm: memcontrol: dump memory.stat during cgroup OOM
Message-ID: <20190606111446.GA15779@dhcp22.suse.cz>
References: <20190604210509.9744-1-hannes@cmpxchg.org>
 <20190605120837.GE15685@dhcp22.suse.cz>
 <20190605161133.GA12453@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190605161133.GA12453@cmpxchg.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 05-06-19 12:11:33, Johannes Weiner wrote:
> On Wed, Jun 05, 2019 at 02:08:37PM +0200, Michal Hocko wrote:
[...]
> > I am not entirely happy with that many lines in the oom report though. I
> > do see that you are trying to reduce code duplication which is fine but
> > would it be possible to squeeze all of these counters on a single line?
> > The same way we do for the global OOM report?
> 
> TBH I really hate those in the global reports because I always
> struggle to find what I'm looking for. And smoking guns don't stand
> out visually either. I'd rather have newlines there as well.

This is obviously a matter of taste. I do not remember anybody
complaining about the data density for the global oom reports.
The amount of data is essentially the same so so there is no real
technical argument one way or another.

That being said, I still do not like the per line stats but I do not
think this is a strong enough matter to argue about. The missing
counters are interesting for oom reports analysis so the patch is
an improvement. If you really do see it important then I will not stand
in the way. One way or another feel free to add

Acked-by: Michal Hocko <mhocko@suse.com>
 
> > > +	seq_buf_init(&s, kvmalloc(PAGE_SIZE, GFP_KERNEL), PAGE_SIZE);
> > 
> > What is the reason to use kvmalloc here? It doesn't make much sense to
> > me to use it for the page size allocation TBH.
> 
> Oh, good spot. I first did something similar to seq_file.c with an
> auto-resizing buffer in case we print too much data. Then decided
> that's silly since everything that will print into the buffer is right
> there, and it's obvious that it'll fit, so I did the fixed allocation
> and the WARN_ON instead.

I've had a suspicion something like that happened. In any case using
kvmalloc wouldn't be a bug. It would just be weird because we do not
even fall back to vmalloc for this size IIRC.
> 
> How about a simple kmalloc?. I know it's a page sized buffer, but the
> gfp interface seems a bit too low-level and has weird kinks that
> kmalloc nicely abstracts into a sane memory allocation interface, with
> kmemleak support and so forth...

Yeah, using kmalloc is fine.

> Thanks for your review.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 0907a96ceddf..b0e0e840705d 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1371,7 +1371,7 @@ static char *memory_stat_format(struct mem_cgroup *memcg)
>  	struct seq_buf s;
>  	int i;
>  
> -	seq_buf_init(&s, kvmalloc(PAGE_SIZE, GFP_KERNEL), PAGE_SIZE);
> +	seq_buf_init(&s, kmalloc(PAGE_SIZE, GFP_KERNEL), PAGE_SIZE);
>  	if (!s.buffer)
>  		return NULL;
>  
> @@ -1533,7 +1533,7 @@ void mem_cgroup_print_oom_meminfo(struct mem_cgroup *memcg)
>  	if (!buf)
>  		return;
>  	pr_info("%s", buf);
> -	kvfree(buf);
> +	kfree(buf);
>  }
>  
>  /*
> @@ -5775,7 +5775,7 @@ static int memory_stat_show(struct seq_file *m, void *v)
>  	if (!buf)
>  		return -ENOMEM;
>  	seq_puts(m, buf);
> -	kvfree(buf);
> +	kfree(buf);
>  	return 0;
>  }
>  

-- 
Michal Hocko
SUSE Labs

