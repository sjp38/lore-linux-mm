Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id 63DD26B0003
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 09:16:12 -0400 (EDT)
Received: by mail-lf1-f69.google.com with SMTP id f4-v6so102814lfa.17
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 06:16:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j14-v6sor428249lfc.69.2018.10.23.06.16.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Oct 2018 06:16:10 -0700 (PDT)
MIME-Version: 1.0
References: <CANiq72kVJn7985EET067Dgj+z0dwb0x2MTUnREMWKCVU6=WnJA@mail.gmail.com>
 <CAFqt6zZ4sPjtb5BaDfwc5tZv+vMj6ao3NJZ_3quX9AH5pCMwJg@mail.gmail.com>
 <CANiq72m9u1PL9X+dPNLxgkhvttj=4ijLyM2sFex=Kws7wswKzw@mail.gmail.com>
 <CAFqt6zYH4Aczu8AYke8AfGuMS70SJXCMn-n8X8C_Tz03gTjn8g@mail.gmail.com>
 <CANiq72kRAZE9SyM4EkpaBZH03Ex0Z=4Pk2iOuc2jBDKTfKjHQg@mail.gmail.com>
 <CAFqt6zZCCPFE3sQ3u_gjiN8wwd99nwWatk9JRsiGxbCwhi91mg@mail.gmail.com>
 <CANiq72k-e_j67==VdrayqggjAd7MAfpaJS-_0=jkmh4OWynukQ@mail.gmail.com>
 <CAFqt6zZ2yHkVcbYtK1dxr9B3K5WVYGboavjP1ibmYei0u4zFbQ@mail.gmail.com>
 <20181023122435.GB20085@bombadil.infradead.org> <CAFqt6zZp=UsSGH148=tPWLnSxC51EGdR0Vv4f5tP58MO-6OS_w@mail.gmail.com>
 <20181023125928.GC20085@bombadil.infradead.org>
In-Reply-To: <20181023125928.GC20085@bombadil.infradead.org>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Tue, 23 Oct 2018 18:45:56 +0530
Message-ID: <CAFqt6zYhXDG8276VfnzrBNM9JZnBsk0YeHP+yMAELB9e+Kt8uA@mail.gmail.com>
Subject: Re: [PATCH v2] mm: Introduce new function vm_insert_kmem_page
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Miguel Ojeda <miguel.ojeda.sandonis@gmail.com>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin@protonic.nl, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie, robin.murphy@arm.com, iamjoonsoo.kim@lge.com, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Kees Cook <keescook@chromium.org>, treding@nvidia.com, Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mark Rutland <mark.rutland@arm.com>, aryabinin@virtuozzo.com, Dmitry Vyukov <dvyukov@google.com>, Kate Stewart <kstewart@linuxfoundation.org>, tchibo@google.com, riel@redhat.com, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Huang, Ying" <ying.huang@intel.com>, ak@linux.intel.com, rppt@linux.vnet.ibm.com, linux@dominikbrodowski.net, Arnd Bergmann <arnd@arndb.de>, cpandya@codeaurora.org, hannes@cmpxchg.org, Joe Perches <joe@perches.com>, mcgrof@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, Linux-MM <linux-mm@kvack.org>

On Tue, Oct 23, 2018 at 6:29 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Tue, Oct 23, 2018 at 06:03:42PM +0530, Souptick Joarder wrote:
> > On Tue, Oct 23, 2018 at 5:54 PM Matthew Wilcox <willy@infradead.org> wrote:
> > > On Tue, Oct 23, 2018 at 05:44:32PM +0530, Souptick Joarder wrote:
> > > > Instruction from Matthew  Wilcox who is supervising the entire vm_fault_t
> > > > migration work :-)
> > >
> > > Hang on.  That was for the initial vm_fault_t conversion in which each
> > > step was clearly an improvement.  What you're looking at now is far
> > > from that.
> >
> > Ok. But my understanding was, the approach of vm_insert_range comes
> > into discussion as part of converting vm_insert_page into vmf_insert_page
> > which is still part of original vm_fault_t conversion discussion.  No ?
>
> No.  The initial part (converting all page fault methods to vm_fault_t)
> is done.  What remains undone (looking at akpm's tree) is changing the
> typedef of vm_fault_t from int to unsigned int.  That will prevent new
> page fault handlers with the wrong type from being added.

Ok, I will post the final typedef of vm_fault_t patch.

>
> I don't necessarily want to get rid of vm_insert_page().  Maybe it will
> make sense to do that, and maybe not.  What I do want to see is thought,
> and not "Matthew told me to do it", when I didn't.

I didn't mean it in other way. Sorry about it.
I will work on it.
