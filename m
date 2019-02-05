Return-Path: <SRS0=TNGr=QM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.0 required=3.0
	tests=HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1FFEC282CB
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 07:14:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE9752145D
	for <linux-mm@archiver.kernel.org>; Tue,  5 Feb 2019 07:14:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE9752145D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 441368E0077; Tue,  5 Feb 2019 02:14:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C9228E001C; Tue,  5 Feb 2019 02:14:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 292698E0077; Tue,  5 Feb 2019 02:14:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id ED5A18E001C
	for <linux-mm@kvack.org>; Tue,  5 Feb 2019 02:14:37 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id q193so2418863qke.12
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 23:14:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:message-id:in-reply-to:references:subject:mime-version
         :content-transfer-encoding:thread-topic:thread-index;
        bh=yEcYxoWgA0XqYv6PmRpdY3ci8NlVZV0O7p+Y0FVCXEI=;
        b=gY37chStqBPjdfE5744a/ApM2bvabomX9rUV+yUoegjuzZJcLRwIj5xvmo9LQ83Xcc
         52Lfr+QTkCAGm02htsjILc8LMcENTyYJ0X4B2EI757IP0LBaI7Ax0MEsplFII55dh4Xv
         kD911YbulNvMM6WgC/ydZMn1WKvORRE1Us5Ukr+y+NJZO38qVc+XSE44RIMkKMkmv/Ke
         +iczYV8ScbAIC4D6MwcUVTUe7+7JqGOhYztlHntwvmO+FY+kAjZRV5icdoxnMV9HtcMj
         256xm0TkSchh9QC1LhV9kZP8lhFTbnK4dDdftpBkdkt6BqfUQ3lj7xorANI72v1lsnx6
         7RnA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuarKUXsUt+UGutDO2YmBzPsM8dIWWD2sak0O9pOsE2APHeqKmqH
	uY8ArqLWu/2EvLB9dwSX/dDEomrDglqqqEjASHeT24K0RWAr8wTmQNAAqtJJS1gfZiTmQfL8oHq
	OAQ5gwMihOe3zgFTLfPBVLrvZ7XE4cX05EMJonkiZSRdx6DJ0fdgDSLJPIb7MO8ZPvg==
X-Received: by 2002:a0c:fe10:: with SMTP id x16mr573794qvr.11.1549350877591;
        Mon, 04 Feb 2019 23:14:37 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib4kaRqoEgoohf/wkfpyE24zbK3umsdlIsHYKZCzakItjOatFLUOol4WmZZtcPDCClwF+VS
X-Received: by 2002:a0c:fe10:: with SMTP id x16mr573765qvr.11.1549350876885;
        Mon, 04 Feb 2019 23:14:36 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549350876; cv=none;
        d=google.com; s=arc-20160816;
        b=JDWAsm9mTi+XAH+5u0l0Eeqk4vCwmqYsUaWjpcWcvlz+rBjCzQEmCYxj0UFqk8kuIb
         sbvJYY1tFGHTso+mO7wML9U0GbPI+B/IPxwX4M0V00lawMoZdps83hCyYeVwXoELbSA0
         w9mRh35fpefz/7bhpsgUBvrT3iITPtuo9jA148UDHp71xYSloRsiMwUBTUrDdY4CLkXd
         kj1Ysneeb1IPg6p1ZO29bAiDvVG+0sk9j+wWby7KJdNJ52gqHJXLEda7qWynS8QvjWZ/
         GrmbW8K8WLDXZ5ESK+TtcC/jvZWTHNlrnLJYzyoy6XPCbw4wk/rCjVZV+D4e2v5m8ToP
         675g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=thread-index:thread-topic:content-transfer-encoding:mime-version
         :subject:references:in-reply-to:message-id:cc:to:from:date;
        bh=yEcYxoWgA0XqYv6PmRpdY3ci8NlVZV0O7p+Y0FVCXEI=;
        b=gAC6UdCH9zsFcGWLP2mY0VozXWCBVC9BcDF6bnqMej5Upne/wQEsQNhhzZJXWzmzKd
         CS8x733M9BVux7Kyn0GgfzWuK8QIM5ol/Ftu/0hBjBKYoBSc0oZccZg6u7QplqAUiEj4
         O8c+3/AAwVNKUEoaZSf5wXx+WavPMcdcXvfe8xJDfLllFncHErTwS7pIXhsL768uaWIp
         MmdssQQLXqVEoFDJ483F0VAoeo3g9gTHOORCDiZjmMixFn/2fs5XfPetCReBaoLp8cLm
         bDSdKyD7AsHFx/1IeorByirwt67jfdfLhoW2mfhyl98sUh9JkiO0OlciWXsblRRABv5w
         larg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u13si3470705qvp.212.2019.02.04.23.14.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 23:14:36 -0800 (PST)
Received-SPF: pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id D92DFC049DC1;
	Tue,  5 Feb 2019 07:14:35 +0000 (UTC)
