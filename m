Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F5C2C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 06:36:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F1B2C2173C
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 06:36:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F1B2C2173C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 677406B0006; Tue, 21 May 2019 02:36:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 600FA6B0007; Tue, 21 May 2019 02:36:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47B986B0008; Tue, 21 May 2019 02:36:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id EA4896B0006
	for <linux-mm@kvack.org>; Tue, 21 May 2019 02:36:31 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id q11so123954wmq.6
        for <linux-mm@kvack.org>; Mon, 20 May 2019 23:36:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=pe1wEfWWxpVevLzH/SDlhBfecYpqVfg5aDepIYqh0eg=;
        b=k91Wt54woQNXLQjPk51lNpY6xeD3xnze7tyF/Ry3qecDhpGwziju5Y+BEHHd6e+j2L
         ten/9UlzDk8hCOYCTQ9jzwlW68Meq+XnW6LJu/VaOpMGApYgKnAAdlRsUxC5+jbF/9w/
         9mBcuAyiK80rJdA68gc3nSOOBVNShq7hDBzXXFWVbwLqbvTSknziORZ91PA/E/VmUQv/
         Tq9DJylwbFTIMo2XrXW+2K/Kkh9dj8D7n3PIs61VOgwvFyPCqMQyJOK6KQJHameyYgEB
         qTX09Ovyqvugbx7tyybuwIk8y6zJYtzB/15bsSGPpuSYlz7bPky67ILC3A6Bz9jCmvCE
         Z/ow==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAW3IJ8HOOQ939OeQnRlVbQkRcWwDJYhNSDFGiZuua8O5J23xvPy
	dFqCJkGEBQCyPtWk3+n7Q0y5MbqCoWLj65XD07dgpkC65LYR+HKFUC9PEjVunZcjKt69fMbIObj
	JYuLNZ7VLWFQl9y/faEVvQ6vFQVCdqOaGtr6vgnz7sljDZjow2LUKDL1W/zmIvYyhbQ==
X-Received: by 2002:a1c:1903:: with SMTP id 3mr1944106wmz.103.1558420591451;
        Mon, 20 May 2019 23:36:31 -0700 (PDT)
X-Received: by 2002:a1c:1903:: with SMTP id 3mr1944065wmz.103.1558420590596;
        Mon, 20 May 2019 23:36:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558420590; cv=none;
        d=google.com; s=arc-20160816;
        b=WPSRXmoYvCy5S4Quf9tiRVmXoty3uCbIBue5rpbS9fmes3vJfLt/SfNNe7CID5NHqX
         7H8VhU+sMhIjw6FUnDEFo8nypnIrtssmP5AyOecWq9x/SZKOHxHyfpIUmLskXAtD/FJ2
         TrFyfUkkn+PE90N+kRBiCFqfkmKVkxpVtlq90vWIY6ENG8l/Gvk8wpdyRm3AkQ2XNilf
         ZNlD6Vg35JvlUqPvHsuM3ecoN7QiTH3Izs40r5FaEypuuWHEfEEKiD4PhnNS/l3iGl8V
         DQk5m2b/bNwjGeeqTFFIHLC7uCaggAqFf9OJA6QYxxpY7k2sMYPmMDKZ9VTK1XzP0Kdh
         gGpg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=pe1wEfWWxpVevLzH/SDlhBfecYpqVfg5aDepIYqh0eg=;
        b=XVNxjPiEJ8WlFJFWt2QSg9CSFUKyF1flJTz5qpxv0GUBGzpuCbUfuY1ZaMD551o//N
         WOICqOv4kdRKEs7YEiYWWGWSxkNdpWTX3ceYEf0PL1hMHDZ3bU1Qa9bhdHQTgUqYfVMI
         G6/O7TSMvRcWjKwT1xyxCoZ6k8tS+8lPRIhHBI9LQpWHFCQ+Esv2JKnDyMb/O9DmFBTO
         PFdAfwI1gWNL/2YzPijTAItdwbVwv/IfYdhdP+b+ozbo1m04vmSjwN1oudA/kmzvIZRi
         Nja8uzVjUeBfNAbP83y8Ys3WskUd8pLRducdH9DP+3vDxisiWLVEZewa5lDJhRvLdi+A
         Fttw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s18sor8053969wrm.38.2019.05.20.23.36.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 23:36:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqwXxAV7y5XZ4ldwJaw3BtY2edne6dyljFDVIHToDTC0rOo9PIiZ79depKRqtC5aXkafrl560A==
