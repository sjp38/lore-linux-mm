Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1E06D6B0038
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 15:10:41 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id u14so105247404lfd.0
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 12:10:41 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id yx6si4008040wjb.207.2016.09.12.12.10.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 12:10:39 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id g141so3991823wmd.1
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 12:10:39 -0700 (PDT)
Date: Mon, 12 Sep 2016 21:10:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm, proc: Fix region lost in /proc/self/smaps
Message-ID: <20160912191035.GD14997@dhcp22.suse.cz>
References: <1473649964-20191-1-git-send-email-guangrong.xiao@linux.intel.com>
 <20160912125447.GM14524@dhcp22.suse.cz>
 <57D6C332.4000409@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <57D6C332.4000409@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Xiao Guangrong <guangrong.xiao@linux.intel.com>, pbonzini@redhat.com, akpm@linux-foundation.org, dan.j.williams@intel.com, gleb@kernel.org, mtosatti@redhat.com, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, stefanha@redhat.com, yuhuang@redhat.com, linux-mm@kvack.org, ross.zwisler@linux.intel.com, Oleg Nesterov <oleg@redhat.com>

On Mon 12-09-16 08:01:06, Dave Hansen wrote:
> On 09/12/2016 05:54 AM, Michal Hocko wrote:
> >> > In order to fix this bug, we make 'file->version' indicate the end address
> >> > of current VMA
> > Doesn't this open doors to another weird cases. Say B would be partially
> > unmapped (tail of the VMA would get unmapped and reused for a new VMA.
> 
> In the end, this interface isn't about VMAs.  It's about addresses, and
> we need to make sure that the _addresses_ coming out of it are sane.  In
> the case that a VMA was partially unmapped, it doesn't make sense to
> show the "new" VMA because we already had some output covering the
> address of the "new" VMA from the old one.

OK, that is a fair point and it speaks for caching the vm_end rather
than vm_start+skip.

> > I am not sure we provide any guarantee when there are more read
> > syscalls. Hmm, even with a single read() we can get inconsistent results
> > from different threads without any user space synchronization.
> 
> Yeah, very true.  But, I think we _can_ at least provide the following
> guarantees (among others):
> 1. addresses don't go backwards
> 2. If there is something at a given vaddr during the entirety of the
>    life of the smaps walk, we will produce some output for it.

I guess we also want 
  3. no overlaps with previously printed values (assuming two subsequent
     reads without seek).

the patch tries to achieve the last part as well AFAICS but I guess this
is incomplete because at least /proc/<pid>/smaps will report counters
for the full vma range while the header (aka show_map_vma) will report
shorter (non-overlapping) range. I haven't checked other files which use
m_{start,next}

Considering how this all can be tricky and how partial reads can be
confusing and even misleading I am really wondering whether we
should simply document that only full reads will provide a sensible
results.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
