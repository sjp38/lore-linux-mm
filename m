Return-Path: <linux-kernel-owner@vger.kernel.org>
Date: Tue, 11 Dec 2018 14:13:00 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH v2] ksm: React on changing "sleep_millisecs" parameter
 faster
Message-ID: <20181211111300.GF2342@uranus.lan>
References: <20181211100346.GE2342@uranus.lan>
 <154452399396.4921.3418365102240528000.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154452399396.4921.3418365102240528000.stgit@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, gorcunov@virtuozzo.com
List-ID: <linux-mm.kvack.org>

On Tue, Dec 11, 2018 at 01:26:59PM +0300, Kirill Tkhai wrote:
> ksm thread unconditionally sleeps in ksm_scan_thread()
> after each iteration:
> 
> 	schedule_timeout_interruptible(
> 		msecs_to_jiffies(ksm_thread_sleep_millisecs))
> 
> The timeout is configured in /sys/kernel/mm/ksm/sleep_millisecs.
> 
> In case of user writes a big value by a mistake, and the thread
> enters into schedule_timeout_interruptible(), it's not possible
> to cancel the sleep by writing a new smaler value; the thread
> is just sleeping till timeout expires.
> 
> The patch fixes the problem by waking the thread each time
> after the value is updated.
> 
> This also may be useful for debug purposes; and also for userspace
> daemons, which change sleep_millisecs value in dependence of
> system load.
> 
> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
> 
> v2: Use wait_event_interruptible_timeout() instead of unconditional
>     schedule_timeout().
...
> @@ -2844,7 +2849,10 @@ static ssize_t sleep_millisecs_store(struct kobject *kobj,
>  	if (err || msecs > UINT_MAX)
>  		return -EINVAL;
>  
> +	mutex_lock(&ksm_thread_mutex);
>  	ksm_thread_sleep_millisecs = msecs;
> +	mutex_unlock(&ksm_thread_mutex);
> +	wake_up_interruptible(&ksm_iter_wait);

Btw, just thought -- if we start using this mutex here don't we
open a window for force attack on the thread self execution,
iow if there gonna be a million of writers do we have a guarantee
thread ksm_scan_thread will grab the mutex earlier than writers
(or somewhere inbetween)?
