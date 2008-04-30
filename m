Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id m3U7P7ms028329
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 12:55:07 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3U7P0cf1400836
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 12:55:00 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id m3U7P7gD020839
	for <linux-mm@kvack.org>; Wed, 30 Apr 2008 07:25:07 GMT
Date: Wed, 30 Apr 2008 12:54:57 +0530
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: correct use of vmtruncate()?
Message-ID: <20080430072457.GB7791@skywalker>
References: <20080429100601.GO108924158@sgi.com> <481756A3.20601@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <481756A3.20601@oracle.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zach Brown <zach.brown@oracle.com>
Cc: David Chinner <dgc@sgi.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, xfs-oss <xfs@oss.sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 29, 2008 at 10:10:59AM -0700, Zach Brown wrote:
> 
> > The obvious fix for this is that block_write_begin() and
> > friends should be calling ->setattr to do the truncation and hence
> > follow normal convention for truncating blocks off an inode.
> > However, even that appears to have thorns. e.g. in XFS we hold the
> > iolock exclusively when we call block_write_begin(), but it is not
> > held in all cases where ->setattr is currently called. Hence calling
> > ->setattr from block_write_begin in this failure case will deadlock
> > unless we also pass a "nolock" flag as well. XFS already
> > supports this (e.g. see the XFS fallocate implementation) but no other
> > filesystem does (some probably don't need to).
> 
> This paragraph in particular reminds me of an outstanding bug with
> O_DIRECT and ext*.  It isn't truncating partial allocations when a dio
> fails with ENOSPC.  This was noticed by a user who saw that fsck found
> bocks outside i_size in the file that saw ENOSPC if they tried to
> unmount and check the volume after the failed write.

This patch should be the fix I guess
	http://lkml.org/lkml/2006/12/18/103

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
