Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7132B6B004D
	for <linux-mm@kvack.org>; Mon,  9 Nov 2009 20:08:28 -0500 (EST)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCHv8 3/3] vhost_net: a kernel-level virtio server
Date: Tue, 10 Nov 2009 11:38:20 +1030
References: <cover.1257349249.git.mst@redhat.com> <200911091647.29655.rusty@rustcorp.com.au> <8f53421d0911082310n1f5f487ew8c2c03d2e1d7ca5c@mail.gmail.com>
In-Reply-To: <8f53421d0911082310n1f5f487ew8c2c03d2e1d7ca5c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200911101138.20569.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: "Michael S. Tsirkin" <m.s.tsirkin@gmail.com>
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, s.hetze@linux-ag.com, Daniel Walker <dwalker@fifo99.com>, Eric Dumazet <eric.dumazet@gmail.com>
List-ID: <linux-mm.kvack.org>

On Mon, 9 Nov 2009 05:40:32 pm Michael S. Tsirkin wrote:
> On Mon, Nov 9, 2009 at 8:17 AM, Rusty Russell <rusty@rustcorp.com.au> wrote:
> > There's something about the 'acked' which rubs me the wrong way.
> > "enabled_features" is perhaps a better term than "acked_features"; "acked"
> > seems more a user point-of-view, "enabled" seems more driver POV?
> 
> Hmm. Are you happy with the ioctl name? If yes I think being consistent
> with that is important.

I think in my original comments I noted that I preferred GET / SET, rather
than GET/ACK.

> > Actually, this looks wrong to me:
> >
> > +       case VHOST_SET_VRING_BASE:
> > ...
> > +               vq->avail_idx = vq->last_avail_idx = s.num;
> >
> > The last_avail_idx is part of the state of the driver.  It needs to be saved
> > and restored over susp/resume.
> 
> 
> Exactly. That's what VHOST_GET/SET_VRING_BASE does.  avail_idx is just a
> cached value for notify on empty, so what this does is clear the value.

Ah, you actually refresh it every time anyway.  Hmm, could you do my poor
brain a favor and either just get_user it in vhost_trigger_irq(), or call
it 'cached_avail_idx' or something?

> >  The only reason it's not in the ring itself
> > is because I figured the other side doesn't need to see it (which is true, but
> > missed debugging opportunities as well as man-in-the-middle issues like this
> > one).  I had a patch which put this field at the end of the ring, I might
> > resurrect it to avoid this problem.  This is backwards compatible with all
> > implementations.  See patch at end.
> 
> Yes, I remember that patch. There seems to be little point though, at
> this stage.

Well, it avoids this ioctl, by exposing all the state.  We may well need it
later, to expand the ring in other ways.

> > I would drop avail_idx altogether: get_user is basically free, and simplifies
> > a lot.  As most state is in the ring, all you need is an ioctl to save/restore
> > the last_avail_idx.
> 
> avail_idx is there for notify on empty: I had this thought that it's
> better to leave the avail cache line alone when we are triggering
> interrupt to avoid bouncing it around if guest is updating it meanwhile
> on another CPU, and I think my testing showed that it helped
> performance, but could be a mistake.  You don't believe this can help?

I believe it could help, but this is YA case where it would have been nice to
have a dumb basic patch and this as a patch on top.  But I am going to ask
you to re-run that measurement, see if it stacks up (because it's an
interesting lesson if it does..)

Thanks!
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
