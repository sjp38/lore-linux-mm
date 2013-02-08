Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id B07C86B0002
	for <linux-mm@kvack.org>; Fri,  8 Feb 2013 16:55:06 -0500 (EST)
Message-ID: <5115743D.3090903@sgi.com>
Date: Fri, 8 Feb 2013 15:55:09 -0600
From: Nathan Zimmer <nzimmer@sgi.com>
MIME-Version: 1.0
Subject: Re: Improving lock pages
References: <20130115173814.GA13329@gulag1.americas.sgi.com> <20130206163129.GR21389@suse.de>
In-Reply-To: <20130206163129.GR21389@suse.de>
Content-Type: text/plain; charset="ISO-8859-15"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: holt@sgi.com, linux-mm@kvack.org

On 02/06/2013 10:31 AM, Mel Gorman wrote:
> On Tue, Jan 15, 2013 at 11:38:14AM -0600, Nathan Zimmer wrote:
>> Hello Mel,
> Hi Nathan,
>
>>      You helped some time ago with contention in lock_pages on very large boxes.
> It was Nick Piggin and Jack Steiner that helped the situation within SLES
> and before my time. I inherited the relevant patches but made relatively
> few contributions to the effort.
>
>> You worked with Jack Steiner on this.  Currently I am tasked with improving this
>> area even more.  So I am fishing for any more ideas that would be productive or
>> worth trying.
>>
>> I have some numbers from a 512 machine.
>>
>> Linux uvpsw1 3.0.51-0.7.9-default #1 SMP Thu Nov 29 22:12:17 UTC 2012 (f3be9d0) x86_64 x86_64 x86_64 GNU/Linux
>>        0.166850
>>        0.082339
>>        0.248428
>>        0.081197
>>        0.127635
> Ok, this looks like a SLES 11 SP2 kernel and so includes some unlock/lock
> page optimisations.
>
>> Linux uvpsw1 3.8.0-rc1-medusa_ntz_clean-dirty #32 SMP Tue Jan 8 16:01:04 CST 2013 x86_64 x86_64 x86_64 GNU/Linux
>>        0.151778
>>        0.118343
>>        0.135750
>>        0.437019
>>        0.120536
>>
> And this is a mainline-ish kernel which doesn't.
>
> The main reason I never made an strong effort to push them upstream
> because the problems are barely observable on any machine I had access to.
> The unlock page optimisation requires a page flag and while it helps
> profiles a little, the effects are barely observable on smaller machines
> (at least since I last checked).  One machine it was reported to help
> dramatically was a 768-way 128 node machine.
>
> Forthe 512-way machine you're testing with the figures are marginal. The
> time to exit is shorter but the amount of time is tiny and very close to
> noise. I forward ported the relevant patches but on a 48-way machine the
> results for the same test were well within the noise and the standard
> deviation was higher.
One thing I had noticed the performance curve on this issue is worse 
then linear.
This has made it tough to measure/capture data on smaller boxes.

> I know you're tasked with improving this area more but what are you
> using as your example workload? What's the minimum sized machine needed
> for the optimisations to make a difference?
>
Right now I am just using the time_exit test I posted earlier.
I know it is a bit artificial and am open to suggestion.

One of the rough goals is to get under a second on a 4096 box.

Also here are some numbers from a larger box with 3.8-rc4...
nzimmer@uv48-sys:~/tests/time_exit> for I in $(seq 1 5); { ./time_exit 
-p 3 2048; }
       0.762282
       0.810356
       0.777785
       0.840679
       0.743509

nzimmer@uv48-sys:~/tests/time_exit> for I in $(seq 1 5); { ./time_exit 
-p 3 4096; }
       2.550571
       2.374378
       2.669021
       2.703232
       2.679028

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
