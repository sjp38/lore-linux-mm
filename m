Return-Path: <SRS0=SV65=O7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B47A3C43387
	for <linux-mm@archiver.kernel.org>; Sat, 22 Dec 2018 08:04:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4F32921939
	for <linux-mm@archiver.kernel.org>; Sat, 22 Dec 2018 08:04:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F32921939
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=hofr.at
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C838F8E0004; Sat, 22 Dec 2018 03:04:32 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C34488E0001; Sat, 22 Dec 2018 03:04:32 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B702B8E0004; Sat, 22 Dec 2018 03:04:32 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5FDDC8E0001
	for <linux-mm@kvack.org>; Sat, 22 Dec 2018 03:04:32 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id r11so2663951wmg.1
        for <linux-mm@kvack.org>; Sat, 22 Dec 2018 00:04:32 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=ywCBPyC7QwIGQnMBDLOHxUcpyhvTqUx/uC/XylS0pso=;
        b=csksdk0rKa71vdHkadtuuRcXkdQQACQOq6w8rSwAUoONbQ9jGDEpH1c/jL54TazeQy
         1xX3tI9vO88ghRUvOpXlAs8u9r+q9yUcXzPi7R6x7WY5Mv0l5SuJLykslCUaVnpCeU0P
         TtWnHdjjC2sL4znVX3kVU5YAjdghZcb1rjOyjpOqhlBFX5SfLDPva4vca6ss18zGtSFY
         VW8LN7ka+XvQ8KzDbua4Cl3hphg2oM43HFHEfc/pIoa5EFMuYOOFeVyoxO50WLfkXerD
         c/Uw/k+eFQTmGVSXfJONFQMe0gN8+oenYo/nltw8NALIL/GYG0Ow2vrVpD0GU84tMv02
         Q9IQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of hofrat@osadl.at designates 178.115.242.59 as permitted sender) smtp.mailfrom=hofrat@osadl.at
X-Gm-Message-State: AJcUukeuUBK7lFn8yj0tclUCsjYCau9ZD2mYmYMIV2zJVQ25SKwnUjs4
	6NRbjP+hwW3WwspSwwSzbUyKLchr8DfoofrTSvodRpohAaYDSovjbUS3GAGAKeigoQnxlfk+ZJM
	qCIG4y1i0UFbCtiI2Ystr4wqrJUf8eK6PrcnZ/lNwY7B1KpNaPcrRuCJ2PgNFePA=
X-Received: by 2002:a1c:e088:: with SMTP id x130mr5301812wmg.23.1545465871766;
        Sat, 22 Dec 2018 00:04:31 -0800 (PST)
X-Google-Smtp-Source: AFSGD/Vus8gy0JqXZPhhUQX1GrEdR4/iY0/oB+/xyUqLSh3MNpQqNyr+nGNX1HhP3lksBOsxV5x+
X-Received: by 2002:a1c:e088:: with SMTP id x130mr5301747wmg.23.1545465870630;
        Sat, 22 Dec 2018 00:04:30 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545465870; cv=none;
        d=google.com; s=arc-20160816;
        b=00JSS30jkViQnWmHl7AfrFNpROpBVQ5hdwNXIkMRJVmgPfkBP1yBIhkJHngoS9pGbK
         SApPZBV1a9GelOx8saeLkAawz+kYKSGikTIfh8EANZKQu61OdYyWlkUepCAMIRJgM3Mo
         IKFPe8p7Hel+U8CHgeCgPwXYtkqoFAmMhejePq2f9V8YPT08Xv7UvB3ccTx57co8FQel
         t/nt7L7jlmVHmlV1jYsNmmRFIwBR8/Lz+5NgvQdHuS4SlA+DJJn9dPHjqQoqBqPrHgEr
         VKEsKbjTXGTDpod0Hea/BJwsKVvPZ5vEv499bteKzythypAQ4V+tUrBwmDER4fOo12a4
         Gc9g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=ywCBPyC7QwIGQnMBDLOHxUcpyhvTqUx/uC/XylS0pso=;
        b=Z9iybcRehYG68P+iBppkBXrxtIrzE9xc14u5d9LrvoeDwLcYvkfNFu5STWQdkBtxrP
         E+PnvwN0pxf+pNDYb6Z6dJuOr8e16ntB3mF+Mf9CqTrptQJHF31LYSyQVYHXlf1A1Hnb
         ycVW5NUJg36Eyuw7EtOveB2J60fBhcM3nLAkCaqBtatlcsIyLkCQhNuwr2SNyTEc+Ii/
         LTy4fO0ng2qtQQnsPsmxMV7V5s/Pvh1mg0Tgzy85xuEQZjRENYhmtRrAZkXyuX8Mzo42
         GSRZx5EaODS+fvKK+66ZljXYq8FAS0Hn8jH6w7L18q1cwpqLUoHm43hXlny7YUyOJlPY
         7lUw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of hofrat@osadl.at designates 178.115.242.59 as permitted sender) smtp.mailfrom=hofrat@osadl.at
