Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6CE126B0033
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 06:58:43 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id u70so14436644pfa.2
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 03:58:43 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id x70si4218437pfe.582.2017.10.16.03.58.40
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Oct 2017 03:58:41 -0700 (PDT)
Subject: Re: [PATCH] virtio: avoid possible OOM lockup at virtballoon_oom_notify()
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1507632457-4611-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171013162134-mutt-send-email-mst@kernel.org>
	<201710140141.JFF26087.FLQHOFOOtFMVSJ@I-love.SAKURA.ne.jp>
	<20171015030921-mutt-send-email-mst@kernel.org>
	<201710151438.FAD86443.tOOFHVOSFQJLMF@I-love.SAKURA.ne.jp>
In-Reply-To: <201710151438.FAD86443.tOOFHVOSFQJLMF@I-love.SAKURA.ne.jp>
Message-Id: <201710161958.IAE65151.HFOLMQSFOVFJtO@I-love.SAKURA.ne.jp>
Date: Mon, 16 Oct 2017 19:58:29 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mst@redhat.com
Cc: mhocko@kernel.org, wei.w.wang@intel.com, virtualization@lists.linux-foundation.org, linux-mm@kvack.org

Tetsuo Handa wrote:
> Michael S. Tsirkin wrote:
> > > > 
> > > > The proper fix isn't that hard - just avoid allocations under lock.
> > > > 
> > > > Patch posted, pls take a look.
> > > 
> > > Your patch allocates pages in order to inflate the balloon, but
> > > your patch will allow leak_balloon() to deflate the balloon.
> > > How deflating the balloon (i.e. calling leak_balloon()) makes sense
> > > when allocating pages for inflating the balloon (i.e. calling
> > > fill_balloon()) ?
> > 
> > The idea is that fill_balloon is allocating memory with __GFP_NORETRY
> > so it will avoid disruptive actions like the OOM killer.
> > Under pressure it will normally fail and retry in half a second or so.
> > 
> > Calling leak_balloon in that situation could benefit the system as a whole.
> > 
> > I might be misunderstanding the meaning of the relevant GFP flags,
> > pls correct me if I'm wrong.
> 
> Would you answer to below question by "yes"/"no" ?
> 
>   If leak_balloon() is called via out_of_memory(), leak_balloon()
>   will decrease "struct virtio_balloon"->num_pages.
>   But, is "struct virtio_balloon_config"->num_pages updated when
>   leak_balloon() is called via out_of_memory() ?
> 
> Below explanation assumes that your answer is "no".
> 
> I consider that fill_balloon() is using __GFP_NORETRY is a bug.

Below are my test results using 4.14-rc5.

  http://I-love.SAKURA.ne.jp/tmp/20171016-default.log.xz
  http://I-love.SAKURA.ne.jp/tmp/20171016-deflate.log.xz

