Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id DFB946B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 04:28:14 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a66so12893957wme.1
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 01:28:14 -0700 (PDT)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id m2si4660518wme.45.2016.07.07.01.28.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 01:28:13 -0700 (PDT)
Received: by mail-wm0-f50.google.com with SMTP id f126so200922796wma.1
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 01:28:13 -0700 (PDT)
Date: Thu, 7 Jul 2016 10:28:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 5/6] vhost, mm: make sure that oom_reaper doesn't
 reap memory read by vhost
Message-ID: <20160707082811.GC5379@dhcp22.suse.cz>
References: <1467365190-24640-1-git-send-email-mhocko@kernel.org>
 <1467365190-24640-6-git-send-email-mhocko@kernel.org>
 <20160703134719.GA28492@redhat.com>
 <20160703140904.GA26908@redhat.com>
 <20160703151829.GA28667@redhat.com>
 <20160703182254-mutt-send-email-mst@redhat.com>
 <20160703164723.GA30151@redhat.com>
 <20160703215250-mutt-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160703215250-mutt-send-email-mst@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>

On Mon 04-07-16 00:17:55, Michael S. Tsirkin wrote:
> On Sun, Jul 03, 2016 at 06:47:23PM +0200, Oleg Nesterov wrote:
> > On 07/03, Michael S. Tsirkin wrote:
> > >
> > > On Sun, Jul 03, 2016 at 05:18:29PM +0200, Oleg Nesterov wrote:
> > > >
> > > > Well, we are going to kill all tasks which share this memory. I mean, ->mm.
> > > > If "sharing memory with another task" means, say, a file, then this memory
> > > > won't be unmapped (if shared).
> > > >
> > > > So let me ask again... Suppose, say, QEMU does VHOST_SET_OWNER and then we
> > > > unmap its (anonymous/non-shared) memory. Who else's memory can be corrupted?
> > >
> > > As you say, I mean anyone who shares memory with QEMU through a file.
> > 
> > And in this case vhost_worker() reads the anonymous memory of QEMU process,
> > not the memory which can be shared with another task, correct?
> > 
> > And if QEMU simply crashes, this can't affect anyone who shares memory with
> > QEMU through a file, yes?
> > 
> > Oleg.
> 
> Well no - the VM memory is not always anonymous memory. It can be an
> mmaped file.

Just to make sure we are all at the same page. I guess the scenario is
as follows. The owner of the mm has ring and other statefull information
in the private memory but consumers living with their own mm consume
some data from a shared memory segments (e.g. files). The worker would
misinterpret statefull information (zeros rather than the original
content) and would copy invalid/corrupted data to the consumer. Am I
correct?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
