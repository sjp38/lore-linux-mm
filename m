Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 9DF8B6B0044
	for <linux-mm@kvack.org>; Fri,  2 Nov 2012 16:52:05 -0400 (EDT)
Received: by mail-qa0-f41.google.com with SMTP id c26so16430qad.14
        for <linux-mm@kvack.org>; Fri, 02 Nov 2012 13:52:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAA25o9SD8cZUaVT-SA2f9NVvPdmYo++WGn8Gfie3bhkrc8dCxQ@mail.gmail.com>
References: <CAA25o9SD8cZUaVT-SA2f9NVvPdmYo++WGn8Gfie3bhkrc8dCxQ@mail.gmail.com>
Date: Fri, 2 Nov 2012 13:52:04 -0700
Message-ID: <CAA25o9TZMbc+S9wFsesPDYvQES2B6QPPKf-F8ZCk45sEU5vUoQ@mail.gmail.com>
Subject: Re: zram on ARM
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>

Some parts of my previous message are premature---I haven't actually
tried exactly this code on x86, and I should also try David Rientjes's
patch.  But I'd still like to know how this has been tested on ARM.

Thanks!

On Fri, Nov 2, 2012 at 12:59 PM, Luigi Semenzato <semenzato@google.com> wrote:
> Does anybody have any information on the status of zram on ARM?
> Specifically, how much it has been tested.
>
> I noticed that zram and zsmalloc on ToT no longer have the x86
> restriction, and they compile fine on our 3.4 branch.  Sadly, that's
> where my luck ends.
>
> When I run my standard Chrome load (which just opens a bunch of
> memory-intensive browser tabs), Chrome dies shortly after the system
> starts swapping pages out.  For instance, here's are the SI and SO
> fields of "vmstat 1":
>
>    si   so
>     0    0
>     0    0
>     0    0
>     0    0
>     0    0
>     0    0
>     0    0
>     0    0
>     0  168
>     0    0
>     0  924
>   188 26332
>   520 30672
>  1304 32208
>  2360 30804
>  18836 24832
>                      <--- chrome dies here
>  6496    0
>   892    0
>   260    0
>     8    0
>
> I also have a simpler load: a program that allocates memory non-stop,
> and fills part of it with data from /dev/urandom (to simulate the
> observed compressibility). The program never reads its data though, so
> it doesn't get swapped back in, as in the previous load.  This runs
> for a while and partially fills the swap device, then the system
> hangs.
>
> Deja vu, eh?  I am running this with my patch, which may result in
> extra OOM kills.  Interestingly, a few threads are blocked in
> exit_mm(), but not on a page fault.  Most processes are in
> congestion_wait(), so this is probably not the same situation I was
> seeing earlier.
>
> Anyway, I am attaching the output of SysRQ-X with lots of stack
> traces.  Thank you very much for any information!
>
> Luigi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
