Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id B5C146B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 18:27:31 -0500 (EST)
Received: by mail-ig0-f174.google.com with SMTP id b16so23750273igk.1
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 15:27:31 -0800 (PST)
Received: from mail-ig0-x234.google.com (mail-ig0-x234.google.com. [2607:f8b0:4001:c05::234])
        by mx.google.com with ESMTPS id m9si3895011igj.17.2015.01.22.15.27.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jan 2015 15:27:31 -0800 (PST)
Received: by mail-ig0-f180.google.com with SMTP id b16so3726799igk.1
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 15:27:31 -0800 (PST)
Date: Thu, 22 Jan 2015 15:27:29 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 2/2] task_mmu: Add user-space support for resetting
 mm->hiwater_rss (peak RSS)
In-Reply-To: <CA+yH71fNZSYVf1G+UUp3N6BhPhT0VJ4aGY=uPGbSD2raV55E3Q@mail.gmail.com>
Message-ID: <alpine.DEB.2.10.1501221523390.27807@chino.kir.corp.google.com>
References: <20150107172452.GA7922@node.dhcp.inet.fi> <20150114152225.GB31484@google.com> <20150114233630.GA14615@node.dhcp.inet.fi> <alpine.DEB.2.10.1501211452580.2716@chino.kir.corp.google.com>
 <CA+yH71fNZSYVf1G+UUp3N6BhPhT0VJ4aGY=uPGbSD2raV55E3Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Primiano Tucci <primiano@chromium.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Petr Cermak <petrcermak@chromium.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Bjorn Helgaas <bhelgaas@google.com>, Hugh Dickins <hughd@google.com>

On Thu, 22 Jan 2015, Primiano Tucci wrote:

> > I think the bigger concern would be that this, and any new line such as
> > resettable_hiwater_rss, invalidates itself entirely.  Any process that
> > checks the hwm will not know of other processes that reset it, so the
> > value itself has no significance anymore.
> >  It would just be the mark since the last clear at an unknown time.
> 
> How is that different from the current logic of clear_refs and the
> corresponding PG_Referenced bit?
> 

If you reset the hwm for a process, rss grows to 100MB, another process 
resets the hwm, and you see a hwm of 2MB, that invalidates the hwm 
entirely.  That's especially true if there's an oom condition that kills a 
process when the rss grew to 100MB but you see a hwm of 2MB and don't 
believe it was possibly the culprit.  The hwm is already defined as the 
highest rss the process has attained, resetting it and trying to make any 
inference from the result is racy and invalidates the actual value which 
is useful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
