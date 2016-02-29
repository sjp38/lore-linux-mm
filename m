Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id B697A6B0005
	for <linux-mm@kvack.org>; Mon, 29 Feb 2016 11:28:37 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id p65so76315594wmp.1
        for <linux-mm@kvack.org>; Mon, 29 Feb 2016 08:28:37 -0800 (PST)
Received: from mail2-relais-roc.national.inria.fr (mail2-relais-roc.national.inria.fr. [192.134.164.83])
        by mx.google.com with ESMTPS id p8si15756202wmb.73.2016.02.29.08.28.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Feb 2016 08:28:36 -0800 (PST)
Date: Mon, 29 Feb 2016 17:28:35 +0100
From: Samuel Thibault <samuel.thibault@ens-lyon.org>
Subject: Costless huge virtual memory? /dev/same, /dev/null?
Message-ID: <20160229162835.GA2816@var.bordeaux.inria.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello,

I'm wondering whether we could introduce a /dev/same device to allow
costless huge virtual memory.

The use case is the simulation of the execution of a big irregular HPC
application, to provision memory usage, cpu time, etc. We know how much
time each computation loop takes, and it's easy to replace them with a
mere accounting. We'd however like to avoid having to revamp the rest
of the code, which does allocation/memcpys/etc., by just replacing
the allocation calls with virtual allocations, i.e. allocations which
return addresses of buffers that one can read/write, but the values you
read are not necessarily what you wrote, i.e. the data is not actually
properly stored (since we don't do the actual computations that's not a
problem).

The way we currently do this is by some folding: we map the same normal
file several times contiguously to form the virtual allocation. By using
a small 1MiB file, this limits memory consumption to 1MiB plus the page
table (and fits the dumb data in a typical cache). This however creates
one VMA per file mapping, we get limited by the 65535 VMA limit, and
VMA lookup becomes slow.

The way I could see is to have a /dev/same device: when you open it, it
allocates one page. When you mmap it, it maps the same page over the
whole resulting single VMA.

This is a quite specific use case, but it seems to be easy to implement,
and it seems to me that it could be integrated mainline. Actually I was
thinking that /dev/null itself could be providing that service?
(currently it returns ENODEV)

What do people think?  Is there perhaps another solution to achieve this
that I didn't think about?

Samuel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
