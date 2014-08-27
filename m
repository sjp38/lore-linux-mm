Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id C9ABC6B0039
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 19:37:48 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id et14so36961pad.16
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 16:37:48 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id lr3si3145815pab.140.2014.08.27.16.37.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Aug 2014 16:37:47 -0700 (PDT)
Date: Wed, 27 Aug 2014 16:37:45 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] x86: Optimize resource lookups for ioremap
Message-Id: <20140827163745.774e9b5c591e8f9cf7542a4d@linux-foundation.org>
In-Reply-To: <53FE68E4.4090902@sgi.com>
References: <20140827225927.364537333@asylum.americas.sgi.com>
	<20140827225927.602319674@asylum.americas.sgi.com>
	<20140827160515.c59f1c191fde5f788a7c42f6@linux-foundation.org>
	<53FE6515.6050102@sgi.com>
	<20140827161854.0619a04653b336d3adc755f3@linux-foundation.org>
	<53FE68E4.4090902@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: mingo@redhat.com, tglx@linutronix.de, hpa@zytor.com, msalter@redhat.com, dyoung@redhat.com, riel@redhat.com, peterz@infradead.org, mgorman@suse.de, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Alex Thorlton <athorlton@sgi.com>

On Wed, 27 Aug 2014 16:25:24 -0700 Mike Travis <travis@sgi.com> wrote:

> > 
> > <looks at the code>
> > 
> > Doing strcmp("System RAM") is rather a hack.  Is there nothing in
> > resource.flags which can be used?  Or added otherwise?
> 
> I agree except this mimics the page_is_ram function:
> 
>         while ((res.start < res.end) &&
>                 (find_next_iomem_res(&res, "System RAM", true) >= 0)) {

Yeah.  Sigh.

> So it passes the same literal string which then find_next does the
> same strcmp on it:
> 
>                 if (p->flags != res->flags)
>                         continue;
>                 if (name && strcmp(p->name, name))
>                         continue;
> 
> I should add back in the check to insure name is not NULL.

If we're still at 1+ hours then little bodges like this are nowhere
near sufficient and sterner stuff will be needed.

Do we actually need the test?  My googling turns up zero instances of
anyone reporting the "ioremap on RAM pfn" warning.

Where's the rest of the time being spent?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
