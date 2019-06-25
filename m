Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34B85C48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 05:31:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 064DE2085A
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 05:31:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 064DE2085A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 94E138E0003; Tue, 25 Jun 2019 01:31:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FF748E0002; Tue, 25 Jun 2019 01:31:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7ED398E0003; Tue, 25 Jun 2019 01:31:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 556428E0002
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 01:31:31 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id d26so19604576qte.19
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 22:31:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=iqExqOnSByAn43v7WYpp5lu2pzQH++GcWPRRvqxzR9E=;
        b=GyFX+Cx28QKEsoXNfaXzdCuS88HPGfeLf1LjwdUk8XYa2zce9nUvAK+40cxYU/ZwlJ
         B27zz3nq2g4rhaysxPhLmq+80aJ+8t4XgDKTeijIocp5wubr8rRHaH8hdD6d5QykhUXu
         gTrm6giaBrTkYm/+1tBJZpIw6Sl3riFRl5weX9HRqwtXRcHu2C79DvUoDKle+XY6s7gE
         2kGp1THtR8HBi1bBkiF6zWbyMT7OiRpS/VQJ1MM0KhMok7BEJT++kF+2PUM+LjuXy2Ci
         m7irjVv8x2/JASpFBoF5yTod56Hludntb+2MT53OIdqtJIG4svdzRGUPK4fN11BvdG+b
         ktuA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUWSEWKQWqJRsZzo6kHzySP/GSo6RcdwYLm08wvrQ69B2IE+RXO
	QFidhHFaOD6gT/Y1Yer0rwFvefWEkBNNq/Te6QbsQIOGpyPWM9GH7FZkhdPUER9AEiyvlplW4aD
	jkf7XoOqRUzthSPpR67ymrWeGer4O3iLiXbE+WLAomgEqupKdVtzwlLX7wSqmvwi+7w==
X-Received: by 2002:ad4:43e3:: with SMTP id f3mr26068327qvu.108.1561440691069;
        Mon, 24 Jun 2019 22:31:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwYDlZ9ZvX5CXum67Y5o6ykz30aRyQjr5/7VtOXVCuOC/EBwAldbLbJmH89o+Vv19v+S/cp
X-Received: by 2002:ad4:43e3:: with SMTP id f3mr26068282qvu.108.1561440690339;
        Mon, 24 Jun 2019 22:31:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561440690; cv=none;
        d=google.com; s=arc-20160816;
        b=BVRRic0+aWsBu49tyXY/JfGLayQgZb6Zxk/mNY/4Z+a1SrabTcw3RYggklBPOukGYD
         eqDfOQapDZ6cymmMFyJL2eSpR/aMsYRr8pMua8A8SoAJ7P/Bnpd7qxGAE9voY/UOrCPo
         vRx6CesBLXV4oHQlNTCy6QeWq8KU2ikY+FWieHZQL+K8oMad+x+tE/pZtAI2GGnemONZ
         K1JZdRA8cmdGq11osDS5aXVIluhCRsfHfknMS33XPIgGhyBSjJrBvS1itbVwSMR466px
         uQg5h3vo9auvk8onZSMaJaGEVUGnOanEo91zNWo2KagWLMGv44gh9EhsOKcvdFsjWWXm
         xVdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=iqExqOnSByAn43v7WYpp5lu2pzQH++GcWPRRvqxzR9E=;
        b=YTmtK4vn2G2Gf6NfOYLa0Cw5stACVaLT4wUOh9uGzldrGCbwQ+wwEapK+y72bsTOsE
         Uuk7qDGeXJ1F5F8hTvnn+18E5QIkF05Xkt4iCsqrb9CeKAXJkozaBrndKdgSQEiwq+o8
         WEFpVAzGDZfaZTuQTBFxk2FSdkug3M9MmdU/M9J60c89zDtNFcXNKrvE7C/vUB28TPCG
         HKyV0ZPoBuqGFvDReAF9GCzG+8L4kEcxTxuV9EQDLtZ19fBFRGfflKKkmhIph4miV9+F
         c6U3McbueKnfalAJkzp+tgWR5m52PFJv3OPkTipEY0ulQrOcbCv54m2AlSAmDsFzdNhl
         7Iaw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q124si8680844qkd.161.2019.06.24.22.31.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 22:31:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 290548E223;
	Tue, 25 Jun 2019 05:31:05 +0000 (UTC)
