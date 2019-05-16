Return-Path: <SRS0=l6tt=TQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D866C04E84
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 14:43:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BFB5020815
	for <linux-mm@archiver.kernel.org>; Thu, 16 May 2019 14:43:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BFB5020815
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B4D06B000A; Thu, 16 May 2019 10:43:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3633E6B000C; Thu, 16 May 2019 10:43:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 22D3D6B000D; Thu, 16 May 2019 10:43:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id CD6CD6B000A
	for <linux-mm@kvack.org>; Thu, 16 May 2019 10:43:27 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id b85so777003wme.3
        for <linux-mm@kvack.org>; Thu, 16 May 2019 07:43:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Cj+rXNfNlUN3r4Yp7FC3w8W2jv87lre7M4pXy1RJygg=;
        b=RWcglj1XZivKGPCK+025CXFcMfCEpYeMXXiNx1F9AAvRsFeOE6PatK7CKNU0ijadOZ
         yRrwBtU8T2L3O9tGiDPEIsSh/QAnOIOwJwwIgl5+Fspy5yTUeaMFmgAAazqLe8cEz8gX
         RQhMKSUdCWh4pQ2i5qdkPwMUyyPLk9q3xjWSu68gYKY0vw4o1lBeoWFJE+B5VafrVxxg
         VqsuPAaYEqBoF9N+u44PN0PV/K+BtdZNxC+iBEKqGeFTECHyPsQTkxuddIHEiA1TBjuu
         Gef5Q+NUJ8+hTh2J1aovNjjC703xS4COjqM/Qw9J8JWHHXPVaxluMR+rQRchYVvCf5/l
         G5cQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAV22C4rPYQCBla/fBimZ0L9SnLfJ9UxKrlkzxrE4aqsvKc9Nf7X
	aYin0YWSG2ljgcmM+vymseblbFFI0no69SJaUr6FTQmLqm4lgDWgYktXRTyzGRVc1uCjC5ma8i7
	cshHazxClnbPetSb12ISEWgxb22MV92sWCR73aZyoJHROXBPI+cV5mn4PrcAbNl+VKA==
X-Received: by 2002:adf:e711:: with SMTP id c17mr8937636wrm.227.1558017807415;
        Thu, 16 May 2019 07:43:27 -0700 (PDT)
X-Received: by 2002:adf:e711:: with SMTP id c17mr8937573wrm.227.1558017806410;
        Thu, 16 May 2019 07:43:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558017806; cv=none;
        d=google.com; s=arc-20160816;
        b=YoMg3O3imYSAVqw/PtuNEjZjsV6SmdshqD+jUSAl/HjsY5Zp4p7TY7ccuZegTaGNwu
         637anze7b5nUm4SNvmKohf3dY5T/EwSQEcqRwCGAYo9ZHQiJqYM4TgyTvSKdp3q0F2DO
         fE9jFDzcDizkrG4zkamnwp8cReJNY/rP0xxQbjgPUwOP8OS4nz4fgq7/syR1x3a0HCTq
         J4ufU5EokCKvxKUJmkZAn5GRODIBJnhUPrH7aqw9GFsEuPF8PifTuHziZUPKKsaFYx5B
         urteRXOyWzLMbGOZV1Qz35pmIn5y8/49zY7Mmr+g2bxffUtJX0cXSYp8Pj7YgwhcGN28
         hG9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Cj+rXNfNlUN3r4Yp7FC3w8W2jv87lre7M4pXy1RJygg=;
        b=SVVaiHIawLinRcmeeDQV0CF2wkkNp8pecrjPUtIt0/JA7voSbu/1uPpA3waw3tYCBI
         1IqNxCGVClkqIS4ksfjQhWZCCKqLGCCb2PjOcOI/gSiqywI0DwsJgNPLsv/LTsmK3pl0
         qccbC/pOt5OTjCw/zTvzNjAkJFJnDbI1GWIhUQh7Z/w1a3Nocsq0Nxi7K12ToHRhG/Um
         bVnpREbQC5uXRHaZ6pu0y9h9ZKY4eJPUPFdEN3DH8HmOBOyZ4q3NidNm4yU74tfvnF/S
         QDSVaWbadcW04159vszSLFlcoq9WGtJ+h8EGvuda7C7Zq9m4PoD8vvkVcw8hnhzUpWOc
         xwIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v4sor4756239wrq.18.2019.05.16.07.43.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 May 2019 07:43:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqzKDhdhn0sTfAQMEnf2Z3MPEpDPMQ1RAoC5i7RhAcgllW8ck8oD5TGkmgzragiiRcn+PESIqQ==
