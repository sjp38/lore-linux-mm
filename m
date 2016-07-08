Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4844E6B0260
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 08:29:53 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id v6so90752668vkb.2
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 05:29:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q18si898193qte.36.2016.07.08.05.29.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jul 2016 05:29:52 -0700 (PDT)
Date: Fri, 8 Jul 2016 14:29:48 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC PATCH 5/6] vhost, mm: make sure that oom_reaper doesn't
 reap memory read by vhost
Message-ID: <20160708122948.GA4733@redhat.com>
References: <1467365190-24640-1-git-send-email-mhocko@kernel.org>
 <1467365190-24640-6-git-send-email-mhocko@kernel.org>
 <20160703134719.GA28492@redhat.com>
 <20160703140904.GA26908@redhat.com>
 <20160703151829.GA28667@redhat.com>
 <20160703182254-mutt-send-email-mst@redhat.com>
 <20160703164723.GA30151@redhat.com>
 <20160703215250-mutt-send-email-mst@redhat.com>
 <20160707082811.GC5379@dhcp22.suse.cz>
 <20160707183848-mutt-send-email-mst@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160707183848-mutt-send-email-mst@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>

On 07/07, Michael S. Tsirkin wrote:
>
> On Thu, Jul 07, 2016 at 10:28:12AM +0200, Michal Hocko wrote:
> >
> > Just to make sure we are all at the same page. I guess the scenario is
> > as follows. The owner of the mm has ring and other statefull information
> > in the private memory but consumers living with their own mm consume
> > some data from a shared memory segments (e.g. files). The worker would
> > misinterpret statefull information (zeros rather than the original
> > content) and would copy invalid/corrupted data to the consumer. Am I
> > correct?
>
> Exactly.

Michael, let me ask again.

But what if we simply kill the owner of this mm? Yes, if we dont't unmap its
memory then vhost_worker() can't read the wrong zero from anonymous vma.
But the killed process obviously won't be able to update this statefull info
after that, it will be frozen. Are you saying this can't affect other apps
which share the memory with the (killed) mm owner?

IOW. If we kill a process, this can affect other applications anyway. Just for
example, suppose that this process takes a non-robust futex in the shared memory
segment. After that other users of this futex will hang forever.

So do you think that this particular "vhost" problem is really worse and we must
specialy avoid it?

If yes, note that this means that any process which can do VHOST_SET_OWNER becomes
"oom-unkillable" to some degree, and this doesn't look right. It can spawn another
CLONE_FILES process and this will block fops->release() which (iiuc) should stop
the kernel thread which pins the memory hog's memory.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
