Return-Path: <SRS0=K2XS=UI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08968C468BD
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 12:52:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6F3D20840
	for <linux-mm@archiver.kernel.org>; Sun,  9 Jun 2019 12:52:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Fb0/d1TP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6F3D20840
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E0726B0266; Sun,  9 Jun 2019 08:52:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 293266B0269; Sun,  9 Jun 2019 08:52:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 17F9C6B026A; Sun,  9 Jun 2019 08:52:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id D41C76B0266
	for <linux-mm@kvack.org>; Sun,  9 Jun 2019 08:52:27 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id t2so151126plo.10
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 05:52:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=nVSIzUxvD1RqXxPMm3DPulW0LemDfOUCgD8NaU75XxU=;
        b=lhXjKJndTQB5LzDPMftD1apoSiVZRg4iwwv66Kjy7n/hIPhLKI38bGDJyR95mGAlTO
         ZuWaQwJk0yVmCVVvV4ZCVD7i0WhDQRN97hlAn1WTEgxKrKa17ory7W6BXGFq4XSAxeun
         nqU9gWaQ3Qp7MT3abAYE/nhIzhZbM5iQzefzXFX0pRRRi/vBk26kQ8zF/jDlsxp2fN/R
         9FPQ/6NUkV3Zwa7u89O8+U51exqjl2q1AA6hyIaLLfUJl01Spa2+xhetkS6D6cQ5j6Nj
         KfZcgyyI+5VAnuIgX1/6k8tLEfNZS+nQVxz6sXiiLiL4aHya4uw7NclL24ot9zARTZDi
         vErA==
X-Gm-Message-State: APjAAAXEbjIrNuVZW6suZIiU3FFGbkIZ7Lw7gv5nlkfZYQP9iPps2Xb9
	IbHX7gXkHQZPDhQbJegzQ0ttoAenHaO6VE+HaNg3rCS0rmVXKWhhKgAE0Ncl7IZY9IfVFvUG8vJ
	g2een13UACgeCv0CjVCCL9MWAwyYR8rohzgueA9eXl9OpzSP0xHE+plkg+0zMMuFftA==
X-Received: by 2002:a17:90a:a404:: with SMTP id y4mr4790952pjp.58.1560084747509;
        Sun, 09 Jun 2019 05:52:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwEhcC3x0WjBHNBEhPe5TWEuATin+6BYr1+gFmE02IJa8Ppq4Aq8bqFcENKFWv0WwFVXxNL
