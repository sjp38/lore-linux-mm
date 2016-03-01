Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 53BEE6B0005
	for <linux-mm@kvack.org>; Tue,  1 Mar 2016 10:55:15 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id l6so17513532pfl.3
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 07:55:15 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q66si51200404pfi.84.2016.03.01.07.55.14
        for <linux-mm@kvack.org>;
        Tue, 01 Mar 2016 07:55:14 -0800 (PST)
Date: Tue, 1 Mar 2016 15:55:07 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: tty: memory leak in tty_register_driver
Message-ID: <20160301155504.GB22107@localhost.localdomain>
References: <CACT4Y+bZticikTpnc0djxRBLCWhj=2DqQk=KRf5zDvrLdHzEbQ@mail.gmail.com>
 <CACT4Y+a+L3+VUEV7c2Q6c7tb8A57dpsitM=P6KVSHV=WYrpahw@mail.gmail.com>
 <20160228234657.GA28225@MBP.local>
 <CACT4Y+a-J5_t2xsHn6RGWoHPE-huJ2zJ0S01zR1kJew=c6SUsQ@mail.gmail.com>
 <20160229113448.GC7935@e104818-lin.cambridge.arm.com>
 <CACT4Y+bXyxLZgt5VXPQJPQ-VpO1SmHT0meKqds5tr5JaZ-867g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+bXyxLZgt5VXPQJPQ-VpO1SmHT0meKqds5tr5JaZ-867g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.com>, LKML <linux-kernel@vger.kernel.org>, Peter Hurley <peter@hurleysoftware.com>, One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>, J Freyensee <james_p_freyensee@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Paul Bolle <pebolle@tiscali.nl>, Alexander Potapenko <glider@google.com>, Kostya Serebryany <kcc@google.com>, Sasha Levin <sasha.levin@oracle.com>, syzkaller <syzkaller@googlegroups.com>

On Tue, Mar 01, 2016 at 04:27:28PM +0100, Dmitry Vyukov wrote:
> On Mon, Feb 29, 2016 at 12:34 PM, Catalin Marinas
> <catalin.marinas@arm.com> wrote:
> > On Mon, Feb 29, 2016 at 11:22:58AM +0100, Dmitry Vyukov wrote:
> >> Regarding stopping all threads and doing proper scan, why is not it
> >> feasible? Will kernel break if we stall all CPUs for seconds? In
> >> automatic testing scenarios a stalled for several seconds machine is
> >> not a problem. But on the other hand, absence of false positives is a
> >> must. And it would improve testing bandwidth, because we don't need
> >> sleep and second scan.
> >
> > Scanning time is the main issue with it taking minutes on some slow ARM
> > machines (my primary testing target). Such timing was significantly
> > improved with commit 93ada579b0ee ("mm: kmemleak: optimise kmemleak_lock
> > acquiring during kmemleak_scan") but even if it is few seconds, it is
> > not suitable for a live, interactive system.
> >
> > What we could do though, since you already trigger the scanning
> > manually, is to add a "stopscan" command that you echo into
> > /sys/kernel/debug/kmemleak and performs a stop_machine() during memory
> > scanning. If you have time, please feel free to give it a try ;).
> 
> Stopscan would be useful for me, but I don't feel like I am ready to
> tackle it.

It's not that hard ;). Anyway, when I get a bit of time I'll try to look
into it.

> To be absolutely sure that we don't miss pointers we would also need
> to scan all registers from stopped CPUs, and I don't know how to
> obtain that.

With stop_machine(), we probably wouldn't need to. This mechanism causes
the other CPUs to go take an IPI and execute a certain function (or wait
for the completion of a function call on another CPU). We can assume
that the functions stop_machine() is calling wouldn't manipulate
allocated objects/lists/etc., so the register file content is not
relevant to kmemleak. The previous context interrupted by the IPI would
be stored on the IRQ stack and that's one area the kmemleak does not
scan (it's architecture specific).

On the CPU issuing the stop_machine(), this would be done as a result of
debugfs write and I don't think we have any object
allocation/manipulation on this path (and it's only the callee-saved
registers that we would miss when calling kmemleak's scan_object()).

So yes, in addition to stop_machine(), we would have to scan the IRQ
stack if the architecture uses a separate one (vs just the current
thread stack).

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
