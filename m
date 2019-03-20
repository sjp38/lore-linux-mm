Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E023C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 04:33:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DDC92175B
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 04:33:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DDC92175B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CAC3D6B0003; Wed, 20 Mar 2019 00:33:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C5BC76B0006; Wed, 20 Mar 2019 00:33:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4B736B0007; Wed, 20 Mar 2019 00:33:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8BDC16B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 00:33:29 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id z123so19872966qka.20
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 21:33:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=1JIHwc8CE0LMo3o6GEKfFP4MbkQC2X9rETKpJRbgjYU=;
        b=A9BfPtC5qYZDWLA5HZRnbGiJFQ6viJ5Hz6Hleb/fntxmScDaUAtRQXZEwieDLFfkVu
         QUKSDfh3w+mjBvajW4MWyX2mH2veSbEQF0ZVYa1eF+gNL5Te3hkayTQz7Xt1N1ZbTbTI
         8lX7sweAXpeFRmNatKA+JoiD9IaCbW+vKpZNJT+zyKQAx6y4TAyt6cSj29c0f2fJww84
         EAqhkwvusNpKeEhFfccOyD/AH0I3nGoYsxdhzQTTg0UVfDuyktvKb5I112bgABjTNOvl
         vOUZgphUv0/Kc22AaTSX11opWWXcLAGDVPjoq6Yhv3DUaISgpodApRXQ/XWwcHfv7T7G
         ZfPA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVDloIiZYS3S13rpNrVQuFkOcg8RRzcnUSm47lrWRU4QBgq1VW9
	qwM5E4UDpSLpdmmHq/iGgbsq0sgKjpMQfbWWQizmYH1Bmh+x7wFmTJbsYKt3HmSeS/8kYzKvjIi
	38Pnm89Xg0vVsB3WUgAlF434Hm15FuK7hZXRHxY/fFGkRKGPVoPBe8E/eOZYv45cITQ==
X-Received: by 2002:ac8:2df8:: with SMTP id q53mr5121290qta.132.1553056409303;
        Tue, 19 Mar 2019 21:33:29 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxXR6Ezr6N88uxQo8hTfR2Gh0jqN30ystQ7uZ7S8kXc9D4DeXa4qGV+sC8hNHy7ZFDhBJ9
X-Received: by 2002:ac8:2df8:: with SMTP id q53mr5121235qta.132.1553056408141;
        Tue, 19 Mar 2019 21:33:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553056408; cv=none;
        d=google.com; s=arc-20160816;
        b=bduftvX+OgPJKY/wkKX6xw2xw0uNEa8QAEYfXK8QFHKl5FLWzfNdeNj5/QV6tD6BwO
         raKrZXGkupyN4lfjeULh2xdQZhohCDwxLXO8jqiOcHFUNmcsgd4h1cSBaAijavwqBvYx
         Q89tROqnx+w1u/IQJ8ZJ3IBlKurlvjI0EhVCXrVitbVpM3y6afu+vjpHfrZMjWeIgaeK
         JzT68NWpX9igK8ckZJXcuM9L7J4yXupLjcHMLBQd/GoUwAGQ+KdbYPeY/23uf7uw+Zic
         LTaXwCexZNAVrKP3lGMe7ukQPwIAQ9wWQzySCHHuUqETiECTAoD55GtuUp9VnPjlFfBi
         1VJA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=1JIHwc8CE0LMo3o6GEKfFP4MbkQC2X9rETKpJRbgjYU=;
        b=p3OqzJG7kMXUZNyQSxWqgzKfvbGms3sSPTimeQB0CrGEDj5a552EPneuKDAUyxS1hp
         riYPyhasJLEvuGcWceeBgq8bNhKBvztg72unUX05PIM7OSJ3owTxbxfqdsMIT/PcAx9a
         r6a1aMnzseLP1jiMLZFRUJ2sddnv1kvHmL4nY2W8/s66qndMGEZJQif6IyHHNaijlrzn
         HvJFkuRkEuBnVFeG2PwYIorH6buzT+Rg4bwVrqYAS/BYpVABkOsK9ZGAUgDNZvrwfg+P
         HVIGdLUaSO8isTdOhov5uq0aCD4ZCMPJ4mxgd3mL9mRiSKO24hrQOglnr1B0y6LTK0x2
         X5YQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g10si378941qvn.144.2019.03.19.21.33.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 21:33:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id B620F81E09;
	Wed, 20 Mar 2019 04:33:26 +0000 (UTC)
