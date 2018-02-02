Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id E54F26B0006
	for <linux-mm@kvack.org>; Fri,  2 Feb 2018 01:20:50 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id g16so3030457wmg.6
        for <linux-mm@kvack.org>; Thu, 01 Feb 2018 22:20:50 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id j59si968150wrj.180.2018.02.01.22.20.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Feb 2018 22:20:48 -0800 (PST)
Date: Fri, 2 Feb 2018 06:20:37 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: possible deadlock in get_user_pages_unlocked
Message-ID: <20180202062037.GH30522@ZenIV.linux.org.uk>
References: <001a113f6344393d89056430347d@google.com>
 <20180202045020.GF30522@ZenIV.linux.org.uk>
 <20180202053502.GB949@zzz.localdomain>
 <20180202054626.GG30522@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180202054626.GG30522@ZenIV.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Biggers <ebiggers3@gmail.com>
Cc: syzbot <syzbot+bacbe5d8791f30c9cee5@syzkaller.appspotmail.com>, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, dan.j.williams@intel.com, james.morse@arm.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mingo@kernel.org, syzkaller-bugs@googlegroups.com

On Fri, Feb 02, 2018 at 05:46:26AM +0000, Al Viro wrote:
> On Thu, Feb 01, 2018 at 09:35:02PM -0800, Eric Biggers wrote:
> 
> > Try starting up multiple instances of the program; that sometimes helps with
> > these races that are hard to hit (since you may e.g. have a different number of
> > CPUs than syzbot used).  If I start up 4 instances I see the lockdep splat after
> > around 2-5 seconds.
> 
> 5 instances in parallel, 10 minutes into the run...
> 
> >  This is on latest Linus tree (4bf772b1467).  Also note the
> > reproducer uses KVM, so if you're running it in a VM it will only work if you've
> > enabled nested virtualization on the host (kvm_intel.nested=1).
> 
> cat /sys/module/kvm_amd/parameters/nested 
> 1
> 
> on host
> 
> > Also it appears to go away if I revert ce53053ce378c21 ("kvm: switch
> > get_user_page_nowait() to get_user_pages_unlocked()").
> 
> That simply prevents this reproducer hitting get_user_pages_unlocked()
> instead of grab mmap_sem/get_user_pages/drop mmap_sem.  I.e. does not
> allow __get_user_pages_locked() to drop/regain ->mmap_sem.
> 
> The bug may be in the way we call get_user_pages_unlocked() in that
> commit, but it might easily be a bug in __get_user_pages_locked()
> exposed by that reproducer somehow.

I think I understand what's going on.  FOLL_NOWAIT handling is a serious
mess ;-/  I'll probably have something to test tomorrow - I still can't
reproduce it here, unfortunately.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
