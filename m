Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8CEC0C4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 03:13:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 107FF21738
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 03:13:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="NHq0rRgS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 107FF21738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8461D6B000E; Thu,  4 Apr 2019 23:13:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7F4BE6B0266; Thu,  4 Apr 2019 23:13:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 70B286B0269; Thu,  4 Apr 2019 23:13:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 21FB16B000E
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 23:13:45 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id k8so2464356edl.22
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 20:13:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=7JRLk73o3zdzwIeyVvfIEIgIijd2IU7f5ObPNEVJ4Uk=;
        b=EEsJgME1LwVe83bkFr0vEpvDnvYIO10K1ebE8+lvgev3viFuSJbV25p6uZ6WSrUZ9N
         gM7IIrdRJ7buC4GLtYDd5CqPoUfuLEM7X4pLc3Eive7tktLI+O6JCChDCSl6+XkbeU7o
         +/UOo9b5qRcRiPqeywdpb/1791CEqM29EDODAIYbSTCfHZ1N56Bry58g7W+eF6MprWyk
         52wuHXOvNJ/Rma1+hJQIbWPLagjqNNsywgErXx3s/Ct9VLk1Y5GyxkAIDLJyqRsckEO4
         +tZZdwHVOFbc9m6TTNoNZBe3y6lxuqsmi8T5Kkt9js2rK8pMms/zeaR80hGt39M5cffQ
         5ezA==
X-Gm-Message-State: APjAAAUXTZ/mF5tUHpGZpaQJ6ybLCfjCNdoPONEQkIzf8KnyHKZ4fSIn
	3k3LXKV6gndFyVaUxTL9loWHxx+z8jqGU5bG2YiCRM2JEt5qhwcYoYjVtUn2oVOhk6J1OqiHc1g
	GYUOeMNyZeaYcy5Vtc1LgtPBZcjzciE/CLERq46jYfVpesFxb/jUIAZdVQ884SuQk2w==
X-Received: by 2002:a50:ec0e:: with SMTP id g14mr6272309edr.29.1554434024563;
        Thu, 04 Apr 2019 20:13:44 -0700 (PDT)
X-Received: by 2002:a50:ec0e:: with SMTP id g14mr6272263edr.29.1554434023570;
        Thu, 04 Apr 2019 20:13:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554434023; cv=none;
        d=google.com; s=arc-20160816;
        b=rNNAd0UjoiP/XN5TIU1WvRxTydwJeQZTEr5Tac3KSOvoZwOKs9Om1BPcSy3QyH3lqS
         70lGrsxghzUJeU/wROloMpZYyIh+B0hGFkizRi8LSLC4aH8KQcv+FSjxJHCwssrRvzku
         PMJZQi5Dm5ZvkqNj0urVfw24MUba/1sU9BsSrJlKjGYSpGwNw1ShZAATl7QL22R5YfnP
         1uwfDIiK5AMu8Pf4tEJ6F5wmya5P/welzACIhyVHF6oxw98078X+L1aTNbxpZlUVgTX/
         /oxbfvPbyhSrpLbUp6R9pjBJqJUNrcqPs287Jd4jL8J9qReeuSh6lcJAyoWXUEsEO7le
         ZikQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=7JRLk73o3zdzwIeyVvfIEIgIijd2IU7f5ObPNEVJ4Uk=;
        b=kazWi40TSiM28KaUZpQixfMww8Z8NOUNpI0+qP9rvWMfC4SI7MAApGZSejkBolHtDh
         zqD7L3+FIZO/n01JgS1Tf0MmlB06MuuZFfyXo93YLWhusYcQYuZUyLBVBzZf4ZxycfqV
         5Z2WTGu2K23snNJgdVRtxbqq4e+IHs8nLbihDMhoicGB2suAf5WabFb9Mc71RcAQlAZH
         5DmNWpVwLV2V7/EBVvAWTRgOf6kqtc5GOH77FRL3MKTlEc2FRWCHwt4BFkH2KsmU/Hty
         4MujPiyQlfS2ayUWCM0QVblFsyCp8qqjJWEWZ/2kwEOQZiZAdEX2L77NFj5gFnSyDcJI
         6CQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NHq0rRgS;
       spf=pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=huangzhaoyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z59sor4247265ede.21.2019.04.04.20.13.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Apr 2019 20:13:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=NHq0rRgS;
       spf=pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=huangzhaoyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=7JRLk73o3zdzwIeyVvfIEIgIijd2IU7f5ObPNEVJ4Uk=;
        b=NHq0rRgSwNnu1x+JHk6N4YcwfOsV9hZcvVMfE6qV6BO/wk2mRcrUEcj3WC6cu01eI4
         oWRDgbhtBxNfIJ2BlcLt0Flx6F8jtIB3Rgf9ar6EkRFSBYOH+pxIEk33S115qOFCAOOx
         IY0XSba1SPLI/uN2ODIGAetRyopTQkbTmJyAbFKeOBzuFLAn+vGq4zapF5jyiyzBejW7
         8rt590KbLxtrdzL+64nJg+b/nsGzfGxM3GoZ5CmdCLWneBE3HqJfFLMhHcuPx1zMjGI0
         OGkvNxSuGwu/vt4b2HqvPzAA549s5Qm2JbLhBjGuPICiJxEp6p1H9+SgQpzKfU3g7LeT
         aWGA==
