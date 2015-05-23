Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 96224829E7
	for <linux-mm@kvack.org>; Fri, 22 May 2015 21:04:38 -0400 (EDT)
Received: by wibt6 with SMTP id t6so3162395wib.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 18:04:38 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m11si728925wij.110.2015.05.22.18.04.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 18:04:36 -0700 (PDT)
Date: Sat, 23 May 2015 03:04:15 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 22/23] userfaultfd: avoid mmap_sem read recursion in
 mcopy_atomic
Message-ID: <20150523010415.GC4251@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
 <1431624680-20153-23-git-send-email-aarcange@redhat.com>
 <20150522131822.74f374dd5a75a0285577c714@linux-foundation.org>
 <20150522204809.GB4251@redhat.com>
 <20150522141830.f969b285ad072a23bb28f196@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150522141830.f969b285ad072a23bb28f196@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Fengguang Wu <fengguang.wu@intel.com>

On Fri, May 22, 2015 at 02:18:30PM -0700, Andrew Morton wrote:
> 
> There's a more serious failure with i386 allmodconfig:
> 
> fs/userfaultfd.c:145:2: note: in expansion of macro 'BUILD_BUG_ON'
>   BUILD_BUG_ON(sizeof(struct uffd_msg) != 32);
> 
> I'm surprised the feature is even reachable on i386 builds?

Unless we risk to run out of vma->vm_flags there's no particular
reason not to enable it on 32bit (even if we run out, making vm_flags
an unsigned long long is a few liner patch). Certainly it's less
useful on 32bit as there's a 3G limit but the max vmas per process are
still a small fraction of that. Especially if used for the volatile
pages on demand notification of page reclaim, it could end up useful
on arm32 (S6 is 64bit I think and latest snapdragon is too, so perhaps
it's too late anyway, but again it's not big deal).

Removing the BUILD_BUG_ON I think is not ok here because while I'm ok
to support 32bit archs, I don't want translation, the 64bit kernel
should talk with the 32bit app directly without a layer in between.

I tried to avoid using packet as without packed I could not get the
alignment wrong (and future union also couldn't get it wrong), and I
could avoid those reserved1/2/3, but it's more robust to use it in
combination with the BUILD_BUG_ON to detect right away problems like
this with 32bit builds that aligns things differently.

I'm actually surprised the buildbot that sends me email about all
archs didn't actually send me anything about it for 32bit x86?
Perhaps I'm overlooking something or x86 32bit (or any other 32bit
arch for that matter) isn't being checked?  This is actually a fairly
recent change, perhaps the buildbot was shutdown recently? That
buildbot was very useful to detect for problems like this.

===
