Return-Path: <owner-linux-mm@kvack.org>
Date: Thu, 19 Dec 2013 14:53:52 -0500
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: bad page state in 3.13-rc4
Message-ID: <20131219195352.GB9228@kvack.org>
References: <20131219040738.GA10316@redhat.com> <CA+55aFwweoGs3eGWXFULcqnbRbpDhpj2qrefXB5OpQOiWW8wYA@mail.gmail.com> <20131219155313.GA25771@redhat.com> <CA+55aFyoXCDNfHb+r5b=CgKQLPA1wrU_Tmh4ROZNEt5TPjpODA@mail.gmail.com> <20131219181134.GC25385@kmo-pixel> <20131219182920.GG30640@kvack.org> <CA+55aFzCo_r7ZGHk+zqUjmCW2w7-7z9oxEJjhR66tZ4qZPxnvw@mail.gmail.com> <20131219192621.GA9228@kvack.org> <CA+55aFz=tEkVAx9VndtCXApDxcw+5T-BxMsVuXp+vMSb05f8Aw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFz=tEkVAx9VndtCXApDxcw+5T-BxMsVuXp+vMSb05f8Aw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kent Overstreet <kmo@daterainc.com>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@gentwo.org>, Al Viro <viro@zeniv.linux.org.uk>

On Fri, Dec 20, 2013 at 04:45:38AM +0900, Linus Torvalds wrote:
> On Fri, Dec 20, 2013 at 4:26 AM, Benjamin LaHaise <bcrl@kvack.org> wrote:
> >
> > Okay, I'll rewriting it to use truncate to free the pages.
> 
> It already does that in put_aio_ring_file() afaik. No?

Yes, that's what I found when I started looking into this in detail again.  
I think the page reference counting is actually correct.  There are 2 
references on each page: the first is from the find_or_create_page() call, 
and the second is from the get_user_pages() (which also makes sure the page 
is populated into the page tables).  The only place I can see things going 
off the rails is if the get_user_pages() call fails.  It's possible trinity 
could be arranging things so that the get_user_pages() call is failing 
somehow.  Also, if it were a double free of a page, we should at least get 
a VM_BUG() occuring when the page's count is 0.

Dave -- do you have CONFIG_DEBUG_VM on in your test rig?

>                 Linus

-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
