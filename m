Received: from spaceape13.eur.corp.google.com (spaceape13.eur.corp.google.com [172.28.16.147])
	by smtp-out.google.com with ESMTP id l1JC9gOA026487
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 12:09:43 GMT
Received: from nf-out-0910.google.com (nfby25.prod.google.com [10.48.101.25])
	by spaceape13.eur.corp.google.com with ESMTP id l1JC9c0v027164
	for <linux-mm@kvack.org>; Mon, 19 Feb 2007 12:09:38 GMT
Received: by nf-out-0910.google.com with SMTP id y25so2911474nfb
        for <linux-mm@kvack.org>; Mon, 19 Feb 2007 04:09:38 -0800 (PST)
Message-ID: <6599ad830702190409x4f64e56ex4044a12d949e44af@mail.gmail.com>
Date: Mon, 19 Feb 2007 04:09:38 -0800
From: "Paul Menage" <menage@google.com>
Subject: Re: [ckrm-tech] [RFC][PATCH][2/4] Add RSS accounting and control
In-Reply-To: <45D9906F.2090605@in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070219065019.3626.33947.sendpatchset@balbir-laptop>
	 <20070219065034.3626.2658.sendpatchset@balbir-laptop>
	 <20070219005828.3b774d8f.akpm@linux-foundation.org>
	 <45D97DF8.5080000@in.ibm.com>
	 <20070219030141.42c65bc0.akpm@linux-foundation.org>
	 <45D9856D.1070902@in.ibm.com>
	 <20070219032352.2856af36.akpm@linux-foundation.org>
	 <45D9906F.2090605@in.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@in.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, vatsa@in.ibm.com, ckrm-tech@lists.sourceforge.net, xemul@sw.ru, linux-kernel@vger.kernel.org, linux-mm@kvack.org, svaidy@linux.vnet.ibm.com, devel@openvz.org
List-ID: <linux-mm.kvack.org>

On 2/19/07, Balbir Singh <balbir@in.ibm.com> wrote:
> >
> > More worrisome is the potential for use-after-free.  What prevents the
> > pointer at mm->container from referring to freed memory after we're dropped
> > the lock?
> >
>
> The container cannot be freed unless all tasks holding references to it are
> gone,

... or have been moved to other containers. If you're not holding
task->alloc_lock or one of the container mutexes, there's nothing to
stop the task being moved to another container, and the container
being deleted.

If you're in an RCU section then you can guarantee that the container
(that you originally read from the task) and its subsystems at least
won't be deleted while you're accessing them, but for accounting like
this I suspect that's not enough, since you need to be adding to the
accounting stats on the correct container. I think you'll need to hold
mm->container_lock for the duration of memctl_update_rss()

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
