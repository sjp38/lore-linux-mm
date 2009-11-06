Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 67CB76B004D
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 14:03:31 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA6J3SR7031640
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 7 Nov 2009 04:03:28 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D367C45DE4F
	for <linux-mm@kvack.org>; Sat,  7 Nov 2009 04:03:27 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9124D45DE52
	for <linux-mm@kvack.org>; Sat,  7 Nov 2009 04:03:27 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 36709EF8027
	for <linux-mm@kvack.org>; Sat,  7 Nov 2009 04:03:27 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C997EF8049
	for <linux-mm@kvack.org>; Sat,  7 Nov 2009 04:03:18 +0900 (JST)
Message-ID: <da621335371fccd6cfb3d8d7c0c2bf3a.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <alpine.DEB.1.10.0911061231580.5187@V090114053VZO-1>
References: <alpine.DEB.1.10.0911041409020.7409@V090114053VZO-1>
    <20091104234923.GA25306@redhat.com>
    <alpine.DEB.1.10.0911051004360.25718@V090114053VZO-1>
    <alpine.DEB.1.10.0911051035100.25718@V090114053VZO-1>
    <20091106101106.8115e0f1.kamezawa.hiroyu@jp.fujitsu.com>
    <20091106122344.51118116.kamezawa.hiroyu@jp.fujitsu.com>
    <alpine.DEB.1.10.0911061231580.5187@V090114053VZO-1>
Date: Sat, 7 Nov 2009 04:03:17 +0900 (JST)
Subject: Re: [MM] Make mm counters per cpu instead of atomic V2
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Jones <davej@redhat.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Fri, 6 Nov 2009, KAMEZAWA Hiroyuki wrote:
>
>> BTW, can't we have single-thread-mode for this counter ?
>> Usual program's read-side will get much benefit.....
>
> Thanks for the measurements.
>
> A single thread mode would be good. Ideas on how to add that would be
> appreciated.
>

Maybe there are some ways....At brief thought....
==
struct usage_counter {
    long rss;
    long file;
}


struct mm_struct {
    ....
    atomic_long_t  rss;   /* only updated when usage_counter is NULL */
    atomic_long_t  file;  /* only updated when usage_counter is NULL */
    struct usage_counter *usage;  /* percpu counter used when
                                     multi-threaded */
    .....
}

And allocate mm->usage only when the first CLONE_THREAD is specified.

if (mm->usage)
    access per cpu
else
    atomic_long_xxx

and read operation will be

    val = atomic_read(mm->rss);
    if (mm->usage)
        for_each_possible_cpu()....
==
Does "if" seems too costly ?

If this idea is bad, I think moving mm_counter to task_struct from
mm_struct and doing slow-sync is an idea instead of percpu.

for example

struct task_struct {
    ....
    mm_counter_t temp_counter;
    ....
};

struct mm_struct {
    .....
    atomic_long_t rss;
    atomic_long_t file;
};

And adds temp_counter's value to mm_struct at some good point....before
sleep ?
kswapd and reclaim routine can update mm_struct's counter, directly.
Readers just read mm_struct's counter.

Thanks,
-Kame









--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