20171016-default.log.xz is without VIRTIO_BALLOON_F_DEFLATE_ON_OOM and
20171016-deflate.log.xz is with VIRTIO_BALLOON_F_DEFLATE_ON_OOM. (I used
inverting virtio_has_feature(VIRTIO_BALLOON_F_DEFLATE_ON_OOM) test
because the QEMU I'm using does not support deflate-on-oom option.)

> Consider an extreme situation that guest1 is started with 8192MB
> memory and then guest1's memory is reduced to 128MB by
> 
>   virsh qemu-monitor-command --domain guest1 --hmp 'balloon 128'
> 
> when VIRTIO_BALLOON_F_DEFLATE_ON_OOM was not negotiated.
> Of course, 128MB would be too small to operate guest1 properly.
> Since update_balloon_size_func() continues calling fill_balloon()
> until guest1's memory is reduced to 128MB, you will see flooding of
> "puff" messages (and guest1 is practically unusable because all CPU
> resource will be wasted for unsuccessful memory reclaim attempts)
> unless the OOM killer is invoked.

20171016-default.log.xz continued printing "puff" messages until kernel
panic caused by somebody else killing all OOM killable processes via
GFP_KERNEL allocation requests. Although fill_balloon() was printing
a lot of noises due to __GFP_NORETRY, the system made forward progress
in the form of kernel panic triggered by no more OOM killable processes.

----------
[   88.270838] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   88.503496] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   88.730058] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   88.937971] Out of memory: Kill process 669 (dhclient) score 54 or sacrifice child
[   89.007322] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   89.234874] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   89.439735] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   89.496389] Out of memory: Kill process 853 (tuned) score 47 or sacrifice child
[   89.663808] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   89.883812] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   90.104417] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   90.251293] Out of memory: Kill process 568 (polkitd) score 36 or sacrifice child
[   90.326131] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   90.821722] Out of memory: Kill process 601 (NetworkManager) score 23 or sacrifice child
[   91.293848] Out of memory: Kill process 585 (rsyslogd) score 13 or sacrifice child
[   91.799413] Out of memory: Kill process 415 (systemd-journal) score 13 or sacrifice child
[   91.861974] Out of memory: Kill process 987 (qmgr) score 6 or sacrifice child
[   91.925297] Out of memory: Kill process 985 (master) score 6 or sacrifice child
[   92.254082] Out of memory: Kill process 985 (master) score 6 or sacrifice child
[   92.464029] Out of memory: Kill process 881 (login) score 4 or sacrifice child
[   92.467859] Out of memory: Kill process 881 (login) score 4 or sacrifice child
[   93.490928] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   93.713220] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   93.932145] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   94.147652] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   94.363826] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   94.606404] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   94.833539] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   95.053230] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   95.267805] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   95.483789] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   98.290124] Out of memory: Kill process 595 (crond) score 3 or sacrifice child
[   98.643588] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   98.864487] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   99.084685] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   99.299766] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   99.515745] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   99.758334] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   99.985175] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  100.204474] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  100.419757] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  100.635681] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  101.263840] Out of memory: Kill process 587 (systemd-logind) score 2 or sacrifice child
[  101.319432] Out of memory: Kill process 586 (irqbalance) score 1 or sacrifice child
[  101.386546] Out of memory: Kill process 569 (dbus-daemon) score 0 or sacrifice child
[  103.805754] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  104.033073] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  104.253104] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  104.467810] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  104.683792] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  104.926409] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  105.153490] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  105.372610] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  105.587751] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  105.803719] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  108.958882] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  109.185254] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  109.404393] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  109.621584] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  109.697419] Kernel panic - not syncing: Out of memory and no killable processes...
[  109.723710] ---[ end Kernel panic - not syncing: Out of memory and no killable processes...
----------

> 
> What this patch is trying to handle is a situation when
> VIRTIO_BALLOON_F_DEFLATE_ON_OOM was negotiated. Once
> update_balloon_size_func() started calling fill_balloon(),
> update_balloon_size_func() will continue calling fill_balloon()
> until guest1's memory is reduced to 128MB, won't it?
> 
> Since fill_balloon() uses __GFP_IO | __GFP_FS, fill_balloon() can
> indirectly trigger out_of_memory() despite __GFP_NORETRY is specified.
> 
> When update_balloon_size_func() is running for calling fill_balloon(),
> calling leak_balloon() will increase number of pages to fill which
> fill_balloon() is supposed to fill. Leaking some pages from leak_balloon()
> via blocking_notifier_call_chain() callback could avoid invocation of the
> OOM killer for that specific moment, but it bounces back to us later because
> number of pages to allocate later (note that update_balloon_size_func() is
> running for calling fill_balloon()) is increased by leak_balloon().

20171016-deflate.log.xz continued printing "puff" messages without any OOM
killer messages, for fill_balloon() always inflates faster than leak_balloon()
deflates.

Since the OOM killer cannot be invoked unless leak_balloon() completely
deflates faster than fill_balloon() inflates, the guest remained unusable
(e.g. unable to login via ssh) other than printing "puff" messages.
This result was worse than 20171016-default.log.xz , for the system was
not able to make any forward progress (i.e. complete OOM lockup).

----------
[   19.866938] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   20.089350] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   20.430965] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   20.652641] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   20.894680] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   21.122063] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   21.340872] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   21.556128] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   21.772473] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   22.014960] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   24.972961] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   25.201565] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   25.420875] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   25.636081] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   25.851670] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   26.095842] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   26.322284] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[   26.851691] virtio_balloon virtio3: Out of puff! Can't get 1 pages
(...snipped...)
[  211.748567] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  211.963910] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  215.157737] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  215.385239] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  215.604426] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  215.819807] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  216.036491] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  216.278718] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  216.505410] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  216.724334] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  216.940318] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  217.155560] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  220.312187] virtio_balloon virtio3: Out of puff! Can't get 1 pages
[  220.342980] sysrq: SysRq : Resetting
----------

> 
> Thus, I don't think that avoid invoking the OOM killer by calling leak_balloon()
> makes sense when update_balloon_size_func() is running for calling fill_balloon().
> And this patch tries to detect it by replacing mutex_lock() with mutex_trylock().
> 
> > Well the point of this flag is that when it's acked,
> > host knows that it's safe to inflate the balloon
> > to a large portion of guest memory and this won't
> > cause an OOM situation.
> 
> Assuming that your answer to the question is "no", I don't think it is
> safe to inflate the balloon to a large portion of guest memory, for once
> update_balloon_size_func() started calling fill_balloon(),
> update_balloon_size_func() can not stop calling fill_balloon() even when
> blocking_notifier_call_chain() callback called leak_balloon() because
> "struct virtio_balloon_config"->num_pages will not be updated when
> blocking_notifier_call_chain() callback called leak_balloon().

As I demonstrated above, VIRTIO_BALLOON_F_DEFLATE_ON_OOM can lead to complete
OOM lockup because out_of_memory() => fill_balloon() => out_of_memory() =>
fill_balloon() sequence can effectively disable the OOM killer when the host
assumed that it's safe to inflate the balloon to a large portion of guest
memory and this won't cause an OOM situation.

> > I think the assumption is that it fill back up eventually
> > when guest does have some free memory.

So, my question again because such assumption is broken.
What is the expected behavior after deflating while inflating?
How should "struct virtio_balloon_config"->num_pages be interpreted?

  struct virtio_balloon_config {
  	/* Number of pages host wants Guest to give up. */
  	__u32 num_pages;
  	/* Number of pages we've actually got in balloon. */
  	__u32 actual;
  };

If leak_balloon() from out_of_memory() should be stronger than
fill_balloon() from update_balloon_size_func(), we need to make
sure that update_balloon_size_func() stops calling fill_balloon()
when leak_balloon() was called from out_of_memory().

If fill_balloon() from update_balloon_size_func() should be
stronger than leak_balloon() from out_of_memory(), we need to make
sure that leak_balloon() from out_of_memory() is ignored when
fill_balloon() from update_balloon_size_func() is running.

Apart from vb->balloon_lock deadlock avoidance, we need to define
the expected behavior.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
