Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1C3BB6B0003
	for <linux-mm@kvack.org>; Wed, 31 Jan 2018 17:58:50 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id n2so2954814wrb.7
        for <linux-mm@kvack.org>; Wed, 31 Jan 2018 14:58:50 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 24si8079490wrx.93.2018.01.31.14.58.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jan 2018 14:58:48 -0800 (PST)
Date: Wed, 31 Jan 2018 14:58:44 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 15/15] mm: add strictlimit knob
Message-Id: <20180131145844.6f3ccb03a73266bebddea80c@linux-foundation.org>
In-Reply-To: <CAJfpeguJyyJ4ix2waeEh9nAC6YoWcxiepBH4iOc1_is3NYChEQ@mail.gmail.com>
References: <5a20831e./7a6H+akjTcq4WCk%akpm@linux-foundation.org>
	<20171201122928.GD8365@quack2.suse.cz>
	<20171206170927.5d40106be6fdc6dc88354b65@linux-foundation.org>
	<20171207041459.64myz37qwmjkoxu5@wfg-t540p.sh.intel.com>
	<CAJfpegsE-jUOWjpMVQv76cDxp3aLpAfxrMa-vutMFa0KhVKrHw@mail.gmail.com>
	<20171207101547.ljfayqfp3lczhfvi@wfg-t540p.sh.intel.com>
	<CAJfpeguJyyJ4ix2waeEh9nAC6YoWcxiepBH4iOc1_is3NYChEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, linux-mm@kvack.org, Maxim Patlasov <MPatlasov@parallels.com>, hmh@hmh.eng.br, mel@csn.ul.ie, t.artem@lycos.com, Theodore Ts'o <tytso@mit.edu>, Jens Axboe <axboe@kernel.dk>, linux-fsdevel@vger.kernel.org

On Thu, 7 Dec 2017 11:32:43 +0100 Miklos Szeredi <miklos@szeredi.hu> wrote:

> On Thu, Dec 7, 2017 at 11:15 AM, Fengguang Wu <fengguang.wu@intel.com> wrote:
> > On Thu, Dec 07, 2017 at 09:50:23AM +0100, Miklos Szeredi wrote:
> >>
> >> On Thu, Dec 7, 2017 at 5:14 AM, Fengguang Wu <fengguang.wu@intel.com>
> >> wrote:
> >>>
> >>> CC fuse maintainer, too.
> >>>
> >>> On Wed, Dec 06, 2017 at 05:09:27PM -0800, Andrew Morton wrote:
> >>>>
> >>>>
> >>>> On Fri, 1 Dec 2017 13:29:28 +0100 Jan Kara <jack@suse.cz> wrote:
> >>>>
> >>>>> On Thu 30-11-17 14:15:58, Andrew Morton wrote:
> >>>>> > From: Maxim Patlasov <MPatlasov@parallels.com>
> >>>>> > Subject: mm: add strictlimit knob
> >>>>> >
> >>>>> > The "strictlimit" feature was introduced to enforce per-bdi dirty
> >>>>> > limits
> >>>>> > for FUSE which sets bdi max_ratio to 1% by default:
> >>>>> >
> >>>>> > http://article.gmane.org/gmane.linux.kernel.mm/105809
> >>>>> >
> >>>>> > However the feature can be useful for other relatively slow or
> >>>>> > untrusted
> >>>>> > BDIs like USB flash drives and DVD+RW.  The patch adds a knob to
> >>>>> > enable
> >>>>> > the feature:
> >>>>> >
> >>>>> > echo 1 > /sys/class/bdi/X:Y/strictlimit
> >>>>> >
> >>>>> > Being enabled, the feature enforces bdi max_ratio limit even if
> >>>>> > global
> >>>>> > (10%) dirty limit is not reached.  Of course, the effect is not
> >>>>> > visible
> >>>>> > until /sys/class/bdi/X:Y/max_ratio is decreased to some reasonable
> >>>>> > value.
> >>>>>
> >>>>> In principle I have nothing against this and the usecase sounds
> >>>>> reasonable
> >>>>> (in fact I believe the lack of a feature like this is one of reasons
> >>>>> why
> >>>>> desktop automounters usually mount USB devices with 'sync' mount
> >>>>> option).
> >>>>> So feel free to add:
> >>>>>
> >>>>> Reviewed-by: Jan Kara <jack@suse.cz>
> >>>>>
> >>>>
> >>>> Cc Jens, who may be vaguely interested in plans to finally merge this
> >>>> three-year-old patch?
> >>>>
> >>>>
> >>>>
> >>>> From: Maxim Patlasov <MPatlasov@parallels.com>
> >>>> Subject: mm: add strictlimit knob
> >>>>
> >>>> The "strictlimit" feature was introduced to enforce per-bdi dirty limits
> >>>> for FUSE which sets bdi max_ratio to 1% by default:
> >>>>
> >>>> http://article.gmane.org/gmane.linux.kernel.mm/105809
> >>>
> >>>
> >>>
> >>> That link is invalid for now, possibly due to the gmane site rebuild.
> >>> I find an email thread here which looks relevant:
> >>>
> >>> https://sourceforge.net/p/fuse/mailman/message/35254883/
> >>>
> >>> Where Maxim has an interesting point:
> >>>
> >>>        > Did any one try increasing the limit and did see any
> >>> better/worse
> >>>>
> >>>> performance ?
> >>>
> >>>
> >>>        We've used 20% as default value in OpenVZ kernel for a long while
> >>> (1%
> >>> was not enough to saturate our distributed parallel storage).
> >>>
> >>> So the knob will also enable people to _disable_ the 1% fuse limit to
> >>> increase performance.
> >>>
> >>> So people can use the exposed knob in 2 ways to fit their needs, which
> >>> is in general a good thing.
> >>>
> >>> However the comment in wb_position_ratio() says
> >>>
> >>>                        Without strictlimit feature, fuse writeback may
> >>>          * consume arbitrary amount of RAM because it is accounted in
> >>>          * NR_WRITEBACK_TEMP which is not involved in calculating
> >>> "nr_dirty".
> >>>
> >>> How dangerous would that be if some user disabled the 1% fuse limit
> >>> through the exposed knob? Will the NR_WRITEBACK_TEMP effect go far
> >>> beyond the user's expectation (20% max dirty limit)?
> >>>
> >>> Looking at the fuse code, NR_WRITEBACK_TEMP will grow proportional to
> >>> WB_WRITEBACK, which should be throttled when bdi_write_congested().
> >>> The congested flag will be set on
> >>>
> >>>        fuse_conn.num_background >= fuse_conn.congestion_threshold
> >>>        So it looks NR_WRITEBACK_TEMP will somehow be throttled. Just that
> >>> it's not included in the 20% dirty limit.
> >>
> >>
> >> Only balance_dirty_pages_ratelimited() is going to limit the
> >> generation of dirty pages, I don't think congestion flags will do
> >> that.
> >
> >
> > Right. However my concern is something to limit the generation of
> > fuse's _writeback_ pages.
> >
> > The normal writeback pages are limited in 2 ways:
> >
> > - balance_dirty_pages_ratelimited()'s dirty throttling:
> >
> >  nr_dirty + nr_writeback + nr_unstable < global and/or bdi dirty limit
> >
> > - block layer's nr_requests queue limit
> >
> > However fuse's NR_WRITEBACK_TEMP looks special and has none of such
> > limits. The congested bit merely affect the vmscan pageout path.
> >
> >        pageout
> >          may_write_to_inode
> >            inode_write_congested
> >              wb_congested
> >
> > I wonder if fuse has its own approach to limit NR_WRITEBACK_TEMP?
> > Either explicitly or implicitly, there has to be some hard limit.
> >
> >> And (AFAICS) for fuse only  BDI_CAP_STRICTLIMIT will allow
> >> accounting temp writeback pages when throttling dirty page generation.
> >> So without BDI_CAP_STRICTLIMIT kernel memory use of fuse may explode.
> >> So we probably need a way to force BDI_CAP_STRICTLIMIT (i.e. do not
> >> permit disabling it for fuse).
> >
> >
> > So fuse relies on small nr_dirty. Does fuse impose any explicit or
> > implicit rule that NR_WRITEBACK_TEMP will never exceed (N * nr_dirty)?
> > Otherwise the size of NR_WRITEBACK_TEMP cannot be guaranteed.
> >
> > For example, is it possible for some process (eg. dd) to dirty pages
> > as fast as possible while some other kernel logic to convert PG_dirty
> > to NR_WRITEBACK_TEMP as fast as possible, so that even the 1% bdi
> > strictlimit (which limits PG_dirty rather than NR_WRITEBACK_TEMP)
> > cannot stop all memory being eat up by ever growing NR_WRITEBACK_TEMP?
> 
> Hmm,  temp pages are still accounted as WB_WRITEBACK until writeback
> finishes.  Does that not count towards the dirty limit?
> 

This discussion died out and the patch is still "stuck" :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
