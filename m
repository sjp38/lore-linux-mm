Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id B56B36B025F
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 10:33:26 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id b35so33070585qta.0
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 07:33:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q43si1601773qta.58.2016.07.12.07.33.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 07:33:25 -0700 (PDT)
Date: Tue, 12 Jul 2016 16:33:47 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC PATCH 5/6] vhost, mm: make sure that oom_reaper doesn't
	reap memory read by vhost
Message-ID: <20160712143346.GC28837@redhat.com>
References: <20160703134719.GA28492@redhat.com> <20160703140904.GA26908@redhat.com> <20160703151829.GA28667@redhat.com> <20160703182254-mutt-send-email-mst@redhat.com> <20160703164723.GA30151@redhat.com> <20160703215250-mutt-send-email-mst@redhat.com> <20160707082811.GC5379@dhcp22.suse.cz> <20160707183848-mutt-send-email-mst@redhat.com> <20160708122948.GA4733@redhat.com> <20160711141427.GM1811@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160711141427.GM1811@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>

On 07/11, Michal Hocko wrote:
>
> On Fri 08-07-16 14:29:48, Oleg Nesterov wrote:
> > On 07/07, Michael S. Tsirkin wrote:
> > >
> > > On Thu, Jul 07, 2016 at 10:28:12AM +0200, Michal Hocko wrote:
> > > >
> > > > Just to make sure we are all at the same page. I guess the scenario is
> > > > as follows. The owner of the mm has ring and other statefull information
> > > > in the private memory but consumers living with their own mm consume
> > > > some data from a shared memory segments (e.g. files). The worker would
> > > > misinterpret statefull information (zeros rather than the original
> > > > content) and would copy invalid/corrupted data to the consumer. Am I
> > > > correct?
> > >
> > > Exactly.
> >
> > Michael, let me ask again.
> >
> > But what if we simply kill the owner of this mm?
>
> I might be wrong here but the mm owner doesn't really matter AFAIU. It
> is the holder of the file descriptor for the "device" who control all
> the actions, no? The fact that it hijacked the mm along the way is hiden
> from users. If you kill the owner but pass the fd somewhere else then
> the mm will live as long as the fd.

Of course. I meant that qemu/guest won't update that statefull info in its
anonymous memory after we kill it. And I have no idea if it is fine or not.

As I said, I do not even know what drivers/vhost actually does, and probably
that is why I do not understand why this particular problem (bogus zeroes in
anonymous memory) is worse than other problems we can't avoid anyway when we
kill the victim and this affects other applications.

> > If yes, note that this means that any process which can do VHOST_SET_OWNER becomes
> > "oom-unkillable" to some degree, and this doesn't look right. It can spawn another
> > CLONE_FILES process and this will block fops->release() which (iiuc) should stop
> > the kernel thread which pins the memory hog's memory.
>
> I believe this is indeed possible. It can even pass the fd to a
> different process and keep it alive, hidden from the oom killer causing
> other processes to be killed.

Yes, so I think we should unmap the memory even if it is used by kthread.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
