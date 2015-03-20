Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f180.google.com (mail-ig0-f180.google.com [209.85.213.180])
	by kanga.kvack.org (Postfix) with ESMTP id D56DE6B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 13:02:23 -0400 (EDT)
Received: by igcau2 with SMTP id au2so24371203igc.0
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 10:02:23 -0700 (PDT)
Received: from mail-ie0-x22d.google.com (mail-ie0-x22d.google.com. [2607:f8b0:4001:c03::22d])
        by mx.google.com with ESMTPS id d19si5132969icc.71.2015.03.20.10.02.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Mar 2015 10:02:23 -0700 (PDT)
Received: by ieclw3 with SMTP id lw3so97245939iec.2
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 10:02:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150320041357.GO10105@dastard>
References: <20150317205104.GA28621@dastard>
	<CA+55aFzSPcNgxw4GC7aAV1r0P5LniyVVC66COz=3cgMcx73Nag@mail.gmail.com>
	<20150317220840.GC28621@dastard>
	<CA+55aFwne-fe_Gg-_GTUo+iOAbbNpLBa264JqSFkH79EULyAqw@mail.gmail.com>
	<CA+55aFy-Mw74rAdLMMMUgnsG3ZttMWVNGz7CXZJY7q9fqyRYfg@mail.gmail.com>
	<CA+55aFyxA9u2cVzV+S7TSY9ZvRXCX=z22YAbi9mdPVBKmqgR5g@mail.gmail.com>
	<20150319224143.GI10105@dastard>
	<CA+55aFy5UeNnFUTi619cs3b9Up2NQ1wbuyvcCS614+o3=z=wBQ@mail.gmail.com>
	<20150320002311.GG28621@dastard>
	<CA+55aFyqXDVv9JkkhvM26x6PC5V82corR7HQNxmkeGZjOCxD=A@mail.gmail.com>
	<20150320041357.GO10105@dastard>
Date: Fri, 20 Mar 2015 10:02:23 -0700
Message-ID: <CA+55aFx1pywykWa0ThcHgE7wzdVuyOBSx27iyx_FtZpYSJbKGQ@mail.gmail.com>
Subject: Re: [PATCH 4/4] mm: numa: Slow PTE scan rate if migration failures occur
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, ppc-dev <linuxppc-dev@lists.ozlabs.org>

On Thu, Mar 19, 2015 at 9:13 PM, Dave Chinner <david@fromorbit.com> wrote:
>
> Testing now. It's a bit faster - three runs gave 7m35s, 7m20s and
> 7m36s. IOWs's a bit better, but not significantly. page migrations
> are pretty much unchanged, too:
>
>            558,632      migrate:mm_migrate_pages ( +-  6.38% )

Ok. That was kind of the expected thing.

I don't really know the NUMA fault rate limiting code, but one thing
that strikes me is that if it tries to balance the NUMA faults against
the *regular* faults, then maybe just the fact that we end up taking
more COW faults after a NUMA fault then means that the NUMA rate
limiting code now gets over-eager (because it sees all those extra
non-numa faults).

Mel, does that sound at all possible? I really have never looked at
the magic automatic rate handling..

                         Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