Received: from mail.osadl.at (178.115.242.59.static.drei.at. [178.115.242.59])
        by mx.google.com with ESMTP id u187si9604652wmf.22.2018.12.22.00.04.30
        for <linux-mm@kvack.org>;
        Sat, 22 Dec 2018 00:04:30 -0800 (PST)
Received-SPF: pass (google.com: domain of hofrat@osadl.at designates 178.115.242.59 as permitted sender) client-ip=178.115.242.59;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of hofrat@osadl.at designates 178.115.242.59 as permitted sender) smtp.mailfrom=hofrat@osadl.at
Received: by mail.osadl.at (Postfix, from userid 1001)
	id B9FF05C075C; Sat, 22 Dec 2018 09:04:21 +0100 (CET)
Date: Sat, 22 Dec 2018 09:04:21 +0100
From: Nicholas Mc Guire <der.herr@hofr.at>
To: David Rientjes <rientjes@google.com>
Cc: Nicholas Mc Guire <hofrat@osadl.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Michal Hocko <mhocko@suse.com>,
	Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Arun KS <arunks@codeaurora.org>, Joe Perches <joe@perches.com>,
	"Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH RFC] mm: vmalloc: do not allow kzalloc to fail
Message-ID: <20181222080421.GB26155@osadl.at>
References: <1545337437-673-1-git-send-email-hofrat@osadl.org>
 <alpine.DEB.2.21.1812211356040.219499@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <alpine.DEB.2.21.1812211356040.219499@chino.kir.corp.google.com>
User-Agent: Mutt/1.5.23 (2014-03-12)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181222080421.deVYeILdkDrNZm3DWZTogeFluy4hscEmwhAFKJIqSrA@z>

On Fri, Dec 21, 2018 at 01:58:39PM -0800, David Rientjes wrote:
> On Thu, 20 Dec 2018, Nicholas Mc Guire wrote:
> 
> > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > index 871e41c..1c118d7 100644
> > --- a/mm/vmalloc.c
> > +++ b/mm/vmalloc.c
> > @@ -1258,7 +1258,7 @@ void __init vmalloc_init(void)
> >  
> >  	/* Import existing vmlist entries. */
> >  	for (tmp = vmlist; tmp; tmp = tmp->next) {
> > -		va = kzalloc(sizeof(struct vmap_area), GFP_NOWAIT);
> > +		va = kzalloc(sizeof(*va), GFP_NOWAIT | __GFP_NOFAIL);
> >  		va->flags = VM_VM_AREA;
> >  		va->va_start = (unsigned long)tmp->addr;
> >  		va->va_end = va->va_start + tmp->size;
> 
> Hi Nicholas,
> 
> You're right that this looks wrong because there's no guarantee that va is 
> actually non-NULL.  __GFP_NOFAIL won't help in init, unfortunately, since 
> we're not giving the page allocator a chance to reclaim so this would 
> likely just end up looping forever instead of crashing with a NULL pointer 
> dereference, which would actually be the better result.
>
tried tracing the __GFP_NOFAIL path and had concluded that it would
end in out_of_memory() -> panic("System is deadlocked on memory\n");
which also should point cleanly to the cause - but I´m actually not
that sure if that trace was correct in all cases.
 
> You could do
> 
> 	BUG_ON(!va);
> 
> to make it obvious why we crashed, however.  It makes it obvious that the 
> crash is intentional rather than some error in the kernel code.

makes sense - that atleast makes it imediately clear from the code
that there is no way out from here.

thx!
hofrat

