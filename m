Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8A1A86B025E
	for <linux-mm@kvack.org>; Mon, 11 Jul 2016 10:14:30 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id g18so71569822lfg.2
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 07:14:30 -0700 (PDT)
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com. [74.125.82.51])
        by mx.google.com with ESMTPS id p10si38632wjp.50.2016.07.11.07.14.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jul 2016 07:14:29 -0700 (PDT)
Received: by mail-wm0-f51.google.com with SMTP id o80so52747210wme.1
        for <linux-mm@kvack.org>; Mon, 11 Jul 2016 07:14:29 -0700 (PDT)
Date: Mon, 11 Jul 2016 16:14:27 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 5/6] vhost, mm: make sure that oom_reaper doesn't
 reap memory read by vhost
Message-ID: <20160711141427.GM1811@dhcp22.suse.cz>
References: <1467365190-24640-6-git-send-email-mhocko@kernel.org>
 <20160703134719.GA28492@redhat.com>
 <20160703140904.GA26908@redhat.com>
 <20160703151829.GA28667@redhat.com>
 <20160703182254-mutt-send-email-mst@redhat.com>
 <20160703164723.GA30151@redhat.com>
 <20160703215250-mutt-send-email-mst@redhat.com>
 <20160707082811.GC5379@dhcp22.suse.cz>
 <20160707183848-mutt-send-email-mst@redhat.com>
 <20160708122948.GA4733@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160708122948.GA4733@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>

On Fri 08-07-16 14:29:48, Oleg Nesterov wrote:
> On 07/07, Michael S. Tsirkin wrote:
> >
> > On Thu, Jul 07, 2016 at 10:28:12AM +0200, Michal Hocko wrote:
> > >
> > > Just to make sure we are all at the same page. I guess the scenario is
> > > as follows. The owner of the mm has ring and other statefull information
> > > in the private memory but consumers living with their own mm consume
> > > some data from a shared memory segments (e.g. files). The worker would
> > > misinterpret statefull information (zeros rather than the original
> > > content) and would copy invalid/corrupted data to the consumer. Am I
> > > correct?
> >
> > Exactly.
> 
> Michael, let me ask again.
> 
> But what if we simply kill the owner of this mm?

I might be wrong here but the mm owner doesn't really matter AFAIU. It
is the holder of the file descriptor for the "device" who control all
the actions, no? The fact that it hijacked the mm along the way is hiden
from users. If you kill the owner but pass the fd somewhere else then
the mm will live as long as the fd.

[...]

> If yes, note that this means that any process which can do VHOST_SET_OWNER becomes
> "oom-unkillable" to some degree, and this doesn't look right. It can spawn another
> CLONE_FILES process and this will block fops->release() which (iiuc) should stop
> the kernel thread which pins the memory hog's memory.

I believe this is indeed possible. It can even pass the fd to a
different process and keep it alive, hidden from the oom killer causing
other processes to be killed.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
