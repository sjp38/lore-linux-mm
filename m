From: James A. Sutherland <jas88@cam.ac.uk>
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
Date: Sun, 22 Apr 2001 11:08:21 +0100
Message-ID: <54b5et09brren07ta6kme3l28th29pven4@4ax.com>
References: <mibudt848g9vrhaac88qjdpnaut4hajooa@4ax.com> <Pine.LNX.4.30.0104201203280.20939-100000@fs131-224.f-secure.com> <sb72ets3sek2ncsjg08sk5tmj7v9hmt4p7@4ax.com> <3AE1DCA8.A6EF6802@earthlink.net> <l0313030fb70791aa88ae@[192.168.239.105]>
In-Reply-To: <l0313030fb70791aa88ae@[192.168.239.105]>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: "Joseph A. Knapka" <jknapka@earthlink.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 21 Apr 2001 20:41:40 +0100, you wrote:

>>> Note that process suspension already happens, but with too fine a
>>> granularity (the scheduler) - that's what causes the problem. If one
>>> process were able to run uninterrupted for, say, a second, it would
>>> get useful work done, then you could switch to another. The current
>>> scheduling doesn't give enough time for that under thrashing
>>> conditions.
>>
>>This suggests that a very simple approach might be to just increase
>>the scheduling granularity as the machine begins to thrash. IOW,
>>use the existing scheduler as the "suspension scheduler".
>
>That might possibly work for some loads, mostly where there are some
>processes which are already swapped-in (and have sensible working sets)
>alongside the "thrashing" processes.  That would at least give the
>well-behaved processes some chance to keep their "active" bits up to date.

The trouble is, thrashing isn't really a process level issue: yes,
there are a group of processes causing it, but you don't have
"thrashing processes" and "non-thrashing processes". Like a car with
one wheel stuck in a pool of mud without a diff-lock: yes, you have
one or two point(s) where all your engine power is going, and the
other wheels are just spinning, but as a result the whole car is going
nowhere! In both cases, the answer is to "starve" the spinning
wheel(s) of power, allowing the others to pull you out...

>However, it doesn't help at all for the cases where some paging-in has to
>be done for a well-behaved but only-just-accessed process.  

Yes it does: we've suspended the runaway process (Netscape, Acrobat
Reader, whatever), leaving enough RAM free for login to be paged in.

>Example of a
>critically important process under this category: LOGIN.  :)  IMHO, the
>only way to sensibly cater for this case (and a few others) is to update
>the page-replacement algorithm.

Updating the page replacement algorithm will help, but our core
problem remains: we don't have enough pages for the currently active
processes! Either we starve SOME processes, or we starve all of
them...


James.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
