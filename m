Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0ABEC6B025E
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 11:39:00 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id c185so43411794qkd.1
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 08:39:00 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m185si2905313qkd.303.2016.07.07.08.38.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jul 2016 08:38:59 -0700 (PDT)
Date: Thu, 7 Jul 2016 18:38:52 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH 5/6] vhost, mm: make sure that oom_reaper doesn't
 reap memory read by vhost
Message-ID: <20160707183848-mutt-send-email-mst@redhat.com>
References: <1467365190-24640-1-git-send-email-mhocko@kernel.org>
 <1467365190-24640-6-git-send-email-mhocko@kernel.org>
 <20160703134719.GA28492@redhat.com>
 <20160703140904.GA26908@redhat.com>
 <20160703151829.GA28667@redhat.com>
 <20160703182254-mutt-send-email-mst@redhat.com>
 <20160703164723.GA30151@redhat.com>
 <20160703215250-mutt-send-email-mst@redhat.com>
 <20160707082811.GC5379@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160707082811.GC5379@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>

On Thu, Jul 07, 2016 at 10:28:12AM +0200, Michal Hocko wrote:
> On Mon 04-07-16 00:17:55, Michael S. Tsirkin wrote:
> > On Sun, Jul 03, 2016 at 06:47:23PM +0200, Oleg Nesterov wrote:
> > > On 07/03, Michael S. Tsirkin wrote:
> > > >
> > > > On Sun, Jul 03, 2016 at 05:18:29PM +0200, Oleg Nesterov wrote:
> > > > >
> > > > > Well, we are going to kill all tasks which share this memory. I mean, ->mm.
> > > > > If "sharing memory with another task" means, say, a file, then this memory
> > > > > won't be unmapped (if shared).
> > > > >
> > > > > So let me ask again... Suppose, say, QEMU does VHOST_SET_OWNER and then we
> > > > > unmap its (anonymous/non-shared) memory. Who else's memory can be corrupted?
> > > >
> > > > As you say, I mean anyone who shares memory with QEMU through a file.
> > > 
> > > And in this case vhost_worker() reads the anonymous memory of QEMU process,
> > > not the memory which can be shared with another task, correct?
> > > 
> > > And if QEMU simply crashes, this can't affect anyone who shares memory with
> > > QEMU through a file, yes?
> > > 
> > > Oleg.
> > 
> > Well no - the VM memory is not always anonymous memory. It can be an
> > mmaped file.
> 
> Just to make sure we are all at the same page. I guess the scenario is
> as follows. The owner of the mm has ring and other statefull information
> in the private memory but consumers living with their own mm consume
> some data from a shared memory segments (e.g. files). The worker would
> misinterpret statefull information (zeros rather than the original
> content) and would copy invalid/corrupted data to the consumer. Am I
> correct?
> 
> -- 
> Michal Hocko
> SUSE Labs


Exactly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
