Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id BEC176B005A
	for <linux-mm@kvack.org>; Mon, 17 Sep 2012 12:35:20 -0400 (EDT)
Received: from relay2.suse.de (unknown [195.135.220.254])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id E6C69A38EA
	for <linux-mm@kvack.org>; Mon, 17 Sep 2012 18:35:18 +0200 (CEST)
Date: Mon, 17 Sep 2012 18:35:18 +0200
From: Jan Kara <jack@suse.cz>
Subject: Does swap_set_page_dirty() calling ->set_page_dirty() make sense?
Message-ID: <20120917163518.GD9150@quack.suse.cz>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="ZGiS0Q5IWpPtfppv"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org


--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

  Hi,

  I tripped over a crash in reiserfs which happened due to PageSwapCache
page being passed to reiserfs_set_page_dirty(). Now it's not that hard to
make reiserfs_set_page_dirty() check that case but I really wonder: Does it
make sense to call mapping->a_ops->set_page_dirty() for a PageSwapCache
page? The page is going to be written via direct IO so from the POV of the
filesystem there's no need for any dirtiness tracking. Also there are
several ->set_page_dirty() implementations which will spectacularly crash
because they do things like page->mapping->host, or call
__set_page_dirty_buffers() which expects buffer heads in page->private.
Or what is the reason for calling filesystem's set_page_dirty() function?

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--ZGiS0Q5IWpPtfppv
Content-Type: text/x-patch; charset=us-ascii
Content-Disposition: attachment; filename="0001-mm-Remove-swap_set_page_dirty.patch"


--ZGiS0Q5IWpPtfppv--
