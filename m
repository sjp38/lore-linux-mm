Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f54.google.com (mail-qa0-f54.google.com [209.85.216.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9773F6B00FB
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 10:39:30 -0400 (EDT)
Received: by mail-qa0-f54.google.com with SMTP id v10so1775349qac.27
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 07:39:30 -0700 (PDT)
Received: from collaborate-mta1.arm.com (fw-tnat.austin.arm.com. [217.140.110.23])
        by mx.google.com with ESMTP id w8si1298409qaw.115.2014.06.12.07.39.29
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 07:39:29 -0700 (PDT)
Date: Thu, 12 Jun 2014 15:39:16 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: kmemleak: Unable to handle kernel paging request
Message-ID: <20140612143916.GB8970@arm.com>
References: <CAOJe8K3fy3XFxDdVc3y1hiMAqUCPmkUhECU7j5TT=E=gxwBqHg@mail.gmail.com>
 <20140611173851.GA5556@MacBook-Pro.local>
 <CAOJe8K1TgTDX5=LdE9r6c0ami7TRa7zr0hL_uu6YpiWrsePAgQ@mail.gmail.com>
 <B01EB0A1-992B-49F4-93AE-71E4BA707795@arm.com>
 <CAOJe8K3LDhhPWbtdaWt23mY+2vnw5p05+eyk2D8fovOxC10cgA@mail.gmail.com>
 <CAOJe8K2WaJUP9_buwgKw89fxGe56mGP1Mn8rDUO9W48KZzmybA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAOJe8K2WaJUP9_buwgKw89fxGe56mGP1Mn8rDUO9W48KZzmybA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Denis Kirjanov <kda@linux-powerpc.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Thu, Jun 12, 2014 at 01:00:57PM +0100, Denis Kirjanov wrote:
> On 6/12/14, Denis Kirjanov <kda@linux-powerpc.org> wrote:
> > On 6/12/14, Catalin Marinas <catalin.marinas@arm.com> wrote:
> >> On 11 Jun 2014, at 21:04, Denis Kirjanov <kda@linux-powerpc.org> wrote:
> >>> On 6/11/14, Catalin Marinas <catalin.marinas@arm.com> wrote:
> >>>> On Wed, Jun 11, 2014 at 04:13:07PM +0400, Denis Kirjanov wrote:
> >>>>> I got a trace while running 3.15.0-08556-gdfb9454:
> >>>>>
> >>>>> [  104.534026] Unable to handle kernel paging request for data at
> >>>>> address 0xc00000007f000000
> >>>>
> >>>> Were there any kmemleak messages prior to this, like "kmemleak
> >>>> disabled"? There could be a race when kmemleak is disabled because of
> >>>> some fatal (for kmemleak) error while the scanning is taking place
> >>>> (which needs some more thinking to fix properly).
> >>>
> >>> No. I checked for the similar problem and didn't find anything relevant.
> >>> I'll try to bisect it.
> >>
> >> Does this happen soon after boot? I guess ita??s the first scan
> >> (scheduled at around 1min after boot). Something seems to be telling
> >> kmemleak that there is a valid memory block at 0xc00000007f000000.
> >
> > Yeah, it happens after a while with a booted system so that's the
> > first kmemleak scan.
> >
> 
> I've bisected to this commit: d4c54919ed86302094c0ca7d48a8cbd4ee753e92
> "mm: add !pte_present() check on existing hugetlb_entry callbacks".
> Reverting the commit fixes the issue

I can't figure how this causes the problem but I have more questions. Is
0xc00000007f000000 address always the same in all crashes? If yes, you
could comment out start_scan_thread() in kmemleak_late_init() to avoid
the scanning thread starting. Once booted, you can run:

  echo dump=0xc00000007f000000 > /sys/kernel/debug/kmemleak

and check the dmesg for what kmemleak knows about that address, when it
was allocated and whether it should be mapped or not.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
