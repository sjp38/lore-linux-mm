Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 791B46B00C2
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 02:17:20 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id hz1so10095615pad.16
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 23:17:20 -0800 (PST)
Received: from psmtp.com ([74.125.245.140])
        by mx.google.com with SMTP id hb3si16407864pac.268.2013.11.05.23.17.18
        for <linux-mm@kvack.org>;
        Tue, 05 Nov 2013 23:17:19 -0800 (PST)
Received: by mail-ie0-f172.google.com with SMTP id tp5so17176283ieb.17
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 23:17:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAA25o9QG2BOmV5MoXCH73sadKoRD6wPivKq6TLvEem8GhZeXGg@mail.gmail.com>
References: <1383693987-14171-1-git-send-email-snanda@chromium.org>
	<alpine.DEB.2.02.1311051715090.29471@chino.kir.corp.google.com>
	<CAA25o9SFZW7JxDQGv+h43EMSS3xH0eXy=LoHO_Psmk_n3dxqoA@mail.gmail.com>
	<alpine.DEB.2.02.1311051727090.29471@chino.kir.corp.google.com>
	<CANMivWZrefY1bbgpJgABqcUwKfqOR9HQtGNY6cWdutcMASeo2A@mail.gmail.com>
	<CAA25o9QG2BOmV5MoXCH73sadKoRD6wPivKq6TLvEem8GhZeXGg@mail.gmail.com>
Date: Tue, 5 Nov 2013 23:17:16 -0800
Message-ID: <CAA25o9Q-HvjQ_5pFJgYNeutaCoYgPu=e=k7EHq=6-+jeEuhzoA@mail.gmail.com>
Subject: Re: [PATCH] mm, oom: Fix race when selecting process to kill
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sameer Nanda <snanda@chromium.org>, msb@facebook.com
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.cz, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Regarding other fixes: would it be possible to have the thread
iterator insert a dummy marker element in the thread list before the
scan?  There would be one such dummy element per CPU, so that multiple
CPUs can scan the list in parallel.  The loop would skip such
elements, and each dummy element would be removed at the end of each
scan.

I think this would work, i.e. it would have all the right properties,
but I don't have a sense of whether the performance impact is
acceptable.  Probably not, or it would have been proposed earlier.



On Tue, Nov 5, 2013 at 8:45 PM, Luigi Semenzato <semenzato@google.com> wrote:
> It's interesting that this was known for 3+ years, but nobody bothered
> adding a small warning to the code.
>
> We noticed this because it's actually happening on Chromebooks in the
> field.  We try to minimize OOM kills, but we can deal with them.  Of
> course, a hung kernel we cannot deal with.
>
> On Tue, Nov 5, 2013 at 7:04 PM, Sameer Nanda <snanda@chromium.org> wrote:
>>
>>
>>
>> On Tue, Nov 5, 2013 at 5:27 PM, David Rientjes <rientjes@google.com> wrote:
>>>
>>> On Tue, 5 Nov 2013, Luigi Semenzato wrote:
>>>
>>> > It's not enough to hold a reference to the task struct, because it can
>>> > still be taken out of the circular list of threads.  The RCU
>>> > assumptions don't hold in that case.
>>> >
>>>
>>> Could you please post a proper bug report that isolates this at the cause?
>>
>>
>> We've been running into this issue on Chrome OS. crbug.com/256326 has
>> additional
>> details.  The issue manifests itself as a soft lockup.
>>
>> The kernel we've been seeing this on is 3.8.
>>
>> We have a pretty consistent repro currently.  Happy to try out other
>> suggestions
>> for a fix.
>>
>>>
>>>
>>> Thanks.
>>
>>
>>
>>
>> --
>> Sameer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
