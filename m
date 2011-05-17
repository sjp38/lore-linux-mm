Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 729186B0025
	for <linux-mm@kvack.org>; Tue, 17 May 2011 16:58:28 -0400 (EDT)
Received: by bwz17 with SMTP id 17so1298406bwz.14
        for <linux-mm@kvack.org>; Tue, 17 May 2011 13:58:25 -0700 (PDT)
Message-ID: <4DD2E16D.1030001@gmail.com>
Date: Tue, 17 May 2011 22:58:21 +0200
From: Jiri Slaby <jirislaby@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] checkpatch.pl: Add check for task comm references
References: <1305665263-20933-1-git-send-email-john.stultz@linaro.org> <1305665263-20933-4-git-send-email-john.stultz@linaro.org>
In-Reply-To: <1305665263-20933-4-git-send-email-john.stultz@linaro.org>
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Joe Perches <joe@perches.com>, Michal Nazarewicz <mina86@mina86.com>, Andy Whitcroft <apw@canonical.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On 05/17/2011 10:47 PM, John Stultz wrote:
> Now that accessing current->comm needs to be protected,
> avoid new current->comm or other task->comm usage by adding
> a warning to checkpatch.pl.
> 
> Fair warning: I know zero perl, so this was written in the
> style of "monkey see, monkey do". It does appear to work
> in my testing though.
> 
> Thanks to Jiri Slaby, Michal Nazarewicz and Joe Perches
> for help improving the regex!
> 
> Close review and feedback would be appreciated.
> 
> CC: Joe Perches <joe@perches.com>
> CC: Michal Nazarewicz <mina86@mina86.com>
> CC: Andy Whitcroft <apw@canonical.com>
> CC: Jiri Slaby <jirislaby@gmail.com>
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: David Rientjes <rientjes@google.com>
> CC: Dave Hansen <dave@linux.vnet.ibm.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> CC: linux-mm@kvack.org
> Signed-off-by: John Stultz <john.stultz@linaro.org>
> ---
>  scripts/checkpatch.pl |    7 +++++++
>  1 files changed, 7 insertions(+), 0 deletions(-)
> 
> diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
> index d867081..a67ea69 100755
> --- a/scripts/checkpatch.pl
> +++ b/scripts/checkpatch.pl
> @@ -2868,6 +2868,13 @@ sub process {
>  			WARN("usage of NR_CPUS is often wrong - consider using cpu_possible(), num_possible_cpus(), for_each_possible_cpu(), etc\n" . $herecurr);
>  		}
>  
> +# check for current->comm usage
> +		our $common_comm_vars = qr{(?x:
> +		        current|tsk|p|task|curr|chip|t|object|me

Hrm, chip->comm looks like a total bullshit.
object->comm refers to kmemleak object, so this would trigger false
alarms too.

> +		)};
> +		if ($line =~ /\b($common_comm_vars)\s*->\s*comm\b/) {
> +			WARN("comm access needs to be protected. Use get_task_comm, or printk's \%ptc formatting.\n" . $herecurr);
> +		}
>  # check for %L{u,d,i} in strings
>  		my $string;
>  		while ($line =~ /(?:^|")([X\t]*)(?:"|$)/g) {

thanks,
-- 
js

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
