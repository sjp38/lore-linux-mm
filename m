Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7C76B0089
	for <linux-mm@kvack.org>; Tue, 21 Dec 2010 00:08:06 -0500 (EST)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id oBL582Kv024612
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 21:08:02 -0800
Received: from pxi4 (pxi4.prod.google.com [10.243.27.4])
	by kpbe19.cbf.corp.google.com with ESMTP id oBL57w1I019526
	for <linux-mm@kvack.org>; Mon, 20 Dec 2010 21:08:01 -0800
Received: by pxi4 with SMTP id 4so932835pxi.16
        for <linux-mm@kvack.org>; Mon, 20 Dec 2010 21:07:58 -0800 (PST)
Date: Mon, 20 Dec 2010 21:07:51 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC 0/5] Change page reference hanlding semantic of page
 cache
In-Reply-To: <AANLkTikss0RW_xRrD_vVvfqy1rH+NC=WPUB2qKBaw5qo@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1012202048220.15447@tigran.mtv.corp.google.com>
References: <cover.1292604745.git.minchan.kim@gmail.com> <20101220103307.GA22986@infradead.org> <AANLkTikss0RW_xRrD_vVvfqy1rH+NC=WPUB2qKBaw5qo@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Dec 2010, Minchan Kim wrote:
> On Mon, Dec 20, 2010 at 7:33 PM, Christoph Hellwig <hch@infradead.org> wrote:
> > You'll need to merge all patches into one, otherwise you create really
> > nasty memory leaks when bisecting between them.
> >
> 
> Okay. I will resend.
> 
> Thanks for the notice, Christoph.

Good point from hch, but I feel even more strongly: if you're going to
do this now, please rename remove_from_page_cache (delete_from_page_cache
was what I chose back when I misdid it) - you're changing an EXPORTed
function in a subtle (well, subtlish) confusing way, which could easily
waste people's time down the line, whether in not-yet-in-tree filesystems
or backports of fixes.  I'd much rather you break someone's build,
forcing them to look at what changed, than crash or leak at runtime.

If you do rename, you can keep your patch structure, introducing the
new function as a wrapper to the old at the beginning, then removing
the old function at the end.

(As you know, I do agree that it's right to decrement the reference
count at the point of removing from page cache.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
