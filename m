Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E7BC06B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 21:03:31 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e189so69619450pfa.2
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 18:03:31 -0700 (PDT)
Received: from mail-pf0-x234.google.com (mail-pf0-x234.google.com. [2607:f8b0:400e:c00::234])
        by mx.google.com with ESMTPS id z3si143053pfz.255.2016.07.19.18.03.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jul 2016 18:03:31 -0700 (PDT)
Received: by mail-pf0-x234.google.com with SMTP id h186so12760866pfg.3
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 18:03:31 -0700 (PDT)
Date: Tue, 19 Jul 2016 18:03:23 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v2] more mapcount page as kpage could reduce total
 replacement times than fewer mapcount one in probability.
In-Reply-To: <alpine.LSU.2.11.1606211807330.6589@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1607191746001.5855@eggly.anvils>
References: <1465955818-101898-1-git-send-email-zhouxianrong@huawei.com> <2460b794-92f0-d115-c729-bcfe33663e48@huawei.com> <alpine.LSU.2.11.1606211807330.6589@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong@huawei.com
Cc: akpm@linux-foundation.org, hughd@google.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, zhouchengming1@huawei.com, geliangtang@163.com, zhouxiyu@huawei.com, wanghaijun5@huawei.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 21 Jun 2016, Hugh Dickins wrote:
> On Tue, 21 Jun 2016, zhouxianrong wrote:
> 
> > hey hugh:
> >     could you please give me some suggestion about this ?
> 
> I must ask you to be more patient: everyone would like me to be
> quicker, but I cannot; and this does not appear to be urgent.
> 
> Your idea makes sense to me; but if your patch seems obvious to you,
> sorry, it isn't obvious to me.  The two pages are not symmetrical,
> the caller of try_to_merge_two_pages() thinks it knows which is which,
> swapping them around underneath it like this is not obviously correct.
> 
> Your patch may be fine, but I've not had time to think it through:
> will do, but not immediately.
> 
> Your idea may not make so much sense to Andrea: he has been troubled
> by the difficulty in unmapping a KSM page with a very high mapcount.
> 
> And you would be maximizing a buggy case, if we think of that page
> being mapped also into non-VM_MERGEABLE areas; but I think we can
> ignore that aspect, it's buggy already, and I don't think anyone
> really cares deeply about madvise(,,MADV_UNMERGEABLE) correctness
> on forked areas.  KSM was not originally written with fork in mind.
> 
> I have never seen such a long title for a patch: maybe
> "[PATCH] ksm: choose the more mapped for the KSM page".
> 
> > 
> > On 2016/6/15 9:56, zhouxianrong@huawei.com wrote:
> > > From: z00281421 <z00281421@notesmail.huawei.com>
> > > 
> > > more mapcount page as kpage could reduce total replacement times
> > > than fewer mapcount one when ksmd scan and replace among
> > > forked pages later.
> > > 
> > > Signed-off-by: z00281421 <z00281421@notesmail.huawei.com>
> 
> And I doubt that z00281421 is your real name:
> see Documentation/SubmittingPatches.
> 
> Hugh
> 
> > > ---
> > >  mm/ksm.c |    8 ++++++++
> > >  1 file changed, 8 insertions(+)
> > > 
> > > diff --git a/mm/ksm.c b/mm/ksm.c
> > > index 4786b41..4d530af 100644
> > > --- a/mm/ksm.c
> > > +++ b/mm/ksm.c
> > > @@ -1094,6 +1094,14 @@ static struct page *try_to_merge_two_pages(struct
> > > rmap_item *rmap_item,
> > >  {
> > >  	int err;
> > > 
> > > +	/*
> > > +	 * select more mapcount page as kpage
> > > +	 */
> > > +	if (page_mapcount(page) < page_mapcount(tree_page)) {
> > > +		swap(page, tree_page);
> > > +		swap(rmap_item, tree_rmap_item);
> > > +	}
> > > +

I gave this a try, but commenting out the condition to make it exchange
the pages every time, to make it more likely to generate problems if any.

It very soon gave me lots of "BUG: Bad page" messages: presumably because
of the point I already made, that cmp_and_merge_page() knows which page
is which, but you've done nothing to tell it of the exchange.

So NAK to this patch as it stands.  No doubt easily corrected, but I
think this can only ever be a minor optimization - the very next page
to be merged with these two may turn out to have a much higher mapcount
than either of the first two.

I think it's better to drop this patch for now: as our other mail thread
indicates, there are more important things for us to worry about in KSM,
and their fixes may change around what's required here anyway.

Hugh

> > >  	err = try_to_merge_with_ksm_page(rmap_item, page, NULL);
> > >  	if (!err) {
> > >  		err = try_to_merge_with_ksm_page(tree_rmap_item,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
