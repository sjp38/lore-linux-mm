Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3E8F56B006C
	for <linux-mm@kvack.org>; Fri,  3 Oct 2014 16:57:40 -0400 (EDT)
Received: by mail-qc0-f170.google.com with SMTP id m20so1688046qcx.15
        for <linux-mm@kvack.org>; Fri, 03 Oct 2014 13:57:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j4si14245717qaf.67.2014.10.03.13.57.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Oct 2014 13:57:39 -0700 (PDT)
Date: Fri, 3 Oct 2014 16:57:23 -0400
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH] mm readahead: Fix sys_readahead breakage by reverting
 2MB limit (bug 79111)
Message-ID: <20141003205722.GB30752@t510.redhat.com>
References: <1404392547-11648-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
 <CA+55aFxOTqUAqEF7+83s890Q18qCHSQqDOxWqWHNjG_25hVhXg@mail.gmail.com>
 <53B59CB5.9060004@linux.vnet.ibm.com>
 <CA+55aFyRgYW6Y8paYKGfqE205enhiPsZ1C8wrKpFavVXq7ZAtA@mail.gmail.com>
 <CA+55aFwwSCrH5QDvrzzyHhRU5R849Mo8A3NdRMwm9OTeWH9diQ@mail.gmail.com>
 <21429.45664.255694.85431@quad.stoffel.home>
 <CA+55aFwhpaTPm+mok0VmypU2T2yvYX=E4hnQwPC4NVdxEzfh0Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwhpaTPm+mok0VmypU2T2yvYX=E4hnQwPC4NVdxEzfh0Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: John Stoffel <john@stoffel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, David Rientjes <rientjes@google.com>, Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Larry Woodman <lwoodman@redhat.com>

On Thu, Jul 03, 2014 at 02:58:54PM -0700, Linus Torvalds wrote:
> On Thu, Jul 3, 2014 at 12:43 PM, John Stoffel <john@stoffel.org> wrote:
> >
> > This is one of those perenial questions of how to tune this.  I agree
> > we should increase the number, but shouldn't it be based on both the
> > amount of memory in the machine, number of devices (or is it all just
> > one big pool?) and the speed of the actual device doing readahead?
> 
> Sure. But I don't trust the throughput data for the backing device at
> all, especially early at boot. We're supposed to work it out for
> writeback over time (based on device contention etc), but I never saw
> that working, and for reading I don't think we have even any code to
> do so.
> 
> And trying to be clever and basing the read-ahead size on the node
> memory size was what caused problems to begin with (with memory-less
> nodes) that then made us just hardcode the maximum.
> 
> So there are certainly better options - in theory. In practice, I
> think we don't really care enough, and the better options are
> questionably implementable.
> 
> I _suspect_ the right number is in that 2-8MB range, and I would
> prefer to keep it at the low end at least until somebody really has
> numbers (and preferably from different real-life situations).
>
> I also suspect that read-ahead is less of an issue with non-rotational
> storage in general, since the only real reason for it tends to be
> latency reduction (particularly the "readahead()" kind of big-hammer
> thing that is really just useful for priming caches). So there's some
> argument to say that it's getting less and less important.
>

I believe you're right, but yet we sort of broke the expectation for
deliberately issued readaheads, and that is what I believe that fellow
complained (poorly worded) at the bugzilla ticket. We recently got the
following report: https://bugzilla.redhat.com/show_bug.cgi?id=1103240
which pretty much is the same thing reported at kernel's BZ. I did some
empirical tests with iozone (forcing madv_willneed behaviour) as well as
I double-checked numbers our performance team got while running their
regression tests and I, honestly, couldn't see any change for better or
worse that could be directly related to the change in question.

Other than setting a hard ceiling of to 2MB for any issued readahead,
which might be seen as trouble for certain users, there seems to be no
other measurable loss here. OTOH, the tangible gain after the change is 
having the readahead working for NUMA layouts where some CPUs are within
a memoryless node.

I believe we could take David's (Rientjes) early suggestion and, instead
of fixing a hard limit on max_sane_readahead(), change it to replace
numa_node_id() by numa_mem_id() calls and follow up the
CONFIG_HAVE_MEMORYLESS_NODES requirements on PPC to have it working
properly (which seems to be the reason that approach was left aside).

Best regards,
-- Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
