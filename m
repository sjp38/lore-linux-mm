Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id DE0766B0253
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 11:30:53 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id c78so35783wme.1
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 08:30:53 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id dw13si10539859wjb.44.2016.10.18.08.30.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 08:30:52 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id d199so9577wmd.1
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 08:30:52 -0700 (PDT)
Date: Tue, 18 Oct 2016 17:30:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 00/10] mm: adjust get_user_pages* functions to explicitly
 pass FOLL_* flags
Message-ID: <20161018153050.GC13117@dhcp22.suse.cz>
References: <20161013002020.3062-1-lstoakes@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161013002020.3062-1-lstoakes@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, adi-buildroot-devel@lists.sourceforge.net, ceph-devel@vger.kernel.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, kvm@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-cris-kernel@axis.com, linux-fbdev@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mips@linux-mips.org, linux-rdma@vger.kernel.org, linux-s390@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org, linux-security-module@vger.kernel.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org

On Thu 13-10-16 01:20:10, Lorenzo Stoakes wrote:
> This patch series adjusts functions in the get_user_pages* family such that
> desired FOLL_* flags are passed as an argument rather than implied by flags.
> 
> The purpose of this change is to make the use of FOLL_FORCE explicit so it is
> easier to grep for and clearer to callers that this flag is being used. The use
> of FOLL_FORCE is an issue as it overrides missing VM_READ/VM_WRITE flags for the
> VMA whose pages we are reading from/writing to, which can result in surprising
> behaviour.
> 
> The patch series came out of the discussion around commit 38e0885, which
> addressed a BUG_ON() being triggered when a page was faulted in with PROT_NONE
> set but having been overridden by FOLL_FORCE. do_numa_page() was run on the
> assumption the page _must_ be one marked for NUMA node migration as an actual
> PROT_NONE page would have been dealt with prior to this code path, however
> FOLL_FORCE introduced a situation where this assumption did not hold.
> 
> See https://marc.info/?l=linux-mm&m=147585445805166 for the patch proposal.

I like this cleanup. Tracking FOLL_FORCE users was always a nightmare
and the flag behavior is really subtle so we should better be explicit
about it. I haven't gone through each patch separately but rather
applied the whole series and checked the resulting diff. This all seems
OK to me and feel free to add
Acked-by: Michal Hocko <mhocko@suse.com>

I am wondering whether we can go further. E.g. it is not really clear to
me whether we need an explicit FOLL_REMOTE when we can in fact check
mm != current->mm and imply that. Maybe there are some contexts which
wouldn't work, I haven't checked.

Then I am also wondering about FOLL_TOUCH behavior.
__get_user_pages_unlocked has only few callers which used to be
get_user_pages_unlocked before 1e9877902dc7e ("mm/gup: Introduce
get_user_pages_remote()"). To me a dropped FOLL_TOUCH seems
unintentional. Now that get_user_pages_unlocked has gup_flags argument I
guess we might want to get rid of the __g-u-p-u version altogether, no?

__get_user_pages is quite low level and imho shouldn't be exported. It's
only user - kvm - should rather pull those two functions to gup instead
and export them. There is nothing really KVM specific in them.

I also cannot say I would be entirely thrilled about get_user_pages_locked,
we only have one user which can simply do lock g-u-p unlock AFAICS.

I guess there is more work in that area and I do not want to impose all
that work on you, but I couldn't resist once I saw you playing in that
area ;) Definitely a good start!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
