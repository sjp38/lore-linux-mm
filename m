Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id E38508E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 21:41:56 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id o205so156203itc.2
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 18:41:56 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m200sor208822itb.0.2019.01.10.18.41.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 18:41:55 -0800 (PST)
MIME-Version: 1.0
References: <1546848299-23628-1-git-send-email-kernelfans@gmail.com>
 <20190108080538.GB4396@rapoport-lnx> <20190108090138.GB18718@MiWiFi-R3L-srv>
 <20190108154852.GC14063@rapoport-lnx> <20190109142516.GA14211@MiWiFi-R3L-srv>
In-Reply-To: <20190109142516.GA14211@MiWiFi-R3L-srv>
From: Pingfan Liu <kernelfans@gmail.com>
Date: Fri, 11 Jan 2019 10:41:44 +0800
Message-ID: <CAFgQCTt6YjoqfvZhEFNAvg-0_r_V5apowNAcg4SSLx1QOMSSWA@mail.gmail.com>
Subject: Re: [PATCHv5] x86/kdump: bugfix, make the behavior of crashkernel=X
 consistent with kaslr
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Baoquan He <bhe@redhat.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>, linux-mm@kvack.org, kexec@lists.infradead.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <lenb@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Michal Hocko <mhocko@suse.com>, Jonathan Corbet <corbet@lwn.net>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Nicholas Piggin <npiggin@gmail.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Daniel Vacek <neelx@redhat.com>, Mathieu Malaterre <malat@debian.org>, Stefan Agner <stefan@agner.ch>, Dave Young <dyoung@redhat.com>, yinghai@kernel.org, vgoyal@redhat.com, linux-kernel@vger.kernel.org

On Wed, Jan 9, 2019 at 10:25 PM Baoquan He <bhe@redhat.com> wrote:
>
> On 01/08/19 at 05:48pm, Mike Rapoport wrote:
> > On Tue, Jan 08, 2019 at 05:01:38PM +0800, Baoquan He wrote:
> > > Hi Mike,
> > >
> > > On 01/08/19 at 10:05am, Mike Rapoport wrote:
> > > > I'm not thrilled by duplicating this code (yet again).
> > > > I liked the v3 of this patch [1] more, assuming we allow bottom-up mode to
> > > > allocate [0, kernel_start) unconditionally.
> > > > I'd just replace you first patch in v3 [2] with something like:
> > >
> > > In initmem_init(), we will restore the top-down allocation style anyway.
> > > While reserve_crashkernel() is called after initmem_init(), it's not
> > > appropriate to adjust memblock_find_in_range_node(), and we really want
> > > to find region bottom up for crashkernel reservation, no matter where
> > > kernel is loaded, better call __memblock_find_range_bottom_up().
> > >
> > > Create a wrapper to do the necessary handling, then call
> > > __memblock_find_range_bottom_up() directly, looks better.
> >
> > What bothers me is 'the necessary handling' which is already done in
> > several places in memblock in a similar, but yet slightly different way.
>
> The page aligning for start and the mirror flag setting, I suppose.
> >
> > memblock_find_in_range() and memblock_phys_alloc_nid() retry with different
> > MEMBLOCK_MIRROR, but memblock_phys_alloc_try_nid() does that only when
> > allocating from the specified node and does not retry when it falls back to
> > any node. And memblock_alloc_internal() has yet another set of fallbacks.
>
> Get what you mean, seems they are trying to allocate within mirrorred
> memory region, if fail, try the non-mirrorred region. If kernel data
> allocation failed, no need to care about if it's movable or not, it need
> to live firstly. For the bottom-up allocation wrapper, maybe we need do
> like this too?
>
> >
> > So what should be the necessary handling in the wrapper for
> > __memblock_find_range_bottom_up() ?
> >
> > BTW, even without any memblock modifications, retrying allocation in
> > reserve_crashkerenel() for different ranges, like the proposal at [1] would
> > also work, wouldn't it?
>
> Yes, it also looks good. This patch only calls once, seems a simpler
> line adding.
>
> In fact, below one and this patch, both is fine to me, as long as it
> fixes the problem customers are complaining about.
>
It seems that there is divergence on opinion. Maybe it is easier to
fix this bug by dyoung's patch. I will repost his patch.

Thanks and regards,
Pingfan
> >
> > [1] http://lists.infradead.org/pipermail/kexec/2017-October/019571.html
>
> Thanks
> Baoquan