Received: from redhat.com (ovpn-120-246.rdu2.redhat.com [10.10.120.246])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 1E74018EC9;
	Wed, 20 Mar 2019 04:33:22 +0000 (UTC)
Date: Wed, 20 Mar 2019 00:33:20 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Dave Chinner <david@fromorbit.com>,
	"Kirill A. Shutemov" <kirill@shutemov.name>, john.hubbard@gmail.com,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Al Viro <viro@zeniv.linux.org.uk>,
	Christian Benvenuti <benve@cisco.com>,
	Christoph Hellwig <hch@infradead.org>,
	Christopher Lameter <cl@linux.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Ralph Campbell <rcampbell@nvidia.com>, Tom Talpey <tom@talpey.com>,
	LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
	Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH v4 1/1] mm: introduce put_user_page*(), placeholder
 versions
Message-ID: <20190320043319.GA7431@redhat.com>
References: <20190308213633.28978-1-jhubbard@nvidia.com>
 <20190308213633.28978-2-jhubbard@nvidia.com>
 <20190319120417.yzormwjhaeuu7jpp@kshutemo-mobl1>
 <20190319134724.GB3437@redhat.com>
 <20190319141416.GA3879@redhat.com>
 <20190319212346.GA26298@dastard>
 <20190319220654.GC3096@redhat.com>
 <20190319235752.GB26298@dastard>
 <20190320000838.GA6364@redhat.com>
 <c854b2d6-5ec1-a8b5-e366-fbefdd9fdd10@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <c854b2d6-5ec1-a8b5-e366-fbefdd9fdd10@nvidia.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Wed, 20 Mar 2019 04:33:27 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 19, 2019 at 06:43:45PM -0700, John Hubbard wrote:
