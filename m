Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E76DB6B0274
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 05:54:16 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l201so12616854wmg.13
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 02:54:16 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id t2si2221334wmb.23.2016.10.26.02.54.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 02:54:15 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id m83so3167739wmc.6
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 02:54:15 -0700 (PDT)
Date: Wed, 26 Oct 2016 11:54:13 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: remove unnecessary __get_user_pages_unlocked() calls
Message-ID: <20161026095413.GF18382@dhcp22.suse.cz>
References: <20161025233609.5601-1-lstoakes@gmail.com>
 <20161025234631.GA5946@lucifer>
 <20161026091542.GD18382@dhcp22.suse.cz>
 <20161026093913.GA12814@lucifer>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161026093913.GA12814@lucifer>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 26-10-16 10:39:13, Lorenzo Stoakes wrote:
> On Wed, Oct 26, 2016 at 11:15:43AM +0200, Michal Hocko wrote:
> > On Wed 26-10-16 00:46:31, Lorenzo Stoakes wrote:
> > > The holdout for unexporting __get_user_pages_unlocked() is its invocation in
> > > mm/process_vm_access.c: process_vm_rw_single_vec(), as this definitely _does_
> > > seem to invoke VM_FAULT_RETRY behaviour which get_user_pages_remote() will not
> > > trigger if we were to replace it with the latter.
> >
> > I am not sure I understand. Prior to 1e9877902dc7e this used
> > get_user_pages_unlocked. What prevents us from reintroducing it with
> > FOLL_REMOVE which was meant to be added by the above commit?
> >
> > Or am I missing your point?
> 
> The issue isn't the flags being passed, rather that in this case:
> 
> a. Replacing __get_user_pages_unlocked() with get_user_pages_unlocked() won't
>    work as the latter assumes task = current and mm = current->mm but
>    process_vm_rw_single_vec() needs to pass different task, mm.

Ohh, right. I should have checked more closely.

> b. Moving to get_user_pages_remote() _will_ allow us to pass different task, mm
>    but won't however match existing behaviour precisely, since
>    __get_user_pages_unlocked() acquires mmap_sem then passes a pointer to a
>    local 'locked' variable to __get_user_pages_locked() which allows
>    VM_FAULT_RETRY to trigger.

I do not see any reason why get_user_pages_remote should implicitely
disallow VM_FAULT_RETRY. Releasing the mmap_sem on a remote task when we
have to wait for IO is a good thing in general. So I would rather see a
way to do allow that. Doing that implicitly sounds too dangerous and
maybe we even have users which wouldn't cope with the mmap sem being
dropped (get_arg_page sounds like a potential example) so I would rather
add locked * parameter to get_user_pages_remote.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
