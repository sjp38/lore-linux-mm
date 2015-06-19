Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 0216D6B008A
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 10:57:13 -0400 (EDT)
Received: by wiga1 with SMTP id a1so21618428wig.0
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 07:57:12 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a5si11695502wja.1.2015.06.19.07.57.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 19 Jun 2015 07:57:10 -0700 (PDT)
Date: Fri, 19 Jun 2015 16:57:08 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RESEND PATCH V2 1/3] Add mmap flag to request pages are locked
 after page fault
Message-ID: <20150619145708.GG4913@dhcp22.suse.cz>
References: <1433942810-7852-1-git-send-email-emunson@akamai.com>
 <1433942810-7852-2-git-send-email-emunson@akamai.com>
 <20150618152907.GG5858@dhcp22.suse.cz>
 <20150618203048.GB2329@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150618203048.GB2329@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org

On Thu 18-06-15 16:30:48, Eric B Munson wrote:
> On Thu, 18 Jun 2015, Michal Hocko wrote:
[...]
> > Wouldn't it be much more reasonable and straightforward to have
> > MAP_FAULTPOPULATE as a counterpart for MAP_POPULATE which would
> > explicitly disallow any form of pre-faulting? It would be usable for
> > other usecases than with MAP_LOCKED combination.
> 
> I don't see a clear case for it being more reasonable, it is one
> possible way to solve the problem.

MAP_FAULTPOPULATE would be usable for other cases as well. E.g. fault
around is all or nothing feature. Either all mappings (which support
this) fault around or none. There is no way to tell the kernel that
this particular mapping shouldn't fault around. I haven't seen such a
request yet but we have seen requests to have a way to opt out from
a global policy in the past (e.g. per-process opt out from THP). So
I can imagine somebody will come with a request to opt out from any
speculative operations on the mapped area in the future.

> But I think it leaves us in an even
> more akward state WRT VMA flags.  As you noted in your fix for the
> mmap() man page, one can get into a state where a VMA is VM_LOCKED, but
> not present.  Having VM_LOCKONFAULT states that this was intentional, if
> we go to using MAP_FAULTPOPULATE instead of MAP_LOCKONFAULT, we no
> longer set VM_LOCKONFAULT (unless we want to start mapping it to the
> presence of two MAP_ flags).  This can make detecting the MAP_LOCKED +
> populate failure state harder.

I am not sure I understand your point here. Could you be more specific
how would you check for that and what for?

>From my understanding MAP_LOCKONFAULT is essentially
MAP_FAULTPOPULATE|MAP_LOCKED with a quite obvious semantic (unlike
single MAP_LOCKED unfortunately). I would love to also have
MAP_LOCKED|MAP_POPULATE (aka full mlock semantic) but I am really
skeptical considering how my previous attempt to make MAP_POPULATE
reasonable went.

> If this is the preferred path for mmap(), I am fine with that. 

> However,
> I would like to see the new system calls that Andrew mentioned (and that
> I am testing patches for) go in as well. 

mlock with flags sounds like a good step but I am not sure it will make
sense in the future. POSIX has screwed that and I am not sure how many
applications would use it. This ship has sailed long time ago.

> That way we give users the
> ability to request VM_LOCKONFAULT for memory allocated using something
> other than mmap.

mmap(MAP_FAULTPOPULATE); mlock() would have the same semantic even
without changing mlock syscall.
 
> > > This patch introduces the ability to request that pages are not
> > > pre-faulted, but are placed on the unevictable LRU when they are finally
> > > faulted in.
> > > 
> > > To keep accounting checks out of the page fault path, users are billed
> > > for the entire mapping lock as if MAP_LOCKED was used.
> > > 
> > > Signed-off-by: Eric B Munson <emunson@akamai.com>
> > > Cc: Michal Hocko <mhocko@suse.cz>
> > > Cc: linux-alpha@vger.kernel.org
> > > Cc: linux-kernel@vger.kernel.org
> > > Cc: linux-mips@linux-mips.org
> > > Cc: linux-parisc@vger.kernel.org
> > > Cc: linuxppc-dev@lists.ozlabs.org
> > > Cc: sparclinux@vger.kernel.org
> > > Cc: linux-xtensa@linux-xtensa.org
> > > Cc: linux-mm@kvack.org
> > > Cc: linux-arch@vger.kernel.org
> > > Cc: linux-api@vger.kernel.org
> > > ---
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