X-Received: by 2002:a5d:688f:: with SMTP id h15mr10725497wru.44.1558420590217;
        Mon, 20 May 2019 23:36:30 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id h17sm1561044wrq.79.2019.05.20.23.36.28
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 20 May 2019 23:36:29 -0700 (PDT)
Date: Tue, 21 May 2019 08:36:28 +0200
From: Oleksandr Natalenko <oleksandr@redhat.com>
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
Subject: Re: [RFC 4/7] mm: factor out madvise's core functionality
Message-ID: <20190521063628.x2npirvs75jxjilx@butterfly.localdomain>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-5-minchan@kernel.org>
 <20190520142633.x5d27gk454qruc4o@butterfly.localdomain>
 <20190521012649.GE10039@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521012649.GE10039@google.com>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi.

On Tue, May 21, 2019 at 10:26:49AM +0900, Minchan Kim wrote:
> On Mon, May 20, 2019 at 04:26:33PM +0200, Oleksandr Natalenko wrote:
> > Hi.
> > 
> > On Mon, May 20, 2019 at 12:52:51PM +0900, Minchan Kim wrote:
> > > This patch factor out madvise's core functionality so that upcoming
> > > patch can reuse it without duplication.
> > > 
> > > It shouldn't change any behavior.
> > > 
> > > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > > ---
> > >  mm/madvise.c | 168 +++++++++++++++++++++++++++------------------------
> > >  1 file changed, 89 insertions(+), 79 deletions(-)
> > > 
> > > diff --git a/mm/madvise.c b/mm/madvise.c
> > > index 9a6698b56845..119e82e1f065 100644
> > > --- a/mm/madvise.c
> > > +++ b/mm/madvise.c
> > > @@ -742,7 +742,8 @@ static long madvise_dontneed_single_vma(struct vm_area_struct *vma,
> > >  	return 0;
> > >  }
> > >  
> > > -static long madvise_dontneed_free(struct vm_area_struct *vma,
> > > +static long madvise_dontneed_free(struct task_struct *tsk,
> > > +				  struct vm_area_struct *vma,
> > >  				  struct vm_area_struct **prev,
> > >  				  unsigned long start, unsigned long end,
> > >  				  int behavior)
> > > @@ -754,8 +755,8 @@ static long madvise_dontneed_free(struct vm_area_struct *vma,
> > >  	if (!userfaultfd_remove(vma, start, end)) {
> > >  		*prev = NULL; /* mmap_sem has been dropped, prev is stale */
> > >  
> > > -		down_read(&current->mm->mmap_sem);
> > > -		vma = find_vma(current->mm, start);
> > > +		down_read(&tsk->mm->mmap_sem);
> > > +		vma = find_vma(tsk->mm, start);
> > >  		if (!vma)
> > >  			return -ENOMEM;
> > >  		if (start < vma->vm_start) {
> > > @@ -802,7 +803,8 @@ static long madvise_dontneed_free(struct vm_area_struct *vma,
> > >   * Application wants to free up the pages and associated backing store.
> > >   * This is effectively punching a hole into the middle of a file.
> > >   */
> > > -static long madvise_remove(struct vm_area_struct *vma,
> > > +static long madvise_remove(struct task_struct *tsk,
> > > +				struct vm_area_struct *vma,
> > >  				struct vm_area_struct **prev,
> > >  				unsigned long start, unsigned long end)
> > >  {
> > > @@ -836,13 +838,13 @@ static long madvise_remove(struct vm_area_struct *vma,
> > >  	get_file(f);
> > >  	if (userfaultfd_remove(vma, start, end)) {
> > >  		/* mmap_sem was not released by userfaultfd_remove() */
> > > -		up_read(&current->mm->mmap_sem);
> > > +		up_read(&tsk->mm->mmap_sem);
> > >  	}
> > >  	error = vfs_fallocate(f,
> > >  				FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
> > >  				offset, end - start);
> > >  	fput(f);
> > > -	down_read(&current->mm->mmap_sem);
> > > +	down_read(&tsk->mm->mmap_sem);
> > >  	return error;
> > >  }
> > >  
> > > @@ -916,12 +918,13 @@ static int madvise_inject_error(int behavior,
> > >  #endif
> > 
> > What about madvise_inject_error() and get_user_pages_fast() in it
> > please?
> 
> Good point. Maybe, there more places where assume context is "current" so
> I'm thinking to limit hints we could allow from external process.
> It would be better for maintainance point of view in that we could know
> the workload/usecases when someone ask new advises from external process
> without making every hints works both contexts.

Well, for madvise_inject_error() we still have a remote variant of
get_user_pages(), and that should work, no?

Regarding restricting the hints, I'm definitely interested in having
remote MADV_MERGEABLE/MADV_UNMERGEABLE. But, OTOH, doing it via remote
madvise() introduces another issue with traversing remote VMAs reliably.
IIUC, one can do this via userspace by parsing [s]maps file only, which
is not very consistent, and once some range is parsed, and then it is
immediately gone, a wrong hint will be sent.

Isn't this a problem we should worry about?

> 
> Thanks.

-- 
  Best regards,
    Oleksandr Natalenko (post-factum)
    Senior Software Maintenance Engineer

