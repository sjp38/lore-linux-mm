Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6557F6B0007
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 16:24:14 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id l16so13316000iti.4
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 13:24:14 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0250.hostedemail.com. [216.40.44.250])
        by mx.google.com with ESMTPS id c127si7251911itc.82.2018.02.14.13.24.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 13:24:13 -0800 (PST)
Message-ID: <1518643449.3678.33.camel@perches.com>
Subject: Re: [PATCH v2 2/8] mm: Add kvmalloc_ab_c and kvzalloc_struct
From: Joe Perches <joe@perches.com>
Date: Wed, 14 Feb 2018 13:24:09 -0800
In-Reply-To: <20180214211203.GF20627@bombadil.infradead.org>
References: <20180214201154.10186-1-willy@infradead.org>
	 <20180214201154.10186-3-willy@infradead.org>
	 <1518641152.3678.28.camel@perches.com>
	 <20180214211203.GF20627@bombadil.infradead.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, linux-mm@kvack.org, Kees Cook <keescook@chromium.org>, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Wed, 2018-02-14 at 13:12 -0800, Matthew Wilcox wrote:
> On Wed, Feb 14, 2018 at 12:45:52PM -0800, Joe Perches wrote:
> > On Wed, 2018-02-14 at 12:11 -0800, Matthew Wilcox wrote:
> > > We have kvmalloc_array in order to safely allocate an array with a
> > > number of elements specified by userspace (avoiding arithmetic overflow
> > > leading to a buffer overrun).  But it's fairly common to have a header
> > > in front of that array (eg specifying the length of the array), so we
> > > need a helper function for that situation.
> > > 
> > > kvmalloc_ab_c() is the workhorse that does the calculation, but in spite
> > > of our best efforts to name the arguments, it's really hard to remember
> > > which order to put the arguments in.  kvzalloc_struct() eliminates that
> > > effort; you tell it about the struct you're allocating, and it puts the
> > > arguments in the right order for you (and checks that the arguments
> > > you've given are at least plausible).
> > > 
> > > For comparison between the three schemes:
> > > 
> > > 	sev = kvzalloc(sizeof(*sev) + sizeof(struct v4l2_kevent) * elems,
> > > 			GFP_KERNEL);
> > > 	sev = kvzalloc_ab_c(elems, sizeof(struct v4l2_kevent), sizeof(*sev),
> > > 			GFP_KERNEL);
> > > 	sev = kvzalloc_struct(sev, events, elems, GFP_KERNEL);
> > 
> > Perhaps kv[zm]alloc_buf_and_array is better naming.
> 
> I think that's actively misleading.  The programmer isn't allocating a
> buf, they're allocating a struct.  kvzalloc_hdr_arr was the earlier name,
> and that made some sense; they're allocating an array with a header.
> But nobody thinks about it like that; they're allocating a structure
> with a variably sized array at the end of it.
> 
> If C macros had decent introspection, I'd like it to be:
> 
> 	sev = kvzalloc_struct(elems, GFP_KERNEL);
> 
> and have the macro examine the structure pointed to by 'sev', check
> the last element was an array, calculate the size of the array element,
> and call kvzalloc_ab_c.  But we don't live in that world, so I have to
> get the programmer to tell me the structure and the name of the last
> element in it.

Look at your patch 4

-       dev_dax = kzalloc(sizeof(*dev_dax) + sizeof(*res) * count, GFP_KERNEL);
+       dev_dax = kvzalloc_struct(dev_dax, res, count, GFP_KERNEL);

Here what is being allocated is exactly a struct
and an array.

And this doesn't compile either.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
