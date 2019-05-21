Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22F13C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 10:55:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D77D621773
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 10:55:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D77D621773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 56ACE6B0005; Tue, 21 May 2019 06:55:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51A3F6B0006; Tue, 21 May 2019 06:55:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4300E6B0007; Tue, 21 May 2019 06:55:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id EA3926B0005
	for <linux-mm@kvack.org>; Tue, 21 May 2019 06:55:05 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id f41so30108109ede.1
        for <linux-mm@kvack.org>; Tue, 21 May 2019 03:55:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=1nYeTedA8kwi8btjBOD06Kuvm3EO7ScK5u4iFYAOYAI=;
        b=rFkwPj1ienDUN6cIJUzBwJ5LppXse/uY1xgj9qvsV5RcV4MxRd4F3xyuKV2RKuWUTU
         pJB91VCQk+caG4uvXhcY5tfHidtiquTP/Pol2ymoq2DEZwuMJzInrWAcVhXrj/ryIzBm
         /FSHX2USoijUlWGtm1Mrzid/oCCSHNCKUVvYWsgCm2KhsAwgOe2PEFwZPzpej897UCrr
         M2zOwhTyYXo+Nu/lsj6muF5JjKnIfT7wncFtcShSdloE4v9yROX3cOwuRRNDJh4KkMz/
         1G5DLhipCV5dke082sQsTMYkrR7X4PwMQxDWriz5edhAXilG3wCl93nmKFjuqgUphyJF
         TfFA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWASgWIZXr/tUqj8e0xf6OGc//JtQtEKxbiZGT2zjW9DPq8kgVL
	qOKWRnqmjqtPjoEVj6tm3Ikpb6i4/Dk/ZFzFA7+ZnBCdu8mMIZF9NSPOlkkOD8qfI4Q30j4edPt
	dvkzFZfCwHx/mIU54mR4zVZbNDdbSgQSRZtu1Q3J7RpbTSIPgZeL15C7TyZQwj/w=
X-Received: by 2002:a50:86fb:: with SMTP id 56mr82558528edu.83.1558436105376;
        Tue, 21 May 2019 03:55:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFJ04qcDQY1clIikn6C5u2v9ROHod1HTKw0DLK1fAct/vTZNaJKz09l5Fb524lQooNWXW4
X-Received: by 2002:a50:86fb:: with SMTP id 56mr82558470edu.83.1558436104632;
        Tue, 21 May 2019 03:55:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558436104; cv=none;
        d=google.com; s=arc-20160816;
        b=NQWE8MXnL2g89T/JjPsmSnLpvKXEpRmEIRhXzjLnpKGydfAW8SlShvkT9w/1VNOvSi
         ERnBwBAKzsy+CBMGCw434tR4KG9dpRRgz/In/L1yJ2lqMlJb+vudVWwobIkqp13UpNK/
         rA+dOp1e8g+is+hapuh5dMSqLB6ogAkUA5PMb7PhukKsfuMW9VdxQgfXgV4jGGR6ESgk
         9HQ4RgPCSyJxCURC74hAQ7fxRJt9Zbvw4PRFAsFEHTqBcEyHOTN1NSP71dkZuPIO2gma
         zDZNuAOTU1RyWgcFpJjduZHgXQ/wgai0fRrcGmBINIBboYKhEG0Y+DnqVQl4K+Bffq2o
         Wkcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=1nYeTedA8kwi8btjBOD06Kuvm3EO7ScK5u4iFYAOYAI=;
        b=I1eRfPKDAdhE6RgFvKPjIsGjtcr/UmtnNRsurVs2yEi1wwotzPG6mIeuD7Xejoynca
         LPOuSxGBmiK1UGXdm7KxPCNMoq90EJhaaHL5udCqidHa08uWkimp+nyR7XjLOVxUrX/a
         +3mLNwPbtnfG1ZG68uAclRmkIvsGBd0adc8W1VPTkamPeRwlxcC0m2/9RF/0R5iiD76t
         exDx/ExwHGHKrKxtUcys4FdwYiCGU22o1vl4vzDWKE4L0Yb51TUKgo49Lu2Qrb+z6k67
         ObDVEovILJt3QVGDOj1nVj+oyg3+v9MUzgaZWXU4JRMm6bpnIoa5cxlFfAe4u42R90tI
         dNMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g20si7822135edc.146.2019.05.21.03.55.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 03:55:04 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 2FCA9ACBC;
	Tue, 21 May 2019 10:55:04 +0000 (UTC)
Date: Tue, 21 May 2019 12:55:03 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Oleksandr Natalenko <oleksandr@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 4/7] mm: factor out madvise's core functionality
Message-ID: <20190521105503.GQ32329@dhcp22.suse.cz>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-5-minchan@kernel.org>
 <20190520142633.x5d27gk454qruc4o@butterfly.localdomain>
 <20190521012649.GE10039@google.com>
 <20190521063628.x2npirvs75jxjilx@butterfly.localdomain>
 <20190521104949.GE219653@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521104949.GE219653@google.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 21-05-19 19:49:49, Minchan Kim wrote:
