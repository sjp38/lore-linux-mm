Received: by ug-out-1314.google.com with SMTP id s2so1110231uge
        for <linux-mm@kvack.org>; Wed, 21 Feb 2007 08:46:21 -0800 (PST)
Message-ID: <45a44e480702210846u218045bmfe6854fb894d7bbd@mail.gmail.com>
Date: Wed, 21 Feb 2007 11:46:21 -0500
From: "Jaya Kumar" <jayakumar.lkml@gmail.com>
Subject: Re: [PATCH 2.6.20 1/1] fbdev,mm: hecuba/E-Ink fbdev driver
In-Reply-To: <45a44e480702192211i78b8f4b1lecb3dfc284fb9eea@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070217104215.GB25512@localhost> <1171715652.5186.7.camel@lappy>
	 <45a44e480702170525n9a15fafpb370cb93f1c1fcba@mail.gmail.com>
	 <20070217135922.GA15373@linux-sh.org>
	 <45a44e480702180331t7e76c396j1a9861f689d4186b@mail.gmail.com>
	 <20070218235741.GA22298@linux-sh.org>
	 <45a44e480702192013s7d49d05ai31e576f0448a485e@mail.gmail.com>
	 <20070220043848.GA4092@linux-sh.org>
	 <45a44e480702192211i78b8f4b1lecb3dfc284fb9eea@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>, Jaya Kumar <jayakumar.lkml@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-fbdev-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jsimmons@infradead.org, Geert.Uytterhoeven@sonycom.com
List-ID: <linux-mm.kvack.org>

On 2/20/07, Jaya Kumar <jayakumar.lkml@gmail.com> wrote:
> On 2/19/07, Paul Mundt <lethal@linux-sh.org> wrote:
> > That works for me, though I'd prefer for struct page_list to be done with
> > a scatterlist, then it's trivial to setup from the workqueue context
> > without having to shuffle things around.
> >
>
> Ok. Will check out when implementing.
>

Took  a quick look. If I used scatterlist, I'd still need to build a
list of scatterlist to pass to the driver callback. The alternative
being a preallocated array of scatterlist based on the page count of
the framebuffer, which seems expensive since scatterlist has page,
offset, dma and length.

On a separate note, Peter pointed out that it may be possible to reuse
page->lru instead of using a struct page_list. This would enable
something like:

in mkwrite:
mutex_lock
list_add(page->lru, defio->pagelist)
mutex_unlock

in deferred handler:
mutex_lock
for_each page {
lock_page
mkclean
unlock_page
}
callback(fb_info, pagelist)
for_each page {
list_del
}
mutex_unlock

The advantage of reusing page->lru is that avoids needing the struct
page_list and allocation in mkwrite. Is the above exploitation of
->lru ok with mm folk?

In above, we're iterating over the page list twice. I have to mkclean
before calling the callback to avoid the situation where a touched
page is missed by the callback. I don't see a way around that part.

Thanks,
jaya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
