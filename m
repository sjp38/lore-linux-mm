Subject: Re: PATCH: Bug in invalidate_inode_pages()?
References: <yttk8h4vcgp.fsf@vexeta.dc.fi.udc.es>
From: Trond Myklebust <trond.myklebust@fys.uio.no>
Date: 09 May 2000 02:29:32 +0200
In-Reply-To: "Juan J. Quintela"'s message of "09 May 2000 01:39:18 +0200"
Message-ID: <shsbt2gh8gj.fsf@charged.uio.no>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

>>>>> " " == Juan J Quintela <quintela@fi.udc.es> writes:

     > Hi
     >         I think that I have found a bug in
     >         invalidate_inode_pages.
     > It results that we don't remove the pages from the
     > &inode->i_mapping->pages list, then when we return te do the
     > next loop through all the pages, we can try to free a page that
     > we have freed in the previous pass.  Once here I have also
     > removed the goto

     > Comments, have I lost something obvious?

Unfortunately, yes...

  Firstly, you're removing the wrong page (viz. curr = curr->next).

  Secondly, we're already removing the page from the mapping using the
  inlined function remove_page_from_inode_queue() which is again
  called by remove_inode_page(). This also updates mapping->nrpages.

So invalidate_inode_pages() is correct as it stands.

Cheers,
  Trond
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
