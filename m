Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7CE4C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 08:27:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 658F921872
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 08:27:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 658F921872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B46666B0275; Fri, 15 Mar 2019 04:27:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B01526B0276; Fri, 15 Mar 2019 04:27:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9BAB46B0277; Fri, 15 Mar 2019 04:27:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6B1596B0275
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 04:27:07 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id n64so7133465qkb.0
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 01:27:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Q0IJeEFhXE6p3ujp42Yas2GkcLkeo9NwARR004K4Sok=;
        b=s9zwwj0HOyg+eABnSyGuGEo1K/RlseU93Mtd+aUt4LfdeZgaF24YJL6aT2/qnALx0S
         DpZJnQC704P7Ix/kmxq4ucKSggdV7xNgMMRMrxiMqzPlcmLk85Kbdx2KD1x+UwhzvEoP
         qBT74w7JIfIbSKsOipEHfSHoolTUyKnCATwAQQ6HcqSimxChcAUouc8pObCTUOgVh+Y4
         NfM1tNjGoPdke2anV3VZ/jUujX5XG0CB4gmKel1jxh6xvm/UzLNQVL3uSeEhrjHbcR/1
         S2CNcKGSlhd228enXhvzi33LSeyTOUUF/Mu5YZx/rv3ptmM+Q9qt+2uys+L4wULI03w4
         x40Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWu8S3yCVoV/gcz61/v34XDrL+hd7SZBjJVThx93ekqDssfr7/1
	gFLrqZyvhkx5eaUBWFAzpujhR9lRARr6XsR9mnbdwcAaSltC/vl83HK4QvbhSUYuUIlPQUIWX/m
	MoQDj/uZLFw9bBdWqY7tPJW+hVcSYHUl2qCNSu198L/yOosczOG75kXkDuISBE5Wl5Q==
X-Received: by 2002:a37:47cb:: with SMTP id u194mr1810560qka.296.1552638427108;
        Fri, 15 Mar 2019 01:27:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxnN9c1iW0rfrTLSIUONSZgrc16xFGYuWuVGpl41OSVE+PInh4MJJ7eIzfu5+h9UtUestg
X-Received: by 2002:a37:47cb:: with SMTP id u194mr1810515qka.296.1552638426022;
        Fri, 15 Mar 2019 01:27:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552638426; cv=none;
        d=google.com; s=arc-20160816;
        b=dJvBMZiAL/txyoQvgqxxDOmpfb8C2SWT5B9YcGl3b7BSzF61XSZjXxNldnSRqPogAD
         QQujgGY3HDiYbm0XJqReLlyF1OqktIu1281eFuSGBFQ+ffZmGwYbYZYwmBUUqpLfPWwO
         i1lKyxavDxITKgsWOY0aXPSIMYnHAcm7sWnS8NqQCUie6BpIKNHC3xNu92losnAUbqQa
         GhoSAR/Vb6QLlwdSte61294AzK+kG0zjhLT5o3L6ixrGvj8X+lhBi8QA0EnG5UgG8Ur/
         ZRWC+Z2dopFTMB7Zwe+igm90Z7f/QkC6fRJVM7EPlNXLfE4Fo59o8rd7AN0LT01Ws6QL
         i0Tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Q0IJeEFhXE6p3ujp42Yas2GkcLkeo9NwARR004K4Sok=;
        b=m6yZKogJlQIed1kpdWK6pwAGlO6ALqNc2OEqs2oAjXAN+2uH2Q5Yfh801cQQK6j3WV
         EB0PGYCxZE1qW+Uk0exWoAfi12yTXlPmHuxUX+1KQrz48ad7BL2prxCz/IudGXxMYTLG
         vP6fDEEyDvxywzojcIl0Z6bvigia1mmy0J7IicEquaFU0GVrv+DacIsBGdJsLvb1DZkr
         dJueIvue96KgYlBVnImxGv16YHoXACNcRhGhsw/tMbT63r03APYc6a7298h0LcYOua2D
         yDMTOQ01H1epx3qmlwqZejIpdSl6pFgGPrtQQEqCFmqopvvBk3y0pbDPw2NWUm3hoTik
         LpFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m6si822119qtn.126.2019.03.15.01.27.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Mar 2019 01:27:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E259A3083392;
	Fri, 15 Mar 2019 08:27:04 +0000 (UTC)
