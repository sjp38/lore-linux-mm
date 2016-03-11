Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 192F26B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 07:12:38 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id n186so15968013wmn.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 04:12:38 -0800 (PST)
Date: Fri, 11 Mar 2016 13:12:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 02/18] mm: make vm_mmap killable
Message-ID: <20160311121235.GI27701@dhcp22.suse.cz>
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
 <1456752417-9626-3-git-send-email-mhocko@kernel.org>
 <56E29702.5030100@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56E29702.5030100@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Benjamin LaHaise <bcrl@kvack.org>, Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>, Al Viro <viro@zeniv.linux.org.uk>

On Fri 11-03-16 10:59:30, Vlastimil Babka wrote:
> On 02/29/2016 02:26 PM, Michal Hocko wrote:
> >From: Michal Hocko <mhocko@suse.com>
> >
> >All the callers of vm_mmap seem to check for the failure already
> >and bail out in one way or another on the error which means that
> 
> Hmm I'm not that sure about this one:
>   17   1071  fs/binfmt_elf.c <<load_elf_binary>>
> 
> Assigns result of vm_mmap() to "error" variable which is never checked.

Yes it is not checked but not used either. If the current got killed
then it wouldn't return to the userspace so my understanding is that not
checking this value is not a problem. At least that is my understanding.

> Shouldn't __must_check trigger here?

well, __must_check is a misleading name. It doesn't actually enforce the
value is checked. It just has to be used and an assignment is
sufficient. I was discussing this without our gcc guy and he promissed
to look and try to come up with a different attribute which would
actually work like __must_check.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