Received: from colo-mx.corp.redhat.com (colo-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id B1B7E8E3DC;
	Tue,  5 Feb 2019 07:14:35 +0000 (UTC)
Received: from zmail17.collab.prod.int.phx2.redhat.com (zmail17.collab.prod.int.phx2.redhat.com [10.5.83.19])
	by colo-mx.corp.redhat.com (Postfix) with ESMTP id 3CB244A460;
	Tue,  5 Feb 2019 07:14:35 +0000 (UTC)
Date: Tue, 5 Feb 2019 02:14:34 -0500 (EST)
From: Jan Stancek <jstancek@redhat.com>
To: Lars Persson <lists@bofh.nu>
Cc: linux-mm@kvack.org, lersek@redhat.com, 
	alex williamson <alex.williamson@redhat.com>, aarcange@redhat.com, 
	rientjes@google.com, kirill@shutemov.name, 
	mgorman@techsingularity.net, mhocko@suse.com, 
	linux-kernel@vger.kernel.org
Message-ID: <997509746.100933786.1549350874925.JavaMail.zimbra@redhat.com>
In-Reply-To: <CADnJP=vsum7_YYWBpknpahTQFAzm7G40_E2dLMB_poFEhPKEfw@mail.gmail.com>
References: <eabca57aa14f4df723173b24891f4a2d9c501f21.1543526537.git.jstancek@redhat.com> <c440d69879e34209feba21e12d236d06bc0a25db.1543577156.git.jstancek@redhat.com> <CADnJP=vsum7_YYWBpknpahTQFAzm7G40_E2dLMB_poFEhPKEfw@mail.gmail.com>
Subject: Re: [PATCH v2] mm: page_mapped: don't assume compound page is huge
 or THP
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.40.204.147, 10.4.195.8]
Thread-Topic: page_mapped: don't assume compound page is huge or THP
Thread-Index: UZRA0ONgTI/KE7JRWOwpjzv1lbRMeg==
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Tue, 05 Feb 2019 07:14:36 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



----- Original Message -----
> On Fri, Nov 30, 2018 at 1:07 PM Jan Stancek <jstancek@redhat.com> wrote:
> >
> > LTP proc01 testcase has been observed to rarely trigger crashes
> > on arm64:
> >     page_mapped+0x78/0xb4
> >     stable_page_flags+0x27c/0x338
> >     kpageflags_read+0xfc/0x164
> >     proc_reg_read+0x7c/0xb8
> >     __vfs_read+0x58/0x178
> >     vfs_read+0x90/0x14c
> >     SyS_read+0x60/0xc0
> >
> > Issue is that page_mapped() assumes that if compound page is not
> > huge, then it must be THP. But if this is 'normal' compound page
> > (COMPOUND_PAGE_DTOR), then following loop can keep running
> > (for HPAGE_PMD_NR iterations) until it tries to read from memory
> > that isn't mapped and triggers a panic:
> >         for (i = 0; i < hpage_nr_pages(page); i++) {
> >                 if (atomic_read(&page[i]._mapcount) >= 0)
> >                         return true;
> >         }
> >
> > I could replicate this on x86 (v4.20-rc4-98-g60b548237fed) only
> > with a custom kernel module [1] which:
> > - allocates compound page (PAGEC) of order 1
> > - allocates 2 normal pages (COPY), which are initialized to 0xff
> >   (to satisfy _mapcount >= 0)
> > - 2 PAGEC page structs are copied to address of first COPY page
> > - second page of COPY is marked as not present
> > - call to page_mapped(COPY) now triggers fault on access to 2nd
> >   COPY page at offset 0x30 (_mapcount)
> >
> > [1]
> > https://github.com/jstancek/reproducers/blob/master/kernel/page_mapped_crash/repro.c
> >
> > Fix the loop to iterate for "1 << compound_order" pages.
> >
> > Debugged-by: Laszlo Ersek <lersek@redhat.com>
> > Suggested-by: "Kirill A. Shutemov" <kirill@shutemov.name>
> > Signed-off-by: Jan Stancek <jstancek@redhat.com>
> > ---
> >  mm/util.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> > Changes in v2:
> > - change the loop instead so we check also mapcount of subpages
> >
> > diff --git a/mm/util.c b/mm/util.c
> > index 8bf08b5b5760..5c9c7359ee8a 100644
> > --- a/mm/util.c
> > +++ b/mm/util.c
> > @@ -478,7 +478,7 @@ bool page_mapped(struct page *page)
> >                 return true;
> >         if (PageHuge(page))
> >                 return false;
> > -       for (i = 0; i < hpage_nr_pages(page); i++) {
> > +       for (i = 0; i < (1 << compound_order(page)); i++) {
> >                 if (atomic_read(&page[i]._mapcount) >= 0)
> >                         return true;
> >         }
> > --
> > 1.8.3.1
> 
> Hi all
> 
> This patch landed in the 4.9-stable tree starting from 4.9.151 and it
> broke our MIPS1004kc system with CONFIG_HIGHMEM=y.

Hi,

are you using THP (CONFIG_TRANSPARENT_HUGEPAGE)?

The changed line should affect only THP and normal compound pages,
so a test with THP disabled might be interesting. 

> 
> The breakage consists of random processes dying with SIGILL or SIGSEGV
> when we stress test the system with high memory pressure and explicit
> memory compaction requested through /proc/sys/vm/compact_memory.
> Reverting this patch fixes the crashes.
> 
> We can put some effort on debugging if there are no obvious
> explanations for this. Keep in mind that this is 32-bit system with
> HIGHMEM.

Nothing obvious that I can see. I've been trying to reproduce on
32-bit x86 Fedora with no luck so far.

Regards,
Jan

