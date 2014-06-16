Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 7C4676B0031
	for <linux-mm@kvack.org>; Sun, 15 Jun 2014 22:40:12 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id r10so3941115pdi.9
        for <linux-mm@kvack.org>; Sun, 15 Jun 2014 19:40:12 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id gq8si9341532pbc.50.2014.06.15.19.40.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Jun 2014 19:40:09 -0700 (PDT)
Message-ID: <1402886406.25275.1.camel@concordia>
Subject: Re: kmemleak: Unable to handle kernel paging request
From: Michael Ellerman <mpe@ellerman.id.au>
Date: Mon, 16 Jun 2014 12:40:06 +1000
In-Reply-To: <CAOJe8K1VJ5RFWSB9i4PMdYq5X2vEgv0opGwU39ZRhYdfwj-kPw@mail.gmail.com>
References: 
	<CAOJe8K3fy3XFxDdVc3y1hiMAqUCPmkUhECU7j5TT=E=gxwBqHg@mail.gmail.com>
	 <20140611173851.GA5556@MacBook-Pro.local>
	 <CAOJe8K1TgTDX5=LdE9r6c0ami7TRa7zr0hL_uu6YpiWrsePAgQ@mail.gmail.com>
	 <B01EB0A1-992B-49F4-93AE-71E4BA707795@arm.com>
	 <CAOJe8K3LDhhPWbtdaWt23mY+2vnw5p05+eyk2D8fovOxC10cgA@mail.gmail.com>
	 <CAOJe8K2WaJUP9_buwgKw89fxGe56mGP1Mn8rDUO9W48KZzmybA@mail.gmail.com>
	 <20140612143916.GB8970@arm.com>
	 <CAOJe8K3zN+fFWumKaGx3Tmv5JRZu10_FZ6R3Tjjc+nc-KVB0hg@mail.gmail.com>
	 <20140613085640.GA21018@arm.com>
	 <CAOJe8K1VJ5RFWSB9i4PMdYq5X2vEgv0opGwU39ZRhYdfwj-kPw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Denis Kirjanov <kda@linux-powerpc.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Paul Mackerras <paulus@samba.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linuxppc-dev@lists.ozlabs.org

On Fri, 2014-06-13 at 14:26 +0400, Denis Kirjanov wrote:
> On 6/13/14, Catalin Marinas <catalin.marinas@arm.com> wrote:
> > On Fri, Jun 13, 2014 at 08:12:08AM +0100, Denis Kirjanov wrote:
> >> On 6/12/14, Catalin Marinas <catalin.marinas@arm.com> wrote:
> >> > On Thu, Jun 12, 2014 at 01:00:57PM +0100, Denis Kirjanov wrote:
> >> >> On 6/12/14, Denis Kirjanov <kda@linux-powerpc.org> wrote:
> >> >> > On 6/12/14, Catalin Marinas <catalin.marinas@arm.com> wrote:
> >> >> >> On 11 Jun 2014, at 21:04, Denis Kirjanov <kda@linux-powerpc.org>
> >> >> >> wrote:
> >> >> >>> On 6/11/14, Catalin Marinas <catalin.marinas@arm.com> wrote:
> >> >> >>>> On Wed, Jun 11, 2014 at 04:13:07PM +0400, Denis Kirjanov wrote:
> >> >> >>>>> I got a trace while running 3.15.0-08556-gdfb9454:
> >> >> >>>>>
> >> >> >>>>> [  104.534026] Unable to handle kernel paging request for data
> >> >> >>>>> at
> >> >> >>>>> address 0xc00000007f000000
> >> >> >>>>
> >> >> >>>> Were there any kmemleak messages prior to this, like "kmemleak
> >> >> >>>> disabled"? There could be a race when kmemleak is disabled
> >> >> >>>> because
> >> >> >>>> of
> >> >> >>>> some fatal (for kmemleak) error while the scanning is taking
> >> >> >>>> place
> >> >> >>>> (which needs some more thinking to fix properly).
> >> >> >>>
> >> >> >>> No. I checked for the similar problem and didn't find anything
> >> >> >>> relevant.
> >> >> >>> I'll try to bisect it.
> >> >> >>
> >> >> >> Does this happen soon after boot? I guess ita??s the first scan
> >> >> >> (scheduled at around 1min after boot). Something seems to be
> >> >> >> telling
> >> >> >> kmemleak that there is a valid memory block at 0xc00000007f000000.
> >> >> >
> >> >> > Yeah, it happens after a while with a booted system so that's the
> >> >> > first kmemleak scan.
> >> >>
> >> >> I've bisected to this commit: d4c54919ed86302094c0ca7d48a8cbd4ee753e92
> >> >> "mm: add !pte_present() check on existing hugetlb_entry callbacks".
> >> >> Reverting the commit fixes the issue
> >> >
> >> > I can't figure how this causes the problem but I have more questions.
> >> > Is
> >> > 0xc00000007f000000 address always the same in all crashes? If yes, you
> >> > could comment out start_scan_thread() in kmemleak_late_init() to avoid
> >> > the scanning thread starting. Once booted, you can run:
> >> >
> >> >   echo dump=0xc00000007f000000 > /sys/kernel/debug/kmemleak
> >> >
> >> > and check the dmesg for what kmemleak knows about that address, when it
> >> > was allocated and whether it should be mapped or not.
> >>
> >> The address is always the same.
> >>
> >> [  179.466239] kmemleak: Object 0xc00000007f000000 (size 16777216):
> >> [  179.466503] kmemleak:   comm "swapper/0", pid 0, jiffies 4294892300
> >> [  179.466508] kmemleak:   min_count = 0
> >> [  179.466512] kmemleak:   count = 0
> >> [  179.466517] kmemleak:   flags = 0x1
> >> [  179.466522] kmemleak:   checksum = 0
> >> [  179.466526] kmemleak:   backtrace:
> >> [  179.466531]      [<c000000000afc3dc>]
> >> .memblock_alloc_range_nid+0x68/0x88
> >> [  179.466544]      [<c000000000afc444>] .memblock_alloc_base+0x20/0x58
> >> [  179.466553]      [<c000000000ae96cc>] .alloc_dart_table+0x5c/0xb0
> >> [  179.466561]      [<c000000000aea300>] .pmac_probe+0x38/0xa0
> >> [  179.466569]      [<000000000002166c>] 0x2166c
> >> [  179.466579]      [<0000000000ae0e68>] 0xae0e68
> >> [  179.466587]      [<0000000000009bc4>] 0x9bc4
> >
> > OK, so that's the DART table allocated via alloc_dart_table(). Is
> > dart_tablebase removed from the kernel linear mapping after allocation?
> > If that's the case, we need to tell kmemleak to ignore this block (see
> > patch below, untested). But I still can't explain how commit
> > d4c54919ed863020 causes this issue.
> >
> > (also cc'ing the powerpc list and maintainers)
> 
> Ok, your path fixes the oops.
> 
> Ben, can you shed some light on this issue?

(I'm not Ben)

Yes, the memory for dart_tablebase is removed from the linear mapping. In fact
it's never mapped, see htab_initialize().

I don't easily see how commit d4c54919ed8, could have exposed this, but I don't
know enough of the kmemleak internals to say for sure.

cheers


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
