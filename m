Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 701FC6B0253
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 10:56:58 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id p65so34628204wmp.0
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 07:56:58 -0800 (PST)
Date: Thu, 10 Mar 2016 16:56:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 01/18] mm: Make mmap_sem for write waits killable for mm
 syscalls
Message-ID: <20160310155655.GB22452@dhcp22.suse.cz>
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
 <1456752417-9626-2-git-send-email-mhocko@kernel.org>
 <56E19704.6030708@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56E19704.6030708@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Benjamin LaHaise <bcrl@kvack.org>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>

On Thu 10-03-16 16:47:16, Vlastimil Babka wrote:
> On 02/29/2016 02:26 PM, Michal Hocko wrote:
> >From: Michal Hocko <mhocko@suse.com>
> >
> >This is the first step in making mmap_sem write holders killable. It
> 
> s/holders/waiters/?

right. Fixed
 
> >focuses on the trivial ones which are taking the lock early after
> >entering the syscall and they are not changing state before.
> >
> >Therefore it is very easy to change them to use down_write_killable
> >and immediately return with -EINTR. This will allow the waiter to
> >pass away without blocking the mmap_sem which might be required to
> >make a forward progress. E.g. the oom reaper will need the lock for
> >reading to dismantle the OOM victim address space.
> >
> >The only tricky function in this patch is vm_mmap_pgoff which has many
> >call sites via vm_mmap. To reduce the risk keep vm_mmap with the
> >original non-killable semantic for now.
> >
> >vm_munmap callers do not bother checking the return value so open code
> >it into the munmap syscall path for now for simplicity.
> >
> >Cc: Mel Gorman <mgorman@suse.de>
> >Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> >Cc: Konstantin Khlebnikov <koct9i@gmail.com>
> >Cc: Hugh Dickins <hughd@google.com>
> >Cc: Andrea Arcangeli <aarcange@redhat.com>
> >Cc: David Rientjes <rientjes@google.com>
> >Cc: Dave Hansen <dave.hansen@linux.intel.com>
> >Cc: Johannes Weiner <hannes@cmpxchg.org>
> >Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
