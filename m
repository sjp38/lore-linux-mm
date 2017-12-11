Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 53D756B0033
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 18:10:02 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id c33so17362886itf.8
        for <linux-mm@kvack.org>; Mon, 11 Dec 2017 15:10:02 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k80sor5188858itk.128.2017.12.11.15.10.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Dec 2017 15:10:01 -0800 (PST)
Date: Mon, 11 Dec 2017 15:09:58 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/2] mm, mmu_notifier: annotate mmu notifiers with
 blockable invalidate callbacks
In-Reply-To: <40828fec-a375-fb90-f4f1-fc647651c2f7@redhat.com>
Message-ID: <alpine.DEB.2.10.1712111507520.14765@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1712111409090.196232@chino.kir.corp.google.com> <40828fec-a375-fb90-f4f1-fc647651c2f7@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paolo Bonzini <pbonzini@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Oded Gabbay <oded.gabbay@gmail.com>, Alex Deucher <alexander.deucher@amd.com>, =?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, David Airlie <airlied@linux.ie>, Joerg Roedel <joro@8bytes.org>, Doug Ledford <dledford@redhat.com>, Jani Nikula <jani.nikula@linux.intel.com>, Mike Marciniszyn <mike.marciniszyn@intel.com>, Sean Hefty <sean.hefty@intel.com>, Dimitri Sivanich <sivanich@sgi.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, =?UTF-8?Q?J=C3=A9r=C3=B4me_Glisse?= <jglisse@redhat.com>, =?UTF-8?Q?Radim_Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 11 Dec 2017, Paolo Bonzini wrote:

> > Commit 4d4bbd8526a8 ("mm, oom_reaper: skip mm structs with mmu notifiers")
> > prevented the oom reaper from unmapping private anonymous memory with the
> > oom reaper when the oom victim mm had mmu notifiers registered.
> > 
> > The rationale is that doing mmu_notifier_invalidate_range_{start,end}()
> > around the unmap_page_range(), which is needed, can block and the oom
> > killer will stall forever waiting for the victim to exit, which may not
> > be possible without reaping.
> > 
> > That concern is real, but only true for mmu notifiers that have blockable
> > invalidate_range_{start,end}() callbacks.  This patch adds a "flags" field
> > for mmu notifiers that can set a bit to indicate that these callbacks do
> > block.
> 
> Why not put the flag in the ops, since the same ops should always be
> either blockable or unblockable?
> 

Hi Paolo,

It certainly can be in mmu_notifier_ops, the only rationale for putting 
the flags member in mmu_notifier was that it may become generally useful 
later for things other than callbacks.  I'm indifferent to where it is 
placed and will happily move it if that's desired, absent any other 
feedback on other parts of the patchset.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
