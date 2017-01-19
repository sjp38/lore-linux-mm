Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id C4CC86B0292
	for <linux-mm@kvack.org>; Thu, 19 Jan 2017 06:05:15 -0500 (EST)
Received: by mail-yw0-f198.google.com with SMTP id z143so44095077ywz.7
        for <linux-mm@kvack.org>; Thu, 19 Jan 2017 03:05:15 -0800 (PST)
Received: from bombadil.infradead.org ([65.50.211.133])
        by mx.google.com with ESMTPS id h35si2397115qtb.85.2017.01.19.03.05.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Jan 2017 03:05:15 -0800 (PST)
Date: Thu, 19 Jan 2017 03:05:13 -0800
From: willy@infradead.org
Subject: Re: [ATTEND] many topics
Message-ID: <20170119110513.GA22816@bombadil.infradead.org>
References: <20170118054945.GD18349@bombadil.infradead.org>
 <20170118133243.GB7021@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170118133243.GB7021@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, lsf-pc@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jan 18, 2017 at 02:32:43PM +0100, Michal Hocko wrote:
> On Tue 17-01-17 21:49:45, Matthew Wilcox wrote:
> [...]
> > 8. Nailing down exactly what GFP_TEMPORARY means
> 
> It's a hint that the page allocator should group those pages together
> for better fragmentation avoidance. Have a look at e12ba74d8ff3 ("Group
> short-lived and reclaimable kernel allocations"). Basically it is
> something like __GFP_MOVABLE for kernel allocations which cannot go to
> the movable zones.

Let me rephrase the topic ... Under what conditions should somebody use
the GFP_TEMPORARY gfp_t?

Example usages that I have questions about:

1. Is it permissible to call kmalloc(GFP_TEMPORARY), or is it only
for alloc_pages?  I ask because if the slab allocator is unaware of
GFP_TEMPORARY, then a non-GFP_TEMPORARY allocation may be placed in a
page allocated with GFP_TEMPORARY and we've just made it meaningless.

2. Is it permissible to sleep while holding a GFP_TEMPORARY allocation?
eg, take a mutex, or wait_for_completion()?

3. Can I make one GFP_TEMPORARY allocation, and then another one?

4. Should I disable preemption while holding a GFP_TEMPORARY allocation,
or are we OK with a task being preempted?

5. What about something even longer duration like allocating a kiocb?
That might take an arbitrary length of time to be freed, but eventually
the command will be timed out (eg 30 seconds for something that ends up
going through SCSI).

6. Or shorter duration like doing a GFP_TEMPORARY allocation, then taking
a spinlock, which *probably* isn't contended, but you never know.

7. I can see it includes __GFP_WAIT so it's not suitable for using from
interrupt context, but interrupt context might be the place which can
benefit from it the most.  Or does GFP_ATOMIC's __GFP_HIGH also allow for
allocation from the movable zone?  Should we have a GFP_TEMPORARY_ATOMIC?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