X-Google-Smtp-Source: APXvYqyTWIC9LSPcGZ2dtyNFPvC0AesUA/LfXkH+3MdpjY9Q+HK47P7R6SwRIa2cE7UiTUnFrbc9PG2/m3r9zBwZkew=
X-Received: by 2002:aa7:d0d3:: with SMTP id u19mr6276058edo.234.1554434023184;
 Thu, 04 Apr 2019 20:13:43 -0700 (PDT)
MIME-Version: 1.0
References: <1554348617-12897-1-git-send-email-huangzhaoyang@gmail.com> <20190404071512.GE12864@dhcp22.suse.cz>
In-Reply-To: <20190404071512.GE12864@dhcp22.suse.cz>
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
Date: Fri, 5 Apr 2019 11:13:32 +0800
Message-ID: <CAGWkznF-LV2BBjcSCmyJzqmYUUvxfNiLbtN5V8xwt3+=uHgqnQ@mail.gmail.com>
Subject: Re: [PATCH] mm:workingset use real time to judge activity of the file page
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, 
	Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, 
	Zhaoyang Huang <zhaoyang.huang@unisoc.com>, Roman Gushchin <guro@fb.com>, 
	Jeff Layton <jlayton@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, 
	"open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	Pavel Tatashin <pasha.tatashin@soleen.com>, Johannes Weiner <hannes@cmpxchg.org>, geng.ren@unisoc.com
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

resend it via the right mailling list and rewrite the comments by ZY.

