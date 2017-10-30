Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id D03246B0038
	for <linux-mm@kvack.org>; Mon, 30 Oct 2017 11:22:22 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id 189so34963206iow.8
        for <linux-mm@kvack.org>; Mon, 30 Oct 2017 08:22:22 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id x25si3609589ita.90.2017.10.30.08.22.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Oct 2017 08:22:21 -0700 (PDT)
Date: Mon, 30 Oct 2017 16:22:00 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: possible deadlock in lru_add_drain_all
Message-ID: <20171030152200.ayfnewoqkxbuk4zh@hirez.programming.kicks-ass.net>
References: <089e0825eec8955c1f055c83d476@google.com>
 <20171027093418.om5e566srz2ztsrk@dhcp22.suse.cz>
 <CACT4Y+Y=NCy20_k4YcrCF2Q0f16UPDZBVAF=RkkZ0uSxZq5XaA@mail.gmail.com>
 <20171027134234.7dyx4oshjwd44vqx@dhcp22.suse.cz>
 <20171030082203.4xvq2af25shfci2z@dhcp22.suse.cz>
 <20171030100921.GA18085@X58A-UD3R>
 <20171030151009.ip4k7nwan7muouca@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171030151009.ip4k7nwan7muouca@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: Michal Hocko <mhocko@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, syzbot <bot+e7353c7141ff7cbb718e4c888a14fa92de41ebaa@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, jglisse@redhat.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, shli@fb.com, syzkaller-bugs@googlegroups.com, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kernel-team@lge.com

On Mon, Oct 30, 2017 at 04:10:09PM +0100, Peter Zijlstra wrote:
> I can indeed confirm it's running old code; cpuhp_state is no more.
> 
> However, that splat translates like:
> 
> 	__cpuhp_setup_state()
> #0	  cpus_read_lock()
> 	  __cpuhp_setup_state_cpuslocked()
> #1	    mutex_lock(&cpuhp_state_mutex)
> 
> 
> 
> 	__cpuhp_state_add_instance()
> #2	  mutex_lock(&cpuhp_state_mutex)
> 	  cpuhp_issue_call()
> 	    cpuhp_invoke_ap_callback()
> #3	      wait_for_completion()
> 
> 						msr_device_create()
> 						  ...
> #4						    filename_create()
> #3						complete()
> 


So all this you can get in a single callchain when you do something
shiny like:

	modprobe msr


> 	do_splice()
> #4	  file_start_write()
> 	  do_splice_from()
> 	    iter_file_splice_write()
> #5	      pipe_lock()
> 	      vfs_iter_write()
> 	        ...
> #6		  inode_lock()
> 
> 

This is a splice into a devtmpfs file


> 	sys_fcntl()
> 	  do_fcntl()
> 	    shmem_fcntl()
> #5	      inode_lock()

#6 (obviously)

> 	      shmem_wait_for_pins()
> 	        if (!scan)
> 		  lru_add_drain_all()
> #0		    cpus_read_lock()
> 

Is the right fcntl()


So 3 different callchains, and *splat*..


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
