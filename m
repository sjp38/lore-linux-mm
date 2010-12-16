Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 244336B00AD
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 19:26:26 -0500 (EST)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id oBG0QMnp024002
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 16:26:22 -0800
Received: from yws5 (yws5.prod.google.com [10.192.19.5])
	by hpaq13.eem.corp.google.com with ESMTP id oBG0Q5hN018993
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 16:26:21 -0800
Received: by yws5 with SMTP id 5so2165404yws.15
        for <linux-mm@kvack.org>; Wed, 15 Dec 2010 16:26:20 -0800 (PST)
Date: Wed, 15 Dec 2010 16:26:11 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: kernel BUG at mm/truncate.c:475!
In-Reply-To: <E1PSpQw-0005s5-QW@pomaz-ex.szeredi.hu>
Message-ID: <alpine.LSU.2.00.1012151542480.7987@tigran.mtv.corp.google.com>
References: <20101130194945.58962c44@xenia.leun.net> <alpine.LSU.2.00.1011301453090.12516@tigran.mtv.corp.google.com> <E1PNjsI-0005Bk-NB@pomaz-ex.szeredi.hu> <20101201124528.6809c539@xenia.leun.net> <E1PNqO1-0005px-9h@pomaz-ex.szeredi.hu>
 <20101202084159.6bff7355@xenia.leun.net> <20101202091552.4a63f717@xenia.leun.net> <E1PO5gh-00079U-Ma@pomaz-ex.szeredi.hu> <20101202115722.1c00afd5@xenia.leun.net> <20101203085350.55f94057@xenia.leun.net> <E1PPaIw-0004pW-Mk@pomaz-ex.szeredi.hu>
 <20101206204303.1de6277b@xenia.leun.net> <E1PRQDn-0007jZ-5S@pomaz-ex.szeredi.hu> <20101213142059.643f8080.akpm@linux-foundation.org> <E1PSSO8-0003sy-Vr@pomaz-ex.szeredi.hu> <alpine.LSU.2.00.1012142020030.12693@tigran.mtv.corp.google.com>
 <E1PSpQw-0005s5-QW@pomaz-ex.szeredi.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: akpm@linux-foundation.org, robert@swiecki.net, lkml20101129@newton.leun.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Dec 2010, Miklos Szeredi wrote:
> On Tue, 14 Dec 2010, Hugh Dickins wrote:
> > I'd feel rather happier about it if I thought it would also fix
> > Robert's kernel BUG at /build/buildd/linux-2.6.35/mm/filemap.c:128!
> > but I've still not found time to explain that one.
> 
> Me neither, all unmap_mapping_range() calls from shmfs are either with
> i_mutex or from evict_inode.

And the page returned by shmem_fault is already locked.

> 
> Hmm, is there anything preventing remap_file_pages() installing a pte
> at an address that unmap_mapping_range() has already processed?

Interesting line of thought: nothing I think, but isn't that okay?

Though its zap_pte can take out present ptes pointing to actual pages,
all populate_range ever installs is non-present pte_file entries: and a
fault on one of those goes through the same checks as in a linear mapping.

(I thought I was going to find an inconsistency with zap_pte_range there,
but no: truncation does not remove pte_file entries beyond end of file,
I remember now thinking that we need to keep SIGBUS-beyond-EOF on them,
instead of letting truncation silently revert those offsets to linear.)

Or am I missing something?
(Well, we know I am, because I've not explained Robert's BUG.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
