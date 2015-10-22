Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 46F6F6B0257
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 11:31:00 -0400 (EDT)
Received: by obbwb3 with SMTP id wb3so70870033obb.0
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 08:31:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id dp7si9153892oeb.44.2015.10.22.08.30.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 08:30:59 -0700 (PDT)
Date: Thu, 22 Oct 2015 17:30:55 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 14/23] userfaultfd: wake pending userfaults
Message-ID: <20151022153055.GC1331@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
 <1431624680-20153-15-git-send-email-aarcange@redhat.com>
 <20151022121056.GB7520@twins.programming.kicks-ass.net>
 <20151022132015.GF19147@redhat.com>
 <20151022133824.GR17308@twins.programming.kicks-ass.net>
 <20151022141831.GA1331@redhat.com>
 <20151022151509.GO3604@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151022151509.GO3604@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

On Thu, Oct 22, 2015 at 05:15:09PM +0200, Peter Zijlstra wrote:
> Indefinitely is such a long time, we should try and finish
> computation before the computer dies etc. :-)

Indefinitely as read_seqcount_retry, eventually it makes progress.

Even returning 0 from the page fault can trigger it again
indefinitely, so VM_FAULT_RETRY isn't fundamentally different from
returning 0 and retrying the page fault again later. So it's not clear
why VM_FAULT_RETRY can only try once more.

FAULT_FLAG_TRIED as a message to the VM so it starts to do heavy
locking and block more aggressively is actually useful as such, but it
shouldn't be a replacement of FAULT_FLAG_ALLOW_RETRY. What I meant
with removing FAULT_FLAG_TRIED is really about converting it to an
hint, but not controlling if the page fault can keep retrying
in-kernel.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
