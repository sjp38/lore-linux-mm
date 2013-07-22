Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 3136F6B0032
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 02:13:44 -0400 (EDT)
Date: Mon, 22 Jul 2013 01:13:39 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [RFC 0/4] Transparent on-demand struct page initialization
 embedded in the buddy allocator
Message-ID: <20130722061339.GC3421@sgi.com>
References: <1373594635-131067-1-git-send-email-holt@sgi.com>
 <51E628F8.6030303@gmail.com>
 <20130717093051.GK3421@sgi.com>
 <CAE9FiQUnsENuMGAXgxmJq+u-NnXW4fEXR-JKww8LY_8jOfoeBA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAE9FiQUnsENuMGAXgxmJq+u-NnXW4fEXR-JKww8LY_8jOfoeBA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Robin Holt <holt@sgi.com>, Sam Ben <sam.bennn@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Nate Zimmer <nzimmer@sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Rob Landley <rob@landley.net>, Mike Travis <travis@sgi.com>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Mel Gorman <mgorman@suse.de>

On Fri, Jul 19, 2013 at 04:51:49PM -0700, Yinghai Lu wrote:
> On Wed, Jul 17, 2013 at 2:30 AM, Robin Holt <holt@sgi.com> wrote:
> > On Wed, Jul 17, 2013 at 01:17:44PM +0800, Sam Ben wrote:
> >> >With this patch, we did boot a 16TiB machine.  Without the patches,
> >> >the v3.10 kernel with the same configuration took 407 seconds for
> >> >free_all_bootmem.  With the patches and operating on 2MiB pages instead
> >> >of 1GiB, it took 26 seconds so performance was improved.  I have no feel
> >> >for how the 1GiB chunk size will perform.
> >>
> >> How to test how much time spend on free_all_bootmem?
> >
> > We had put a pr_emerg at the beginning and end of free_all_bootmem and
> > then used a modified version of script which record the time in uSecs
> > at the beginning of each line of output.
> 
> used two patches, found 3TiB system will take 100s before slub is ready.
> 
> about three portions:
> 1. sparse vmemap buf allocation, it is with bootmem wrapper, so clear those
> struct page area take about 30s.
> 2. memmap_init_zone: take about 25s
> 3. mem_init/free_all_bootmem about 30s.
> 
> so still wonder why 16TiB will need hours.

I don't know where you got the figure of hours for memory initialization.
That is likely for a 32TiB boot and includes the entire boot, not just
getting the memory allocator initialized.

For a 16 TiB boot:
1) 344
2) 1151
3) 407

I hope that illustrates why we chose to address the memmap_init_zone first
which had the nice side effect of also impacting the free_all_bootmem
slowdown.

With these patches, those numbers are currently:
1) 344
2) 49
3) 26

> also your patches looks like only address 2 and 3.

Right, but I thought that was the normal way to do things.  Address
one thing at a time and work toward a better kernel.  I don't see a
relationship between the work we are doing here and the sparse vmemmap
buffer allocation.  Have I missed something?

Did you happen to time a boot with these patches applied to see how
long it took and how much impact they had on a smaller config?

Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