X-Received: by 2002:a5d:4206:: with SMTP id n6mr17691401wrq.58.1558017806003;
        Thu, 16 May 2019 07:43:26 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id q13sm6113444wrn.27.2019.05.16.07.43.24
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 16 May 2019 07:43:25 -0700 (PDT)
Date: Thu, 16 May 2019 16:43:24 +0200
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: Jann Horn <jannh@google.com>
Cc: kernel list <linux-kernel@vger.kernel.org>,
	Kirill Tkhai <ktkhai@virtuozzo.com>,
	Hugh Dickins <hughd@google.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Greg KH <greg@kroah.com>, Suren Baghdasaryan <surenb@google.com>,
	Minchan Kim <minchan@kernel.org>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	Grzegorz Halat <ghalat@redhat.com>, Linux-MM <linux-mm@kvack.org>,
	Linux API <linux-api@vger.kernel.org>
Subject: Re: [PATCH RFC 4/5] mm/ksm, proc: introduce remote merge
Message-ID: <20190516144323.pzkvs6hapf3czorz@butterfly.localdomain>
References: <20190516094234.9116-1-oleksandr@redhat.com>
 <20190516094234.9116-5-oleksandr@redhat.com>
 <CAG48ez2yXw_PJXO-mS=Qw5rkLpG6zDPd0saMhhGk09-du2bpaA@mail.gmail.com>
 <20190516142013.sf2vitmksvbkb33f@butterfly.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190516142013.sf2vitmksvbkb33f@butterfly.localdomain>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 16, 2019 at 04:20:13PM +0200, Oleksandr Natalenko wrote:
> > [...]
> > > @@ -2960,15 +2962,63 @@ static int proc_stack_depth(struct seq_file *m, struct pid_namespace *ns,
> > >  static ssize_t madvise_write(struct file *file, const char __user *buf,
> > >                 size_t count, loff_t *ppos)
> > >  {
> > > +       /* For now, only KSM hints are implemented */
> > > +#ifdef CONFIG_KSM
> > > +       char buffer[PROC_NUMBUF];
> > > +       int behaviour;
> > >         struct task_struct *task;
> > > +       struct mm_struct *mm;
> > > +       int err = 0;
> > > +       struct vm_area_struct *vma;
> > > +
> > > +       memset(buffer, 0, sizeof(buffer));
> > > +       if (count > sizeof(buffer) - 1)
> > > +               count = sizeof(buffer) - 1;
> > > +       if (copy_from_user(buffer, buf, count))
> > > +               return -EFAULT;
> > > +
> > > +       if (!memcmp("merge", buffer, min(sizeof("merge")-1, count)))
> > 
> > This means that you also match on something like "mergeblah". Just use strcmp().
> 
> I agree. Just to make it more interesting I must say that
> 
>    /sys/kernel/mm/transparent_hugepage/enabled
> 
> uses memcmp in the very same way, and thus echoing "alwaysssss" or
> "madviseeee" works perfectly there, and it was like that from the very
> beginning, it seems. Should we fix it, or it became (zomg) a public API?

Actually, maybe, the reason for using memcmp is to handle "echo"
properly: by default it puts a newline character at the end, so if we use
just strcmp, echo should be called with -n, otherwise strcmp won't match
the string.

Huh?

> [...]

-- 
  Best regards,
    Oleksandr Natalenko (post-factum)
    Senior Software Maintenance Engineer

