Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.5 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA033C43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 22:08:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 811BA2075E
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 22:08:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 811BA2075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DAF496B000C; Thu, 28 Mar 2019 18:08:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D5F836B0266; Thu, 28 Mar 2019 18:08:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4E416B0274; Thu, 28 Mar 2019 18:08:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id A6DDC6B000C
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 18:08:29 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id d131so66040qkc.18
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 15:08:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=h0wVGhGqMdrTppX6tkD5HPWg1t6S6OIyRNqJBAvAd+g=;
        b=tU7TWr3sRYb4KbTNVILw1BVnRWxnqC2N/SFqhNkP2ix1hai2kR3ZJAOsiEEuIqUMP0
         FYvdq8ng+ks0kcwgr+9SfMA6ZYG5dbVVJApIIQni5jsHe4FCx0mZXZU13UM0ef4ySXKt
         dk++LXVw1LK/2kf7PPJX4u5pauwPNrI0fccwg7v32MwTc7ks9wMIOZfVuFoyIw+qENGv
         dbLSL4CnD0Lan3rLOsWZ0qOw1Avsr97k9VmncY1xfJWdfE1cS6ydwbjfrU0Qp/Nr3LAi
         OMRb9QB7cYNM4pEpyHT3UJl1doEdiHorDr5I2E6JqsaPsvwKX34wpmGOQRUutk4OZT57
         gdIQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXkF5jsmORxuH2aZ+7d+PDvI2J7pCT6Z95ec6qgbbcjzOeQKOBA
	UwP55qciYp5/r6Myah0lokKsU2GOfN5uKq7m+N710E4pApEgFOQqXTHDh92yP2crEYN5DP+uzYA
	qGhRASrNnVYldnGbiozP1Tn+8qb+L5Jrsm6gzs1OAAyiodmksAZ2y/i+t0ePXbXIlqg==
X-Received: by 2002:a37:b005:: with SMTP id z5mr35426290qke.119.1553810909437;
        Thu, 28 Mar 2019 15:08:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzbyFv7ozCzgMp0P2GN6QNVfwxwQpWHsYeAMR1F0EhskXaQ1WL7hAn3iqmIe3699g5k/Rm7
X-Received: by 2002:a37:b005:: with SMTP id z5mr35426242qke.119.1553810908737;
        Thu, 28 Mar 2019 15:08:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553810908; cv=none;
        d=google.com; s=arc-20160816;
        b=0eXrzWgAgqFxTOqcRAd9G5QSH6iTcPitjDzk9em34kbVOCe3C/GhhpkJ3gCauMblGZ
         1rxsZs7dJZJAMh3NBe1a2V84JbHZuSRg52Ik4Pdyeu1J3DjRXxViZzx4MbwRpaYj+/zi
         eeTp96CQOaBI+ENsvbKZsqiC5angwy2Rpx9benavgjB5PJI1iX5BLs0zaJohmHrx8pzm
         U0pVhL+uSwkg18KJTp6i/JyHb/nSRJefAaeiNDScaqI96P2TIWoZltZXlezpd3dTP4Dc
         ELe4VvpJZT7WBTYaDBowlFsdXCU8IKiBEYH0nCAB5sZ6kK/IdTaDRbCjYldBbUD+dQNv
         YhUQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=h0wVGhGqMdrTppX6tkD5HPWg1t6S6OIyRNqJBAvAd+g=;
        b=E7jPzjjZ6fDk8OqwDun3Cz+kJAlvD29/fqKPMae4dwlXDHdrj64XobsYZ+zzpd4bpV
         qfB77B+DpUaapa4okK+b1fgwajSF+vSkHYn6o/lonPAuryvOM3qksg7ltUhA0uhM0jnK
         0ES4MUhU9pF94BVJ6z0ZkVdfeevGcMc8bZJHkyukp7ySXQP6YuETI6FFN/YZmQIrkOsY
         oNiVBjsaCR1yOTYuY3bH0XTelQDsi19InZmcwQIS9GSHq2N92ny3GIazmqLNtc+pyusO
         kHAvTE4tIfCvSnAS1jmkfpiRvmkstUgGH+RwQjgYN4lrWXsI0V8YYrwH3x4BB81pmbnG
         Vu6g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o32si133232qte.347.2019.03.28.15.08.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Mar 2019 15:08:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 8B6A73082AF0;
	Thu, 28 Mar 2019 22:08:27 +0000 (UTC)
