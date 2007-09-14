Date: Fri, 14 Sep 2007 16:15:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 6/6] cpuset dirty limits
Message-Id: <20070914161540.5b192348.akpm@linux-foundation.org>
In-Reply-To: <46E743F8.9050206@google.com>
References: <469D3342.3080405@google.com>
	<46E741B1.4030100@google.com>
	<46E743F8.9050206@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ethan Solomita <solo@google.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, 11 Sep 2007 18:42:16 -0700
Ethan Solomita <solo@google.com> wrote:

> Per cpuset dirty ratios
> 
> This implements dirty ratios per cpuset. Two new files are added
> to the cpuset directories:
> 
> background_dirty_ratio	Percentage at which background writeback starts
> 
> throttle_dirty_ratio	Percentage at which the application is throttled
> 			and we start synchrononous writeout.
> 
> Both variables are set to -1 by default which means that the global
> limits (/proc/sys/vm/vm_dirty_ratio and /proc/sys/vm/dirty_background_ratio)
> are used for a cpuset.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> Acked-by: Ethan Solomita <solo@google.com>
> 
> ---
> 
> Patch against 2.6.23-rc4-mm1
> 
> diff -uprN -X 0/Documentation/dontdiff 5/include/linux/cpuset.h 7/include/linux/cpuset.h
> --- 5/include/linux/cpuset.h	2007-09-11 14:50:48.000000000 -0700
> +++ 7/include/linux/cpuset.h	2007-09-11 14:51:12.000000000 -0700
> @@ -77,6 +77,7 @@ extern void cpuset_track_online_nodes(vo
>  
>  extern int current_cpuset_is_being_rebound(void);
>  
> +extern void cpuset_get_current_ratios(int *background, int *ratio);
>  /*
>   * We need macros since struct address_space is not defined yet
>   */
> diff -uprN -X 0/Documentation/dontdiff 5/kernel/cpuset.c 7/kernel/cpuset.c
> --- 5/kernel/cpuset.c	2007-09-11 14:50:49.000000000 -0700
> +++ 7/kernel/cpuset.c	2007-09-11 14:56:18.000000000 -0700
> @@ -51,6 +51,7 @@
>  #include <linux/time.h>
>  #include <linux/backing-dev.h>
>  #include <linux/sort.h>
> +#include <linux/writeback.h>
>  
>  #include <asm/uaccess.h>
>  #include <asm/atomic.h>
> @@ -92,6 +93,9 @@ struct cpuset {
>  	int mems_generation;
>  
>  	struct fmeter fmeter;		/* memory_pressure filter */
> +
> +	int background_dirty_ratio;
> +	int throttle_dirty_ratio;
>  };
>  
>  /* Retrieve the cpuset for a container */
> @@ -169,6 +173,8 @@ static struct cpuset top_cpuset = {
>  	.flags = ((1 << CS_CPU_EXCLUSIVE) | (1 << CS_MEM_EXCLUSIVE)),
>  	.cpus_allowed = CPU_MASK_ALL,
>  	.mems_allowed = NODE_MASK_ALL,
> +	.background_dirty_ratio = -1,
> +	.throttle_dirty_ratio = -1,
>  };
>  
>  /*
> @@ -785,6 +791,21 @@ static int update_flag(cpuset_flagbits_t
>  	return 0;
>  }
>  
> +static int update_int(int *cs_int, char *buf, int min, int max)
> +{
> +	char *endp;
> +	int val;
> +
> +	val = simple_strtol(buf, &endp, 10);
> +	if (val < min || val > max)
> +		return -EINVAL;
> +
> +	mutex_lock(&callback_mutex);
> +	*cs_int = val;
> +	mutex_unlock(&callback_mutex);

I don't think this locking does anything?

> +	return 0;
> +}
> +
>  /*
>   * Frequency meter - How fast is some event occurring?
>   *
> ...
> +void cpuset_get_current_ratios(int *background_ratio, int *throttle_ratio)
> +{
> +	int background = -1;
> +	int throttle = -1;
> +	struct task_struct *tsk = current;
> +
> +	task_lock(tsk);
> +	background = task_cs(tsk)->background_dirty_ratio;
> +	throttle = task_cs(tsk)->throttle_dirty_ratio;
> +	task_unlock(tsk);

ditto?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
