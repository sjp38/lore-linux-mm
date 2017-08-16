Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2D6EC6B025F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 05:13:16 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id p20so8182063pfj.2
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 02:13:16 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d88si230721pfb.645.2017.08.16.02.13.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 02:13:14 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7G9D0RA052286
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 05:13:14 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ccefncksk-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 05:13:14 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Wed, 16 Aug 2017 10:13:11 +0100
Date: Wed, 16 Aug 2017 11:13:07 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: BUG: using __this_cpu_read() in preemptible [00000000] code:
 mm_percpu_wq/7
References: <b7cc8709-5bbf-8a9a-a155-0ea804641e9a@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1707121039180.15771@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1707121039180.15771@nuc-kabylake>
Message-Id: <20170816091307.GA3102@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>, Tejun Heo <tj@kernel.org>
Cc: Andre Wild <wild@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Tejun,

can you make any sense of the below? It _looks_ like a bug in the workqueue
code. Andre's testcase is also doing cpu hotplug until we finally see a
workqueue.c warning.

On Wed, Jul 12, 2017 at 10:44:54AM -0500, Christopher Lameter wrote:
> On Wed, 7 Jun 2017, Andre Wild wrote:
> 
> > I'm currently seeing the following message running kernel version 4.11.0.
> > It looks like it was introduced with the patch
> > 4037d452202e34214e8a939fa5621b2b3bbb45b7.
> 
> A 2007 patch? At that point we did not have __this_cpu_read() nor
> refresh_cpu_vmstats.... Is this on s390 or some such architecture?
> > Can you please take a look at this problem?
> 
> Could you give me a bit more context?

Cc'ing Tejun, since this might be workqueue related.

> > [Tue Jun  6 15:27:03 2017] BUG: using __this_cpu_read() in preemptible [00000000] code: mm_percpu_wq/7
> > [Tue Jun  6 15:27:03 2017] caller is refresh_cpu_vm_stats+0x198/0x3d8
> > [Tue Jun  6 15:27:03 2017] CPU: 0 PID: 7 Comm: mm_percpu_wq Tainted: GW       4.11.0-20170529.0.ae409ab.224a322.fc25.s390xdefault #1
> > [Tue Jun  6 15:27:03 2017] Workqueue: mm_percpu_wq vmstat_update
> 
> It is run in preemptible mode but this from a kworker
> context so the processor cannot change (see vmstat_refresh()).
> 
> Even on s390 or so this should be fine.

Sorry for this late answer. Andre reproduced the problem on vanilla
4.13.0-rc4 with this small patch applied (whitespace damaged due to
copy-paste), so that we have a dump to look at:

diff --git a/lib/smp_processor_id.c b/lib/smp_processor_id.c
index 2fb007be0212..dc18575044c3 100644
--- a/lib/smp_processor_id.c
+++ b/lib/smp_processor_id.c
@@ -44,7 +44,7 @@ notrace static unsigned int check_preemption_disabled(const char *what1,

        print_symbol("caller is %s\n", (long)__builtin_return_address(0));
        dump_stack();
-
+       panic("preempt check\n");
 out_enable:
        preempt_enable_no_resched_notrace();
 out:

With that applied we see:

[ 5968.010352] WARNING: CPU: 54 PID: 7 at kernel/workqueue.c:2041 process_one_work+0x6d4/0x718

(I don't remember we have seen the warning above in the first report) and then

[ 5968.010913] Kernel panic - not syncing: preempt check
[ 5968.010919] CPU: 54 PID: 7 Comm: mm_percpu_wq Tainted: G        W       4.13.0-rc4-dirty #3
[ 5968.010923] Hardware name: IBM 3906 M03 703 (z/VM 6.4.0)
[ 5968.010927] Workqueue: mm_percpu_wq vmstat_update
[ 5968.010933] Call Trace:
[ 5968.010937] ([<0000000000113fbe>] show_stack+0x8e/0xe0)
[ 5968.010942]  [<0000000000a514be>] dump_stack+0x96/0xd8
[ 5968.010947]  [<000000000014302a>] panic+0x102/0x248
[ 5968.010952]  [<00000000007836d8>] check_preemption_disabled+0xf8/0x110
[ 5968.010956]  [<00000000002ee8e2>] refresh_cpu_vm_stats+0x1b2/0x400
[ 5968.010961]  [<00000000002ef8be>] vmstat_update+0x2e/0x98
[ 5968.010965]  [<0000000000166374>] process_one_work+0x3d4/0x718
[ 5968.010970]  [<000000000016708c>] rescuer_thread+0x214/0x390
[ 5968.010974]  [<000000000016edbc>] kthread+0x16c/0x180
[ 5968.010978]  [<0000000000a7273a>] kernel_thread_starter+0x6/0xc
[ 5968.010983]  [<0000000000a72734>] kernel_thread_starter+0x0/0xc

On cpu 54 we have mm_percpu_wq with:

    nr_cpus_allowed = 0x1,
    cpus_allowed = {
	      bits = {0x4, 0x0, 0x0, 0x0}
    },

We also have CONFIG_NR_CPUS=256, so the above translates to cpu 3, which
obviously is not cpu 54 and explains the preempt check warning.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
