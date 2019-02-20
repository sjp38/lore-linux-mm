Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EBECFC43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 22:19:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A97E520859
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 22:19:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A97E520859
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43F578E003C; Wed, 20 Feb 2019 17:19:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C5718E0002; Wed, 20 Feb 2019 17:19:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 268A58E003C; Wed, 20 Feb 2019 17:19:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id E9CAA8E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 17:19:37 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id x63so3836742qka.5
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 14:19:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=Wy/mL2VQEulOHFfA+mQr9/7a6/AAOegXi2ilgUD+yWw=;
        b=bbvp1vbDWE/rPxPrMGsMfddIxvRO8i2PDI9cF6SK+2qgYlNHrqSHl/FvrwJ2SmXLGS
         f/D4s+N87kUW0Z01kdDlu1258xLfZT6zZkHLugAjISYE5Hx/xS5GVkyGdHXGzbx/nKUZ
         wP2S2GDUwrqoy5sJtRyjlpEDSR099c4lCOCbhNN6hgzxSKm5il9wKXwsaOqjfmDyWfp0
         PYNet89/dPkn7ofkQZ78wGJaiMBXevDstHjeDKZbV71kF46vWpjEY2mpAm2xBd/hA40W
         d0ypgF2co0xJa4mU5/XSzijwN+gCjlM5qKSabEeA3fPZnbpunwpJhvTBMEVrTRNiaQTi
         lexg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuYcv+0bS6ryV4BSuW9blwhJj0z4t/o/numwHi66PPNnk4q687BL
	liaMDG/jH/sTDEcQXreM/C4o3KAZMCjhqQxEI3hti+GgJnBWnvFCn8CUAP8PLn3Ag9/gWACbAkQ
	UwhqW+ORjqT1HkpGAr08g4pftGL237axzU+WzE+svjWBaI/UFYZU/whtV3tQhv+WajQ==
X-Received: by 2002:a37:6744:: with SMTP id b65mr2983739qkc.162.1550701177696;
        Wed, 20 Feb 2019 14:19:37 -0800 (PST)
X-Google-Smtp-Source: AHgI3IY6yeFRuudl6ah5loIC9vcM8FztmhnMFgx7kh5pgMt6+qzjZIm7Wf/JQpTZn4bEdIrx/cYG
X-Received: by 2002:a37:6744:: with SMTP id b65mr2983713qkc.162.1550701177074;
        Wed, 20 Feb 2019 14:19:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550701177; cv=none;
        d=google.com; s=arc-20160816;
        b=Lpn3Yez48UfLNqnwFjqc69SC97x7zmbdkwRjYc9ZdFFJ6bjC2BNB8smsOSI63v2FBe
         37AfZNTNPP9H1gzq4aR4b3s3uqhh2b0x4+FLH9TZcrtRHr4wYUjby8AtVaMtJWUJBwgh
         DlW9m4hRofOrib46GqyrDKg0+5EiKJcXlqQPX59TT4hB2kzysvpkeO/1AkguN9OmwA6F
         GbVbqxVxlL/rLWSxFsAXXalHiDsVY0gcSSq/W+KMitP25poN8IpRTFJzqgu6e+S5D6RZ
         yzu7n9UjIxggji/gtGHHZ8s5sTlfSjR9Z5NEItbZFVtAGSy4ak7MBW1Q7KOCdbgS05Ep
         aj+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=Wy/mL2VQEulOHFfA+mQr9/7a6/AAOegXi2ilgUD+yWw=;
        b=yTaLagBBnJjyZzkKtEzip45XhM9zkCEOXx5uA7lQ2PmAcTLLt5a6HWmgOUHNlRpiHW
         GCswGLbEYpM04WGP8WRHUePHoU4Y2K3ra7fuisc1vuAq0cGeAQnJ/n/6OSAyW+1YV7BE
         7kPeqyEht528FT7DWkoUHrOWJLwvXCG6luzxDmrfkgKBoRC6GVKlFxO0pMhUqLS9Lv2Z
         bzbJ1WsxtDBnkbLihAQt8Jl7pxjAdFZGzU6fMZ02wHn6Cf+vNw0G+Xs9huvpzFrL7+uz
         pKLIu5oQDehqT5xBUCPoeyQ6r4z5rhGrAT+4+wcOqQSAbAvTq7SQkt3gTEBc+uUJWkUS
         OtQg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m12si3864209qkl.250.2019.02.20.14.19.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 14:19:37 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 4210D8552A;
	Wed, 20 Feb 2019 22:19:36 +0000 (UTC)
