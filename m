From: Nick Piggin <npiggin@suse.de>
Subject: Re: Why doesn't zap_pte_range() call page_mkwrite()
Date: Tue, 8 Sep 2009 19:00:02 +0200
Message-ID: <20090908170002.GD29902__23838.751592166$1252429222$gmane$org@wotan.suse.de>
References: <E1Lx4yU-0007A8-Gl@pomaz-ex.szeredi.hu> <1240519320.5602.9.camel@heimdal.trondhjem.org> <E1LxFd4-0008Ih-Rd@pomaz-ex.szeredi.hu> <20090424104137.GA7601@sgi.com> <E1LxMlO-0000sU-1J@pomaz-ex.szeredi.hu> <1240592448.4946.35.camel@heimdal.trondhjem.org> <20090425051028.GC10088@wotan.suse.de> <20090908153007.GB2513@think> <20090908154132.GC29902@wotan.suse.de> <20090908163149.GB2975@think>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D2BAD6B007E
	for <linux-mm@kvack.org>; Tue,  8 Sep 2009 13:00:04 -0400 (EDT)
Content-Disposition: inline
In-Reply-To: <20090908163149.GB2975@think>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>, Trond Myklebust <trond.myklebust@fys.uio.no>, Miklos Szeredi <miklos@szeredi.hu>, holt@sgi.com, linux-nfs@vger.kernel.org, linux-fsdevel@vger.ker
List-Id: linux-mm.kvack.org

On Tue, Sep 08, 2009 at 12:31:49PM -0400, Chris Mason wrote:
> On Tue, Sep 08, 2009 at 05:41:32PM +0200, Nick Piggin wrote:
> > It hasn't fallen completely off my radar. fsblock has the same issue
> > (although I've just been ignoring gup writes into fsblock fs for the
> > time being).
> 
> Ok, I'll change my detection code a bit then.

OK.


> > I have a basic idea of what to do... It would be nice to change calling
> > convention of get_user_pages and take the page lock. Database people might
> > scream, in which case we could only take the page lock for filesystems that
> > define ->page_mkwrite (so shared mem segments avoid the overhead). Lock
> > ordering might get a bit interesting, but if we can have callers ensure they
> > always submit and release partially fulfilled requirests, then we can always
> > trylock them.
> 
> I think everyone will have page_mkwrite eventually, at least everyone
> who the databases will care about ;)

Ah, the problem is not where the DIO write goes, it's where the read
goes :) (ie. the read writes into get_user_pages pages).

So for databases this should typically be shared memory segments I'd
say (tmpfs), or maybe anonymous memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
