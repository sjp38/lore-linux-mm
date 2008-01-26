From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: Unpredictable performance
Date: Sat, 26 Jan 2008 11:38:30 +1100
References: <4799C8E8.9060501@ifi.uio.no> <4799F2D7.5060504@sannes.org> <4799FA3C.6040700@sannes.org>
In-Reply-To: <4799FA3C.6040700@sannes.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Message-Id: <200801261138.30963.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?iso-8859-1?q?Asbj=F8rn_Sannes?= <ace@sannes.org>, linux-mm@kvack.org
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Saturday 26 January 2008 02:03, Asbjorn Sannes wrote:
> Asbjorn Sannes wrote:
> > Nick Piggin wrote:
> >> On Friday 25 January 2008 22:32, Asbjorn Sannes wrote:
> >>> Hi,
> >>>
> >>> I am experiencing unpredictable results with the following test
> >>> without other processes running (exception is udev, I believe):
> >>> cd /usr/src/test
> >>> tar -jxf ../linux-2.6.22.12
> >>> cp ../working-config linux-2.6.22.12/.config
> >>> cd linux-2.6.22.12
> >>> make oldconfig
> >>> time make -j3 > /dev/null # This is what I note down as a "test" result
> >>> cd /usr/src ; umount /usr/src/test ; mkfs.ext3 /dev/cc/test
> >>> and then reboot
> >>>
> >>> The kernel is booted with the parameter mem=81920000
> >>>
> >>> For 2.6.23.14 the results vary from (real time) 33m30.551s to
> >>> 45m32.703s (30 runs)
> >>> For 2.6.23.14 with nop i/o scheduler from 29m8.827s to 55m36.744s (24
> >>> runs) For 2.6.22.14 also varied a lot.. but, lost results :(
> >>> For 2.6.20.21 only vary from 34m32.054s to 38m1.928s (10 runs)
> >>>
> >>> Any idea of what can cause this? I have tried to make the runs as equal
> >>> as possible, rebooting between each run.. i/o scheduler is cfq as
> >>> default.
> >>>
> >>> sys and user time only varies a couple of seconds.. and the order of
> >>> when it is "fast" and when it is "slow" is completly random, but it
> >>> seems that the results are mostly concentrated around the mean.
> >>
> >> Hmm, lots of things could cause it. With such big variations in
> >> elapsed time, and small variations on CPU time, I guess the fs/IO
> >> layers are the prime suspects, although it could also involve the
> >> VM if you are doing a fair amount of page reclaim.
> >>
> >> Can you boot with enough memory such that it never enters page
> >> reclaim? `grep scan /proc/vmstat` to check.
> >>
> >> Otherwise you could mount the working directory as tmpfs to
> >> eliminate IO.
> >>
> >> bisecting it down to a single patch would be really helpful if you
> >> can spare the time.
> >
> > I'm going to run some tests without limiting the memory to 80 megabytes
> > (so that it is 2 gigabyte) and see how much it varies then, but iff I
> > recall correctly it did not vary much. I'll reply to this e-mail with
> > the results.
>
> 5 runs gives me:
> real    5m58.626s
> real    5m57.280s
> real    5m56.584s
> real    5m57.565s
> real    5m56.613s
>
> Should I test with tmpfs aswell?

I wouldn't worry about it. It seems like it might be due to page reclaim
(fs / IO can't be ruled out completely though). Hmm, I haven't been following
reclaim so closely lately; you say it started going bad around 2.6.22? It
may be lumpy reclaim patches?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
