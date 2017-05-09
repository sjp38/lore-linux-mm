Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 14B06280730
	for <linux-mm@kvack.org>; Tue,  9 May 2017 12:24:21 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id d14so2018525qkb.0
        for <linux-mm@kvack.org>; Tue, 09 May 2017 09:24:21 -0700 (PDT)
Received: from mail-qk0-f182.google.com (mail-qk0-f182.google.com. [209.85.220.182])
        by mx.google.com with ESMTPS id f123si488091qkd.196.2017.05.09.09.24.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 May 2017 09:24:20 -0700 (PDT)
Received: by mail-qk0-f182.google.com with SMTP id u75so5414133qka.3
        for <linux-mm@kvack.org>; Tue, 09 May 2017 09:24:19 -0700 (PDT)
Message-ID: <1494347057.2659.10.camel@redhat.com>
Subject: Re: [PATCH v4 25/27] Documentation: flesh out the section in
 vfs.txt on storing and reporting writeback errors
From: Jeff Layton <jlayton@redhat.com>
Date: Tue, 09 May 2017 12:24:17 -0400
In-Reply-To: <20170509154930.29524-26-jlayton@redhat.com>
References: <20170509154930.29524-1-jlayton@redhat.com>
	 <20170509154930.29524-26-jlayton@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net, linux-xfs@vger.kernel.org, cluster-devel@redhat.com, linux-f2fs-devel@lists.sourceforge.net, v9fs-developer@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-block@vger.kernel.org
Cc: dhowells@redhat.com, akpm@linux-foundation.org, hch@infradead.org, ross.zwisler@linux.intel.com, mawilcox@microsoft.com, jack@suse.com, viro@zeniv.linux.org.uk, corbet@lwn.net, neilb@suse.de, clm@fb.com, tytso@mit.edu, axboe@kernel.dk, josef@toxicpanda.com, hubcap@omnibond.com, rpeterso@redhat.com, bo.li.liu@oracle.com, Michael Kerrisk <mtk.manpages@gmail.com>

On Tue, 2017-05-09 at 11:49 -0400, Jeff Layton wrote:
> I waxed a little loquacious here, but I figured that more detail was
> better, and writeback error handling is so hard to get right.
> 
> Cc: Jan Kara <jack@suse.cz>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  Documentation/filesystems/vfs.txt | 54 ++++++++++++++++++++++++++++++++-------
>  1 file changed, 45 insertions(+), 9 deletions(-)
> 
> diff --git a/Documentation/filesystems/vfs.txt b/Documentation/filesystems/vfs.txt
> index f201a77873f7..382190a872e5 100644
> --- a/Documentation/filesystems/vfs.txt
> +++ b/Documentation/filesystems/vfs.txt
> @@ -576,12 +576,46 @@ should clear PG_Dirty and set PG_Writeback.  It can be actually
>  written at any point after PG_Dirty is clear.  Once it is known to be
>  safe, PG_Writeback is cleared.
>  
> -If there is an error during writeback, then the address_space should be
> -marked with an error (typically using mapping_set_error), in order to
> -ensure that the error can later be reported to the application when an
> -fsync is issued.
> -
> -Writeback makes use of a writeback_control structure...
> +Writeback makes use of a writeback_control structure to direct the
> +operations.  This gives the the writepage and writepages operations some
> +information about the nature of and reason for the writeback request,
> +and the constraints under which it is being done.  It is also used to
> +return information back to the caller about the result of a writepage or
> +writepages request.
> +
> +Handling errors during writeback
> +--------------------------------
> +Most applications that utilize the pagecache will periodically call
> +fsync to ensure that data written has made it to the backing store.
> +When there is an error during writeback, that error should be reported
> +when fsync is called.  After an error has been reported to fsync,
> +subsequent fsync calls on the same file descriptor should return 0,
> +unless further writeback errors have occurred since the previous fsync.
> +
> +Ideally, the kernel would report it only on file descriptions on which
> +writes were done that subsequently failed to be written back.  The
> +generic pagecache infrastructure does not track the file descriptions
> +that have dirtied each individual page however, so determining which
> +file descriptors should get back an error is not possible.
> +
> +Instead, the generic writeback error tracking infrastructure in the
> +kernel settles for reporting errors to fsync on all file descriptions
> +that were open at the time that the error occurred.  In a situation with
> +multiple writers, all of them will get back an error on a subsequent fsync,
> +even if all of the writes done through that particular file descriptor
> +succeeded (or even if there were no writes on that file descriptor at all).
> +

(cc'ing Michael Kerrisk)

Once this is closer to merge, I think we'll also want to update the
fsync(2) manpage with something similar to the 3 paragraphs above, and
also with an explanation of the behavior that applications can expect
from earlier kernels.

> +Filesystems that wish to use this infrastructure should call
> +mapping_set_error to record the error in the address_space when it
> +occurs.  The generic vfs code will then handle reporting the error when
> +fsync is called, even if the fsync file operation returned 0.
> +
> +Filesystems are free to track errors internally if they choose (i.e. if
> +they do keep track of how the pages were dirtied), but they should aim
> +to provide the same (or better) error reporting semantics for when there
> +are multiple writers.  Those filesystems should avoid calling
> +mapping_set_error in order to ensure that errors stored in the mapping
> +aren't improperly reported by the generic filesystem code.
>  
>  struct address_space_operations
>  -------------------------------
> @@ -810,7 +844,8 @@ struct address_space_operations {
>  The File Object
>  ===============
>  
> -A file object represents a file opened by a process.
> +A file object represents a file opened by a process. This is also known
> +as an "open file description" in POSIX parlance.
>  
>  
>  struct file_operations
> @@ -893,9 +928,10 @@ otherwise noted.
>  
>    release: called when the last reference to an open file is closed
>  
> -  fsync: called by the fsync(2) system call. Errors that were previously
> +  fsync: called by the fsync(2) system call.  Errors that were previously
>  	 recorded using mapping_set_error will automatically be returned to
> -	 the application and the file's error sequence advanced.
> +	 the application and the struct file's error sequence advanced.
> +	 See the section above on handling writeback errors.
>  
>    fasync: called by the fcntl(2) system call when asynchronous
>  	(non-blocking) mode is enabled for a file


-- 
Jeff Layton <jlayton@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
