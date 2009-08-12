Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 09C966B005A
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 09:26:58 -0400 (EDT)
Date: Wed, 12 Aug 2009 16:25:40 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv2 2/2] vhost_net: a kernel-level virtio server
Message-ID: <20090812132539.GD29200@redhat.com>
References: <cover.1249992497.git.mst@redhat.com> <20090811212802.GC26309@redhat.com> <4A82076A.1060805@gmail.com> <20090812090219.GB26847@redhat.com> <4A82BD2F.7080405@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4A82BD2F.7080405@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, hpa@zytor.com, paulmck@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Wed, Aug 12, 2009 at 09:01:35AM -0400, Gregory Haskins wrote:
> I think I understand what your comment above meant:  You don't need to
> do synchronize_rcu() because you can flush the workqueue instead to
> ensure that all readers have completed.

Yes.

>  But if thats true, to me, the
> rcu_dereference itself is gratuitous,

Here's a thesis on what rcu_dereference does (besides documentation):

reader does this

	A: sock = n->sock
	B: use *sock

Say writer does this:

	C: newsock = allocate socket
	D: initialize(newsock)
	E: n->sock = newsock
	F: flush


On Alpha, reads could be reordered.  So, on smp, command A could get
data from point F, and command B - from point D (uninitialized, from
cache).  IOW, you get fresh pointer but stale data.
So we need to stick a barrier in there.

> and that pointer is *not* actually
> RCU protected (nor does it need to be).

Heh, if readers are lockless and writer does init/update/sync,
this to me spells rcu.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
