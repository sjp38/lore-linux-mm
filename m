Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 356596B0035
	for <linux-mm@kvack.org>; Wed, 19 Feb 2014 18:08:20 -0500 (EST)
Received: by mail-qc0-f172.google.com with SMTP id r5so1979787qcx.31
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 15:08:19 -0800 (PST)
Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net. [2001:4b98:c:538::196])
        by mx.google.com with ESMTPS id y1si630197qce.115.2014.02.19.15.08.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 19 Feb 2014 15:08:19 -0800 (PST)
Date: Wed, 19 Feb 2014 15:08:09 -0800
From: Josh Triplett <josh@joshtriplett.org>
Subject: Re: [OPW kernel] Re: [RFC] mm:prototype for the updated swapoff
 implementation
Message-ID: <20140219230809.GA8221@jtriplet-mobl1>
References: <20140219003522.GA8887@kelleynnn-virtual-machine>
 <20140219132757.58b61f07bad914b3848275e9@linux-foundation.org>
 <530524A3.6090700@surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <530524A3.6090700@surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@surriel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Kelley Nielsen <kelleynnn@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, opw-kernel@googlegroups.com, jamieliu@google.com, sjenning@linux.vnet.ibm.com, Hugh Dickins <hughd@google.com>

On Wed, Feb 19, 2014 at 04:39:47PM -0500, Rik van Riel wrote:
> On 02/19/2014 04:27 PM, Andrew Morton wrote:
> > On Tue, 18 Feb 2014 16:35:22 -0800 Kelley Nielsen <kelleynnn@gmail.com> wrote:
> > 
> >> The function try_to_unuse() is of quadratic complexity, with a lot of
> >> wasted effort. It unuses swap entries one by one, potentially iterating
> >> over all the page tables for all the processes in the system for each
> >> one.
> >>
> >> This new proposed implementation of try_to_unuse simplifies its
> >> complexity to linear. It iterates over the system's mms once, unusing
> >> all the affected entries as it walks each set of page tables. It also
> >> makes similar changes to shmem_unuse.
> >>
> >> Improvement
> >>
> >> swapoff was called on a swap partition containing about 50M of data,
> >> and calls to the function unuse_pte_range were counted.
> >>
> >> Present implementation....about 22.5M calls.
> >> Prototype.................about  7.0K   calls.
> > 
> > Do you have situations in which swapoff is taking an unacceptable
> > amount of time?  If so, please update the changelog to provide full
> > details on this, with before-and-after timing measurements.
> 
> I have seen plenty of that.  With just a few GB in swap space in
> use, on a system with 24GB of RAM, and about a dozen GB in use
> by various processes, I have seen swapoff take several hours of
> CPU time.

And it's clear what the lower bound on swapoff should be: current amount
of swap in use, divided by maximum disk write speed.  We're definitely
not to *that* point yet; this ought to get us a lot closer.

- Josh Triplett

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
