Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 28A96440874
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 12:13:48 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 40so2709308wrw.10
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 09:13:48 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d138si3094027wme.188.2017.07.12.09.13.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jul 2017 09:13:46 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v6CGAexD070754
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 12:13:42 -0400
Received: from e06smtp15.uk.ibm.com (e06smtp15.uk.ibm.com [195.75.94.111])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2bnp323h41-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 12:13:42 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <heiko.carstens@de.ibm.com>;
	Wed, 12 Jul 2017 17:13:39 +0100
Date: Wed, 12 Jul 2017 18:13:36 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: BUG: using __this_cpu_read() in preemptible [00000000] code:
 mm_percpu_wq/7
References: <b7cc8709-5bbf-8a9a-a155-0ea804641e9a@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1707121039180.15771@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1707121039180.15771@nuc-kabylake>
Message-Id: <20170712161336.GA3190@osiris>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Andre Wild <wild@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Jul 12, 2017 at 10:44:54AM -0500, Christopher Lameter wrote:
> On Wed, 7 Jun 2017, Andre Wild wrote:
> 
> > I'm currently seeing the following message running kernel version 4.11.0.
> > It looks like it was introduced with the patch
> > 4037d452202e34214e8a939fa5621b2b3bbb45b7.
> 
> A 2007 patch? At that point we did not have __this_cpu_read() nor
> refresh_cpu_vmstats.... Is this on s390 or some such architecture?

It is on s390, but after I looked into the code a bit deeper the mentioned
patch doesn't seem to be the problem.

My initial thought was a missing preempt_disable() / preempt_enable() pair,
but that can't be the problem, since the code is executed on a per-cpu
workqueue.

> > Can you please take a look at this problem?
> 
> Could you give me a bit more context?
> 
> 
> > [Tue Jun  6 15:27:03 2017] BUG: using __this_cpu_read() in preemptible
> > [00000000] code: mm_percpu_wq/7
> > [Tue Jun  6 15:27:03 2017] caller is refresh_cpu_vm_stats+0x198/0x3d8
> > [Tue Jun  6 15:27:03 2017] CPU: 0 PID: 7 Comm: mm_percpu_wq Tainted: G
> > W       4.11.0-20170529.0.ae409ab.224a322.fc25.s390xdefault #1
> > [Tue Jun  6 15:27:03 2017] Workqueue: mm_percpu_wq vmstat_update
> 
> It is run in preemptible mode but this from a kworker
> context so the processor cannot change (see vmstat_refresh()).
> 
> Even on s390 or so this should be fine.

Yes, it *should* be fine. The only unusual thing here is that this happens
during quite a lot of cpu hotplug operations. So even though the workqueue
code should be able to handle cpu hotplug correctly, my best guess is that
current->cpus_allowed is not cpumask_of(this_cpu) for some reason.

That would be this check within lib/smp_processor_id.c:check_preemption_disabled()

	if (cpumask_equal(&current->cpus_allowed, cpumask_of(this_cpu)))
		goto out;

I changed the code to simply panic, so I can look into a dump to figure out
what actually does cause the warning. As soon as Andre finds some time to
reproduce this we will come back to you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