X-Received: by 2002:a17:90a:a404:: with SMTP id y4mr4790916pjp.58.1560084746763;
        Sun, 09 Jun 2019 05:52:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560084746; cv=none;
        d=google.com; s=arc-20160816;
        b=kWwhZedPF1znfVxAm6cMZdYYtrO7aIwucEEmN7CH1OuWUn05oiTp2joPzWZ+pRGsHO
         7dd/4aqDz03OVNVrKINx0YkA27Hl5sfuWxtnc6WarLsWlneO22FTDhNTcRO/LdFjuN1Y
         2S/Oj4yK/B6SYqTemj88X09wnLwExnDN6qLAKyXwzlqeOM2QO2LddPR664V2vNfTIzx5
         CdwcBtjhAIQ/IJFKFC5C7X5iD4nQ7rg1QoeX/x8ZwxaofJSCphsocyZVzn+Tfx6giBeC
         UFjWweA/b1q7uoYTy98ag+SQE+zqsPUY3rPJ5xBjMUj75/CXCXEPRtHe4sXPJXttQ7tM
         Z+AQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:date:cc:to:from:subject:message-id:dkim-signature;
        bh=nVSIzUxvD1RqXxPMm3DPulW0LemDfOUCgD8NaU75XxU=;
        b=cgw2P9t0Try9CTWayhUhn9jr4P943eV5RDnlhttdN3yjNkQzzeg4TsQ2OsKeZ8YA2V
         d08ksfz/nNxq4WIxzxGzUED5AOfwh5Ns8NoB218Hr16jmyUMQ5JkYwrxU6Sdm7hfo3h0
         Fxdtm7k+PHnRLty3rm/YDPVmGMj4vMJUXUv9dmTkYspq8AvvatqHEHUHv6wzQTyPgWOp
         xJE6LriZHs3W3sykeP0TKI6MuMlW1P1mmFF9CfUP+B0CDctZhtDntte95Qdk5p5s4WLN
         Yq28yOKDgodtbzYqvRArzWROLxcowuTJU2rkW0UrvCIH0mruZ6uYmypYLxCPDroXsV3e
         DGWw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="Fb0/d1TP";
       spf=pass (google.com: domain of jlayton@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jlayton@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 74si6958437pga.291.2019.06.09.05.52.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Jun 2019 05:52:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of jlayton@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b="Fb0/d1TP";
       spf=pass (google.com: domain of jlayton@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=jlayton@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from vulcan (047-135-017-034.res.spectrum.com [47.135.17.34])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0543520644;
	Sun,  9 Jun 2019 12:52:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1560084746;
	bh=Jp7kr5DJqAmzvLis1iU/kH5HcxTG0RVYIAF+Rpsd6qw=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=Fb0/d1TPF/IYByoPE3/h+/h5Nml1u3pYuNxucYdi3Pa7jHKQWf5ff6iC0gdj4ClyR
	 1+mbW/akKAyRuHM4gDoX0wazMyWkrtb2zYBHWqsFXVnAUf4YOmYBHdBPzbKX96kB2U
	 oP2KgGTk8o+FmZtKSAhFyGm8i96fdLia2YEod7hM=
Message-ID: <dbc19013b6f2a654541980edd1a00b72331645f9.camel@kernel.org>
Subject: Re: [PATCH RFC 01/10] fs/locks: Add trace_leases_conflict
From: Jeff Layton <jlayton@kernel.org>
To: ira.weiny@intel.com, Dan Williams <dan.j.williams@intel.com>, Jan Kara
 <jack@suse.cz>, Theodore Ts'o <tytso@mit.edu>, Dave Chinner
 <david@fromorbit.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-xfs@vger.kernel.org, Andrew
	Morton <akpm@linux-foundation.org>, John Hubbard <jhubbard@nvidia.com>, 
	=?ISO-8859-1?Q?J=E9r=F4me?= Glisse
	 <jglisse@redhat.com>, linux-fsdevel@vger.kernel.org, 
	linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, 
	linux-ext4@vger.kernel.org, linux-mm@kvack.org
Date: Sun, 09 Jun 2019 08:52:20 -0400
In-Reply-To: <20190606014544.8339-2-ira.weiny@intel.com>
References: <20190606014544.8339-1-ira.weiny@intel.com>
	 <20190606014544.8339-2-ira.weiny@intel.com>
Content-Type: text/plain; charset="UTF-8"
User-Agent: Evolution 3.32.2 (3.32.2-1.fc30) 
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-06-05 at 18:45 -0700, ira.weiny@intel.com wrote:
> From: Ira Weiny <ira.weiny@intel.com>
> 
> Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> ---
>  fs/locks.c                      | 20 ++++++++++++++-----
>  include/trace/events/filelock.h | 35 +++++++++++++++++++++++++++++++++
>  2 files changed, 50 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/locks.c b/fs/locks.c
> index ec1e4a5df629..0cc2b9f30e22 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -1534,11 +1534,21 @@ static void time_out_leases(struct inode *inode, struct list_head *dispose)
>  
>  static bool leases_conflict(struct file_lock *lease, struct file_lock *breaker)
>  {
> -	if ((breaker->fl_flags & FL_LAYOUT) != (lease->fl_flags & FL_LAYOUT))
> -		return false;
> -	if ((breaker->fl_flags & FL_DELEG) && (lease->fl_flags & FL_LEASE))
> -		return false;
> -	return locks_conflict(breaker, lease);
> +	bool rc;
> +
> +	if ((breaker->fl_flags & FL_LAYOUT) != (lease->fl_flags & FL_LAYOUT)) {
> +		rc = false;
> +		goto trace;
> +	}
> +	if ((breaker->fl_flags & FL_DELEG) && (lease->fl_flags & FL_LEASE)) {
> +		rc = false;
> +		goto trace;
> +	}
> +
> +	rc = locks_conflict(breaker, lease);
> +trace:
> +	trace_leases_conflict(rc, lease, breaker);
> +	return rc;
>  }
>  
>  static bool
> diff --git a/include/trace/events/filelock.h b/include/trace/events/filelock.h
> index fad7befa612d..4b735923f2ff 100644
> --- a/include/trace/events/filelock.h
> +++ b/include/trace/events/filelock.h
> @@ -203,6 +203,41 @@ TRACE_EVENT(generic_add_lease,
>  		show_fl_type(__entry->fl_type))
>  );
>  
> +TRACE_EVENT(leases_conflict,
> +	TP_PROTO(bool conflict, struct file_lock *lease, struct file_lock *breaker),
> +
> +	TP_ARGS(conflict, lease, breaker),
> +
> +	TP_STRUCT__entry(
> +		__field(void *, lease)
> +		__field(void *, breaker)
> +		__field(unsigned int, l_fl_flags)
> +		__field(unsigned int, b_fl_flags)
> +		__field(unsigned char, l_fl_type)
> +		__field(unsigned char, b_fl_type)
> +		__field(bool, conflict)
> +	),
> +
> +	TP_fast_assign(
> +		__entry->lease = lease;
> +		__entry->l_fl_flags = lease->fl_flags;
> +		__entry->l_fl_type = lease->fl_type;
> +		__entry->breaker = breaker;
> +		__entry->b_fl_flags = breaker->fl_flags;
> +		__entry->b_fl_type = breaker->fl_type;
> +		__entry->conflict = conflict;
> +	),
> +
> +	TP_printk("conflict %d: lease=0x%p fl_flags=%s fl_type=%s; breaker=0x%p fl_flags=%s fl_type=%s",
> +		__entry->conflict,
> +		__entry->lease,
> +		show_fl_flags(__entry->l_fl_flags),
> +		show_fl_type(__entry->l_fl_type),
> +		__entry->breaker,
> +		show_fl_flags(__entry->b_fl_flags),
> +		show_fl_type(__entry->b_fl_type))
> +);
> +
>  #endif /* _TRACE_FILELOCK_H */
>  
>  /* This part must be outside protection */

This looks useful. I'll plan to merge this one for v5.3 unless there
are objections.

Reviewed-by: Jeff Layton <jlayton@kernel.org>

