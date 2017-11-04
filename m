Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f198.google.com (mail-ua0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 206F56B0033
	for <linux-mm@kvack.org>; Sat,  4 Nov 2017 05:55:36 -0400 (EDT)
Received: by mail-ua0-f198.google.com with SMTP id e46so3060153uaa.6
        for <linux-mm@kvack.org>; Sat, 04 Nov 2017 02:55:36 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k2sor2868687uad.249.2017.11.04.02.55.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 04 Nov 2017 02:55:35 -0700 (PDT)
MIME-Version: 1.0
From: Maxim Levitsky <maximlevitsky@gmail.com>
Date: Sat, 4 Nov 2017 11:55:14 +0200
Message-ID: <CACAwPwY0owut+314c5sy7jNViZqfrKy3sSf1hjLTocXefrz3xA@mail.gmail.com>
Subject: Guaranteed allocation of huge pages (1G) using movablecore=N doesn't
 seem to work at all
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org

Hi!

My system has 64G of ram and I want to create 32 1G huge pages to use
in KVM virtualization,
on demand, only when VM is running.

So I booted the kernel with
'hugepagesz=1G hugepages=0 default_hugepagesz=1G movablecore=40G'

However I still can't allocate the pages reliably.
For instance this simple script is enough to make it not possible to
even allocate one 1G huge page after few dozens of iterations:

while true ; do
    sudo hugeadm  --enable-zone-movable  --pool-pages-min 1G:0G
    sudo hugeadm  --enable-zone-movable  --pool-pages-min 1G:60G
done


I disabled mlock systemwide (now ulimit -l shows 0), I still see 8
pages mlocked in  zone 'Movable' but this is not enough to explain
this
nr_mlock     8

I do have around 64GB of swap too, but I see no even an attempt to use it.

# free
              total        used        free      shared  buff/cache   available
Mem:       65887928     1748344    62640276       61688     1499308    62053832
Swap:      67108860           0    67108860

Any idea about what is going on?

This was tested on 4.14.0-rc5 (my custom compiled) and on several
older kernels (4.10,4.12,4.13) from ubuntu repositories.

Disabling/enabling transparent huge pages in the kernel config didn't
make a difference.

VT-d was enabled during the tests (intel_iommu=on,igfx_off) if that
would make any difference, but no VM was started when I run the above
script, in fact I run it just after the system booted.

Best regards,
          Maxim Levitsky

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
