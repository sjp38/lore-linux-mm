Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id F22CA6B004F
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 13:30:27 -0400 (EDT)
Received: by yw-out-1718.google.com with SMTP id 5so1832719ywm.26
        for <linux-mm@kvack.org>; Mon, 08 Jun 2009 10:30:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.1.10.0906081126260.5754@gentwo.org>
References: <20090608091044.880249722@intel.com>
	 <20090608091201.953724007@intel.com>
	 <alpine.DEB.1.10.0906081126260.5754@gentwo.org>
Date: Tue, 9 Jun 2009 01:30:51 +0800
Message-ID: <ab418ea90906081030s3dca33a1l91591918abe37588@mail.gmail.com>
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first class
	citizen
From: Nai Xia <nai.xia@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 8, 2009 at 11:34 PM, Christoph
Lameter<cl@linux-foundation.org> wrote:
> On Mon, 8 Jun 2009, Wu Fengguang wrote:
>
>> 1.2) test scenario
>>
>> - nfsroot gnome desktop with 512M physical memory
>> - run some programs, and switch between the existing windows
>> =A0 after starting each new program.
>
> Is there a predefined sequence or does this vary between tests? Scripted?
>
> What percentage of time is saved in the test after due to the
> modifications?
> Around 20%?

I think measuring the percentage of saved time may not be a good idea.
The major underlying  factor for time of swithing GUI windows may vary
application to application, distribution to distribution and machine to
machine. It's not reproducable.
I am having a ridiculous timing for swithing from any window to window
of slickedit, because of its damn slow redrawing method.
I bet this patch will gain at most 1% on timing for this case. :)

>
>> (1) begin: =A0 =A0 shortly after the big read IO starts;
>> (2) end: =A0 =A0 =A0 just before the big read IO stops;
>> (3) restore: =A0 the big read IO stops and the zsh working set restored
>> (4) restore X: after IO, switch back and forth between the urxvt and fir=
efox
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0windows to restore their working set.
>
> Any action done on the firefox sessions? Or just switch to a firefox
> session that needs to redraw?
>
>> The above console numbers show that
>>
>> - The startup pgmajfault of 2.6.30-rc4-mm is merely 1/3 that of 2.6.29.
>> =A0 I'd attribute that improvement to the mmap readahead improvements :-=
)
>
> So there are other effects,,, You not measuring the effect only this
> patchset?
>
>> - The pgmajfault increment during the file copy is 633-630=3D3 vs 260-21=
0=3D50.
>> =A0 That's a huge improvement - which means with the VM_EXEC protection =
logic,
>> =A0 active mmap pages is pretty safe even under partially cache hot stre=
aming IO.
>
> Looks good.
>
>> - The absolute nr_mapped drops considerably to 1/9 during the big IO, an=
d the
>> =A0 dropped pages are mostly inactive ones. The patch has almost no impa=
ct in
>> =A0 this aspect, that means it won't unnecessarily increase memory press=
ure.
>> =A0 (In contrast, your 20% mmap protection ratio will keep them all, and
>> =A0 therefore eliminate the extra 41 major faults to restore working set
>> =A0 of zsh etc.)
>
> Good.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org. =A0For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
