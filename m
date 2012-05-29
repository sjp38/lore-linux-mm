Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id A00D46B005C
	for <linux-mm@kvack.org>; Tue, 29 May 2012 07:44:33 -0400 (EDT)
Date: Tue, 29 May 2012 14:45:54 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 23/35] autonuma: core
Message-ID: <20120529114554.GA7017@shutemov.name>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
 <1337965359-29725-24-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1337965359-29725-24-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Fri, May 25, 2012 at 07:02:27PM +0200, Andrea Arcangeli wrote:

> +static int knumad_do_scan(void)
> +{

...

> +	if (knumad_test_exit(mm) || !vma) {
> +		mm_autonuma = mm->mm_autonuma;
> +		if (mm_autonuma->mm_node.next != &knumad_scan.mm_head) {
> +			mm_autonuma = list_entry(mm_autonuma->mm_node.next,
> +						 struct mm_autonuma, mm_node);
> +			knumad_scan.mm = mm_autonuma->mm;
> +			atomic_inc(&knumad_scan.mm->mm_count);
> +			knumad_scan.address = 0;
> +			knumad_scan.mm->mm_autonuma->numa_fault_pass++;
> +		} else
> +			knumad_scan.mm = NULL;

knumad_scan.mm should be nulled only after list_del otherwise you will
have race with autonuma_exit():

[   22.905208] ------------[ cut here ]------------
[   23.003620] WARNING: at /home/kas/git/public/linux/lib/list_debug.c:50 __list_del_entry+0x63/0xd0()
[   23.003621] Hardware name: QSSC-S4R
[   23.003624] list_del corruption, ffff880771a49300->next is LIST_POISON1 (dead000000100100)
[   23.003626] Modules linked in: megaraid_sas
[   23.003629] Pid: 569, comm: udevd Not tainted 3.4.0+ #31
[   23.003630] Call Trace:
[   23.003640]  [<ffffffff8105956f>] warn_slowpath_common+0x7f/0xc0
[   23.003643]  [<ffffffff81059666>] warn_slowpath_fmt+0x46/0x50
[   23.003645]  [<ffffffff813202e3>] __list_del_entry+0x63/0xd0
[   23.003648]  [<ffffffff81320361>] list_del+0x11/0x40
[   23.003654]  [<ffffffff8117b80f>] autonuma_exit+0x5f/0xb0
[   23.003657]  [<ffffffff810567ab>] mmput+0x7b/0x120
[   23.003663]  [<ffffffff8105e7d8>] exit_mm+0x108/0x130
[   23.003674]  [<ffffffff8165da5b>] ? _raw_spin_unlock_irq+0x2b/0x40
[   23.003677]  [<ffffffff8105e94a>] do_exit+0x14a/0x8d0
[   23.003682]  [<ffffffff811b71c6>] ? mntput+0x26/0x40
[   23.003688]  [<ffffffff8119a599>] ? fput+0x1c9/0x270
[   23.003693]  [<ffffffff81319dd9>] ? lockdep_sys_exit_thunk+0x35/0x67
[   23.003696]  [<ffffffff8105f41f>] do_group_exit+0x4f/0xc0
[   23.003698]  [<ffffffff8105f4a7>] sys_exit_group+0x17/0x20
[   23.003703]  [<ffffffff816663e9>] system_call_fastpath+0x16/0x1b
[   23.003705] ---[ end trace 8b21c7adb0af191b ]---

> +
> +		if (knumad_test_exit(mm))
> +			list_del(&mm->mm_autonuma->mm_node);
> +		else
> +			mm_numa_fault_flush(mm);
> +
> +		mmdrop(mm);
> +	}
> +
> +	return progress;
> +}

...

> +
> +static int knuma_scand(void *none)
> +{

...

> +	mm = knumad_scan.mm;
> +	knumad_scan.mm = NULL;

The same problem here.

> +	if (mm)
> +		list_del(&mm->mm_autonuma->mm_node);
> +	mutex_unlock(&knumad_mm_mutex);
> +
> +	if (mm)
> +		mmdrop(mm);
> +
> +	return 0;
> +}

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
