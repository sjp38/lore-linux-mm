Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE881C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 14:26:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8EB592146E
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 14:26:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="gLcmBEUP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8EB592146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A6D16B0003; Tue, 19 Mar 2019 10:26:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 256676B0006; Tue, 19 Mar 2019 10:26:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 11EB36B0007; Tue, 19 Mar 2019 10:26:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id BAABE6B0003
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 10:26:45 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id z1so23057629pfz.8
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 07:26:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=cVUGITg2L4pgVSKVd9xmSsgzIKi2mYC0AanLNtYTWB4=;
        b=iZQGZ3Q2ncFK2Ja3NIo2kOwmtG0bfPjwF1NHkLtr5O+7X3v5H2ZJIWaJaGFF0maRDn
         mfGNclohXrlpON/U7RlLU70Cfmol7TK5oo+8MKM3AR7VrIiO4uofiyDGtoCtt8RWwwM7
         UIkwJlzjLOxTTWUVp+Jjrd/n7FRBaJIEfQfQVhe9DB3v1uT5FPdMxNIDMkD0qRHVvJri
         u0hOp2S4fVibUcqyF+cLKqWAkxq6Q5k+EuwTZgw6N3INEh8SIoW7SnwchnjpNvBu3r2m
         7KJ2xTDs1iP1dOZt+B+PLfmwiTJK9ilJmBp3lbkNmPelU0RDXIvVzdQvQwp2S+AY91fn
         HKGQ==
X-Gm-Message-State: APjAAAUn+OJGfeg3TG7a2Xsgf1EKyv/yLF7DVzmf9m4Cm6fUqSGpmcft
	M5vVMEmNStsytu9dxsQBd13dSIbtO967nOwK2ByJww+1iCPPElWTRsxLMnLnp095lORPlX85+AF
	NuFqnxOfCgJKz12d0TfbApi7XtCymKHXTMwLQ3KB1svpZYyHP2FPdBCHgB9tstwL1aA==
X-Received: by 2002:a63:cc0e:: with SMTP id x14mr2127411pgf.159.1553005605311;
        Tue, 19 Mar 2019 07:26:45 -0700 (PDT)
X-Received: by 2002:a63:cc0e:: with SMTP id x14mr2127329pgf.159.1553005604302;
        Tue, 19 Mar 2019 07:26:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553005604; cv=none;
        d=google.com; s=arc-20160816;
        b=cJEpEsh24/Rb/enFXV3Oo1gQ6nmgoGR/6B9c65eJHdkvd3wv3HSsCiVQMbLWw//PsE
         8Yj1YJgqAv/C9tDXg3FoD69yh666CVf9ZLWNbdsS+l+sdk2mViDf4ylsBphwlnUqx4Zh
         roRXkOV9uLNb5jVTJOwfTDndi8AsK6u1OCjz/kTTLHJpRV9eT5UEJXRzG/0PMw1A1CzR
         HiHxtVNJTCp2zqkV7/zBKBNntIj5CJ4CxGcoW1u003eSrhX2ebJ82EeIdbZOgixR2MBy
         hwooTnhVCg4vqC/WZihBTkc6t4Mj17Qrdx4OPCktYYOHJDJI6pBuHQIrsYUU5x3LmMyB
         x8Gg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=cVUGITg2L4pgVSKVd9xmSsgzIKi2mYC0AanLNtYTWB4=;
        b=z9Qc3Lzuoke85o+XwNDUshNyLEhENmzGvefz4qTzAmiFCzWgV+f+CTcN7fXcKshByp
         +eEOwKLY2Z2Mywi+iJY1wzdD3C/zZ3vHS8SCKQPrw1qlXeeuUFLilDuChBRkMTzvMrTl
         lpOMzcYUmd+4ZiFYIxcSsYB7X4t5Qc83qMUWS25KbqYDI4sUQjnZxJs9CQS0WDEt5YrW
         0XxK0RFG+8cnVdwohWBAsKx83oNLVobCphaj7bVFefS2TPjyFGF9HYcw8RqeWBGynBB1
         Pxe0ZKWxoUdQj28RAyPO4Xcz+ZbtkniPWBqNylSVwjnlQdYq89pEdeLmxzMUjRrsx+xN
         ne4A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=gLcmBEUP;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f129sor3314330pfb.54.2019.03.19.07.26.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 07:26:44 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=gLcmBEUP;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=cVUGITg2L4pgVSKVd9xmSsgzIKi2mYC0AanLNtYTWB4=;
        b=gLcmBEUPq6+FhjVTCB/1mMjLAAaIogaKjVkouQC7kbP5RvveutFYJUHjoHKZmggPwA
         zb1N/JuLPnPyZItndAUwOZ1k/TDGDR4gQfIGkx8vSsRrs5I0FQ/1AB3f3aMGcrJQyrPZ
         QxiZnAr9fOzrJBhmnF5E0Ravo8aZqcFbSfreCI3iqaV9hEbQApw+llyW+kI/uPfyXYHJ
         1kdp8KOFjox8c4sOp7pFLbUNd6mNWU6E/lFxu1aIq+FBjbmpJilyVJeGcOQVlndmUsaP
         xSVRvSEwuk21SVwIGxV8QqORybOzDbmRLbooX7aq2ROTcHmGmHOqAX0DXt78Plf82G06
         CncQ==
