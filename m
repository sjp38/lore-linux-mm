Return-Path: <SRS0=TqY8=VP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1,USER_IN_DEF_DKIM_WL autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3AACC76196
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 22:07:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65F272184E
	for <linux-mm@archiver.kernel.org>; Thu, 18 Jul 2019 22:07:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="W1DjZwMa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65F272184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EF2E76B0003; Thu, 18 Jul 2019 18:07:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EA3A08E0003; Thu, 18 Jul 2019 18:07:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D6AFC8E0001; Thu, 18 Jul 2019 18:07:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id AED306B0003
	for <linux-mm@kvack.org>; Thu, 18 Jul 2019 18:07:10 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id e25so17420481pfn.5
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 15:07:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :in-reply-to:message-id:references:user-agent:mime-version;
        bh=+Jwz3mP3TVVRwA+8/Iil5EIlfG8Tly5xGOIwN4hmUt4=;
        b=iwLnNj8+GSFQWPCcyPIAqH8aGG4vVoChyrbhSNi+SE4lq81ha/ciEZa8hIOkPwl8MB
         a5Y1As6TcEYh4o2BWssg+n6DX0tNn81JoYe6jC8Q72h+6wtLg81HycrnJKV9oZclYHSG
         jhhPBAVqYuH8+Dpn21dRRQjV/vAGBBS8oIT+OYpb8stz72ZWzAffOT0ieVF+9+GmrxjG
         omDMGgbwc0jV7CDWdx6g8tVEmOvXkrQNO0GeaezHZqftxuLDPDU7xu5U8z2+yknBuyu8
         CEFaXsx6a4XtPpA3Pr9ScxF27NL21ukRFEaTmoFFxaLKmBdaA2N6cBWjgA2MiH2I9Hs5
         f2ig==
X-Gm-Message-State: APjAAAX0Esb9knp129/cjR26+H/pM49BZSyWeW2QyKnk4T+bmrTtW6Up
	iwdjI5/3cMdWTi0bVbPF0OlmmRZv2JjtmG0yqbkgBN4GcSH6bd9Y01AXbIPuAKrQVpjDoWan85V
	qZrutE1fFqNzESskmYkaZI0qr9gJmGWhjyFKeN9Uf2F+CTRAW7WBdUXZgjvAqewH6vQ==
X-Received: by 2002:a63:4554:: with SMTP id u20mr51379566pgk.406.1563487630229;
        Thu, 18 Jul 2019 15:07:10 -0700 (PDT)
