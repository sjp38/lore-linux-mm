Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 8CEDA6B00B1
	for <linux-mm@kvack.org>; Sun, 15 Mar 2015 11:42:13 -0400 (EDT)
Received: by wixw10 with SMTP id w10so23685164wix.0
        for <linux-mm@kvack.org>; Sun, 15 Mar 2015 08:42:13 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id vm4si12866309wjc.66.2015.03.15.08.42.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 15 Mar 2015 08:42:12 -0700 (PDT)
Message-ID: <1426434125.28068.100.camel@stgolabs.net>
Subject: Re: [PATCH -next v2 0/4] mm: replace mmap_sem for mm->exe_file
 serialization
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Sun, 15 Mar 2015 08:42:05 -0700
In-Reply-To: <20150315152652.GA24590@redhat.com>
References: <1426372766-3029-1-git-send-email-dave@stgolabs.net>
	 <20150315142137.GA21741@redhat.com>
	 <1426431270.28068.92.camel@stgolabs.net>
	 <20150315152652.GA24590@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: akpm@linux-foundation.org, viro@zeniv.linux.org.uk, gorcunov@openvz.org, koct9i@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 2015-03-15 at 16:26 +0100, Oleg Nesterov wrote:
> On 03/15, Davidlohr Bueso wrote:
> >
> > On Sun, 2015-03-15 at 15:21 +0100, Oleg Nesterov wrote:
> > > I didn't even read this version, but honestly I don't like it anyway.
> > >
> > > I leave the review to Cyrill and Konstantin though, If they like these
> > > changes I won't argue.
> > >
> > > But I simply can't understand why are you doing this.
> > >
> > >
> > >
> > > Yes, this code needs cleanups, I agree. Does this series makes it better?
> > > To me it doesn't, and the diffstat below shows that it blows the code.
> >
> > Looking at some of the caller paths now, I have to disagree.
> 
> And I believe you are wrong. But let me repeat, I leave this to Cyrill
> and Konstantin. Cleanups are always subjective.
> 
> > > In fact, to me it complicates this code. For example. Personally I think
> > > that MMF_EXE_FILE_CHANGED should die. And currently we can just remove it.
> >
> > How could you remove this?
> 
> Just remove this flag and the test_and_set_bit(MMF_EXE_FILE_CHANGED) check.
> Again, this is subjective, but to me it looks ugly. Why do we allow to
> change ->exe_file but only once?

Ok I think I am finally seeing where you are going. And I like it *a
lot* because it allows us to basically replace mmap_sem with rcu
(MMF_EXE_FILE_CHANGED being the only user that requires a lock!!), but
am afraid it might not be possible. I mean currently we have no rule wrt
to users that don't deal with prctl. 

Forbidding multiple exe_file changes to be generic would certainly
change address space semantics, probably for the better (tighter around
security), but changed nonetheless so users would have a right to
complain, no? So if we can get away with removing MMF_EXE_FILE_CHANGED
I'm all for it. Andrew?

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
