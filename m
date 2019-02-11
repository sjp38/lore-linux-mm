Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA0F1C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 21:45:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5A93921855
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 21:45:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="USp2kFdW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5A93921855
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 02E4A8E016E; Mon, 11 Feb 2019 16:45:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF98E8E0165; Mon, 11 Feb 2019 16:45:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D9AB78E016E; Mon, 11 Feb 2019 16:45:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id A70E98E0165
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 16:45:18 -0500 (EST)
Received: by mail-ot1-f71.google.com with SMTP id j23so478227otl.6
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 13:45:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=IHB5000f+0jGPG331KCY3dFcs5NUkfAb7Nc5FDYKduk=;
        b=hm/I/tuXhhWnwRm9yuvucd/OOMKu6siRYfnB0mNtfj1Do8GNFOI/N24SZJiVa32uC9
         vxlE6sw0B0zatL/kid4zjQ/dP35eU+4uWwtNI2wR/8rveJCVz+6qkMlPK8nYushREJ+S
         ajgRti+ZBMlnsk8omIl0OcUX1Q+HP0Zop9Y8uN7ZjZ68K+FQ+Li/A0McG+XnWGke/6TL
         NAtn87NDE6fjDDbM1buH83915ckC1xO5ozJLW3PZk+A/8h/zag7iAOgyH9RY28HRuK4z
         T3jZu2mcHjUdpwZJBx3y9tzZEsit57ODf7JvKahfJO4TJL8LVg8b+k2zhxu+vtG3fKUF
         ywMQ==
X-Gm-Message-State: AHQUAuZ29T8zdZ8f/NbmmE+uRMSHQRHF5udnW4FPWMOyezOaUfyYK7Ed
	UHURejwnkyic6c+sAyXBSrAryigNKbtEzYx8l3i18qYUzopzkDXuI6dthiyAWhTu2Sj4PctAoZu
	69q/x7URPSDzqm9X+2QVpWT58KnWp68YoDGMYUfTVv8SNkQN8p0fctjgsoIlIRL/rKAxF/8tJoW
	HH265NXW4mcJsf3A1e1ge46+SaBUqAzCSUb69V1nFkcnHmhy0bEke1wfMviwAvBWlmOjkGVnAP8
	Z/tTo1hQY0+8/WbYDGTGiyJWFn+I+0Mfizeq598+itI1ekwKRcrofSMdcjhKJPJWH96DNJUcGfG
	kOEam71dyi4PIt3B2g8sP3tB53pzDHCZgkx/Ry15R/rR+ZLRchr4UNJzCvMwWqgc2pRW1CZeV9I
	T
X-Received: by 2002:a9d:7a5a:: with SMTP id z26mr76552otm.303.1549921518313;
        Mon, 11 Feb 2019 13:45:18 -0800 (PST)
X-Received: by 2002:a9d:7a5a:: with SMTP id z26mr76459otm.303.1549921516932;
        Mon, 11 Feb 2019 13:45:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549921516; cv=none;
        d=google.com; s=arc-20160816;
        b=A3xELYvsXuu8EdlNA66yKTEqb9ZN+prQRQXYvwvbb7O0Y80Q+wbNy5aVYrY3my21cd
         jrGOOIo93LfB5rOte7Oj73szGN2dVXN4RAsr4Ny38KcuqEhNY/K7GwGKeyxOODs0ybyz
         iPEhGO81Q1jMYYQ4H81O50lyDdvlzKWE+hlMDFtc/StunUmWCCELrYQrfuEpFnM472Sk
         aePUdos2lB6my6RJPYxBCKOadkc1Hn549tfvepEQENgzQxygjqFz6qq+CMIMRH29YDIg
         1wlqi7DO5BQARZE0z+rSHnzVMyaZOOWa01cPrRRKKD7c9zneNFmuYSc0W5UUPuPxMWx2
         qW0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=IHB5000f+0jGPG331KCY3dFcs5NUkfAb7Nc5FDYKduk=;
        b=jm36PZ1n8CG9zktWOZ6t3gZEuhNSOF2Hbx7baXrs43QMw9KJ0Ymd5ZdQr049ilJ9Mc
         Ecg8TmwKRj3xmzMa5FmCLjQ5rAYZoi7HWR7IzdHKV4Siyeh7qhQcVH92QKvPlD6J9/i9
         LY6bqdT/Va2nJd0A35qNbOyosj8FgzwzFRSfP/KgeK586bsPlMS9QbB8QftUNOefSZ0d
         NGGTY8DHw5yP984OwPRIimjodhrXvJgalS/WF3d/XZeW6zu365/NV8VQXgbZtN0F/UFY
         gN0jT2zWo1G8wEMpQdyixX+imEK9PJxbuxVG+qVaEq0daqMytcTMPSZFux6HmGcqKVxz
         oiRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=USp2kFdW;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l109sor6427727otc.139.2019.02.11.13.45.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 13:45:16 -0800 (PST)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=USp2kFdW;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=IHB5000f+0jGPG331KCY3dFcs5NUkfAb7Nc5FDYKduk=;
        b=USp2kFdWHkpFy9GUpyBwhgLeMsja1nZWVvt0FG3gUdhs9S1dJNB1ZiTyEPFgyPcdFX
         Wl5oewMW4P8WckqwWimQoo0GAybQSBEy7WlZ7aJEA4Dhn7zIjH2FiM4R/dESfLkUUdsQ
         8Fe5WNe3Jl2SrrihXSB7zzanWb8Dp9KSPz1omUWX2xSFR7fSjcr4csAgGKG323I24qvi
         sdd8V+zILguEI78fmKmGVPJVL7gmqenNr4PxzofQnGieeHYwz7SaGysjTF2oPigbFNEL
         aVrDCvOcwaIZBID3VpRG70H+/1e0QvrAg5NjyJ7KjsKYPLGFSZ5I0rhDzjBwMOAUMntv
         UAZw==