On Thu, Apr 4, 2019 at 3:15 PM Michal Hocko <mhocko@kernel.org> wrote:
>
> [Fixup email for Pavel and add Johannes]
>
> On Thu 04-04-19 11:30:17, Zhaoyang Huang wrote:
> > From: Zhaoyang Huang <zhaoyang.huang@unisoc.com>
> >
> > In previous implementation, the number of refault pages is used
> > for judging the refault period of each page, which is not precised as
> > eviction of other files will be affect a lot on current cache.
> > We introduce the timestamp into the workingset's entry and refault ratio
> > to measure the file page's activity. It helps to decrease the affection
> > of other files(average refault ratio can reflect the view of whole system
> > 's memory).
> > The patch is tested on an Android system, which can be described as
> > comparing the launch time of an application between a huge memory
> > consumption. The result is launch time decrease 50% and the page fault
> > during the test decrease 80%.
> >
I don't understand what exactly you're saying here, can you please elaborate?

The reason it's using distances instead of absolute time is because
the ordering of the LRU is relative and not based on absolute time.

E.g. if a page is accessed every 500ms, it depends on all other pages
to determine whether this page is at the head or the tail of the LRU.

So when you refault, in order to determine the relative position of
the refaulted page in the LRU, you have to compare it to how fast that
LRU is moving. The absolute refault time, or the average time between
refaults, is not comparable to what's already in memory.

comment by ZY
For current implementation, it is hard to deal with the evaluation of
refault period under the scenario of huge dropping of file pages
within short time, which maybe caused by a high order allocation or
continues single page allocation in KSWAPD. On the contrary, such page
which having a big refault_distance will be deemed as INACTIVE
wrongly, which will be reclaimed earlier than it should be and lead to
page thrashing. So we introduce 'avg_refault_time' & 'refault_ratio'
to judge if the refault is a accumulated thing or caused by a tight
reclaiming. That is to say, a big refault_distance in a long time
would also be inactive as the result of comparing it with ideal
time(avg_refault_time: avg_refault_time = delta_lru_reclaimed_pages/
avg_refault_retio (refault_ratio = lru->inactive_ages / time).
> > Signed-off-by: Zhaoyang Huang <huangzhaoyang@gmail.com>
> > ---
> >  include/linux/mmzone.h |  2 ++
> >  mm/workingset.c        | 24 +++++++++++++++++-------
> >  2 files changed, 19 insertions(+), 7 deletions(-)
> >
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index 32699b2..c38ba0a 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -240,6 +240,8 @@ struct lruvec {
> >       atomic_long_t                   inactive_age;
> >       /* Refaults at the time of last reclaim cycle */
> >       unsigned long                   refaults;
> > +     atomic_long_t                   refaults_ratio;
> > +     atomic_long_t                   prev_fault;
> >  #ifdef CONFIG_MEMCG
> >       struct pglist_data *pgdat;
> >  #endif
> > diff --git a/mm/workingset.c b/mm/workingset.c
> > index 40ee02c..6361853 100644
> > --- a/mm/workingset.c
> > +++ b/mm/workingset.c
> > @@ -159,7 +159,7 @@
> >                        NODES_SHIFT +  \
> >                        MEM_CGROUP_ID_SHIFT)
> >  #define EVICTION_MASK        (~0UL >> EVICTION_SHIFT)
> > -
> > +#define EVICTION_JIFFIES (BITS_PER_LONG >> 3)
> >  /*
> >   * Eviction timestamps need to be able to cover the full range of
> >   * actionable refaults. However, bits are tight in the radix tree
> > @@ -175,18 +175,22 @@ static void *pack_shadow(int memcgid, pg_data_t *pgdat, unsigned long eviction)
> >       eviction >>= bucket_order;
> >       eviction = (eviction << MEM_CGROUP_ID_SHIFT) | memcgid;
> >       eviction = (eviction << NODES_SHIFT) | pgdat->node_id;
> > +     eviction = (eviction << EVICTION_JIFFIES) | (jiffies >> EVICTION_JIFFIES);
> >       eviction = (eviction << RADIX_TREE_EXCEPTIONAL_SHIFT);
> >
> >       return (void *)(eviction | RADIX_TREE_EXCEPTIONAL_ENTRY);
> >  }
> >
> >  static void unpack_shadow(void *shadow, int *memcgidp, pg_data_t **pgdat,
> > -                       unsigned long *evictionp)
> > +                       unsigned long *evictionp, unsigned long *prev_jiffp)
> >  {
> >       unsigned long entry = (unsigned long)shadow;
> >       int memcgid, nid;
> > +     unsigned long prev_jiff;
> >
> >       entry >>= RADIX_TREE_EXCEPTIONAL_SHIFT;
> > +     entry >>= EVICTION_JIFFIES;
> > +     prev_jiff = (entry & ((1UL << EVICTION_JIFFIES) - 1)) << EVICTION_JIFFIES;
> >       nid = entry & ((1UL << NODES_SHIFT) - 1);
> >       entry >>= NODES_SHIFT;
> >       memcgid = entry & ((1UL << MEM_CGROUP_ID_SHIFT) - 1);
> > @@ -195,6 +199,7 @@ static void unpack_shadow(void *shadow, int *memcgidp, pg_data_t **pgdat,
> >       *memcgidp = memcgid;
> >       *pgdat = NODE_DATA(nid);
> >       *evictionp = entry << bucket_order;
> > +     *prev_jiffp = prev_jiff;
> >  }
> >
> >  /**
> > @@ -242,8 +247,12 @@ bool workingset_refault(void *shadow)
> >       unsigned long refault;
> >       struct pglist_data *pgdat;
> >       int memcgid;
> > +     unsigned long refault_ratio;
> > +     unsigned long prev_jiff;
> > +     unsigned long avg_refault_time;
> > +     unsigned long refault_time;
> >
> > -     unpack_shadow(shadow, &memcgid, &pgdat, &eviction);
> > +     unpack_shadow(shadow, &memcgid, &pgdat, &eviction, &prev_jiff);
> >
> >       rcu_read_lock();
> >       /*
> > @@ -288,10 +297,11 @@ bool workingset_refault(void *shadow)
> >        * list is not a problem.
> >        */
> >       refault_distance = (refault - eviction) & EVICTION_MASK;
> > -
> >       inc_lruvec_state(lruvec, WORKINGSET_REFAULT);
> > -
> > -     if (refault_distance <= active_file) {
> > +     lruvec->refaults_ratio = atomic_long_read(&lruvec->inactive_age) / jiffies;
> > +     refault_time = jiffies - prev_jiff;
> > +     avg_refault_time = refault_distance / lruvec->refaults_ratio;
> > +     if (refault_time <= avg_refault_time) {
> >               inc_lruvec_state(lruvec, WORKINGSET_ACTIVATE);
> >               rcu_read_unlock();
> >               return true;
> > @@ -521,7 +531,7 @@ static int __init workingset_init(void)
> >        * some more pages at runtime, so keep working with up to
> >        * double the initial memory by using totalram_pages as-is.
> >        */
> > -     timestamp_bits = BITS_PER_LONG - EVICTION_SHIFT;
> > +     timestamp_bits = BITS_PER_LONG - EVICTION_SHIFT - EVICTION_JIFFIES;
> >       max_order = fls_long(totalram_pages - 1);
> >       if (max_order > timestamp_bits)
> >               bucket_order = max_order - timestamp_bits;
> > --
> > 1.9.1
>
> --
> Michal Hocko
> SUSE Labs

