Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 01B1E6B0069
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 17:24:13 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id i17so11066441otb.2
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 14:24:12 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l46si5357383otb.119.2017.12.11.14.24.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Dec 2017 14:24:12 -0800 (PST)
Subject: Re: [patch 1/2] mm, mmu_notifier: annotate mmu notifiers with
 blockable invalidate callbacks
References: <alpine.DEB.2.10.1712111409090.196232@chino.kir.corp.google.com>
From: Paolo Bonzini <pbonzini@redhat.com>
Message-ID: <40828fec-a375-fb90-f4f1-fc647651c2f7@redhat.com>
Date: Mon, 11 Dec 2017 23:23:54 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1712111409090.196232@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Oded Gabbay <oded.gabbay@gmail.com>, Alex Deucher <alexander.deucher@amd.com>, =?UTF-8?Q?Christian_K=c3=b6nig?= <christian.koenig@amd.com>, David Airlie <airlied@linux.ie>, Joerg Roedel <joro@8bytes.org>, Doug Ledford <dledford@redhat.com>, Jani Nikula <jani.nikula@linux.intel.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Sean Hefty <sean.hefty@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, =?UTF-8?B?UmFkaW0gS3LEjW3DocWZ?= <rkrcmar@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/12/2017 23:11, David Rientjes wrote:
> Commit 4d4bbd8526a8 ("mm, oom_reaper: skip mm structs with mmu notifiers")
> prevented the oom reaper from unmapping private anonymous memory with the
> oom reaper when the oom victim mm had mmu notifiers registered.
> 
> The rationale is that doing mmu_notifier_invalidate_range_{start,end}()
> around the unmap_page_range(), which is needed, can block and the oom
> killer will stall forever waiting for the victim to exit, which may not
> be possible without reaping.
> 
> That concern is real, but only true for mmu notifiers that have blockable
> invalidate_range_{start,end}() callbacks.  This patch adds a "flags" field
> for mmu notifiers that can set a bit to indicate that these callbacks do
> block.

Why not put the flag in the ops, since the same ops should always be
either blockable or unblockable?

Paolo

> The implementation is steered toward an expensive slowpath, such as after
> the oom reaper has grabbed mm->mmap_sem of a still alive oom victim.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
