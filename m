Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3FACC6B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 19:28:39 -0500 (EST)
Received: by mail-qc0-f173.google.com with SMTP id m20so4145181qcx.4
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 16:28:39 -0800 (PST)
Received: from mail-qc0-x234.google.com (mail-qc0-x234.google.com. [2607:f8b0:400d:c01::234])
        by mx.google.com with ESMTPS id y97si6763558qgd.60.2015.01.22.16.28.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jan 2015 16:28:38 -0800 (PST)
Received: by mail-qc0-f180.google.com with SMTP id r5so4128996qcx.11
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 16:28:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1501221523390.27807@chino.kir.corp.google.com>
References: <20150107172452.GA7922@node.dhcp.inet.fi>
	<20150114152225.GB31484@google.com>
	<20150114233630.GA14615@node.dhcp.inet.fi>
	<alpine.DEB.2.10.1501211452580.2716@chino.kir.corp.google.com>
	<CA+yH71fNZSYVf1G+UUp3N6BhPhT0VJ4aGY=uPGbSD2raV55E3Q@mail.gmail.com>
	<alpine.DEB.2.10.1501221523390.27807@chino.kir.corp.google.com>
Date: Fri, 23 Jan 2015 00:28:38 +0000
Message-ID: <CA+yH71e2ewvA41BNyb=TTPn+yx2zWzY6rn09hRVVgWKoeMgwXQ@mail.gmail.com>
Subject: Re: [PATCH v2 2/2] task_mmu: Add user-space support for resetting
 mm->hiwater_rss (peak RSS)
From: Primiano Tucci <primiano@chromium.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Petr Cermak <petrcermak@chromium.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Bjorn Helgaas <bhelgaas@google.com>, Hugh Dickins <hughd@google.com>

On Thu, Jan 22, 2015 at 11:27 PM, David Rientjes <rientjes@google.com> wrote:
> If you reset the hwm for a process, rss grows to 100MB, another process
> resets the hwm, and you see a hwm of 2MB, that invalidates the hwm
> entirely.

Not sure I follow this scenario. Where does the 2MB come from? How can
you see a hwm of 2MB, under which conditions? HVM can never be < RSS.
Again, what you are talking about is the case of two profilers racing
for using the same interface (hwm).
This is the same case today of the PG_referenced bit.

> The hwm is already defined as the
> highest rss the process has attained, resetting it and trying to make any
> inference from the result is racy and invalidates the actual value which
> is useful.
The counter arugment is: once you have one very high peak, the hvm
becomes essentially useless for the rest of the lifetime of the
process (until a higher peak comes). This makes very hard to
understand what is going on in the meanwhile (from userspace).

Anyways, are you proposing to pursue a different approach? Is the
approach 2. that petrcermark@ proposed in the beginning of the thread
going to address this concern?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
