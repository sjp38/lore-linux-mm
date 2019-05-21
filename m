Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B21B7C04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 01:26:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5FD392173E
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 01:26:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DLIH2eCP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5FD392173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 00ED06B0005; Mon, 20 May 2019 21:26:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F01776B0006; Mon, 20 May 2019 21:26:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DF0EF6B0007; Mon, 20 May 2019 21:26:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A7DCE6B0005
	for <linux-mm@kvack.org>; Mon, 20 May 2019 21:26:57 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id e6so6892531pgl.1
        for <linux-mm@kvack.org>; Mon, 20 May 2019 18:26:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=q5tudNQ9cSMh3fCrTxG8NdksCakwJg8DbWSQrWyIrTI=;
        b=qHGh/t/vcWVGOxmF+6mc4GdCwNfOoOwHP9C4vjRr1xfT2AgZPcG/Zlvez0JBzNw9SU
         LziIh3jLJr2OqaGlCdMAI0uZVQVFb8FG0RUpPMC4r1w9JWNr4gUAQDSyAV9cjSnCUxBb
         TNreTZGLFGObFILCsCaszRyem473kXgwaUlVy5LuOKL1GNuJOmX8EPnuqF3n/Tp18um1
         lQwQ2P0yYCSLp4pEh3Dtui4Ft35gW2pIG1V4t5tC+Hr8+AGV7376mwAhV7gjKXZ+sqJH
         nQnsaTuZ/j7qTtM2wXtvQApSAYVyhQFfiwYZcCVZ+RsZ+hEz/RnWkaAqdmjUbSoAgy+4
         /ang==
X-Gm-Message-State: APjAAAUn/KkB6OXQ/M/Z/lhhUTkExZEWwmreLAL3Qi4DBuzGQU7iwfAx
	+zPmXZAKuHbcWh9A9HL7CkrN1WukZFO8vIdw0KBykxkc2b3vD8AQz/CDtucoPV9L2JaHa7KKZoB
	aNKLZT2lM83t+NItaoBfX/OdvlHwqaIO5fJlcwb5Fkvl/c7Qi+nuhwMlbjTrKKyo=
X-Received: by 2002:a17:902:9689:: with SMTP id n9mr79879103plp.133.1558402017228;
        Mon, 20 May 2019 18:26:57 -0700 (PDT)
X-Received: by 2002:a17:902:9689:: with SMTP id n9mr79879055plp.133.1558402016510;
        Mon, 20 May 2019 18:26:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558402016; cv=none;
        d=google.com; s=arc-20160816;
        b=nO5UcCzy4D2hGxqY5DFZZzXI0UxZvdr9qNQRQmxO7h5ob+7j9MGpO2OSv582vHcDmR
         AEgHMcPno6AtSqi57U+rbouyITxWsW8S0hy6BAHbh6a4zBOsAjbcxhdSabLW57eghVi6
         bBZW2aVtPEp14Kxd1aEpboHVzTmput5EjFba+PcFX8Xohb2Wtkg1A8hXLky3Uk5IJVKQ
         OpjY4bf+2SkIWZ0Nn2czXilDtehBY/Z9Em5eFHuO/GwShnT9bKO/qBWeBC4/IbJ4UZ92
         nLHCyknszX0Rqk2vH70T+1YDB7n+bpp54p+9SNwVQcVrIcKz9r5UD19xvqqSrAaHZHDz
         tBsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=q5tudNQ9cSMh3fCrTxG8NdksCakwJg8DbWSQrWyIrTI=;
        b=zJD424M6RDNCaUvzQcp17/klINWZI9ldlEzVFdZmCAKXFucaRBBYGRYLPkgyUCi1Cz
         ZLYHBFdFlYHM985PS+TIBFd7L9beV8tboiup2U8w3JeBR764EFSiyePa+LeFrVtt6/dD
         QS96qJpl5RdR0xdnDR4ei+OXy5AOoD+OvBk+M4IddXp3/bHRh/sCmWEHb8BhClDHosd5
         ev3aAqb5uPtY07AMjRuge4lewJY7fljv81RHdpy/kM/PvtlYV724fHn7rokOwfgIzvD3
         fEMUkM/RF42RABfp2U1YFY0P1zF9xupuoXnlTkjp38HGVksAXnOCZ6JNzXT1d4Y2dbPR
         0kWg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DLIH2eCP;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h3sor17264000pld.22.2019.05.20.18.26.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 18:26:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=DLIH2eCP;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=q5tudNQ9cSMh3fCrTxG8NdksCakwJg8DbWSQrWyIrTI=;
        b=DLIH2eCPL/TbrcrBJeS072RZfACT/OHayR/cqOaUp7jstN6cQtTJ2IEb2WSwA905Yu
         CbztJl76ysh8fRQywqbHQMTK4Rtqu2TV+LgMStlkUkwDn4fgj109EcDjDtosETfHillX
         pAjdbYgfJtj0PofpNUmu9de9BVwPaZ6FWCF4NrS6UB4R2FgmYMg6DFxcPpyMVltTUWf6
         1QvvaVsF5RCkX2nLqQFkXPI/4Ia/PTK4vdvU6FjwFgyo5LvCfhUcqE6RfsJ//mYo5vgp
         zn0yh4FxQMYMqrVG7Uz48HqxvkW8oi1wqdHSvAJdr88NARk0dpExcyT1I9jxgVTaC5O/
         m0Cw==
