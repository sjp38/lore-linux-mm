Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id E41AD6B0261
	for <linux-mm@kvack.org>; Wed, 25 May 2016 02:31:15 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id k186so19545405lfe.3
        for <linux-mm@kvack.org>; Tue, 24 May 2016 23:31:15 -0700 (PDT)
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com. [74.125.82.44])
        by mx.google.com with ESMTPS id wt4si8919505wjc.187.2016.05.24.23.31.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 May 2016 23:31:14 -0700 (PDT)
Received: by mail-wm0-f44.google.com with SMTP id z87so49064289wmh.0
        for <linux-mm@kvack.org>; Tue, 24 May 2016 23:31:14 -0700 (PDT)
Date: Wed, 25 May 2016 08:31:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: page order 0 allocation fail but free pages are enough
Message-ID: <20160525063112.GA20132@dhcp22.suse.cz>
References: <CADUS3okXhU5mW5Y2BC88zq2GtaVyK1i+i2uT34zHbWPw3hFPTA@mail.gmail.com>
 <20160523144711.GV2278@dhcp22.suse.cz>
 <CADUS3onEpdMF6Pi9-cHkf+hA6bqOc4mkXAci7ikeUhtaELx4WQ@mail.gmail.com>
 <20160523190051.GF32715@dhcp22.suse.cz>
 <CADUS3onbkOC=kSsHxVgwK-m-ftmrzH+73RHDAFw_mbLvPGBx6A@mail.gmail.com>
 <20160524115049.GH8259@dhcp22.suse.cz>
 <CADUS3om92UNPrwji7A_M6W-YPM2zjO9j6uPJ=c3vtVwUzrg_WA@mail.gmail.com>
 <CADUS3okn3a74j-aYKyfPis+NJa4OGvNPsJWW4iyyRu6bfdZB6Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADUS3okn3a74j-aYKyfPis+NJa4OGvNPsJWW4iyyRu6bfdZB6Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yoma sophian <sophian.yoma@gmail.com>
Cc: linux-mm@kvack.org

On Wed 25-05-16 10:11:23, yoma sophian wrote:
> >> free-free_cma = 636kB so you are way below the watermark and that is
> > After tracing the __alloc_pages_slowpath, in the 2nd time we call
> > get_page_from_freelist, we will purposely put alloc_flags &
> > ~ALLOC_NO_WATERMARKS.
> > Doesn't that mean kernel will bypass __zone_watermark_ok?
> I apologize for my misunderstanding.
> (alloc_flags & ~ALLOC_NO_WATERMARKS) will NOT bypass __zone_watermark_ok.
> on the contrary, it will filter out watermarks checking.

true

> there is one thing makes me curious,
> why we put  alloc_flags = gfp_to_alloc_flags(gfp_mask) in
> __alloc_pages_slowpath  instead of __alloc_pages_nodemask?

Because we want to make the hot path as effective as possible. So the
hot path is an optimistic attempt with low watermark target which then
falls into the slow path with the full gfp_masks restrictions against
min watermark.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
