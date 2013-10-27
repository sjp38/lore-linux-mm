Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id F384F6B00DC
	for <linux-mm@kvack.org>; Sun, 27 Oct 2013 07:23:01 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so5891202pab.8
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 04:23:01 -0700 (PDT)
Received: from psmtp.com ([74.125.245.169])
        by mx.google.com with SMTP id kk1si9259038pbc.64.2013.10.27.04.23.00
        for <linux-mm@kvack.org>;
        Sun, 27 Oct 2013 04:23:00 -0700 (PDT)
Received: by mail-qa0-f47.google.com with SMTP id k15so1507970qaq.6
        for <linux-mm@kvack.org>; Sun, 27 Oct 2013 04:22:59 -0700 (PDT)
Date: Sun, 27 Oct 2013 07:22:55 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/3] percpu counter: cast this_cpu_sub() adjustment
Message-ID: <20131027112255.GB14934@mtj.dyndns.org>
References: <1382859876-28196-1-git-send-email-gthelen@google.com>
 <1382859876-28196-3-git-send-email-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1382859876-28196-3-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, handai.szj@taobao.com, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

On Sun, Oct 27, 2013 at 12:44:35AM -0700, Greg Thelen wrote:
> this_cpu_sub() is implemented as negation and addition.
> 
> This patch casts the adjustment to the counter type before negation to
> sign extend the adjustment.  This helps in cases where the counter
> type is wider than an unsigned adjustment.  An alternative to this
> patch is to declare such operations unsupported, but it seemed useful
> to avoid surprises.
> 
> This patch specifically helps the following example:
>   unsigned int delta = 1
>   preempt_disable()
>   this_cpu_write(long_counter, 0)
>   this_cpu_sub(long_counter, delta)
>   preempt_enable()
> 
> Before this change long_counter on a 64 bit machine ends with value
> 0xffffffff, rather than 0xffffffffffffffff.  This is because
> this_cpu_sub(pcp, delta) boils down to this_cpu_add(pcp, -delta),
> which is basically:
>   long_counter = 0 + 0xffffffff
> 
> Also apply the same cast to:
>   __this_cpu_sub()
>   this_cpu_sub_return()
>   and __this_cpu_sub_return()
> 
> All percpu_test.ko passes, especially the following cases which
> previously failed:
> 
>   l -= ui_one;
>   __this_cpu_sub(long_counter, ui_one);
>   CHECK(l, long_counter, -1);
> 
>   l -= ui_one;
>   this_cpu_sub(long_counter, ui_one);
>   CHECK(l, long_counter, -1);
>   CHECK(l, long_counter, 0xffffffffffffffff);
> 
>   ul -= ui_one;
>   __this_cpu_sub(ulong_counter, ui_one);
>   CHECK(ul, ulong_counter, -1);
>   CHECK(ul, ulong_counter, 0xffffffffffffffff);
> 
>   ul = this_cpu_sub_return(ulong_counter, ui_one);
>   CHECK(ul, ulong_counter, 2);
> 
>   ul = __this_cpu_sub_return(ulong_counter, ui_one);
>   CHECK(ul, ulong_counter, 1);
> 
> Signed-off-by: Greg Thelen <gthelen@google.com>

Ouch, nice catch.

 Acked-by: Tejun Heo <tj@kernel.org>

We probably want to cc stable for this and the next one.  How should
these be routed?  I can take these through percpu tree or mm works
too.  Either way, it'd be best to route them together.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
