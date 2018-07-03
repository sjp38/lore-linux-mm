Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id A48C56B0003
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 05:18:26 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b12-v6so661224edi.12
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 02:18:26 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g3-v6si794524edg.360.2018.07.03.02.18.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 02:18:24 -0700 (PDT)
Date: Tue, 3 Jul 2018 11:18:21 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH v5 0/6] fs/dcache: Track & limit # of negative dentries
Message-ID: <20180703091821.oiywpdxd6rhtxl4p@quack2.suse.cz>
References: <1530510723-24814-1-git-send-email-longman@redhat.com>
 <CA+55aFyH6dHw-7R3364dn32J4p7kxT=TqmnuozCn9_Bz-MHhxQ@mail.gmail.com>
 <20180702141811.ef027fd7d8087b7fb2ba0cce@linux-foundation.org>
 <1530570880.3179.9.camel@HansenPartnership.com>
 <20180702161925.1c717283dd2bd4a221bc987c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180702161925.1c717283dd2bd4a221bc987c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <longman@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Miklos Szeredi <mszeredi@redhat.com>, Matthew Wilcox <willy@infradead.org>, Larry Woodman <lwoodman@redhat.com>, "Wangkai (Kevin,C)" <wangkai86@huawei.com>, linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>

On Mon 02-07-18 16:19:25, Andrew Morton wrote:
> On Mon, 02 Jul 2018 15:34:40 -0700 James Bottomley <James.Bottomley@HansenPartnership.com> wrote:
> 
> > On Mon, 2018-07-02 at 14:18 -0700, Andrew Morton wrote:
> > > On Mon, 2 Jul 2018 12:34:00 -0700 Linus Torvalds <torvalds@linux-foun
> > > dation.org> wrote:
> > > 
> > > > On Sun, Jul 1, 2018 at 10:52 PM Waiman Long <longman@redhat.com>
> > > > wrote:
> > > > > 
> > > > > A rogue application can potentially create a large number of
> > > > > negative
> > > > > dentries in the system consuming most of the memory available if
> > > > > it
> > > > > is not under the direct control of a memory controller that
> > > > > enforce
> > > > > kernel memory limit.
> > > > 
> > > > I certainly don't mind the patch series, but I would like it to be
> > > > accompanied with some actual example numbers, just to make it all a
> > > > bit more concrete.
> > > > 
> > > > Maybe even performance numbers showing "look, I've filled the
> > > > dentry
> > > > lists with nasty negative dentries, now it's all slower because we
> > > > walk those less interesting entries".
> > > > 
> > > 
> > > (Please cc linux-mm@kvack.org on this work)
> > > 
> > > Yup.  The description of the user-visible impact of current behavior
> > > is far too vague.
> > > 
> > > In the [5/6] changelog it is mentioned that a large number of -ve
> > > dentries can lead to oom-killings.  This sounds bad - -ve dentries
> > > should be trivially reclaimable and we shouldn't be oom-killing in
> > > such a situation.
> > 
> > If you're old enough, it's deja vu; Andrea went on a negative dentry
> > rampage about 15 years ago:
> > 
> > https://lkml.org/lkml/2002/5/24/71
> 
> That's kinda funny.
> 
> > I think the summary of the thread is that it's not worth it because
> > dentries are a clean cache, so they're immediately shrinkable.
> 
> Yes, "should be".  I could understand that the presence of huge
> nunmbers of -ve dentries could result in undesirable reclaim of
> pagecache, etc.  Triggering oom-killings is very bad, and presumably
> has the same cause.
> 
> Before we go and add a large amount of code to do the shrinker's job
> for it, we should get a full understanding of what's going wrong.  Is
> it because the dentry_lru had a mixture of +ve and -ve dentries? 
> Should we have a separate LRU for -ve dentries?  Are we appropriately
> aging the various dentries?  etc.
> 
> It could be that tuning/fixing the current code will fix whatever
> problems inspired this patchset.

What I think is contributing to the problems and could lead to reclaim
oddities is the internal fragmentation of dentry slab cache. Dentries are
relatively small, you get 21 per page on my system, so if trivial to
reclaim negative dentries get mixed with a small amount of unreclaimable
positive dentries, you can get a lot of pages in dentry slab cache that are
unreclaimable.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
