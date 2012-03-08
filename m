Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 525466B007E
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 18:13:02 -0500 (EST)
Received: by obbta14 with SMTP id ta14so1671038obb.14
        for <linux-mm@kvack.org>; Thu, 08 Mar 2012 15:13:01 -0800 (PST)
Message-ID: <4F593CF8.2000105@amacapital.net>
Date: Thu, 08 Mar 2012 15:12:56 -0800
From: Andy Lutomirski <luto@amacapital.net>
MIME-Version: 1.0
Subject: Re: [PATCH 00/11 v2] Push file_update_time() into .page_mkwrite
References: <1330602103-8851-1-git-send-email-jack@suse.cz>
In-Reply-To: <1330602103-8851-1-git-send-email-jack@suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org, dchinner@redhat.com, Jaya Kumar <jayalk@intworks.biz>, Sage Weil <sage@newdream.net>, ceph-devel@vger.kernel.org, Steve French <sfrench@samba.org>, linux-cifs@vger.kernel.org, Eric Van Hensbergen <ericvh@gmail.com>, Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>, v9fs-developer@lists.sourceforge.net, Miklos Szeredi <miklos@szeredi.hu>, fuse-devel@lists.sourceforge.net, Steven Whitehouse <swhiteho@redhat.com>, cluster-devel@redhat.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>

On 03/01/2012 03:41 AM, Jan Kara wrote:
>   Hello,
> 
>   to provide reliable support for filesystem freezing, filesystems need to have
> complete control over when metadata is changed. In particular,
> file_update_time() calls from page fault code make it impossible for
> filesystems to prevent inodes from being dirtied while the filesystem is
> frozen.
> 
> To fix the issue, this patch set changes page fault code to call
> file_update_time() only when ->page_mkwrite() callback is not provided. If the
> callback is provided, it is the responsibility of the filesystem to perform
> update of i_mtime / i_ctime if needed. We also push file_update_time() call
> to all existing ->page_mkwrite() implementations if the time update does not
> obviously happen by other means. If you know your filesystem does not need
> update of modification times in ->page_mkwrite() handler, please speak up and
> I'll drop the patch for your filesystem.
> 
> As a side note, an alternative would be to remove call of file_update_time()
> from page fault code altogether and require all filesystems needing it to do
> that in their ->page_mkwrite() implementation. That is certainly possible
> although maybe slightly inefficient and would require auditting 100+
> vm_operations_structs *shiver*.



IMO updating file times should happen when changes get written out, not
when a page is made writable, for two reasons:

1. Correctness.  With the current approach, it's very easy for files to
be changed after the last mtime update -- any changes between mkwrite
and actual writeback won't affect mtime.

2. Performance.  I have an application (presumably guessable from my
email address) for which blocking in page_mkwrite is an absolute
show-stopper.  (In fact it's so bad that we reverted back to running on
Windows until I hacked up a kernel to not do this.)  I have an incorrect
patch [1] to fix it, but I haven't gotten around to a real fix.  (I also
have stable pages reverted in my kernel.  Some day I'll submit a patch
to make it a filesystem option.  Or maybe it should even be a block
device / queue property like the alignment offset and optimal io size --
there are plenty of block device and file combinations which don't
benefit at all from stable pages.)

I'd prefer if file_update_time in page_mkwrite didn't proliferate.  A
better fix is probably to introduce a new inode flag, update it when a
page is undirtied, and then dirty and write the inode from the writeback
path.  (Kind of like my patch, but with an inode flag instead of a page
flag, and with the file_update_time done from the fs.)

[1] http://patchwork.ozlabs.org/patch/122516/

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
