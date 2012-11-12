Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id EAEE36B0072
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 17:14:42 -0500 (EST)
Received: by mail-la0-f41.google.com with SMTP id p5so6274680lag.14
        for <linux-mm@kvack.org>; Mon, 12 Nov 2012 14:14:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121108155112.GN31821@dhcp22.suse.cz>
References: <alpine.DEB.2.00.1211080125150.3450@chino.kir.corp.google.com>
	<alpine.DEB.2.00.1211080126390.3450@chino.kir.corp.google.com>
	<20121108155112.GN31821@dhcp22.suse.cz>
Date: Mon, 12 Nov 2012 20:14:40 -0200
Message-ID: <CACnwZYcUEmEStT7uwN3O3=m34uLi9YnJSYWFPZafuzCy_t4uaw@mail.gmail.com>
Subject: Re: [patch 2/2] mm, oom: fix race when specifying a thread as the oom origin
From: Thiago Farina <tfransosi@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Anton Vorontsov <anton.vorontsov@linaro.org>, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Nov 8, 2012 at 1:51 PM, Michal Hocko <mhocko@suse.cz> wrote:
> On Thu 08-11-12 01:27:00, David Rientjes wrote:
>> test_set_oom_score_adj() and compare_swap_oom_score_adj() are used to
>> specify that current should be killed first if an oom condition occurs in
>> between the two calls.
>>
>> The usage is
>>
>>       short oom_score_adj = test_set_oom_score_adj(OOM_SCORE_ADJ_MAX);
>>       ...
>>       compare_swap_oom_score_adj(OOM_SCORE_ADJ_MAX, oom_score_adj);
>>
>> to store the thread's oom_score_adj, temporarily change it to the maximum
>> score possible, and then restore the old value if it is still the same.
>>
>> This happens to still be racy, however, if the user writes
>> OOM_SCORE_ADJ_MAX to /proc/pid/oom_score_adj in between the two calls.
>> The compare_swap_oom_score_adj() will then incorrectly reset the old
>> value prior to the write of OOM_SCORE_ADJ_MAX.
>>
>> To fix this, introduce a new oom_flags_t member in struct signal_struct
>> that will be used for per-thread oom killer flags.  KSM and swapoff can
>> now use a bit in this member to specify that threads should be killed
>> first in oom conditions without playing around with oom_score_adj.
>>
>> This also allows the correct oom_score_adj to always be shown when
>> reading /proc/pid/oom_score.
>>
>> Signed-off-by: David Rientjes <rientjes@google.com>
>
> I didn't like the previous playing with the oom_score_adj and what you
> propose looks much nicer.
> Maybe s/oom_task_origin/task_oom_origin/ would be a better fit
May be s/oom_task_origin/is_task_origin_oom? Just my 2 cents.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
