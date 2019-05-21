Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AB4C2C04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 15:31:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78D0A2173C
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 15:31:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78D0A2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 053E16B0007; Tue, 21 May 2019 11:31:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0043D6B0008; Tue, 21 May 2019 11:31:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E0E106B000A; Tue, 21 May 2019 11:31:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id BE86D6B0007
	for <linux-mm@kvack.org>; Tue, 21 May 2019 11:31:28 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id g19so17595479qtb.18
        for <linux-mm@kvack.org>; Tue, 21 May 2019 08:31:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=spp5/Rx11m4+j8QI7L7v35SEP4GNZRUUzlUP79Q8L8Q=;
        b=aJ4jgKpqsU82iue1ejlfIRS7/jl4O9gDC3Iq35DccPeaV2pt32jo2zpqyWN3Q8tTcR
         QfpAZsao3TEgOspjtsUB00GMvUuZVBZfJYmx/KDo8421LAJRjdrY7o/XGfiggx8c+feF
         HXxLrcCaAQgbJSJJP2zsdKLI1IGlkE4CfR+Djg1VAKRzsSWzPlU5mjKnfxm6fIQ5A2YO
         4AF1V+S5EsP+CMqSDfqG2713TQQxGjaQDonu7DincUCUKAmnFxYAgnBzWC9lGaZEu9zJ
         mlBMJTFNh5Xdr8BS/AwZ3NSISjex1+ibWpkjT+JAAN/UNLdxM7cykh3g3LeqnAktHLFy
         xXZg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWsFWy5TcHR1GPdvdVheN8hH99Xsb9vBlfifutC68k6VpnXFBhY
	X+FnsxnlBnMkXoeVo+q3fgZ0kOL+IgC9hrUI9AHRKv5NaDOYgytFFY0G9vx/sN+U0IDD7wIu7N/
	FGeHYb3TJ+BcaLlbqPxpLiDMEYJtV4FLVilyAZdE6fzJ8H/4wNFcjl8wPGZvz2kO5WQ==
X-Received: by 2002:a0c:b39e:: with SMTP id t30mr22360959qve.212.1558452688581;
        Tue, 21 May 2019 08:31:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxqz+Qk6Ahw3rF64FHs54SXhkFowJ2xnqkD4f/dMqGWgdEc7tCPfpwz50T/UcglcDgScneX
X-Received: by 2002:a0c:b39e:: with SMTP id t30mr22360894qve.212.1558452687994;
        Tue, 21 May 2019 08:31:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558452687; cv=none;
        d=google.com; s=arc-20160816;
        b=qMwNkWPMGKr8a7UrpOZuxvXrovKZ/TYH8d0ULGlxE0TPp51FRJENKCOhomvmGo3HUN
         diFLAajjKhw4JzZns5Y+CUeOlZlGU8dXsxEYbxPkBoXB0PKuDvhuBn/yv7lx0fSMqtGu
         UmOLDPpjxyZ8eEI5nV+AT8o2MdDj+pUuKjZM8zUJQsJ3OMHUyy651+04JOPYoIhZQxVE
         KL+yRT36CctWOBizCw3PDVlj9Sgz0jCihnoEASeinxm+N8A2HNh2CcjFVCmsmxjH0n9E
         pgRSt3hVY+dJQbzDNqLPC8np4RRSjuyh1TRfHB4AdxWWgyIxQ4PKYyyhnacLkiN6ROsW
         uSRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=spp5/Rx11m4+j8QI7L7v35SEP4GNZRUUzlUP79Q8L8Q=;
        b=wt0iggtki7MehSzZjZ5QxK5f6K2TubiI+tWfGXi3FeP1mwxOd2Z2axYaPPGpbpOY1f
         //NaTPmWbBqOYFk5OGNETFZHAi+XJ19o0jN6DtVIMC108MmwxqKRXgYTtV6r8W6u3T8S
         L1GNE7dtp1KsRGTLHXM6jL85cZ5wC1iOI+ejkJpi9DzQh4oM1LTKO+xikeiMSD0qRmZF
         6YkYGr1HmMBZcVWvOFIRTDrJJKa6znK9M5r5cC28RRzKDJD3xK66yqIfprrEu3jlLtk+
         A6dkaifXt6Heb1U/n4w40psdFSZTPcGT/c2YOt0EX/k4Kn6h7thgYoWQ2nwX2jJ9P0C6
         o4Kg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n94si2706266qte.210.2019.05.21.08.31.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 08:31:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleg@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=oleg@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9E2FC356F2;
	Tue, 21 May 2019 15:31:19 +0000 (UTC)
Received: from dhcp-27-174.brq.redhat.com (unknown [10.43.17.159])
	by smtp.corp.redhat.com (Postfix) with SMTP id D8BD959154;
	Tue, 21 May 2019 15:31:14 +0000 (UTC)
Received: by dhcp-27-174.brq.redhat.com (nbSMTP-1.00) for uid 1000
	oleg@redhat.com; Tue, 21 May 2019 17:31:18 +0200 (CEST)
Date: Tue, 21 May 2019 17:31:13 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 5/7] mm: introduce external memory hinting API
Message-ID: <20190521153113.GA2235@redhat.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-6-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190520035254.57579-6-minchan@kernel.org>
User-Agent: Mutt/1.5.24 (2015-08-30)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Tue, 21 May 2019 15:31:27 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 05/20, Minchan Kim wrote:
>
> +	rcu_read_lock();
> +	tsk = pid_task(pid, PIDTYPE_PID);
> +	if (!tsk) {
> +		rcu_read_unlock();
> +		goto err;
> +	}
> +	get_task_struct(tsk);
> +	rcu_read_unlock();
> +	mm = mm_access(tsk, PTRACE_MODE_ATTACH_REALCREDS);
> +	if (!mm || IS_ERR(mm)) {
> +		ret = IS_ERR(mm) ? PTR_ERR(mm) : -ESRCH;
> +		if (ret == -EACCES)
> +			ret = -EPERM;
> +		goto err;
> +	}
> +	ret = madvise_core(tsk, start, len_in, behavior);

IIUC, madvise_core(tsk) plays with tsk->mm->mmap_sem. But this tsk can exit and
nullify its ->mm right after mm_access() succeeds.

another problem is that pid_task(pid) can return a zombie leader, in this case
mm_access() will fail while it shouldn't.

Oleg.