> On 3/19/19 5:08 PM, Jerome Glisse wrote:
> > On Wed, Mar 20, 2019 at 10:57:52AM +1100, Dave Chinner wrote:
> >> On Tue, Mar 19, 2019 at 06:06:55PM -0400, Jerome Glisse wrote:
> >>> On Wed, Mar 20, 2019 at 08:23:46AM +1100, Dave Chinner wrote:
> >>>> On Tue, Mar 19, 2019 at 10:14:16AM -0400, Jerome Glisse wrote:
> >>>>> On Tue, Mar 19, 2019 at 09:47:24AM -0400, Jerome Glisse wrote:
> >>>>>> On Tue, Mar 19, 2019 at 03:04:17PM +0300, Kirill A. Shutemov wrote:
> >>>>>>> On Fri, Mar 08, 2019 at 01:36:33PM -0800, john.hubbard@gmail.com wrote:
> >>>>>>>> From: John Hubbard <jhubbard@nvidia.com>
> >>>>>> [...]
> >>>>> Forgot to mention one thing, we had a discussion with Andrea and Jan
> >>>>> about set_page_dirty() and Andrea had the good idea of maybe doing
> >>>>> the set_page_dirty() at GUP time (when GUP with write) not when the
> >>>>> GUP user calls put_page(). We can do that by setting the dirty bit
> >>>>> in the pte for instance. They are few bonus of doing things that way:
> >>>>>     - amortize the cost of calling set_page_dirty() (ie one call for
> >>>>>       GUP and page_mkclean()
> >>>>>     - it is always safe to do so at GUP time (ie the pte has write
> >>>>>       permission and thus the page is in correct state)
> >>>>>     - safe from truncate race
> >>>>>     - no need to ever lock the page
> >>>>
> >>>> I seem to have missed this conversation, so please excuse me for
> >>>
> >>> The set_page_dirty() at GUP was in a private discussion (it started
> >>> on another topic and drifted away to set_page_dirty()).
> >>>
> >>>> asking a stupid question: if it's a file backed page, what prevents
> >>>> background writeback from cleaning the dirty page ~30s into a long
> >>>> term pin? i.e. I don't see anything in this proposal that prevents
> >>>> the page from being cleaned by writeback and putting us straight
> >>>> back into the situation where a long term RDMA is writing to a clean
> >>>> page....
> >>>
> >>> So this patchset does not solve this issue.
> >>
> >> OK, so it just kicks the can further down the road.
> >>
> >>>     [3..N] decide what to do for GUPed page, so far the plans seems
> >>>          to be to keep the page always dirty and never allow page
> >>>          write back to restore the page in a clean state. This does
> >>>          disable thing like COW and other fs feature but at least
> >>>          it seems to be the best thing we can do.
> >>
> >> So the plan for GUP vs writeback so far is "break fsync()"? :)
> >>
> >> We might need to work on that a bit more...
> > 
> > Sorry forgot to say that we still do write back using a bounce page
> > so that at least we write something to disk that is just a snapshot
> > of the GUPed page everytime writeback kicks in (so either through
> > radix tree dirty page write back or fsync or any other sync events).
> > So many little details that i forgot the big chunk :)
> > 
> > Cheers,
> > Jérôme
> > 
> 
> Dave, Jan, Jerome,
> 
> Bounce pages for periodic data integrity still seem viable. But for the
> question of things like fsync or truncate, I think we were zeroing in
> on file leases as a nice building block.
> 
> Can we revive the file lease discussion? By going all the way out to user
> space and requiring file leases to be coordinated at a high level in the
> software call chain, it seems like we could routinely avoid some of the
> worst conflicts that the kernel code has to resolve.
> 
> For example:
> 
> Process A
> =========
>     gets a lease on file_a that allows gup 
>         usage on a range within file_a
> 
>     sets up writable DMA:
>         get_user_pages() on the file_a range
>         start DMA (independent hardware ops)
>             hw is reading and writing to range
> 
>                                                     Process B
>                                                     =========
>                                                     truncate(file_a)
>                                                        ...
>                                                        __break_lease()
>     
>     handle SIGIO from __break_lease
>          if unhandled, process gets killed
>          and put_user_pages should get called
>          at some point here
> 
> ...and so this way, user space gets to decide the proper behavior,
> instead of leaving the kernel in the dark with an impossible decision
> (kill process A? Block process B? User space knows the preference,
> per app, but kernel does not.)

There is no need to kill anything here ... if truncate happens then
the GUP user is just GUPing page that do not correspond to anything
anymore. This is the current behavior and it is what GUP always has
been. By the time you get the page from GUP there is no garantee that
they correspond to anything.

If a device really want to mirror process address faithfully then the
hardware need to make little effort either have something like ATS/
PASID or be able to abide mmu notifier.

If we start blocking existing syscall just because someone is doing a
GUP we are opening a pandora box. It is not just truncate, it is a
whole range of syscall that deals with either file or virtual address.

The semantic of GUP is really the semantic of direct I/O and the
virtual address you are direct I/O-ing to/from and the rule there is:
do not do anything stupid to those virtual addresses while you are
doing direct I/O with them (no munmap, mremap, madvise, truncate, ...).


Same logic apply to file, when two process do thing to same file there
the kernel never get in the way of one process doing something the
other process did not expect. For instance one process mmaping the file
the other process truncating the file, if the first process try to access
the file through the mmap after the truncation it will get a sigbus.

So i believe best we could do is send a SIGBUS to the process that has
GUPed a range of a file that is being truncated this would match what
we do for CPU acces. There is no reason access through GUP should be
handled any differently.

Cheers,
Jérôme

