Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id C12616B0093
	for <linux-mm@kvack.org>; Sun, 15 Mar 2015 10:54:39 -0400 (EDT)
Received: by wixw10 with SMTP id w10so16890335wix.0
        for <linux-mm@kvack.org>; Sun, 15 Mar 2015 07:54:39 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fp8si12651431wic.70.2015.03.15.07.54.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 15 Mar 2015 07:54:37 -0700 (PDT)
Message-ID: <1426431270.28068.92.camel@stgolabs.net>
Subject: Re: [PATCH -next v2 0/4] mm: replace mmap_sem for mm->exe_file
 serialization
From: Davidlohr Bueso <dave@stgolabs.net>
Date: Sun, 15 Mar 2015 07:54:30 -0700
In-Reply-To: <20150315142137.GA21741@redhat.com>
References: <1426372766-3029-1-git-send-email-dave@stgolabs.net>
	 <20150315142137.GA21741@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: akpm@linux-foundation.org, viro@zeniv.linux.org.uk, gorcunov@openvz.org, koct9i@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun, 2015-03-15 at 15:21 +0100, Oleg Nesterov wrote:
> I didn't even read this version, but honestly I don't like it anyway.
> 
> I leave the review to Cyrill and Konstantin though, If they like these
> changes I won't argue.
> 
> But I simply can't understand why are you doing this.
> 
> 
> 
> Yes, this code needs cleanups, I agree. Does this series makes it better?
> To me it doesn't, and the diffstat below shows that it blows the code.

Looking at some of the caller paths now, I have to disagree.

> 
> In fact, to me it complicates this code. For example. Personally I think
> that MMF_EXE_FILE_CHANGED should die. And currently we can just remove it.

How could you remove this? I mean it's user functionality, so you need
some way of keeping track of a changed file. But you might be talking
about something else.

> Not after your patch which adds another dependency.

I don't add another dependency, I just replace the current one.

> 
> Or do you think this is performance improvement? I don't think so. Yes,
> prctl() abuses mmap_sem, but this not a hot path and the task can only
> abuse its own ->mm.

I've tried to make it as clear as possible this is a not performance
patch. I guess I've failed. Let me repeat it again: this is *not*
performance motivated ;) This kind of things under mmap_sem prevents
lock breakup.

> OK, I agree, dup_mm_exe_file() is horrible. But as I already said it can
> simply die. We can move this code into dup_mmap() and avoid another
> down_read/up_read.

If this series goes to the dumpster then ok I'll send a patch for this,
I have no objection.

> 
> Hmm. And this series is simply wrong without more changes in audit paths.
> Unfortunately this is fixable, but let me NACK at least this version ;)

Could you explain this? Are you referring to the audit.c user? If so
that caller has already been updated.

> 
> 
> Speaking of cleanups... IIRC Konstantin suggested to rcuify this pointer
> and I agree, this looks better than the new lock.

Yes, I can do that in patch 1, but as mentioned, rcu is not really the
question to me, it's the lock for when we change the exe file, so if
it's not mmap_sem we'd still need another lock. If mmap_sem is kept, yes
we can use the read lock in things like get_mm_exe_file() and still rely
on the file ref counting so we wouldn't need to do everything under rcu,
which was a though I originally had.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
