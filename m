Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id F2B8A6B0282
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 04:55:50 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id u187so4823652wmd.8
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 01:55:50 -0700 (PDT)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id bb10si1270540wjb.161.2016.10.26.01.55.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 01:55:49 -0700 (PDT)
Received: by mail-wm0-x241.google.com with SMTP id z194so1209117wmd.5
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 01:55:49 -0700 (PDT)
Date: Wed, 26 Oct 2016 09:55:47 +0100
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: Re: [PATCH 00/10] mm: adjust get_user_pages* functions to explicitly
 pass FOLL_* flags
Message-ID: <20161026085547.GA3737@lucifer>
References: <20161013002020.3062-1-lstoakes@gmail.com>
 <20161018153050.GC13117@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161018153050.GC13117@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On Tue, Oct 18, 2016 at 05:30:50PM +0200, Michal Hocko wrote:
>I am wondering whether we can go further. E.g. it is not really clear to
>me whether we need an explicit FOLL_REMOTE when we can in fact check
>mm != current->mm and imply that. Maybe there are some contexts which
>wouldn't work, I haven't checked.
>
>Then I am also wondering about FOLL_TOUCH behavior.
>__get_user_pages_unlocked has only few callers which used to be
>get_user_pages_unlocked before 1e9877902dc7e ("mm/gup: Introduce
>get_user_pages_remote()"). To me a dropped FOLL_TOUCH seems
>unintentional. Now that get_user_pages_unlocked has gup_flags argument I
>guess we might want to get rid of the __g-u-p-u version altogether, no?
>
>__get_user_pages is quite low level and imho shouldn't be exported. It's
>only user - kvm - should rather pull those two functions to gup instead
>and export them. There is nothing really KVM specific in them.

I believe I've attacked each of these, other than the use of explicit
FOLL_REMOTE which was explained by Dave.

> I also cannot say I would be entirely thrilled about get_user_pages_locked,
> we only have one user which can simply do lock g-u-p unlock AFAICS.

The principle difference here seems to be the availability of VM_FAULT_RETRY
behaviour (by passing a non-NULL locked argument), and indeed the comments in
gup.c recommends using get_user_pages_locked() if possible (though it seems not
to have been heeded too much :), so I'm not sure if this would be a fruitful
refactor, let me know!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
