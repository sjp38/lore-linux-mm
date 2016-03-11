Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 61DAE6B0005
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 06:54:22 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id l68so15001073wml.0
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 03:54:22 -0800 (PST)
Subject: Re: [PATCH 11/18] coredump: make coredump_wait wait for mma_sem for
 write killable
References: <1456752417-9626-1-git-send-email-mhocko@kernel.org>
 <1456752417-9626-12-git-send-email-mhocko@kernel.org>
 <56E2ACE7.50008@suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56E2B1E9.90201@suse.cz>
Date: Fri, 11 Mar 2016 12:54:17 +0100
MIME-Version: 1.0
In-Reply-To: <56E2ACE7.50008@suse.cz>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Deucher <alexander.deucher@amd.com>, Alex Thorlton <athorlton@sgi.com>, Andrea Arcangeli <aarcange@redhat.com>, Andy Lutomirski <luto@amacapital.net>, Benjamin LaHaise <bcrl@kvack.org>, =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>, Daniel Vetter <daniel.vetter@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, David Airlie <airlied@linux.ie>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-arch@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Petr Cermak <petrcermak@chromium.org>, Thomas Gleixner <tglx@linutronix.de>, Michal Hocko <mhocko@suse.com>

On 03/11/2016 12:32 PM, Vlastimil Babka wrote:
> On 02/29/2016 02:26 PM, Michal Hocko wrote:
>> From: Michal Hocko <mhocko@suse.com>
>>
>> coredump_wait waits for mmap_sem for write currently which can
>> prevent oom_reaper to reclaim the oom victims address space
>> asynchronously because that requires mmap_sem for read. This might
>> happen if the oom victim is multi threaded and some thread(s) is
>> holding mmap_sem for read (e.g. page fault) and it is stuck in
>> the page allocator while other thread(s) reached coredump_wait
>> already.
>>
>> This patch simply uses down_write_killable and bails out with EINTR
>> if the lock got interrupted by the fatal signal. do_coredump will
>> return right away and do_group_exit will take care to zap the whole
>> thread group.
>>
>> Cc: Oleg Nesterov <oleg@redhat.com>
>> Signed-off-by: Michal Hocko <mhocko@suse.com>
>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Forgot to point out typo in Subject which makes it hard to grep for mmap_sem

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
