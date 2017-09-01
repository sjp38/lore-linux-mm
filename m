Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 55C1C6B0292
	for <linux-mm@kvack.org>; Fri,  1 Sep 2017 05:36:32 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 63so9492244pgc.0
        for <linux-mm@kvack.org>; Fri, 01 Sep 2017 02:36:32 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id p64si1567988pga.272.2017.09.01.02.36.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Sep 2017 02:36:31 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v819ZP7K102094
	for <linux-mm@kvack.org>; Fri, 1 Sep 2017 05:36:30 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2cq4q9175n-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 01 Sep 2017 05:36:30 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <wild@linux.vnet.ibm.com>;
	Fri, 1 Sep 2017 10:36:28 +0100
Subject: Re: BUG: using __this_cpu_read() in preemptible [00000000] code:
 mm_percpu_wq/7
References: <b7cc8709-5bbf-8a9a-a155-0ea804641e9a@linux.vnet.ibm.com>
 <alpine.DEB.2.20.1707121039180.15771@nuc-kabylake>
 <20170816091307.GA3102@osiris>
 <20170816142042.GB4087514@devbig577.frc2.facebook.com>
From: Andre Wild <wild@linux.vnet.ibm.com>
Date: Fri, 1 Sep 2017 11:36:24 +0200
MIME-Version: 1.0
In-Reply-To: <20170816142042.GB4087514@devbig577.frc2.facebook.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Message-Id: <71a53bf8-3279-68db-3a95-b9e13c1fc73a@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Christopher Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/16/2017 04:20 PM, Tejun Heo wrote:
> Hello,
> 
> On Wed, Aug 16, 2017 at 11:13:07AM +0200, Heiko Carstens wrote:
>> [ 5968.010352] WARNING: CPU: 54 PID: 7 at kernel/workqueue.c:2041 process_one_work+0x6d4/0x718
>>
>> (I don't remember we have seen the warning above in the first report) and then
>>
>> [ 5968.010913] Kernel panic - not syncing: preempt check
>> [ 5968.010919] CPU: 54 PID: 7 Comm: mm_percpu_wq Tainted: G        W       4.13.0-rc4-dirty #3
>> [ 5968.010923] Hardware name: IBM 3906 M03 703 (z/VM 6.4.0)
>> [ 5968.010927] Workqueue: mm_percpu_wq vmstat_update
>> [ 5968.010933] Call Trace:
>> [ 5968.010937] ([<0000000000113fbe>] show_stack+0x8e/0xe0)
>> [ 5968.010942]  [<0000000000a514be>] dump_stack+0x96/0xd8
>> [ 5968.010947]  [<000000000014302a>] panic+0x102/0x248
>> [ 5968.010952]  [<00000000007836d8>] check_preemption_disabled+0xf8/0x110
>> [ 5968.010956]  [<00000000002ee8e2>] refresh_cpu_vm_stats+0x1b2/0x400
>> [ 5968.010961]  [<00000000002ef8be>] vmstat_update+0x2e/0x98
>> [ 5968.010965]  [<0000000000166374>] process_one_work+0x3d4/0x718
>> [ 5968.010970]  [<000000000016708c>] rescuer_thread+0x214/0x390
>> [ 5968.010974]  [<000000000016edbc>] kthread+0x16c/0x180
>> [ 5968.010978]  [<0000000000a7273a>] kernel_thread_starter+0x6/0xc
>> [ 5968.010983]  [<0000000000a72734>] kernel_thread_starter+0x0/0xc
>>
>> On cpu 54 we have mm_percpu_wq with:
>>
>>      nr_cpus_allowed = 0x1,
>>      cpus_allowed = {
>> 	      bits = {0x4, 0x0, 0x0, 0x0}
>>      },
>>
>> We also have CONFIG_NR_CPUS=256, so the above translates to cpu 3, which
>> obviously is not cpu 54 and explains the preempt check warning.
> 
> Looks like the same issue Paul was hitting.
> 
>   http://lkml.kernel.org/r/1501541603-4456-3-git-send-email-paulmck@linux.vnet.ibm.com
> 
> Can you see whether the above patch helps?
> 
> Thank.s
> 

Hello,

please excuse my late response. But I've found another kernel panic 
which stopped my test case execution each time. Now I've managed to work 
around the problem and it looks pretty good. With the patch I was not 
able to reproduce the problem within 24 hours runtime. Previously I 
could trigger it within 2-4 hours runtime.

Kind regards

AndrA(C)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
