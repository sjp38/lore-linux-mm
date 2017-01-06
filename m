Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9CDEA6B0272
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 17:20:16 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id b22so544735001pfd.0
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 14:20:16 -0800 (PST)
Received: from mail-pf0-x22b.google.com (mail-pf0-x22b.google.com. [2607:f8b0:400e:c00::22b])
        by mx.google.com with ESMTPS id 33si80910924pli.144.2017.01.06.14.20.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Jan 2017 14:20:15 -0800 (PST)
Received: by mail-pf0-x22b.google.com with SMTP id 189so3907266pfu.3
        for <linux-mm@kvack.org>; Fri, 06 Jan 2017 14:20:15 -0800 (PST)
Date: Fri, 6 Jan 2017 14:20:14 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, thp: add new background defrag option
In-Reply-To: <558ce85c-4cb4-8e56-6041-fc4bce2ee27f@suse.cz>
Message-ID: <alpine.DEB.2.10.1701061407300.138109@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1701041532040.67903@chino.kir.corp.google.com> <20170105101330.bvhuglbbeudubgqb@techsingularity.net> <fe83f15e-2d9f-e36c-3a89-ce1a2b39e3ca@suse.cz> <alpine.DEB.2.10.1701051446140.19790@chino.kir.corp.google.com>
 <558ce85c-4cb4-8e56-6041-fc4bce2ee27f@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 6 Jan 2017, Vlastimil Babka wrote:

> Deciding between "defer" and "background" is however confusing, and also
> doesn't indicate that the difference is related to madvise.
> 

Any suggestions for a better name for "background" are more than welcome.  

> > The kernel implementation takes less of a priority to userspace 
> > simplicitly, imo, and my patch actually cleans up much of the existing 
> > code and ends up adding fewer lines that yours.  I consider it an 
> > improvement in itself.  I don't see the benefit of allowing combined 
> > options.
> 
> I don't like bikesheding, but as this is about user-space API, more care
> should be taken than for implementation details that can change. Even
> though realistically there will be in 99% of cases only two groups of
> users setting this
> - experts like you who know what they are doing, and confusing names
> won't prevent them from making the right choice
> - people who will blindly copy/paste from the future cargo-cult websites
> (if they ever get updated from the enabled="never" recommendations), who
> likely won't stop and think about the other options.
> 

I think the far majority will go with a third option: simply use the 
kernel default and be unaware of other settings or consider it to be the 
most likely choice solely because it is the kernel default.

I think the kernel default could easily be changed to "background" after 
this and nobody would actually notice, but I don't have a strong 
preference for that.  I think users who notice large thp_fault_fallback 
and want to get the true "transparent" nature of hugepages will 
investigate defragmentation behavior and see "background" is exactly what 
they want.  Indeed, I think that the new "background" mode meshes well 
with the expectation of "transparent" hugepages.  I don't foresee any 
usecase, present or future, for "defer" so I'll simply ignore it.

So whether it's better to do echo background or echo "madvise defer" is 
not important to me, I simply imagine that the combination will be more 
difficult to describe to users.  It would break our userspace to currently 
tests for "[madvise]" and reports that state as strictly madvise to our 
mission control, but I can work around that; not sure if others would 
encounter the same issue (would "[defer madvise]" or "[defer] [madvise]" 
break fewer userspaces?).

I'd leave it to Andrew to decide whether sysfs files should accept 
multiple modes or not.  If you are to propose a patch to do so, I'd 
encourage you to do the same cleanup of triple_flag_store() that I did and 
make the gfp mask construction more straight-forward.  If you'd like to 
suggest a different name for "background", I'd be happy to change that if 
it's more descriptive.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
