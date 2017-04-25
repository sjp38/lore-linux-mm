Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id D752C6B0350
	for <linux-mm@kvack.org>; Tue, 25 Apr 2017 12:43:28 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id k1so49863847qtb.20
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 09:43:28 -0700 (PDT)
Received: from mail-qt0-f171.google.com (mail-qt0-f171.google.com. [209.85.216.171])
        by mx.google.com with ESMTPS id p91si22611584qtd.90.2017.04.25.09.43.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Apr 2017 09:43:27 -0700 (PDT)
Received: by mail-qt0-f171.google.com with SMTP id m36so144714526qtb.0
        for <linux-mm@kvack.org>; Tue, 25 Apr 2017 09:43:27 -0700 (PDT)
Message-ID: <1493138603.2758.3.camel@redhat.com>
Subject: Re: [PATCH v3 10/20] fuse: set mapping error in writepage_locked
 when it fails
From: Jeff Layton <jlayton@redhat.com>
Date: Tue, 25 Apr 2017 12:43:23 -0400
In-Reply-To: <20170425111903.GI2793@quack2.suse.cz>
References: <20170424132259.8680-1-jlayton@redhat.com>
	 <20170424132259.8680-11-jlayton@redhat.com>
	 <20170424160431.GK23988@quack2.suse.cz>
	 <1493054076.2895.17.camel@redhat.com>
	 <20170425081720.GA2793@quack2.suse.cz> <1493116513.2758.1.camel@redhat.com>
	 <20170425111903.GI2793@quack2.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, osd-dev@open-osd.org, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org, dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dkJonathan Corbet <corbet@lwn.net>

On Tue, 2017-04-25 at 13:19 +0200, Jan Kara wrote:
> On Tue 25-04-17 06:35:13, Jeff Layton wrote:
> > On Tue, 2017-04-25 at 10:17 +0200, Jan Kara wrote:
> > > On Mon 24-04-17 13:14:36, Jeff Layton wrote:
> > > > On Mon, 2017-04-24 at 18:04 +0200, Jan Kara wrote:
> > > > > On Mon 24-04-17 09:22:49, Jeff Layton wrote:
> > > > > > This ensures that we see errors on fsync when writeback fails.
> > > > > > 
> > > > > > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > > > > 
> > > > > Hum, but do we really want to clobber mapping errors with temporary stuff
> > > > > like ENOMEM? Or do you want to handle that in mapping_set_error?
> > > > > 
> > > > 
> > > > Right now we don't really have such a thing as temporary errors in the
> > > > writeback codepath. If you return an error here, the data doesn't stay
> > > > dirty or anything, and I think we want to ensure that that gets reported
> > > > via fsync.
> > > > 
> > > > I'd like to see us add better handling for retryable errors for stuff
> > > > like ENOMEM or EAGAIN. I think this is the first step toward that
> > > > though. Once we have more consistent handling of writeback errors in
> > > > general, then we can start doing more interesting things with retryable
> > > > errors.
> > > > 
> > > > So yeah, I this is the right thing to do for now.
> > > 
> > > OK, fair enough. And question number 2):
> > > 
> > > Who is actually responsible for setting the error in the mapping when error
> > > happens inside ->writepage()? Is it the ->writepage() callback or the
> > > caller of ->writepage()? Or something else? Currently it seems to be a
> > > strange mix (e.g. mm/page-writeback.c: __writepage() calls
> > > mapping_set_error() when ->writepage() returns error) so I'd like to
> > > understand what's the plan and have that recorded in the changelogs.
> > > 
> > 
> > That's an excellent question.
> > 
> > I think we probably want the writepage/launder_page operations to call
> > mapping_set_error. That makes it possible for filesystems (e.g. NFS) to
> > handle their own error tracking and reporting without using the new
> > infrastructure. If they never call mapping_set_error then we'll always
> > just return whatever their ->fsync operation returns on an fsync.
> 
> OK, makes sense. It is also in line with what you did for DAX, 9p, or here
> for FUSE. So feel free to add:
> 
> Reviewed-by: Jan Kara <jack@suse.cz>
> 
> for this patch but please also add a sentense that ->writepage() is
> responsible for calling mapping_set_error() if it fails and page is not
> redirtied to the changelogs of patches changing writepage handlers.
> 
> > I'll make another pass through the tree and see whether we have some
> > mapping_set_error calls that should be removed, and will flesh out
> > vfs.txt to state this. Maybe that file needs a whole section on
> > writeback error reporting? Hmmm...
> 
> I think it would be nice to have all the logic described in one place. So
> +1 from me.
> 
> > That probably also means that I should drop patch 8 from this series
> > (mm: ensure that we set mapping error if writeout fails), since that
> > should be happening in writepage already.
> 
> Yes.
> 
> 								Honza

(cc'ing Jon since I'm proposing a doc update)

Here's what I'm thinking for a vfs.txt update after this series. The
section on writeback_control could probably be more specific.

----------------------8<-------------------------

diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
index 94dd27ef4a76..aa912b65792a 100644
--- a/Documentation/filesystems/vfs.txt
+++ b/Documentation/filesystems/vfs.txt
@@ -576,7 +576,23 @@ should clear PG_Dirty and set PG_Writeback.  It can be actually
 written at any point after PG_Dirty is clear.  Once it is known to be
 safe, PG_Writeback is cleared.
 
-Writeback makes use of a writeback_control structure...
+Writeback makes use of a writeback_control structure to direct the
+operations. This tells the writepage and writepages operations something
+about the nature of and reason for the writeback request, and the
+constraints under which it is being done. It is also used to track state
+between successive writeback requests.
+
+When there is an error during writeback, then an error should be
+reported to fsync on all file descriptors that were open at the time of
+the error. This is typically done by setting the wb_err value in the
+address_space via mapping_set_error when writeback errors occur. The
+vfs-layer fsync code will then report the errors on a per-fd basis.
+
+Filesystems are free to track errors internally if they choose, but they
+should aim to provide the same semantics for error reporting when there
+are multiple writers. Filesystems that track their own errors should
+avoid calling mapping_set_error in order to ensure that errors stored in
+the mapping aren't improperly reported by the generic filesystem code.
 
 struct address_space_operations
 -------------------------------
@@ -888,7 +904,9 @@ otherwise noted.
 
   release: called when the last reference to an open file is closed
 
-  fsync: called by the fsync(2) system call
+  fsync: called by the fsync(2) system call. Errors that were previously
+	 recorded using mapping_set_error will automatically be returned to
+	 the application and the file's error sequence advanced.
 
   fasync: called by the fcntl(2) system call when asynchronous
 	(non-blocking) mode is enabled for a file

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
