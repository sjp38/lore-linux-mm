Message-ID: <45FA1864.9010909@redhat.com>
Date: Fri, 16 Mar 2007 00:09:08 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/filemap.c: unconditionally call mark_page_accessed
References: <Pine.GSO.4.64.0703081612290.1080@cpu102.cs.uwaterloo.ca> <20070312142012.GH30777@atrey.karlin.mff.cuni.cz> <20070312143900.GB6016@wotan.suse.de> <20070312151355.GB23532@duck.suse.cz> <Pine.GSO.4.64.0703121247210.7679@cpu102.cs.uwaterloo.ca> <20070312173500.GF23532@duck.suse.cz> <Pine.GSO.4.64.0703131438580.8193@cpu102.cs.uwaterloo.ca> <20070313185554.GA5105@duck.suse.cz> <Pine.GSO.4.64.0703141218530.28958@cpu102.cs.uwaterloo.ca> <1173905741.8763.36.camel@kleikamp.austin.ibm.com> <20070314213317.GA22234@rhlx01.hs-esslingen.de> <200703151737.l2FHb81d001600@turing-police.cc.vt.edu>            <45F991E5.1060001@redhat.com> <200703160351.l2G3p3GJ020217@turing-police.cc.vt.edu>
In-Reply-To: <200703160351.l2G3p3GJ020217@turing-police.cc.vt.edu>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Valdis.Kletnieks@vt.edu
Cc: Andreas Mohr <andi@rhlx01.fht-esslingen.de>, Dave Kleikamp <shaggy@linux.vnet.ibm.com>, Ashif Harji <asharji@cs.uwaterloo.ca>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Jan Kara <jack@suse.cz>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Valdis.Kletnieks@vt.edu wrote:

> On the other hand, Andreas suggested only marking it once every 32 calls,
> but that required a helper variable.  Statistically, jiffies%32 should
> end up about the same as a helper variable %32.
> 
> This of course, if just calling mark_page_accessed() is actually expensive
> enough that we don't want to do it unconditionally.

Not caching a needed page and having to wait for a disk seek
to complete will be *way* more expensive than any call to
mark_page_accessed().

A modern CPU can do somewhere on the order of 50 million
instructions in the time it takes to bring one page in from
disk.

However, this does not mean we should unconditionally call
mark_page_accessed(), since that could cause use to push
wanted data out of the cache because of one program that
does its streaming accesses in a strange way...

This is a situation where getting it right almost certainly
matters.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
