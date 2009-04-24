Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 2A3C66B004D
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 10:07:04 -0400 (EDT)
Subject: Re: Why doesn't zap_pte_range() call page_mkwrite()
From: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1240579914.4946.19.camel@heimdal.trondhjem.org>
References: <1240510668.11148.40.camel@heimdal.trondhjem.org>
	 <E1Lx4yU-0007A8-Gl@pomaz-ex.szeredi.hu>
	 <1240519320.5602.9.camel@heimdal.trondhjem.org>
	 <E1LxFd4-0008Ih-Rd@pomaz-ex.szeredi.hu>
	 <E1LxFuD-0008M9-1a@pomaz-ex.szeredi.hu>
	 <1240577989.32585.1.camel@think.oraclecorp.com>
	 <1240579914.4946.19.camel@heimdal.trondhjem.org>
Content-Type: text/plain
Date: Fri, 24 Apr 2009 10:06:58 -0400
Message-Id: <1240582018.4946.25.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: Miklos Szeredi <miklos@szeredi.hu>, npiggin@suse.de, linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2009-04-24 at 09:31 -0400, Trond Myklebust wrote:
> The only alternative I can think of would be to unmap the page when the
> filesystem starts to write it out in order to force another page fault
> if the user application writes more data into that page.

Actually, this might be fairly trivial to implement in NFS. We'd tag the
nfs_page request as having been created by page_mkwrite(), then unmap
any such tagged page in the ->writepage() callback (assuming that
calling unmap_mapping_range() from ->writepage() is allowed?).

AFAICS that should get rid of those residual dirty ptes in sys_munmap().

Cheers
  Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
