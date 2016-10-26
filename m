Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7C0106B0282
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 05:07:09 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id k25so4693279wmi.14
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 02:07:09 -0700 (PDT)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id gq2si1307841wjb.190.2016.10.26.02.07.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 02:07:08 -0700 (PDT)
Received: by mail-wm0-f48.google.com with SMTP id 140so9259380wmv.0
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 02:07:08 -0700 (PDT)
Date: Wed, 26 Oct 2016 11:07:05 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: remove unnecessary __get_user_pages_unlocked() calls
Message-ID: <20161026090705.GA18382@dhcp22.suse.cz>
References: <20161025233609.5601-1-lstoakes@gmail.com>
 <20161026075952.GA30977@lucifer>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161026075952.GA30977@lucifer>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, kvm@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed 26-10-16 08:59:52, Lorenzo Stoakes wrote:
> On Wed, Oct 26, 2016 at 12:36:09AM +0100, Lorenzo Stoakes wrote:
> > In hva_to_pfn_slow() we are able to replace __get_user_pages_unlocked() with
> > get_user_pages_unlocked() since we can now pass gup_flags.
> >
> > In async_pf_execute() we need to pass different tsk, mm arguments so
> > get_user_pages_remote() is the sane replacement here (having added manual
> > acquisition and release of mmap_sem.)
> >
> > Since we pass a NULL pages parameter the subsequent call to
> > __get_user_pages_locked() will have previously bailed any attempt at
> > VM_FAULT_RETRY, so we do not change this behaviour by using
> > get_user_pages_remote() which does not invoke VM_FAULT_RETRY logic at all.
> >
> > Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>
> 
> Note that the use of get_user_pages_remote() in async_pf_execute() reintroduces
> the use of the FOLL_TOUCH flag - I don't think this is a problem as this flag
> was dropped by 1e987790 ("mm/gup: Introduce get_user_pages_remote()") which
> states 'Without protection keys, this patch should not change any behavior', so
> I don't think this was intentional.

Yes, I have already mentioned this in one of my previous emails. This
indeed doesn't seem to be intentional

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
