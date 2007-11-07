Date: Tue, 6 Nov 2007 22:00:45 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [RFC PATCH 6/10] split anon and file LRUs
Message-ID: <20071106220045.2a8a189f@bree.surriel.com>
In-Reply-To: <Pine.LNX.4.64.0711061825590.5249@schroedinger.engr.sgi.com>
References: <20071103184229.3f20e2f0@bree.surriel.com>
	<20071103190158.34b4650e@bree.surriel.com>
	<Pine.LNX.4.64.0711061825590.5249@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Nov 2007 18:28:19 -0800 (PST)
Christoph Lameter <clameter@sgi.com> wrote:
> On Sat, 3 Nov 2007, Rik van Riel wrote:
> 
> > Split the LRU lists in two, one set for pages that are backed by
> > real file systems ("file") and one for pages that are backed by
> > memory and swap ("anon").  The latter includes tmpfs.
> 
> If we split the memory backed from the disk backed pages then
> they are no longer competing with one another on equal terms? So the file LRU 
> may run faster than the memory LRU?

The file LRU probably *should* run faster than the memory LRU most
of the time, since we stream the readahead data for many sequentially
accessed files through the file LRU.

We adjust the rates at which the two LRUs are scanned depending on
the fraction of referenced pages found when scanning each list.
Look at vmscan.c:get_scan_ratio() for the magic.

> The patch looks awfully large.

Making it smaller would probably result in something that does
not work right.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
