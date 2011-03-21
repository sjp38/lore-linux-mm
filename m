Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id E990D8D0039
	for <linux-mm@kvack.org>; Mon, 21 Mar 2011 13:11:21 -0400 (EDT)
Subject: Re: [PATCH] tmpfs: implement security.capability xattrs
From: Eric Paris <eparis@redhat.com>
In-Reply-To: <alpine.LSU.2.00.1103202108160.21738@sister.anvils>
References: <20110111210710.32348.1642.stgit@paris.rdu.redhat.com>
	 <AANLkTi=wyaLP6gFmNxajp+HtYu3B9_KGf2o4BnYA+rwy@mail.gmail.com>
	 <AANLkTi=7GyY=O2eTupPXQijcnT_55a3RnHAruJpm_5Jo@mail.gmail.com>
	 <alpine.LSU.2.00.1103202108160.21738@sister.anvils>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 21 Mar 2011 12:43:05 -0400
Message-ID: <1300725785.2744.57.camel@unknown001a4b0c2895>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Eric Paris <eparis@parisplace.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, Christoph Hellwig <hch@infradead.org>, James Morris <jmorris@namei.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Sun, 2011-03-20 at 22:17 -0700, Hugh Dickins wrote:
> On Wed, 2 Mar 2011, Eric Paris wrote:

> > >>  include/linux/shmem_fs.h |    8 +++
> > >>  mm/shmem.c               |  112 ++++++++++++++++++++++++++++++++++++++++++++--
> > >>  2 files changed, 116 insertions(+), 4 deletions(-)
> 
> No change to fs/Kconfig?  You seem to smuggle the xattr and security
> support in under CONFIG_TMPFS_POSIX_ACL, and leave it unsupported
> without.  It's probably a fair assumption that the people with that
> option selected are the people who will be interested in this, so
> no need for the maze of separate config options which a grownup
> filesystem would have here.  But at the very least you need to say
> more in the TMPFS_POSIX_ACL Kconfig entry (a new name may be more
> trouble than it's worth).

Will update text.

> > >> @@ -2071,24 +2076,123 @@ static size_t shmem_xattr_security_list(struct dentry *dentry, char *list,
> > >>                                        size_t list_len, const char *name,
> > >>                                        size_t name_len, int handler_flags)
> > >>  {
> > >> -       return security_inode_listsecurity(dentry->d_inode, list, list_len);
> > >> +       struct shmem_xattr *xattr;
> > >> +       struct shmem_inode_info *shmem_i;
> 
> It's a nit, but (almost) everywhere else in shmem.c the shmem_inode_info
> pointer is known as "info": easy for me to fix up if I care, but nicer
> if you follow local custom.

Will fix.  I certainly don't like breaking conventions needlessly.

> > >> +       size_t used;
> > >> +       char *buf = NULL;
> > >> +
> > >> +       used = security_inode_listsecurity(dentry->d_inode, list, list_len);
> > >> +
> > >> +       shmem_i = SHMEM_I(dentry->d_inode);
> > >> +       if (list)
> > >> +               buf = list + used;
> 
> This is the place that caused me most trouble.  On a minor note:
> it worried me that security_inode_listsecurity() might return an
> error, whereas I think you know and assume that the worst it can
> return is 0 - might be worth a comment.

Will fix.

> But more major: I found it very odd that you collect one set of things
> from security_inode_listsecurity(), then proceed to tack on some more
> below from the shmem inode.  I looked at other filesystems (well, ext2!)
> and couldn't find a precedent.  What's this about?  Is it because other
> filesystems have an on-disk format which determines what they're capable
> of, whereas tmpfs is plastic and can reflect what the running system has?
> Or is it to allow for future xattrs which might be added to tmpfs, but
> frankly I'd rather do without until they're defined?

So there is a belief (based I think on an erroneous comment in the code
somewhere which I plan to find and fix) that the VFS provides some form
of generic xattr support if filesystems do not provide their own xattr
support.  This isn't true.  What actually happens is that the VFS will
directly call special LSM functions, if the filesystem provides no xattr
methods.  If the filesystem provides any xattr methods, which tmpfs does
when CONFIG_TMPFS_POSIX_ACL is set, then the VFS does different
stupi^wmagic things with regard to xattr calls.  I only really know the
SELinux LSM and will use it as an example, but I believe that SMACK does
very similar things.  When you run with SELinux enabled it will provide
support for ONLY security.selinux.  It provides this support by storing
the security.selinux xattr information inside the inode->i_security->sid
field.  I might be making this already weird interface even worse
because I'm trying to take advantage of the SELinux handling for
security.selinux rather than be required to store those in the
shmem_inode_info as well.  Other filesystems don't play this trick.

I'll try to rewrite the code to just be completely generic for
security.* and see if it is cleaner even if we waste some space storing
strings in ram we don't technically need to....

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
