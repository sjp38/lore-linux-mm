Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37EE4C76188
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 14:01:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 09E7B21851
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 14:01:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 09E7B21851
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A02FA6B0005; Fri, 19 Jul 2019 10:01:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B3526B0006; Fri, 19 Jul 2019 10:01:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 87D458E0001; Fri, 19 Jul 2019 10:01:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3AEAC6B0005
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 10:01:26 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y3so22106511edm.21
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 07:01:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Re9XNDBGaEOf1drjRYRw2FyiATnegfB3VIFvqkNcyd4=;
        b=AVXb0TeXexkRVMUYBGkZDZDvFlqKqD6SHDYFb8g8OtPJVTNasdNpmH6jUyt9zkV5GP
         /MbYgtfLKjSqyFllhCGVb1eURBLACYtffZ5UH+18qhIXlIdFhqDhbMXg/GwOopO+xB6a
         RB7zYLZ3KyUw0OWQPKNC1b82u6ehfa9/OIAVdVzPyuedfPAiujILsgv/yDnwXF30Puw0
         niO/OX9mXNR9ML6XeSV2yGLntClnsies6WynXsnOLHss3/7g7H6tnnj2K9LUlGkZmk0b
         9gmmv4V0689ZYMCpg6LsZDaXab8ycmD/o1VMJwnaX/cZl2Pnvp+KjhEf0lqk7+PWdrMr
         +omg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=jroedel@suse.de
X-Gm-Message-State: APjAAAUwW+5ZcWtVeatj7OibnB5Jh6qJVBVuTb892hfRhHyPOuAdTnKf
	+OVjFhG3StMOMZLDaHIKEx2iLQhYpvZH8XDFZPJhrCG5V0j2zH+AKU3KwB+CYpbq9uj8PQk1tCv
	58ZBpQhmdi9N25+nyUgQtukZRNoNSSM2W/WkbeiFlYPOAiNHya6JhZ6Tj/qQkWBlvMw==
X-Received: by 2002:a50:9822:: with SMTP id g31mr45435593edb.175.1563544885803;
        Fri, 19 Jul 2019 07:01:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw/JQkiuVgu8790/ZJkmYpg4nflYT1O+4ZoOq6fjPTCT3Ur4akiB9Mw8ihqo29xghw1RDdb
X-Received: by 2002:a50:9822:: with SMTP id g31mr45435494edb.175.1563544885039;
        Fri, 19 Jul 2019 07:01:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563544885; cv=none;
        d=google.com; s=arc-20160816;
        b=znnnkydXnE2TFRwcVxPOtQAYF56QWspuAoGp/fi1cijoKhlmF1IMwOCNqGiU8L4tZF
         UqsO6k0VEat5Y4oqzN6XGkRVUPRghO+6C76jaRjvqT/k4MPPNEC88nWSfkdS6HVKOvx1
         ELvbMViaaS+XECAuyTtcqkdZFdKaZoYTsmVPHgDtn/glh6OYbOEg6vIZ7Y+8GrxO6zBM
         2sv911ilT1sb7eWatQXYStBHVgylLPZCEO/nNoCmNpXVk0k3VI8GeB4SMEkZR7rtY7KY
         yc8iUAeJlv61P+8AB9WMERH2Kb/mj+ZjFS2w0zX/jkehU9WxVyQIHNpSWQLOi2G6audo
         tPGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Re9XNDBGaEOf1drjRYRw2FyiATnegfB3VIFvqkNcyd4=;
        b=xAkYFi1Uxrp20wjUJFTC3fXCcpd9yjKHAc6wxtvGf+/QDneh/kO23uNSz1bBKE8TmK
         UrdjDXScZJ0cjZOtIkwXH/WadxpsePTOf7Q5av1+DdbMbXP2+DPC3GNthbwn7nQzHyp+
         q71vT0v2AEDkMZ3Cu5bxHQfcvykBsIklDxg5oiKeAEhGKNgkkCG1z111pJ+DPFsbWBI4
         QTVWY5rRX1kPVPdaStD1G0QbKZSaGNWDEE28KEdtGksmlxScS8/KcQKQev/5b4cCAG2y
         xRiEBRkqQF0zdaneayil5/Kvt6Ahie6XuxBBgqyrgBZ8RtRvI9zRiVfwSy26PkUKcMS8
         IxXg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=jroedel@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 13si1319720edz.208.2019.07.19.07.01.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 07:01:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jroedel@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=jroedel@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 77F1CAE86;
	Fri, 19 Jul 2019 14:01:24 +0000 (UTC)
Date: Fri, 19 Jul 2019 16:01:22 +0200
From: Joerg Roedel <jroedel@suse.de>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Joerg Roedel <joro@8bytes.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 2/3] x86/mm: Sync also unmappings in vmalloc_sync_one()
Message-ID: <20190719140122.GF19068@suse.de>
References: <20190717071439.14261-1-joro@8bytes.org>
 <20190717071439.14261-3-joro@8bytes.org>
 <alpine.DEB.2.21.1907172337590.1778@nanos.tec.linutronix.de>
 <20190718084654.GF13091@suse.de>
 <alpine.DEB.2.21.1907181103120.1984@nanos.tec.linutronix.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1907181103120.1984@nanos.tec.linutronix.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 18, 2019 at 11:04:57AM +0200, Thomas Gleixner wrote:
> Joerg,
> 
> On Thu, 18 Jul 2019, Joerg Roedel wrote:
> > On Wed, Jul 17, 2019 at 11:43:43PM +0200, Thomas Gleixner wrote:
> > > On Wed, 17 Jul 2019, Joerg Roedel wrote:
> > > > +
> > > > +	if (!pmd_present(*pmd_k))
> > > > +		return NULL;
> > > >  	else
> > > >  		BUG_ON(pmd_pfn(*pmd) != pmd_pfn(*pmd_k));
> > > 
> > > So in case of unmap, this updates only the first entry in the pgd_list
> > > because vmalloc_sync_all() will break out of the iteration over pgd_list
> > > when NULL is returned from vmalloc_sync_one().
> > > 
> > > I'm surely missing something, but how is that supposed to sync _all_ page
> > > tables on unmap as the changelog claims?
> > 
> > No, you are right, I missed that. It is a bug in this patch, the code
> > that breaks out of the loop in vmalloc_sync_all() needs to be removed as
> > well. Will do that in the next version.
> 
> I assume that p4d/pud do not need the pmd treatment, but a comment
> explaining why would be appreciated.

Actually there is already a comment in this function explaining why p4d
and pud don't need any treatment:

        /*
         * set_pgd(pgd, *pgd_k); here would be useless on PAE
         * and redundant with the set_pmd() on non-PAE. As would
         * set_p4d/set_pud.
         */ 

I couldn't say it with less words :)


Regards,

	Joerg

