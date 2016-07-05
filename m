Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DFB106B0005
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 02:22:25 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id a69so430746702pfa.1
        for <linux-mm@kvack.org>; Mon, 04 Jul 2016 23:22:25 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id k26si2600113pfk.85.2016.07.04.23.22.23
        for <linux-mm@kvack.org>;
        Mon, 04 Jul 2016 23:22:25 -0700 (PDT)
Date: Tue, 5 Jul 2016 14:22:22 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [RFC RESEND PATCH] swap: choose swap device according to numa
 node
Message-ID: <20160705062221.GA12620@aaronlu.sh.intel.com>
References: <20160429083408.GA20728@aaronlu.sh.intel.com>
 <263e604d-aa8c-1b6b-e80a-0c34142349c9@intel.com>
 <CADjb_WQGuUULfiMhY3LzwcMUyFa7XcuF6vbgEXcRP2iFNh3TXQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CADjb_WQGuUULfiMhY3LzwcMUyFa7XcuF6vbgEXcRP2iFNh3TXQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu Chen <yu.chen.surf@gmail.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Jul 05, 2016 at 01:57:35PM +0800, Yu Chen wrote:
> On Tue, Jul 5, 2016 at 11:19 AM, Aaron Lu <aaron.lu@intel.com> wrote:
> > Resend:
> > This is a resend, the original patch doesn't catch much attention.
> > It may not be a big deal for swap devices that used to be hosted on
> > HDD but with devices like 3D Xpoint to be used as swap device, it could
> > make a real difference if we consider NUMA information when doing IO.
> > Comments are appreciated, thanks for your time.
> >
> -------------------------%<-------------------------
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 71b1c29948db..dd7e44a315b0 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -3659,9 +3659,11 @@ void kswapd_stop(int nid)
> >
> >  static int __init kswapd_init(void)
> >  {
> > -       int nid;
> > +       int nid, err;
> >
> > -       swap_setup();
> > +       err = swap_setup();
> > +       if (err)
> > +               return err;
> >         for_each_node_state(nid, N_MEMORY)
> >                 kswapd_run(nid);
> >         hotcpu_notifier(cpu_callback, 0);
> In original implementation, although swap_setup failed,

In current implementaion swap_setup never fail :-)

> the swapd would also be created, since swapd is
> not only  used for swap out but also for other page reclaim,
> so this change above might modify its semantic? Sorry if
> I understand incorrectly.

Indeed it's a behaviour change. The only reason swap_setup can return an
error code now is when it fails to allocate nr_node_ids * sizeof(struct
plist_head) memory and if that happens, I don't think it makes much
sense to continue boot the system.

Thanks,
Aaron

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
