Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 20B4D6B0038
	for <linux-mm@kvack.org>; Mon, 30 Oct 2017 11:10:24 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id y5so13776403pgq.15
        for <linux-mm@kvack.org>; Mon, 30 Oct 2017 08:10:24 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id e22si9593897plj.603.2017.10.30.08.10.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Oct 2017 08:10:22 -0700 (PDT)
Date: Mon, 30 Oct 2017 16:10:09 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: possible deadlock in lru_add_drain_all
Message-ID: <20171030151009.ip4k7nwan7muouca@hirez.programming.kicks-ass.net>
References: <089e0825eec8955c1f055c83d476@google.com>
 <20171027093418.om5e566srz2ztsrk@dhcp22.suse.cz>
 <CACT4Y+Y=NCy20_k4YcrCF2Q0f16UPDZBVAF=RkkZ0uSxZq5XaA@mail.gmail.com>
 <20171027134234.7dyx4oshjwd44vqx@dhcp22.suse.cz>
 <20171030082203.4xvq2af25shfci2z@dhcp22.suse.cz>
 <20171030100921.GA18085@X58A-UD3R>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171030100921.GA18085@X58A-UD3R>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Byungchul Park <byungchul.park@lge.com>
Cc: Michal Hocko <mhocko@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, syzbot <bot+e7353c7141ff7cbb718e4c888a14fa92de41ebaa@syzkaller.appspotmail.com>, Andrew Morton <akpm@linux-foundation.org>, Dan Williams <dan.j.williams@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, jglisse@redhat.com, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, shli@fb.com, syzkaller-bugs@googlegroups.com, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, ying.huang@intel.com, kernel-team@lge.com

On Mon, Oct 30, 2017 at 07:09:21PM +0900, Byungchul Park wrote:
> On Mon, Oct 30, 2017 at 09:22:03AM +0100, Michal Hocko wrote:
> > [Cc Byungchul. The original full report is
> > http://lkml.kernel.org/r/089e0825eec8955c1f055c83d476@google.com]
> > 
> > Could you have a look please? This smells like a false positive to me.
> 
> +cc peterz@infradead.org
> 
> Hello,
> 
> IMHO, the false positive was caused by the lockdep_map of 'cpuhp_state'
> which couldn't distinguish between cpu-up and cpu-down.
> 
> And it was solved with the following commit by Peter and Thomas:
> 
> 5f4b55e10645b7371322c800a5ec745cab487a6c
> smp/hotplug: Differentiate the AP-work lockdep class between up and down
> 
> Therefore, we can avoid the false positive on later than the commit.
> 
> Peter and Thomas, could you confirm it?

I can indeed confirm it's running old code; cpuhp_state is no more.

However, that splat translates like:

	__cpuhp_setup_state()
#0	  cpus_read_lock()
	  __cpuhp_setup_state_cpuslocked()
#1	    mutex_lock(&cpuhp_state_mutex)



	__cpuhp_state_add_instance()
#2	  mutex_lock(&cpuhp_state_mutex)
	  cpuhp_issue_call()
	    cpuhp_invoke_ap_callback()
#3	      wait_for_completion()

						msr_device_create()
						  ...
#4						    filename_create()
#3						complete()



	do_splice()
#4	  file_start_write()
	  do_splice_from()
	    iter_file_splice_write()
#5	      pipe_lock()
	      vfs_iter_write()
	        ...
#6		  inode_lock()



	sys_fcntl()
	  do_fcntl()
	    shmem_fcntl()
#5	      inode_lock()
	      shmem_wait_for_pins()
	        if (!scan)
		  lru_add_drain_all()
#0		    cpus_read_lock()



Which is an actual real deadlock, there is no mixing of up and down.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
