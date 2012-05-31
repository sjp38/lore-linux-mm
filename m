Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 7CC776B0062
	for <linux-mm@kvack.org>; Thu, 31 May 2012 16:12:27 -0400 (EDT)
Date: Thu, 31 May 2012 13:12:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RFC 3/3] proc/smaps: show amount of hwpoison pages
Message-Id: <20120531131225.a3761dc8.akpm@linux-foundation.org>
In-Reply-To: <CAHGf_=o_R8k-ywaAodrrHcnnjad01kp1szw_AuA-5AiB19fLew@mail.gmail.com>
References: <20120430112903.14137.81692.stgit@zurg>
	<20120430112910.14137.28935.stgit@zurg>
	<CAHGf_=rWDMMv2dKz3paV2MnjsCNWBa2BaUTi+RnDo8DZ4zEr=g@mail.gmail.com>
	<4FA02603.80807@openvz.org>
	<CAHGf_=o_R8k-ywaAodrrHcnnjad01kp1szw_AuA-5AiB19fLew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>

On Tue, 1 May 2012 14:14:57 -0400
KOSAKI Motohiro <kosaki.motohiro@gmail.com> wrote:

> On Tue, May 1, 2012 at 2:05 PM, Konstantin Khlebnikov
> <khlebnikov@openvz.org> wrote:
> > KOSAKI Motohiro wrote:
> >>
> >> On Mon, Apr 30, 2012 at 7:29 AM, Konstantin Khlebnikov
> >> <khlebnikov@openvz.org> __wrote:
> >>>
> >>> This patch adds line "HWPoinson:<size> __kB" into /proc/pid/smaps if
> >>> CONFIG_MEMORY_FAILURE=y and some HWPoison pages were found.
> >>> This may be useful for searching applications which use a broken memory.
> >>
> >>
> >> I dislike "maybe useful" claim. If we don't know exact motivation of a
> >> feature,
> >> we can't maintain them especially when a bugfix can't avoid ABI change.
> >>
> >> Please write down exact use case.
> >
> > I don't know how to exactly use this hw-poison stuff, but smaps suppose to
> > export state of ptes in vma. It seems to rational to show also hw-poisoned
> > ptes,
> > since kernel has this feature and pte can be in hw-poisoned state.
> >
> > and now everyone can easily find them:
> > # sudo grep HWPoison /proc/*/smaps
> 
> First, I don't think "we can expose it" is good reason. Second, hw-poisoned mean
> such process is going to be killed at next page touch. But I can't
> imagine anyone can
> use its information because it's racy against process kill. I think
> admin should use mce log.
> 
> So, until we find a good use case, I don't ack this.

Yes, I think I'll drop this patch for now.  If we can later produce a
good reason for expanding the kernel API in this fashion then please
resend.


From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Subject: proc/smaps: show amount of hwpoison pages

Add the line "HWPoinson: <size> kB" into /proc/pid/smaps if
CONFIG_MEMORY_FAILURE=y and some HWPoison pages were found.  This may be
useful for searching applications which use a broken memory.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Acked-by: Andi Kleen <ak@linux.intel.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/proc/task_mmu.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff -puN fs/proc/task_mmu.c~proc-smaps-show-amount-of-hwpoison-pages fs/proc/task_mmu.c
--- a/fs/proc/task_mmu.c~proc-smaps-show-amount-of-hwpoison-pages
+++ a/fs/proc/task_mmu.c
@@ -394,6 +394,7 @@ struct mem_size_stats {
 	unsigned long anonymous_thp;
 	unsigned long swap;
 	unsigned long nonlinear;
+	unsigned long hwpoison;
 	u64 pss;
 };
 
@@ -416,6 +417,8 @@ static void smaps_pte_entry(pte_t ptent,
 			mss->swap += ptent_size;
 		else if (is_migration_entry(swpent))
 			page = migration_entry_to_page(swpent);
+		else if (is_hwpoison_entry(swpent))
+			mss->hwpoison += ptent_size;
 	} else if (pte_file(ptent)) {
 		if (pte_to_pgoff(ptent) != pgoff)
 			mss->nonlinear += ptent_size;
@@ -430,6 +433,9 @@ static void smaps_pte_entry(pte_t ptent,
 	if (page->index != pgoff)
 		mss->nonlinear += ptent_size;
 
+	if (PageHWPoison(page))
+		mss->hwpoison += ptent_size;
+
 	mss->resident += ptent_size;
 	/* Accumulate the size in pages that have been accessed. */
 	if (pte_young(ptent) || PageReferenced(page))
@@ -535,6 +541,10 @@ static int show_smap(struct seq_file *m,
 		seq_printf(m, "Nonlinear:      %8lu kB\n",
 				mss.nonlinear >> 10);
 
+	if (IS_ENABLED(CONFIG_MEMORY_FAILURE) && mss.hwpoison)
+		seq_printf(m, "HWPoison:       %8lu kB\n",
+				mss.hwpoison >> 10);
+
 	if (m->count < m->size)  /* vma is copied successfully */
 		m->version = (vma != get_gate_vma(task->mm))
 			? vma->vm_start : 0;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
