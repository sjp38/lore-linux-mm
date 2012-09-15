Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 4EAAA6B005D
	for <linux-mm@kvack.org>; Sat, 15 Sep 2012 13:38:00 -0400 (EDT)
Date: Sat, 15 Sep 2012 19:37:53 +0200
From: Petr Holasek <pholasek@redhat.com>
Subject: Re: [PATCH v3] KSM: numa awareness sysfs knob
Message-ID: <20120915173752.GA10698@stainedmachine.redhat.com>
References: <1347657767-1912-1-git-send-email-pholasek@redhat.com>
 <20120914150248.59e9757d.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120914150248.59e9757d.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@sous-sol.org>, Izik Eidus <izik.eidus@ravellosystems.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Anton Arapov <anton@redhat.com>

On Fri, 14 Sep 2012, Andrew Morton wrote:

Hi Andrew,

at first thanks for your review!

> On Fri, 14 Sep 2012 23:22:47 +0200
> Petr Holasek <pholasek@redhat.com> wrote:
> 
> > Introduces new sysfs boolean knob /sys/kernel/mm/ksm/merge_nodes
> 
> I wonder if merge_across_nodes would be a better name.
> 

Agreed.

> > which control merging pages across different numa nodes.
> > When it is set to zero only pages from the same node are merged,
> > otherwise pages from all nodes can be merged together (default behavior).
> > 
> > Typical use-case could be a lot of KVM guests on NUMA machine
> > and cpus from more distant nodes would have significant increase
> > of access latency to the merged ksm page. Sysfs knob was choosen
> > for higher scalability.
> 
> Well...  what is the use case for merge_nodes=0?  IOW, why shouldn't we
> make this change non-optional and avoid the sysfs knob?

I assume that there are still some users who want to use KSM mainly for
saving of physical memory and access latency is not priority for them.

> > 
> > This patch also adds share_all sysfs knob which can be used for adding
> > all anon vmas of all processes in system to ksmd scan queue. Knob can be
> > triggered only when run knob is set to zero.
> 
> I really don't understand this share_all thing.  From reading the code,
> it is a once-off self-resetting trigger thing.  Why?  How is one to use
> this?  What's the benefit?  What's the effect?

I introduced it on the basis of our discussion about v2 patch
https://lkml.org/lkml/2012/6/29/426 as some knob which can madvise all anon
mappings with MADV_MERGEABLE. But I might have misunderstood your idea.
If you don't like current self-resetting trigger we either can implement it
as stable 0/1 knob that would madvise all current and future anon mappings
when set to 1 or completely exclude this share_all thing from the patch.

I am going to fix all all mistakes you pointed out in your review as well as
add more verbose documentation and comments in next version.

thanks,
Petr H

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
