Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 851FB6B0253
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 11:28:43 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id p65so76319713wmp.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 08:28:43 -0800 (PST)
Date: Mon, 29 Feb 2016 17:28:40 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 15/18] uprobes: wait for mmap_sem for write killable
Message-ID: <20160229162840.GH16930@dhcp22.suse.cz>
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
 <1456752417-9626-16-git-send-email-mhocko@kernel.org>
 <20160229155712.GA1964@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160229155712.GA1964@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Benjamin LaHaise <bcrl@kvack.org>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>

On Mon 29-02-16 16:57:13, Oleg Nesterov wrote:
> On 02/29, Michal Hocko wrote:
> >
> > --- a/kernel/events/uprobes.c
> > +++ b/kernel/events/uprobes.c
> > @@ -1130,7 +1130,9 @@ static int xol_add_vma(struct mm_struct *mm, struct xol_area *area)
> >  	struct vm_area_struct *vma;
> >  	int ret;
> >
> > -	down_write(&mm->mmap_sem);
> > +	if (down_write_killable(&mm->mmap_sem))
> > +		return -EINTR;
> > +
> 
> Yes, but then dup_xol_work() should probably check fatal_signal_pending() to
> suppress uprobe_warn(), the warning looks like a kernel problem.

Ahh, I see. I didn't understand what is the purpose of the warning. Does
the following work for you?
---
diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index a79315d0f711..fb4a6bcc88ce 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -1470,7 +1470,8 @@ static void dup_xol_work(struct callback_head *work)
 	if (current->flags & PF_EXITING)
 		return;
 
-	if (!__create_xol_area(current->utask->dup_xol_addr))
+	if (!__create_xol_area(current->utask->dup_xol_addr) &&
+			!fatal_signal_pending(current)
 		uprobe_warn(current, "dup xol area");
 }
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
