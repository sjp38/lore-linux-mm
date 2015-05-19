Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id D26CC6B00B1
	for <linux-mm@kvack.org>; Tue, 19 May 2015 09:46:40 -0400 (EDT)
Received: by igbpi8 with SMTP id pi8so75782405igb.1
        for <linux-mm@kvack.org>; Tue, 19 May 2015 06:46:40 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0077.hostedemail.com. [216.40.44.77])
        by mx.google.com with ESMTP id im9si210611igb.59.2015.05.19.06.46.39
        for <linux-mm@kvack.org>;
        Tue, 19 May 2015 06:46:40 -0700 (PDT)
Date: Tue, 19 May 2015 09:46:36 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: linux-next: Tree for May 18 (mm/memory-failure.c)
Message-ID: <20150519094636.67c9a4a3@gandalf.local.home>
In-Reply-To: <20150519024933.GA1614@hori1.linux.bs1.fc.nec.co.jp>
References: <20150518185226.23154d47@canb.auug.org.au>
	<555A0327.9060709@infradead.org>
	<20150519024933.GA1614@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Randy Dunlap <rdunlap@infradead.org>, Stephen Rothwell <sfr@canb.auug.org.au>, "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Jim Davis <jim.epost@gmail.com>, Chen Gong <gong.chen@linux.intel.com>

On Tue, 19 May 2015 02:49:34 +0000
Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> On Mon, May 18, 2015 at 08:20:07AM -0700, Randy Dunlap wrote:
> > On 05/18/15 01:52, Stephen Rothwell wrote:
> > > Hi all,
> > > 
> > > Changes since 20150515:
> > > 
> > 
> > on i386:
> > 
> > mm/built-in.o: In function `action_result':
> > memory-failure.c:(.text+0x344a5): undefined reference to `__tracepoint_memory_failure_event'
> > memory-failure.c:(.text+0x344d5): undefined reference to `__tracepoint_memory_failure_event'
> > memory-failure.c:(.text+0x3450c): undefined reference to `__tracepoint_memory_failure_event'
> 
> Thanks for the reporting, Randy.
> Here is a patch for this problem, could you try it?
> 
> Thanks,
> Naoya
> ---
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Subject: [PATCH] ras: hwpoison: fix build failure around
>  trace_memory_failure_event
> 
> next-20150515 fails to build on i386 with the following error:
> 
>   mm/built-in.o: In function `action_result':
>   memory-failure.c:(.text+0x344a5): undefined reference to `__tracepoint_memory_failure_event'
>   memory-failure.c:(.text+0x344d5): undefined reference to `__tracepoint_memory_failure_event'
>   memory-failure.c:(.text+0x3450c): undefined reference to `__tracepoint_memory_failure_event'
> 
> Defining CREATE_TRACE_POINTS and TRACE_INCLUDE_PATH fixes it.
> 
> Reported-by: Randy Dunlap <rdunlap@infradead.org>
> Reported-by: Jim Davis <jim.epost@gmail.com>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> ---
>  drivers/ras/ras.c       | 1 -
>  include/ras/ras_event.h | 2 ++
>  mm/memory-failure.c     | 1 +
>  3 files changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/ras/ras.c b/drivers/ras/ras.c
> index b67dd362b7b6..3e2745d8e221 100644
> --- a/drivers/ras/ras.c
> +++ b/drivers/ras/ras.c
> @@ -9,7 +9,6 @@
>  #include <linux/ras.h>
>  
>  #define CREATE_TRACE_POINTS
> -#define TRACE_INCLUDE_PATH ../../include/ras
>  #include <ras/ras_event.h>
>  
>  static int __init ras_init(void)
> diff --git a/include/ras/ras_event.h b/include/ras/ras_event.h
> index 1443d79e4fe6..43054c0fcf65 100644
> --- a/include/ras/ras_event.h
> +++ b/include/ras/ras_event.h
> @@ -1,6 +1,8 @@
>  #undef TRACE_SYSTEM
>  #define TRACE_SYSTEM ras
>  #define TRACE_INCLUDE_FILE ras_event
> +#undef TRACE_INCLUDE_PATH
> +#define TRACE_INCLUDE_PATH ../../include/ras

Note, ideally, you want:

#define TRACE_INCLUDE_PATH .

and change the Makefile to have:

CFLAGS_ras.o := -I$(src)

...


>  
>  #if !defined(_TRACE_HW_EVENT_MC_H) || defined(TRACE_HEADER_MULTI_READ)
>  #define _TRACE_HW_EVENT_MC_H
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index 8cbe23ac1056..e88e14d87571 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -57,6 +57,7 @@
>  #include <linux/mm_inline.h>
>  #include <linux/kfifo.h>
>  #include "internal.h"
> +#define CREATE_TRACE_POINTS
>  #include "ras/ras_event.h"

Um, you can only define CREATE_TRACE_POINTS for a single instance.
Otherwise you will be making duplicate functions with the same name and
same variables.

That is, you must either pick CREATE_TRACE_POINTS for ras_event.h in
mm/memory-failure.c or drivers/ras/ras.c. Not both.

-- Steve


>  
>  int sysctl_memory_failure_early_kill __read_mostly = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
