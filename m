Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f182.google.com (mail-ie0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id 9925E6B00B0
	for <linux-mm@kvack.org>; Tue,  6 Jan 2015 03:47:21 -0500 (EST)
Received: by mail-ie0-f182.google.com with SMTP id x19so1626159ier.13
        for <linux-mm@kvack.org>; Tue, 06 Jan 2015 00:47:21 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w3si6899002igl.34.2015.01.06.00.47.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jan 2015 00:47:20 -0800 (PST)
Date: Tue, 6 Jan 2015 00:47:14 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v12 00/20] DAX: Page cache bypass for filesystems on
 memory storage
Message-Id: <20150106004714.6d63023c.akpm@linux-foundation.org>
In-Reply-To: <20150105184143.GA665@infradead.org>
References: <1414185652-28663-1-git-send-email-matthew.r.wilcox@intel.com>
	<20141210140347.GA23252@infradead.org>
	<20141210141211.GD2220@wil.cx>
	<20150105184143.GA665@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Milosz Tanski <milosz@adfin.com>

On Mon, 5 Jan 2015 10:41:43 -0800 Christoph Hellwig <hch@infradead.org> wrote:

> On Wed, Dec 10, 2014 at 09:12:11AM -0500, Matthew Wilcox wrote:
> > On Wed, Dec 10, 2014 at 06:03:47AM -0800, Christoph Hellwig wrote:
> > > What is the status of this patch set?
> > 
> > I have no outstanding bug reports against it.  Linus told me that he
> > wants to see it come through Andrew's tree.  I have an email two weeks
> > ago from Andrew saying that it's on his list.  I would love to see it
> > merged since it's almost a year old at this point.
> 
> And since then another month and aother merge window has passed.  Is
> there any way to speed up merging big patch sets like this one?

I took a look at dax last time and found it to be unreviewable due to
lack of design description, objectives and code comments.  Hopefully
that's been addressed - I should get back to it fairly soon as I chew
through merge window and holiday backlog.

> Another one is non-blocking read one that has real life use on one
> of the biggest server side webapp frameworks but doesn't seem to make
> progress, which is a bit frustrating.

I took a look at pread2() as well and I have two main issues:

- The patchset includes a pwrite2() syscall which has nothing to do
  with nonblocking reads and which was poorly described and had little
  justification for inclusion.

- We've talked for years about implementing this via fincore+pread
  and at least two fincore implementations are floating about.  Now
  along comes pread2() which does it all in one hit.

  Which approach is best?  I expect fincore+pread is simpler, more
  flexible and more maintainable.  But pread2() will have lower CPU
  consumption and lower average-case latency.

  But how *much* better is pread2()?  I expect the difference will be
  minor because these operations are associated with a great big
  cache-stomping memcpy.  If the pread2() advantage is "insignificant
  for real world workloads" then perhaps it isn't the best way to go.

  I just don't know, and diligence requires that we answer the
  question.  But all I've seen in response to these questions is
  handwaving.  It would be a shame to make a mistake because nobody
  found the time to perform the investigation.

Also, integration of pread2() into xfstests is (or was) happening and
the results of that aren't yet known.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
