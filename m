Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 167C4C10F07
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 23:10:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A46C3218D8
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 23:10:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A46C3218D8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E04B08E0044; Wed, 20 Feb 2019 18:09:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB25D8E0002; Wed, 20 Feb 2019 18:09:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC96E8E0044; Wed, 20 Feb 2019 18:09:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id A2E548E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 18:09:59 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id 207so3945604qkl.2
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 15:09:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=CKiKYIFTPjS4+739HXLPuvYCxjTmRU3HXrabUqH2Q0g=;
        b=BagLWYaB3/y2zTU4Agwr4fhA6gC02VD0hQagvewuZfO44/RSxRhDMM5Ffqbh/P2FHy
         nJ6YJp+oWTlkJANvEOsZmUMO1RLdXErlYExR3eQCgBvP1ipgmzKeslaGo5/6sdN7p0Dp
         aPeD+IyKuhKdD7y0nOsdCn8n+T/8pj7KUHufDVkwze1bAbytN2a8lgPgUwDcVwLbZi84
         ch/WnnPmcpjpwNL/pQ7RGb0C3HzECwr/VMo84sWcAI99TcrMa2n9+f+d/zrH9V4QgqTV
         jiMmWBBhlROdAO+V/M+lsLm98lvULgRFws7v1nuNfCD46JLYc2oHZcdqvZdSooRIN9Q0
         bx1A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubhhbhORpCRYzqhmFFuhMrUUGE4B3wVfC62YKDNtezEZfheVdbD
	CYBqxPbIOtOGduqg+q2ENcAm6SjXEnMN3NPqzPbYqgLUM1FWwRUSNN/Wa+93MJRS+bMQSFt2sy/
	QWhvptet7yoj5ppElF3RMkQ3xNHaQnd4NH7DzZpZcmwvdPhJcurhV3uHsLs6DaRR3Jw==
X-Received: by 2002:a0c:b527:: with SMTP id d39mr27666979qve.201.1550704199264;
        Wed, 20 Feb 2019 15:09:59 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZDjWujqe4dZ93mqx5eLn9CLO/X+wRIy8le1nVtfyZf99SZ931HcmmCyVn04egjMzZa4WE5
X-Received: by 2002:a0c:b527:: with SMTP id d39mr27666937qve.201.1550704198503;
        Wed, 20 Feb 2019 15:09:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550704198; cv=none;
        d=google.com; s=arc-20160816;
        b=zrc3lhbyP8JBI7MpvuopNdronRij6eQdrPw/IFbpZAKPcy47TAZ3GHYKBoJPymcT2A
         GfX3Zu3SB6k/cWy7x1ivvBd5RL7YP2513YL6XeceZgXCobSrXqPgtaT+6u28EqxbQyaR
         rOvTOyo8RH6CRuUGOp0i+zUXND2aNubpm4OA0wAKdryc2awZRv1XCyADj0UVdM+WSuUt
         QGKcw+q1Z85nc2s7fz9yHGZ+g6elAZcba1fLZIjpTSqCg9bOTGvh6RB+DBcu9Js449it
         UHk9HGGbyesJnmECqUNr4e6mwm7luqKFRazE6HYpTYamQeq1J6wt4ZO5qAu3FLMHvaEk
         zWpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=CKiKYIFTPjS4+739HXLPuvYCxjTmRU3HXrabUqH2Q0g=;
        b=Dfyi3xPrq4eLSHrrCAv6fXu2/nuwhJ4HYnjaCpwZGqqSHMeV1ZMWrHZM14OZLGEa+6
         1x3lomMYDCLBF5WMNBFu2arlvOwqxt4GecFLC2koYSqT7MTYINarmEMUG4m9i3bkgtTN
         u8+WV3GDaVej6ZwdFLBUY8AZRrZ/8R0FzSJPvn1LoZ0xM3AaxnzJwhDdGpgN4+u1LcuQ
         BdNtZxNMLVui1tG93YfwzSnW/564URU4mPA0V50mHws6GfrNev3+2y1QxT3VEufqWKqv
         qaRHFgsKv9D9cZ0E+F4RVExKYeVMsdcOPQy7hkyQ+jTVamKwHTpcMcccMWNFI7smaRkE
         lwAw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g4si586492qki.69.2019.02.20.15.09.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 15:09:58 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 486483091740;
	Wed, 20 Feb 2019 23:09:57 +0000 (UTC)
Received: from redhat.com (ovpn-120-249.rdu2.redhat.com [10.10.120.249])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 5DC145D9D2;
	Wed, 20 Feb 2019 23:09:56 +0000 (UTC)
Date: Wed, 20 Feb 2019 18:09:54 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>
Subject: Re: [PATCH 10/10] mm/hmm: add helpers for driver to safely take the
 mmap_sem
Message-ID: <20190220230954.GA11325@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
 <20190129165428.3931-11-jglisse@redhat.com>
 <16e62992-c937-6b05-ae37-a287294c0005@nvidia.com>
 <20190220221933.GB29398@redhat.com>
 <41888fd2-6154-4f85-7949-7a59c434d047@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <41888fd2-6154-4f85-7949-7a59c434d047@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Wed, 20 Feb 2019 23:09:57 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 02:40:20PM -0800, John Hubbard wrote:
