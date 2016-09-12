Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 20D9F6B0038
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 03:51:33 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ag5so326078873pad.2
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 00:51:33 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id yv3si20402193pab.56.2016.09.12.00.51.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 00:51:32 -0700 (PDT)
Date: Mon, 12 Sep 2016 00:51:28 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: DAX mapping detection (was: Re: [PATCH] Fix region lost in
 /proc/self/smaps)
Message-ID: <20160912075128.GB21474@infradead.org>
References: <CAPcyv4iDra+mRqEejfGqapKEAFZmUtUcg0dsJ8nt7mOhcT-Qpw@mail.gmail.com>
 <20160908225636.GB15167@linux.intel.com>
 <20160912052703.GA1897@infradead.org>
 <CAOSf1CHaW=szD+YEjV6vcUG0KKr=aXv8RXomw9xAgknh_9NBFQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOSf1CHaW=szD+YEjV6vcUG0KKr=aXv8RXomw9xAgknh_9NBFQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oliver O'Halloran <oohall@gmail.com>
Cc: Christoph Hellwig <hch@infradead.org>, Yumei Huang <yuhuang@redhat.com>, Michal Hocko <mhocko@suse.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, KVM list <kvm@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Gleb Natapov <gleb@kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@ml01.01.org>, mtosatti@redhat.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dave Hansen <dave.hansen@intel.com>, Stefan Hajnoczi <stefanha@redhat.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Paolo Bonzini <pbonzini@redhat.com>

On Mon, Sep 12, 2016 at 05:25:15PM +1000, Oliver O'Halloran wrote:
> What are the problems here? Is this a matter of existing filesystems
> being unable/unwilling to support this or is it just fundamentally
> broken?

It's a fundamentally broken model.  See Dave's post that actually was
sent slightly earlier then mine for the list of required items, which
is fairly unrealistic.  You could probably try to architect a file
system for it, but I doubt it would gain much traction.

> The end goal is to let applications manage the persistence of
> their own data without having to involve the kernel in every IOP, but
> if we can't do that then what would a 90% solution look like? I think
> most people would be OK with having to do an fsync() occasionally, but
> not after ever write to pmem.

You need an fsync for each write that you want to persist.  This sounds
painful for now.  But I have an implementation that will allow the
atomic commit of more or less arbitrary amounts of previous writes for
XFS that I plan to land once the reflink work is in.

That way you create almost arbitrarily complex data structures in your
programs and commit them atomicly.  It's not going to fit the nvml
model, but that whole think has been complete bullshit since the
beginning anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
