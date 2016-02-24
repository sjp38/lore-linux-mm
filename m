Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id A03B36B0005
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 10:56:29 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id g62so36293984wme.0
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 07:56:29 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id go14si4243016wjc.241.2016.02.24.07.56.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 Feb 2016 07:56:28 -0800 (PST)
Date: Wed, 24 Feb 2016 16:56:24 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH v5 03/20] kthread: Add create_kthread_worker*()
Message-ID: <20160224155624.GZ3305@pathway.suse.cz>
References: <1456153030-12400-4-git-send-email-pmladek@suse.com>
 <201602222335.d3Pey8SI%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201602222335.d3Pey8SI%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <lkp@intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Josh Triplett <josh@joshtriplett.org>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Jiri Kosina <jkosina@suse.cz>, Borislav Petkov <bp@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon 2016-02-22 23:48:53, kbuild test robot wrote:
> Hi Petr,
> 
> [auto build test ERROR on soc-thermal/next]
> [also build test ERROR on v4.5-rc5 next-20160222]
> [if your patch is applied to the wrong git tree, please drop us a note to help improving the system]
> 
> url:    https://github.com/0day-ci/linux/commits/Petr-Mladek/kthread-Use-kthread-worker-API-more-widely/20160222-230250
> base:   https://git.kernel.org/pub/scm/linux/kernel/git/evalenti/linux-soc-thermal next
> config: xtensa-allyesconfig (attached as .config)
> reproduce:
>         wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=xtensa 
> 
> All error/warnings (new ones prefixed by >>):
> 
>    kernel/kthread.c: In function 'create_kthread_worker_on_cpu':
> >> kernel/kthread.c:691:9: error: incompatible type for argument 3 of '__create_kthread_worker'
>      return __create_kthread_worker(cpu, namefmt, NULL);
>             ^
>    kernel/kthread.c:622:1: note: expected 'va_list' but argument is of type 'void *'
>     __create_kthread_worker(int cpu, const char namefmt[], va_list args)
>     ^
> >> kernel/kthread.c:692:1: warning: control reaches end of non-void function [-Wreturn-type]
>     }
>     ^
> 
> vim +/__create_kthread_worker +691 kernel/kthread.c
> 
>    685	 * when the needed structures could not get allocated, and ERR_PTR(-EINTR)
>    686	 * when the worker was SIGKILLed.
>    687	 */
>    688	struct kthread_worker *
>    689	create_kthread_worker_on_cpu(int cpu, const char namefmt[])
>    690	{
>  > 691		return __create_kthread_worker(cpu, namefmt, NULL);
>  > 692	}
>    693	EXPORT_SYMBOL(create_kthread_worker_on_cpu);
>    694	
>    695	/* insert @work before @pos in @worker */

I can be fixed by passing a fake va_list. It is not used when
__create_kthread_worker() is called with a valid CPU number.

See below an updated patch that passes the build.
