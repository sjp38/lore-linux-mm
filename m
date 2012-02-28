Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 403586B0092
	for <linux-mm@kvack.org>; Mon, 27 Feb 2012 23:11:28 -0500 (EST)
Received: by dadv6 with SMTP id v6so7134986dad.14
        for <linux-mm@kvack.org>; Mon, 27 Feb 2012 20:11:27 -0800 (PST)
Date: Mon, 27 Feb 2012 20:10:53 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] tmpfs: security xattr setting on inode creation
In-Reply-To: <CAGGTEhPQ6OLgqZbbAwE=3Xj8qE2iNhLOk5LdkGU13WxbY=qb2w@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1202272003380.1574@eggly.anvils>
References: <1329990365-23779-1-git-send-email-jarkko.sakkinen@intel.com> <alpine.LRH.2.02.1202241913400.30742@tundra.namei.org> <alpine.LSU.2.00.1202241904070.22389@eggly.anvils> <20120227144602.07f5ec33.akpm@linux-foundation.org>
 <CAGGTEhPQ6OLgqZbbAwE=3Xj8qE2iNhLOk5LdkGU13WxbY=qb2w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Ware, Ryan R" <ryan.r.ware@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jarkko Sakkinen <jarkko.sakkinen@intel.com>, James Morris <jmorris@namei.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org

On Tue, 28 Feb 2012, Ware, Ryan R wrote:
> On Tue, Feb 28, 2012 at 7:46 AM, Andrew Morton <akpm@linux-foundation.org>wrote:
> > On Fri, 24 Feb 2012 19:19:22 -0800 (PST)
> > Hugh Dickins <hughd@google.com> wrote:
> >...
> > > +             if (!new_xattr->name) {
> > > +                     kfree(new_xattr);
> > > +                     return -ENOMEM;
> > > +             }
> > > +
> > > +             memcpy(new_xattr->name, XATTR_SECURITY_PREFIX,
> > > +                    XATTR_SECURITY_PREFIX_LEN);
> > > +             memcpy(new_xattr->name + XATTR_SECURITY_PREFIX_LEN,
> > > +                    xattr->name, len);
> > > +
> > > +             spin_lock(&info->lock);
> > > +             list_add(&new_xattr->list, &info->xattr_list);
> > > +             spin_unlock(&info->lock);
> > > +     }
> > > +
> > > +     return 0;
> > > +}
> >
> > So if there's a kmalloc failure partway through the array, we leave a
> > partially xattrified inode in place.
> >
> > Are we sure this is OK?
> >
> 
> I'm guessing Jarkko can clean that up a bit.  It wouldn't be a good idea to
> leave inaccurate data structures laying around during failure cases.

Andrew raises a good concern, but Jarkko got it just right and no
change is needed: any xattrs already allocated are properly linked
on info->xattr_list, then when security_inode_init_security() fails
(with an error other than EOPNOTSUPP) the failing inode is iput(),
which ends up in shmem_evict_inode(), which kfree()s those xattrs
(and their names) on info->xattr_list.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
