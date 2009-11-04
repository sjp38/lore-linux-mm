Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1689C6B0044
	for <linux-mm@kvack.org>; Wed,  4 Nov 2009 14:08:23 -0500 (EST)
Date: Wed, 4 Nov 2009 21:05:23 +0200
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv6 1/3] tun: export underlying socket
Message-ID: <20091104190523.GA772@redhat.com>
References: <cover.1257193660.git.mst@redhat.com> <20091102222612.GB15184@redhat.com> <200911031312.33580.arnd@arndb.de> <200911041909.06054.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200911041909.06054.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: Arnd Bergmann <arnd@arndb.de>
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, gregory.haskins@gmail.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com
List-ID: <linux-mm.kvack.org>

On Wed, Nov 04, 2009 at 07:09:05PM +0100, Arnd Bergmann wrote:
> On Tuesday 03 November 2009, Arnd Bergmann wrote:
> > > index 3f5fd52..404abe0 100644
> > > --- a/include/linux/if_tun.h
> > > +++ b/include/linux/if_tun.h
> > > @@ -86,4 +86,18 @@ struct tun_filter {
> > >         __u8   addr[0][ETH_ALEN];
> > >  };
> > >  
> > > +#ifdef __KERNEL__
> > > +#if defined(CONFIG_TUN) || defined(CONFIG_TUN_MODULE)
> > > +struct socket *tun_get_socket(struct file *);
> > > +#else
> > > +#include <linux/err.h>
> > > +#include <linux/errno.h>
> > > +struct file;
> > > +struct socket;
> > > +static inline struct socket *tun_get_socket(struct file *f)
> > > +{
> > > +       return ERR_PTR(-EINVAL);
> > > +}
> > > +#endif /* CONFIG_TUN */
> > > +#endif /* __KERNEL__ */
> > >  #endif /* __IF_TUN_H */
> > 
> > Is this a leftover from testing? Exporting the function for !__KERNEL__
> > seems pointless.
> > 
> 
> Michael, you didn't reply on this comment and the code is still there in v8.
> Do you actually need this? What for?
> 
> 	Arnd <><

Sorry, missed the question. If you look closely it is not exported for
!__KERNEL__ at all.  The stub is for when CONFIG_TUN is undefined.
Maybe I'll add a comment near #else, even though this is a bit strange
since the #if is just 2 lines above it.

-- 
MST

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
