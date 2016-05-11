Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id BBA146B0005
	for <linux-mm@kvack.org>; Wed, 11 May 2016 07:07:39 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id rd14so5272388obb.3
        for <linux-mm@kvack.org>; Wed, 11 May 2016 04:07:39 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id m20si4213618ita.72.2016.05.11.04.07.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 May 2016 04:07:39 -0700 (PDT)
Subject: Re: [PATCH 1/2] mmap.2: clarify MAP_LOCKED semantic
References: <1431527892-2996-1-git-send-email-miso@dhcp22.suse.cz>
 <1431527892-2996-2-git-send-email-miso@dhcp22.suse.cz>
From: Peter Zijlstra <peterz@infradead.org>
Message-ID: <57331275.9000805@infradead.org>
Date: Wed, 11 May 2016 13:07:33 +0200
MIME-Version: 1.0
In-Reply-To: <1431527892-2996-2-git-send-email-miso@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <miso@dhcp22.suse.cz>, Michael Kerrisk <mtk.manpages@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>



On 05/13/2015 04:38 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.cz>
>
> MAP_LOCKED had a subtly different semantic from mmap(2)+mlock(2) since
> it has been introduced.
> mlock(2) fails if the memory range cannot get populated to guarantee
> that no future major faults will happen on the range. mmap(MAP_LOCKED) on
> the other hand silently succeeds even if the range was populated only
> partially.
>
> Fixing this subtle difference in the kernel is rather awkward because
> the memory population happens after mm locks have been dropped and so
> the cleanup before returning failure (munlock) could operate on something
> else than the originally mapped area.
>
> E.g. speculative userspace page fault handler catching SEGV and doing
> mmap(fault_addr, MAP_FIXED|MAP_LOCKED) might discard portion of a racing
> mmap and lead to lost data. Although it is not clear whether such a
> usage would be valid, mmap page doesn't explicitly describe requirements
> for threaded applications so we cannot exclude this possibility.
>
> This patch makes the semantic of MAP_LOCKED explicit and suggest using
> mmap + mlock as the only way to guarantee no later major page faults.
>

URGH, this really blows chunks. It basically means MAP_LOCKED is 
pointless cruft and we might as well remove it.

Why not fix it proper?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
