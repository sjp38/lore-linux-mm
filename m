Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 945056B004D
	for <linux-mm@kvack.org>; Mon,  9 Nov 2009 06:58:33 -0500 (EST)
Date: Mon, 9 Nov 2009 13:55:48 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv8 3/3] vhost_net: a kernel-level virtio server
Message-ID: <20091109115548.GA2368@redhat.com>
References: <cover.1257349249.git.mst@redhat.com> <200911061529.17500.rusty@rustcorp.com.au> <20091108113516.GA19016@redhat.com> <200911091647.29655.rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200911091647.29655.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, s.hetze@linux-ag.com, Daniel Walker <dwalker@fifo99.com>, Eric Dumazet <eric.dumazet@gmail.com>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 09, 2009 at 04:47:29PM +1030, Rusty Russell wrote:
> Actually, this looks wrong to me:
> 
> +	case VHOST_SET_VRING_BASE:
> ...
> +		vq->avail_idx = vq->last_avail_idx = s.num;
> 
> The last_avail_idx is part of the state of the driver.  It needs to be saved
> and restored over susp/resume.  The only reason it's not in the ring itself
> is because I figured the other side doesn't need to see it (which is true, but
> missed debugging opportunities as well as man-in-the-middle issues like this
> one).  I had a patch which put this field at the end of the ring, I might
> resurrect it to avoid this problem.  This is backwards compatible with all
> implementations.  See patch at end.
> 
> I would drop avail_idx altogether: get_user is basically free, and simplifies
> a lot.  As most state is in the ring, all you need is an ioctl to save/restore
> the last_avail_idx.

I remembered another reason for caching head in avail_idx.  Basically,
avail index could change between when I poll for descriptors and when I
want to notify guest.

So we could have:
	- poll descriptors until empty
	- notify
		detects not empty so does not notify

And the way to solve it would be to return flag from
notify telling us to restart the polling loop.

But, this will be more code, on data path, than
what happens today where I simply keep state
from descriptor polling and use that to notify.

I also suspect that somehow this race in practice can not create
deadlocks ... but I prefer to avoid it, these things are very tricky: if
I see an empty ring, and stop processing descriptors, I want to trigger
notify on empty.

So if we want to avoid keeping "empty" state, IMO the best way would be
to pass a flag to vhost_signal that tells it that ring is empty.
Makes sense?

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