> On Tue, May 21, 2019 at 08:36:28AM +0200, Oleksandr Natalenko wrote:
> > Hi.
> > 
> > On Tue, May 21, 2019 at 10:26:49AM +0900, Minchan Kim wrote:
> > > On Mon, May 20, 2019 at 04:26:33PM +0200, Oleksandr Natalenko wrote:
> > > > Hi.
> > > > 
> > > > On Mon, May 20, 2019 at 12:52:51PM +0900, Minchan Kim wrote:
> > > > > This patch factor out madvise's core functionality so that upcoming
> > > > > patch can reuse it without duplication.
> > > > > 
> > > > > It shouldn't change any behavior.
> > > > > 
> > > > > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > > > > ---
> > > > >  mm/madvise.c | 168 +++++++++++++++++++++++++++------------------------
> > > > >  1 file changed, 89 insertions(+), 79 deletions(-)
> > > > > 
> > > > > diff --git a/mm/madvise.c b/mm/madvise.c
> > > > > index 9a6698b56845..119e82e1f065 100644
> > > > > --- a/mm/madvise.c
> > > > > +++ b/mm/madvise.c
> > > > > @@ -742,7 +742,8 @@ static long madvise_dontneed_single_vma(struct vm_area_struct *vma,
> > > > >  	return 0;
> > > > >  }
> > > > >  
> > > > > -static long madvise_dontneed_free(struct vm_area_struct *vma,
> > > > > +static long madvise_dontneed_free(struct task_struct *tsk,
> > > > > +				  struct vm_area_struct *vma,
> > > > >  				  struct vm_area_struct **prev,
> > > > >  				  unsigned long start, unsigned long end,
> > > > >  				  int behavior)
> > > > > @@ -754,8 +755,8 @@ static long madvise_dontneed_free(struct vm_area_struct *vma,
> > > > >  	if (!userfaultfd_remove(vma, start, end)) {
> > > > >  		*prev = NULL; /* mmap_sem has been dropped, prev is stale */
> > > > >  
> > > > > -		down_read(&current->mm->mmap_sem);
> > > > > -		vma = find_vma(current->mm, start);
> > > > > +		down_read(&tsk->mm->mmap_sem);
> > > > > +		vma = find_vma(tsk->mm, start);
> > > > >  		if (!vma)
> > > > >  			return -ENOMEM;
> > > > >  		if (start < vma->vm_start) {
> > > > > @@ -802,7 +803,8 @@ static long madvise_dontneed_free(struct vm_area_struct *vma,
> > > > >   * Application wants to free up the pages and associated backing store.
> > > > >   * This is effectively punching a hole into the middle of a file.
> > > > >   */
> > > > > -static long madvise_remove(struct vm_area_struct *vma,
> > > > > +static long madvise_remove(struct task_struct *tsk,
> > > > > +				struct vm_area_struct *vma,
> > > > >  				struct vm_area_struct **prev,
> > > > >  				unsigned long start, unsigned long end)
> > > > >  {
> > > > > @@ -836,13 +838,13 @@ static long madvise_remove(struct vm_area_struct *vma,
> > > > >  	get_file(f);
> > > > >  	if (userfaultfd_remove(vma, start, end)) {
> > > > >  		/* mmap_sem was not released by userfaultfd_remove() */
> > > > > -		up_read(&current->mm->mmap_sem);
> > > > > +		up_read(&tsk->mm->mmap_sem);
> > > > >  	}
> > > > >  	error = vfs_fallocate(f,
> > > > >  				FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
> > > > >  				offset, end - start);
> > > > >  	fput(f);
> > > > > -	down_read(&current->mm->mmap_sem);
> > > > > +	down_read(&tsk->mm->mmap_sem);
> > > > >  	return error;
> > > > >  }
> > > > >  
> > > > > @@ -916,12 +918,13 @@ static int madvise_inject_error(int behavior,
> > > > >  #endif
> > > > 
> > > > What about madvise_inject_error() and get_user_pages_fast() in it
> > > > please?
> > > 
> > > Good point. Maybe, there more places where assume context is "current" so
> > > I'm thinking to limit hints we could allow from external process.
> > > It would be better for maintainance point of view in that we could know
> > > the workload/usecases when someone ask new advises from external process
> > > without making every hints works both contexts.
> > 
> > Well, for madvise_inject_error() we still have a remote variant of
> > get_user_pages(), and that should work, no?
> 
> Regardless of madvise_inject_error, it seems to be risky to expose all
> of hints for external process, I think. For example, MADV_DONTNEED with
> race, it's critical for stability. So, until we could get the way to
> prevent the race, I want to restrict hints.

Well, if you allow the full ptrace access then you can shoot the target
whatever you like.

> > Regarding restricting the hints, I'm definitely interested in having
> > remote MADV_MERGEABLE/MADV_UNMERGEABLE. But, OTOH, doing it via remote
> > madvise() introduces another issue with traversing remote VMAs reliably.
> 
> How is it signifiact when the race happens? It could waste CPU cycle
> and make unncessary break of that merged pages but expect it should be
> rare so such non-desruptive hint could be exposed via process_madvise, I think.
> 
> If the hint is critical for the race, yes, as Michal suggested, we need a way
> to close it and I guess non-cooperative userfaultfd with synchronous support
> would help private anonymous vma.

If we have a per vma fd approach then we can revalidate atomically and
make sure the operation is performed on the range that was really
requested. I do not think we want to provide a more specific guarantees.
Monitor process has to be careful same way ptrace doesn't want to harm
the target.

-- 
Michal Hocko
SUSE Labs

