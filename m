Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29344C10F00
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 03:42:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E36CA20836
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 03:42:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E36CA20836
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6DB2B8E00E2; Thu, 21 Feb 2019 22:42:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 661178E00B1; Thu, 21 Feb 2019 22:42:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 529318E00E2; Thu, 21 Feb 2019 22:42:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 243928E00B1
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 22:42:41 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id r24so989004qtj.13
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 19:42:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=rkbeRFhs2LNrNzCirt39Q52/FFX6z/0SuUG3oQKcPys=;
        b=KSRFuoZ4fFTi/RyA4xG0AArXO2o/q7QDxxeMKJ8pMvvj5OnB0z3l7eUioJA1bftY9e
         SH6qERHoH/MFuiNlSiEtJ1ZxcGn2DPepQ7JwPIiyjHtic2qjiQ9rA7+pERyZ9rvzsaDA
         V0xLlJDSdCfP6JAAg5t9TBLIj17lvAW6q3HXrAUv5u1rhrkYWFK5G03iiKMct/PehM/C
         Rd4L5W7lPgc2Wl3oPHwXBMTjTeeo9za7XWoIoBLDQ0TW0sVA9ewqZjgs798SdDh/QCtm
         Eb3jdaPxri0Pxd00zHV6ok6wqMPLmu3ZS8wow2hMjirs2cQpwXTLqGjyDCqaZpjwr4vC
         9kQQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubxNiccZ+h1OU7LEldzO25fbOdCoQbCK2+NxW+s/9QP4009z4Id
	7x6gCPNh3WYMivjibjZNUXZlUDXsOPd0xB+zLT/FEbb0o+YUx00nwQXAuOvi5fBcG8qUq7E8yhm
	1ZnxCSWLCBEHjisDBx6nhZSICLIo9WLTZZRdFhvgQ2hfvCTzOtsZ7cAydqXs1btsyZg==
X-Received: by 2002:a37:6744:: with SMTP id b65mr1470113qkc.162.1550806960883;
        Thu, 21 Feb 2019 19:42:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaqSt1MWCZ3RpKi3+T+wIbgAsPkqaTQIleS7TyhPyKwLDRtgwrjUQxNdbwPlPch27cIko8J
X-Received: by 2002:a37:6744:: with SMTP id b65mr1470087qkc.162.1550806959950;
        Thu, 21 Feb 2019 19:42:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550806959; cv=none;
        d=google.com; s=arc-20160816;
        b=w2G4uOHazRbCetXsgyY/RJhIN53oaDUUjHFqvuUbhEjCVlgPGiNOa+uAxSkE0S6Aem
         csK/lTg4t4bsm9pIfYZIOrVsFIqdB5zTJCE0g4j6kxV8c+w0zDlp29b4KqcRNMshFbEP
         TEoFNczykbE0+LOw3E0zxvrcYIObL6nLykIUCPRlMlGWqMKuC6ZUd02zpswrxafpJh43
         6vjX54ZPohdVa0i2EW6a6GM24CaSi3qq/Ee/pRNHp+trWGDOFx9UKa1lL0Hn3QK0tITs
         Llm2m0snn2dDE7Df6a04K4h+Co7Wh7TxtxocpHvhdb0qQ0Gv8Tv17qsaigyka11Ajn5i
         T7jQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=rkbeRFhs2LNrNzCirt39Q52/FFX6z/0SuUG3oQKcPys=;
        b=lv3cuS7hBDmdm9Kb6CNxVTUGiqXYENycywR09PSOW4QD7UzbOl3Tc/xiz7USgmB8Xq
         ooHNEQLjpG2WQ4+XaskGFuFIKITyoVFY4cVDwZwKMFsA+vicTbmVAU3X2rffDpxKvLU/
         Wl/9v1fKHYgdLIBuUXk+G9kBT7mEvpjbiJ5GAeiPCJmBfRFJ4Oxb8ILMk/Fpdct3fDD2
         ZKZRz5LFkRVha45xdNa0C0DUlkDAMgaDjInR43eZONRAVjlCwerHrlhiCjtrKAs7NK6J
         3aKJTbXnOM7RBPPeLGvz4CJx+G+buyeB7pbbVk8nVZ5y3em82I9IkKkVD6P8/EVVnQ6r
         zwzA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 24si203681qtu.137.2019.02.21.19.42.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Feb 2019 19:42:39 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 537BB81F11;
	Fri, 22 Feb 2019 03:42:38 +0000 (UTC)
Received: from xz-x1 (ovpn-12-57.pek2.redhat.com [10.72.12.57])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 246CD60C80;
	Fri, 22 Feb 2019 03:42:22 +0000 (UTC)
Date: Fri, 22 Feb 2019 11:42:14 +0800
From: Peter Xu <peterx@redhat.com>
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>, Shaohua Li <shli@fb.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v2 01/26] mm: gup: rename "nonblocking" to "locked" where
 proper
Message-ID: <20190222034214.GB8904@xz-x1>
References: <20190212025632.28946-1-peterx@redhat.com>
 <20190212025632.28946-2-peterx@redhat.com>
 <20190221151742.GA2813@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190221151742.GA2813@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Fri, 22 Feb 2019 03:42:39 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 21, 2019 at 10:17:42AM -0500, Jerome Glisse wrote:
> On Tue, Feb 12, 2019 at 10:56:07AM +0800, Peter Xu wrote:
> > There's plenty of places around __get_user_pages() that has a parameter
> > "nonblocking" which does not really mean that "it won't block" (because
> > it can really block) but instead it shows whether the mmap_sem is
> > released by up_read() during the page fault handling mostly when
> > VM_FAULT_RETRY is returned.
> > 
> > We have the correct naming in e.g. get_user_pages_locked() or
> > get_user_pages_remote() as "locked", however there're still many places
> > that are using the "nonblocking" as name.
> > 
> > Renaming the places to "locked" where proper to better suite the
> > functionality of the variable.  While at it, fixing up some of the
> > comments accordingly.
> > 
> > Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> > Signed-off-by: Peter Xu <peterx@redhat.com>
> 
> Minor issue see below
> 
> Reviewed-by: Jérôme Glisse <jglisse@redhat.com>
> 
> [...]
> 
> > @@ -656,13 +656,11 @@ static int check_vma_flags(struct vm_area_struct *vma, unsigned long gup_flags)
> >   * appropriate) must be called after the page is finished with, and
> >   * before put_page is called.
> >   *
> > - * If @nonblocking != NULL, __get_user_pages will not wait for disk IO
> > - * or mmap_sem contention, and if waiting is needed to pin all pages,
> > - * *@nonblocking will be set to 0.  Further, if @gup_flags does not
> > - * include FOLL_NOWAIT, the mmap_sem will be released via up_read() in
> > - * this case.
> > + * If @locked != NULL, *@locked will be set to 0 when mmap_sem is
> > + * released by an up_read().  That can happen if @gup_flags does not
> > + * has FOLL_NOWAIT.
> 
> I am not a native speaker but i believe the correct wording is:
>      @gup_flags does not have FOLL_NOWAIT

Yes I agree.

(r-b taken, and I kept Mike's too assuming this is a trivial change)

Thanks!

-- 
Peter Xu

