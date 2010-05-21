Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D94AA6B01B1
	for <linux-mm@kvack.org>; Fri, 21 May 2010 16:08:44 -0400 (EDT)
Date: Fri, 21 May 2010 13:08:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] cpu_up: hold zonelists_mutex when build_all_zonelists
Message-Id: <20100521130808.919ecb35.akpm@linux-foundation.org>
In-Reply-To: <4BF4AB24.7070107@linux.intel.com>
References: <201005192322.o4JNMu5v012158@imap1.linux-foundation.org>
	<4BF4AB24.7070107@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Haicheng Li <haicheng.li@linux.intel.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, andi.kleen@intel.com, cl@linux-foundation.org, fengguang.wu@intel.com, mel@csn.ul.ie, tj@kernel.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, minskey guo <chaohong.guo@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, 20 May 2010 11:23:16 +0800
Haicheng Li <haicheng.li@linux.intel.com> wrote:

> 
> Here is another issue, we should always hold zonelists_mutex when calling build_all_zonelists
> unless system_state == SYSTEM_BOOTING.

Taking a global mutex in the cpu-hotplug code is worrisome.  Perhaps
because of the two years spent weeding out strange deadlocks between
cpu-hotplug and cpufreq.

Has this change been carefully and fully tested with lockdep enabled
(please)?

> --- a/kernel/cpu.c
> +++ b/kernel/cpu.c
> @@ -357,8 +357,11 @@ int __cpuinit cpu_up(unsigned int cpu)
>                  return -ENOMEM;
>          }
> 
> -       if (pgdat->node_zonelists->_zonerefs->zone == NULL)
> +       if (pgdat->node_zonelists->_zonerefs->zone == NULL) {
> +               mutex_lock(&zonelists_mutex);
>                  build_all_zonelists(NULL);
> +               mutex_unlock(&zonelists_mutex);
> +       }

Your email client is performing space-stuffing and it replaces tabs
with spaces.  This requires me to edit the patches rather a lot,
which is dull.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
