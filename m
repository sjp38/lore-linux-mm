Message-ID: <481756A3.20601@oracle.com>
Date: Tue, 29 Apr 2008 10:10:59 -0700
From: Zach Brown <zach.brown@oracle.com>
MIME-Version: 1.0
Subject: Re: correct use of vmtruncate()?
References: <20080429100601.GO108924158@sgi.com>
In-Reply-To: <20080429100601.GO108924158@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, xfs-oss <xfs@oss.sgi.com>
List-ID: <linux-mm.kvack.org>

> The obvious fix for this is that block_write_begin() and
> friends should be calling ->setattr to do the truncation and hence
> follow normal convention for truncating blocks off an inode.
> However, even that appears to have thorns. e.g. in XFS we hold the
> iolock exclusively when we call block_write_begin(), but it is not
> held in all cases where ->setattr is currently called. Hence calling
> ->setattr from block_write_begin in this failure case will deadlock
> unless we also pass a "nolock" flag as well. XFS already
> supports this (e.g. see the XFS fallocate implementation) but no other
> filesystem does (some probably don't need to).

This paragraph in particular reminds me of an outstanding bug with
O_DIRECT and ext*.  It isn't truncating partial allocations when a dio
fails with ENOSPC.  This was noticed by a user who saw that fsck found
bocks outside i_size in the file that saw ENOSPC if they tried to
unmount and check the volume after the failed write.

So, whether we decide that failed writes should call setattr or
vmtruncate, we should also keep the generic O_DIRECT path in
consideration.  Today it doesn't even try the supposed generic method of
calling vmtrunate().

- z

(Though I'm sure XFS' dio code already handles freeing blocks :))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
