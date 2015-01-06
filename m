Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f175.google.com (mail-ie0-f175.google.com [209.85.223.175])
	by kanga.kvack.org (Postfix) with ESMTP id B184F6B0092
	for <linux-mm@kvack.org>; Mon,  5 Jan 2015 19:31:49 -0500 (EST)
Received: by mail-ie0-f175.google.com with SMTP id x19so200475ier.6
        for <linux-mm@kvack.org>; Mon, 05 Jan 2015 16:31:49 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id hg8si6106953igb.58.2015.01.05.16.31.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Jan 2015 16:31:48 -0800 (PST)
Date: Mon, 5 Jan 2015 16:31:46 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] fs: proc: task_mmu: show page size in
 /proc/<pid>/numa_maps
Message-Id: <20150105163146.c9576414bce83978278cb549@linux-foundation.org>
In-Reply-To: <20150106002134.GC28105@t510.redhat.com>
References: <734bca19b3a8f4e191ccc9055ad4740744b5b2b6.1420464466.git.aquini@redhat.com>
	<20150105133500.e0ce4b090e6b378c3edc9c56@linux-foundation.org>
	<20150105225504.GC1795@t510.redhat.com>
	<20150105152037.5a33e34652db6b82fcfd46bf@linux-foundation.org>
	<20150106002134.GC28105@t510.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-kernel@vger.kernel.org, jweiner@redhat.com, dave.hansen@linux.intel.com, rientjes@google.com, linux-mm@kvack.org

On Mon, 5 Jan 2015 19:21:35 -0500 Rafael Aquini <aquini@redhat.com> wrote:

> > > > 
> > > > 
> > > > > +	seq_printf(m, " kernelpagesize_kB=%lu", vma_kernel_pagesize(vma) >> 10);
> > > > 
> > > > This changes the format of the numa_maps file and can potentially break
> > > > existing parsers.  Please discuss.
> > 
> > ^^ ??
> >
> Sorry I overlooked it.
> 
> Parsers indeed would have to be adjusted to cope with an extra line element
> (they already have to do so, similarly, for the conditional 'huge' hint).
> Despite I don't think of it as a showstopper (as is), I think we can consider
> moving it to EOL, if its actual printout position turns out to be an issue.
>  
> 
> For instance, with this patch a numa_maps line would look like the following:
> 
>  7ff965200000 default file=/anon_hugepage\040(deleted) huge kernelpagesize_kB=2048 anon=5 dirty=5 N0=5
> 
> 
> or it could look like this, if we decide to switch kernelpagesize_kB position to EOL,
> for the sake of parsers:
> 
>  7ff965200000 default file=/anon_hugepage\040(deleted) huge anon=5 dirty=5 N0=5 kernelpagesize_kB=2048

hm, OK, numa_maps is actually a pretty complex thing: it's a
combination of `name' and `name=value'.  Some fields may be absent. 
Parsers need to fully parse each field and can't make assumptions based
on field number.

So yes, I agree that any parser which actually works is unlikely to
break due to this change.  However it's probably a bit safer to put the
new field at the end of the line.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
