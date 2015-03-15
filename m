Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 823346B00AE
	for <linux-mm@kvack.org>; Sun, 15 Mar 2015 11:28:51 -0400 (EDT)
Received: by wgbcc7 with SMTP id cc7so21900643wgb.0
        for <linux-mm@kvack.org>; Sun, 15 Mar 2015 08:28:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id lh10si12807173wjb.88.2015.03.15.08.28.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Mar 2015 08:28:49 -0700 (PDT)
Date: Sun, 15 Mar 2015 16:26:52 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH -next v2 0/4] mm: replace mmap_sem for mm->exe_file
	serialization
Message-ID: <20150315152652.GA24590@redhat.com>
References: <1426372766-3029-1-git-send-email-dave@stgolabs.net> <20150315142137.GA21741@redhat.com> <1426431270.28068.92.camel@stgolabs.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1426431270.28068.92.camel@stgolabs.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <dave@stgolabs.net>
Cc: akpm@linux-foundation.org, viro@zeniv.linux.org.uk, gorcunov@openvz.org, koct9i@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/15, Davidlohr Bueso wrote:
>
> On Sun, 2015-03-15 at 15:21 +0100, Oleg Nesterov wrote:
> > I didn't even read this version, but honestly I don't like it anyway.
> >
> > I leave the review to Cyrill and Konstantin though, If they like these
> > changes I won't argue.
> >
> > But I simply can't understand why are you doing this.
> >
> >
> >
> > Yes, this code needs cleanups, I agree. Does this series makes it better?
> > To me it doesn't, and the diffstat below shows that it blows the code.
>
> Looking at some of the caller paths now, I have to disagree.

And I believe you are wrong. But let me repeat, I leave this to Cyrill
and Konstantin. Cleanups are always subjective.

> > In fact, to me it complicates this code. For example. Personally I think
> > that MMF_EXE_FILE_CHANGED should die. And currently we can just remove it.
>
> How could you remove this?

Just remove this flag and the test_and_set_bit(MMF_EXE_FILE_CHANGED) check.
Again, this is subjective, but to me it looks ugly. Why do we allow to
change ->exe_file but only once?

> > Not after your patch which adds another dependency.
>
> I don't add another dependency, I just replace the current one.

But you did. If we remove test_and_set_bit(MMF_EXE_FILE_CHANGED)
set_mm_exe_file() becomes racy with your patch. Sure, this is fixable too.

> > Or do you think this is performance improvement? I don't think so. Yes,
> > prctl() abuses mmap_sem, but this not a hot path and the task can only
> > abuse its own ->mm.
>
> I've tried to make it as clear as possible this is a not performance
> patch. I guess I've failed. Let me repeat it again: this is *not*
> performance motivated ;)

OK.

> This kind of things under mmap_sem prevents
> lock breakup.

Could you spell?

> > Hmm. And this series is simply wrong without more changes in audit paths.
> > Unfortunately this is fixable, but let me NACK at least this version ;)
>
> Could you explain this? Are you referring to the audit.c user? If so
> that caller has already been updated.

I do not see these changes in Linus's tree. OK, if those caller's were
already changed somewhere else then unfortunately I can't nack this patch
by technical reasons ;)

But perhaps you should mention that this change depends on other patches
and name them.

> > Speaking of cleanups... IIRC Konstantin suggested to rcuify this pointer
> > and I agree, this looks better than the new lock.
>
> Yes, I can do that in patch 1, but as mentioned, rcu is not really the
> question to me, it's the lock for when we change the exe file, so if
> it's not mmap_sem we'd still need another lock.

Not if we keep MMF_EXE_FILE_CHANGED. See above, we can change it lockless.
And even without MMF_EXE_FILE_CHANGED, we can use xchg().

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
