Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 436016B0003
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 11:33:52 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id c3so2845086eda.3
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 08:33:52 -0800 (PST)
Received: from vulcan.natalenko.name (vulcan.natalenko.name. [2001:19f0:6c00:8846:5400:ff:fe0c:dfa0])
        by mx.google.com with ESMTPS id r22si8345262edc.302.2018.11.13.08.33.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 13 Nov 2018 08:33:49 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 8bit
Date: Tue, 13 Nov 2018 17:33:49 +0100
From: Oleksandr Natalenko <oleksandr@natalenko.name>
Subject: Re: [PATCH V3] KSM: allow dedup all tasks memory
In-Reply-To: <<20181112231344.7161-1-timofey.titovets@synesis.ru>>
Message-ID: <d45addefdf05b84af96fb494d52b4ec4@natalenko.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: timofey.titovets@synesis.ru
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nefelim4ag@gmail.com, willy@infradead.org

So,

> a?|snipa?|
> +static int ksm_seeker_thread(void *nothing)
> +{
> +	pid_t last_pid = 1;
> +	pid_t curr_pid;
> +	struct task_struct *task;
> +
> +	set_freezable();
> +	set_user_nice(current, 5);
> +
> +	while (!kthread_should_stop()) {
> +		wait_while_offlining();
> +
> +		try_to_freeze();
> +
> +		if (!ksm_mode_always()) {
> +			wait_event_freezable(ksm_seeker_thread_wait,
> +				ksm_mode_always() || kthread_should_stop());
> +			continue;
> +		}
> +
> +		/*
> +		 * import one task's vma per run
> +		 */
> +		read_lock(&tasklist_lock);
> +
> +		/* Try always get next task */
> +		for_each_process(task) {
> +			curr_pid = task_pid_nr(task);
> +			if (curr_pid == last_pid) {
> +				task = next_task(task);
> +				break;
> +			}
> +
> +			if (curr_pid > last_pid)
> +				break;
> +		}
> +
> +		last_pid = task_pid_nr(task);
> +		ksm_import_task_vma(task);

This seems to be a bad idea. ksm_import_task_vma() may sleep with 
tasklist_lock being held. Thus, IIUC, you'll get this:

[ 1754.410322] BUG: scheduling while atomic: ksmd_seeker/50/0x00000002
a?|
[ 1754.410444] Call Trace:
[ 1754.410455]  dump_stack+0x5c/0x80
[ 1754.410460]  __schedule_bug.cold.19+0x38/0x51
[ 1754.410464]  __schedule+0x11dc/0x2080
[ 1754.410483]  schedule+0x32/0xb0
[ 1754.410487]  rwsem_down_write_failed+0x15d/0x240
[ 1754.410496]  call_rwsem_down_write_failed+0x13/0x20
[ 1754.410499]  down_write+0x20/0x30
[ 1754.410502]  ksm_import_task_vma+0x22/0x70
[ 1754.410505]  ksm_seeker_thread+0x134/0x1c0
[ 1754.410512]  kthread+0x113/0x130
[ 1754.410518]  ret_from_fork+0x35/0x40

I think you may want to get a reference to task_struct before releasing 
tasklist_lock, and then put it after ksm_import_task_vma() does its job.

> +		read_unlock(&tasklist_lock);
> +
> +		schedule_timeout_interruptible(
> +			msecs_to_jiffies(ksm_thread_seeker_sleep_millisecs));
> +	}
> +	return 0;
> +}
> a?|snipa?|

-- 
   Oleksandr Natalenko (post-factum)