X-Google-Smtp-Source: AHgI3IZpQkO6Q7u1ap3EPTD5YgMYQRmpYMOLxGfMgPikgk5xOT344EyQQuXvrc/AMI8dXXhiGGtGDj5KB9mrXR9EHA4=
X-Received: by 2002:a9d:6a50:: with SMTP id h16mr328208otn.95.1549921516543;
 Mon, 11 Feb 2019 13:45:16 -0800 (PST)
MIME-Version: 1.0
References: <20190211201643.7599-1-ira.weiny@intel.com> <20190211201643.7599-3-ira.weiny@intel.com>
 <20190211203916.GA2771@ziepe.ca> <bcc03ee1-4c42-48c3-bc67-942c0f04875e@nvidia.com>
 <20190211212652.GA7790@iweiny-DESK2.sc.intel.com> <fc9c880b-24f8-7063-6094-00175bc27f7d@nvidia.com>
In-Reply-To: <fc9c880b-24f8-7063-6094-00175bc27f7d@nvidia.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 11 Feb 2019 13:45:05 -0800
Message-ID: <CAPcyv4iEqYRzFgu4oqS8J+MtOuBrq6Dx7C7tcWZLj0C0ML9LQw@mail.gmail.com>
Subject: Re: [PATCH 2/3] mm/gup: Introduce get_user_pages_fast_longterm()
To: John Hubbard <jhubbard@nvidia.com>
Cc: Ira Weiny <ira.weiny@intel.com>, Jason Gunthorpe <jgg@ziepe.ca>, 
	linux-rdma <linux-rdma@vger.kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Daniel Borkmann <daniel@iogearbox.net>, Davidlohr Bueso <dave@stgolabs.net>, 
	Netdev <netdev@vger.kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, 
	Dennis Dalessandro <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, 
	Andrew Morton <akpm@linux-foundation.org>, 
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 1:39 PM John Hubbard <jhubbard@nvidia.com> wrote:
>
> On 2/11/19 1:26 PM, Ira Weiny wrote:
> > On Mon, Feb 11, 2019 at 01:13:56PM -0800, John Hubbard wrote:
> >> On 2/11/19 12:39 PM, Jason Gunthorpe wrote:
> >>> On Mon, Feb 11, 2019 at 12:16:42PM -0800, ira.weiny@intel.com wrote:
> >>>> From: Ira Weiny <ira.weiny@intel.com>
> >> [...]
> >> It seems to me that the longterm vs. short-term is of questionable value.
> >
> > This is exactly why I did not post this before.  I've been waiting our other
> > discussions on how GUP pins are going to be handled to play out.  But with the
> > netdev thread today[1] it seems like we need to make sure we have a "safe" fast
> > variant for a while.  Introducing FOLL_LONGTERM seemed like the cleanest way to
> > do that even if we will not need the distinction in the future...  :-(
>
> Yes, I agree. Below...
>
> > [...]
> > This is also why I did not change the get_user_pages_longterm because we could
> > be ripping this all out by the end of the year...  (I hope. :-)
> >
> > So while this does "pollute" the GUP family of calls I'm hoping it is not
> > forever.
> >
> > Ira
> >
> > [1] https://lkml.org/lkml/2019/2/11/1789
> >
>
> Yes, and to be clear, I think your patchset here is fine. It is easy to find
> the FOLL_LONGTERM callers if and when we want to change anything. I just think
> also it's appopriate to go a bit further, and use FOLL_LONGTERM all by itself.
>
> That's because in either design outcome, it's better that way:
>
> -- If we keep the concept of "I'm a long-term gup call site", then FOLL_LONGTERM
> is just right. The gup API already has _fast and non-fast variants, and once
> you get past a couple, you end up with a multiplication of names that really
> work better as flags. We're there.
>
> -- If we drop the concept, then you've already done part of the work, by removing
> the _longterm API variants.
>

A problem I now see with the _longterm name is that it hides its true
intent. It's really a "dax can't use page cache tricks to make it seem
like this page is ok to access indefinitely, if the system needs this
page back your pin would prevent the forward progress of the system
state.". If the discussion results in a need to have an explicit file
state (immutable or lease) then we'll continue to need a gup pin type
distinction. If the discussion resolves to one of the silent options
(fail truncate, lie about truncate) then FOLL_LONGTERM might be able
to die at that point.

