Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4AD91C04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 10:49:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 003C921743
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 10:49:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iIN5PRr2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 003C921743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 93F706B0003; Tue, 21 May 2019 06:49:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8C82F6B0005; Tue, 21 May 2019 06:49:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 767CE6B0006; Tue, 21 May 2019 06:49:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3AAC16B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 06:49:58 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id s5so11900527pgv.21
        for <linux-mm@kvack.org>; Tue, 21 May 2019 03:49:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Stm0C6YcpMXYSmn/MRE96nYtm0sE3cLGz18Bicx3vkY=;
        b=EkgzZO62YzPSo6MB/cCiPP5BbMZj61SmanqMUc7CXc1/ccBKl45F2TvxJbuYC9gs1O
         8MzENDRxbX+Wb0sJSSIBnqhhTEUOByl91+YinVkXBadsSAYG2TyRv0g8KwNTj8Use234
         5YVrjhlPck+qqdT56qnBUxHWdY4o7ko/TFnPpPY+28yuzRVojzJFRjqnwcb10fIv7+IT
         PFkpdue/87TfKvfyhn9Rv/GoHma6iF+Q+2Kvb/MO3/lLVZ9twjgePhCimMEIXNyRhRyI
         z3zbgXyHcKSG15eDgBebnK7Xb1dTF4ivmPL8BHDwvWTq+To1+/btQ2PwfixdVszRuyId
         /5vA==
X-Gm-Message-State: APjAAAVJhreadmKX24DCf62CwV6dzWLXJSVweUF22ocDprwaAzsPhXp+
	8LZDzulWEr6VzHPYGGn+es3g4+zDZn7mm/nGM+lxrMt3t4Y52+PN74zxUU41OEI2QHIFPV4t7pd
	/ZSbcSyvsSWRQuBE9S5S4wJtggruRIjq3fftMoo4PQGBiDvzG7tIh9rKBIWlzEmQ=
X-Received: by 2002:a63:c50c:: with SMTP id f12mr80363816pgd.71.1558435797869;
        Tue, 21 May 2019 03:49:57 -0700 (PDT)
X-Received: by 2002:a63:c50c:: with SMTP id f12mr80363747pgd.71.1558435796935;
        Tue, 21 May 2019 03:49:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558435796; cv=none;
        d=google.com; s=arc-20160816;
        b=Su+7tHORT078K/a5S5awIknL68SHhab5J3x+UBg1vWsQQe21SHuZAv8Qdebyttb+f4
         p8ScLjbcQ818rSTkfb94axQb3G5IU02gj7CYiMlIU8ijS83hGnbWkpgOhLhMLPp5HIoX
         D9FX1GiFaAoAQWqB/9P3bMmjfvhRnrdsrz9CzjRwBkAjTVtXIakdHrBxrYgd/fo4mV/9
         Jc4Vpn8AE6tEyr7wCHidWn8AfMxrX03e6NBXzval+mq8T4xttgiqm8lHO4fO/g1UTtbr
         3dnP1ZY6qFuel/TsLn6LATx+HV6LbT9zkDCW5gKpLf3iBvQlYMO0V+a43ntIT/kYiM27
         ZmJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:sender:dkim-signature;
        bh=Stm0C6YcpMXYSmn/MRE96nYtm0sE3cLGz18Bicx3vkY=;
        b=Gr+wX7zHGgnZWaHcRfBTAqBx1871/MokZHPi5X8itJGmEJ+GzIlhywf2EQoVmQMB5O
         HChQikaiLDua5BSTToxnEw6FpY1K4AGm00dPopeFWlEGliaBfLj2xyqJFAqHiJ63fI5p
         3ALGIbKtqPNoWpgd3VBC8QWaXQf2b4d7FSTImwK4DOLnJP9/7mq82QC/75GHQJrdRz+r
         J1YwY5/FvTG/ZhH/gf4FD8D8+bUHJpor+4l1kN08ipaQqfHOC95IBvtl8N2TomX9wJY5
         HnOa5OLwXsEb4JN9TYj1NUpjcHy75QxQ+xAqXHbd05NkAZIpWB27R+r0S7iko52Jnfwe
         yang==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iIN5PRr2;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h7sor22066286pfe.27.2019.05.21.03.49.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 21 May 2019 03:49:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=iIN5PRr2;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Stm0C6YcpMXYSmn/MRE96nYtm0sE3cLGz18Bicx3vkY=;
        b=iIN5PRr2hhNy5miQal2uGj/iuK5FmlUMC9h2UEPsfJeTZju++lqBt+VYJDK9rKDdjC
         d+/cjsV2pGDIU4DDOVYwu0ysyBmR0aU5skWSm8VCVT0YCVByWj7Ej0BUb1MoaVN4FwhD
         ve/wwArQeyg3pYsNH3YRSPnltb8ptahfbBNSqSx7ui/rgUPwX3w7xo38gGlRC8hohIHK
         Q20WLiy8bPg42TX01v2UIP8MbTprSMe6tI927OHDRqRk8KfeKgmjJF8wqYhmXp6TYdhT
         YM7sJeyPGmdz12RWrnG7b2EUBYFAGYy9JWq/npboH53iH0aQBko+NJf6ryHJlb0fgsfB
         ZXig==
