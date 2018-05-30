Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 03C486B0003
	for <linux-mm@kvack.org>; Wed, 30 May 2018 14:32:31 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id n9-v6so11409524wmh.6
        for <linux-mm@kvack.org>; Wed, 30 May 2018 11:32:30 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id d1-v6si7310056wre.54.2018.05.30.11.32.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 May 2018 11:32:29 -0700 (PDT)
Subject: Re: [PATCH 13/13] Documentation: add a doc for blk-iolatency
References: <20180529211724.4531-1-josef@toxicpanda.com>
 <20180529211724.4531-14-josef@toxicpanda.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <4c044b70-8d53-055b-933b-1b8570bd4fc2@infradead.org>
Date: Wed, 30 May 2018 11:32:18 -0700
MIME-Version: 1.0
In-Reply-To: <20180529211724.4531-14-josef@toxicpanda.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josef Bacik <josef@toxicpanda.com>, axboe@kernel.dk, kernel-team@fb.com, linux-block@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, linux-fsdevel@vger.kernel.org
Cc: Josef Bacik <jbacik@fb.com>

On 05/29/2018 02:17 PM, Josef Bacik wrote:
> From: Josef Bacik <jbacik@fb.com>
> 
> A basic documentation to describe the interface, statistics, and
> behavior of io.latency.
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>
> ---
>  Documentation/blk-iolatency.txt | 80 +++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 80 insertions(+)
>  create mode 100644 Documentation/blk-iolatency.txt
> 
> diff --git a/Documentation/blk-iolatency.txt b/Documentation/blk-iolatency.txt
> new file mode 100644
> index 000000000000..9dd86f4f64b6
> --- /dev/null
> +++ b/Documentation/blk-iolatency.txt
> @@ -0,0 +1,80 @@
> +Block IO Latency Controller
> +
> +Overview
> +========
> +
> +This is a cgroup v2 controller for IO workload protection.  You provide a group
> +with a latency target, and if the average latency exceeds that target the
> +controller will throttle any peers that have a lower latency target than the
> +protected workload.
> +
> +Interface
> +=========
> +
> +- io.latency.  This takes a similar format as the other controllers

              end above sentence with a period or a colon:

> +
> +	"MAJOR:MINOR target=<target time in microseconds"
> +
> +- io.stat.  If the controller is enabled you will see extra stats in io.stat in
> +  addition to the normal ones

                end above sentence with a period.

> +
> +	- depth=<integer>.  This is the current queue depth for the group.
> +	- delay=<time in microseconds>. This is the current delay per task that
> +	  does IO in this group.
> +	- use_delay=<integer>.  This is how deep into the delay we currently
> +	  are, the larger this number is the longer it'll take us to get back to
> +	  queue depth > 1.
> +	- total_lat_avg=<time in microseconds>.  The running average IO latency
> +	  for this group.  Running average is generally flawed, but will give an
> +	  admistrator a general idea of the overall latency they can expect for

	  administrator

> +	  their workload on the given disk.
> +
> +HOWTO
> +=====
> +
> +The limits are only applied at the peer level in the heirarchy.  This means that
> +in the diagram below, only groups A, B, and C will influence eachother, and

                                                                each other, and

> +groups D and F will influence eachother.  Group G will influence nobody.

                                 each other.

> +
> +			[root]
> +		/	   |		\
> +		A	   B		C
> +	       /  \        |
> +	      D    F	   G
> +
> +
> +So the ideal way to configure this is to set io.latency in groups A, B, and C.
> +Generally you do not want to set a value lower than the latency your device
> +supports.  Experiment to find the value that works best for your workload, start
> +at higher than the expected latency for your device and watch the total_lat_avg
> +value in io.stat for your workload group to get an idea of the latency you see
> +during normal operation.  Use this value as a basis for your real setting,
> +setting at 10-15% higher than the value in io.stat.  Experimentation is key here
> +because total_lat_avg is a running total, so is the "statistics" portion of
> +"lies, damned lies, and statistics."
> +
> +How Throttling Works
> +====================
> +
> +io.latency is work conserving, so as long as everybody is meeting their latency
> +target the controller doesn't do anything.  Once a group starts missing it's

                                                                           its

> +target it begins throttling any peer group that has a higher target than itself.
> +This throttling takes 2 forms

                         2 forms:

> +
> +- Queue depth throttling.  This is the number of outstanding IO's a group is
> +  allowed to have.  We will clamp down relatively quickly, starting at no limit
> +  and going all the way down to 1 IO at a time.
> +
> +- Artificial delay induction.  There are certain types of IO that cannot be
> +  throttled without possibly adversely affecting higher priority groups.  This
> +  includes swapping and metadata IO.  These types of IO are allowed to occur
> +  normally, however they are "charged" to the originating group.  If the
> +  originating group is being throttled you will see the use_delay and delay
> +  fields in io.stat increase.  The delay value is how many microseconds that are
> +  being added to any process that runs in this group.  Because this number can
> +  grow quite large if there is a lot of swapping or metadata IO occuring we

                                                                   occurring

> +  limit the individual delay events to 1 second at a time.
> +
> +Once the victimized group starts meeting it's latency target again it will start

                                            its

> +unthrottling any peer groups that were throttled previous.  If the victimized

                                                    previously.

> +group simply stops doing IO the global counter will unthrottle appropriately.
> 


-- 
~Randy
