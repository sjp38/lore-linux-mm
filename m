Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 164C76B0261
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 13:14:35 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id j90so88077142lfi.3
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 10:14:35 -0800 (PST)
Received: from mail-lf0-x244.google.com (mail-lf0-x244.google.com. [2a00:1450:4010:c07::244])
        by mx.google.com with ESMTPS id p194si9850385lfe.195.2017.01.25.10.14.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 10:14:33 -0800 (PST)
Received: by mail-lf0-x244.google.com with SMTP id x1so21933696lff.0
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 10:14:33 -0800 (PST)
MIME-Version: 1.0
From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Wed, 25 Jan 2017 10:14:12 -0800
Message-ID: <CAADnVQ+iGPFwTwQ03P1Ga2qM1nt14TfA+QO8-npkEYzPD+vpdw@mail.gmail.com>
Subject: Re: [PATCH 0/6 v3] kvmalloc
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>

On Wed, Jan 25, 2017 at 5:21 AM, Michal Hocko <mhocko@kernel.org> wrote:
> On Wed 25-01-17 14:10:06, Michal Hocko wrote:
>> On Tue 24-01-17 11:17:21, Alexei Starovoitov wrote:
>> > On Tue, Jan 24, 2017 at 04:17:52PM +0100, Michal Hocko wrote:
>> > > On Thu 12-01-17 16:37:11, Michal Hocko wrote:
>> > > > Hi,
>> > > > this has been previously posted as a single patch [1] but later on more
>> > > > built on top. It turned out that there are users who would like to have
>> > > > __GFP_REPEAT semantic. This is currently implemented for costly >64B
>> > > > requests. Doing the same for smaller requests would require to redefine
>> > > > __GFP_REPEAT semantic in the page allocator which is out of scope of
>> > > > this series.
>> > > >
>> > > > There are many open coded kmalloc with vmalloc fallback instances in
>> > > > the tree.  Most of them are not careful enough or simply do not care
>> > > > about the underlying semantic of the kmalloc/page allocator which means
>> > > > that a) some vmalloc fallbacks are basically unreachable because the
>> > > > kmalloc part will keep retrying until it succeeds b) the page allocator
>> > > > can invoke a really disruptive steps like the OOM killer to move forward
>> > > > which doesn't sound appropriate when we consider that the vmalloc
>> > > > fallback is available.
>> > > >
>> > > > As it can be seen implementing kvmalloc requires quite an intimate
>> > > > knowledge if the page allocator and the memory reclaim internals which
>> > > > strongly suggests that a helper should be implemented in the memory
>> > > > subsystem proper.
>> > > >
>> > > > Most callers I could find have been converted to use the helper instead.
>> > > > This is patch 5. There are some more relying on __GFP_REPEAT in the
>> > > > networking stack which I have converted as well but considering we do
>> > > > not have a support for __GFP_REPEAT for requests smaller than 64kB I
>> > > > have marked it RFC.
>> > >
>> > > Are there any more comments? I would really appreciate to hear from
>> > > networking folks before I resubmit the series.
>> >
>> > while this patchset was baking the bpf side switched to use bpf_map_area_alloc()
>> > which fixes the issue with missing __GFP_NORETRY that we had to fix quickly.
>> > See commit d407bd25a204 ("bpf: don't trigger OOM killer under pressure with map alloc")
>> > it covers all kmalloc/vmalloc pairs instead of just one place as in this set.
>> > So please rebase and switch bpf_map_area_alloc() to use kvmalloc().
>>
>> OK, will do. Thanks for the heads up.
>
> Just for the record, I will fold the following into the patch 1
> ---
> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> index 19b6129eab23..8697f43cf93c 100644
> --- a/kernel/bpf/syscall.c
> +++ b/kernel/bpf/syscall.c
> @@ -53,21 +53,7 @@ void bpf_register_map_type(struct bpf_map_type_list *tl)
>
>  void *bpf_map_area_alloc(size_t size)
>  {
> -       /* We definitely need __GFP_NORETRY, so OOM killer doesn't
> -        * trigger under memory pressure as we really just want to
> -        * fail instead.
> -        */
> -       const gfp_t flags = __GFP_NOWARN | __GFP_NORETRY | __GFP_ZERO;
> -       void *area;
> -
> -       if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER)) {
> -               area = kmalloc(size, GFP_USER | flags);
> -               if (area != NULL)
> -                       return area;
> -       }
> -
> -       return __vmalloc(size, GFP_KERNEL | __GFP_HIGHMEM | flags,
> -                        PAGE_KERNEL);
> +       return kvzalloc(size, GFP_USER);
>  }
>
>  void bpf_map_area_free(void *area)

Looks fine by me.
Daniel, thoughts?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
