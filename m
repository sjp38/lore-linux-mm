Date: Fri, 2 Dec 2005 17:46:45 -0500
From: "Frank Ch. Eigler" <fche@redhat.com>
Subject: Re: Better pagecache statistics ?
Message-ID: <20051202224645.GB6576@redhat.com>
References: <20051201152029.GA14499@dmt.cnet> <1133452790.27824.117.camel@localhost.localdomain> <1133453411.2853.67.camel@laptopd505.fenrus.org> <20051201170850.GA16235@dmt.cnet> <1133457315.21429.29.camel@localhost.localdomain> <1133457700.2853.78.camel@laptopd505.fenrus.org> <20051201175711.GA17169@dmt.cnet> <1133461212.21429.49.camel@localhost.localdomain> <y0md5kfxi15.fsf@tooth.toronto.redhat.com> <1133562716.21429.103.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1133562716.21429.103.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Arjan van de Ven <arjan@infradead.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi -

On Fri, Dec 02, 2005 at 02:31:56PM -0800, Badari Pulavarty wrote:
> On Fri, 2005-12-02 at 17:15 -0500, Frank Ch. Eigler wrote:
> [...]
> > #! stap
> > probe kernel.function("add_to_page_cache") {
> >   printf("pid %d added pages (%d)\n", pid(), $mapping->nrpages)
> > }
> > probe kernel.function("__remove_from_page_cache") {
> >   printf("pid %d removed pages (%d)\n", pid(), $page->mapping->nrpages)
> > }
>
> [...]  Having by "pid" basis is not good enough. I need per
> file/mapping basis collected and sent to user-space on-demand.

If you can characterize all your data needs in terms of points to
insert hooks (breakpoint addresses) and expressions to sample there,
systemtap scripts can probably track the relationships.  (We have
associative arrays, looping, etc.)

> Is systemtap hooked to relayfs to send data across to user-land ?
> printf() is not an option.

systemtap can optionally use relayfs.  The printf you see here does
not relate to/invoke the kernel printk, if that's what you're worried
about.

> And also, I need to have this probe, installed from the boot time
> and collecting all the information - so I can access it when I need
> it

We haven't done much work yet to address on-demand kind of interaction
with a systemtap probe session.  However, one could fake it by
associating data-printing operations with events that are triggered
purposely from userspace, like running a particular system call from a
particularly named process.

> which means this bloats kernel memory. [...]

The degree of bloat is under the operator's control: systemtap only
uses initialization-time memory allocation, so its arrays can fill up.


- FChE

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