X-Google-Smtp-Source: APXvYqxGi76NyYcWDtIEDaY2syL993S0wFdNZNV0ypOc260KhQBGfoSIl0aV4GKSCP+mvB5L7Z0TGw==
X-Received: by 2002:a62:81c1:: with SMTP id t184mr85481313pfd.221.1558435796458;
        Tue, 21 May 2019 03:49:56 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id l21sm29029996pff.40.2019.05.21.03.49.52
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 21 May 2019 03:49:55 -0700 (PDT)
Date: Tue, 21 May 2019 19:49:49 +0900
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
Message-ID: <20190521104949.GE219653@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520035254.57579-5-minchan@kernel.org>
 <20190520142633.x5d27gk454qruc4o@butterfly.localdomain>
 <20190521012649.GE10039@google.com>
 <20190521063628.x2npirvs75jxjilx@butterfly.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190521063628.x2npirvs75jxjilx@butterfly.localdomain>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 21, 2019 at 08:36:28AM +0200, Oleksandr Natalenko wrote:
> Hi.
> 
> On Tue, May 21, 2019 at 10:26:49AM +0900, Minchan Kim wrote:
> > On Mon, May 20, 2019 at 04:26:33PM +0200, Oleksandr Natalenko wrote:
> > > Hi.
> > > 
> > > On Mon, May 20, 2019 at 12:52:51PM +0900, Minchan Kim wrote:
> > > > This patch factor out madvise's core functionality so that upcoming
> > > > patch can reuse it without duplication.
> > > > 
> > > > It shouldn't change any behavior.
> > > > 
> > > > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > > > ---
> > > >  mm/madvise.c | 168 +++++++++++++++++++++++++++------------------------
> > > >  1 file changed, 89 insertions(+), 79 deletions(-)
> > > > 
> > > > diff --git a/mm/madvise.c b/mm/madvise.c
> > > > index 9a6698b56845..119e82e1f065 100644
> > > > --- a/mm/madvise.c
> > > > +++ b/mm/madvise.c
> > > > @@ -742,7 +742,8 @@ static long madvise_dontneed_single_vma(struct vm_area_struct *vma,
> > > >  	return 0;
> > > >  }
> > > >  
> > > > -static long madvise_dontneed_free(struct vm_area_struct *vma,
> > > > +static long madvise_dontneed_free(struct task_struct *tsk,
> > > > +				  struct vm_area_struct *vma,
> > > >  				  struct vm_area_struct **prev,
> > > >  				  unsigned long start, unsigned long end,
> > > >  				  int behavior)
> > > > @@ -754,8 +755,8 @@ static long madvise_dontneed_free(struct vm_area_struct *vma,
> > > >  	if (!userfaultfd_remove(vma, start, end)) {
> > > >  		*prev = NULL; /* mmap_sem has been dropped, prev is stale */
> > > >  
> > > > -		down_read(&current->mm->mmap_sem);
> > > > -		vma = find_vma(current->mm, start);
> > > > +		down_read(&tsk->mm->mmap_sem);
> > > > +		vma = find_vma(tsk->mm, start);
> > > >  		if (!vma)
> > > >  			return -ENOMEM;
> > > >  		if (start < vma->vm_start) {
> > > > @@ -802,7 +803,8 @@ static long madvise_dontneed_free(struct vm_area_struct *vma,
> > > >   * Application wants to free up the pages and associated backing store.
> > > >   * This is effectively punching a hole into the middle of a file.
> > > >   */
> > > > -static long madvise_remove(struct vm_area_struct *vma,
> > > > +static long madvise_remove(struct task_struct *tsk,
> > > > +				struct vm_area_struct *vma,
> > > >  				struct vm_area_struct **prev,
> > > >  				unsigned long start, unsigned long end)
> > > >  {
> > > > @@ -836,13 +838,13 @@ static long madvise_remove(struct vm_area_struct *vma,
> > > >  	get_file(f);
> > > >  	if (userfaultfd_remove(vma, start, end)) {
> > > >  		/* mmap_sem was not released by userfaultfd_remove() */
> > > > -		up_read(&current->mm->mmap_sem);
> > > > +		up_read(&tsk->mm->mmap_sem);
> > > >  	}
> > > >  	error = vfs_fallocate(f,
> > > >  				FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
> > > >  				offset, end - start);
> > > >  	fput(f);
> > > > -	down_read(&current->mm->mmap_sem);
> > > > +	down_read(&tsk->mm->mmap_sem);
> > > >  	return error;
> > > >  }
> > > >  
> > > > @@ -916,12 +918,13 @@ static int madvise_inject_error(int behavior,
> > > >  #endif
> > > 
> > > What about madvise_inject_error() and get_user_pages_fast() in it
> > > please?
> > 
> > Good point. Maybe, there more places where assume context is "current" so
> > I'm thinking to limit hints we could allow from external process.
> > It would be better for maintainance point of view in that we could know
> > the workload/usecases when someone ask new advises from external process
> > without making every hints works both contexts.
> 
> Well, for madvise_inject_error() we still have a remote variant of
> get_user_pages(), and that should work, no?

Regardless of madvise_inject_error, it seems to be risky to expose all
of hints for external process, I think. For example, MADV_DONTNEED with
race, it's critical for stability. So, until we could get the way to
prevent the race, I want to restrict hints.

> 
> Regarding restricting the hints, I'm definitely interested in having
> remote MADV_MERGEABLE/MADV_UNMERGEABLE. But, OTOH, doing it via remote
> madvise() introduces another issue with traversing remote VMAs reliably.

How is it signifiact when the race happens? It could waste CPU cycle
and make unncessary break of that merged pages but expect it should be
rare so such non-desruptive hint could be exposed via process_madvise, I think.

If the hint is critical for the race, yes, as Michal suggested, we need a way
to close it and I guess non-cooperative userfaultfd with synchronous support
would help private anonymous vma.

> IIUC, one can do this via userspace by parsing [s]maps file only, which
> is not very consistent, and once some range is parsed, and then it is
> immediately gone, a wrong hint will be sent.
> 
> Isn't this a problem we should worry about?

I think it depends on the hint and usecase.

> 
> > 
> > Thanks.
> 
> -- 
>   Best regards,
>     Oleksandr Natalenko (post-factum)
>     Senior Software Maintenance Engineer