Received: from xz-x1 (ovpn-12-78.pek2.redhat.com [10.72.12.78])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id B9CFE1001DEB;
	Fri, 15 Mar 2019 08:26:54 +0000 (UTC)
Date: Fri, 15 Mar 2019 16:26:55 +0800
From: Peter Xu <peterx@redhat.com>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-kernel@vger.kernel.org, Paolo Bonzini <pbonzini@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Maxime Coquelin <maxime.coquelin@redhat.com>, kvm@vger.kernel.org,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Martin Cracauer <cracauer@cons.org>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>, linux-mm@kvack.org,
	Marty McFadden <mcfadden8@llnl.gov>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	linux-fsdevel@vger.kernel.org,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] userfaultfd: allow to forbid unprivileged users
Message-ID: <20190315082655.GA6654@xz-x1>
References: <20190311093701.15734-1-peterx@redhat.com>
 <58e63635-fc1b-cb53-a4d1-237e6b8b7236@oracle.com>
 <20190313060023.GD2433@xz-x1>
 <dd56566e-7b7f-51f6-bf01-ffda530a8073@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <dd56566e-7b7f-51f6-bf01-ffda530a8073@oracle.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.44]); Fri, 15 Mar 2019 08:27:05 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 13, 2019 at 10:50:48AM -0700, Mike Kravetz wrote:
> On 3/12/19 11:00 PM, Peter Xu wrote:
> > On Tue, Mar 12, 2019 at 12:59:34PM -0700, Mike Kravetz wrote:
> >> On 3/11/19 2:36 AM, Peter Xu wrote:
> >>>
> >>> The "kvm" entry is a bit special here only to make sure that existing
> >>> users like QEMU/KVM won't break by this newly introduced flag.  What
> >>> we need to do is simply set the "unprivileged_userfaultfd" flag to
> >>> "kvm" here to automatically grant userfaultfd permission for processes
> >>> like QEMU/KVM without extra code to tweak these flags in the admin
> >>> code.
> >>
> >> Another user is Oracle DB, specifically with hugetlbfs.  For them, we would
> >> like to add a special case like kvm described above.  The admin controls
> >> who can have access to hugetlbfs, so I think adding code to the open
> >> routine as in patch 2 of this series would seem to work.
> > 
> > Yes I think if there's an explicit and safe place we can hook for
> > hugetlbfs then we can do the similar trick as KVM case.  Though I
> > noticed that we can not only create hugetlbfs files under the
> > mountpoint (which the admin can control), but also using some other
> > ways.  The question (of me... sorry if it's a silly one!) is whether
> > all other ways to use hugetlbfs is still under control of the admin.
> > One I know of is memfd_create() which seems to be doable even as
> > unprivileged users.  If so, should we only limit the uffd privilege to
> > those hugetlbfs users who use the mountpoint directly?
> 
> Wow!  I did not realize that apps which specify mmap(MAP_HUGETLB) do not
> need any special privilege to use huge pages.  Honestly, I am not sure if
> that was by design or a bug.  The memfd_create code is based on the MAP_HUGETLB
> code and also does not need any special privilege.  Not to sidetrack this
> discussion, but people on Cc may know if this is a bug or by design.  My
> opinion is that huge pages are a limited resource and should be under control.
> One needs to be a member of a special group (or root) to access via System V
> interfaces.

Yeah I completely agree that huge pages should need some special
care...

> 
> The DB use case only does mmap of files in an explicitly mounted filesystem.
> So, limiting it in that manner would work for them.
> 
> > Another question is about fork() of privileged processes - for KVM we
> > only grant privilege for the exact process that opened the /dev/kvm
> > node, and the privilege will be lost for any forked childrens.  Is
> > that the same thing for OracleDB/Hugetlbfs?
> 
> I need to confirm with the DB people, but it is my understanding that the
> exact process which does the open/mmap will be the one using userfaultfd.

It'll be nice if these can be confirmed and if above proposal could
still be an alternative for us (grant privilege for processes who do
mknod() upon the hugetlbfs mountpoint; drop privilege when fork as
usual), since IMHO it is still the simplest approach comparing to what
we've discussed in the other threads...

Thanks,

-- 
Peter Xu

