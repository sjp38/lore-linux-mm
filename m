Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id C56A66B0291
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 18:21:22 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id x2-v6so10658306plv.0
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 15:21:22 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f17-v6si14896786pgv.383.2018.07.02.15.21.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 02 Jul 2018 15:21:21 -0700 (PDT)
Date: Mon, 2 Jul 2018 15:21:05 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v5 0/6] fs/dcache: Track & limit # of negative dentries
Message-ID: <20180702222105.GA2438@bombadil.infradead.org>
References: <1530510723-24814-1-git-send-email-longman@redhat.com>
 <CA+55aFyH6dHw-7R3364dn32J4p7kxT=TqmnuozCn9_Bz-MHhxQ@mail.gmail.com>
 <20180702141811.ef027fd7d8087b7fb2ba0cce@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180702141811.ef027fd7d8087b7fb2ba0cce@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <longman@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Larry Woodman <lwoodman@redhat.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>

On Mon, Jul 02, 2018 at 02:18:11PM -0700, Andrew Morton wrote:
> In the [5/6] changelog it is mentioned that a large number of -ve
> dentries can lead to oom-killings.  This sounds bad - -ve dentries
> should be trivially reclaimable and we shouldn't be oom-killing in such
> a situation.
> 
> Dumb question: do we know that negative dentries are actually
> worthwhile?  Has anyone checked in the past couple of decades?  Perhaps
> our lookups are so whizzy nowadays that we don't need them?

I can't believe that's true.  Have you looked at strace of a typical
program startup recently?

$ strace -o ls.out ls 
$ grep -c ENOENT ls.out 
10

There's a few duplicates in there (6 accesses to /etc/ld.so.nohwcap), so
we definitely want those negative entries.
