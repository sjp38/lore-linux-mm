Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0342C43218
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 18:58:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B709020859
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 18:58:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B709020859
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3D85C6B026A; Mon, 10 Jun 2019 14:58:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 388FC6B026B; Mon, 10 Jun 2019 14:58:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 279246B026C; Mon, 10 Jun 2019 14:58:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id CCA056B026A
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 14:58:07 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d27so16700412eda.9
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 11:58:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=RPZGbefbXyaa0DALfZtnqVpFSQmajkOXzntvnw+q3Os=;
        b=AlSPpROQTMEYD2hbNE8JOL+sECXfUBXgNHj4r+ol/dKzdiZ8NlpJ3RktaeakKQu+RR
         F953fwqqa424Ysyj7ZVnkluTO7YS6YTb+dLQFhTEyqhy87tTwPOWLCXtZjbsS2VqwwTz
         9ioN0ihQxn0rZJhyp812FYSs1FeYeensC7XLqJf0hJTNUysEYQuuVaPxW/j8dy8sk9FA
         AMCRNUma5GsQ7UWO6X+wY00EA8zztp6StB9oT8VB1q/ATOBEjmxzxMkyooiCZnxHVKJz
         jZx8TtOqGIvWEZRb5nIJfsotdTiFPzSXVYXwOGzFFFxPyXo1uKKFMvo1PWNR9hIJ1ucc
         dr0Q==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXJd6bjs113QzRc+MrVeoFmpQ+S8TMKMpEi9+9NcTajgjDjwRwu
	0knw0+8WRaaKiiYFCBmHn7RA6zgDEm3SNqH7cGwxphFAUkr4LEIKFd7wQSiBABPOvurcW5o8Ely
	Cf2CChrKShMVolNE3qLlSBsuYY9Jc3PdlpfC9f6Xpe47uJQRsITcW/2Drc3qtWcQ=
X-Received: by 2002:a50:a784:: with SMTP id i4mr6634922edc.3.1560193087435;
        Mon, 10 Jun 2019 11:58:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzbV+D5zopUBac2O3/ozfTqBD9ia2rfk7iWLWIEUEuVk9dBD4zk1cYMHQFTENyzRhYYmdIx
X-Received: by 2002:a50:a784:: with SMTP id i4mr6634844edc.3.1560193086465;
        Mon, 10 Jun 2019 11:58:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560193086; cv=none;
        d=google.com; s=arc-20160816;
        b=e2Ikk41B9rLCF8id3WDLXANbqM/+GZF2c/efcxaDw6/ZSpBjBBwPhjkR+D8aG34QsK
         r6rp0X1bPHSo9CrKNYVd98nfnY5sxM/b2yhIPXJFd19AEFzmtkQzh/6EeBJ5HI/bANYx
         Gk4SLmbG2L9K8bgkKn0Vw9XoYIsSsLFH1M8YCbhLwOiN6HW+Nje5uQwEvg3Iu0es/UD5
         d6ZdfYT2Di0EOL/c0vIhXOBElkd9EwU1ibxlsvLc4q0M9z2uuKocHqeJIE/seDhyHhf6
         DeAnD31N7DPQDEDGmgY0K+Hm/+hy7pqfyohIpj/KQ7fXCFe07f7CTxRJf+mwcwlNOzwU
         r0rw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=RPZGbefbXyaa0DALfZtnqVpFSQmajkOXzntvnw+q3Os=;
        b=QtIIoDHXXpg3h9Bhr/wDTOAgXdgqcFUAIT46F2NSx7zpsSLyqe3uwQX1GliBBT5b8V
         oO+N+HuP2PW2yCQmzxNMe2uTPyflpxvIbF+u23kJEw6rL9qeBkCJbSDTwxqZlpCj0H9G
         HeN/XHJaOUt87dkXgfijBV79xL8yDxyVeKAD+qN08k4KweUV8Sek4gdFcjq+LAQPj3/R
         4bbE+HlcRPbnmSdfT4h/jVc/GtU3tP/+9FJ5rPZmviBX/PNugYXjBPFgHInHzrO0qvW+
         oHvqDQ3+eZSUB6qX0VdALsCu/ovvJhzpYKm07g4ID36ltgQIzvevPZmoY9W44RJfmJLX
         1kZw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w4si8070463edd.42.2019.06.10.11.58.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Jun 2019 11:58:06 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 7B8E2ABC7;
	Mon, 10 Jun 2019 18:58:05 +0000 (UTC)
Date: Mon, 10 Jun 2019 20:58:04 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Cyrill Gorcunov <gorcunov@gmail.com>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH 2/5] proc: use down_read_killable for
 /proc/pid/smaps_rollup
Message-ID: <20190610185804.GB2388@dhcp22.suse.cz>
References: <155790967258.1319.11531787078240675602.stgit@buzz>
 <155790967469.1319.14744588086607025680.stgit@buzz>
 <20190517124555.GB1825@dhcp22.suse.cz>
 <bda80d9c-7594-94c9-db2c-37b8bc3b58c8@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bda80d9c-7594-94c9-db2c-37b8bc3b58c8@yandex-team.ru>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun 09-06-19 12:07:36, Konstantin Khlebnikov wrote:
[...]
> > > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> > > index 2bf210229daf..781879a91e3b 100644
> > > --- a/fs/proc/task_mmu.c
> > > +++ b/fs/proc/task_mmu.c
> > > @@ -832,7 +832,10 @@ static int show_smaps_rollup(struct seq_file *m, void *v)
> > >   	memset(&mss, 0, sizeof(mss));
> > > -	down_read(&mm->mmap_sem);
> > > +	ret = down_read_killable(&mm->mmap_sem);
> > > +	if (ret)
> > > +		goto out_put_mm;
> > 
> > Why not ret = -EINTR. The seq_file code seems to be handling all errors
> > AFAICS.
> > 
> 
> I've missed your comment. Sorry.
> 
> down_read_killable returns 0 for success and exactly -EINTR for failure.

You are right of course. I must have misread the code at the time. Sorry
about that.
-- 
Michal Hocko
SUSE Labs

