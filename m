Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f175.google.com (mail-ve0-f175.google.com [209.85.128.175])
	by kanga.kvack.org (Postfix) with ESMTP id CEC496B0031
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 17:58:55 -0400 (EDT)
Received: by mail-ve0-f175.google.com with SMTP id jx11so874837veb.20
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 14:58:55 -0700 (PDT)
Received: from mail-ve0-x232.google.com (mail-ve0-x232.google.com [2607:f8b0:400c:c01::232])
        by mx.google.com with ESMTPS id v15si14747602vei.0.2014.07.03.14.58.54
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 03 Jul 2014 14:58:54 -0700 (PDT)
Received: by mail-ve0-f178.google.com with SMTP id oy12so883119veb.23
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 14:58:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <21429.45664.255694.85431@quad.stoffel.home>
References: <1404392547-11648-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
	<CA+55aFxOTqUAqEF7+83s890Q18qCHSQqDOxWqWHNjG_25hVhXg@mail.gmail.com>
	<53B59CB5.9060004@linux.vnet.ibm.com>
	<CA+55aFyRgYW6Y8paYKGfqE205enhiPsZ1C8wrKpFavVXq7ZAtA@mail.gmail.com>
	<CA+55aFwwSCrH5QDvrzzyHhRU5R849Mo8A3NdRMwm9OTeWH9diQ@mail.gmail.com>
	<21429.45664.255694.85431@quad.stoffel.home>
Date: Thu, 3 Jul 2014 14:58:54 -0700
Message-ID: <CA+55aFwhpaTPm+mok0VmypU2T2yvYX=E4hnQwPC4NVdxEzfh0Q@mail.gmail.com>
Subject: Re: [PATCH] mm readahead: Fix sys_readahead breakage by reverting 2MB
 limit (bug 79111)
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stoffel <john@stoffel.org>
Cc: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, Jan Kara <jack@suse.cz>, David Rientjes <rientjes@google.com>, Nishanth Aravamudan <nacc@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Jul 3, 2014 at 12:43 PM, John Stoffel <john@stoffel.org> wrote:
>
> This is one of those perenial questions of how to tune this.  I agree
> we should increase the number, but shouldn't it be based on both the
> amount of memory in the machine, number of devices (or is it all just
> one big pool?) and the speed of the actual device doing readahead?

Sure. But I don't trust the throughput data for the backing device at
all, especially early at boot. We're supposed to work it out for
writeback over time (based on device contention etc), but I never saw
that working, and for reading I don't think we have even any code to
do so.

And trying to be clever and basing the read-ahead size on the node
memory size was what caused problems to begin with (with memory-less
nodes) that then made us just hardcode the maximum.

So there are certainly better options - in theory. In practice, I
think we don't really care enough, and the better options are
questionably implementable.

I _suspect_ the right number is in that 2-8MB range, and I would
prefer to keep it at the low end at least until somebody really has
numbers (and preferably from different real-life situations).

I also suspect that read-ahead is less of an issue with non-rotational
storage in general, since the only real reason for it tends to be
latency reduction (particularly the "readahead()" kind of big-hammer
thing that is really just useful for priming caches). So there's some
argument to say that it's getting less and less important.

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
