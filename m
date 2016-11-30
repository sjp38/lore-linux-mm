Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id C25A16B0038
	for <linux-mm@kvack.org>; Tue, 29 Nov 2016 23:32:55 -0500 (EST)
Received: by mail-oi0-f71.google.com with SMTP id l192so345190381oih.2
        for <linux-mm@kvack.org>; Tue, 29 Nov 2016 20:32:55 -0800 (PST)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id l13si30248938otl.109.2016.11.29.20.32.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Nov 2016 20:32:54 -0800 (PST)
Subject: Re: next: Commit 'mm: Prevent __alloc_pages_nodemask() RCU CPU stall
 ...' causing hang on sparc32 qemu
References: <20161129212308.GA12447@roeck-us.net>
 <20161130012817.GH3924@linux.vnet.ibm.com>
From: Guenter Roeck <linux@roeck-us.net>
Message-ID: <b96c1560-3f06-bb6d-717a-7a0f0c6e869a@roeck-us.net>
Date: Tue, 29 Nov 2016 20:32:51 -0800
MIME-Version: 1.0
In-Reply-To: <20161130012817.GH3924@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, sparclinux@vger.kernel.org, davem@davemloft.net

On 11/29/2016 05:28 PM, Paul E. McKenney wrote:
> On Tue, Nov 29, 2016 at 01:23:08PM -0800, Guenter Roeck wrote:
>> Hi Paul,
>>
>> most of my qemu tests for sparc32 targets started to fail in next-20161129.
>> The problem is only seen in SMP builds; non-SMP builds are fine.
>> Bisect points to commit 2d66cccd73436 ("mm: Prevent __alloc_pages_nodemask()
>> RCU CPU stall warnings"); reverting that commit fixes the problem.
>>
>> Test scripts are available at:
>> 	https://github.com/groeck/linux-build-test/tree/master/rootfs/sparc
>> Test results are at:
>> 	https://github.com/groeck/linux-build-test/tree/master/rootfs/sparc
>>
>> Bisect log is attached.
>>
>> Please let me know if there is anything I can do to help tracking down the
>> problem.
>
> Apologies!!!  Does the patch below help?
>
No, sorry, it doesn't make a difference.

Guenter

> 							Thanx, Paul
>
> ------------------------------------------------------------------------
>
> commit 97708e737e2a55fed4bdbc005bf05ea909df6b73
> Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Date:   Tue Nov 29 11:06:05 2016 -0800
>
>     rcu: Allow boot-time use of cond_resched_rcu_qs()
>
>     The cond_resched_rcu_qs() macro is used to force RCU quiescent states into
>     long-running in-kernel loops.  However, some of these loops can execute
>     during early boot when interrupts are disabled, and during which time
>     it is therefore illegal to enter the scheduler.  This commit therefore
>     makes cond_resched_rcu_qs() be a no-op during early boot.
>
>     Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
>
> diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
> index 525ca34603b7..b6944cc19a07 100644
> --- a/include/linux/rcupdate.h
> +++ b/include/linux/rcupdate.h
> @@ -423,7 +423,7 @@ extern struct srcu_struct tasks_rcu_exit_srcu;
>   */
>  #define cond_resched_rcu_qs() \
>  do { \
> -	if (!cond_resched()) \
> +	if (!is_idle_task(current) && !cond_resched()) \
>  		rcu_note_voluntary_context_switch(current); \
>  } while (0)
>
> diff --git a/include/linux/rcutiny.h b/include/linux/rcutiny.h
> index 7232d199a81c..20f5990deeee 100644
> --- a/include/linux/rcutiny.h
> +++ b/include/linux/rcutiny.h
> @@ -228,6 +228,7 @@ static inline void exit_rcu(void)
>  extern int rcu_scheduler_active __read_mostly;
>  void rcu_scheduler_starting(void);
>  #else /* #ifdef CONFIG_DEBUG_LOCK_ALLOC */
> +#define rcu_scheduler_active false
>  static inline void rcu_scheduler_starting(void)
>  {
>  }
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
