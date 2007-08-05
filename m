Date: Sun, 5 Aug 2007 15:29:25 +0200
From: Willy Tarreau <w@1wt.eu>
Subject: Re: [PATCH 00/23] per device dirty throttling -v8
Message-ID: <20070805132925.GA4089@1wt.eu>
References: <20070803123712.987126000@chello.nl> <46B4E161.9080100@garzik.org> <20070804224706.617500a0@the-village.bc.nu> <200708050051.40758.ctpm@ist.utl.pt> <20070805014926.400d0608@the-village.bc.nu> <20070805072805.GB4414@elte.hu> <20070805134640.2c7d1140@the-village.bc.nu> <20070805125847.GC22060@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070805125847.GC22060@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Claudio Martins <ctpm@ist.utl.pt>, Jeff Garzik <jeff@garzik.org>, =?iso-8859-1?Q?J=F6rn?= Engel <joern@logfs.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, richard@rsk.demon.co.uk, david@lang.hm
List-ID: <linux-mm.kvack.org>

On Sun, Aug 05, 2007 at 02:58:47PM +0200, Ingo Molnar wrote:
> 
> * Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> 
> > > The only remotely valid compatibility argument would be Mutt - but even 
> > > that handles it just fine. (we broke way more software via noexec)
> > 
> > And went through a sensible process of resolving it.
> >
> > And its not just mutt. HSM stuff stops working which is a big deal as 
> > stuff clogs up. The /tmp/ cleaning tools go wrong as well.
> 
> what OSS HSM software stops working and what is its failure mode? /tmp 
> cleaning tools will work _just fine_ if we report back max(mtime,ctime) 
> as atime - they'll zap more /tmp stuff as they used to. There's no 
> guarantee for /tmp contents anyway if tmpwatch is running. Or the patch 
> below.

Ingo,

In your example above, maybe it's the opposite, users know they can keep a
file in /tmp one more week by simply cat'ing it.

Changing the kernel in a non-easily reversible way is not kind to the users.
As you pointed it, there's no "atime" option in mount, and quite frankly,
having to reboot an NFS server to change a command line option which should
belong to fstab is quite gross. And yes, there may be people realying on
atime in specific environments. I remember having used it in the past to
automatically archive unused files. Those people might not be affected by
the drop in performance at all and would rather keep the feature.

I like Alan's idea of a package to automatically add "noatime" everywhere
in fstab, not only because it's easy to use, but because it will also teach
users how they can proceed on their other systems. Also, if you make the
package yourself, it will benefit from the "coolness factor" many people
see in everything that's done by renown persons (you know, the type of
people who regularly ask you if you use vi/emacs and what type of window
manager, and who then consider it must be good if you use it). I'll stop
ranting here, some of them may be reading ;-)

As a second step, once many people explicitly ask for "noatime" by default,
it will be time to add MS_ATIME to the kernel and to mount, and set NOATIME
as the default with big warnings. This will make everyone happy.

But expecting the admins to recompile their kernels or to reboot to change
the atime status is not acceptable IMHO. Moreover, they will not even know
they have to do this and they will feel frustrated because the system will
not do what they want.

I've already been bothered a lot by ext3 filesystems with dirindex enabled.
When you boot from an old CD and you cannot mount them, it's already quite
irritating (not to mention that tune2fs from the old CD does not know about
it either so you cannot disable the option). But it's even worse when you
plug an USB hard disk into an old server to start a backup and notice that
you cannot mount the disk without first upgrading your kernel !

For this reason, I think that the default noatime will be desirable only
after MS_ATIME is supported by both the kernel and the tools.

Cheers,
Willy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
