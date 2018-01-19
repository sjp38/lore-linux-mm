Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id F299E6B0033
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 17:13:34 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id b195so1728310wmb.1
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 14:13:34 -0800 (PST)
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk. [195.92.253.2])
        by mx.google.com with ESMTPS id a72si9327519wrc.311.2018.01.19.14.13.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jan 2018 14:13:33 -0800 (PST)
Date: Fri, 19 Jan 2018 22:12:43 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [mm 4.15-rc8] Random oopses under memory pressure.
Message-ID: <20180119221243.GL13338@ZenIV.linux.org.uk>
References: <201801172008.CHH39543.FFtMHOOVSQJLFO@I-love.SAKURA.ne.jp>
 <201801181712.BFD13039.LtHOSVMFJQFOFO@I-love.SAKURA.ne.jp>
 <20180118122550.2lhsjx7hg5drcjo4@node.shutemov.name>
 <d8347087-18a6-1709-8aa8-3c6f2d16aa94@linux.intel.com>
 <20180118145830.GA6406@redhat.com>
 <20180118165629.kpdkezarsf4qymnw@node.shutemov.name>
 <CA+55aFy43ypm0QvA5SqNR4O0ZJETbkR3NDR=dnSdvejc_nmSJQ@mail.gmail.com>
 <20180118234955.nlo55rw2qsfnavfm@node.shutemov.name>
 <20180119125503.GA2897@bombadil.infradead.org>
 <CA+55aFwWCeFrhN+WJDD8u9nqBzmvknXk428Q0dVwwXAvwhg_-w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwWCeFrhN+WJDD8u9nqBzmvknXk428Q0dVwwXAvwhg_-w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Matthew Wilcox <willy@infradead.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@linux.intel.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Tony Luck <tony.luck@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, "hillf.zj" <hillf.zj@alibaba-inc.com>, Hugh Dickins <hughd@google.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>

On Fri, Jan 19, 2018 at 10:42:18AM -0800, Linus Torvalds wrote:
> On Fri, Jan 19, 2018 at 4:55 AM, Matthew Wilcox <willy@infradead.org> wrote:
> >
> > So really we should be casting 'b' and 'a' to uintptr_t to be fully
> > compliant with the spec.
> 
> That's an unnecessary technicality.
> 
> Any compiler that doesn't get pointer inequality testing right is not
> worth even worrying about. We wouldn't want to use such a compiler,
> because it's intentionally generating garbage just to f*ck with us.
> Why would you go along with that?
> 
> So the only real issue is that pointer subtraction case.
> 
> I actually asked (long long ago) for an optinal compiler warning for
> "pointer subtraction with non-power-of-2 sizes". Not because of it
> being undefined, but simply because it's expensive. The
> divide->multiply thing doesn't always work, and a real divide is
> really quite expensive on many architectures.
> 
> We *should* be careful about it. I guess sparse could be made to warn,
> but I'm afraid that we have so many of these things that a warning
> isn't reasonable.

You mean like -Wptr-subtraction-blows?

FWIW, allmodconfig on amd64 with C=2 CF=-Wptr-subtraction-blows is not too large
The tail (alphabetically sorted) is
lib/dynamic_debug.c:1013:9: warning: potentially expensive pointer subtraction
lib/extable.c:70:28: warning: potentially expensive pointer subtraction
mm/memory_hotplug.c:1530:13: warning: potentially expensive pointer subtraction
mm/memory_hotplug.c:734:13: warning: potentially expensive pointer subtraction
mm/memory_hotplug.c:831:41: warning: potentially expensive pointer subtraction
mm/page_owner.c:607:38: warning: potentially expensive pointer subtraction
mm/vmstat.c:1334:38: warning: potentially expensive pointer subtraction
net/core/net-sysfs.c:1040:19: warning: potentially expensive pointer subtraction
net/ipv4/ipmr.c:3026:32: warning: potentially expensive pointer subtraction
net/ipv6/ip6mr.c:458:32: warning: potentially expensive pointer subtraction
net/mac80211/tx.c:1307:41: warning: potentially expensive pointer subtraction
net/mac80211/tx.c:1351:44: warning: potentially expensive pointer subtraction
net/rds/ib_recv.c:345:49: warning: potentially expensive pointer subtraction
net/rds/ib_recv.c:861:38: warning: potentially expensive pointer subtraction
net/sched/cls_tcindex.c:622:43: warning: potentially expensive pointer subtraction
net/sched/sch_cbs.c:302:35: warning: potentially expensive pointer subtraction
net/sched/sch_hhf.c:367:23: warning: potentially expensive pointer subtraction
net/sched/sch_hhf.c:434:38: warning: potentially expensive pointer subtraction
net/sunrpc/svc_xprt.c:1377:43: warning: potentially expensive pointer subtraction
sound/pci/hda/hda_generic.c:301:20: warning: potentially expensive pointer subtraction

IOW it's not terribly noisy.  Might be an interesting idea to teach sparse to
print the type in question...  Aha - with

--- a/evaluate.c
+++ b/evaluate.c
@@ -848,7 +848,8 @@ static struct symbol *evaluate_ptr_sub(struct expression *expr)
 
                if (value & (value-1)) {
                        if (Wptr_subtraction_blows)
-                               warning(expr->pos, "potentially expensive pointer subtraction");
+                               warning(expr->pos, "[%s] potentially expensive pointer subtraction",
+                                       show_typename(lbase));
                }
 
                sub->op = '-';

we get things like
drivers/gpu/drm/i915/i915_gem_execbuffer.c:435:17: warning: [struct drm_i915_gem_exec_object2] potentially expensive pointer subtraction

OK, the top sources of that warning are:
     91 struct cpufreq_frequency_table
     36 struct Indirect				(actually, that conflates ext2/ext4/minix/sysv)
     21 struct ips_scb
     18 struct runlist_element
     13 struct zone
     13 struct vring
     11 struct usbhsh_device
     10 struct xpc_partition
      9 struct skge_element 
      9 struct lock_class
      9 struct hstate
      7 struct nvme_rdma_queue
      7 struct iso_context  
      6 struct i915_power_well
      6 struct hpet_dev 
      6 struct ext4_extent
      6 struct esas2r_target
      5 struct iio_chan_spec
      5 struct hwspinlock
      4 struct myri10ge_slice_state
      4 struct ext4_extent_idx

everything beyond that is 3 instances or less...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
