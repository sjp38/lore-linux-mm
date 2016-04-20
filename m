Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f200.google.com (mail-yw0-f200.google.com [209.85.161.200])
	by kanga.kvack.org (Postfix) with ESMTP id 43E696B0266
	for <linux-mm@kvack.org>; Wed, 20 Apr 2016 04:31:46 -0400 (EDT)
Received: by mail-yw0-f200.google.com with SMTP id v81so81166662ywa.1
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 01:31:46 -0700 (PDT)
Received: from mail-qg0-x22b.google.com (mail-qg0-x22b.google.com. [2607:f8b0:400d:c04::22b])
        by mx.google.com with ESMTPS id o66si54662863qgd.91.2016.04.20.01.31.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Apr 2016 01:31:45 -0700 (PDT)
Received: by mail-qg0-x22b.google.com with SMTP id f74so21470594qge.2
        for <linux-mm@kvack.org>; Wed, 20 Apr 2016 01:31:45 -0700 (PDT)
Date: Wed, 20 Apr 2016 01:31:42 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCHv7 00/29] THP-enabled tmpfs/shmem using compound pages
In-Reply-To: <571565F0.9070203@linaro.org>
Message-ID: <alpine.LSU.2.11.1604200114440.3009@eggly.anvils>
References: <1460766240-84565-1-git-send-email-kirill.shutemov@linux.intel.com> <571565F0.9070203@linaro.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Shi, Yang" <yang.shi@linaro.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-arm-kernel@lists.infradead.org

On Mon, 18 Apr 2016, Shi, Yang wrote:

> Hi Kirill,
> 
> Finally, I got some time to look into and try yours and Hugh's patches, got

Thank you.

> two problems.
> 
> 1. A quick boot up test on my ARM64 machine with your v7 tree shows some
> unexpected error:
> 
> systemd-journald[285]: Failed to save stream data
> /run/systemd/journal/streams/8:16863: No space left on device
> systemd-journald[285]: Failed to save stream data
> /run/systemd/journal/streams/8:16865: No space left on device
>          Starting DNS forwarder and DHCP server.systemd-journald[285]: Failed
> to save stream data /run/systemd/journal/streams/8:16867: No space left on
> device
> ..
> systemd-journald[285]: Failed to save stream data
> /run/systemd/journal/streams/8:16869: No space left on device
>          Starting Postfix Mail Transport Agent...
> systemd-journald[285]: Failed to save stream data
> /run/systemd/journal/streams/8:16871: No space left on device
>          Starting Berkeley Internet Name Domain (DNS)...
>          Starting Wait for Network to be Configured...
> systemd-journald[285]: Failed to save stream data
> /run/systemd/journal/streams/8:2422: No space left on device
> [  OK  ] Started /etc/rc.local Compatibility.
> [FAILED] Failed to start DNS forwarder and DHCP server.
> See 'systemctl status dnsmasq.service' for details.
> systemd-journald[285]: Failed to save stream data
> /run/systemd/journal/streams/8:2425: No space left on device
> [  OK  ] Started Serial Getty on ttyS1.
> [  OK  ] Started Serial Getty on ttyS0.
> [  OK  ] Started Getty on tty1.
> systemd-journald[285]: Failed to save stream data
> /run/systemd/journal/streams/8:2433: No space left on device
> [FAILED] Failed to start Berkeley Internet Name Domain (DNS).
> See 'systemctl status named.service' for details.

Expected behaviour: that is a significant limitation of Kirill's current
implementation.  We have agreed at LSF/MM that he will fix that before
his patchset goes further.  (And different changes needed in my patchset.)

> 
> 
> The /run dir is mounted as tmpfs.
> 
> x86 boot doesn't get such error. And, Hugh's patches don't have such problem.
> 
> 2. I ran my THP test (generated a program with 4MB text section) on both
> x86-64 and ARM64 with yours and Hugh's patches (linux-next tree), I got the
> program execution time reduced by ~12% on x86-64, it looks very impressive.

12% sounds about right for x86.  Some loads have been seen to benefit 17%.

> 
> But, on ARM64, there is just ~3% change, and sometimes huge tmpfs may show
> even worse data than non-hugepage.
> 
> Both yours and Hugh's patches has the same behavior.
> 
> Any idea?

... and in a later posting..,

> 
> It would be better if Kirill and Hugh could share what benchmark they ran and
> how much they got improved since my test case is very simple and may just
> cover a small part of it.

Sorry, I've not run any benchmark myself (prefer to let others get more
objective results), nor run on arm64.  I have no idea what to expect on
arm64 - you need to ask the arm64 guys what hugepage advantage they see
with anon THP or hugetlbfs (and probably need to tell them what machine
you're running on): then expect a similar advantage from either Kirill's
or my huge tmpfs patchset.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
