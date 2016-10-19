Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 263FC6B0069
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 04:13:55 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id f193so10888923wmg.4
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 01:13:55 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id 143si3399757wmv.82.2016.10.19.01.13.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 01:13:53 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id g16so2760882wmg.2
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 01:13:53 -0700 (PDT)
Date: Wed, 19 Oct 2016 10:13:52 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 08/10] mm: replace __access_remote_vm() write parameter
 with gup_flags
Message-ID: <20161019081352.GB7562@dhcp22.suse.cz>
References: <20161013002020.3062-1-lstoakes@gmail.com>
 <20161013002020.3062-9-lstoakes@gmail.com>
 <20161019075903.GP29967@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161019075903.GP29967@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Lorenzo Stoakes <lstoakes@gmail.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, adi-buildroot-devel@lists.sourceforge.net, ceph-devel@vger.kernel.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, kvm@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-cris-kernel@axis.com, linux-fbdev@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mips@linux-mips.org, linux-rdma@vger.kernel.org, linux-s390@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org, linux-security-module@vger.kernel.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org

On Wed 19-10-16 09:59:03, Jan Kara wrote:
> On Thu 13-10-16 01:20:18, Lorenzo Stoakes wrote:
> > This patch removes the write parameter from __access_remote_vm() and replaces it
> > with a gup_flags parameter as use of this function previously _implied_
> > FOLL_FORCE, whereas after this patch callers explicitly pass this flag.
> > 
> > We make this explicit as use of FOLL_FORCE can result in surprising behaviour
> > (and hence bugs) within the mm subsystem.
> > 
> > Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>
> 
> So I'm not convinced this (and the following two patches) is actually
> helping much. By grepping for FOLL_FORCE we will easily see that any caller
> of access_remote_vm() gets that semantics and can thus continue search

I am really wondering. Is there anything inherent that would require
FOLL_FORCE for access_remote_vm? I mean FOLL_FORCE is a really
non-trivial thing. It doesn't obey vma permissions so we should really
minimize its usage. Do all of those users really need FOLL_FORCE?

Anyway I would rather see the flag explicit and used at more places than
hidden behind a helper function.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
