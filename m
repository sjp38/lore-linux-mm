Return-Path: <SRS0=5q+O=TJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED504C04AB1
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 10:12:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B59F21479
	for <linux-mm@archiver.kernel.org>; Thu,  9 May 2019 10:12:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="RxAmX5GV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B59F21479
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3ABC76B0003; Thu,  9 May 2019 06:12:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 35D8A6B0006; Thu,  9 May 2019 06:12:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 24A9F6B0007; Thu,  9 May 2019 06:12:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 03AE56B0003
	for <linux-mm@kvack.org>; Thu,  9 May 2019 06:12:11 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id e129so1289913iof.16
        for <linux-mm@kvack.org>; Thu, 09 May 2019 03:12:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=Xgses+TIdzaI9yt59q3h+UsOZwveq16nUB5ccuxI8FU=;
        b=D5n6Ck8v8mqBXICfQCcd+uQvUoFWC8ZeOnKHk89mJwvJyLYF3c+lAgM5N5s5a4dOix
         1nIMI+UOFgDzZIoNscS0lnjZHXZbrlM94875QT75cKde2ouzecEq7GIFQ2HVzu4DBwk5
         vQ5f75wL3azYWGtwmtCHrkSyeXG9biyfFCh/TeAyU81UY5y1VnrCnvWSSAj0k44ft17e
         Itm3Z80k9GZk8htoe7BkBiONfpzKx1gLhl4tffT0VggMo3sBAtELKv6BiKQKRI9PUNP5
         TfxAMc6nXoySbo5jG6S8+x9xbZq0c5rt3K2fqPzkTHo8SfEJ03mn92IqFW1XwFmetWf5
         SJ6A==
X-Gm-Message-State: APjAAAVbWvhPt8ZxtTplrpzj4aOYMzpxQEPHaj3FjfGocTPdmQqW/ShI
	QhF8r+pvOd+9JQbxmozE6NFsRhUxidIQ6SkSEviF6IGRgls2lEuIXcYHdHvygKCBRVMqseZ8bW5
	ML9KZ/1XCUz8lznnZ1iNlrsO3KciS+/Pnlqj7xxD+dgzusyDeqe+3MC3N9U3xjZSW4Q==
X-Received: by 2002:a5d:9383:: with SMTP id c3mr1209045iol.222.1557396730655;
        Thu, 09 May 2019 03:12:10 -0700 (PDT)
