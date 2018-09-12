Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 407748E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 11:56:03 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id b29-v6so1321912pfm.1
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 08:56:03 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m14-v6si1470385pgc.368.2018.09.12.08.56.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 12 Sep 2018 08:56:01 -0700 (PDT)
Date: Wed, 12 Sep 2018 08:55:57 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v3 4/4] fs/dcache: Eliminate branches in
 nr_dentry_negative accounting
Message-ID: <20180912155557.GA18304@bombadil.infradead.org>
References: <1536693506-11949-1-git-send-email-longman@redhat.com>
 <1536693506-11949-5-git-send-email-longman@redhat.com>
 <20180912023610.GB20056@bombadil.infradead.org>
 <bf7592c3-dc1d-635e-8bb0-717f6e8a54d9@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bf7592c3-dc1d-635e-8bb0-717f6e8a54d9@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Waiman Long <longman@redhat.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Wangkai (Kevin C)" <wangkai86@huawei.com>, Michal Hocko <mhocko@kernel.org>

On Wed, Sep 12, 2018 at 11:49:22AM -0400, Waiman Long wrote:
> > unless our macrology has got too clever for the compilre to see through
> > it.  In which case, the right answer is to simplify the percpu code,
> > not to force the compiler to optimise the code in the way that makes
> > sense for your current microarchitecture.
> >
> I had actually looked at the x86 object file generated to verify that it
> did use cmove with the patch and use branch without. It is possible that
> there are other twists to make that happen with the above expression. I
> will need to run some experiments to figure it out. In the mean time, I
> am fine with dropping this patch as it is a micro-optimization that
> doesn't change the behavior at all.

I don't understand why you included it, to be honest.  But it did get
me looking at the percpu code to see if it was too clever.  And that
led to the resubmission of rth's patch from two years ago that I cc'd
you on earlier.

With that patch applied, gcc should be able to choose to use the
cmov if it feels that would be a better optimisation.  It already
makes one different decision in dcache.o, namely that it uses addq
$0x1,%gs:0x0(%rip) instead of incq %gs:0x0(%rip).  Apparently this
performs better on some CPUs.

So I wouldn't spend any more time on this patch.