X-Received: by 2002:a63:4554:: with SMTP id u20mr51379526pgk.406.1563487629553;
        Thu, 18 Jul 2019 15:07:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563487629; cv=none;
        d=google.com; s=arc-20160816;
        b=f96RsM5LiQ3T6InvI8mKETJABRdz8YdX9EZX6862eRw/j/o3Hk9Dq4Yo5tCYzpKG3D
         nJod4+k+fy7b4ZV5S7JQRaM1oV17oRAV6+BAMTdRuW5umzZJUureYLtojWo6gCiRNtp+
         6wGc+HEHff90G6/xr2d4fZ4mtKOObwWQOKtvV1cyUkD91VvZiGdrYRfc7r3C1GhYpEBg
         jhWb2a2DudnqQseInIYhn78PZhG5S/mcxCLmkSJq1PTV7hk0yskpMsEl6j9aLumz96k6
         C0vVRvdXHSiQzyVYBHDtDjH83H9Sz2cGsvz1nGDEkypJMdrd2jXA4xzDItJO4JBltTzJ
         9Rng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date:dkim-signature;
        bh=+Jwz3mP3TVVRwA+8/Iil5EIlfG8Tly5xGOIwN4hmUt4=;
        b=Nx5LiXyeflXzkjcRag8LHg3qrjXXvcePKfH1MFpQX/jqMG3CkI0sRaC7hogPWCtyYp
         toUKMIwClH1Fpfp6Xia70quoPyw6dVyaJf3R3hmwnYjujgNlzyoWuUDt7T+Jt/mmjR3W
         VLzgI7sIQfG7ZsdsGdqGwnUQ/gQHr5rRWLAlBitPvbTQs/FA8MvCopZi72LMNxo4fCPT
         9XMHny3T1Q9sPjptgPnREtA/LUc+Akf5AmPZIHRfnXII+gEuQsxufiFvujN8xNQatECa
         sLjfBy3bFUyzuPhcPkivqCKmOJsJr8izxIPQal8BXyplk42O/+PdjCcPPtcQtkPPVvVs
         MVSQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=W1DjZwMa;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w129sor15393469pfw.1.2019.07.18.15.07.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 18 Jul 2019 15:07:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=W1DjZwMa;
       spf=pass (google.com: domain of hughd@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=hughd@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:from:to:cc:subject:in-reply-to:message-id:references
         :user-agent:mime-version;
        bh=+Jwz3mP3TVVRwA+8/Iil5EIlfG8Tly5xGOIwN4hmUt4=;
        b=W1DjZwMaV2AVqZiBstV2H1vjkSj6VtgV6Kmx6bJAsEAr0wQHBkcWN+Pg/hUDmKbt5p
         nMos2P60R5Bbjn1yfEN+bY1coSARNSMrKZIIbo2KPmBUYzn5z5Y6rxqg7g5GjzAvXPvP
         rSfnukwB+GZNj2/rusjBqenkizmReRbaS3qzOPb923VVWv4TzTTQa2PBKODzaLZDZyx4
         Rn27bQY42PbyATHJCjQRXx3zSdCCC8vzd5I92Bbyy1xQ+t1bFl+M06WUpscxo7Mc8ZZW
         ZETwIioafzk5vCUX/pmAaionzCoSgvIF8fSKZW6d9P/BxtDHAdsSZXYvA4GkN1yP3iao
         7J5A==
X-Google-Smtp-Source: APXvYqz72l6x5vi2AqfAo9LXFLVSwCI9JsECSVsC7JxZmY4Foa9BJh1PdsZ/eBhOfrWAoI2b1Nuz0w==
X-Received: by 2002:a63:506:: with SMTP id 6mr49373861pgf.434.1563487628287;
        Thu, 18 Jul 2019 15:07:08 -0700 (PDT)
Received: from [100.112.64.100] ([104.133.8.100])
        by smtp.gmail.com with ESMTPSA id r2sm39349424pfl.67.2019.07.18.15.07.07
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 18 Jul 2019 15:07:07 -0700 (PDT)
Date: Thu, 18 Jul 2019 15:06:50 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
X-X-Sender: hugh@eggly.anvils
To: Vlastimil Babka <vbabka@suse.cz>
cc: Andrew Morton <akpm@linux-foundation.org>, 
    Yang Shi <yang.shi@linux.alibaba.com>, hughd@google.com, 
    kirill.shutemov@linux.intel.com, mhocko@suse.com, rientjes@google.com, 
    linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [v3 PATCH 2/2] mm: thp: fix false negative of shmem vma's THP
 eligibility
In-Reply-To: <dd44eb2f-a982-bd0e-a1ed-ab3ecbf3fc91@suse.cz>
Message-ID: <alpine.LSU.2.11.1907181457150.2510@eggly.anvils>
References: <1560401041-32207-1-git-send-email-yang.shi@linux.alibaba.com> <1560401041-32207-3-git-send-email-yang.shi@linux.alibaba.com> <4a07a6b8-8ff2-419c-eac8-3e7dc17670df@suse.cz> <5dde4380-68b4-66ee-2c3c-9b9da0c243ca@linux.alibaba.com>
 <20190718144459.7a20ac42ee16e093bdfcfab4@linux-foundation.org> <dd44eb2f-a982-bd0e-a1ed-ab3ecbf3fc91@suse.cz>
User-Agent: Alpine 2.11 (LSU 23 2013-08-11)
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Jul 2019, Vlastimil Babka wrote:
> On 7/18/19 11:44 PM, Andrew Morton wrote:
> > On Wed, 19 Jun 2019 09:28:42 -0700 Yang Shi <yang.shi@linux.alibaba.com> wrote:
> > 
> >>> Sorry for replying rather late, and not in the v2 thread, but unlike
> >>> Hugh I'm not convinced that we should include vma size/alignment in the
> >>> test for reporting THPeligible, which was supposed to reflect
> >>> administrative settings and madvise hints. I guess it's mostly a matter
> >>> of personal feeling. But one objective distinction is that the admin
> >>> settings and madvise do have an exact binary result for the whole VMA,
> >>> while this check is more fuzzy - only part of the VMA's span might be
> >>> properly sized+aligned, and THPeligible will be 1 for the whole VMA.
> >>
> >> I think THPeligible is used to tell us if the vma is suitable for 
> >> allocating THP. Both anonymous and shmem THP checks vma size/alignment 
> >> to decide to or not to allocate THP.
> >>
> >> And, if vma size/alignment is not checked, THPeligible may show "true" 
> >> for even 4K mapping. This doesn't make too much sense either.
> > 
> > This discussion seems rather inconclusive.  I'll merge up the patchset
> > anyway.  Vlastimil, if you think some changes are needed here then
> > please let's get them sorted out over the next few weeks?
> 
> Well, Hugh did ack it, albeit without commenting on this part. I don't
> feel strongly enough about this for a nack.

Right, I had no further comment: Yang and I agreed one way round,
you thought the other way.  I was more persuaded by Yang's 4kB
example than by what you wrote; but not hugely excited either way.

Hugh

