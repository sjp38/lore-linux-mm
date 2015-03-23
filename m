Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id A665F6B0038
	for <linux-mm@kvack.org>; Mon, 23 Mar 2015 08:01:37 -0400 (EDT)
Received: by wixw10 with SMTP id w10so33469889wix.0
        for <linux-mm@kvack.org>; Mon, 23 Mar 2015 05:01:37 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i10si11436882wif.64.2015.03.23.05.01.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 23 Mar 2015 05:01:35 -0700 (PDT)
Date: Mon, 23 Mar 2015 12:01:31 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/4] mm: numa: Slow PTE scan rate if migration failures
 occur
Message-ID: <20150323120131.GB4701@suse.de>
References: <20150317220840.GC28621@dastard>
 <CA+55aFwne-fe_Gg-_GTUo+iOAbbNpLBa264JqSFkH79EULyAqw@mail.gmail.com>
 <CA+55aFy-Mw74rAdLMMMUgnsG3ZttMWVNGz7CXZJY7q9fqyRYfg@mail.gmail.com>
 <CA+55aFyxA9u2cVzV+S7TSY9ZvRXCX=z22YAbi9mdPVBKmqgR5g@mail.gmail.com>
 <20150319224143.GI10105@dastard>
 <CA+55aFy5UeNnFUTi619cs3b9Up2NQ1wbuyvcCS614+o3=z=wBQ@mail.gmail.com>
 <20150320002311.GG28621@dastard>
 <CA+55aFyqXDVv9JkkhvM26x6PC5V82corR7HQNxmkeGZjOCxD=A@mail.gmail.com>
 <20150320041357.GO10105@dastard>
 <CA+55aFx1pywykWa0ThcHgE7wzdVuyOBSx27iyx_FtZpYSJbKGQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFx1pywykWa0ThcHgE7wzdVuyOBSx27iyx_FtZpYSJbKGQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, ppc-dev <linuxppc-dev@lists.ozlabs.org>

On Fri, Mar 20, 2015 at 10:02:23AM -0700, Linus Torvalds wrote:
> On Thu, Mar 19, 2015 at 9:13 PM, Dave Chinner <david@fromorbit.com> wrote:
> >
> > Testing now. It's a bit faster - three runs gave 7m35s, 7m20s and
> > 7m36s. IOWs's a bit better, but not significantly. page migrations
> > are pretty much unchanged, too:
> >
> >            558,632      migrate:mm_migrate_pages ( +-  6.38% )
> 
> Ok. That was kind of the expected thing.
> 
> I don't really know the NUMA fault rate limiting code, but one thing
> that strikes me is that if it tries to balance the NUMA faults against
> the *regular* faults, then maybe just the fact that we end up taking
> more COW faults after a NUMA fault then means that the NUMA rate
> limiting code now gets over-eager (because it sees all those extra
> non-numa faults).
> 
> Mel, does that sound at all possible? I really have never looked at
> the magic automatic rate handling..
> 

It should not be trying to balance against regular faults as it has no
information on it. The trapping of additional faults to mark the PTE
writable will alter timing so it indirectly affects how many migration
faults there but this is only a side-effect IMO.

There is more overhead now due to losing the writable information and
that should be reduced so I tried a few approaches.  Ultimately, the one
that performed the best and was easiest to understand simply preserved
the writable bit across the protection update and page fault. I'll post
it later when I stick a changelog on it.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
