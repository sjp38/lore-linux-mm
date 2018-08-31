Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id EA0986B5768
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 10:31:11 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id t23-v6so6910712pfe.20
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 07:31:11 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f40-v6si10306766plb.504.2018.08.31.07.31.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 31 Aug 2018 07:31:10 -0700 (PDT)
Date: Fri, 31 Aug 2018 07:31:00 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/2] fs/dcache: Track & report number of negative dentries
Message-ID: <20180831143100.GA6379@bombadil.infradead.org>
References: <1535476780-5773-1-git-send-email-longman@redhat.com>
 <1535476780-5773-2-git-send-email-longman@redhat.com>
 <20180829001153.GD1572@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180829001153.GD1572@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Waiman Long <longman@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>

On Wed, Aug 29, 2018 at 10:11:53AM +1000, Dave Chinner wrote:
> > +++ b/Documentation/sysctl/fs.txt
> > @@ -63,19 +63,26 @@ struct {
> >          int nr_unused;
> >          int age_limit;         /* age in seconds */
> >          int want_pages;        /* pages requested by system */
> > -        int dummy[2];
> > +        int nr_negative;       /* # of unused negative dentries */
> > +        int dummy;
> >  } dentry_stat = {0, 0, 45, 0,};
> 
> That's not a backwards compatible ABI change. Those dummy fields
> used to represent some metric we no longer calculate, and there are
> probably still monitoring apps out there that think they still have
> the old meaning. i.e. they are still visible to userspace:

I believe you are incorrect.  dentry_stat was introduced in 2.1.60 with
this hunk:

+struct {
+       int nr_dentry;
+       int nr_unused;
+       int age_limit;          /* age in seconds */
+       int want_pages;         /* pages requested by system */
+       int dummy[2];
+} dentry_stat = {0, 0, 45, 0,};
+

Looking through the rest of the dentry_stat changes in the 2.1.60 release,
it's not replacing anything, it's adding new information.
