MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <18151.20356.862163.430265@stoffel.org>
Date: Tue, 11 Sep 2007 22:31:32 -0400
From: "John Stoffel" <john@stoffel.org>
Subject: Re: [PATCH 00/23] per device dirty throttling -v10
In-Reply-To: <20070911195350.825778000@chello.nl>
References: <20070911195350.825778000@chello.nl>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Peter> Per device dirty throttling patches These patches aim to
Peter> improve balance_dirty_pages() and directly address three
Peter> issues:

Peter>   1) inter device starvation
Peter>   2) stacked device deadlocks
Peter>   3) inter process starvation

Peter> 1 and 2 are a direct result from removing the global dirty
Peter> limit and using per device dirty limits. By giving each device
Peter> its own dirty limit is will no longer starve another device,
Peter> and the cyclic dependancy on the dirty limit is broken.

Ye haa!  This should be a big improvement.  

Peter> In order to efficiently distribute the dirty limit across the
Peter> independant devices a floating proportion is used, this will
Peter> allocate a share of the total limit proportional to the
Peter> device's recent activity.

I'm not sure I like or agree with this.  Shouldn't we be limiting
based on the device's capability to sustain traffic?  So if I have a
RAID device which can read/write a total of 100Mb/sec, while at the
same time I've got a CF device which can do 5Mb/sec, shouldn't we be
more strongly limiting the CF device, even if it is the only device
being written to?  

Of course, I haven't read the patches yet, nor am I qualified to
comment on them in any meanginful way I think.  Hopefully I'm just
missing something key here in the explanation.

Peter> 3 is done by also scaling the dirty limit proportional to the
Peter> current task's recent dirty rate.

Do you mean task or device here?  I'm just wondering how well this
works with a bunch of devices with wildly varying speeds.  

John

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