X-Received: by 2002:a5d:9383:: with SMTP id c3mr1209008iol.222.1557396729879;
        Thu, 09 May 2019 03:12:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557396729; cv=none;
        d=google.com; s=arc-20160816;
        b=IjtTNgDRhXyBbL+V36A5YHXpwIKuIIe8eNvPFGpTC5DI+aizcSJC5CoO4ClgUJ3QCU
         rsc71ZaSencWRzlpPfNokJpN/PaxZiIxE5NpJNTuPqcP8Zq1TiKhIvBxUUDvSlVkxHTa
         jw0E7byev20012BS5fFAMwZtFPb3i9YzZpV8BdXuLsMT/V7GjbgKknvbcVwdABCISJ5i
         R84uirm7pJRWJZKnX28WCst5W43doOxGN9Q0Tke2+PTQQFOQzjRwYZp6aUduyDjgrrpL
         Zpst8CQVnmzij678O2uL6eLp6C0j46ee5jXmnc7s7Tqn2hZHWon5aJjDZCeMdHElPJ/s
         kCow==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=Xgses+TIdzaI9yt59q3h+UsOZwveq16nUB5ccuxI8FU=;
        b=Q1tcZmsV5qbjCBihRXRKa9oXekj736FhGlObe4p9hIfnf6CFwtfmFU8ujVhqusOwt0
         wHDQCyYgmOFMBGj8aNilWNdKW/X/lOAK6XzOKjHkicya2t+ha4IwAsnfdu8cQCmoeoSw
         n4hL36HXRHkzzSgn6XIpqvRZ21zBttCOOZ4AhuIIMAt//ez+g/uKoJFBTOFG+QhwWkGU
         n6gnqnr3838jIzVlCgPXot2nSlsrly9/7BZPWuVTCXiUwqOjowOW3SjwDmDykH4yvuQd
         mgNXhF6lFJwU2Xj04G7+FrE11+9SGn3i265BVjBNSZWhMytGbYrlSZWFc/cP0e+gyQCM
         k0og==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=RxAmX5GV;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q9sor845129ion.130.2019.05.09.03.12.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 09 May 2019 03:12:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=RxAmX5GV;
       spf=pass (google.com: domain of dvyukov@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dvyukov@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=Xgses+TIdzaI9yt59q3h+UsOZwveq16nUB5ccuxI8FU=;
        b=RxAmX5GVAUo3hXQYwg3dPu3Q9Varjm1hYAUEw1ayyij3jCaD3T90ZnSFYVqDnO4Jd9
         VSKU/sNrphohVRznZkoYjrnZBY7kU5AlYA3x/iJ1PgxgHJdlifFggTh8lDFNtgW1Dc7p
         zkA26ZamrAWGFwvArytvJrwM9TaSTmoyKF6n+EwGOEfoA9EUnvdvKDO9xtQdDGF37K7z
         idYdH2cLH0RJcwExk6kxhASAUZ0/R7axkT5/QXsH8SIhGGwyKqFJAeZNjMNFyBkURgVd
         5wVpYwnSmc4MXDwKHwZymEqazstWztqRc1KViKjpHjA8wHBlmrZty9VTH872pdawPIJx
         V3mw==
X-Google-Smtp-Source: APXvYqxd70Xrt+pA6K9WN4S6IMIE0rw4KJus77FSRLXOePxsWEZOyfXKNufr5siKIWHWXL6YIETEwcXNHBr3p5oZbOc=
X-Received: by 2002:a5e:d60f:: with SMTP id w15mr1720583iom.282.1557396729132;
 Thu, 09 May 2019 03:12:09 -0700 (PDT)
MIME-Version: 1.0
References: <0000000000003beebd0588492456@google.com> <20190509095724.GG18914@techsingularity.net>
In-Reply-To: <20190509095724.GG18914@techsingularity.net>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 9 May 2019 12:11:57 +0200
Message-ID: <CACT4Y+Yt6U0C7UJqp4b_v=-_csDn81S7BEJKhudSDeK0-fFDQw@mail.gmail.com>
Subject: Re: BUG: unable to handle kernel paging request in isolate_freepages_block
To: Mel Gorman <mgorman@techsingularity.net>
Cc: syzbot <syzbot+d84c80f9fe26a0f7a734@syzkaller.appspotmail.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, 
	Qian Cai <cai@lca.pw>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, 
	Michal Hocko <mhocko@suse.com>, syzkaller-bugs <syzkaller-bugs@googlegroups.com>, 
	Vlastimil Babka <vbabka@suse.cz>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> On Tue, May 07, 2019 at 02:50:05AM -0700, syzbot wrote:
> > Hello,
> >
> > syzbot found the following crash on:
> >
> > HEAD commit:    baf76f0c slip: make slhc_free() silently accept an error p..
> > git tree:       upstream
> > console output: https://syzkaller.appspot.com/x/log.txt?x=16dbe6cca00000
> > kernel config:  https://syzkaller.appspot.com/x/.config?x=a42d110b47dd6b36
> > dashboard link: https://syzkaller.appspot.com/bug?extid=d84c80f9fe26a0f7a734
> > compiler:       gcc (GCC) 9.0.0 20181231 (experimental)
> >
> > Unfortunately, I don't have any reproducer for this crash yet.
> >
>
> How reproducible is it and can the following (compile tested only) patch
> be tested please? I'm thinking it's a similar class of bug to 6b0868c820ff
> ("mm/compaction.c: correct zone boundary handling when resetting pageblock
> skip hints")

Hi Mel,

The info about reproducibility is always available on the dashboard:

> > dashboard link: https://syzkaller.appspot.com/bug?extid=d84c80f9fe26a0f7a734

So far it happened only 3 times which is not very frequent, 1 crash
every few days. syzbot did not come up with a reproducer so far.
If you think this should fix the bug, commit the patch, syzbot will
close the bug and then notify us again if the crash will happen again
after the patch reaches all tested trees.



> diff --git a/mm/compaction.c b/mm/compaction.c
> index 3319e0872d01..ae4d99d31b61 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -1228,7 +1228,7 @@ fast_isolate_around(struct compact_control *cc, unsigned long pfn, unsigned long
>
>         /* Pageblock boundaries */
>         start_pfn = pageblock_start_pfn(pfn);
> -       end_pfn = min(start_pfn + pageblock_nr_pages, zone_end_pfn(cc->zone));
> +       end_pfn = min(start_pfn + pageblock_nr_pages, zone_end_pfn(cc->zone) - 1);
>
>         /* Scan before */
>         if (start_pfn != pfn) {
> @@ -1239,7 +1239,7 @@ fast_isolate_around(struct compact_control *cc, unsigned long pfn, unsigned long
>
>         /* Scan after */
>         start_pfn = pfn + nr_isolated;
> -       if (start_pfn != end_pfn)
> +       if (start_pfn < end_pfn)
>                 isolate_freepages_block(cc, &start_pfn, end_pfn, &cc->freepages, 1, false);
>
>         /* Skip this pageblock in the future as it's full or nearly full */

