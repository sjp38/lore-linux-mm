Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id m9L1TUra004730
	for <linux-mm@kvack.org>; Mon, 20 Oct 2008 18:29:31 -0700
Received: from qw-out-2122.google.com (qwi5.prod.google.com [10.241.195.5])
	by zps35.corp.google.com with ESMTP id m9L1TTqS012918
	for <linux-mm@kvack.org>; Mon, 20 Oct 2008 18:29:29 -0700
Received: by qw-out-2122.google.com with SMTP id 5so601472qwi.57
        for <linux-mm@kvack.org>; Mon, 20 Oct 2008 18:29:28 -0700 (PDT)
Message-ID: <6599ad830810201829o5483ef48g633e920cce9cc015@mail.gmail.com>
Date: Mon, 20 Oct 2008 18:29:28 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH -mm 1/5] memcg: replace res_counter
In-Reply-To: <20081021101430.d2629a81.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20081017194804.fce28258.nishimura@mxp.nes.nec.co.jp>
	 <20081017195601.0b9abda1.nishimura@mxp.nes.nec.co.jp>
	 <6599ad830810201253u3bca41d4rabe48eb1ec1d529f@mail.gmail.com>
	 <20081021101430.d2629a81.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, Oct 20, 2008 at 6:14 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> 1. It's harmful to increase size of *generic* res_counter. So, modifing
>   res_counter only for us is not a choice.

Adding an extra pointer to a per-cgroup structure isn't particularly harmful.

> 2. Operation should be done under a lock. We have to do
>   -page + swap in atomic, at least.

How bad would things really be if you did something like the code below?

if (charge_swap()) {
  uncharge_mem();
} else {
  return -ENOMEM;
}

It's true that this introduces a tiny race whereby a single swap-in
page allocation that might have succeeded could fail, but if you're
that close to the limit your cgroup is heading for an OOM anyway.

> 3. We want to pack all member into a cache-line, multiple res_counter
>   is no good.

As I said previously, if we do a prefetch on the aggregated
res_counter before we touch any fields in the basic counter, then in
theory we should never have to wait on a cache miss on the aggregated
counter - either we have no misses (if both were in cache) or we fetch
both lines concurrently (if neither were in cache). Do you think that
reasoning is invalid?

>
>> Maybe have an "aggregate" pointer in a res_counter that points to
>> another res_counter that sums some number of counters; both the mem
>> and the swap res_counter objects for a cgroup would point to the
>> mem+swap res_counter for their aggregate. Adjusting the usage of a
>> counter would also adjust its aggregate (or fail if adjusting the
>> aggregate failed).
>>
> It's complicated.

Agreed, it's a bit more complicated than defining a new structure and
code that's very reminiscent of res_counter. But it does solve the
problem of aggregating across multiple resource types and multiple
children in a generic way.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
