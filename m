Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 728E96B0005
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 03:55:11 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 4so17151403wmz.1
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 00:55:11 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id iq3si6345296wjb.18.2016.06.09.00.55.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Jun 2016 00:55:10 -0700 (PDT)
Date: Thu, 9 Jun 2016 09:55:39 +0200
From: David Sterba <dsterba@suse.cz>
Subject: Re: [PATCH 04/21] fs: Replace CURRENT_TIME with current_fs_time()
 for inode timestamps
Message-ID: <20160609075539.GF3905@suse.cz>
Reply-To: dsterba@suse.cz
References: <1465448705-25055-1-git-send-email-deepa.kernel@gmail.com>
 <1465448705-25055-5-git-send-email-deepa.kernel@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1465448705-25055-5-git-send-email-deepa.kernel@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Deepa Dinamani <deepa.kernel@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Colin Cross <ccross@android.com>, Arnd Bergmann <arnd@arndb.de>, pvfs2-developers@beowulf-underground.org, Kees Cook <keescook@chromium.org>, Matt Fleming <matt@codeblueprint.co.uk>, "David S. Miller" <davem@davemloft.net>, Boaz Harrosh <ooo@electrozaur.com>, Anton Vorontsov <anton@enomsg.org>, Joel Becker <jlbec@evilplan.org>, Chris Mason <clm@fb.com>, Josef Bacik <jbacik@fb.com>, "J. Bruce Fields" <bfields@fieldses.org>, Eric Van Hensbergen <ericvh@gmail.com>, Firo Yang <firogm@gmail.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Prasad Joshi <prasadjoshi.linux@gmail.com>, Hugh Dickins <hughd@google.com>, "Serge E. Hallyn" <serge@hallyn.com>, Nadia Yvette Chambers <nyc@holomorphy.com>, Peter Hurley <peter@hurleysoftware.com>, Sean Hefty <sean.hefty@intel.com>, Tony Luck <tony.luck@intel.com>, Latchesar Ionkov <lucho@ionkov.net>, Josh Triplett <josh@joshtriplett.org>, Alexei Starovoitov <ast@kernel.org>, Felipe Balbi <balbi@kernel.org>, Jaegeuk Kim <jaegeuk@kernel.org>, Robert Richter <rric@kernel.org>, Dave Kleikamp <shaggy@kernel.org>, linux-mm@kvack.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Julia Lawall <Julia.Lawall@lip6.fr>, y2038@lists.linaro.org, samba-technical@lists.samba.org, oprofile-list@lists.sf.net, fuse-devel@lists.sourceforge.net, jfs-discussion@lists.sourceforge.net, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, Joern Engel <joern@logfs.org>, logfs@logfs.org, Matthew Garrett <matthew.garrett@nebula.com>, Anna Schumaker <anna.schumaker@netapp.com>, Mike Marshall <hubcap@omnibond.com>, osd-dev@open-osd.org, James Morris <james.l.morris@oracle.com>, ocfs2-devel@oss.oracle.com, Jeremy Kerr <jk@ozlabs.org>, Eric Paris <eparis@parisplace.org>, Paul Moore <paul@paul-moore.com>, Jeff Layton <jlayton@poochiereds.net>, Benny Halevy <bhalevy@primarydata.com>, Trond Myklebust <trond.myklebust@primarydata.com>, cluster-devel@redhat.com, David Howells <dhowells@redhat.com>, Doug Ledford <dledford@redhat.com>, Bob Peterson <rpeterso@redhat.com>, Steven Whitehouse <swhiteho@redhat.com>, Steve French <sfrench@samba.org>, Chao Yu <chao2.yu@samsung.com>, Changman Lee <cm224.lee@samsung.com>, Ron Minnich <rminnich@sandia.gov>, Mark Fasheh <MFasheh@suse.com>, Michal Hocko <MHocko@suse.com>, Miklos Szeredi <miklos@szeredi.hu>, Ian Kent <raven@themaw.net>, Stephen Smalley <sds@tycho.nsa.gov>, selinux@tycho.nsa.gov, autofs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-efi@vger.kernel.org, linux-nfs@vger.kernel.org, linux-nilfs@vger.kernel.org, linux-rdma@vger.kernel.org, linux-security-module@vger.kernel.org, linux-usb@vger.kernel.org, netdev@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>

On Wed, Jun 08, 2016 at 10:04:48PM -0700, Deepa Dinamani wrote:
> CURRENT_TIME macro is not appropriate for filesystems as it
> doesn't use the right granularity for filesystem timestamps.
> Use current_fs_time() instead.
> 
> CURRENT_TIME is also not y2038 safe.
> 
> This is also in preparation for the patch that transitions
> vfs timestamps to use 64 bit time and hence make them
> y2038 safe. As part of the effort current_fs_time() will be
> extended to do range checks. Hence, it is necessary for all
> file system timestamps to use current_fs_time(). Also,
> current_fs_time() will be transitioned along with vfs to be
> y2038 safe.
> 
> Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
> Cc: David Sterba <dsterba@suse.com>

for the btrfs bits

Reviewed-by: David Sterba <dsterba@suse.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
