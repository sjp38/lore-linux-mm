Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id A94206B0095
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 20:12:35 -0400 (EDT)
Received: by mail-pa0-f44.google.com with SMTP id bj1so10613983pad.31
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 17:12:35 -0700 (PDT)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp. [192.51.44.36])
        by mx.google.com with ESMTPS id h3si104865paw.250.2014.04.01.17.12.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 01 Apr 2014 17:12:34 -0700 (PDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 321343EE0C1
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 09:12:33 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 202F145DEBA
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 09:12:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.nic.fujitsu.com [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F392345DD76
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 09:12:32 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E4575E08003
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 09:12:32 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id F29AB1DB8038
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 09:12:31 +0900 (JST)
Message-ID: <533B55AE.9090906@jp.fujitsu.com>
Date: Wed, 02 Apr 2014 09:11:26 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] ipc,shm: increase default size for shmmax
References: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net> <20140331143217.c6ff958e1fd9944d78507418@linux-foundation.org> <1396306773.18499.22.camel@buesod1.americas.hpqcorp.net> <20140331161308.6510381345cb9a1b419d5ec0@linux-foundation.org> <1396308332.18499.25.camel@buesod1.americas.hpqcorp.net> <20140331170546.3b3e72f0.akpm@linux-foundation.org> <533A5CB1.1@jp.fujitsu.com> <20140401121920.50d1dd96c2145acc81561b82@linux-foundation.org> <CAHGf_=r03QWxw3Jg7BE3z37k4omgo_HRE9qCGw80ngtUD_iEeA@mail.gmail.com>
In-Reply-To: <CAHGf_=r03QWxw3Jg7BE3z37k4omgo_HRE9qCGw80ngtUD_iEeA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Davidlohr Bueso <davidlohr@hp.com>, Manfred Spraul <manfred@colorfullife.com>, aswin@hp.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Gotou, Yasunori" <y-goto@jp.fujitsu.com>, chenhanxiao <chenhanxiao@cn.fujitsu.com>, Gao feng <gaofeng@cn.fujitsu.com>

(2014/04/02 5:15), KOSAKI Motohiro wrote:
>>> Our middleware engineers has been complaining about this sysctl limit.
>>> System administrator need to calculate required sysctl value by making sum
>>> of all planned middlewares, and middleware provider needs to write "please
>>> calculate systcl param by....." in their installation manuals.
>>
>> Why aren't people just setting the sysctl to a petabyte?  What problems
>> would that lead to?
>
> I don't have much Fujitsu middleware knowledges. But I'd like to explain
> very funny bug I saw.
>
> 1. middleware-A suggest to set SHMMAX to very large value (maybe
> LONG_MAX, but my memory was flushed)
> 2. middleware-B suggest to set SHMMAX to increase some dozen mega byte.
>
> Finally, it was overflow and didn't work at all.
>
> Let's demonstrate.
>
> # echo 18446744073709551615 > /proc/sys/kernel/shmmax
> # cat /proc/sys/kernel/shmmax
> 18446744073709551615
> # echo 18446744073709551616 > /proc/sys/kernel/shmmax
> # cat /proc/sys/kernel/shmmax
> 0
>
> That's why many open source software continue the silly game. But
> again, I don't have knowledge about Fujitsu middleware. I'm waiting
> kamezawa-san's answer.
>

Nowadays, Middleware/application are required to be installed automatically without
any admin's operations. But the shmmax tends to be a value which admin needs to modify
by hand after installation. This is not the last one problem, but it is.

I says MW engineers "you, middleware/application, can modify it automatically
as you needed, there will be no pain".

But they tend not to do it. (in my guess) in application writer's way on thinking..
   - If there is a limit by OS, it should have some meaning.
     There may be an unknown, os internal reason which the system admin need to check it.
     For example, os will consume more resource when shmmax is enlarged.
   - If there is a limit by OS, it should be modified by admin.

I guess customer thinks so, too. There is no official information "increasing shmmax
will not cunsume any resource and will not cause any problem in the kernel inside."

Then, admins need to set it. Middleware needs to write "please modify the sysctl
value based on this calculation....." in their manual.

I think the worst problem about this "limit" is that it's hard to explain "why this limit
exists". I need to answer "I guess it's just legacy, hehe...."

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
