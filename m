Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id BD3706B025E
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 17:04:29 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id u5so1005605524pgi.7
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 14:04:29 -0800 (PST)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id h184si43011967pfc.168.2017.01.04.14.04.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 14:04:28 -0800 (PST)
Received: by mail-pf0-x22f.google.com with SMTP id 189so84045990pfz.3
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 14:04:28 -0800 (PST)
Date: Wed, 4 Jan 2017 14:04:27 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, thp: always direct reclaim for MADV_HUGEPAGE even
 when deferred
In-Reply-To: <75bf7af0-76e8-2d8e-cb00-745fd06c42ef@suse.cz>
Message-ID: <alpine.DEB.2.10.1701041353220.77987@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1612211621210.100462@chino.kir.corp.google.com> <bba4c707-c470-296c-edbe-b8a6d21152ad@suse.cz> <alpine.DEB.2.10.1701031431120.139238@chino.kir.corp.google.com> <75bf7af0-76e8-2d8e-cb00-745fd06c42ef@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 4 Jan 2017, Vlastimil Babka wrote:

> > Hmm, is there a significant benefit to setting "defer" rather than "never" 
> > if you can rely on khugepaged to trigger compaction when it tries to 
> > allocate.  I suppose if there is nothing to collapse that this won't do 
> > compaction, but is this not intended for users who always want to defer 
> > when not immediately available?
> 
> I guess two things
> - khugepaged is quite sleepy and will not respond to demand quickly, so
> it won't compact that much than kcompactd triggered by "defer"

That's configurable, so if a user sets defrag to never, they also have the 
ability to make khugepaged more aggressive in the background to complement 
that decision.

> I don't think the primary motivation for "defer" was to restrict
> MADV_HUGEPAGE apps, but rather to prevent latency to the majority of
> apps oblivious to THP when the default was "always". On the other hand,
> setting "madvise" would make performance needlessly worse in some
> scenarios, so "defer" is a compromise that tries to provide THP's but
> without the latency, and still much more timely than khugepaged.
> 

It's disappointing we need to have an option that exists solely to 
suppress a userspace MADV_HUGEPAGE and not actually fix the userspace to 
not do the MADV_HUGEPAGE in the first place by making it configurable.  
That is backwards compatible and doesn't require a new kernel version.  
This never gets answered in the thread, however, and I offered to make the 
very trivial patch to qemu to do that for the translation buffer but 
nobody who uses qemu is even asking for this.  It's baffling.

> >> So would something like this be possible?
> >>
> >>> echo "defer madvise" > /sys/kernel/mm/transparent_hugepage/defrag
> >>> cat /sys/kernel/mm/transparent_hugepage/defrag
> >> always [defer] [madvise] never
> >>
> >> I'm not sure about the analogous kernel boot option though, I guess
> >> those can't use spaces, so maybe comma-separated?
> 
> No opinion on the above? I think it could be somewhat more elegant than
> a fifth-option that Mel said he would prefer, and deliver the same
> flexibility.
> 

I think this would work, but I'm concerned about two things: (1) the 
kernel command line format as you pointed out earlier, (2) allowing two 
options to be combined but not other options (always + never), so it takes 
even more explaining to do to say what you can actually formulate and 
what the results of that combining is.  The tristate, quadstate, and now 
quint-state options for thp were never extendable, but now this appears to 
be the most desired option.  We can await the bug reports of users who say 
their MADV_HUGEPAGE is a no-op, though, and tell them their admin needs to 
switch away from "defer" if anybody actually ever uses that setting.

I think you, me, and Kirill are mostly on the same page with respect to 
this, but I can't argue against hypothetical usecases and how we need to 
wait years for "defer" to be available to see if any bug reports are 
generated to make a decision in this area, so my final proposal in this 
matter will be the reluctant fifth option and if it doesn't work I'll just 
carry this for ourselves (we have no use for "defer" without this patch).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
