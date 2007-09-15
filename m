Received: by rv-out-0910.google.com with SMTP id l15so680146rvb
        for <linux-mm@kvack.org>; Fri, 14 Sep 2007 17:16:07 -0700 (PDT)
Message-ID: <a781481a0709141716n569d54eeqbe51746d3a5110ca@mail.gmail.com>
Date: Sat, 15 Sep 2007 05:46:07 +0530
From: "Satyam Sharma" <satyam.sharma@gmail.com>
Subject: Re: [PATCH 1/6] cpuset write dirty map
In-Reply-To: <20070914170733.dbe89493.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <469D3342.3080405@google.com> <46E741B1.4030100@google.com>
	 <46E742A2.9040006@google.com>
	 <20070914161536.3ec5c533.akpm@linux-foundation.org>
	 <a781481a0709141647q3d019423s388c64bf6bed871a@mail.gmail.com>
	 <20070914170733.dbe89493.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ethan Solomita <solo@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On 9/15/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> On Sat, 15 Sep 2007 05:17:48 +0530
> "Satyam Sharma" <satyam.sharma@gmail.com> wrote:
>
> > > It's unobvious why the break point is at MAX_NUMNODES = BITS_PER_LONG and
> > > we might want to tweak that in the future.  Yet another argument for
> > > centralising this comparison.
> >
> > Looks like just an optimization to me ... Ethan wants to economize and not bloat
> > struct address_space too much.
> >
> > So, if sizeof(nodemask_t) == sizeof(long), i.e. when:
> > MAX_NUMNODES <= BITS_PER_LONG, then we'll be adding only sizeof(long)
> > extra bytes to the struct (by plonking the object itself into it).
> >
> > But even when MAX_NUMNODES > BITS_PER_LONG, because we're storing
> > a pointer, and because sizeof(void *) == sizeof(long), so again the maximum
> > bloat addition to struct address_space would only be sizeof(long) bytes.
>
> yup.
>
> Note that "It's unobvious" != "It's unobvious to me".  I review code for
> understandability-by-others, not for understandability-by-me.
>
> > I didn't see the original mail, but if the #ifdeffery for this
> > conditional is too much
> > as a result of this optimization, Ethan should probably just do away
> > with all of it
> > entirely, and simply put a full nodemask_t object (irrespective of MAX_NUMNODES)
> > into the struct. After all, struct task_struct does the same unconditionally ...
> > but admittedly, there are several times more address_space struct's resident in
> > memory at any given time than there are task_struct's, so this optimization does
> > make sense too ...
>
> I think the optimisation is (probably) desirable, but it would be best to
> describe the tradeoff in the changelog and to add some suitable
> code-commentary for those who read the code in a year's time and to avoid
> sprinkling the logic all over the tree.

True, the other option could be to put the /pointer/ in there unconditionally,
but that would slow down the MAX_NUMNODES <= BITS_PER_LONG case,
which (after grepping through defconfigs) appears to be the common case on
all archs other than ia64. So I think your idea of making that conditional
centralized in the code with an accompanying comment is the way to go here ...


Satyam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
