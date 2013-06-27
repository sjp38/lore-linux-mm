Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id CFE066B0034
	for <linux-mm@kvack.org>; Thu, 27 Jun 2013 05:26:21 -0400 (EDT)
Date: Thu, 27 Jun 2013 11:26:16 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] vmpressure: implement strict mode
Message-ID: <20130627092616.GB17647@dhcp22.suse.cz>
References: <20130626231712.4a7392a7@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130626231712.4a7392a7@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luiz Capitulino <lcapitulino@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, minchan@kernel.org, anton@enomsg.org, akpm@linux-foundation.org, kmpark@infradead.org, hyunhee.kim@samsung.com

On Wed 26-06-13 23:17:12, Luiz Capitulino wrote:
> Currently, an eventfd is notified for the level it's registered for
> _plus_ higher levels.
> 
> This is a problem if an application wants to implement different
> actions for different levels. For example, an application might want
> to release 10% of its cache on level low, 50% on medium and 100% on
> critical. To do this, an application has to register a different
> eventfd for each pressure level. However, fd low is always going to
> be notified and and all fds are going to be notified on level critical.
> 
> Strict mode solves this problem by strictly notifiying an eventfd
> for the pressure level it registered for. This new mode is optional,
> by default we still notify eventfds on higher levels too.
> 
> Signed-off-by: Luiz Capitulino <lcapitulino@redhat.com>

Two nits bellow but it looks good in general to me. You can add my
Reviewed-by: Michal Hocko <mhocko@suse.cz>

I still think that edge triggering makes some sense but that one might
be rebased on top of this patch. We should still figure out whether the
edge triggering is the right approach for the use case Hyunhee Kim wants
it for so the strict mode should go first IMO.

> ---
> 
> o v2
> 
>  - Improve documentation
>  - Use a bit to store mode instead of a bool
>  - Minor changelog changes
> 
>  Documentation/cgroups/memory.txt | 26 ++++++++++++++++++++++----
>  mm/vmpressure.c                  | 26 ++++++++++++++++++++++++--
>  2 files changed, 46 insertions(+), 6 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index ddf4f93..412872b 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -791,6 +791,22 @@ way to trigger. Applications should do whatever they can to help the
>  system. It might be too late to consult with vmstat or any other
>  statistics, so it's advisable to take an immediate action.
>  
> +Applications can also choose between two notification modes when
> +registering an eventfd for memory pressure events:
> +
> +When in "non-strict" mode, an eventfd is notified for the specific level
> +it's registered for and higher levels. For example, an eventfd registered
> +for low level is also going to be notified on medium and critical levels.
> +This mode makes sense for applications interested on monitoring reclaim
> +activity or implementing simple load-balacing logic. The non-strict mode
> +is the default notification mode.
> +
> +When in "strict" mode, an eventfd is strictly notified for the pressure
> +level it's registered for. For example, an eventfd registered for the low
> +level event is not going to be notified when memory pressure gets into
> +medium or critical levels. This allows for more complex logic based on
> +the actual pressure level the system is experiencing.

It would be also fair to mention that there is no guarantee that lower
levels are signaled before higher so nobody should rely on seeing LOW
before MEDIUM or CRITICAL.

> +
>  The events are propagated upward until the event is handled, i.e. the
>  events are not pass-through. Here is what this means: for example you have
>  three cgroups: A->B->C. Now you set up an event listener on cgroups A, B
> @@ -807,12 +823,14 @@ register a notification, an application must:
>  
>  - create an eventfd using eventfd(2);
>  - open memory.pressure_level;
> -- write string like "<event_fd> <fd of memory.pressure_level> <level>"
> +- write string like "<event_fd> <fd of memory.pressure_level> <level> [strict]"
>    to cgroup.event_control.
>  
> -Application will be notified through eventfd when memory pressure is at
> -the specific level (or higher). Read/write operations to
> -memory.pressure_level are no implemented.
> +Applications will be notified through eventfd when memory pressure is at
> +the specific level or higher. If strict is passed, then applications
> +will only be notified when memory pressure reaches the specified level.
> +
> +Read/write operations to memory.pressure_level are no implemented.
>  
>  Test:
>  
> diff --git a/mm/vmpressure.c b/mm/vmpressure.c
> index 736a601..ba5c17e 100644
> --- a/mm/vmpressure.c
> +++ b/mm/vmpressure.c
> @@ -138,8 +138,16 @@ struct vmpressure_event {
>  	struct eventfd_ctx *efd;
>  	enum vmpressure_levels level;
>  	struct list_head node;
> +	unsigned int mode;

You would fill up a hole between level and node if you move it up on
64b. Doesn't matter much but why not do it...

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