X-Google-Smtp-Source: APXvYqzHw7YWMJoXHoNZzDdyBDej4OrPTq0rRPnimLby0KkdWRMw7rd+8qTBc8Dl9vyNVoT2Bz+dqg==
X-Received: by 2002:aa7:8a92:: with SMTP id a18mr2256393pfc.218.1553005603844;
        Tue, 19 Mar 2019 07:26:43 -0700 (PDT)
Received: from kshutemo-mobl1.localdomain ([192.55.54.44])
        by smtp.gmail.com with ESMTPSA id k74sm31022831pfb.172.2019.03.19.07.26.42
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 07:26:43 -0700 (PDT)
Received: by kshutemo-mobl1.localdomain (Postfix, from userid 1000)
	id 8921E3011DA; Tue, 19 Mar 2019 17:26:39 +0300 (+03)
Date: Tue, 19 Mar 2019 17:26:39 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
To: Oscar Salvador <osalvador@suse.de>
Cc: Yang Shi <shy828301@gmail.com>, Cyril Hrubis <chrubis@suse.cz>,
	Linux MM <linux-mm@kvack.org>, linux-api@vger.kernel.org,
	ltp@lists.linux.it, Vlastimil Babka <vbabka@suse.cz>,
	kirill.shutemov@linux.intel.com
Subject: Re: mbind() fails to fail with EIO
Message-ID: <20190319142639.wbind5smqcji264l@kshutemo-mobl1>
References: <20190315160142.GA8921@rei>
 <CAHbLzkqvQ2SW4soYHOOhWG0ShkdUhaiNK0_y+ULaYYHo62O0fQ@mail.gmail.com>
 <20190319132729.s42t3evt6d65sz6f@d104.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190319132729.s42t3evt6d65sz6f@d104.suse.de>
User-Agent: NeoMutt/20180716
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 02:27:33PM +0100, Oscar Salvador wrote:
> +CC Kirill
> 
> On Mon, Mar 18, 2019 at 11:12:19AM -0700, Yang Shi wrote:
> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> > index abe7a67..6ba45aa 100644
> > --- a/mm/mempolicy.c
> > +++ b/mm/mempolicy.c
> > @@ -521,11 +521,14 @@ static int queue_pages_pte_range(pmd_t *pmd,
> > unsigned long addr,
> >                         continue;
> >                 if (!queue_pages_required(page, qp))
> >                         continue;
> > -               migrate_page_add(page, qp->pagelist, flags);
> > +               if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
> > +                       migrate_page_add(page, qp->pagelist, flags);
> > +               else
> > +                       break;
> >         }
> >         pte_unmap_unlock(pte - 1, ptl);
> >         cond_resched();
> > -       return 0;
> > +       return addr != end ? -EIO : 0;
> >  }
> > 
> >  static int queue_pages_hugetlb(pte_t *pte, unsigned long hmask,
> 
> This alone is not going to help.
> 
> The problem is that we do skip the vma early in queue_pages_test_walk() in
> case MPOL_MF_MOVE and MPOL_MF_MOVE_ALL are not set.
> 
> walk_page_range
>  walk_page_test
>   queue_pages_test_walk
> 
> 	...
>  	...
> 	/* queue pages from current vma */
> 	if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
> 		return 0;
> 	return 1;
> 
> So, we skip the vma and keep going.
> 
> Before ("77bf45e78050: mempolicy: do not try to queue pages from !vma_migratable()"),
> queue_pages_test_walk() would not have skipped the vma in case we had MPOL_MF_STRICT
> or MPOL_MF_MOVE | MPOL_MF_MOVE_ALL.
> 
> I did not give it a lot of thought, but it seems to me that we might need to reach
> queue_pages_to_pte_range() in order to see whether the page is in the required node
> or not by calling queue_pages_required(), and if it is not, check for
> MPOL_MF_MOVE | MPOL_MF_MOVE_ALL like the above patch does, so we would be able to
> return -EIO.
> That would imply that we would need to re-add MPOL_MF_STRICT in queue_pages_test_walk().

That's all sounds reasonable.

We only need to make sure the bug fixed by 77bf45e78050 will not be
re-introduced.

-- 
 Kirill A. Shutemov

