Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0740B6B0276
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 12:32:19 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id h8so3277915otb.4
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 09:32:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j23sor1009822ote.97.2018.10.03.09.32.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Oct 2018 09:32:18 -0700 (PDT)
MIME-Version: 1.0
References: <20180929013611.163130-1-jannh@google.com> <20181003162905.GK4714@dhcp22.suse.cz>
In-Reply-To: <20181003162905.GK4714@dhcp22.suse.cz>
From: Jann Horn <jannh@google.com>
Date: Wed, 3 Oct 2018 18:31:50 +0200
Message-ID: <CAG48ez1f0pXx=ZJgjmwsxtF+v_w9eJYpJKtzP7MDK1eiUOyswA@mail.gmail.com>
Subject: Re: [PATCH] mm/vmstat: fix outdated vmstat_text
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Davidlohr Bueso <dave@stgolabs.net>, Oleg Nesterov <oleg@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, clameter@sgi.com, guro@fb.com, kemi.wang@intel.com, Kees Cook <keescook@chromium.org>

On Wed, Oct 3, 2018 at 6:29 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> On Sat 29-09-18 03:36:11, Jann Horn wrote:
> > commit 7a9cdebdcc17 ("mm: get rid of vmacache_flush_all() entirely")
> > removed the VMACACHE_FULL_FLUSHES statistics, but didn't remove the
> > corresponding entry in vmstat_text. This causes an out-of-bounds access in
> > vmstat_show().
> >
> > Luckily this only affects kernels with CONFIG_DEBUG_VM_VMACACHE=y, which is
> > probably very rare.
> >
> > Having two gigantic arrays that must be kept in sync isn't exactly robust.
> > To make it easier to catch such issues in the future, add a BUILD_BUG_ON().
> >
> > Fixes: 7a9cdebdcc17 ("mm: get rid of vmacache_flush_all() entirely")
> > Cc: stable@vger.kernel.org
> > Signed-off-by: Jann Horn <jannh@google.com>
>
> Those could be two separate patches but anyway
> Acked-by: Michal Hocko <mhocko@suse.com>
>
> to both changes. I have burned myself on this in the past as well. Build
> bugon would save me a lot of debugging.

I actually sent a v2 that splits this into two patches, and adds
another fix for nr_tlb_remote_flush and nr_tlb_remote_flush_received
for systems with CONFIG_VM_EVENT_COUNTERS=y && CONFIG_DEBUG_TLBFLUSH=y
&& CONFIG_SMP=n. akpm has already added the v2 patches to the mm tree.
