Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 154456B0062
	for <linux-mm@kvack.org>; Thu,  7 Jan 2010 09:15:45 -0500 (EST)
Received: by ey-out-1920.google.com with SMTP id 4so4187725eyg.18
        for <linux-mm@kvack.org>; Thu, 07 Jan 2010 06:15:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100107135831.GA29564@csn.ul.ie>
References: <87a5b0801001070434m7f6b0fd6vfcdf49ab73a06cbb@mail.gmail.com>
	 <20100107135831.GA29564@csn.ul.ie>
Date: Thu, 7 Jan 2010 14:15:42 +0000
Message-ID: <87a5b0801001070615p42268d77k66d472eff7a0e9fa@mail.gmail.com>
Subject: Re: Commit f50de2d38 seems to be breaking my oom killer
From: Will Newton <will.newton@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 7, 2010 at 1:58 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> On Thu, Jan 07, 2010 at 12:34:54PM +0000, Will Newton wrote:
>> Hi,
>>
>> I'm having some problems on a small embedded box with 24Mb of RAM and
>> no swap. If a process tries to use large amounts of memory and gets
>> OOM killed, with 2.6.32 it's fine, but with 2.6.33-rc2 kswapd gets
>> stuck and the system locks up.
>
> By stuck, do you mean it consumes 100% CPU and never goes to sleep?

I assume so. The system sems locked up so ctrl-c of the process
doesn't work and I can't get in via telnet. Looking where the pc and
return pointer are going via JTAG leads me to believe it's stuck in
kswapd.

>> The problem appears to have been
>> introduced with f50de2d38. If I change sleeping_prematurely to skip
>> the for_each_populated_zone test then OOM killing operates as
>> expected. I'm guessing it's caused by the new code not allowing kswapd
>> to schedule when it is required to let the killed task exit. Does that
>> sound plausible?
>>
>
> It's conceivable. The expectation was that the cond_resched() in
> balance_pgdat() should have been called at
>
> =A0 =A0 =A0 =A0if (!all_zones_ok) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0cond_resched();
>
> But it would appear that if all zones are unreclaimable, all_zones_ok =3D=
=3D 1.
> It could be looping there indefinitly never calling schedule because it
> never reaches the points where cond_resched is called.
>
>> I'll try and investigate further into what's going on.
>>
>
> Can you try the following?
>
> =3D=3D=3D=3D CUT HERE =3D=3D=3D=3D
> vmscan: kswapd should notice that all zones are not ok if they are unrecl=
aimble
>
> In the event all zones are unreclaimble, it is possible for kswapd to
> never go to sleep because "all zones are ok even though watermarks are
> not reached". It gets into a situation where cond_reched() is not
> called.
>
> This patch notes that if all zones are unreclaimable then the zones are
> not ok and cond_resched() should be called.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

This fixes the problem, thanks for the quick response!

Tested-by: Will Newton <will.newton@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
