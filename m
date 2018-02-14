Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 49A396B0005
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 15:45:56 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id y187so13333521itc.8
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 12:45:56 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0141.hostedemail.com. [216.40.44.141])
        by mx.google.com with ESMTPS id v3si1951876itf.20.2018.02.14.12.45.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 12:45:55 -0800 (PST)
Message-ID: <1518641152.3678.28.camel@perches.com>
Subject: Re: [PATCH v2 2/8] mm: Add kvmalloc_ab_c and kvzalloc_struct
From: Joe Perches <joe@perches.com>
Date: Wed, 14 Feb 2018 12:45:52 -0800
In-Reply-To: <20180214201154.10186-3-willy@infradead.org>
References: <20180214201154.10186-1-willy@infradead.org>
	 <20180214201154.10186-3-willy@infradead.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Wed, 2018-02-14 at 12:11 -0800, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> We have kvmalloc_array in order to safely allocate an array with a
> number of elements specified by userspace (avoiding arithmetic overflow
> leading to a buffer overrun).  But it's fairly common to have a header
> in front of that array (eg specifying the length of the array), so we
> need a helper function for that situation.
> 
> kvmalloc_ab_c() is the workhorse that does the calculation, but in spite
> of our best efforts to name the arguments, it's really hard to remember
> which order to put the arguments in.  kvzalloc_struct() eliminates that
> effort; you tell it about the struct you're allocating, and it puts the
> arguments in the right order for you (and checks that the arguments
> you've given are at least plausible).
> 
> For comparison between the three schemes:
> 
> 	sev = kvzalloc(sizeof(*sev) + sizeof(struct v4l2_kevent) * elems,
> 			GFP_KERNEL);
> 	sev = kvzalloc_ab_c(elems, sizeof(struct v4l2_kevent), sizeof(*sev),
> 			GFP_KERNEL);
> 	sev = kvzalloc_struct(sev, events, elems, GFP_KERNEL);

Perhaps kv[zm]alloc_buf_and_array is better naming.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