Received: from redhat.com (ovpn-121-118.rdu2.redhat.com [10.10.121.118])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A056D5D961;
	Thu, 28 Mar 2019 22:08:26 +0000 (UTC)
Date: Thu, 28 Mar 2019 18:08:24 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH v2 10/11] mm/hmm: add helpers for driver to safely take
 the mmap_sem v2
Message-ID: <20190328220824.GE13560@redhat.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
 <20190325144011.10560-11-jglisse@redhat.com>
 <9df742eb-61ca-3629-a5f4-8ad1244ff840@nvidia.com>
 <20190328213047.GB13560@redhat.com>
 <a16efd42-3e2b-1b72-c205-0c2659de2750@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <a16efd42-3e2b-1b72-c205-0c2659de2750@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Thu, 28 Mar 2019 22:08:27 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Mar 28, 2019 at 02:41:02PM -0700, John Hubbard wrote:
> On 3/28/19 2:30 PM, Jerome Glisse wrote:
> > On Thu, Mar 28, 2019 at 01:54:01PM -0700, John Hubbard wrote:
> >> On 3/25/19 7:40 AM, jglisse@redhat.com wrote:
> >>> From: Jérôme Glisse <jglisse@redhat.com>
> >>>
> >>> The device driver context which holds reference to mirror and thus to
> >>> core hmm struct might outlive the mm against which it was created. To
> >>> avoid every driver to check for that case provide an helper that check
> >>> if mm is still alive and take the mmap_sem in read mode if so. If the
> >>> mm have been destroy (mmu_notifier release call back did happen) then
> >>> we return -EINVAL so that calling code knows that it is trying to do
> >>> something against a mm that is no longer valid.
> >>>
> >>> Changes since v1:
> >>>     - removed bunch of useless check (if API is use with bogus argument
> >>>       better to fail loudly so user fix their code)
> >>>
> >>> Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
> >>> Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
> >>> Cc: Andrew Morton <akpm@linux-foundation.org>
> >>> Cc: John Hubbard <jhubbard@nvidia.com>
> >>> Cc: Dan Williams <dan.j.williams@intel.com>
> >>> ---
> >>>  include/linux/hmm.h | 50 ++++++++++++++++++++++++++++++++++++++++++---
> >>>  1 file changed, 47 insertions(+), 3 deletions(-)
> >>>
> >>> diff --git a/include/linux/hmm.h b/include/linux/hmm.h
> >>> index f3b919b04eda..5f9deaeb9d77 100644
> >>> --- a/include/linux/hmm.h
> >>> +++ b/include/linux/hmm.h
> >>> @@ -438,6 +438,50 @@ struct hmm_mirror {
> >>>  int hmm_mirror_register(struct hmm_mirror *mirror, struct mm_struct *mm);
> >>>  void hmm_mirror_unregister(struct hmm_mirror *mirror);
> >>>  
> >>> +/*
> >>> + * hmm_mirror_mm_down_read() - lock the mmap_sem in read mode
> >>> + * @mirror: the HMM mm mirror for which we want to lock the mmap_sem
> >>> + * Returns: -EINVAL if the mm is dead, 0 otherwise (lock taken).
> >>> + *
> >>> + * The device driver context which holds reference to mirror and thus to core
> >>> + * hmm struct might outlive the mm against which it was created. To avoid every
> >>> + * driver to check for that case provide an helper that check if mm is still
> >>> + * alive and take the mmap_sem in read mode if so. If the mm have been destroy
> >>> + * (mmu_notifier release call back did happen) then we return -EINVAL so that
> >>> + * calling code knows that it is trying to do something against a mm that is
> >>> + * no longer valid.
> >>> + */
> >>> +static inline int hmm_mirror_mm_down_read(struct hmm_mirror *mirror)
> >>
> >> Hi Jerome,
> >>
> >> Let's please not do this. There are at least two problems here:
> >>
> >> 1. The hmm_mirror_mm_down_read() wrapper around down_read() requires a 
> >> return value. This is counter to how locking is normally done: callers do
> >> not normally have to check the return value of most locks (other than
> >> trylocks). And sure enough, your own code below doesn't check the return value.
> >> That is a pretty good illustration of why not to do this.
> > 
> > Please read the function description this is not about checking lock
> > return value it is about checking wether we are racing with process
> > destruction and avoid trying to take lock in such cases so that driver
> > do abort as quickly as possible when a process is being kill.
> > 
> >>
> >> 2. This is a weird place to randomly check for semi-unrelated state, such 
> >> as "is HMM still alive". By that I mean, if you have to detect a problem
> >> at down_read() time, then the problem could have existed both before and
> >> after the call to this wrapper. So it is providing a false sense of security,
> >> and it is therefore actually undesirable to add the code.
> > 
> > It is not, this function is use in device page fault handler which will
> > happens asynchronously from CPU event or process lifetime when a process
> > is killed or is dying we do want to avoid useless page fault work and
> > we do want to avoid blocking the page fault queue of the device. This
> > function reports to the caller that the process is dying and that it
> > should just abort the page fault and do whatever other device specific
> > thing that needs to happen.
> > 
> 
> But it's inherently racy, to check for a condition outside of any lock, so again,
> it's a false sense of security.

Yes and race are fine here, this is to avoid useless work if we are
unlucky and we race and fail to see the destruction that is just
happening then it is fine we are just going to do useless work. So
we do not care about race here we just want to bailout early if we
can witness the process dying.

> 
> >>
> >> If you insist on having this wrapper, I think it should have approximately 
> >> this form:
> >>
> >> void hmm_mirror_mm_down_read(...)
> >> {
> >> 	WARN_ON(...)
> >> 	down_read(...)
> >> } 
> > 
> > I do insist as it is useful and use by both RDMA and nouveau and the
> > above would kill the intent. The intent is do not try to take the lock
> > if the process is dying.
> 
> Could you provide me a link to those examples so I can take a peek? I
> am still convinced that this whole thing is a race condition at best.

The race is fine and ok see:

https://cgit.freedesktop.org/~glisse/linux/commit/?h=hmm-odp-v2&id=eebd4f3095290a16ebc03182e2d3ab5dfa7b05ec

which has been posted and i think i provided a link in the cover
letter to that post. The same patch exist for nouveau i need to
cleanup that tree and push it.

> > 
> > 
> >>
> >>> +{
> >>> +	struct mm_struct *mm;
> >>> +
> >>> +	/* Sanity check ... */
> >>> +	if (!mirror || !mirror->hmm)
> >>> +		return -EINVAL;
> >>> +	/*
> >>> +	 * Before trying to take the mmap_sem make sure the mm is still
> >>> +	 * alive as device driver context might outlive the mm lifetime.
> >>
> >> Let's find another way, and a better place, to solve this problem.
> >> Ref counting?
> > 
> > This has nothing to do with refcount or use after free or anthing
> > like that. It is just about checking wether we are about to do
> > something pointless. If the process is dying then it is pointless
> > to try to take the lock and it is pointless for the device driver
> > to trigger handle_mm_fault().
> 
> Well, what happens if you let such pointless code run anyway? 
> Does everything still work? If yes, then we don't need this change.
> If no, then we need a race-free version of this change.

Yes everything work, nothing bad can happen from a race, it will just
do useless work which never hurt anyone.

Cheers,
Jérôme