X-Google-Smtp-Source: APXvYqwrSyAyALFyw9JHfY/nrm7OEjpxF4Wqstkj8FkkR4Th/leZJbMdZSinz1oSvJWv54bKmZF/tA==
X-Received: by 2002:a17:902:ba8d:: with SMTP id k13mr65556652pls.52.1558402016072;
        Mon, 20 May 2019 18:26:56 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id a8sm9209871pfk.14.2019.05.20.18.26.51
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 20 May 2019 18:26:54 -0700 (PDT)
Date: Tue, 21 May 2019 10:26:49 +0900
From: Minchan Kim <minchan@kernel.org>
To: Oleksandr Natalenko <oleksandr@redhat.com>
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
Subject: Re: [RFC 4/7] mm: factor out madvise's core functionality
Message-ID: <20190521012649.GE10039@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-5-minchan@kernel.org>
 <20190520142633.x5d27gk454qruc4o@butterfly.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190520142633.x5d27gk454qruc4o@butterfly.localdomain>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Oleksandr,

On Mon, May 20, 2019 at 04:26:33PM +0200, Oleksandr Natalenko wrote:
> Hi.
> 
> On Mon, May 20, 2019 at 12:52:51PM +0900, Minchan Kim wrote:
> > This patch factor out madvise's core functionality so that upcoming
> > patch can reuse it without duplication.
> > 
> > It shouldn't change any behavior.
> > 
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  mm/madvise.c | 168 +++++++++++++++++++++++++++------------------------
> >  1 file changed, 89 insertions(+), 79 deletions(-)
> > 
> > diff --git a/mm/madvise.c b/mm/madvise.c
> > index 9a6698b56845..119e82e1f065 100644
> > --- a/mm/madvise.c
> > +++ b/mm/madvise.c
> > @@ -742,7 +742,8 @@ static long madvise_dontneed_single_vma(struct vm_area_struct *vma,
> >  	return 0;
> >  }
> >  
> > -static long madvise_dontneed_free(struct vm_area_struct *vma,
> > +static long madvise_dontneed_free(struct task_struct *tsk,
> > +				  struct vm_area_struct *vma,
> >  				  struct vm_area_struct **prev,
> >  				  unsigned long start, unsigned long end,
> >  				  int behavior)
> > @@ -754,8 +755,8 @@ static long madvise_dontneed_free(struct vm_area_struct *vma,
> >  	if (!userfaultfd_remove(vma, start, end)) {
> >  		*prev = NULL; /* mmap_sem has been dropped, prev is stale */
> >  
> > -		down_read(&current->mm->mmap_sem);
> > -		vma = find_vma(current->mm, start);
> > +		down_read(&tsk->mm->mmap_sem);
> > +		vma = find_vma(tsk->mm, start);
> >  		if (!vma)
> >  			return -ENOMEM;
> >  		if (start < vma->vm_start) {
> > @@ -802,7 +803,8 @@ static long madvise_dontneed_free(struct vm_area_struct *vma,
> >   * Application wants to free up the pages and associated backing store.
> >   * This is effectively punching a hole into the middle of a file.
> >   */
> > -static long madvise_remove(struct vm_area_struct *vma,
> > +static long madvise_remove(struct task_struct *tsk,
> > +				struct vm_area_struct *vma,
> >  				struct vm_area_struct **prev,
> >  				unsigned long start, unsigned long end)
> >  {
> > @@ -836,13 +838,13 @@ static long madvise_remove(struct vm_area_struct *vma,
> >  	get_file(f);
> >  	if (userfaultfd_remove(vma, start, end)) {
> >  		/* mmap_sem was not released by userfaultfd_remove() */
> > -		up_read(&current->mm->mmap_sem);
> > +		up_read(&tsk->mm->mmap_sem);
> >  	}
> >  	error = vfs_fallocate(f,
> >  				FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
> >  				offset, end - start);
> >  	fput(f);
> > -	down_read(&current->mm->mmap_sem);
> > +	down_read(&tsk->mm->mmap_sem);
> >  	return error;
> >  }
> >  
> > @@ -916,12 +918,13 @@ static int madvise_inject_error(int behavior,
> >  #endif
> 
> What about madvise_inject_error() and get_user_pages_fast() in it
> please?

Good point. Maybe, there more places where assume context is "current" so
I'm thinking to limit hints we could allow from external process.
It would be better for maintainance point of view in that we could know
the workload/usecases when someone ask new advises from external process
without making every hints works both contexts.

Thanks.