Received: from xz-x1 (unknown [10.66.60.185])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 9BB435D9C3;
	Tue, 25 Jun 2019 05:30:49 +0000 (UTC)
Date: Tue, 25 Jun 2019 13:30:47 +0800
From: Peter Xu <peterx@redhat.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>,
	Linux List Kernel Mailing <linux-kernel@vger.kernel.org>,
	David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>, Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Shaohua Li <shli@fb.com>, Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: Re: [PATCH v5 02/25] mm: userfault: return VM_FAULT_RETRY on signals
Message-ID: <20190625053047.GC10020@xz-x1>
References: <20190620022008.19172-1-peterx@redhat.com>
 <20190620022008.19172-3-peterx@redhat.com>
 <CAHk-=wiGphH2UL+To5rASyFoCk6=9bROUkGDWSa_rMu9Kgb0yw@mail.gmail.com>
 <20190624074250.GF6279@xz-x1>
 <CAHk-=whRw_6ZTj=AT=cRoSTyoEk2-hiqJoNkqgWE-gSRVE5YwQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAHk-=whRw_6ZTj=AT=cRoSTyoEk2-hiqJoNkqgWE-gSRVE5YwQ@mail.gmail.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Tue, 25 Jun 2019 05:31:29 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 24, 2019 at 09:31:42PM +0800, Linus Torvalds wrote:
> On Mon, Jun 24, 2019 at 3:43 PM Peter Xu <peterx@redhat.com> wrote:
> >
> > Should we still be able to react on signal_pending() as part of fault
> > handling (because that's what this patch wants to do, at least for an
> > user-mode page fault)?  Please kindly correct me if I misunderstood...
> 
> I think that with this patch (modulo possible fix-ups) then yes, as
> long as we're returning to user mode we can do signal_pending() and
> return RETRY.
> 
> But I think we really want to add a new FAULT_FLAG_INTERRUPTIBLE bit
> for that (the same way we already have FAULT_FLAG_KILLABLE for things
> that can react to fatal signals), and only do it when that is set.
> Then the page fault handler can set that flag when it's doing a
> user-mode page fault.
> 
> Does that sound reasonable?

Yes that sounds reasonable to me, and that matches perfectly with
TASK_INTERRUPTIBLE and TASK_KILLABLE.  The only thing that I am a bit
uncertain is whether we should define FAULT_FLAG_INTERRUPTIBLE as a
new bit or make it simply a combination of:

  FAULT_FLAG_KILLABLE | FAULT_FLAG_USER

The problem is that when we do set_current_state() with either
TASK_INTERRUPTIBLE or TASK_KILLABLE we'll only choose one of them, but
never both.  Here since the fault flag is a bitmask then if we
introduce a new FAULT_FLAG_INTERRUPTIBLE bit and use it in the fault
flags then we should probably be sure that FAULT_FLAG_KILLABLE is also
set when with that (since IMHO it won't make much sense to make a page
fault "interruptable" but "un-killable"...).  Considering that
TASK_INTERRUPTIBLE should also always in user-mode page faults so this
dependency seems to exist with FAULT_FLAG_USER.  Then I'm thinking
maybe using the combination to express the meaning that "we would like
this page fault to be interruptable, even for general userspace
signals" would be nicer?

AFAIK currently only handle_userfault() have such code to handle
normal signals besides SIGKILL, and it was trying to detect this using
this rule already:

	return_to_userland =
		(vmf->flags & (FAULT_FLAG_USER|FAULT_FLAG_KILLABLE)) ==
		(FAULT_FLAG_USER|FAULT_FLAG_KILLABLE);

Then if we define that globally and officially then we can probably
replace this simply with:

	return_to_userland = vmf->flags & FAULT_FLAG_INTERRUPTIBLE;

What do you think?

Thanks,

-- 
Peter Xu

