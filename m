Subject: Re: [PATCH 30/40] nfs: fixup missing error code
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <463B30CC.8070305@redhat.com>
References: <20070504102651.923946304@chello.nl>
	 <20070504103202.468420061@chello.nl>  <463B30CC.8070305@redhat.com>
Content-Type: text/plain
Date: Fri, 04 May 2007 15:18:08 +0200
Message-Id: <1178284688.24217.37.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Staubach <staubach@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, Trond Myklebust <trond.myklebust@fys.uio.no>, Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>, James Bottomley <James.Bottomley@SteelEye.com>, Mike Christie <michaelc@cs.wisc.edu>, Andrew Morton <akpm@linux-foundation.org>, Daniel Phillips <phillips@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-05-04 at 09:10 -0400, Peter Staubach wrote:
> Peter Zijlstra wrote:
> > Commit 0b67130149b006628389ff3e8f46be9957af98aa lost the setting of tk_status
> > to -EIO when there was no progress with short reads.
> >
> > Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > ---
> >  fs/nfs/read.c |    4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> >
> > Index: linux-2.6-git/fs/nfs/read.c
> > ===================================================================
> > --- linux-2.6-git.orig/fs/nfs/read.c	2007-03-13 14:35:53.000000000 +0100
> > +++ linux-2.6-git/fs/nfs/read.c	2007-03-13 14:36:05.000000000 +0100
> > @@ -384,8 +384,10 @@ static int nfs_readpage_retry(struct rpc
> >  	/* This is a short read! */
> >  	nfs_inc_stats(data->inode, NFSIOS_SHORTREAD);
> >  	/* Has the server at least made some progress? */
> > -	if (resp->count == 0)
> > +	if (resp->count == 0) {
> > +		task->tk_status = -EIO;
> >  		return 0;
> > +	}
> >  
> >  	/* Yes, so retry the read at the end of the data */
> >  	argp->offset += resp->count;
> 
> This doesn't look right to me.  It is not an error for the NFS server
> to return 0 bytes.  It is usually an indication of EOF.  If an error
> occured, then the NFS server would have returned an error.

Ah, ok; I found this when looking through NFS changelogs, and this
change was not changelogged. Consider it dropped.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
