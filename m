Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 926E76B00EE
	for <linux-mm@kvack.org>; Mon, 15 Aug 2011 06:33:26 -0400 (EDT)
Message-ID: <4E48F5F3.2020509@suse.cz>
Date: Mon, 15 Aug 2011 12:33:23 +0200
From: Michal Marek <mmarek@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Switch NUMA_BUILD and COMPACTION_BUILD to new IS_ENABLED()
 syntax
References: <1312989160-737-1-git-send-email-mmarek@suse.cz> <20110815102707.GA3967@tiehlicka.suse.cz>
In-Reply-To: <20110815102707.GA3967@tiehlicka.suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 15.8.2011 12:27, Michal Hocko wrote:
> On Wed 10-08-11 17:12:40, Michal Marek wrote:
>> Introduced in 3.1-rc1, IS_ENABLED(CONFIG_NUMA) expands to a true value
>> iff CONFIG_NUMA is set. This makes it easier to grep for code that
>> depends on CONFIG_NUMA.
> 
> It looks this doesn't work properly. I can see the following build
> error:
>   CHK     include/linux/version.h
>   CHK     include/generated/utsrelease.h
>   UPD     include/generated/utsrelease.h
>   CC      arch/x86/kernel/asm-offsets.s
> In file included from include/linux/kmod.h:22:0,
>                  from include/linux/module.h:13,
>                  from include/linux/crypto.h:21,
>                  from arch/x86/kernel/asm-offsets.c:8:
> include/linux/gfp.h: In function a??gfp_zonelista??:
> include/linux/gfp.h:265:1: error: a??__enabled_CONFIG_NUMAa?? undeclared (first use in this function)
> include/linux/gfp.h:265:1: note: each undeclared identifier is reported only once for each function it appears in
> include/linux/gfp.h:265:1: error: a??__enabled_CONFIG_NUMA_MODULEa?? undeclared (first use in this function)
> make[1]: *** [arch/x86/kernel/asm-offsets.s] Error 1
> 
> I do not have CONFIG_NUMA set so it seems to have issues with config
> symbols which are not set to any value. Is this something that could be
> fixed?

It works if CONFIG_NUMA is not set, but it doesn't work if CONFIG_NUMA
is not visible (if its dependencies are not met). The fix would be to
generate the __enabled_* defines for all symbols, not only for the
visible ones. I'll repost the patch once this is fixed.

Michal

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
