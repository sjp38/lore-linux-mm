Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3A3016B0299
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 18:43:14 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id w1-v6so9735plq.8
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 15:43:14 -0700 (PDT)
Received: from bedivere.hansenpartnership.com (bedivere.hansenpartnership.com. [66.63.167.143])
        by mx.google.com with ESMTPS id b1-v6si17429567pld.323.2018.07.02.15.34.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 02 Jul 2018 15:34:43 -0700 (PDT)
Message-ID: <1530570880.3179.9.camel@HansenPartnership.com>
Subject: Re: [PATCH v5 0/6] fs/dcache: Track & limit # of negative dentries
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Mon, 02 Jul 2018 15:34:40 -0700
In-Reply-To: <20180702141811.ef027fd7d8087b7fb2ba0cce@linux-foundation.org>
References: <1530510723-24814-1-git-send-email-longman@redhat.com>
	 <CA+55aFyH6dHw-7R3364dn32J4p7kxT=TqmnuozCn9_Bz-MHhxQ@mail.gmail.com>
	 <20180702141811.ef027fd7d8087b7fb2ba0cce@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Waiman Long <longman@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>

On Mon, 2018-07-02 at 14:18 -0700, Andrew Morton wrote:
> On Mon, 2 Jul 2018 12:34:00 -0700 Linus Torvalds <torvalds@linux-foun
> dation.org> wrote:
> 
> > On Sun, Jul 1, 2018 at 10:52 PM Waiman Long <longman@redhat.com>
> > wrote:
> > > 
> > > A rogue application can potentially create a large number of
> > > negative
> > > dentries in the system consuming most of the memory available if
> > > it
> > > is not under the direct control of a memory controller that
> > > enforce
> > > kernel memory limit.
> > 
> > I certainly don't mind the patch series, but I would like it to be
> > accompanied with some actual example numbers, just to make it all a
> > bit more concrete.
> > 
> > Maybe even performance numbers showing "look, I've filled the
> > dentry
> > lists with nasty negative dentries, now it's all slower because we
> > walk those less interesting entries".
> > 
> 
> (Please cc linux-mm@kvack.org on this work)
> 
> Yup.A A The description of the user-visible impact of current behavior
> is far too vague.
> 
> In the [5/6] changelog it is mentioned that a large number of -ve
> dentries can lead to oom-killings.A A This sounds bad - -ve dentries
> should be trivially reclaimable and we shouldn't be oom-killing in
> such a situation.

If you're old enough, it's dA(C)jA  vu; Andrea went on a negative dentry
rampage about 15 years ago:

https://lkml.org/lkml/2002/5/24/71

I think the summary of the thread is that it's not worth it because
dentries are a clean cache, so they're immediately shrinkable.

> Dumb question: do we know that negative dentries are actually
> worthwhile?A A Has anyone checked in the past couple of
> decades?A A Perhaps our lookups are so whizzy nowadays that we don't
> need them?

There are still a lot of applications that keep looking up non-existent 
files, so I think it's still beneficial to keep them.  Apparently
apache still looks for a .htaccess file in every directory it
traverses, for instance.  Round tripping every one of these to disk
instead of caching it as a negative dentry would seem to be a
performance loser here.

However, actually measuring this again might be useful.

James
