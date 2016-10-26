Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 94F8E6B0274
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 05:39:17 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id l124so2021071wml.4
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 02:39:17 -0700 (PDT)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id lz10si1405860wjb.276.2016.10.26.02.39.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 02:39:16 -0700 (PDT)
Received: by mail-wm0-x234.google.com with SMTP id d128so75185850wmf.1
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 02:39:16 -0700 (PDT)
Date: Wed, 26 Oct 2016 10:39:13 +0100
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: Re: [PATCH] mm: remove unnecessary __get_user_pages_unlocked() calls
Message-ID: <20161026093913.GA12814@lucifer>
References: <20161025233609.5601-1-lstoakes@gmail.com>
 <20161025234631.GA5946@lucifer>
 <20161026091542.GD18382@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161026091542.GD18382@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Oct 26, 2016 at 11:15:43AM +0200, Michal Hocko wrote:
> On Wed 26-10-16 00:46:31, Lorenzo Stoakes wrote:
> > The holdout for unexporting __get_user_pages_unlocked() is its invocation in
> > mm/process_vm_access.c: process_vm_rw_single_vec(), as this definitely _does_
> > seem to invoke VM_FAULT_RETRY behaviour which get_user_pages_remote() will not
> > trigger if we were to replace it with the latter.
>
> I am not sure I understand. Prior to 1e9877902dc7e this used
> get_user_pages_unlocked. What prevents us from reintroducing it with
> FOLL_REMOVE which was meant to be added by the above commit?
>
> Or am I missing your point?

The issue isn't the flags being passed, rather that in this case:

a. Replacing __get_user_pages_unlocked() with get_user_pages_unlocked() won't
   work as the latter assumes task = current and mm = current->mm but
   process_vm_rw_single_vec() needs to pass different task, mm.

b. Moving to get_user_pages_remote() _will_ allow us to pass different task, mm
   but won't however match existing behaviour precisely, since
   __get_user_pages_unlocked() acquires mmap_sem then passes a pointer to a
   local 'locked' variable to __get_user_pages_locked() which allows
   VM_FAULT_RETRY to trigger.

The main issue I had here was not being sure whether we care about the
VM_FAULT_RETRY functionality being used here or not, if we don't care then we
can just move to get_user_pages_remote(), otherwise perhaps this should be left
alone or maybe we need to consider adjusting the API to allow for remote access
with VM_FAULT_RETRY functionality.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
