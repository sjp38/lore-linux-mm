Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 64A6D6B0009
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 22:09:24 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id ho8so15174575pac.2
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 19:09:24 -0800 (PST)
Received: from mail-pf0-x22e.google.com (mail-pf0-x22e.google.com. [2607:f8b0:400e:c00::22e])
        by mx.google.com with ESMTPS id r71si6853894pfa.179.2016.01.27.19.09.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 19:09:22 -0800 (PST)
Received: by mail-pf0-x22e.google.com with SMTP id n128so15366534pfn.3
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 19:09:22 -0800 (PST)
Date: Wed, 27 Jan 2016 19:09:13 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: fork on processes with lots of memory
In-Reply-To: <20160126162853.GA1836@qarx.de>
Message-ID: <alpine.LSU.2.11.1601271905210.2349@eggly.anvils>
References: <20160126160641.GA530@qarx.de> <20160126162853.GA1836@qarx.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Felix von Leitner <felix-linuxkernel@fefe.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 26 Jan 2016, Felix von Leitner wrote:
> > Dear Linux kernel devs,
> 
> > I talked to someone who uses large Linux based hardware to run a
> > process with huge memory requirements (think 4 GB), and he told me that
> > if they do a fork() syscall on that process, the whole system comes to
> > standstill. And not just for a second or two. He said they measured a 45
> > minute (!) delay before the system became responsive again.
> 
> I'm sorry, I meant 4 TB not 4 GB.
> I'm not used to working with that kind of memory sizes.
> 
> > Their working theory is that all the pages need to be marked copy-on-write
> > in both processes, and if you touch one page, a copy needs to be made,
> > and than just takes a while if you have a billion pages.
> 
> > I was wondering if there is any advice for such situations from the
> > memory management people on this list.
> 
> > In this case the fork was for an execve afterwards, but I was going to
> > recommend fork to them for something else that can not be tricked around
> > with vfork.
> 
> > Can anyone comment on whether the 45 minute number sounds like it could
> > be real? When I heard it, I was flabberghasted. But the other person
> > swore it was real. Can a fork cause this much of a delay? Is there a way
> > to work around it?
> 
> > I was going to recommend the fork to create a boundary between the
> > processes, so that you can recover from memory corruption in one
> > process. In fact, after the fork I would want to munmap almost all of
> > the shared pages anyway, but there is no way to tell fork that.

You might find madvise(addr, length, MADV_DONTFORK) helpful:
that tells fork not to duplicate the given range in the child.

Hugh

> 
> > Thanks,
> 
> > Felix
> 
> > PS: Please put me on Cc if you reply, I'm not subscribed to this mailing
> > list.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
