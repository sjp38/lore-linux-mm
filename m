Date: Wed, 16 Apr 2008 20:00:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Warning on memory offline (and possible in usual migration?)
Message-Id: <20080416200036.2ea9b5c2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0804141044030.6296@schroedinger.engr.sgi.com>
References: <20080414145806.c921c927.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0804141044030.6296@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, npiggin@suse.de, Andrew Morton <akpm@linux-foundation.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 14 Apr 2008 10:46:47 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Mon, 14 Apr 2008, KAMEZAWA Hiroyuki wrote:
> 
> > Then, "page" is not Uptodate when it reaches (*).
> 
> The page will be marked uptodate before we reach ** so its okay in
> general. If a page is not uptodate then we should not be getting here.
> 
> An !uptodate page is not migratable. Maybe we need to add better checking?
> 
> 
With tons of printk, I think I found when it happens.

Assume I use ia64/PAGE_SIZE=16k and ext3's blocksize=4k.
A page has 4 buffer_heads.

Assume that a page is not Uptodate before issuing write_begin()

At the end of writing to ext3, the kernel reaches here.
==
static int __block_commit_write(struct inode *inode, struct page *page,
                unsigned from, unsigned to)
{
    int patrial=0;

    if (!All_buffers_to_this_page_is_uptodate)
	partial = 1
    if (!partial)
        SetPageUptodate(page)
}
==
To set a page as Uptodate, all buffers must be uptodate.

But *all* buffers to this page is not necessary to be uptodate, here. 
Then, the page can be not-up-to-date after commit-write.

At page offlining, all buffers on the page seems to be marked as Uptodate
(by printk) but the page itself isn't. This seems strange.

But I don't found who set Uptodate to the buffers. 
And why page isn't up-to-date while all buffers are marked as up-to-date.

still chasing.

Thanks,
-Kame







--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
