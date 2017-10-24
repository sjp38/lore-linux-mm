Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id D1FF36B0038
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 17:10:10 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id a192so15259469pge.1
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 14:10:10 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id p13si611599pll.609.2017.10.24.14.10.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Oct 2017 14:10:09 -0700 (PDT)
Date: Tue, 24 Oct 2017 15:10:07 -0600
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: Re: [PATCH] mmap.2: Add description of MAP_SHARED_VALIDATE and
 MAP_SYNC
Message-ID: <20171024211007.GA1611@linux.intel.com>
References: <20171024152415.22864-1-jack@suse.cz>
 <20171024152415.22864-19-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171024152415.22864-19-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Dan Williams <dan.j.williams@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@infradead.org>, linux-ext4@vger.kernel.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-xfs@vger.kernel.org, linux-api@vger.kernel.org, linux-mm@kvack.org

On Tue, Oct 24, 2017 at 05:24:15PM +0200, Jan Kara wrote:
> Signed-off-by: Jan Kara <jack@suse.cz>

This looks unchanged since the previous version?

> ---
>  man2/mmap.2 | 30 ++++++++++++++++++++++++++++++
>  1 file changed, 30 insertions(+)
> 
> diff --git a/man2/mmap.2 b/man2/mmap.2
> index 47c3148653be..598ff0c64f7f 100644
> --- a/man2/mmap.2
> +++ b/man2/mmap.2
> @@ -125,6 +125,21 @@ are carried through to the underlying file.
>  to the underlying file requires the use of
>  .BR msync (2).)
>  .TP
> +.B MAP_SHARED_VALIDATE
> +The same as
> +.B MAP_SHARED
> +except that
> +.B MAP_SHARED
> +mappings ignore unknown flags in
> +.IR flags .
> +In contrast when creating mapping of
> +.B MAP_SHARED_VALIDATE
> +mapping type, the kernel verifies all passed flags are known and fails the
> +mapping with
> +.BR EOPNOTSUPP
> +otherwise. This mapping type is also required to be able to use some mapping
> +flags.
> +.TP
>  .B MAP_PRIVATE
>  Create a private copy-on-write mapping.
>  Updates to the mapping are not visible to other processes
> @@ -352,6 +367,21 @@ option.
>  Because of the security implications,
>  that option is normally enabled only on embedded devices
>  (i.e., devices where one has complete control of the contents of user memory).
> +.TP
> +.BR MAP_SYNC " (since Linux 4.15)"
> +This flags is available only with
> +.B MAP_SHARED_VALIDATE
> +mapping type. Mappings of
> +.B MAP_SHARED
> +type will silently ignore this flag.
> +This flag is supported only for files supporting DAX (direct mapping of persistent
> +memory). For other files, creating mapping with this flag results in
> +.B EOPNOTSUPP
> +error. Shared file mappings with this flag provide the guarantee that while
> +some memory is writeably mapped in the address space of the process, it will
> +be visible in the same file at the same offset even after the system crashes or
> +is rebooted. This allows users of such mappings to make data modifications
> +persistent in a more efficient way using appropriate CPU instructions.
>  .PP
>  Of the above flags, only
>  .B MAP_FIXED
> -- 
> 2.12.3
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