Received: from redhat.com (ovpn-121-220.rdu2.redhat.com [10.10.121.220])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 8256F5D9D2;
	Wed, 20 Feb 2019 22:19:35 +0000 (UTC)
Date: Wed, 20 Feb 2019 17:19:33 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>
Subject: Re: [PATCH 10/10] mm/hmm: add helpers for driver to safely take the
 mmap_sem
Message-ID: <20190220221933.GB29398@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
 <20190129165428.3931-11-jglisse@redhat.com>
 <16e62992-c937-6b05-ae37-a287294c0005@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <16e62992-c937-6b05-ae37-a287294c0005@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Wed, 20 Feb 2019 22:19:36 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 01:59:13PM -0800, John Hubbard wrote:
> On 1/29/19 8:54 AM, jglisse@redhat.com wrote:
> > From: Jérôme Glisse <jglisse@redhat.com>
> > 
> > The device driver context which holds reference to mirror and thus to
> > core hmm struct might outlive the mm against which it was created. To
> > avoid every driver to check for that case provide an helper that check
> > if mm is still alive and take the mmap_sem in read mode if so. If the
> > mm have been destroy (mmu_notifier release call back did happen) then
> > we return -EINVAL so that calling code knows that it is trying to do
> > something against a mm that is no longer valid.
> > 
> > Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Ralph Campbell <rcampbell@nvidia.com>
> > Cc: John Hubbard <jhubbard@nvidia.com>
> > ---
> >   include/linux/hmm.h | 50 ++++++++++++++++++++++++++++++++++++++++++---
> >   1 file changed, 47 insertions(+), 3 deletions(-)
> > 
> > diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> > index b3850297352f..4a1454e3efba 100644
> > --- a/include/linux/hmm.h
> > +++ b/include/linux/hmm.h
> > @@ -438,6 +438,50 @@ struct hmm_mirror {
> >   int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm);
> >   void hmm_mirror_unregister(struct hmm_mirror *mirror);
> > +/*
> > + * hmm_mirror_mm_down_read() - lock the mmap_sem in read mode
> > + * @mirror: the HMM mm mirror for which we want to lock the mmap_sem
> > + * Returns: -EINVAL if the mm is dead, 0 otherwise (lock taken).
> > + *
> > + * The device driver context which holds reference to mirror and thus to core
> > + * hmm struct might outlive the mm against which it was created. To avoid every
> > + * driver to check for that case provide an helper that check if mm is still
> > + * alive and take the mmap_sem in read mode if so. If the mm have been destroy
> > + * (mmu_notifier release call back did happen) then we return -EINVAL so that
> > + * calling code knows that it is trying to do something against a mm that is
> > + * no longer valid.
> > + */
> 
> Hi Jerome,
> 
> Are you thinking that, throughout the HMM API, there is a problem that
> the mm may have gone away, and so driver code needs to be littered with
> checks to ensure that mm is non-NULL? If so, why doesn't HMM take a
> reference on mm->count?
> 
> This solution here cannot work. I think you'd need refcounting in order
> to avoid this kind of problem. Just doing a check will always be open to
> races (see below).
> 
> 
> > +static inline int hmm_mirror_mm_down_read(struct hmm_mirror *mirror)
> > +{
> > +	struct mm_struct *mm;
> > +
> > +	/* Sanity check ... */
> > +	if (!mirror || !mirror->hmm)
> > +		return -EINVAL;
> > +	/*
> > +	 * Before trying to take the mmap_sem make sure the mm is still
> > +	 * alive as device driver context might outlive the mm lifetime.
> > +	 *
> > +	 * FIXME: should we also check for mm that outlive its owning
> > +	 * task ?
> > +	 */
> > +	mm = READ_ONCE(mirror->hmm->mm);
> > +	if (mirror->hmm->dead || !mm)
> > +		return -EINVAL;
> > +
> 
> Nothing really prevents mirror->hmm->mm from changing to NULL right here.

This is really just to catch driver mistake, if driver does not call
hmm_mirror_unregister() then the !mm will never be true ie the
mirror->hmm->mm can not go NULL until the last reference to hmm_mirror
is gone.

> 
> > +	down_read(&mm->mmap_sem);
> > +	return 0;
> > +}
> > +
> 
> ...maybe better to just drop this patch from the series, until we see a
> pattern of uses in the calling code.

It use by nouveau now.

Cheers,
Jérôme