> On 2/20/19 2:19 PM, Jerome Glisse wrote:
> > On Wed, Feb 20, 2019 at 01:59:13PM -0800, John Hubbard wrote:
> > > On 1/29/19 8:54 AM, jglisse@redhat.com wrote:
> > > > From: Jérôme Glisse <jglisse@redhat.com>
> > > > 
> > > > The device driver context which holds reference to mirror and thus to
> > > > core hmm struct might outlive the mm against which it was created. To
> > > > avoid every driver to check for that case provide an helper that check
> > > > if mm is still alive and take the mmap_sem in read mode if so. If the
> > > > mm have been destroy (mmu_notifier release call back did happen) then
> > > > we return -EINVAL so that calling code knows that it is trying to do
> > > > something against a mm that is no longer valid.
> > > > 
> > > > Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> > > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > > Cc: Ralph Campbell <rcampbell@nvidia.com>
> > > > Cc: John Hubbard <jhubbard@nvidia.com>
> > > > ---
> > > >    include/linux/hmm.h | 50 ++++++++++++++++++++++++++++++++++++++++++---
> > > >    1 file changed, 47 insertions(+), 3 deletions(-)
> > > > 
> > > > diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> > > > index b3850297352f..4a1454e3efba 100644
> > > > --- a/include/linux/hmm.h
> > > > +++ b/include/linux/hmm.h
> > > > @@ -438,6 +438,50 @@ struct hmm_mirror {
> > > >    int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm);
> > > >    void hmm_mirror_unregister(struct hmm_mirror *mirror);
> > > > +/*
> > > > + * hmm_mirror_mm_down_read() - lock the mmap_sem in read mode
> > > > + * @mirror: the HMM mm mirror for which we want to lock the mmap_sem
> > > > + * Returns: -EINVAL if the mm is dead, 0 otherwise (lock taken).
> > > > + *
> > > > + * The device driver context which holds reference to mirror and thus to core
> > > > + * hmm struct might outlive the mm against which it was created. To avoid every
> > > > + * driver to check for that case provide an helper that check if mm is still
> > > > + * alive and take the mmap_sem in read mode if so. If the mm have been destroy
> > > > + * (mmu_notifier release call back did happen) then we return -EINVAL so that
> > > > + * calling code knows that it is trying to do something against a mm that is
> > > > + * no longer valid.
> > > > + */
> > > 
> > > Hi Jerome,
> > > 
> > > Are you thinking that, throughout the HMM API, there is a problem that
> > > the mm may have gone away, and so driver code needs to be littered with
> > > checks to ensure that mm is non-NULL? If so, why doesn't HMM take a
> > > reference on mm->count?
> > > 
> > > This solution here cannot work. I think you'd need refcounting in order
> > > to avoid this kind of problem. Just doing a check will always be open to
> > > races (see below).
> > > 
> > > 
> > > > +static inline int hmm_mirror_mm_down_read(struct hmm_mirror *mirror)
> > > > +{
> > > > +	struct mm_struct *mm;
> > > > +
> > > > +	/* Sanity check ... */
> > > > +	if (!mirror || !mirror->hmm)
> > > > +		return -EINVAL;
> > > > +	/*
> > > > +	 * Before trying to take the mmap_sem make sure the mm is still
> > > > +	 * alive as device driver context might outlive the mm lifetime.
> > > > +	 *
> > > > +	 * FIXME: should we also check for mm that outlive its owning
> > > > +	 * task ?
> > > > +	 */
> > > > +	mm = READ_ONCE(mirror->hmm->mm);
> > > > +	if (mirror->hmm->dead || !mm)
> > > > +		return -EINVAL;
> > > > +
> > > 
> > > Nothing really prevents mirror->hmm->mm from changing to NULL right here.
> > 
> > This is really just to catch driver mistake, if driver does not call
> > hmm_mirror_unregister() then the !mm will never be true ie the
> > mirror->hmm->mm can not go NULL until the last reference to hmm_mirror
> > is gone.
> 
> In that case, then this again seems unnecessary, and in fact undesirable.
> If the driver code has a bug, then let's let the backtrace from a NULL
> dereference just happen, loud and clear.
> 
> This patch, at best, hides bugs. And it adds code that should simply be
> unnecessary, so I don't like it. :)  Let's make it go away.
> 
> > 
> > > 
> > > > +	down_read(&mm->mmap_sem);
> > > > +	return 0;
> > > > +}
> > > > +
> > > 
> > > ...maybe better to just drop this patch from the series, until we see a
> > > pattern of uses in the calling code.
> > 
> > It use by nouveau now.
> 
> Maybe you'd have to remove that use case in a couple steps, depending on the
> order that patches are going in.

Well all that is needed is removing if (mirror->hmm->dead || !mm) return -EINVAL;
from functions so it does not have any ordering conflict with anything really.

Cheers,
Jérôme

